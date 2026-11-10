#!/usr/bin/env python3
"""Remove Gemini's sparkle watermark from the bottom-right corner of AI pictures.

Gemini app pictures carry a 4-point sparkle: plain white laid over the
picture at up to 50% opacity, 96x96 px, 64 px in from the right and bottom
edges at full output size (2752x1536 scenes, 2048x2048 squares). Its opacity
map, measured on flat-colour icons, is tool/gemini_watermark_alpha.png
(128x128, 16-bit, alpha x 65535, the mark plus a 16 px margin). Because the
overlay is known, it is undone exactly ("reverse alpha blend"):

    original = (seen - alpha * 255) / (1 - alpha)

so floor, rug or fabric texture under the mark comes back instead of a smear.
A mark is reported only when the corner is brighter where the sparkle is, by
about what the overlay would add; pictures without one are left alone.

tool/import_art.py runs this on every picture before resizing. Standalone:

  tool/cutout/.venv/bin/python tool/remove_watermark.py <file|dir> [--out DIR] [--check]

Writes cleaned copies to DIR (default <dir>/clean/ or <file dir>/clean/),
never over the originals. --check only lists which pictures have the mark.
Needs numpy: use tool/cutout/.venv/bin/python (system python3 has none).
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageOps

ALPHA_FILE = Path(__file__).resolve().parent / 'gemini_watermark_alpha.png'
INSET = 48       # alpha map's right/bottom edge from the picture's edges (mark at 64)
EXTS = {'.png', '.jpg', '.jpeg', '.webp'}

_alpha: np.ndarray | None = None


def alpha_map() -> np.ndarray:
    global _alpha
    if _alpha is None:
        _alpha = np.asarray(Image.open(ALPHA_FILE), dtype=np.float64) / 65535.0
    return _alpha


def _window(size: tuple[int, int]) -> tuple[int, int, int, int] | None:
    w, h = size
    n = alpha_map().shape[0]
    if w < 4 * (n + INSET) or h < 4 * (n + INSET):
        return None  # too small: not a full-size Gemini picture
    return w - INSET - n, h - INSET - n, w - INSET, h - INSET


def mark_strength(img: Image.Image) -> float:
    """How much of the expected sparkle brightness is there: ~1 = full mark, ~0 = none."""
    win = _window(img.size)
    if win is None:
        return 0.0
    a = alpha_map()
    reg = np.asarray(img.convert('RGB').crop(win), dtype=np.float64).mean(2)
    core, ring = a > 0.3, (a == 0)
    base = np.median(reg[ring])
    seen = reg[core].mean() - base
    expected = (a[core] * (255.0 - base)).mean()
    return float(seen / expected) if expected > 1 else 0.0


def remove_watermark(img: Image.Image, force: bool = False) -> tuple[Image.Image, bool]:
    """(picture with the sparkle undone, whether a mark was found). Keeps size and alpha."""
    img = ImageOps.exif_transpose(img)
    win = _window(img.size)
    if win is None or not (force or mark_strength(img) > 0.5):
        return img, False
    a = alpha_map()[..., None]
    out = img.convert('RGB')
    # A Gemini edit of a marked picture keeps the old sparkle and adds a new
    # one on top: undo it again while a mark still shows (at most 3 layers).
    passes = 0
    for i in range(3):
        if i and mark_strength(out) <= 0.5:
            break
        seen = np.asarray(out.crop(win), dtype=np.float64)
        orig = np.clip((seen - a * 255.0) / (1.0 - a), 0, 255)
        out.paste(Image.fromarray(orig.round().astype(np.uint8)), win[:2])
        passes += 1
    if passes > 1:
        # The old sparkle was redrawn a bit soft, so a faint outline stays:
        # fill the sparkle's edge from around it.
        import cv2
        edge = ((a[..., 0] > 0.01) & (a[..., 0] < 0.45)).astype(np.uint8)
        edge = cv2.dilate(edge, np.ones((5, 5), np.uint8))
        patch = np.asarray(out.crop(win))
        out.paste(Image.fromarray(cv2.inpaint(patch, edge * 255, 5, cv2.INPAINT_TELEA)), win[:2])
    if 'A' in img.getbands():
        out.putalpha(img.getchannel('A'))
    return out, True


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('src', type=Path)
    ap.add_argument('--out', type=Path)
    ap.add_argument('--check', action='store_true', help='only report which pictures have the mark')
    ap.add_argument('--force', action='store_true',
                    help='undo the mark even when not detected (it sits over a busy spot)')
    args = ap.parse_args()
    src = args.src.expanduser()
    files = sorted(p for p in src.iterdir() if p.suffix.lower() in EXTS) if src.is_dir() else [src]
    out_dir = args.out.expanduser() if args.out else (src if src.is_dir() else src.parent) / 'clean'
    for f in files:
        with Image.open(f) as im:
            im.load()
            if args.check:
                s = mark_strength(ImageOps.exif_transpose(im))
                print(f'{f.name}: {"mark" if s > 0.5 else "no mark"} ({s:.2f})')
                continue
            clean, found = remove_watermark(im, force=args.force)
        out_dir.mkdir(parents=True, exist_ok=True)
        dest = out_dir / f.name
        if dest.resolve() == f.resolve():
            sys.exit(f'refusing to overwrite the original {f}')
        clean.save(dest)
        print(f'{f.name}: {"removed" if found else "no mark"} -> {dest}')


if __name__ == '__main__':
    main()
