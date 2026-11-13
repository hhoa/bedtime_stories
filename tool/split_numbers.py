#!/usr/bin/env python3
"""Cut math template lines recorded in one go into their word pieces.

A math story line like "{name} ơi, {a} bạn cừu thêm {b} bạn nữa…" plays as
word clips (<key>_p1, _p2, _p3) with the shared number clips in between. The
parent records it once, with the example numbers `gen_audio.py --list` shows,
as <key>_full.<ext> in the story's audio/<lang>/. This finds each number in the
recording (forced alignment of the known words, torchaudio MMS_FA, on this
machine), cuts at the quietest moment between the number and its neighbours, and writes the pieces <key>_p<i>.wav. The full recording
moves to audio_backup/ (kept, never bundled). Then run clean_audio.py as usual.

Usage:
  tool/voice/.venv/bin/python tool/split_numbers.py <id> [--lang vi] [--only c1,b1] [--dry] [--force]
  tool/voice/.venv/bin/python tool/split_numbers.py <id> --dir <folder>   # trial folder of *_full files

Model: torchaudio MMS_FA (~1.2 GB, downloaded once). Audio never leaves the machine.
"""
from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
import unicodedata
import wave
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
from story_text import NUMBER_WORDS, example_values, has_numbers, option_example, tokens  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
BACKUP = ROOT / 'audio_backup'
RATE = 16000
EXTS = ('m4a', 'wav', 'mp3', 'aiff', 'aif', 'caf')
FADE = 0.012     # fade in/out (s) on every piece, no clicks


def load(path: Path) -> np.ndarray:
    raw = subprocess.run(['ffmpeg', '-v', 'error', '-i', str(path), '-ac', '1', '-ar', str(RATE),
                          '-f', 's16le', '-'], capture_output=True, check=True).stdout
    return np.frombuffer(raw, dtype=np.int16).astype(np.float32) / 32768


def save(path: Path, audio: np.ndarray) -> None:
    n = len(audio)
    f = min(int(FADE * RATE), n // 4)
    if f:
        ramp = np.linspace(0, 1, f, dtype=np.float32)
        audio = audio.copy()
        audio[:f] *= ramp
        audio[-f:] *= ramp[::-1]
    with wave.open(str(path), 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes((np.clip(audio, -1, 1) * 32767).astype(np.int16).tobytes())


def norm(word: str) -> str:
    """Lowercase, no accents, no punctuation: 'Một,' -> 'mot' (lenient on ASR tones)."""
    w = unicodedata.normalize('NFD', word.lower().replace('đ', 'd'))
    return ''.join(c for c in w if c.isalnum() and unicodedata.category(c) != 'Mn')


def expected(text: str, lang: str, values: dict[str, int], n: int | None):
    """Words the parent says, [(word, slot)] with slot = ('piece', i) or ('num', j), and the
    gaps between pieces in order: ('num', j) for a said number, ('name', k) for {name}
    (not in the recording: a zero-length cut before expected word k)."""
    words = NUMBER_WORDS[lang]
    vals = {**values, **({'n': n} if n is not None else {})}
    out, gaps, piece, num = [], [], 0, 0
    for kind, value, _ in tokens(text):
        if kind == 'words':
            out += [(w, ('piece', piece)) for w in value.split() if norm(w)]
            piece += 1
        elif kind == 'name':
            gaps.append(('name', len(out)))
        elif kind == 'number':
            out.append((words[vals[value]], ('num', num)))
            gaps.append(('num', num))
            num += 1
        elif kind == 'count':
            for k in range(1, vals[value] + 1):
                out.append((words[k], ('num', num)))
            gaps.append(('num', num))
            num += 1
    return out, gaps


_fa = None


def align(audio: np.ndarray, words: list[str]) -> list[tuple[float, float]]:
    """(start s, end s) of each expected word: forced alignment of the known text
    (torchaudio MMS_FA, multilingual; accents dropped, which it doesn't need)."""
    global _fa
    import torch
    import torchaudio
    if _fa is None:
        print('loading torchaudio MMS_FA (first time: downloads ~1.2 GB)…')
        bundle = torchaudio.pipelines.MMS_FA
        _fa = (bundle.get_model(with_star=False), bundle.get_tokenizer(), bundle.get_aligner())
    model, tokenizer, aligner = _fa
    wav = torch.from_numpy(audio).unsqueeze(0)
    with torch.inference_mode():
        emission, _ = model(wav)
    spans = aligner(emission[0], tokenizer(words))
    sec = wav.shape[1] / emission.shape[1] / RATE
    return [(sp[0].start * sec, sp[-1].end * sec) for sp in spans]


def quietest(audio: np.ndarray, lo: float, hi: float) -> float:
    """Quietest moment (10 ms frames) between lo and hi; the middle when they touch."""
    if hi - lo < 0.03:
        return (lo + hi) / 2
    hop = int(0.01 * RATE)
    seg = audio[int(lo * RATE):int(hi * RATE)]
    frames = [float(np.sqrt(np.mean(seg[i:i + hop] ** 2))) for i in range(0, max(1, len(seg) - hop), hop)]
    return lo + (int(np.argmin(frames)) + 0.5) * 0.01 if frames else (lo + hi) / 2


def split(audio: np.ndarray, exp, gaps) -> list[tuple[float, float]]:
    """Time span of each words piece: cuts at the quietest moment between a number and
    the words next to it."""
    times = align(audio, [norm(w) for w, _ in exp])
    dur = len(audio) / RATE
    slots: dict[int, list[int]] = {}
    for i, (_, (kind, j)) in enumerate(exp):
        if kind == 'num':
            slots.setdefault(j, []).append(i)

    def edge_before(i: int) -> float:   # end of the word before expected word i
        return times[i - 1][1] if i > 0 else 0.0

    def edge_after(i: int) -> float:    # start of the word after expected word i
        return times[i + 1][0] if i + 1 < len(exp) else dur

    cuts = [0.0]
    for kind, j in gaps:
        if kind == 'num':
            first, last = slots[j][0], slots[j][-1]
            cuts += [quietest(audio, edge_before(first), times[first][0]),
                     quietest(audio, times[last][1], edge_after(last))]
        else:   # {name}: not in the recording; a zero-length cut between its neighbours
            t = 0.0 if j == 0 else dur if j >= len(exp) else quietest(audio, times[j - 1][1], times[j][0])
            cuts += [t, t]
    cuts.append(dur)
    return [(cuts[2 * i], cuts[2 * i + 1]) for i in range(len(gaps) + 1)]


def lines(story: dict, lang: str):
    """(key, text, option number or None) for every template line."""
    ex = example_values(story)
    for n in story['nodes']:
        if has_numbers(n['text'][lang]):
            yield n['id'], n['text'][lang], None
        for o in n.get('options', []):
            t = o['label'][lang]
            if has_numbers(t):
                ans = o.get('answer')
                yield f'{n["id"]}_{o["id"]}', t, option_example(story, ans, ex) if ans else None


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('story')
    ap.add_argument('--lang', choices=['vi', 'en'])
    ap.add_argument('--only', help='comma-separated keys (c1,b1,c1_right)')
    ap.add_argument('--dir', help='read *_full files from and write pieces to this folder (trials)')
    ap.add_argument('--dry', action='store_true', help='show the cuts, write nothing')
    ap.add_argument('--force', action='store_true', help='overwrite existing pieces')
    args = ap.parse_args()

    sdir = ROOT / 'assets/stories' / args.story
    story = json.loads((sdir / 'story.json').read_text(encoding='utf-8'))
    values = example_values(story)
    only = set(args.only.split(',')) if args.only else None
    done = 0
    for lang in [args.lang] if args.lang else ['vi', 'en']:
        folder = Path(args.dir) if args.dir else sdir / 'audio' / lang
        for key, text, n in lines(story, lang):
            if only and key not in only:
                continue
            full = next((folder / f'{key}_full.{e}' for e in EXTS if (folder / f'{key}_full.{e}').exists()), None)
            if full is None:
                continue
            exp, gaps = expected(text, lang, values, n)
            audio = load(full)
            try:
                spans = split(audio, exp, gaps)
            except Exception as e:   # noqa: BLE001 (alignment failed: odd recording)
                print(f'[{lang}] {key}: could not line up the words ({e}). Record it again, or record the pieces.')
                continue
            print(f'[{lang}] {key}:')
            piece_texts = [t for kind, t, _ in tokens(text) if kind == 'words']
            for i, (s, e) in enumerate(spans):
                if not norm(piece_texts[i]):
                    continue   # punctuation only: no clip (as gen_audio.py)
                out = folder / f'{key}_p{i}.wav'
                exists = any((folder / f'{key}_p{i}.{x}').exists() for x in EXTS)
                print(f'    _p{i} {s:5.2f}–{e:5.2f}s  "{piece_texts[i].strip()}"'
                      + ('  (exists, kept)' if exists and not args.force else ''))
                if args.dry or (exists and not args.force):
                    continue
                for x in EXTS:   # a forced redo replaces the old take in any format
                    (folder / f'{key}_p{i}.{x}').unlink(missing_ok=True)
                save(out, audio[int(s * RATE):int(e * RATE)])
            if not args.dry and not args.dir:
                dest = BACKUP / full.relative_to(ROOT)
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.move(str(full), dest)
            done += 1
    if not done:
        print('No *_full recordings found (gen_audio.py --list shows what to record).')
    elif not args.dry and not args.dir:
        print(f'\nNext: python3 tool/clean_audio.py --story {args.story}  (then --check)')


if __name__ == '__main__':
    main()
