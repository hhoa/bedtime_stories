#!/usr/bin/env python3
"""Make story pictures with an image AI (Google Gemini or OpenAI), saved as WebP.

Keys: GEMINI_API_KEY (aistudio.google.com/apikey) or OPENAI_API_KEY
(platform.openai.com/api-keys), from the shell environment or the repo's
.env file (git-ignored). Never commit a key. Costs money per picture: try
--dry first. --engine picks the service (default: gemini if its key is set).

1. Character sheets (once, then reused by every story so the hero looks
   the same everywhere). Look at them, redo until happy:
     python3 tool/gen_image.py --refs                 # girl, boy, kid, lulu
     python3 tool/gen_image.py --refs --only lulu --force
   They land in tool/image_refs/<name>.png.

2. Scene prompts: docs/stories/<id>/art_prompts.json
     {
       "setting": "a cozy kid bedroom at night, toy box, star lamp",
       "pictures": {
         "s1_toys": "{hero} sits on the rug with blocks around; Lulu peeks from the toy box",
         "icon_toybox": "a wooden toy box with toys neatly inside",
         "sticker_toybox": "a smiling toy box sticker"
       }
     }
   {hero} becomes "the girl/boy/child from the reference picture", picked by
   the story's hero (story.json "hero": girl|boy|kid). Pictures that
   mention {hero} or Lulu get that character sheet as a reference.
   Name rules (shape) are the same as tool/import_art.py.

3. Generate (skips files that exist unless --force):
     python3 tool/gen_image.py --story tidy_toys --dry          # print prompts, no cost
     python3 tool/gen_image.py --story tidy_toys
     python3 tool/gen_image.py --story tidy_toys --only s1_toys --force

No API credit? Make them by hand in the Gemini or ChatGPT app:
     python3 tool/gen_image.py --refs --prompts-out ~/Downloads/art_prompts
     python3 tool/gen_image.py --story tidy_toys --prompts-out ~/Downloads/art_prompts
   Paste each .txt (attach the listed reference sheets), download the
   image under the "Save the image as" name, then bring them in:
     tool/cutout/.venv/bin/python tool/import_art.py --refs ~/Downloads/story_art
     tool/cutout/.venv/bin/python tool/import_art.py tidy_toys ~/Downloads/story_art/tidy_toys --new
   (or /story-art tidy_toys: import, watermark, checks)

Kit stories (few pictures: one empty room + sheets of poses and props that
tool/sprite_sheet.py cuts apart and tool/stage.py composes into scenes) keep
their prompts under "kit" in art_prompts.json:
     "kit": {"room": {"attach": "<picture to edit, or nothing>", "prompt": "..."},
             "sheets": {"hero_a": {"who": "hero", "figures": {"sit_play": "the child sits ...", ...}},
                        "lulu_a": {"who": "lulu", "figures": {...}},
                        "props": {"who": "props", "figures": {"ball": "a red-and-white ball", ...}}}}
     python3 tool/gen_image.py --story tidy_toys --kit --prompts-out ~/Downloads/art_prompts
   A sheet may set "columns", a "note" (extra sentence) and "attach" (a picture
   made earlier, e.g. kit/hero_a.png for hero_b). Save as kit/<name>.png.
   Top-level "attach": {"cover": ["kit/room.png", "kit/props.png"]} lists earlier
   pictures to attach to a normal picture's prompt (--prompts-out only).

Then set the node images in story.json to images/<name>.webp.
Only drawn reference sheets and text are sent: never photos of the real
child, never the child's name.
"""
from __future__ import annotations

import argparse
import base64
import io
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from import_art import dest_for, save_art  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
REFS = ROOT / 'tool/image_refs'
OPENAI_API = 'https://api.openai.com/v1/images'
GEMINI_API = 'https://generativelanguage.googleapis.com/v1beta/models'
ENGINES = {  # engine -> key env name, model env name, default model
    'gemini': ('GEMINI_API_KEY', 'GEMINI_IMAGE_MODEL', 'gemini-3.1-flash-image-preview'),
    'openai': ('OPENAI_API_KEY', 'OPENAI_IMAGE_MODEL', 'gpt-image-2'),
}

STYLE = (
    'Soft 3D cartoon picture-book illustration for a bedtime story for 3-5 year olds. '
    'Warm cozy lamp light, gentle pastel colors, calm and safe mood, rounded friendly shapes, '
    'big expressive eyes. No text, no letters, no words, no logos anywhere in the picture.'
)

CHARACTERS = {
    'girl': 'A cheerful 4 year old Vietnamese girl with a chin-length fluffy dark brown bob '
            'and full straight bangs, big dark brown eyes, round rosy cheeks, wearing soft '
            'mint-green long-sleeve pajamas with little white stars, barefoot.',
    'boy': 'A cheerful 4 year old Vietnamese boy with short dark brown hair and a soft fringe, '
           'wearing soft mint-green long-sleeve pajamas with little white stars, barefoot.',
    'lulu': 'Lulu, a small magical plush bunny friend: round cream-white body, long cream ears '
            'with pink insides, rosy cheeks, tiny pink nose, an amber crescent moon on the belly, '
            'softly glowing and floating a little above the ground.',
    'kid': 'A cheerful 4 year old Vietnamese child, can be a girl or a boy: a short fluffy '
           'dark brown bob haircut with soft bangs just above the eyes, round rosy cheeks, '
           'no bow, no hair clips, no jewelry, wearing soft mint-green pajamas with little white stars.',
}


class Shape:
    def __init__(self, openai_size: str, aspect: str, frame: str):
        self.openai_size, self.aspect, self.frame = openai_size, aspect, frame


SHAPES = {  # name prefix -> shape
    'icon_': Shape('1024x1024', '1:1', 'A single simple object centered on a plain soft dark-blue '
                                       'background, big and clear like an app icon, readable at small size.'),
    'sticker_': Shape('1024x1024', '1:1', 'A cute sticker: one object with a thick white outline, centered, '
                                          'on a plain white background.'),
}
SCENE = Shape('1536x1024', '4:3', 'Landscape scene. Keep the main characters in the middle area, '
                                  'away from the edges.')
SHEET = Shape('1024x1024', '1:1', '')


def shape_for(name: str) -> Shape:
    if name == 'sticker':
        return SHAPES['sticker_']
    for prefix, shape in SHAPES.items():
        if name.startswith(prefix):
            return shape
    return SCENE


def load_dotenv():
    """KEY=VALUE lines from the repo .env; shell variables win, empty values skipped."""
    env = ROOT / '.env'
    if not env.exists():
        return
    for line in env.read_text(encoding='utf-8').splitlines():
        line = line.strip()
        if not line or line.startswith('#') or '=' not in line:
            continue
        k, v = line.removeprefix('export ').split('=', 1)
        k, v = k.strip(), v.strip().strip('"\'')
        if v and not os.environ.get(k):
            os.environ[k] = v


def api_key(engine: str) -> str:
    name = ENGINES[engine][0]
    key = os.environ.get(name, '').strip()
    if not key:
        sys.exit(f'{name} not set. Put it in the repo .env file ({name}=...) or in ~/.zshrc.')
    return key


def curl(args: list[str], headers: str) -> dict:
    """Run curl with headers (holding the key) on stdin, never in argv."""
    cmd = ['curl', '-sS', '--max-time', '300', '-H', '@-'] + args
    out = subprocess.run(cmd, input=headers.encode(), capture_output=True)
    body = out.stdout.decode(errors='replace')
    try:
        data = json.loads(body)
    except json.JSONDecodeError:
        sys.exit(f'API error: {body or out.stderr.decode(errors="replace")}')
    if 'error' in data:
        msg = data['error'].get('message', data['error'])
        hint = '\n(try another --model if this one is not available to you)' if 'model' in str(msg).lower() else ''
        sys.exit(f'API error: {msg}{hint}')
    return data


def _json_file(obj) -> str:
    f = tempfile.NamedTemporaryFile('w', suffix='.json', delete=False)
    json.dump(obj, f)
    f.close()
    return f.name


def call_openai(prompt, shape: Shape, refs, model, quality, transparent) -> Image.Image:
    fields = {'model': model, 'prompt': prompt, 'size': shape.openai_size, 'quality': quality, 'n': 1}
    if transparent:
        fields['background'] = 'transparent'
    headers = f'Authorization: Bearer {api_key("openai")}\n'
    if refs:  # /edits takes reference images as multipart
        args = [x for k, v in fields.items() for x in ('-F', f'{k}={v}')]
        args += [x for r in refs for x in ('-F', f'image[]=@{r}')]
        data = curl(args + [f'{OPENAI_API}/edits'], headers)
    else:
        data = curl(['-d', '@' + _json_file(fields), f'{OPENAI_API}/generations'],
                    headers + 'Content-Type: application/json\n')
    return Image.open(io.BytesIO(base64.b64decode(data['data'][0]['b64_json'])))


def call_gemini(prompt, shape: Shape, refs, model, quality, transparent) -> Image.Image:
    parts = [{'text': prompt}]
    for r in refs:
        parts.append({'inlineData': {'mimeType': 'image/png',
                                     'data': base64.b64encode(r.read_bytes()).decode()}})
    body = {
        'contents': [{'role': 'user', 'parts': parts}],
        'generationConfig': {
            'responseModalities': ['IMAGE'],
            'imageConfig': {'aspectRatio': shape.aspect},
        },
    }
    headers = f'x-goog-api-key: {api_key("gemini")}\nContent-Type: application/json\n'
    data = curl(['-d', '@' + _json_file(body), f'{GEMINI_API}/{model}:generateContent'], headers)
    cands = data.get('candidates') or []
    for p in (cands[0].get('content', {}).get('parts', []) if cands else []):
        if 'inlineData' in p:
            return Image.open(io.BytesIO(base64.b64decode(p['inlineData']['data'])))
    reason = cands[0].get('finishReason') if cands else data.get('promptFeedback')
    text = ' '.join(p.get('text', '') for p in cands[0].get('content', {}).get('parts', [])) if cands else ''
    sys.exit(f'Gemini returned no image (reason: {reason}). {text}'.strip())


def call(args, prompt, shape, refs, transparent=False) -> Image.Image:
    fn = call_gemini if args.engine == 'gemini' else call_openai
    return fn(prompt, shape, refs, args.model, args.quality, transparent)


def build_prompt(text: str, hero: str | None, setting: str | None, name: str):
    """Full prompt + the reference sheets it needs."""
    refs, who = [], []
    if hero and '{hero}' in text:
        text = text.replace('{hero}', f'the {hero} from the reference picture')
        refs.append(REFS / f'{hero}.png')
        who.append(f'Draw the {hero} exactly like the reference picture, same face, hair, '
                   f'outfit, colors and proportions: {CHARACTERS[hero]}')
    if 'lulu' in text.lower():
        refs.append(REFS / 'lulu.png')
        who.append(f'Draw Lulu exactly like the bunny reference picture, same size, shape and '
                   f'colors: {CHARACTERS["lulu"]} Lulu is small, about the size of a cat.')
    if who:
        who.append('Keep the same soft 3D art style as the reference pictures.')
    shape = shape_for(name)
    parts = [STYLE, shape.frame]
    if setting and not name.startswith(('icon_', 'sticker')):
        parts.append(f'Setting: {setting}.')
    parts += who + [f'Scene: {text}']
    return ' '.join(parts), refs, shape


def name_tag(target: str) -> str:
    """Opening line of a pasted prompt, so the Gemini chat shows which file it is."""
    return f'[{target}] (file name for my notes only, never draw it)\n'


def write_prompt(args, label: str, prompt: str, refs: list[Path], target: str, aspect: str,
                 extra: list[str] | None = None):
    """--prompts-out: one .txt per picture to paste into the Gemini/ChatGPT app.
    `extra`: pictures the parent made earlier to attach too (art_prompts.json "attach")."""
    out = Path(args.prompts_out).expanduser()
    out.mkdir(parents=True, exist_ok=True)
    args.n_written = getattr(args, 'n_written', 0) + 1
    f = out / f'{args.n_written:02d}_{label}.txt'
    attach = ', '.join([r.name for r in refs] + (extra or [])) or 'nothing'
    f.write_text(
        f'Attach first: {attach}  (your character sheets, also in tool/image_refs/)\n'
        f'Shape: {aspect}\n'
        f'Save the image as: {target}\n\n'
        f'{name_tag(target)}{prompt}\n', encoding='utf-8')
    print(f'{f}')


def run_refs(args):
    REFS.mkdir(parents=True, exist_ok=True)
    for name, desc in CHARACTERS.items():
        if args.only and name not in args.only:
            continue
        dest = REFS / f'{name}.png'
        if dest.exists() and not args.force:
            print(f'skip {dest.relative_to(ROOT)} (exists, --force to redo)')
            continue
        prompt = (f'{STYLE} Character reference sheet: {desc} '
                  'Full body, standing, front view, friendly smile, plain light background.')
        if args.prompts_out:
            write_prompt(args, f'ref_{name}', prompt, [], f'{name}.png', SHEET.aspect)
            continue
        if args.dry:
            print(f'--- {name}\n{prompt}\n')
            continue
        print(f'making {name} with {args.engine} ({args.model}) ...', flush=True)
        call(args, prompt, SHEET, []).save(dest)
        print(f'  -> {dest.relative_to(ROOT)}')


def story_hero(story: str, spec: dict) -> str:
    """The story's hero (story.json "hero"), else art_prompts "hero", else kid."""
    path = ROOT / 'assets/stories' / story / 'story.json'
    if path.exists():
        hero = json.loads(path.read_text(encoding='utf-8')).get('hero')
        if hero:
            return hero
    return spec.get('hero', 'kid')


def run_story(args):
    spec_path = ROOT / 'docs/stories' / args.story / 'art_prompts.json'
    if not spec_path.exists():
        sys.exit(f'missing {spec_path.relative_to(ROOT)} (see --help for the format)')
    spec = json.loads(spec_path.read_text(encoding='utf-8'))
    hero = story_hero(args.story, spec)
    if hero not in CHARACTERS:
        sys.exit(f'unknown hero "{hero}" (girl|boy|kid)')
    for name, text in spec['pictures'].items():
        if args.only and name not in args.only:
            continue
        sticker = name == 'sticker' or name.startswith('sticker_')
        dest = dest_for(args.story, name)
        if dest.exists() and not args.force:
            print(f'skip {dest.relative_to(ROOT)} (exists)')
            continue
        prompt, refs, shape = build_prompt(text, hero, spec.get('setting'), name)
        if args.prompts_out:
            write_prompt(args, name, prompt, refs, f'{name}.png', shape.aspect,
                         spec.get('attach', {}).get(name))
            continue
        missing = [r for r in refs if not r.exists()]
        if missing and not args.dry:
            sys.exit(f'missing reference {missing[0].relative_to(ROOT)}: run --refs first')
        if args.dry:
            print(f'--- {dest.relative_to(ROOT)} [{shape.aspect}, refs: {[r.name for r in refs]}]\n{prompt}\n')
            continue
        print(f'making {dest.relative_to(ROOT)} with {args.engine} ...', flush=True)
        out = save_art(call(args, prompt, shape, refs, transparent=sticker), dest,
                       unmark=False)  # API pictures have no visible sparkle
        print(f'  -> {out.stat().st_size // 1024} KB')


SHEET_RULES = (
    'Rules for the sheet: every figure is complete, nothing cut off by the picture edge. Wide empty '
    'space around every figure: no figure touches or overlaps another. Every figure is drawn at the '
    'same scale, as if seen from the same distance, from the front and slightly above, like in a '
    'picture book. Plain flat pale warm-grey background and nothing else: no floor line, no furniture, '
    'no shadow on the background, no frame, no numbers, no labels, no text. Soft warm lamp light from '
    'the upper left on every figure, like a cozy bedroom at night.'
)
SHEET_WHO = {'lulu': ('lulu', 'Lulu the bunny'), 'props': (None, 'things')}


def kit_sheet_prompt(sheet: dict, hero: str) -> tuple[str, list[Path]]:
    """One sheet of the kit: several figures on a plain background, cut apart
    by tool/sprite_sheet.py in this order."""
    figures = sheet['figures']
    who = sheet.get('who', 'hero')
    ref, noun = SHEET_WHO.get(who, (hero, 'the same child'))
    cols = sheet.get('columns', 3 if len(figures) <= 6 else 4)
    rows = -(-len(figures) // cols)
    listing = ' '.join(f'{i}) {text}.' for i, text in enumerate(figures.values(), start=1))
    if who == 'props':
        head = (f'A sheet of {len(figures)} separate toys and things for a picture book, each drawn once, '
                f'in a grid of {cols} columns and {rows} rows.')
        look = 'Soft rounded toy-like shapes, the same art style for all of them.'
    elif sheet.get('outfit'):
        # Same child, other clothes ("outfit": "a plain soft-yellow t-shirt and navy shorts").
        head = (f'A pose sheet: {len(figures)} separate full-body pictures of {noun}, '
                f'in a grid of {cols} columns and {rows} rows.')
        who_text = re.sub(r',? wearing .*$', '', CHARACTERS[ref]).rstrip('.')
        look = (f'Draw {noun} exactly like the reference picture in every figure, same face, hair, '
                f'colors and body size: {who_text}. But in every figure the child wears '
                f'{sheet["outfit"]} instead of the pajamas.')
    else:
        head = (f'A pose sheet: {len(figures)} separate full-body pictures of {noun}, '
                f'in a grid of {cols} columns and {rows} rows.')
        look = (f'Draw {noun} exactly like the reference picture in every figure, same face, hair, '
                f'clothes, colors and body size: {CHARACTERS[ref]}')
    extra = f' {sheet["note"]}' if sheet.get('note') else ''
    prompt = (f'{STYLE} {head} In reading order, row by row, left to right: {listing} '
              f'{SHEET_RULES} {look}{extra}')
    return prompt, ([REFS / f'{ref}.png'] if ref else [])


def kit_rooms(kit: dict) -> dict[str, dict]:
    """Room pictures of a kit, by their file name in kit/: "room" (one room)
    or "room_<name>" ("rooms": {"night": {...}, "day": {...}}). An entry is
    {"attach", "prompt"} (made in Gemini) or {"from": "<story>/kit/<file>.png"}
    (copied from another story's art folder)."""
    rooms = {f'room_{k}': v for k, v in kit.get('rooms', {}).items()}
    if kit.get('room'):
        rooms['room'] = kit['room']
    return rooms


def run_kit(args):
    """--kit --prompts-out: prompts for the kit (art_prompts.json "kit": one
    empty room + sheets of poses and props), for tool/sprite_sheet.py and tool/stage.py."""
    spec = json.loads((ROOT / 'docs/stories' / args.story / 'art_prompts.json').read_text(encoding='utf-8'))
    kit = spec.get('kit')
    if not kit:
        return
    hero = story_hero(args.story, spec)
    out = Path(args.prompts_out).expanduser()
    out.mkdir(parents=True, exist_ok=True)
    n = 0
    for name, room in kit_rooms(kit).items():
        if args.only and name not in args.only:
            continue
        if room.get('from'):
            print(f'{name}: copy ~/Downloads/story_art/{room["from"]} to '
                  f'~/Downloads/story_art/{args.story}/kit/{name}.png (no Gemini)')
            continue
        n += 1
        f = out / f'{n:02d}_kit_{name}.txt'
        f.write_text(
            f'Attach first: {room.get("attach", "nothing")}\n'
            f'Shape: {room.get("shape", SCENE.aspect)}\n'
            f'Save the image as: kit/{name}.png\n\n'
            f'{name_tag(f"kit/{name}.png")}{room["prompt"]}\n', encoding='utf-8')
        print(f)
    for name, sheet in kit.get('sheets', {}).items():
        if args.only and name not in args.only:
            continue
        cut = (f'  then: tool/cutout/.venv/bin/python tool/sprite_sheet.py '
               f'~/Downloads/story_art/{args.story}/kit/{name}.png --names {",".join(sheet["figures"])}'
               + (' --fill-holes' if sheet.get('who') == 'lulu' else ''))
        if sheet.get('from'):
            # Made for another story: copy it, cut it here under the same names.
            print(f'{name}: copy ~/Downloads/story_art/{sheet["from"]} to '
                  f'~/Downloads/story_art/{args.story}/kit/{name}.png (no Gemini)')
            print(cut)
            continue
        n += 1
        prompt, refs = kit_sheet_prompt(sheet, hero)
        # "attach": extra pictures after the character sheet, e.g. the first
        # pose sheet so the second one draws the child at the same size.
        attach = [r.name for r in refs] + ([sheet['attach']] if sheet.get('attach') else [])
        f = out / f'{n:02d}_kit_{name}.txt'
        f.write_text(
            f'Attach first: {", ".join(attach) or "nothing"}\n'
            f'Shape: {SCENE.aspect}\n'
            f'Save the image as: kit/{name}.png\n\n'
            f'{name_tag(f"kit/{name}.png")}{prompt}\n', encoding='utf-8')
        print(f)
        print(cut)


def main():
    load_dotenv()
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0],
                                 formatter_class=argparse.RawDescriptionHelpFormatter, epilog=__doc__)
    ap.add_argument('--refs', action='store_true', help='make character sheets in tool/image_refs/')
    ap.add_argument('--story')
    ap.add_argument('--kit', action='store_true',
                    help='with --story and --prompts-out: room + sheet prompts (art_prompts.json "kit") '
                         'for tool/sprite_sheet.py and tool/stage.py')
    ap.add_argument('--only', type=lambda s: set(s.split(',')), help='comma list of picture names')
    ap.add_argument('--force', action='store_true', help='redo existing files')
    ap.add_argument('--dry', action='store_true', help='print prompts only, no API call')
    ap.add_argument('--prompts-out', metavar='DIR',
                    help='write one prompt .txt per picture to paste into the Gemini/ChatGPT app (no key)')
    ap.add_argument('--engine', choices=list(ENGINES),
                    default='gemini' if os.environ.get('GEMINI_API_KEY') else 'openai')
    ap.add_argument('--model', help='default per engine (env GEMINI_IMAGE_MODEL / OPENAI_IMAGE_MODEL)')
    ap.add_argument('--quality', default='medium', choices=['low', 'medium', 'high'],
                    help='OpenAI only: low for drafts, high for final art (costs more)')
    args = ap.parse_args()
    _, model_env, default_model = ENGINES[args.engine]
    args.model = args.model or os.environ.get(model_env) or default_model
    if args.refs:
        run_refs(args)
    elif args.story and args.kit:
        if not args.prompts_out:
            ap.error('--kit needs --prompts-out')
        run_kit(args)
    elif args.story:
        run_story(args)
    else:
        ap.error('use --refs or --story <id>')


if __name__ == '__main__':
    main()
