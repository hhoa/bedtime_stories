#!/usr/bin/env python3
"""Remove steady background noise (fan, air con, room hum, hiss) from one recording.

Spectral gating, Wiener-style spectral subtraction:
  1. learn the noise: the clip's own pauses (quietest 100 ms windows, digital
     silence skipped) give each frequency's noise level and spread
  2. per short frame (43 ms) and frequency, take away the noise's share
     (Wiener-style gain, a little extra so the pauses go quiet), never more
     than --reduce dB
  3. smooth the gains over time and frequency so they never warble
     ("musical noise"), then rebuild the audio

The voice itself is never filtered, only the noise around and between words,
so the recording keeps its own sound. Steady noise only: a dog bark or a car
horn is not learned and stays.

  tool/cutout/.venv/bin/python tool/denoise.py in.wav out.wav [--reduce 24]

Reads anything ffmpeg reads, writes 32-bit float WAV at the input's rate.
Prints the noise level it learned and how much it turned down. Used by
tool/clean_audio.py; needs numpy + scipy (use tool/cutout/.venv/bin/python).
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys

import numpy as np
from scipy.ndimage import uniform_filter
from scipy.signal import istft, stft

RATE = 48000
N_FFT, HOP = 2048, 512
WIN = 0.1           # pause search window (s)
QUIET_PCT = 20      # pauses = this quietest share of the non-silent windows
OVER = 3.0          # subtract this many times the noise power (quieter pauses, voice -0.5 dB at most)
SMOOTH_F, SMOOTH_T = 5, 7  # power smoothing: bins (~117 Hz) x frames (~75 ms)


def load(path: str) -> np.ndarray:
    raw = subprocess.run(['ffmpeg', '-loglevel', 'error', '-i', path, '-ac', '1', '-ar', str(RATE),
                          '-f', 'f32le', '-'], capture_output=True, check=True).stdout
    return np.frombuffer(raw, np.float32).astype(np.float64)


def save(path: str, x: np.ndarray) -> None:
    subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-f', 'f32le', '-ar', str(RATE), '-ac', '1',
                    '-i', '-', '-c:a', 'pcm_f32le', path],
                   input=x.astype(np.float32).tobytes(), check=True)


def windows_db(x: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    """(100 ms windows, their level in dB)."""
    n = int(RATE * WIN)
    w = x[:len(x) // n * n].reshape(-1, n)
    return w, 10 * np.log10((w ** 2).mean(1) + 1e-20)


def pauses(x: np.ndarray) -> tuple[np.ndarray, float] | None:
    """(which windows are pauses, voice level dB), or None when nothing to learn from."""
    _, db = windows_db(x)
    live = db > -100  # phone recordings start with digital zeros: not noise
    if live.sum() < 5:
        return None
    quiet = live & (db <= np.percentile(db[live], QUIET_PCT))
    voice = float(np.percentile(db[live], 90))
    # The voice must be well above the pauses, else there is nothing to learn.
    if quiet.sum() < 3 or voice - db[quiet].mean() < 8:
        return None
    return quiet, voice


def denoise(x: np.ndarray, reduce_db: float) -> tuple[np.ndarray, dict]:
    found = pauses(x)
    if found is None:
        return x, {'denoised': False}
    quiet, voice = found
    w, db = windows_db(x)
    _, _, N = stft(w[quiet].ravel(), RATE, nperseg=N_FFT, noverlap=N_FFT - HOP)
    pn = (np.abs(N) ** 2).mean(1)[:, None]  # noise power per frequency

    _, _, X = stft(x, RATE, nperseg=N_FFT, noverlap=N_FFT - HOP)
    px = uniform_filter(np.abs(X) ** 2, size=(SMOOTH_F, SMOOTH_T), mode='nearest')
    # Wiener-style gain: take away the noise's share of each bin (a bit more,
    # OVER, so the pauses really go quiet), never below the floor.
    floor = 10 ** (-reduce_db / 20)
    gain = np.sqrt(np.clip(1 - OVER * pn / np.maximum(px, 1e-20), 0, 1))
    gain = np.maximum(uniform_filter(gain, size=(3, SMOOTH_T), mode='nearest'), floor)
    _, y = istft(X * gain, RATE, nperseg=N_FFT, noverlap=N_FFT - HOP)
    y = np.pad(y[:len(x)], (0, max(0, len(x) - len(y))))

    _, ydb = windows_db(y)
    before = 10 * np.log10((10 ** (db[quiet] / 10)).mean())
    after = 10 * np.log10((10 ** (ydb[quiet] / 10)).mean())
    # snr = how far the pauses sit under the voice, before and after
    return y, {'denoised': True, 'snr': [round(voice - before, 1), round(voice - after, 1)]}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('src')
    ap.add_argument('dst')
    ap.add_argument('--reduce', type=float, default=24.0,
                    help='most the noise is turned down, dB (default 24)')
    args = ap.parse_args()
    x = load(args.src)
    y, info = denoise(x, args.reduce)
    save(args.dst, y)
    print(json.dumps(info))
    return 0


if __name__ == '__main__':
    sys.exit(main())
