#!/usr/bin/env python3
"""Build a phone-friendly HTML page of a story's Gemini prompts (kit room and
sheets, pictures, plates, poses) with copy buttons and done ticks, for making
the art by hand in the Gemini app. Publish the page as an Artifact to use it on a phone.

    python3 tool/prompts_page.py <id> <out.html> [--title 'Backpack Story Prompts']

Runs gen_image.py --prompts-out for every step (no API call), so every
prompt starts with its file name. Character sheets come from tool/image_refs/.
Ticks are saved in the viewer's browser only (localStorage, per story).
"""
import base64
import html
import io
import json
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
REFS = ROOT / 'tool/image_refs'

STEPS = [   # a step with no prompts (no kit, or a kit story's plates and poses) is left out
    ('kit', ['--kit'], 'Kit · Room and sheets',
     'The whole story is built from these: one empty room, then sheets of poses and things on a plain '
     'background. Every figure must be whole, apart from the others and the same size. Save in a kit/ folder.'),
    ('pictures', [], 'Step 1 · Pictures',
     'Attach the sheets listed on each card, paste the prompt, save under the name shown. '
     'Keep all scenes in one Gemini chat so the room and props stay the same.'),
    ('plates', ['--plates'], 'Step 2 · Plates',
     'Attach the scene picture from step 1; Gemini removes the child and/or Lulu. Save in a plates/ folder.'),
    ('poses', ['--poses'], 'Step 3 · Poses',
     'Attach the scene picture from step 1; only the pose changes. If the character moves or changes size, '
     'redo it. Save in a poses/ folder.'),
]

CSS = '''
/* Layout: one narrow column of prompt cards, night-bedroom palette, big copy buttons for a phone */
:root {
  --bg: #f6f3fb; --card: #ffffff; --fg: #2b2540; --muted: #6b6485; --line: #e3ddf0;
  --accent: #e0604e; --accent-fg: #ffffff; --done: #3f9a6b; --pre: #f3eff9;
  --display: "Baloo 2", "Nunito", system-ui, sans-serif; --body: "Nunito", system-ui, sans-serif;
  --mono: "JetBrains Mono", ui-monospace, Menlo, monospace;
}
@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) {
  --bg: #161327; --card: #211d38; --fg: #ece8f8; --muted: #a39cc0; --line: #343052;
  --accent: #f08a74; --accent-fg: #1b1426; --done: #6fcf9c; --pre: #1a1730; color-scheme: dark; } }
:root[data-theme="dark"] {
  --bg: #161327; --card: #211d38; --fg: #ece8f8; --muted: #a39cc0; --line: #343052;
  --accent: #f08a74; --accent-fg: #1b1426; --done: #6fcf9c; --pre: #1a1730; color-scheme: dark; }
body { background: var(--bg); color: var(--fg); font: 16px/1.5 var(--body);
  padding-left: max(16px, env(safe-area-inset-left, 0px)); padding-right: max(16px, env(safe-area-inset-right, 0px)); padding-block: 24px 64px; }
main { max-width: 720px; margin: 0 auto; display: grid; gap: 32px; }
h1, h2 { font-family: var(--display); line-height: 1.15; text-wrap: balance; margin: 0; }
h1 { font-size: 2rem; } h2 { font-size: 1.4rem; }
.lead, .note { color: var(--muted); margin: 6px 0 0; }
section { display: grid; gap: 12px; }
.refs { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; }
figure { margin: 0; background: var(--card); border: 1px solid var(--line); border-radius: 12px; overflow: hidden; }
figure img { display: block; width: 100%; height: auto; }
figcaption { padding: 6px 10px; font: 13px var(--mono); color: var(--muted); }
.list { display: grid; gap: 14px; }
.card { background: var(--card); border: 1px solid var(--line); border-radius: 14px; padding: 14px; display: grid; gap: 10px; min-width: 0; }
.card.is-done { opacity: .55; }
.done { display: flex; align-items: center; gap: 10px; cursor: pointer; }
.done input { width: 22px; height: 22px; accent-color: var(--done); }
.name { font-family: var(--display); font-size: 1.15rem; font-weight: 700; }
dl { margin: 0; display: grid; gap: 2px; font-size: .92rem; }
dl div { display: flex; gap: 8px; flex-wrap: wrap; }
dt { color: var(--muted); min-width: 64px; text-transform: uppercase; letter-spacing: .06em; font-size: .75rem; padding-top: 3px; }
dd { margin: 0; min-width: 0; overflow-wrap: anywhere; }
code { font-family: var(--mono); font-size: .85rem; }
pre { margin: 0; background: var(--pre); border-radius: 10px; padding: 10px 12px; white-space: pre-wrap; overflow-wrap: anywhere;
  font: 13px/1.5 var(--mono); max-height: 9.5em; overflow: auto; }
.copy { min-height: 48px; border: 0; border-radius: 12px; background: var(--accent); color: var(--accent-fg); font: 700 1rem var(--body); cursor: pointer; }
.copy:focus-visible, .done input:focus-visible { outline: 3px solid var(--fg); outline-offset: 2px; }
.copy.ok { background: var(--done); }
.progress { font: 600 .95rem var(--body); color: var(--muted); }
'''

JS = '''
(() => {
  const KEY = 'ticks_' + document.body.dataset.story;
  let ticks = {};
  try { ticks = JSON.parse(localStorage.getItem(KEY) || '{}'); } catch (e) {}
  const boxes = [...document.querySelectorAll('.done input')];
  const progress = document.getElementById('progress');
  const paint = () => {
    let done = 0;
    boxes.forEach(b => {
      const card = b.closest('.card');
      b.checked = !!ticks[card.dataset.id];
      card.classList.toggle('is-done', b.checked);
      if (b.checked) done++;
    });
    progress.textContent = done + ' of ' + boxes.length + ' done';
  };
  boxes.forEach(b => b.addEventListener('change', () => {
    const id = b.closest('.card').dataset.id;
    if (b.checked) ticks[id] = 1; else delete ticks[id];
    try { localStorage.setItem(KEY, JSON.stringify(ticks)); } catch (e) {}
    paint();
  }));
  document.querySelectorAll('.copy').forEach(btn => btn.addEventListener('click', () => {
    const pre = document.getElementById(btn.dataset.target);
    const ok = () => { btn.textContent = 'Copied'; btn.classList.add('ok');
      setTimeout(() => { btn.textContent = 'Copy prompt'; btn.classList.remove('ok'); }, 1500); };
    const select = () => { const r = document.createRange(); r.selectNodeContents(pre);
      const s = getSelection(); s.removeAllRanges(); s.addRange(r); btn.textContent = 'Selected: copy it'; };
    if (navigator.clipboard) navigator.clipboard.writeText(pre.textContent).then(ok, select); else select();
  }));
  paint();
})();
'''


def parse(f: Path) -> dict:
    head, _, body = f.read_text(encoding='utf-8').partition('\n\n')
    meta = dict(line.split(': ', 1) for line in head.splitlines() if ': ' in line)
    return {'attach': meta.get('Attach first', 'nothing').split('  (')[0],
            'save': meta['Save the image as'], 'shape': meta.get('Shape'), 'prompt': body.strip()}


def thumb(p: Path) -> str:
    im = Image.open(p).convert('RGB')
    im.thumbnail((520, 520))
    b = io.BytesIO()
    im.save(b, 'JPEG', quality=80)
    return 'data:image/jpeg;base64,' + base64.b64encode(b.getvalue()).decode()


def card(n: int, c: dict) -> str:
    name = html.escape(Path(c['save']).stem)
    rows = [('Attach', html.escape(c['attach'])), ('Save as', f'<code>{html.escape(c["save"])}</code>')]
    if c['shape']:
        rows.append(('Shape', c['shape']))
    dl = ''.join(f'<div><dt>{k}</dt><dd>{v}</dd></div>' for k, v in rows)
    return (f'<article class="card" id="c{n}" data-id="{html.escape(c["save"])}">'
            f'<header><label class="done"><input type="checkbox" id="done{n}" aria-label="Mark {name} done">'
            f'<span class="name">{name}</span></label></header>'
            f'<dl>{dl}</dl><pre id="p{n}">{html.escape(c["prompt"])}</pre>'
            f'<button type="button" class="copy" data-target="p{n}">Copy prompt</button></article>')


def main():
    args = sys.argv[1:]
    page_title = None
    if '--title' in args:
        i = args.index('--title')
        page_title = args[i + 1]
        del args[i:i + 2]
    if len(args) != 2:
        sys.exit(__doc__)
    story, out = args[0], Path(args[1]).expanduser()
    meta = json.loads((ROOT / 'assets/stories' / story / 'story.json').read_text(encoding='utf-8'))
    hero = meta.get('hero', 'kid')
    title_vi = meta['title']['vi'].replace('{name}', 'Bé')
    page_title = page_title or story.replace('_', ' ').capitalize() + ' prompts'
    sections, n, sheets = [], 0, set()
    with tempfile.TemporaryDirectory() as tmp:
        for folder, flags, title, note in STEPS:
            d = Path(tmp) / folder
            subprocess.run([sys.executable, str(ROOT / 'tool/gen_image.py'), '--story', story, *flags,
                            '--prompts-out', str(d)], check=True, stdout=subprocess.DEVNULL)
            items = []
            for f in sorted(d.glob('*.txt')):
                n += 1
                c = parse(f)
                sheets.update(a.strip() for a in c['attach'].split(',') if a.strip() in ('girl.png', 'boy.png', 'kid.png', 'lulu.png'))
                items.append(card(n, c))
            if not items:
                continue
            sections.append(f'<section><h2>{title}</h2><p class="note">{len(items)} prompts. {note}</p>'
                            f'<div class="list">{"".join(items)}</div></section>')
    figs = ''.join(f'<figure><img src="{thumb(REFS / s)}" alt="{s} character sheet"><figcaption>{s}</figcaption></figure>'
                   for s in sorted(sheets) if (REFS / s).exists())
    page = (
        f'<title>{html.escape(page_title)}</title>\n'
        '<meta name="claude:viewport-fit-sides" content="cover">\n'
        '<link rel="preconnect" href="https://fonts.googleapis.com">\n'
        '<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Baloo+2:wght@600;700'
        '&family=Nunito:wght@400;600;700&family=JetBrains+Mono:wght@400&display=swap">\n'
        f'<style>{CSS}</style>\n'
        f'<main data-story="{story}">\n<header><h1>{html.escape(title_vi)} · Gemini prompts</h1>'
        f'<p class="lead">{hero.capitalize()} pictures for <code>{story}</code> ({n} prompts). Each prompt starts with '
        f'its file name in [brackets], so the Gemini chat shows which picture it is. Save everything to '
        f'<code>~/Downloads/story_art/{story}/</code>. Long-press a character sheet to save it, then attach it in '
        f'Gemini. Ticks are remembered on this device only.</p><p class="progress" id="progress"></p></header>\n'
        f'<section><h2>Character sheets</h2><div class="refs">{figs}</div></section>\n'
        f'{"".join(sections)}\n</main>\n'
        f'<script>document.body.dataset.story = {json.dumps(story)};{JS}</script>\n')
    out.write_text(page, encoding='utf-8')
    print(f'{out}  ({n} prompts, {len(page) // 1024} KB)')


if __name__ == '__main__':
    main()
