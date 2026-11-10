#!/usr/bin/env python3
"""Cut one AI "sheet" (several figures on a plain background) into sprites.

Kit art (docs: CLAUDE.md, "Kit"): instead of one Gemini picture per scene,
the parent makes a few sheets (hero poses, Lulu poses, props) and
tool/stage.py composes the scenes from the pieces. This tool turns a sheet
into one transparent PNG per figure.

How: Gemini's corner mark is undone (tool/remove_watermark.py), the whole
sheet goes through the background-removal model once to find the figures,
pieces closer than --gap join into one figure (scattered blocks are one
prop), then each figure is cut again from its own crop for a sharp edge.
Figures are named row by row, left to right, from --names. With --grid CxR
the pieces are grouped by grid cell instead (use it when figures stand
close, or one figure is many far-apart pieces).

Writes <out>/<name>.png (trimmed, RGBA) and <out>/_contact.jpg to look at.
The count must match --names: otherwise nothing is saved but the contact
sheet, which shows what was found.

Setup (once): tool/cutout/setup.sh

Usage:
  tool/cutout/.venv/bin/python tool/sprite_sheet.py ~/Downloads/story_art/tidy_toys/kit/hero_a.png \\
      --names sit_play,sit_look_up,bed_sit,kneel_search,kneel_yawn,kneel_happy
  (default --out: <sheet folder>/sprites/<sheet name>/)
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageOps
from rembg import new_session, remove

sys.path.insert(0, str(Path(__file__).resolve().parent))
from remove_watermark import remove_watermark  # noqa: E402

MODEL = 'birefnet-general-lite'   # same as tool/cutout.py
HAZE = 40          # mask values under this are the model's faint haze
FEATHER = 1.2      # px blur on the cut edge
CROP_PAD = 0.035   # room around a figure for its own cut, fraction of the sheet width
MIN_AREA = 0.0015  # pieces smaller than this fraction of the sheet are specks
MARGIN = 4         # transparent px kept around a saved sprite
PEACH = (236, 188, 160)  # contact sheet background, like the bedroom wall


def find_groups(mask: np.ndarray, gap: int, grid: tuple[int, int] | None) -> list[np.ndarray]:
    """Boolean masks, one per figure, in reading order."""
    h, w = mask.shape
    solid = (mask >= HAZE).astype(np.uint8)
    n, labels, stats, cents = cv2.connectedComponentsWithStats(solid, connectivity=8)
    keep = [i for i in range(1, n) if stats[i, cv2.CC_STAT_AREA] >= MIN_AREA * w * h]
    if not keep:
        return []
    if grid:
        cols, rows = grid
        cells: dict[tuple[int, int], np.ndarray] = {}
        for i in keep:
            cx, cy = cents[i]
            cell = (min(rows - 1, int(cy * rows / h)), min(cols - 1, int(cx * cols / w)))
            cells[cell] = cells.get(cell, np.zeros((h, w), bool)) | (labels == i)
        return [cells[c] for c in sorted(cells)]

    # Join pieces closer than [gap], then read rows top to bottom.
    kept = np.isin(labels, keep).astype(np.uint8)
    k = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (gap + 1, gap + 1))
    n2, joined = cv2.connectedComponents(cv2.dilate(kept, k), connectivity=8)
    groups = []
    for j in range(1, n2):
        g = (joined == j) & (kept > 0)
        ys, xs = np.nonzero(g)
        if len(ys):
            groups.append((g, ys.min(), ys.max(), (xs.min() + xs.max()) / 2))
    # Same row = vertical spans overlap by more than half the shorter one.
    groups.sort(key=lambda t: (t[1] + t[2]) / 2)
    rows: list[list] = []
    for g in groups:
        for row in rows:
            top, bottom = max(g[1], row[0][1]), min(g[2], row[0][2])
            if bottom - top > 0.5 * min(g[2] - g[1], row[0][2] - row[0][1]):
                row.append(g)
                break
        else:
            rows.append([g])
    return [g[0] for row in rows for g in sorted(row, key=lambda t: t[3])]


def cut_figure(img: Image.Image, group: np.ndarray, session, fill_holes: bool) -> Image.Image:
    """The figure in [group] as a trimmed RGBA sprite, cut from its own crop."""
    w, h = img.size
    ys, xs = np.nonzero(group)
    pad = int(CROP_PAD * w)
    box = (max(0, xs.min() - pad), max(0, ys.min() - pad), min(w, xs.max() + pad), min(h, ys.max() + pad))
    crop = img.crop(box)
    m = np.array(remove(crop, session=session, only_mask=True).convert('L'))
    m[m < HAZE] = 0
    # Only this figure: a neighbour's hand can reach into the crop.
    near = cv2.dilate(group[box[1]:box[3], box[0]:box[2]].astype(np.uint8),
                      cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (31, 31)))
    m[near == 0] = 0
    if fill_holes:
        outside = (m > 0).astype(np.uint8)
        cv2.floodFill(outside, np.zeros((m.shape[0] + 2, m.shape[1] + 2), np.uint8), (0, 0), 1)
        m[outside == 0] = 255
    alpha = Image.fromarray(m).filter(ImageFilter.GaussianBlur(FEATHER))
    sprite = crop.convert('RGBA')
    sprite.putalpha(alpha)
    b = alpha.point(lambda v: 255 if v > 60 else 0).getbbox()
    if b is None:
        return sprite
    return sprite.crop((max(0, b[0] - MARGIN), max(0, b[1] - MARGIN),
                        min(sprite.width, b[2] + MARGIN), min(sprite.height, b[3] + MARGIN)))


def contact(img: Image.Image, groups: list[np.ndarray], names: list[str], sprites: list[Image.Image],
            path: Path) -> None:
    """Top: the sheet with numbered boxes. Bottom: the cut sprites on the wall colour."""
    w = 1600
    top = img.resize((w, round(img.height * w / img.width)))
    k = w / img.width
    d = ImageDraw.Draw(top)
    for i, g in enumerate(groups):
        ys, xs = np.nonzero(g)
        box = [xs.min() * k, ys.min() * k, xs.max() * k, ys.max() * k]
        d.rectangle(box, outline=(230, 60, 60), width=3)
        label = f'{i + 1} {names[i] if i < len(names) else "?"}'
        d.rectangle([box[0], box[1], box[0] + 9 * len(label) + 10, box[1] + 20], fill=(230, 60, 60))
        d.text((box[0] + 5, box[1] + 4), label, fill='white')
    rows = [top]
    if sprites:
        cell = w // max(1, min(len(sprites), 6))
        lines = [sprites[i:i + 6] for i in range(0, len(sprites), 6)]
        for line_no, line in enumerate(lines):
            strip = Image.new('RGB', (w, cell), PEACH)
            for i, s in enumerate(line):
                t = s.copy()
                t.thumbnail((cell - 16, cell - 34))
                strip.paste(t, (i * cell + (cell - t.width) // 2, cell - 28 - t.height), t)
                name = names[line_no * 6 + i]
                ImageDraw.Draw(strip).text((i * cell + 8, cell - 22), f'{name}  {s.width}x{s.height}',
                                           fill=(60, 40, 40))
            rows.append(strip)
    sheet = Image.new('RGB', (w, sum(r.height for r in rows)), 'white')
    y = 0
    for r in rows:
        sheet.paste(r, (0, y))
        y += r.height
    path.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(path, quality=88)


def parse_grid(s: str) -> tuple[int, int]:
    try:
        c, r = s.lower().split('x')
        return int(c), int(r)
    except ValueError:
        raise argparse.ArgumentTypeError(f'--grid wants COLSxROWS like 3x2, got {s!r}')


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0],
                                 formatter_class=argparse.RawDescriptionHelpFormatter, epilog=__doc__)
    ap.add_argument('sheet', type=Path)
    ap.add_argument('--names', required=True, help='comma list, row by row, left to right')
    ap.add_argument('--out', type=Path, help='default: <sheet folder>/sprites/<sheet name>/')
    ap.add_argument('--gap', type=float, default=0.02,
                    help='pieces closer than this (fraction of the sheet width) are one figure (default 0.02)')
    ap.add_argument('--grid', type=parse_grid, metavar='CxR', help='group pieces by grid cell instead of --gap')
    ap.add_argument('--fill-holes', action='store_true',
                    help='fill enclosed holes (Lulu: the model drops her pink inner ears). Not for the child: '
                         'an arm can enclose real background')
    ap.add_argument('--keep-corner', action='store_true', help="don't undo Gemini's corner mark")
    ap.add_argument('--force-mark', action='store_true',
                    help='undo the corner mark even when it is not detected (mark over a figure, not background)')
    args = ap.parse_args()

    src = args.sheet.expanduser()
    if not src.exists():
        sys.exit(f'no sheet {src}')
    names = [n.strip() for n in args.names.split(',') if n.strip()]
    if len(set(names)) != len(names):
        sys.exit('--names has a name twice')
    out = (args.out.expanduser() if args.out else src.parent / 'sprites' / src.stem)

    with Image.open(src) as im:
        img = ImageOps.exif_transpose(im).convert('RGB')
    if not args.keep_corner:
        img, had_mark = remove_watermark(img, force=args.force_mark)
        if had_mark:
            print('  Gemini mark removed')
    session = new_session(MODEL)
    mask = np.array(remove(img, session=session, only_mask=True).convert('L'))
    groups = find_groups(mask, max(1, int(args.gap * img.width)), args.grid)

    if len(groups) != len(names):
        contact(img, groups, names, [], out / '_contact.jpg')
        sys.exit(f'found {len(groups)} figure(s), --names has {len(names)}. Nothing saved. '
                 f'Look at {out / "_contact.jpg"}: figures too close → --grid CxR or a smaller --gap; '
                 f'one figure split → a bigger --gap.')

    out.mkdir(parents=True, exist_ok=True)
    sprites = [cut_figure(img, g, session, args.fill_holes) for g in groups]
    for name, s in zip(names, sprites):
        s.save(out / f'{name}.png')
        print(f'{out / name}.png  {s.width}x{s.height}')
    contact(img, groups, names, sprites, out / '_contact.jpg')
    print(f'contact sheet: {out / "_contact.jpg"}')


if __name__ == '__main__':
    main()
