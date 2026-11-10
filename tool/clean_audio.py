"""Clean the parent's narration recordings: trim, denoise, even loudness (ffmpeg).

Run it every time new recordings land in a story's audio/<lang>/ folder.
For each new clip:

  1. denoise   high-pass at 60 Hz, then tool/denoise.py: learns the steady
               background noise (fan, air con, hiss) from the clip's own
               pauses and takes it away, frequency by frequency; the voice
               stays as recorded (about -0.5 dB). Pauses end up ~15-20 dB
               quieter. Needs tool/cutout/.venv (numpy + scipy).
  2. trim      cut silence, breaths and record-button clicks at both ends,
               keeping 0.05 s before the first word and 0.15 s after the last,
               with tiny fades so the cut never clicks
  3. loudness  gain toward -16 LUFS; a peak limiter at -2 dB may shave the
               loudest word by at most 6 dB (more flattens the voice), so a
               clip with sharp peaks stays a little softer (down to -20 LUFS)
  4. encode    mono AAC 64k with Apple's encoder (aac_at, as the phone uses;
               ffmpeg's own when missing). Keeps a bilingual story small.

Noise is measured in float from real pauses: phones start a recording with
digital silence, which once passed for "no noise" and skipped the denoise.

Recordings may be saved as .m4a, .wav, .mp3, .aiff or .caf under the clip's
name; they come out as .m4a.

Originals are copied to audio_backup/<asset path> and never changed. Each run
starts from that original, so re-running never stacks. audio_backup/cleaned.json
remembers each finished clip by hash: a clip whose file changed (a new take
under the same name) counts as new again. gen_audio.py registers the clips it
makes there, so cloned clips are not treated as recordings.

Every finished clip also carries the tag comment=bedtime_stories_cleaned
inside the .m4a. audio_backup/ is not in git, so on a fresh clone the hash
list is empty: the tag is what stops already-cleaned clips from being
denoised a second time. A new phone recording has no tag, so it still counts
as new. Clips cleaned before the tag existed get it (no re-encode) on the next
clean run.

  python3 tool/clean_audio.py --story <id>          # clean new recordings
  python3 tool/clean_audio.py --story <id> --redo   # re-clean all from originals
  python3 tool/clean_audio.py --check [--story <id>]  # report levels, change nothing
  python3 tool/clean_audio.py --restore [--story <id>]  # put the originals back
  python3 tool/clean_audio.py --ui                  # shared clips (assets/audio/ui)
  python3 tool/clean_audio.py ... --denoise 0       # most noise turned down, dB (default 24, 0 = off)
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import re
import shutil
import subprocess
import sys
import tempfile
from array import array
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
STORIES = ROOT / 'assets' / 'stories'
UI_AUDIO = ROOT / 'assets' / 'audio' / 'ui'
BACKUP = ROOT / 'audio_backup'
MANIFEST = BACKUP / 'cleaned.json'
EXT = 'm4a'  # keep in sync with AppConstants.audioExt
RAW_EXTS = ('m4a', 'wav', 'mp3', 'aiff', 'aif', 'caf', 'aac')

TARGET_I, TARGET_TP = -16.0, -1.5
LIMIT_DB = -2.0  # limiter ceiling (sample peak), keeps true peak under TARGET_TP
MAX_SQUASH = 6.0  # most dB the limiter may take off the loudest word; a clip
                  # with sharper peaks ends up a little under TARGET_I instead
DENOISE_DB = 24.0  # most the background noise is turned down (tool/denoise.py)
DENOISE_PY = ROOT / 'tool' / 'cutout' / '.venv' / 'bin' / 'python'  # numpy + scipy
SILENCE_BELOW, MIN_SILENCE = 25.0, 0.2  # silence = this far under the voice, this long
LEAD, TAIL, FADE = 0.05, 0.15, 0.015  # seconds kept / faded at the edges
MAX_BYTES = 150 * 1024  # keep in sync with AUDIO_MAX in check_assets.py
CLEAN_TAG = 'bedtime_stories_cleaned'  # m4a comment on every finished clip

# --check limits
OK_I = (-20.0, -14.0)
MAX_TP = -1.0
MIN_SNR = 30.0  # dB between the voice and the quiet parts
MAX_LEAD, MAX_TAIL = 0.3, 0.4
SOFT_PEAK = -6.0

WIN = 0.02  # analysis window (s)
DIGITAL_SILENCE = -100.0  # windows below this are exact zeros, not noise
RATE = 16000  # analysis sample rate


# ---------- measuring ----------

def run(cmd: list[str]) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, capture_output=True, check=True)


def levels(path: Path) -> tuple[float, float]:
    """(mean, peak) in dBFS."""
    out = run(['ffmpeg', '-hide_banner', '-nostats', '-i', str(path),
               '-af', 'volumedetect', '-f', 'null', '-']).stderr.decode()
    mean = float(re.search(r'mean_volume: (-?[\d.]+) dB', out).group(1))
    peak = float(re.search(r'max_volume: (-?[\d.]+) dB', out).group(1))
    return mean, peak


def loudness(path: Path) -> tuple[float, float] | None:
    """(integrated LUFS, true peak dBTP), or None when too short to measure."""
    out = run(['ffmpeg', '-hide_banner', '-nostats', '-i', str(path),
               '-af', 'loudnorm=print_format=json', '-f', 'null', '-']).stderr.decode()
    m = re.search(r'\{[^{}]*"input_i"[^{}]*\}', out, re.S)
    if not m:
        return None
    data = json.loads(m.group(0))
    try:
        i, tp = float(data['input_i']), float(data['input_tp'])
    except ValueError:
        return None
    if abs(i) == float('inf') or abs(tp) == float('inf'):
        return None
    return i, tp


def window_db(path: Path) -> list[float]:
    """Loudness of each 20 ms window, in dBFS (float: a very soft recording's
    noise would round to digital silence in 16 bit)."""
    raw = run(['ffmpeg', '-hide_banner', '-loglevel', 'error', '-i', str(path),
               '-ac', '1', '-ar', str(RATE), '-f', 'f32le', '-']).stdout
    pcm = array('f')
    pcm.frombytes(raw[:len(raw) // 4 * 4])
    if sys.byteorder == 'big':
        pcm.byteswap()
    n = int(RATE * WIN)
    out = []
    for s in range(0, len(pcm) - n + 1, n):
        chunk = pcm[s:s + n]
        ms = sum(v * v for v in chunk) / n
        out.append(10 * math.log10(ms) if ms > 1e-12 else -120.0)
    return out


def pct(values: list[float], p: float) -> float:
    s = sorted(values)
    return s[min(len(s) - 1, int(len(s) * p))] if s else -120.0


class Shape:
    """Noise floor, speech level and where the speech starts and ends.

    The floor is measured only from real silence: at least 0.2 s of windows
    more than SILENCE_BELOW dB under the voice (a hand recording always has
    some before and after the words). Clips with no silence (cloned or already
    trimmed) get floor None: their softest syllables are not noise.
    """

    def __init__(self, path: Path):
        db = window_db(path)
        self.duration = len(db) * WIN
        self.speech = pct(db, 0.95)
        # Digital silence (phones start a recording with it) is not the room's
        # noise: measuring the floor from it hid real noise before.
        quiet = sorted(d for d in db if DIGITAL_SILENCE < d < self.speech - SILENCE_BELOW)
        self.floor = quiet[len(quiet) // 2] if len(quiet) >= MIN_SILENCE / WIN else None
        # Speech = windows clearly above the noise (or, with no silence to
        # measure, anything not near-silent). Needs 3 windows in a row (60 ms),
        # so a record-button click or a lip smack doesn't count.
        if self.floor is not None:
            thr = min(self.floor + 10, self.speech - 20)
        else:
            thr = max(self.speech - 40, -70.0)
        loud = [d > thr for d in db]
        runs = [i for i in range(len(loud) - 2) if loud[i] and loud[i + 1] and loud[i + 2]]
        if runs:
            self.start = runs[0] * WIN
            self.end = (runs[-1] + 3) * WIN
        else:
            self.start, self.end = 0.0, self.duration

    @property
    def snr(self) -> float | None:
        return None if self.floor is None else self.speech - self.floor

    @property
    def lead(self) -> float:
        return self.start

    @property
    def tail(self) -> float:
        return self.duration - self.end


# ---------- files ----------

def clip_dirs(args) -> list[Path]:
    if args.story:
        return [STORIES / args.story / 'audio']
    if args.ui:
        return [UI_AUDIO]
    ids = json.loads((STORIES / 'index.json').read_text())['stories']
    return [STORIES / i / 'audio' for i in ids] + [UI_AUDIO]


def sources(dirs: list[Path]) -> list[Path]:
    """Every audio file in the folders (recursive: audio/vi, audio/en)."""
    found = []
    for d in dirs:
        if d.is_dir():
            found += [f for f in d.rglob('*') if f.is_file()
                      and f.suffix.lower().lstrip('.') in RAW_EXTS]
    return sorted(found)


def clips(dirs: list[Path]) -> list[Path]:
    return [c for c in sources(dirs) if c.suffix == f'.{EXT}']


def key(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def sha1(path: Path) -> str:
    return hashlib.sha1(path.read_bytes()).hexdigest()


def load_manifest() -> dict:
    return json.loads(MANIFEST.read_text()) if MANIFEST.exists() else {}


def save_manifest(data: dict) -> None:
    BACKUP.mkdir(parents=True, exist_ok=True)
    MANIFEST.write_text(json.dumps(data, indent=1, sort_keys=True, ensure_ascii=False) + '\n')


def is_asset(path: Path) -> bool:
    p = path.resolve()
    return any(p.is_relative_to(d) for d in (STORIES, UI_AUDIO))


def mark_cleaned(path: Path, generated: bool = True) -> None:
    """Record a finished clip (gen_audio.py calls this for clips it makes)."""
    if not is_asset(path):
        return  # trial output (--out), not an app clip
    data = load_manifest()
    data[key(path)] = {'sha1': sha1(path), 'generated': generated}
    save_manifest(data)


def has_tag(path: Path) -> bool:
    out = subprocess.run(['ffprobe', '-v', 'error', '-show_entries', 'format_tags=comment',
                          '-of', 'default=nw=1:nk=1', str(path)],
                         capture_output=True, text=True).stdout
    return CLEAN_TAG in out


def add_tag(path: Path) -> None:
    """Tag a finished clip in place (stream copy: same audio)."""
    with tempfile.TemporaryDirectory() as tmp:
        out = Path(tmp) / f'clip.{EXT}'
        run(['ffmpeg', '-y', '-loglevel', 'error', '-i', str(path), '-map', '0',
             '-c', 'copy', '-metadata', f'comment={CLEAN_TAG}', str(out)])
        shutil.move(str(out), path)


def is_new(src: Path, manifest: dict) -> bool:
    if src.suffix != f'.{EXT}':
        return True
    entry = manifest.get(key(src))
    if entry and entry['sha1'] == sha1(src):
        return False
    return not has_tag(src)  # cleaned on another machine / backup folder lost


def tag_old_clips(files: list[Path], manifest: dict) -> None:
    """Clips cleaned before CLEAN_TAG existed: add it, keep the hash list right."""
    done = 0
    for f in files:
        entry = manifest.get(key(f))
        if f.suffix == f'.{EXT}' and entry and entry['sha1'] == sha1(f) and not has_tag(f):
            add_tag(f)
            entry['sha1'] = sha1(f)
            done += 1
    if done:
        save_manifest(manifest)
        print(f'Tagged {done} clip(s) cleaned before the cleaned tag existed (audio unchanged).')


# ---------- cleaning ----------

_AAC: str | None = None


def aac_encoder() -> str:
    """Apple's AAC encoder (the one phones record with) when ffmpeg has it:
    clearer than ffmpeg's own at the same bitrate."""
    global _AAC
    if _AAC is None:
        out = run(['ffmpeg', '-hide_banner', '-encoders']).stdout.decode()
        _AAC = 'aac_at' if re.search(r'\baac_at\b', out) else 'aac'
    return _AAC


def encode(src: Path, dst: Path, af: str) -> None:
    with tempfile.TemporaryDirectory() as tmp:
        out = Path(tmp) / f'clip.{EXT}'
        run(['ffmpeg', '-y', '-loglevel', 'error', '-i', str(src), '-af', af,
             '-ac', '1', '-codec:a', aac_encoder(), '-b:a', '64k',
             '-metadata', f'comment={CLEAN_TAG}', str(out)])
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(out), dst)


def boost(src: Path, dst: Path) -> float:
    """Level a cloned clip (gen_audio.py): gain toward TARGET_I, up or down,
    then the same peak limiter as clean(). No denoise or trim. Some clone
    voices come out hot (peaks over 0 dB), so plain boost-only gain clipped.
    """
    measured = loudness(src)
    peak = levels(src)[1]
    gain = (TARGET_I - measured[0]) if measured else (LIMIT_DB - peak)
    gain = min(gain, LIMIT_DB - peak + MAX_SQUASH)
    gain = min(max(gain, -20.0), 35.0)
    with tempfile.TemporaryDirectory() as tmp:
        # dst may be src: read from a copy.
        tmp_src = Path(tmp) / f'src{src.suffix}'
        shutil.copy(src, tmp_src)
        ceiling = LIMIT_DB
        for _ in range(4):
            encode(tmp_src, dst, f'volume={gain:.2f}dB,alimiter=limit='
                   f'{10 ** (ceiling / 20):.4f}:attack=5:release=50:level=0:latency=1')
            after = loudness(dst)
            over = (after[1] if after else levels(dst)[1]) - TARGET_TP
            if over <= 0 or ceiling < -12:
                break
            ceiling -= over + 0.3
    return gain


def denoise(src: Path, dst: Path, reduce_db: float) -> dict:
    """tool/denoise.py: learn the steady noise from the pauses, turn it down."""
    if reduce_db <= 0 or not DENOISE_PY.exists():
        if reduce_db > 0:
            print('  (no tool/cutout/.venv: not denoised; run tool/cutout/setup.sh)')
        run(['ffmpeg', '-y', '-loglevel', 'error', '-i', str(src), '-ac', '1', '-ar', '48000',
             '-c:a', 'pcm_f32le', str(dst)])
        return {'denoised': False}
    out = run([str(DENOISE_PY), '-I', str(ROOT / 'tool' / 'denoise.py'), '--reduce', f'{reduce_db:g}',
               str(src), str(dst)]).stdout.decode()
    return json.loads(out.strip().splitlines()[-1])


def clean(src: Path, dst: Path, nr: float) -> dict:
    """Denoise, trim and level one recording. Returns before/after numbers."""
    before = Shape(src)
    before_i = loudness(src)
    with tempfile.TemporaryDirectory() as tmp:
        raw = Path(tmp) / 'raw.wav'
        den = Path(tmp) / 'den.wav'
        # Only rumble below 60 Hz goes by filter; the rest is the voice as recorded.
        run(['ffmpeg', '-y', '-loglevel', 'error', '-i', str(src), '-af', 'highpass=f=60',
             '-ac', '1', '-ar', '48000', '-c:a', 'pcm_f32le', str(raw)])
        dn = denoise(raw, den, nr)
        shape = Shape(den)
        start = max(shape.start - LEAD, 0.0)
        end = min(shape.end + TAIL, shape.duration)
        length = end - start

        trimmed = Path(tmp) / 'trim.wav'
        run(['ffmpeg', '-y', '-loglevel', 'error', '-i', str(den), '-af',
             f'atrim=start={start:.3f}:end={end:.3f},asetpts=PTS-STARTPTS,'
             f'afade=t=in:d={FADE},afade=t=out:st={max(length - FADE, 0):.3f}:d={FADE}',
             '-c:a', 'pcm_f32le', str(trimmed)])

        measured = loudness(trimmed)
        peak = levels(trimmed)[1]
        gain = (TARGET_I - measured[0]) if measured else (LIMIT_DB - peak)
        # The limiter may only shave the loudest words a little (MAX_SQUASH):
        # more flattens the voice. Sharper clips stay a bit under TARGET_I.
        gain = min(gain, LIMIT_DB - peak + MAX_SQUASH)
        gain = min(max(gain, -20.0), 35.0)
        # AAC can overshoot the limiter on sharp sounds: measure the true
        # peak after encoding and lower the ceiling until it fits.
        ceiling = LIMIT_DB
        for _ in range(4):
            encode(trimmed, dst, f'volume={gain:.2f}dB,alimiter=limit='
                   f'{10 ** (ceiling / 20):.4f}:attack=5:release=50:level=0:latency=1')
            after_i = loudness(dst)
            over = (after_i[1] if after_i else levels(dst)[1]) - TARGET_TP
            if over <= 0 or ceiling < -12:
                break
            ceiling -= over + 0.3

    snr = tuple(dn['snr']) if dn.get('denoised') else (before.snr, before.snr)
    return {'cut_lead': start, 'cut_tail': before.duration - end, 'denoised': dn.get('denoised', False),
            'snr': snr,
            'lufs': (before_i[0] if before_i else None, after_i[0] if after_i else None),
            'peak': after_i[1] if after_i else levels(dst)[1], 'gain': gain}


def backup_of(src: Path) -> Path:
    return BACKUP / src.relative_to(ROOT)


def fmt(v: float | None) -> str:
    return '  ?  ' if v is None else f'{v:5.1f}'


def do_clean(files: list[Path], redo: bool, nr: float) -> int:
    manifest = load_manifest()
    tag_old_clips(files, manifest)
    jobs = []  # (original in backup, clip path)
    for src in files:
        dst = src.with_suffix(f'.{EXT}')
        entry = manifest.get(key(dst))
        if is_new(src, manifest):
            b = backup_of(src)
            b.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, b)
            jobs.append((b, src, dst))
        elif redo and entry and entry.get('original'):
            jobs.append((ROOT / entry['original'], src, dst))
    if not jobs:
        print('No new recordings to clean.')
        return 0
    flagged = 0
    for orig, src, dst in jobs:
        r = clean(orig, dst, nr)
        if src != dst:
            src.unlink()  # .wav/.mp3 → .m4a; the original stays in the backup
        manifest[key(dst)] = {'sha1': sha1(dst), 'original': key(orig), 'snr': r['snr'][1]}
        save_manifest(manifest)
        warn = problems(dst, quick=r)
        flagged += bool(warn)
        print(f'  {key(dst)}  cut {r["cut_lead"]:.2f}s + {r["cut_tail"]:.2f}s'
              + (f'  noise {fmt(r["snr"][0])} -> {fmt(r["snr"][1])} dB under voice'
                 if r['denoised'] else
                 f'  clean already ({fmt(r["snr"][0]).strip()} dB): not denoised' if r['snr'][0]
                 else '  no silence: not denoised')
              + f'  {fmt(r["lufs"][0])} -> {fmt(r["lufs"][1])} LUFS  peak {fmt(r["peak"])}'
              + (f'  !! {"; ".join(warn)}' if warn else ''))
    print(f'{len(jobs)} clip(s) cleaned. Originals in {BACKUP.relative_to(ROOT)}/'
          + (f'  {flagged} flagged (!!): listen, re-record if bad.' if flagged else ''))
    return 0


# ---------- checking ----------

def problems(path: Path, quick: dict | None = None, snr: float | None = None) -> list[str]:
    out = []
    if quick:
        i, tp = quick['lufs'][1], quick['peak']
        snr = quick['snr'][1]
        shape = None
    else:
        m = loudness(path)
        i, tp = m if m else (None, levels(path)[1])
        shape = Shape(path)
    if i is not None and not OK_I[0] <= i <= OK_I[1]:
        out.append(f'{"soft" if i < OK_I[0] else "loud"} {i:.1f} LUFS')
    if i is None and tp < SOFT_PEAK:
        out.append(f'soft (peak {tp:.1f} dB)')
    if tp > MAX_TP:
        out.append(f'peak {tp:.1f} dB')
    if snr is not None and snr < MIN_SNR:
        out.append(f'noisy (only {snr:.0f} dB under the voice)')
    if shape and shape.lead > MAX_LEAD:
        out.append(f'{shape.lead:.2f}s silence at start')
    if shape and shape.tail > MAX_TAIL:
        out.append(f'{shape.tail:.2f}s silence at end')
    return out


def do_check(dirs: list[Path]) -> int:
    manifest = load_manifest()
    pending = [s for s in sources(dirs) if is_new(s, manifest)]
    bad = 0
    for f in clips(dirs):
        if f in pending:
            continue
        warn = problems(f, snr=manifest.get(key(f), {}).get('snr'))
        if warn:
            bad += 1
            print(f'  {key(f)}  {"; ".join(warn)}')
    for s in pending:
        print(f'  new   {key(s)}  not cleaned yet')
    total = len(clips(dirs))
    print(f'{total} clip(s): {bad} with problems, {len(pending)} not cleaned yet'
          + (' -> run python3 tool/clean_audio.py' if pending else '.'))
    return 1 if bad or pending else 0


def do_restore(dirs: list[Path]) -> int:
    manifest = load_manifest()
    restored = 0
    for d in dirs:
        for clip_key, entry in list(manifest.items()):
            orig = entry.get('original')
            clip = ROOT / clip_key
            if not orig or not clip.resolve().is_relative_to(d.resolve()):
                continue
            src = ROOT / orig
            back = ROOT / Path(orig).relative_to(BACKUP.relative_to(ROOT))
            shutil.copy2(src, back)
            if back != clip and clip.exists():
                clip.unlink()
            del manifest[clip_key]
            restored += 1
            print(f'  restored {key(back)}')
    save_manifest(manifest)
    print(f'{restored} clip(s) restored (run clean again to redo).')
    return 0


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    target = p.add_mutually_exclusive_group()
    target.add_argument('--story', help='only this story id')
    target.add_argument('--ui', action='store_true', help='only assets/audio/ui')
    mode = p.add_mutually_exclusive_group()
    mode.add_argument('--check', action='store_true', help='report problems, change nothing')
    mode.add_argument('--restore', action='store_true', help='copy originals back')
    mode.add_argument('--redo', action='store_true', help='re-clean every recording from its original')
    p.add_argument('--denoise', type=float, default=DENOISE_DB,
                   help=f'most the background noise is turned down, dB (default {DENOISE_DB:g}, 0 = off)')
    args = p.parse_args()

    dirs = clip_dirs(args)
    if args.check:
        return do_check(dirs)
    if args.restore:
        return do_restore(dirs)
    files = sources(dirs)
    if not files:
        print('No clips found.')
        return 1
    return do_clean(files, args.redo, args.denoise)


if __name__ == '__main__':
    sys.exit(main())
