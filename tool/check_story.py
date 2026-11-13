#!/usr/bin/env python3
"""Fast checks for a story.json before art/audio/Flutter tests.

Errors (exit 1) are things the app or the house rules reject:
  - schema: ids, links, node types, 2 options (one kind, one learn),
    "hero" is girl|boy|kid, ambient values, ambient_origin in 0..1,
    reachable ending, cue actions known
  - every text (title, node text, option label) in every language (vi, en);
    cues per language: {"vi": [...], "en": [...]}, words found in order
  - {name} once per line at most, as its first or last word (so it records as
    name + one clip); never in option labels
    (keep in sync with namePlacementError in story.dart; both run
    test/fixtures/name_rule_cases.json)
  - learn path must reach a scene with offer_rewind_to = that choice
  - gendered words about the hero (say "bé" / "the little one")
  - image paths must be under images/ (one folder per story, no {hero})
  - pose cues need "pose", move cues need "to" in 0..1
  - with --art: every image exists, a pose cue or start pose names a pose
    its layer has, a cue names a part its picture has (layer kind in
    images/layers.json, or a hotspot kind in images/hotspots.json)

Warnings are for the reviewer to judge:
  - sentence longer than MAX_WORDS words, node text over MAX_NODE_WORDS
  - English he/she/his/her (fine for Lulu, not for the hero)
  - part layers still full-canvas (re-run tool/stage.py)

Usage:
  python3 tool/check_story.py <id>
  python3 tool/check_story.py <id> --art
  python3 tool/check_story.py --selftest   # shared {name} cases (test/fixtures/name_rule_cases.json)
"""
import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
STORIES_DIR = ROOT / 'assets/stories'
LANGS = ('vi', 'en')
HEROES = {'girl', 'boy', 'kid'}
AMBIENTS = {'stars', 'sparkles', 'zzz', 'motes'}
ACTIONS = {'hop', 'wiggle', 'pulse', 'pose', 'move'}
NAME = '{name}'
MAX_WORDS = {'vi': 12, 'en': 12}
MAX_NODE_WORDS = {'vi': 40, 'en': 40}
# Phrases that give the hero a gender (errors). Lulu is a bunny "bạn", fine.
GENDERED = {
    'vi': ['cậu bé', 'cô bé', 'bé trai', 'bé gái', 'con trai', 'con gái', 'anh ấy',
           'cô ấy', 'chị ấy', 'cậu ấy', 'bạn trai', 'bạn gái', 'công chúa', 'hoàng tử'],
    'en': ['boy', 'girl', 'son', 'daughter', 'prince', 'princess'],
}
# English pronouns: fine for Lulu, so only a warning.
PRONOUNS_EN = ['he', 'she', 'him', 'his', 'her', 'hers', 'himself', 'herself']


class Report:
    def __init__(self):
        self.errors, self.warnings = [], []

    def err(self, msg):
        self.errors.append(msg)

    def warn(self, msg):
        self.warnings.append(msg)


def split_sentences(text):
    """Same split as splitSentences in story.dart."""
    return [s.strip() for s in re.split(r'(?<=[.!?…])(?:["”»])?\s+', text) if s.strip()]


def name_error(text):
    """Why text breaks the {name} rule, or None. Mirrors story.dart.

    At most once per line (scene, choice question, ending), and only as the
    first or last word of the whole line, so it records as name + one clip.
    """
    n = text.count(NAME)
    if n == 0:
        return None
    if n > 1:
        return f'{NAME} more than once in the line'
    core = re.sub(r'^["“«\s]+', '', text.strip())
    core = re.sub(r'[.!?…,"”»\s]+$', '', core)
    if not core.startswith(NAME) and not core.endswith(NAME):
        return f'"{text}": {NAME} must be the first or last word of the line'
    return None


def words_of(sentence):
    return re.sub(r'["“”]', ' ', sentence).split()


def check_text(where, text, lang, r):
    low = text.lower()
    for g in GENDERED[lang]:
        if re.search(rf'(?<!\w){re.escape(g)}s?(?!\w)', low):
            r.err(f'{where}: gendered word "{g}" (say "bé" / "the little one")')
    if lang == 'en':
        for p in PRONOUNS_EN:
            if re.search(rf'(?<!\w){p}(?!\w)', low):
                r.warn(f'{where}: "{p}" — fine for Lulu, not for the hero')
                break
    for s in split_sentences(text):
        n = len(words_of(s))
        if n > MAX_WORDS[lang]:
            r.warn(f'{where}: {n} words: "{s}"')
    total = len(text.split())
    if total > MAX_NODE_WORDS[lang]:
        r.warn(f'{where}: node text has {total} words (aim ≤ {MAX_NODE_WORDS[lang]})')


def local(where, value, r):
    """{lang: text} for every language, or {} after reporting what's missing."""
    if not isinstance(value, dict):
        r.err(f'{where}: text must be {{"vi": ..., "en": ...}}')
        return {}
    for lang in LANGS:
        if not str(value.get(lang, '')).strip():
            r.err(f'{where}: no "{lang}" text')
    return {lang: value[lang] for lang in LANGS if str(value.get(lang, '')).strip()}


IMAGE_EXTS = ('.svg', '.webp', '.png', '.jpg', '.jpeg')


def check_image(where, path, r):
    if not isinstance(path, str) or not path.lower().endswith(IMAGE_EXTS):
        r.err(f'{where}: bad image path {path!r}')
    elif '{hero}' in path:
        r.err(f'{where}: {path}: no {{hero}} folders in v2, use images/<file>')
    elif not path.startswith('images/'):
        r.err(f'{where}: {path} must be under images/')


def check(story, r):
    nodes = story.get('nodes', [])
    by_id = {}
    for n in nodes:
        if n.get('id') in by_id:
            r.err(f'duplicate id {n.get("id")}')
        by_id[n.get('id')] = n

    for key in ('id', 'theme', 'hero', 'title', 'cover', 'start'):
        if not story.get(key):
            r.err(f'missing top-level "{key}"')
    if story.get('hero') and story['hero'] not in HEROES:
        r.err(f'hero "{story["hero"]}" not in {sorted(HEROES)}')
    check_image('cover', story.get('cover'), r)
    for lang, t in local('title', story.get('title'), r).items():
        check_text(f'title ({lang})', t, lang, r)
    if story.get('start') not in by_id:
        r.err(f'start "{story.get("start")}" is not a node')

    def link(where, target):
        if target not in by_id:
            r.err(f'{where}: links to missing node "{target}"')

    for n in nodes:
        nid, kind = n.get('id'), n.get('type')
        where = f'node {nid}'
        check_image(where, n.get('image'), r)
        texts = local(where, n.get('text'), r)
        for lang, t in texts.items():
            check_text(f'{where} ({lang})', t, lang, r)
            e = name_error(t)
            if e:
                r.err(f'{where} ({lang}): {e}')
        amb = n.get('ambient')
        if amb is not None and amb not in AMBIENTS:
            r.err(f'{where}: unknown ambient "{amb}"')
        origin = n.get('ambient_origin')
        if origin is not None:
            if not (isinstance(origin, list) and len(origin) == 2 and all(0 <= v <= 1 for v in origin)):
                r.err(f'{where}: ambient_origin must be [x, y] in 0..1')
            if amb != 'zzz':
                r.warn(f'{where}: ambient_origin only matters for zzz')
        elif amb == 'zzz':
            r.err(f'{where}: zzz needs ambient_origin at the sleeping head')

        cues = n.get('cues')
        if cues is not None and not isinstance(cues, dict):
            r.err(f'{where}: cues must be {{"vi": [...], "en": [...]}}')
            cues = {}
        for lang, lang_cues in (cues or {}).items():
            if lang not in LANGS:
                r.err(f'{where}: cues for unknown language "{lang}"')
                continue
            pos, text = 0, texts.get(lang, '')
            for c in lang_cues:
                w = c.get('word', '')
                at = text.find(w, pos) if w else -1
                if at < 0:
                    r.err(f'{where} ({lang}): cue word "{w}" not found (in order) in text')
                else:
                    pos = at + len(w)
                if c.get('action') not in ACTIONS:
                    r.err(f'{where}: cue action "{c.get("action")}" not in {sorted(ACTIONS)}')
                if not c.get('part'):
                    r.err(f'{where}: cue without "part"')
                if c.get('action') == 'pose' and not c.get('pose'):
                    r.err(f'{where}: pose cue "{w}" needs "pose"')
                to = c.get('to')
                if c.get('action') == 'move' and not (
                        isinstance(to, list) and len(to) == 2 and all(0 <= v <= 1 for v in to)):
                    r.err(f'{where}: move cue "{w}" needs "to": [x, y] in 0..1')
                when = c.get('at')
                if when is not None and not (isinstance(when, (int, float)) and 0 <= when <= 1):
                    r.err(f'{where}: cue "{w}" needs "at" in 0..1 (fraction of its clip)')
        if cues and set(cues) != set(LANGS):
            r.warn(f'{where}: cues only for {sorted(cues)}; the other language won\'t move')

        if kind == 'scene':
            link(where, n.get('next'))
            rw = n.get('offer_rewind_to')
            if rw is not None and by_id.get(rw, {}).get('type') != 'choice':
                r.err(f'{where}: offer_rewind_to "{rw}" is not a choice')
        elif kind == 'choice':
            opts = n.get('options', [])
            if len(opts) != 2:
                r.err(f'{where}: needs exactly 2 options')
            if sorted(o.get('kind', '') for o in opts) != ['kind', 'learn']:
                r.err(f'{where}: options must be one "kind" and one "learn"')
            for o in opts:
                ow = f'{where}/{o.get("id")}'
                link(ow, o.get('next'))
                check_image(ow, o.get('icon'), r)
                for lang, t in local(ow, o.get('label'), r).items():
                    check_text(f'{ow} ({lang})', t, lang, r)
                    if NAME in t:
                        r.err(f'{ow} ({lang}): no {NAME} in option labels')
        elif kind == 'ending':
            check_image(where, n.get('sticker'), r)
        else:
            r.err(f'{where}: unknown type "{kind}"')

    if not any(n.get('type') == 'ending' for n in nodes):
        r.err('no ending node')
    if r.errors:
        return  # graph walks below assume valid links

    def walk(start, stop_at_rewind_to=None):
        """Nodes reachable from start (following scene.next and all options)."""
        seen, todo = set(), [start]
        while todo:
            cur = todo.pop()
            if cur in seen:
                continue
            seen.add(cur)
            n = by_id[cur]
            if stop_at_rewind_to and n.get('offer_rewind_to') == stop_at_rewind_to:
                continue
            if n['type'] == 'scene':
                todo.append(n['next'])
            elif n['type'] == 'choice':
                todo += [o['next'] for o in n['options']]
        return seen

    reach = walk(story['start'])
    for nid in by_id:
        if nid not in reach:
            r.err(f'node {nid} is unreachable from start')
    for n in nodes:
        if n['type'] != 'choice':
            continue
        learn = next(o for o in n['options'] if o['kind'] == 'learn')
        path = walk(learn['next'], stop_at_rewind_to=n['id'])
        if not any(by_id[p].get('offer_rewind_to') == n['id'] for p in path):
            r.err(f'choice {n["id"]}: learn path never offers rewind (offer_rewind_to: "{n["id"]}")')


def images_used(story):
    paths = [story.get('cover')] + [n.get('image') for n in story['nodes']]
    paths += [o.get('icon') for n in story['nodes'] for o in n.get('options', [])]
    paths += [n.get('sticker') for n in story['nodes']]
    return {p.removeprefix('images/') for p in paths if p}


def load_json(path):
    return json.loads(path.read_text(encoding='utf-8')) if path.exists() else None


def check_art(story_id, story, r):
    images = STORIES_DIR / story_id / 'images'
    used = images_used(story)
    for f in sorted(used):
        if not (images / f).exists():
            r.err(f'art: images/{f} missing')
    layers = load_json(images / 'layers.json') or {}
    spots = load_json(images / 'hotspots.json') or {}

    for scene, ls in sorted(layers.items()):
        for l in ls:
            files = [l['file'], *l.get('poses', {}).values()]
            if l.get('blink'):
                files.append(l['blink'])
            for f in files:
                if not (images / f).exists():
                    r.err(f'art: layers.json {scene}: images/{f} missing')
            # Part layers must be cropped: a full-canvas layer decodes like
            # a whole scene (~7.7 MB each), and choices preload both next scenes.
            if l.get('kind') and not l['file'].endswith('.svg') and 'rect' not in l:
                r.warn(f'art: {scene} {l["kind"]} layer is full-canvas (re-run tool/stage.py {story_id})')

    for f in sorted(set(spots) - used):
        r.warn(f'hotspots.json: {f} is not a picture of this story')
    for n in story['nodes']:
        img = n.get('image', '').removeprefix('images/')
        # Layer parts move; hotspots (flat AI pictures) play a burst.
        kinds = {l['kind'] for l in layers.get(img, []) if 'kind' in l}
        kinds |= {h['kind'] for h in spots.get(img, [])}
        poses = {}  # {kind: {"default", ...poses}}, poses live on layers
        for l in layers.get(img, []):
            if 'kind' in l:
                poses.setdefault(l['kind'], {'default'}).update(l.get('poses', {}))
        all_cues = [(lang, c) for lang, cs in (n.get('cues') or {}).items() for c in cs]
        for lang, c in all_cues:
            if c.get('part') not in kinds:
                r.err(f'node {n["id"]} ({lang}): cue part "{c.get("part")}" not in {img} '
                      f'(parts/hotspots: {", ".join(sorted(kinds)) or "none"})')
            if c.get('action') in ('pose', 'move') and c.get('part') not in poses:
                r.err(f'node {n["id"]} ({lang}): {c["action"]} cue "{c.get("word")}" needs '
                      f'"{c.get("part")}" as a moving layer in {img}, a hotspot can\'t do it')
        wanted = [(c['part'], c['pose'], f'({lang}) cue "{c["word"]}"') for lang, c in all_cues
                  if c.get('action') == 'pose' and c.get('pose')]
        wanted += [(k, v, 'start pose') for k, v in n.get('poses', {}).items()]
        for part, pose, what in wanted:
            if pose not in poses.get(part, set()):
                r.err(f'node {n["id"]} {what}: no pose "{pose}" for "{part}" in {img} '
                      f'(has: {", ".join(sorted(poses.get(part, []))) or "none"})')


NAME_CASES = ROOT / 'test/fixtures/name_rule_cases.json'


def selftest():
    """Runs the shared {name} cases (the Dart test runs the same file)."""
    cases = json.loads(NAME_CASES.read_text(encoding='utf-8'))['cases']
    bad = [c for c in cases if (name_error(c['text']) is None) != c['ok']]
    for c in bad:
        print(f'FAIL  {c["text"]!r}: expected {"ok" if c["ok"] else "error"}')
    print(f'name rule: {len(cases) - len(bad)}/{len(cases)} cases pass')
    sys.exit(1 if bad else 0)


def main():
    if '--selftest' in sys.argv[1:]:
        selftest()
    parser = argparse.ArgumentParser()
    parser.add_argument('story_id')
    parser.add_argument('--art', action='store_true', help='also check images, layers, cue parts, poses')
    parser.add_argument('--dir', help='story folder (default assets/stories/<id>)')
    args = parser.parse_args()

    global STORIES_DIR
    if args.dir:
        STORIES_DIR = Path(args.dir).resolve().parent
    path = STORIES_DIR / args.story_id / 'story.json'
    try:
        story = json.loads(path.read_text(encoding='utf-8'))
    except (OSError, json.JSONDecodeError) as e:
        raise SystemExit(f'ERROR {path}: {e}')
    r = Report()
    if story.get('id') != args.story_id:
        r.err(f'id "{story.get("id")}" != folder "{args.story_id}"')
    check(story, r)
    if args.art and not r.errors:
        check_art(args.story_id, story, r)

    for w in r.warnings:
        print(f'WARN  {w}')
    for e in r.errors:
        print(f'ERROR {e}')
    print(f'{args.story_id}: {len(r.errors)} errors, {len(r.warnings)} warnings')
    sys.exit(1 if r.errors else 0)


if __name__ == '__main__':
    main()
