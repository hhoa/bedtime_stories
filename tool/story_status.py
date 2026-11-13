#!/usr/bin/env python3
"""Where each story is in the pipeline, and the next step.

Pictures and recordings arrive over days, in batches. This reads the files
(outline, reviews, art_prompts.json, images, layers, audio, pubspec) plus
docs/stories/<id>/progress.json (what files can't show: approvals, the
prompts page link, pictures marked redo, cloned clips the parent listened to)
and prints one report per story. Changes nothing.

Two tracks run side by side after the script is approved: art (the parent
makes pictures in Gemini, /story-art imports them) and audio (the parent
records, /story-audio cleans and fills gaps). Claude's own work comes first
in "next" (files waiting to import or clean), then what the parent can do.

progress.json (committed, no personal data; skills write it):
  {"gates": {"outline": "2026-11-09", "script": "...", "art_prompts": "..."},
   "prompts_page": "https://claude.ai/artifact/...",
   "redo": {"s1_backpack": "why, and the line to add to the prompt"},
   "listened": {"vi": ["s1", "c1_p1"], "en": []},
   "notes": ["..."]}

Usage:
  python3 tool/story_status.py                # every story
  python3 tool/story_status.py <id>           # one story, full report
  python3 tool/story_status.py --brief        # one line per unfinished story (session start)
  python3 tool/story_status.py <id> --json    # for the story-tracker agent
  python3 tool/story_status.py <id> --art-dir <dir>   # pictures folder (default ~/Downloads/story_art/<id>)
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import clean_audio  # noqa: E402
from gen_audio import EXT, LANGS, VOICE_DIR, clone_ready, line_clips, story_lines  # noqa: E402
from wire_story import missing as wire_missing  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
STORIES = ROOT / 'assets/stories'
DOCS = ROOT / 'docs/stories'
REFS = ROOT / 'tool/image_refs'
ART_DIR = Path.home() / 'Downloads/story_art'
PIC_EXTS = ('.png', '.jpg', '.jpeg', '.webp')
KB = 1024
STORY_MAX = 4 * KB * KB


def read_json(path: Path, default=None):
    try:
        return json.loads(path.read_text(encoding='utf-8'))
    except (OSError, json.JSONDecodeError):
        return default


def verdict(path: Path) -> str | None:
    """PASS / FIX from a review file, None when there is none."""
    if not path.exists():
        return None
    m = re.search(r'VERDICT:\s*(PASS|FIX)', path.read_text(encoding='utf-8'))
    return m.group(1) if m else '?'


def find_pic(folder: Path, stem: str) -> Path | None:
    for ext in PIC_EXTS:
        p = folder / f'{stem}{ext}'
        if p.exists():
            return p
    return None


def newer(a: Path, b: Path) -> bool:
    return a.stat().st_mtime > b.stat().st_mtime


# ---------- art ----------

def kit_status(sid: str, prompts: dict, layers: dict, art_dir: Path) -> dict | None:
    """Kit stories (art_prompts.json "kit"): one room + sheets the parent makes,
    tool/sprite_sheet.py cuts each sheet, tool/stage.py composes the scenes of
    docs/stories/<id>/stage.json. None for picture-per-scene stories."""
    kit = prompts.get('kit')
    if not kit:
        return None
    sheets = kit.get('sheets', {})
    rooms = {f'room_{k}': v for k, v in kit.get('rooms', {}).items()}
    if kit.get('room'):
        rooms['room'] = kit['room']
    names = list(rooms) + list(sheets)
    saved = {n: find_pic(art_dir / 'kit', n) for n in names}
    # Rooms and sheets made for another story: copied, not made in Gemini.
    shared = {n: e['from'] for n, e in [*rooms.items(), *sheets.items()] if e.get('from')}
    to_cut = []
    for name, sheet in sheets.items():
        src = saved[name]
        if not src:
            continue
        sprites = [art_dir / 'kit/sprites' / name / f'{fig}.png' for fig in sheet.get('figures', {})]
        if any(not f.exists() or newer(src, f) for f in sprites):
            to_cut.append(name)
    stage_path = DOCS / sid / 'stage.json'
    scenes = list((read_json(stage_path, {}) or {}).get('scenes', {}))
    staged = [sc for sc in scenes
              if any(l.get('file', '').startswith('layers/kit_') for l in layers.get(f'{sc}.webp', []))]
    manifest = STORIES / sid / 'images/layers.json'
    all_cut = all(saved.values()) and not to_cut
    return {
        'total': len(names), 'saved': sum(1 for v in saved.values() if v),
        'missing': [n for n, v in saved.items() if not v and n not in shared],
        # Copy once the other story's image exists; until then it waits for that story.
        'to_copy': {n: shared[n] for n, v in saved.items()
                    if not v and n in shared and (art_dir.parent / shared[n]).exists()},
        'waits_for': sorted({shared[n].split('/')[0] for n, v in saved.items()
                             if not v and n in shared and not (art_dir.parent / shared[n]).exists()}),
        'rooms': len(rooms), 'sheets_unsaved': sum(1 for n in sheets if not saved[n]),
        'sheets': len(sheets), 'to_cut': to_cut,
        'stage_json': stage_path.exists(), 'scenes': len(scenes), 'staged': len(staged),
        # Everything is cut, and the scenes were never composed or stage.json changed since.
        'compose': bool(all_cut and scenes and (len(staged) < len(scenes)
                                                or newer(stage_path, manifest))),
    }


def art_status(sid: str, prompts: dict, progress: dict, art_dir: Path) -> dict:
    images = STORIES / sid / 'images'
    layers = read_json(images / 'layers.json', {})
    redo = progress.get('redo', {})
    pics = list(prompts.get('pictures', {}))

    known = set(pics)
    done, waiting, missing = [], [], []
    for name in pics:
        webp = images / f'{name}.webp'
        src = find_pic(art_dir, name)
        if webp.exists() and name not in redo:
            done.append(name)
            if src and newer(src, webp):
                waiting.append(name)  # a redone picture saved after the import
        elif src and (not webp.exists() or newer(src, webp)):
            waiting.append(name)
        elif name not in redo:
            missing.append(name)

    unknown = []
    if prompts.get('kit') and images.is_dir():
        # Old per-scene pictures of a story turned kit: the app's scenes and icons are staged now.
        known |= {f.stem for f in images.glob('*.webp')}
    if art_dir.is_dir():
        unknown = sorted(f.name for f in art_dir.iterdir()
                         if f.is_file() and f.suffix.lower() in PIC_EXTS and f.stem not in known)
    return {
        'pictures': {'total': len(pics), 'done': len(done), 'waiting': waiting,
                     'missing': missing, 'redo': {k: v for k, v in redo.items() if k in known}},
        'kit': kit_status(sid, prompts, layers, art_dir),
        'unknown_files': unknown,
        'art_dir': str(art_dir),
        'art_dir_exists': art_dir.is_dir(),
    }


def over_budget(sid: str) -> list[str]:
    """Size-only budget check (pixel widths: tool/check_assets.py)."""
    from check_assets import AUDIO_MAX, LAYER_MAX, budget
    folder = STORIES / sid
    out, total = [], 0
    for f in sorted((folder / 'images').rglob('*')):
        if not f.is_file() or f.suffix == '.json':
            continue
        size = f.stat().st_size
        total += size
        rel = f.relative_to(folder / 'images').as_posix()
        limit = LAYER_MAX if rel.startswith('layers/') else budget(rel)[1]
        if size > limit:
            out.append(f'{rel} {size // KB} KB > {limit // KB} KB')
    for f in sorted((folder / 'audio').rglob(f'*.{EXT}')):
        size = f.stat().st_size
        total += size
        if size > AUDIO_MAX:
            out.append(f'{f.relative_to(folder)} {size // KB} KB > {AUDIO_MAX // KB} KB')
    if total > STORY_MAX:
        out.append(f'story total {total / KB / KB:.1f} MB > 4 MB')
    return out


# ---------- audio ----------

def audio_status(sid: str, story: dict, progress: dict) -> dict:
    manifest = clean_audio.load_manifest()
    listened = progress.get('listened', {})
    out = {}
    for lang in LANGS:
        folder = STORIES / sid / 'audio' / lang
        names = [n for text, key in story_lines(story, lang)
                 for n, _ in line_clips(text, key, lang) if n]
        recorded, uncleaned, unheard, missing = [], [], [], []
        for n in names:
            clip = folder / n
            raw = [folder / f'{Path(n).stem}.{e}' for e in clean_audio.RAW_EXTS if e != EXT]
            raw = [r for r in raw if r.exists()]
            if not clip.exists() and not raw:
                missing.append(Path(n).stem)
                continue
            if raw or clean_audio.is_new(clip, manifest):
                uncleaned.append(Path(n).stem)
                continue
            entry = manifest.get(clean_audio.key(clip), {})
            if entry.get('generated') and Path(n).stem not in listened.get(lang, []):
                unheard.append(Path(n).stem)
            else:
                recorded.append(Path(n).stem)
        out[lang] = {'total': len(names), 'ok': len(recorded), 'not_cleaned': uncleaned,
                     'cloned_not_heard': unheard, 'missing': missing}
    return out


# ---------- one story ----------

def status(sid: str, art_dir: Path | None = None) -> dict:
    docs = DOCS / sid
    story_path = STORIES / sid / 'story.json'
    story = read_json(story_path)
    progress = read_json(docs / 'progress.json', {})
    gates = progress.get('gates', {})
    prompts = read_json(docs / 'art_prompts.json')
    art_review = verdict(docs / 'art_review.md')
    if (art_review == 'FIX' and prompts is not None
            and newer(docs / 'art_prompts.json', docs / 'art_review.md')):
        art_review = 'FIX applied'

    s = {
        'id': sid,
        'title': (story or {}).get('title', {}).get('vi'),
        'hero': (story or {}).get('hero'),
        'section': (story or {}).get('section', 'behavior'),
        'outline': (docs / 'outline.md').exists(),
        'script': story is not None,
        'script_review': verdict(docs / 'review.md'),
        'art_prompts': prompts is not None,
        'art_review': art_review,
        'gates': gates,
        'prompts_page': progress.get('prompts_page'),
        'notes': progress.get('notes', []),
        'blockers': [],
    }
    hero = s['hero']
    if hero and not (REFS / f'{hero}.png').exists():
        s['blockers'].append(f'hero sheet tool/image_refs/{hero}.png missing: '
                             f'python3 tool/gen_image.py --refs --only {hero} --prompts-out <dir>')
    if story is not None:
        s['audio'] = audio_status(sid, story, progress)
        ref = VOICE_DIR / 'ref'
        for lang in LANGS:
            if s['audio'][lang]['missing'] and not clone_ready(ref, lang):
                s['blockers'].append(f'cloned voice ({lang}) not set up: gaps can only be '
                                     'recorded by hand (or macOS say placeholders)'
                                     + (': needs tool/voice/ref/en/ref.wav + ref.txt and '
                                        'F5TTS_v1_Base (tool/voice/setup.sh)' if lang == 'en' else ''))
        need_index, need_dirs = wire_missing(sid)
        s['wired'] = not need_index and not need_dirs
    if prompts is not None:
        s['art'] = art_status(sid, prompts, progress, art_dir or ART_DIR / sid)
    if (STORIES / sid / 'images').is_dir() or (STORIES / sid / 'audio').is_dir():
        s['over_budget'] = over_budget(sid)
    s['next'] = next_steps(s)
    s['done'] = not s['next']
    return s


def next_steps(s: dict) -> list[str]:
    """Claude's work first (files waiting), then the parent's."""
    sid, g = s['id'], s['gates']
    if not s['outline']:
        return [f'plan the story: /new-story (story-planner) for {sid}']
    if not g.get('outline') and not s['script']:
        return ['parent approves the outline (Gate 1), then story-writer']
    if not s['script']:
        return ['write the script: story-writer']
    if s['script_review'] != 'PASS' and not g.get('script'):
        return ['review the script: story-reviewer (then story-writer for FIX items)']
    if not g.get('script'):
        return ['parent approves the script (Gate 2)']

    steps = []
    art, audio = s.get('art'), s.get('audio', {})
    # Claude's work: files are waiting.
    if art and art['pictures']['waiting']:
        steps.append(f'import {len(art["pictures"]["waiting"])} new picture(s): /story-art {sid}')
    if art and art['unknown_files']:
        steps.append(f'name {len(art["unknown_files"])} unknown file(s) in {art["art_dir"]}: '
                     f'/story-art {sid} (step 1)')
    kit = art and art['kit']
    if kit and kit['to_copy']:
        steps.append('copy shared kit image(s) made for another story into '
                     f'{art["art_dir"]}/kit/: '
                     + ', '.join(f'{src} -> {n}.png' for n, src in kit['to_copy'].items()))
    if kit and kit['to_cut']:
        steps.append(f'cut {len(kit["to_cut"])} kit sheet(s) into sprites ({", ".join(kit["to_cut"])}): '
                     'tool/sprite_sheet.py (names: gen_image.py --kit --prompts-out prints the command)')
    if kit and not kit['stage_json'] and not kit['missing'] and not kit['to_copy']:
        steps.append(f'write docs/stories/{sid}/stage.json (where every part stands, per scene): tool/stage.py --help')
    elif kit and kit['compose']:
        steps.append(f'compose the scenes: tool/cutout/.venv/bin/python tool/stage.py {sid} --preview <dir>, '
                     'then show the stills to the parent')
    uncleaned = {l: a['not_cleaned'] for l, a in audio.items() if a['not_cleaned']}
    if uncleaned:
        steps.append('clean new recordings ('
                     + ', '.join(f'{l} {len(c)}' for l, c in uncleaned.items())
                     + f'): /story-audio {sid}')

    # Art prompts not ready yet: nothing for the parent to draw.
    if not s['art_prompts']:
        return steps + [f'write art prompts: art-director, then art-reviewer ({sid})']
    if s['art_review'] in (None, 'FIX', '?'):
        return steps + ['review art prompts: art-reviewer (art-director applies FIX items)']
    if not s['prompts_page']:
        steps.append(f'build + publish the prompts page: python3 tool/prompts_page.py {sid} ... '
                     '(save its link in progress.json)')

    # Parent's work.
    if art:
        p = art['pictures']
        if p['redo']:
            steps.append(f'parent redoes {len(p["redo"])} picture(s): {", ".join(p["redo"])}')
        if art['kit'] and art['kit']['waits_for']:
            steps.append(f'shared kit sheets wait for {", ".join(art["kit"]["waits_for"])} '
                         '(made there, then copied here)')
        if art['kit'] and art['kit']['missing']:
            steps.append(f'parent makes {len(art["kit"]["missing"])} kit image(s) in Gemini '
                         f'(save in {art["art_dir"]}/kit/): {", ".join(art["kit"]["missing"])}')
        if p['missing']:
            steps.append(f'parent makes {len(p["missing"])} picture(s) in Gemini, next: '
                         f'{", ".join(p["missing"][:3])}' + (' ...' if len(p['missing']) > 3 else ''))
    unheard = {l: a['cloned_not_heard'] for l, a in audio.items() if a['cloned_not_heard']}
    if unheard:
        steps.append('parent listens to cloned clips ('
                     + ', '.join(f'{l} {len(c)}' for l, c in unheard.items())
                     + f'), then mark them in progress.json: /story-audio {sid} (step 4)')
    gaps = {l: a['missing'] for l, a in audio.items() if a['missing']}
    if gaps:
        steps.append('parent records (or clone fills) '
                     + ', '.join(f'{l} {len(c)}' for l, c in gaps.items())
                     + f' clip(s): python3 tool/gen_audio.py --story {sid} --missing')

    if not steps:
        if not s.get('wired'):
            steps.append(f'wire + test: python3 tool/wire_story.py {sid}, then fvm flutter test')
        elif s.get('over_budget'):
            steps.append(f'over budget: {"; ".join(s["over_budget"][:3])} (python3 tool/check_assets.py {sid})')
    return steps


# ---------- output ----------

def kit_line(kit: dict) -> str:
    return (f'kit {kit["saved"]}/{kit["total"]} saved'
            f', sheets cut {kit["sheets"] - len(kit["to_cut"]) - kit["sheets_unsaved"]}'
            f'/{kit["sheets"]}, scenes staged {kit["staged"]}/{kit["scenes"]}')


def brief(s: dict) -> str:
    parts = []
    art = s.get('art')
    if art:
        parts.append(f'pictures {art["pictures"]["done"]}/{art["pictures"]["total"]}')
        if art['kit']:
            parts.append(kit_line(art['kit']))
    for lang, a in s.get('audio', {}).items():
        parts.append(f'audio {lang} {a["ok"]}/{a["total"]}')
    if 'wired' in s:
        parts.append('wired' if s['wired'] else 'not wired')
    tag = '' if s.get('section', 'behavior') == 'behavior' else f' [{s["section"]}]'
    head = f'{s["id"]}{tag}: ' + (', '.join(parts) if parts else 'planning')
    return head + (f' -> next: {s["next"][0]}' if s['next'] else ' -> done')


def report(s: dict) -> str:
    lines = [f'== {s["id"]}  {s["title"] or ""}  (hero {s["hero"] or "?"}, section {s["section"]})']
    g = s['gates']
    lines.append(f'outline {"yes" if s["outline"] else "no"} (approved {g.get("outline") or "no"})'
                 f' | script {"yes" if s["script"] else "no"}, review {s["script_review"] or "-"}'
                 f' (approved {g.get("script") or "no"})'
                 f' | art prompts {"yes" if s["art_prompts"] else "no"}, review {s["art_review"] or "-"}')
    if s['prompts_page']:
        lines.append(f'prompts page: {s["prompts_page"]}')
    art = s.get('art')
    if art:
        p = art['pictures']
        lines.append(f'pictures {p["done"]}/{p["total"]} imported'
                     + (f', waiting to import: {", ".join(p["waiting"])}' if p['waiting'] else '')
                     + ('' if art['art_dir_exists'] else f'  (no folder {art["art_dir"]} yet)'))
        for name, why in p['redo'].items():
            lines.append(f'  redo {name}: {why}')
        if p['missing']:
            lines.append(f'  missing: {", ".join(p["missing"])}')
        if art['kit']:
            lines.append(kit_line(art['kit'])
                         + (f', missing: {", ".join(art["kit"]["missing"])}' if art['kit']['missing'] else ''))
        if art['unknown_files']:
            lines.append(f'  unknown files: {", ".join(art["unknown_files"])}')
    for lang, a in s.get('audio', {}).items():
        extra = [f'{len(a[k])} {label}' for k, label in
                 (('not_cleaned', 'not cleaned'), ('cloned_not_heard', 'cloned, not heard'),
                  ('missing', 'missing')) if a[k]]
        lines.append(f'audio {lang}: {a["ok"]}/{a["total"]} done' + (f' ({", ".join(extra)})' if extra else ''))
    if 'wired' in s:
        lines.append('wired (index.json + pubspec)' if s['wired'] else 'not wired yet')
    for o in s.get('over_budget', []):
        lines.append(f'  OVER {o}')
    for b in s['blockers']:
        lines.append(f'BLOCKER {b}')
    for n in s['notes']:
        lines.append(f'note: {n}')
    lines.append('next:' if s['next'] else 'next: nothing left. Play it in both languages.')
    lines += [f'  {i}. {step}' for i, step in enumerate(s['next'], 1)]
    return '\n'.join(lines)


def story_ids() -> list[str]:
    ids = {p.name for p in DOCS.iterdir() if p.is_dir()} if DOCS.is_dir() else set()
    ids |= {p.name for p in STORIES.iterdir() if (p / 'story.json').exists()}
    return sorted(ids)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('story_id', nargs='?')
    out = ap.add_mutually_exclusive_group()
    out.add_argument('--brief', action='store_true', help='one line per unfinished story')
    out.add_argument('--json', action='store_true', help='machine-readable')
    ap.add_argument('--art-dir', type=Path, help='pictures folder (default ~/Downloads/story_art/<id>)')
    args = ap.parse_args()

    ids = [args.story_id] if args.story_id else story_ids()
    if args.story_id and args.story_id not in story_ids():
        sys.exit(f'No story {args.story_id} (docs/stories/ or assets/stories/)')
    results = [status(i, args.art_dir) for i in ids]
    if args.json:
        print(json.dumps(results[0] if args.story_id else results, ensure_ascii=False, indent=1))
    elif args.brief:
        unfinished = [s for s in results if not s['done']]
        if unfinished:
            print('Bedtime stories in progress (python3 tool/story_status.py <id> for details, '
                  '/story-continue to resume):')
            for s in unfinished:
                print(f'  {brief(s)}')
            for s in unfinished:
                for b in s['blockers']:
                    print(f'  {s["id"]} blocker: {b}')
    else:
        print('\n\n'.join(report(s) for s in results) or 'No stories yet.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
