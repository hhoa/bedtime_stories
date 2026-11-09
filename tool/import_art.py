#!/usr/bin/env python3
"""Bring AI-made pictures (PNG/JPG/WebP) into a story as WebP assets.

Shape comes from the target file name:
  icon_*.webp     choice icon, 400x400 square
  sticker*.webp   ending sticker, 600x600 square, keeps transparency (a plain
                  white background is cut away and a white outline drawn)
  cover.webp      home card, 800x600: home decodes every visible cover, so it
                  stays small (~30-60 KB)
  anything else   scene, 1600x1200 (4:3)

The picture is center-cropped to that shape (no stretching), resized and
saved as WebP (quality 82, ~50-150 KB a scene). Every story has one hero
(story.json "hero": girl|boy|kid), so all pictures go to images/.

Usage:
  python3 tool/import_art.py --refs ~/Downloads/story_art     # girl/boy/kid/lulu.png -> tool/image_refs/
  python3 tool/import_art.py tidy_toys ~/Downloads/s1.png --as s1_toys
  python3 tool/import_art.py tidy_toys ~/Downloads/story_art/tidy_toys   # every image, same names
  python3 tool/import_art.py tidy_toys ~/Downloads/sticker.png --as sticker

Then point story.json at the new file (images/s1_toys.webp) and run
python3 tool/check_story.py <id> --art and python3 tool/check_assets.py <id>.
A flat picture has no movable parts: give it hotspots, or cut parts with
tool/cutout.py.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parent.parent
STORIES = ROOT / 'assets/stories'
INPUT_EXTS = {'.png', '.jpg', '.jpeg', '.webp'}
QUALITY = 82


def is_sticker(name: str) -> bool:
    return name == 'sticker' or name.startswith('sticker_')


def target_size(name: str) -> tuple[int, int]:
    if name.startswith('icon_'):
        return 400, 400
    if is_sticker(name):
        return 600, 600
    if name == 'cover':
        return 800, 600
    return 1600, 1200


def cut_white_bg(img: Image.Image) -> Image.Image:
    """Sticker on a plain white background (Gemini has no transparency):
    clear the white around it, then draw a fresh white outline."""
    rgb = img.convert('RGB')
    w, h = rgb.size
    marker = (255, 0, 255)
    probe = rgb.copy()
    for corner in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]:
        if probe.getpixel(corner) != marker:
            ImageDraw.floodfill(probe, corner, marker, thresh=40)
    diff = ImageChops.difference(probe, Image.new('RGB', (w, h), marker)).convert('L')
    body = diff.point(lambda v: 255 if v else 0)
    pad = max(3, round(w * 0.012)) * 2 + 1
    outline = body.filter(ImageFilter.MaxFilter(pad)).filter(ImageFilter.GaussianBlur(1.5))
    out = Image.new('RGBA', (w, h), (255, 255, 255, 0))
    out.paste((255, 255, 255, 255), mask=outline)
    out.paste(rgb, mask=body.filter(ImageFilter.GaussianBlur(1)))
    return out


def opaque_white_corners(img: Image.Image) -> bool:
    rgba = img.convert('RGBA')
    w, h = rgba.size
    return all(min(rgba.getpixel(c)) > 235 for c in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)])


def save_art(img: Image.Image, dest: Path) -> Path:
    """Crop, resize and write [img] as WebP at [dest] (suffix forced)."""
    dest = dest.with_suffix('.webp')
    img = ImageOps.exif_transpose(img)
    if is_sticker(dest.stem) and opaque_white_corners(img):
        img = cut_white_bg(img)
    keep_alpha = is_sticker(dest.stem) and img.mode in ('RGBA', 'LA', 'P')
    img = img.convert('RGBA' if keep_alpha else 'RGB')
    img = ImageOps.fit(img, target_size(dest.stem), Image.LANCZOS)
    dest.parent.mkdir(parents=True, exist_ok=True)
    img.save(dest, 'WEBP', quality=QUALITY, method=6)
    return dest


def dest_for(story: str, stem: str) -> Path:
    return STORIES / story / 'images' / f'{stem}.webp'


REF_NAMES = ('girl', 'boy', 'lulu', 'kid')


def import_refs(src: Path):
    """Character sheets for tool/gen_image.py: PNG, whole sheet kept, longest side ≤ 1536."""
    dest_dir = ROOT / 'tool/image_refs'
    dest_dir.mkdir(parents=True, exist_ok=True)
    found = [p for p in sorted(src.iterdir()) if p.stem.lower() in REF_NAMES
             and p.suffix.lower() in INPUT_EXTS]
    if not found:
        sys.exit(f'no {"/".join(REF_NAMES)} image in {src}')
    for f in found:
        with Image.open(f) as img:
            img = ImageOps.exif_transpose(img).convert('RGB')
            img.thumbnail((1536, 1536), Image.LANCZOS)
            out = dest_dir / f'{f.stem.lower()}.png'
            img.save(out)
        print(f'{f.name} -> {out.relative_to(ROOT)}')


def main():
    if len(sys.argv) == 3 and sys.argv[1] == '--refs':
        return import_refs(Path(sys.argv[2]).expanduser())
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('story')
    ap.add_argument('src', type=Path, help='an image file or a folder of them')
    ap.add_argument('--as', dest='name', help='target name without extension (single file only)')
    args = ap.parse_args()

    if not (STORIES / args.story).is_dir():
        sys.exit(f'no story folder assets/stories/{args.story}')
    src = args.src.expanduser()
    files = sorted(p for p in src.iterdir() if p.suffix.lower() in INPUT_EXTS) if src.is_dir() else [src]
    if not files:
        sys.exit(f'no images in {src}')
    if args.name and len(files) > 1:
        sys.exit('--as works with one file only')

    for f in files:
        stem = args.name or f.stem
        with Image.open(f) as img:
            out = save_art(img, dest_for(args.story, stem))
        print(f'{f.name} -> {out.relative_to(ROOT)} ({out.stat().st_size // 1024} KB)')


if __name__ == '__main__':
    main()
