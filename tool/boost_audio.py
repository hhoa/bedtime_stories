"""Check and raise the loudness of bundled narration clips (ffmpeg).

Own-voice recordings often come in soft. This applies a plain gain to each
clip toward -16 LUFS, stopping where the peak hits -1.5 dB (no compressor, so
the voice is not squashed), keeping the same file name and format.

Originals are copied to audio_backup/<asset path> before the first boost and
never overwritten. Every boost starts from that original, so re-running does
not stack, and --restore always gets the true original.

  python3 tool/boost_audio.py --check            # list soft clips, touch nothing
  python3 tool/boost_audio.py                    # boost every story + ui clips
  python3 tool/boost_audio.py --story <id>       # one story
  python3 tool/boost_audio.py --ui               # shared clips only
  python3 tool/boost_audio.py --restore [...]    # put the originals back
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
STORIES = ROOT / 'assets' / 'stories'
UI_AUDIO = ROOT / 'assets' / 'audio' / 'ui'
BACKUP = ROOT / 'audio_backup'
EXT = 'm4a'  # keep in sync with AppConstants.audioExt

TARGET_I, TARGET_TP = -16.0, -1.5
# Peak (dBFS) below which a clip still has room to get louder.
SOFT_PEAK = -6.0


def clip_dirs(args) -> list[Path]:
    if args.story:
        return [STORIES / args.story / 'audio']
    if args.ui:
        return [UI_AUDIO]
    ids = json.loads((STORIES / 'index.json').read_text())['stories']
    return [STORIES / i / 'audio' for i in ids] + [UI_AUDIO]


def clips(dirs: list[Path]) -> list[Path]:
    # Recursive: clips sit in per-language folders (audio/vi, audio/en).
    return [c for d in dirs if d.is_dir() for c in sorted(d.rglob(f'*.{EXT}'))]


def levels(path: Path) -> tuple[float, float]:
    """(mean, peak) in dBFS."""
    out = subprocess.run(
        ['ffmpeg', '-hide_banner', '-nostats', '-i', str(path),
         '-af', 'volumedetect', '-f', 'null', '-'],
        capture_output=True, text=True, check=True,
    ).stderr
    mean = float(re.search(r'mean_volume: (-?[\d.]+) dB', out).group(1))
    peak = float(re.search(r'max_volume: (-?[\d.]+) dB', out).group(1))
    return mean, peak


def is_soft(peak: float) -> bool:
    """Soft = can be made noticeably louder without clipping."""
    return peak < SOFT_PEAK


def loudness(path: Path) -> tuple[float, float] | None:
    """(integrated LUFS, true peak dBTP), or None when too short to measure."""
    out = subprocess.run(
        ['ffmpeg', '-hide_banner', '-nostats', '-i', str(path),
         '-af', 'loudnorm=print_format=json', '-f', 'null', '-'],
        capture_output=True, text=True, check=True,
    ).stderr
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


def gain_db(src: Path) -> float:
    """Plain gain toward TARGET_I, never pushing the peak past TARGET_TP.

    Pure gain (no loudnorm compressor), so the voice and pauses sound the
    same, only louder. Never turns a clip down.
    """
    measured = loudness(src)
    if measured:
        i, tp = measured
        gain = min(TARGET_I - i, TARGET_TP - tp)
    else:
        gain = TARGET_TP - levels(src)[1]
    return max(gain, 0.0)


def boost(src: Path, dst: Path) -> float:
    gain = gain_db(src)
    with tempfile.TemporaryDirectory() as tmp:
        out = Path(tmp) / dst.name
        subprocess.run(
            ['ffmpeg', '-y', '-loglevel', 'error', '-i', str(src),
             '-af', f'volume={gain:.2f}dB',
             '-ac', '1', '-codec:a', 'aac', '-b:a', '96k', str(out)],
            check=True,
        )
        shutil.move(str(out), dst)
    return gain


def backup_path(path: Path) -> Path:
    return BACKUP / path.relative_to(ROOT)


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    target = p.add_mutually_exclusive_group()
    target.add_argument('--story', help='only this story id')
    target.add_argument('--ui', action='store_true', help='only assets/audio/ui')
    mode = p.add_mutually_exclusive_group()
    mode.add_argument('--check', action='store_true', help='list soft clips, change nothing')
    mode.add_argument('--restore', action='store_true', help='copy originals back')
    args = p.parse_args()

    files = clips(clip_dirs(args))
    if not files:
        print('No clips found.')
        return 1

    if args.restore:
        restored = 0
        for f in files:
            b = backup_path(f)
            if b.exists():
                shutil.copy2(b, f)
                restored += 1
                print(f'  restored {f.relative_to(ROOT)}')
        print(f'{restored} clip(s) restored.')
        return 0

    if args.check:
        soft = []
        for f in files:
            mean, peak = levels(f)
            if is_soft(peak):
                soft.append(f)
                print(f'  soft  {f.relative_to(ROOT)}  mean {mean:.1f} dB  peak {peak:.1f} dB')
        print(f'{len(soft)} of {len(files)} clip(s) soft'
              + (' -> run python3 tool/boost_audio.py' if soft else '.'))
        return 1 if soft else 0

    for f in files:
        b = backup_path(f)
        if not b.exists():
            b.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(f, b)
        before = levels(b)
        gain = boost(b, f)
        after = levels(f)
        print(f'  {f.relative_to(ROOT)}  +{gain:.1f} dB  mean {before[0]:.1f} -> {after[0]:.1f}'
              f'  peak {before[1]:.1f} -> {after[1]:.1f}')
    print(f'{len(files)} clip(s) boosted. Originals in {BACKUP.relative_to(ROOT)}/')
    return 0


if __name__ == '__main__':
    sys.exit(main())
