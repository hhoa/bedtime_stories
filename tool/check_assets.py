#!/usr/bin/env python3
"""Asset weight check: what each story costs in download size and memory.

Home decodes every visible cover; the player decodes the scene, its cut
layers and the next scenes ahead (both branches at a choice). Big files mean
slow web loads, big pictures mean decode memory (iOS cuts audio under memory
pressure). Flags anything over budget so it can be downsized before it ships.

Budgets (per file unless noted):
  cover.*            <= 800 px wide, <= 60 KB
  scene              <= 1600 px wide, <= 150 KB
  icon_*             <= 400 px, <= 40 KB
  sticker*           <= 600 px, <= 80 KB
  cut layer          cropped ("rect" in layers.json), <= 120 KB
  audio clip         <= 150 KB
  story total        <= 4 MB (images + audio, both languages)

Usage:
  python3 tool/check_assets.py            # every story in assets/stories/index.json
  python3 tool/check_assets.py <id>       # one story
  python3 tool/check_assets.py --dir test/fixtures/stories/demo
Exit 1 when something is over budget.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
STORIES = ROOT / 'assets/stories'
KB = 1024
STORY_MAX = 4 * KB * KB
AUDIO_MAX = 150 * KB
LAYER_MAX = 120 * KB


def budget(name: str) -> tuple[int, int]:
    """(max width px, max bytes) for a picture by file name."""
    stem = Path(name).stem
    if stem == 'cover':
        return 800, 60 * KB
    if stem.startswith('icon_'):
        return 400, 40 * KB
    if stem == 'sticker' or stem.startswith('sticker_'):
        return 600, 80 * KB
    return 1600, 150 * KB


def width(path: Path) -> int | None:
    if path.suffix == '.svg':
        return None
    with Image.open(path) as im:
        return im.width


def check_story(folder: Path) -> list[str]:
    problems = []
    images = folder / 'images'
    layers_json = images / 'layers.json'
    layers = json.loads(layers_json.read_text()) if layers_json.exists() else {}
    layer_files = {l['file']: l for ls in layers.values() for l in ls}
    layer_files |= {p: l for ls in layers.values() for l in ls for p in l.get('poses', {}).values()}

    total = 0
    sizes = {'images': 0, 'layers': 0, 'audio': 0}
    for f in sorted(images.rglob('*')):
        if not f.is_file() or f.suffix == '.json':
            continue
        size = f.stat().st_size
        total += size
        rel = f.relative_to(images).as_posix()
        if rel.startswith('layers/'):
            sizes['layers'] += size
            layer = layer_files.get(rel)
            if size > LAYER_MAX:
                problems.append(f'{rel}: {size // KB} KB (> {LAYER_MAX // KB} KB)')
            if layer and layer.get('kind') and f.suffix != '.svg' and 'rect' not in layer:
                problems.append(f'{rel}: full-canvas part layer (re-run tool/stage.py)')
            continue
        sizes['images'] += size
        max_w, max_b = budget(rel)
        w = width(f)
        if w and w > max_w:
            problems.append(f'{rel}: {w} px wide (> {max_w}), re-import with tool/import_art.py')
        if size > max_b:
            problems.append(f'{rel}: {size // KB} KB (> {max_b // KB} KB)')
    for f in sorted((folder / 'audio').rglob('*.m4a')):
        size = f.stat().st_size
        total += size
        sizes['audio'] += size
        if size > AUDIO_MAX:
            problems.append(f'{f.relative_to(folder)}: {size // KB} KB (> {AUDIO_MAX // KB} KB)')
    if total > STORY_MAX:
        problems.append(f'story total {total / KB / KB:.1f} MB (> {STORY_MAX // KB // KB} MB)')
    parts = ', '.join(f'{k} {v / KB / KB:.1f} MB' for k, v in sizes.items())
    print(f'{folder.name}: {total / KB / KB:.1f} MB ({parts})')
    return problems


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('story', nargs='?')
    ap.add_argument('--dir', type=Path, help='a story folder outside assets/stories')
    args = ap.parse_args()
    if args.dir:
        folders = [args.dir.resolve()]
    elif args.story:
        folders = [STORIES / args.story]
    else:
        ids = json.loads((STORIES / 'index.json').read_text())['stories']
        folders = [STORIES / i for i in ids]
    if not folders:
        print('No stories yet.')
    bad = False
    for folder in folders:
        if not (folder / 'story.json').exists():
            sys.exit(f'no story at {folder}')
        for p in check_story(folder):
            bad = True
            print(f'  OVER  {p}')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
