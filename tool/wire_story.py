#!/usr/bin/env python3
"""Add a story to the app: its id in assets/stories/index.json and its asset
folders in pubspec.yaml (Flutter lists folders one level at a time).

Safe to re-run: adds only what is missing, keeps the order of index.json.
images/layers/ is listed only when the story has that folder.

Usage:
  python3 tool/wire_story.py <id>          # wire it
  python3 tool/wire_story.py <id> --check  # say what's missing, change nothing (exit 1 if any)
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
STORIES = ROOT / 'assets/stories'
INDEX = STORIES / 'index.json'
PUBSPEC = ROOT / 'pubspec.yaml'
ANCHOR = '    - assets/stories/\n'  # story folders go right after this line
LANGS = ('vi', 'en')  # keep in sync with AppLanguage


def folders(story_id: str) -> list[str]:
    base = f'assets/stories/{story_id}/'
    out = [base, base + 'images/']
    if (STORIES / story_id / 'images/layers').is_dir():
        out.append(base + 'images/layers/')
    out += [f'{base}audio/{lang}/' for lang in LANGS]
    return out


def missing(story_id: str) -> tuple[bool, list[str]]:
    """(id missing from index.json, folders missing from pubspec.yaml)."""
    ids = json.loads(INDEX.read_text(encoding='utf-8'))['stories']
    listed = {line.strip().removeprefix('- ') for line in PUBSPEC.read_text().splitlines()}
    return story_id not in ids, [f for f in folders(story_id) if f not in listed]


def wire(story_id: str) -> None:
    need_index, need_dirs = missing(story_id)
    if need_index:
        data = json.loads(INDEX.read_text(encoding='utf-8'))
        data['stories'].append(story_id)
        INDEX.write_text(json.dumps(data, ensure_ascii=False) + '\n', encoding='utf-8')
        print(f'index.json: added {story_id}')
    if need_dirs:
        text = PUBSPEC.read_text()
        if ANCHOR not in text:
            sys.exit(f'pubspec.yaml: no "{ANCHOR.strip()}" line to add story folders after')
        # After the anchor and any story folders already listed.
        lines = text.splitlines(keepends=True)
        at = lines.index(ANCHOR) + 1
        while at < len(lines) and lines[at].startswith('    - assets/stories/'):
            at += 1
        lines[at:at] = [f'    - {d}\n' for d in need_dirs]
        PUBSPEC.write_text(''.join(lines))
        for d in need_dirs:
            print(f'pubspec.yaml: added {d}')
    if not need_index and not need_dirs:
        print(f'{story_id}: already wired.')


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('story_id')
    p.add_argument('--check', action='store_true', help='report only, exit 1 if not wired')
    args = p.parse_args()
    if not (STORIES / args.story_id / 'story.json').exists():
        sys.exit(f'No assets/stories/{args.story_id}/story.json')
    if args.check:
        need_index, need_dirs = missing(args.story_id)
        if need_index:
            print(f'index.json: {args.story_id} not listed')
        for d in need_dirs:
            print(f'pubspec.yaml: {d} not listed')
        print('wired.' if not need_index and not need_dirs else 'not wired: run python3 tool/wire_story.py '
              + args.story_id)
        return 1 if need_index or need_dirs else 0
    wire(args.story_id)
    return 0


if __name__ == '__main__':
    sys.exit(main())
