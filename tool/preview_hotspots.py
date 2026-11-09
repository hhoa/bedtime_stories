#!/usr/bin/env python3
"""Draw a story's tap hotspots (images/hotspots.json) on its pictures, to check
the boxes sit on the child and Lulu.

Usage:
  python3 tool/preview_hotspots.py <id> <out_dir>

Writes one JPEG per picture with a 10% grid (to measure new boxes: x, y, w, h
as fractions) and each hotspot box labeled with its kind and burst.
"""
import argparse
import json
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
COLORS = {'hero': (255, 120, 170), 'lulu': (255, 200, 90)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('story')
    ap.add_argument('out', type=Path)
    args = ap.parse_args()

    images = ROOT / 'assets/stories' / args.story / 'images'
    spots_file = images / 'hotspots.json'
    spots = json.loads(spots_file.read_text()) if spots_file.exists() else {}
    args.out.mkdir(parents=True, exist_ok=True)
    for pic in sorted(images.glob('*.webp')):
        if pic.stem.startswith('icon_'):
            continue
        im = Image.open(pic).convert('RGB').resize((800, 600))
        d = ImageDraw.Draw(im)
        for k in range(1, 10):
            d.line([(k * 80, 0), (k * 80, 600)], fill=(90, 90, 90))
            d.line([(0, k * 60), (800, k * 60)], fill=(90, 90, 90))
            d.text((k * 80 + 2, 2), str(k), fill='white')
            d.text((2, k * 60 + 2), str(k), fill='white')
        for h in spots.get(pic.name, []):
            x, y, w, hh = h['box']
            c = COLORS.get(h['kind'], (120, 220, 255))
            d.rectangle([x * 800, y * 600, (x + w) * 800, (y + hh) * 600], outline=c, width=3)
            d.text((x * 800 + 4, y * 600 + 4), f'{h["kind"]} {h.get("burst", "sparkles")}', fill=c)
        out = args.out / f'{pic.stem}.jpg'
        im.save(out, quality=85)
        print(out)


if __name__ == '__main__':
    main()
