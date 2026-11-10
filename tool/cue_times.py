#!/usr/bin/env python3
"""Time each cue to the real recording: write "at" (fraction of its clip)
into the story's cues so parts move when the word is actually said.

Without "at" the app guesses from the word's place in the text (character
count), which drifts on real speech: quiet starts, pauses after sentences,
slow and fast parts. This tool finds the pauses in each clip, lines them up
with the sentence and comma breaks of its text, and times each cue word by
its place inside its own stretch of speech.

    tool/cutout/.venv/bin/python tool/cue_times.py <id> [--lang vi|en] [--dry] [--lead 0.08]

Run it again whenever a clip is re-recorded or re-cloned (cues with a missing
clip keep no "at"). story.json is edited in place, only the cue objects'
"at" values change, so its hand formatting stays.
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent.parent
NAME = '{name}'
RATE = 16000
HOP = 0.01                     # s per frame
MIN_PAUSE = 0.12               # s of quiet that counts as a pause
STRONG = '.!?…:;'
WEAK = ',—–'


def load(clip: Path) -> np.ndarray:
    raw = subprocess.run(['ffmpeg', '-v', 'error', '-i', str(clip), '-ac', '1', '-ar', str(RATE),
                          '-f', 'f32le', '-'], capture_output=True, check=True).stdout
    return np.frombuffer(raw, np.float32)


def speech_map(wav: np.ndarray) -> tuple[float, float, list[tuple[float, float]], float]:
    """(speech start, speech end, pauses [(start, end)] inside it, clip length) in seconds."""
    n = int(HOP * RATE)
    frames = len(wav) // n
    rms = np.sqrt(np.mean(wav[:frames * n].reshape(frames, n) ** 2, axis=1) + 1e-12)
    db = 20 * np.log10(rms)
    floor, loud = np.percentile(db, 10), np.percentile(db, 95)
    on = db > floor + 0.35 * (loud - floor)
    # close tiny gaps inside words, drop tiny blips
    def runs(mask):
        out, i = [], 0
        while i < len(mask):
            j = i
            while j < len(mask) and mask[j] == mask[i]:
                j += 1
            out.append((bool(mask[i]), i, j))
            i = j
        return out
    for val, i, j in runs(on):
        if not val and (j - i) * HOP < 0.06 and i > 0 and j < len(on):
            on[i:j] = True
    for val, i, j in runs(on):
        if val and (j - i) * HOP < 0.05:
            on[i:j] = False
    idx = np.flatnonzero(on)
    length = len(wav) / RATE
    if not len(idx):
        return 0.0, length, [], length
    start, end = idx[0] * HOP, (idx[-1] + 1) * HOP
    pauses = [(i * HOP, j * HOP) for val, i, j in runs(on)
              if not val and i > idx[0] and j <= idx[-1] and (j - i) * HOP >= MIN_PAUSE]
    # a lip click or breath before the first word / after the last one
    if pauses and pauses[0][0] - start < 0.25:
        start = pauses.pop(0)[1]
    if pauses and end - pauses[-1][1] < 0.25:
        end = pauses.pop()[0]
    return start, end, pauses, length


def breaks(text: str) -> list[tuple[int, int, bool]]:
    """Text breaks where a reader may pause: (end of the words before,
    start of the words after, strong?)."""
    out = []
    for m in re.finditer(r'[' + re.escape(STRONG + WEAK) + r']+["”»)]*\s+', text):
        strong = any(ch in STRONG for ch in m.group())
        nxt = m.end()
        while nxt < len(text) and text[nxt] in '"“«(':
            nxt += 1
        if nxt < len(text):
            out.append((m.start(), nxt, strong))
    return out


def align(text: str, start: float, end: float, pauses: list[tuple[float, float]]):
    """Anchors (char, time) for a piecewise-linear char -> time map."""
    brs = breaks(text)
    L = max(1, len(text))
    def expect(c):
        return start + c / L * (end - start)
    nb, npz = len(brs), len(pauses)
    INF = float('inf')
    # cost[j][k]: best cost after j breaks and k pauses considered
    cost = [[INF] * (npz + 1) for _ in range(nb + 1)]
    back = [[None] * (npz + 1) for _ in range(nb + 1)]
    cost[0][0] = 0.0
    for j in range(nb + 1):
        for k in range(npz + 1):
            c = cost[j][k]
            if c == INF:
                continue
            if j < nb:      # break with no pause
                skip = 0.9 if brs[j][2] else 0.25
                if c + skip < cost[j + 1][k]:
                    cost[j + 1][k], back[j + 1][k] = c + skip, ('b', j, k)
            if k < npz:     # pause with no break (breath mid-sentence)
                p = pauses[k][1] - pauses[k][0]
                pen = 0.15 + 1.5 * p
                if c + pen < cost[j][k + 1]:
                    cost[j][k + 1], back[j][k + 1] = c + pen, ('p', j, k)
            if j < nb and k < npz:   # break heard as this pause
                mid = (pauses[k][0] + pauses[k][1]) / 2
                d = abs(expect(brs[j][0]) - mid)
                m = c + d - (0.2 if brs[j][2] else 0.05)
                if m < cost[j + 1][k + 1]:
                    cost[j + 1][k + 1], back[j + 1][k + 1] = m, ('m', j, k)
    j, k, pairs = nb, npz, []
    while (j, k) != (0, 0):
        kind, pj, pk = back[j][k]
        if kind == 'm':
            pairs.append((brs[pj], pauses[pk]))
        j, k = pj, pk
    pairs.reverse()
    anchors = [(0, start)]
    for (before, after, _), (p0, p1) in pairs:
        anchors += [(before, p0), (after, p1)]
    anchors.append((L, end))
    return anchors


def time_at(anchors, c: int) -> float:
    for (c0, t0), (c1, t1) in zip(anchors, anchors[1:]):
        if c0 <= c <= c1:
            return t0 if c1 == c0 else t0 + (c - c0) / (c1 - c0) * (t1 - t0)
    return anchors[-1][1]


def cue_fractions(story: dict, lang: str, audio: Path, lead: float) -> dict[tuple[str, int], float]:
    """(node id, cue index) -> fraction of its clip."""
    out = {}
    for n in story['nodes']:
        cues = (n.get('cues') or {}).get(lang) or []
        if not cues:
            continue
        text = n['text'][lang]
        pieces = text.split(NAME)
        cache, pos = {}, 0
        for i, c in enumerate(cues):
            at = text.find(c['word'], pos)
            if at < 0:
                continue
            pos = at + len(c['word'])
            start = 0
            for p, piece in enumerate(pieces):
                if at < start + len(piece):
                    break
                start += len(piece) + len(NAME)
            clip = audio / (f'{n["id"]}.m4a' if len(pieces) == 1 else f'{n["id"]}_p{p}.m4a')
            if not clip.exists():
                continue
            if clip not in cache:
                s, e, pauses, length = speech_map(load(clip))
                cache[clip] = (align(piece, s, e, pauses), length)
            anchors, length = cache[clip]
            t = max(0.0, time_at(anchors, at - start) - lead)
            out[n['id'], i] = round(min(0.98, t / length), 3)
    return out


CUE_RE = re.compile(r'\{"word":\s*"((?:[^"\\]|\\.)*)"[^{}]*\}')


def write_back(path: Path, story: dict, found: dict[tuple[str, str, int], float]) -> int:
    """Set "at" in each cue object of the file text, keeping its formatting."""
    order = [(n['id'], lang, i, c['word'])
             for n in story['nodes'] for lang, cues in (n.get('cues') or {}).items()
             for i, c in enumerate(cues)]
    src = path.read_text(encoding='utf-8')
    matches = list(CUE_RE.finditer(src))
    if len(matches) != len(order):
        sys.exit(f'{path}: found {len(matches)} cue objects in the text, story has {len(order)}; not writing')
    out, last, changed = [], 0, 0
    for m, (nid, lang, i, word) in zip(matches, order):
        if json.loads(f'"{m.group(1)}"') != word:
            sys.exit(f'{path}: cue order mismatch at {nid} ({lang}) "{word}"; not writing')
        obj = re.sub(r',\s*"at":\s*[0-9.]+', '', m.group())
        if (nid, lang, i) in found:
            obj = obj[:-1] + f', "at": {found[nid, lang, i]}' + '}'
        changed += obj != m.group()
        out += [src[last:m.start()], obj]
        last = m.end()
    out.append(src[last:])
    path.write_text(''.join(out), encoding='utf-8')
    return changed


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('story')
    ap.add_argument('--lang', choices=['vi', 'en'])
    ap.add_argument('--dry', action='store_true', help='print, do not write')
    ap.add_argument('--lead', type=float, default=0.08, help='fire this many seconds before the word (default 0.08)')
    args = ap.parse_args()
    path = ROOT / 'assets/stories' / args.story / 'story.json'
    story = json.loads(path.read_text(encoding='utf-8'))
    found = {}
    for lang in [args.lang] if args.lang else ['vi', 'en']:
        fr = cue_fractions(story, lang, path.parent / 'audio' / lang, args.lead)
        for n in story['nodes']:
            cues = (n.get('cues') or {}).get(lang) or []
            for i, c in enumerate(cues):
                if (n['id'], i) in fr:
                    found[n['id'], lang, i] = fr[n['id'], i]
            if cues:
                print(f'{n["id"]:>4} {lang}: ' + '  '.join(
                    f'{c["word"]}@{fr.get((n["id"], i), "-")}' for i, c in enumerate(cues)))
    if args.dry:
        return
    changed = write_back(path, story, found)
    print(f'{path.relative_to(ROOT)}: {len(found)} cue(s) timed, {changed} changed')


if __name__ == '__main__':
    main()
