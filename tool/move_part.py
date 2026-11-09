#!/usr/bin/env python3
"""Move a cut part (layer + its poses) to another spot in the picture.

For when a part should sit somewhere the AI didn't put it (clock_time: Lulu
from the stool to the window sill, so the SVG clock can stand on the stool).
The base layer already has the part removed (tool/cutout.py with a clean
plate), so only the part's own layers move. Shifts and scales each layer
image so the part's feet (bottom centre of its box) land on --to, then
updates its box, pivot and rect in images/layers.json and its hotspot box.
Works on cropped layers (tool/layer_crop.py): expands, moves, crops again.

Run after tool/cutout.py (re-cutting puts the part back where it was).

  tool/cutout/.venv/bin/python tool/move_part.py clock_time s2_lulu_clock lulu --to 0.8,0.33 --scale 0.7
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

import sys

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from layer_crop import crop_group, expand  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
QUALITY = 86


def opaque_box(img: Image.Image) -> tuple[int, int, int, int]:
    """Bounding box of the clearly visible part (skips faint glow)."""
    return img.getchannel('A').point(lambda v: 255 if v > 128 else 0).getbbox()


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0],
                                 formatter_class=argparse.RawDescriptionHelpFormatter, epilog=__doc__)
    ap.add_argument('story')
    ap.add_argument('scene', help='picture name without extension')
    ap.add_argument('kind', help='layer kind to move, e.g. lulu')
    ap.add_argument('--to', required=True, help='x,y of the feet (picture fractions)')
    ap.add_argument('--scale', type=float, default=1.0, help='size change (farther back = smaller)')
    args = ap.parse_args()

    images = ROOT / 'assets/stories' / args.story / 'images'
    name = f'{args.scene}.webp'
    manifest_path = images / 'layers.json'
    manifest = json.loads(manifest_path.read_text())
    layer = next((l for l in manifest.get(name, []) if l.get('kind') == args.kind), None)
    if not layer:
        raise SystemExit(f'no {args.kind} layer in layers.json[{name}]')
    files = [layer['file'], *layer.get('poses', {}).values()]

    tx, ty = (float(v) for v in args.to.split(','))
    # Canvas size from the full-picture base layer.
    size = Image.open(images / manifest[name][0]['file']).size
    rect = layer.get('rect')
    default = expand(Image.open(images / layer['file']), rect, size)
    w, h = size
    x0, y0, x1, y1 = opaque_box(default)
    fx, fy = (x0 + x1) / 2, y1          # feet now
    s = args.scale
    # new = to + s * (old - feet)  ->  old = (new - to) / s + feet
    inv = (1 / s, 0, fx - tx * w / s, 0, 1 / s, fy - ty * h / s)

    union = None
    moved_all = []
    for f in files:
        src = expand(Image.open(images / f), rect, size)
        moved = src.transform((w, h), Image.AFFINE, inv, resample=Image.BICUBIC)
        moved_all.append(moved)
        b = opaque_box(moved)
        union = b if union is None else (min(union[0], b[0]), min(union[1], b[1]),
                                         max(union[2], b[2]), max(union[3], b[3]))
    nb = opaque_box(moved_all[0])
    new_rect, crops = crop_group(moved_all)
    for f, c in zip(files, crops):
        c.save(images / f, 'WEBP', quality=QUALITY, method=6)
        print(f'moved {f}')

    box = [round(union[0] / w, 4), round(union[1] / h, 4),
           round((union[2] - union[0]) / w, 4), round((union[3] - union[1]) / h, 4)]
    floating = layer.get('idle') == 'float'
    pivot = [round((nb[0] + nb[2]) / 2 / w, 4),
             round(((nb[1] + nb[3]) / 2 if floating else nb[3]) / h, 4)]
    layer['box'], layer['pivot'], layer['rect'] = box, pivot, new_rect
    manifest_path.write_text(json.dumps(manifest, indent=1) + '\n', encoding='utf-8')

    spots_path = images / 'hotspots.json'
    spots = json.loads(spots_path.read_text())
    for spot in spots.get(name, []):
        if spot['kind'] == args.kind:
            spot['box'] = [round(v, 2) for v in box]
    # Same one-line-per-picture layout the file is written in by hand.
    lines = [f' {json.dumps(k, ensure_ascii=False)}: {json.dumps(v, ensure_ascii=False)}' for k, v in spots.items()]
    spots_path.write_text('{\n' + ',\n'.join(lines) + '\n}\n', encoding='utf-8')
    print(f'{args.kind} in {name}: box {box}, pivot {pivot}')


if __name__ == '__main__':
    main()
