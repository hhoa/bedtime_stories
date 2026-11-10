#!/usr/bin/env python3
"""Bring AI-made pictures (PNG/JPG/WebP) into a story as WebP assets.

Shape comes from the target file name:
  icon_*.webp     choice icon, 400x400 square
  sticker*.webp   ending sticker, 600x600 square, keeps transparency (a plain
                  white background is cut away and a white outline drawn)
  cover.webp      home card, 800x600: home decodes every visible cover, so it
                  stays small (~30-60 KB)
  anything else   scene, 1600x1200 (4:3)

First Gemini's corner sparkle watermark is undone (tool/remove_watermark.py,
--keep-corner skips it). Then the picture is center-cropped to that shape (no
stretching), resized and saved as WebP at the highest quality (92 down to 72)
that fits its tool/check_assets.py budget (tool/webp_save.py). Every story has
one hero (story.json "hero": girl|boy|kid), so all pictures go to images/.
Needs numpy: run with tool/cutout/.venv/bin/python.

Usage:
  PY=tool/cutout/.venv/bin/python
  $PY tool/import_art.py --refs ~/Downloads/story_art     # girl/boy/kid/lulu.png -> tool/image_refs/
  $PY tool/import_art.py tidy_toys ~/Downloads/s1.png --as s1_toys
  $PY tool/import_art.py tidy_toys ~/Downloads/story_art/tidy_toys   # every picture art_prompts.json names
  $PY tool/import_art.py tidy_toys ~/Downloads/story_art/tidy_toys --new   # only new/changed ones
  $PY tool/import_art.py tidy_toys ~/Downloads/sticker.png --as sticker

A folder import skips files art_prompts.json doesn't name (Gemini's default
names, typos) and lists them; bring one in with --as.

Then point story.json at the new file (images/s1_toys.webp) and run
python3 tool/check_story.py <id> --art and python3 tool/check_assets.py <id>.
A flat picture has no movable parts: give it hotspots, or cut parts with
tool/cutout.py.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageOps

sys.path.insert(0, str(Path(__file__).resolve().parent))
from check_assets import budget  # noqa: E402
from webp_save import save_webp  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
STORIES = ROOT / 'assets/stories'
INPUT_EXTS = {'.png', '.jpg', '.jpeg', '.webp'}


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


def save_art(img: Image.Image, dest: Path, unmark: bool = True) -> Path:
    """Remove the watermark, crop, resize and write [img] as WebP at [dest]
    (suffix forced), best quality under budget. Prints what it did."""
    dest = dest.with_suffix('.webp')
    img = ImageOps.exif_transpose(img)
    note = ''
    if unmark:
        try:
            from remove_watermark import remove_watermark
        except ImportError:
            sys.exit('numpy missing: run with tool/cutout/.venv/bin/python (or pass --keep-corner)')
        img, found = remove_watermark(img)
        note = ', watermark removed' if found else ''
    if is_sticker(dest.stem) and opaque_white_corners(img):
        img = cut_white_bg(img)
    keep_alpha = is_sticker(dest.stem) and img.mode in ('RGBA', 'LA', 'P')
    img = img.convert('RGBA' if keep_alpha else 'RGB')
    img = ImageOps.fit(img, target_size(dest.stem), Image.LANCZOS)
    max_px, max_bytes = budget(dest.name)
    dest, q, size, over = save_webp(img, dest, max_bytes)
    shown = dest.relative_to(ROOT) if dest.is_relative_to(ROOT) else dest
    print(f'  {shown}: q{q}, {size // 1024} KB{note}'
          + (f'  OVER {max_bytes // 1024} KB' if over else ''))
    return dest


def dest_for(story: str, stem: str) -> Path:
    return STORIES / story / 'images' / f'{stem}.webp'


def expected_names(story: str) -> set[str] | None:
    """Picture names from docs/stories/<id>/art_prompts.json, or None without one."""
    f = ROOT / 'docs/stories' / story / 'art_prompts.json'
    if not f.exists():
        return None
    return set(json.loads(f.read_text(encoding='utf-8')).get('pictures', {}))


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
    ap.add_argument('--new', action='store_true', help='skip pictures whose .webp is newer than the source')
    ap.add_argument('--keep-corner', action='store_true', help="don't remove the Gemini watermark")
    args = ap.parse_args()

    if not (STORIES / args.story).is_dir():
        sys.exit(f'no story folder assets/stories/{args.story}')
    src = args.src.expanduser()
    files = sorted(p for p in src.iterdir() if p.suffix.lower() in INPUT_EXTS) if src.is_dir() else [src]
    if not files:
        sys.exit(f'no images in {src}')
    if args.name and len(files) > 1:
        sys.exit('--as works with one file only')

    # A folder brings in only the pictures art_prompts.json names, so Gemini's
    # default file names (Gemini_Generated_Image_*) never become junk scenes.
    known = None if args.name or not src.is_dir() else expected_names(args.story)
    unknown = [f.name for f in files if known is not None and f.stem not in known]
    skipped = 0
    for f in files:
        stem = args.name or f.stem
        if f.name in unknown:
            continue
        dest = dest_for(args.story, stem)
        if args.new and dest.exists() and dest.stat().st_mtime >= f.stat().st_mtime:
            skipped += 1
            continue
        print(f.name)
        with Image.open(f) as img:
            save_art(img, dest, unmark=not args.keep_corner)
    if skipped:
        print(f'{skipped} already imported (--new)')
    if unknown:
        print(f'not in art_prompts.json, skipped (import one with --as <name>): {", ".join(unknown)}')


if __name__ == '__main__':
    main()
