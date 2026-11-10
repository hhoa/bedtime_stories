#!/usr/bin/env python3
"""Crop a story's full-canvas cut layers (and their poses) to the part's size.

For layers cut before tool/cutout.py cropped them itself. Reads
images/layers.json, crops every raster part layer without a "rect" (one
shared rect per part and its poses), rewrites the WebP files and adds "rect".
Same pixels, much less decode memory (see tool/layer_crop.py). Safe to re-run:
layers that already have a rect are skipped.

  python3 tool/crop_layers.py clock_time [--dry]
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from layer_crop import crop_group  # noqa: E402
from check_assets import LAYER_MAX  # noqa: E402
from webp_save import save_webp  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
QUALITY = 92  # re-encoding: high enough that the second pass is invisible


def save_layer(img: Image.Image, path: Path) -> None:
    """Best WebP quality (from QUALITY down) that fits the cut-layer budget."""
    _, q, size, over = save_webp(img, path, LAYER_MAX, q_hi=QUALITY)
    if over or q < QUALITY:
        print(f'  {path.name}: q{q}, {size // 1024} KB' + ('  OVER budget' if over else ''))


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0],
                                 formatter_class=argparse.RawDescriptionHelpFormatter, epilog=__doc__)
    ap.add_argument('story')
    ap.add_argument('--dry', action='store_true', help='only print what would change')
    args = ap.parse_args()

    images = ROOT / 'assets/stories' / args.story / 'images'
    manifest_path = images / 'layers.json'
    if not manifest_path.exists():
        sys.exit(f'no {manifest_path.relative_to(ROOT)}')
    manifest = json.loads(manifest_path.read_text())

    before = after = 0
    for scene, layers in manifest.items():
        for layer in layers:
            if not layer.get('kind') or layer['file'].endswith('.svg') or 'rect' in layer:
                continue
            files = [layer['file'], *layer.get('poses', {}).values()]
            paths = [images / f for f in files if (images / f).exists()]
            imgs = [Image.open(p).convert('RGBA') for p in paths]
            if len({im.size for im in imgs}) != 1:
                sys.exit(f'{scene} {layer["kind"]}: layers differ in size, not full-canvas?')
            rect, crops = crop_group(imgs)
            w, h = imgs[0].size
            before += len(imgs) * w * h * 4
            after += sum(c.width * c.height * 4 for c in crops)
            print(f'{scene} {layer["kind"]}: {len(files)} picture(s) -> rect {rect}')
            if args.dry:
                continue
            for p, c in zip(paths, crops):
                save_layer(c, p)
            layer['rect'] = rect

    print(f'decoded memory, all cut layers: {before / 1e6:.0f} MB -> {after / 1e6:.0f} MB')
    if not args.dry and after:
        manifest_path.write_text(json.dumps(manifest, indent=1) + '\n', encoding='utf-8')
        print(f'wrote {manifest_path.relative_to(ROOT)}')


if __name__ == '__main__':
    main()
