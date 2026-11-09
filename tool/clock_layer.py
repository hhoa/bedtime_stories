#!/usr/bin/env python3
"""Draw Bác Đồng Hồ (the talking alarm clock) as SVG layers over AI pictures.

AI art gets clock numbers and hand positions wrong, so the AI pictures leave
the bedside table empty and this tool draws the clock on top: exact time,
numbers 1-12, a face with a mood, ring/chime lines. Each scene gets a
full-canvas transparent SVG layer (1600x1200, same as the WebP scenes) as a
`clock` part in images/layers.json (idle sway, tap wiggle); extra states are
pose pictures, switched by story cues {"part": "clock", "action": "pose"}.

Config: docs/stories/<id>/clock.json
  {
    "scenes": {
      "s1_ring": {
        "at": [0.2, 0.6, 0.22],            # x centre, y of the feet, height (picture fractions)
        "default": {"time": "7:00", "mood": "smile", "fx": "ring"},
        "poses": {"swirly": {"time": "8:00", "mood": "swirly"}}
      }
    },
    "sticker": {"file": "sticker_clock.svg", "time": "9:00", "mood": "asleep", "moon": true}
  }
  mood: smile | big | swirly | sleepy | asleep      fx: ring | chime | none

Run after tool/import_art.py and tool/cutout.py (cutout keeps the clock on
top when re-cutting). Measure "at" with tool/preview_hotspots.py. A scene with
no layers yet gets its own picture as the base layer.

  python3 tool/clock_layer.py clock_time [--preview DIR]
"""
from __future__ import annotations

import argparse
import json
import math
import subprocess
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from layer_crop import expand  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
W, H = 1600, 1200

BODY = '#F59E8B'        # coral
BODY_DARK = '#D9705E'
BELL = '#F6C76B'        # warm gold
BELL_DARK = '#D49A3A'
DIAL = '#FFF8EC'
INK = '#3B3355'         # numbers, short hand, face
LONG = '#E0604E'        # long hand: a different colour from the short one
CHEEK = '#F7B3A8'


def clock(cx: float, cy: float, r: float, time: str, mood: str = 'smile', fx: str = 'none',
          moon: bool = False) -> str:
    """Clock centred on the dial at (cx, cy), dial radius r (px)."""
    hh, mm = (int(v) for v in time.split(':'))
    sw = r * 0.06
    out = []
    # Feet, behind the body.
    for side in (-1, 1):
        fx_, fy = cx + side * r * 0.66, cy + r * 1.12
        out.append(f'<line x1="{cx + side * r * 0.45:.1f}" y1="{cy + r * 0.85:.1f}" x2="{fx_:.1f}" y2="{fy - r * 0.06:.1f}" '
                   f'stroke="{BODY_DARK}" stroke-width="{r * 0.13:.1f}" stroke-linecap="round"/>'
                   f'<ellipse cx="{fx_:.1f}" cy="{fy:.1f}" rx="{r * 0.17:.1f}" ry="{r * 0.09:.1f}" fill="{BODY_DARK}"/>')
    # Bells and hammer on top.
    for side in (-1, 1):
        a = math.radians(side * 38)
        bx, by = cx + math.sin(a) * r * 1.14, cy - math.cos(a) * r * 1.14
        out.append(f'<g transform="rotate({side * 38} {bx:.1f} {by:.1f})">'
                   f'<path d="M{bx - r * 0.44:.1f},{by + r * 0.08:.1f} a{r * 0.44:.1f},{r * 0.44:.1f} 0 0 1 {r * 0.88:.1f},0 z" '
                   f'fill="url(#bell)" stroke="{BELL_DARK}" stroke-width="{sw * 0.6:.1f}"/>'
                   f'<circle cx="{bx:.1f}" cy="{by - r * 0.4:.1f}" r="{r * 0.08:.1f}" fill="{BELL_DARK}"/></g>')
    out.append(f'<line x1="{cx:.1f}" y1="{cy - r * 1.05:.1f}" x2="{cx:.1f}" y2="{cy - r * 1.28:.1f}" '
               f'stroke="{BELL_DARK}" stroke-width="{r * 0.08:.1f}" stroke-linecap="round"/>')
    out.append(f'<circle cx="{cx:.1f}" cy="{cy - r * 1.3:.1f}" r="{r * 0.09:.1f}" fill="{BELL}" '
               f'stroke="{BELL_DARK}" stroke-width="{sw * 0.5:.1f}"/>')
    if moon:
        mx, my = cx + r * 0.78, cy - r * 1.18
        out.append(f'<path d="M{mx:.1f},{my - r * 0.2:.1f} a{r * 0.2:.1f},{r * 0.2:.1f} 0 1 0 {r * 0.2:.1f},{r * 0.3:.1f} '
                   f'a{r * 0.15:.1f},{r * 0.15:.1f} 0 1 1 {-r * 0.2:.1f},{-r * 0.3:.1f} z" fill="#9B8CF0"/>')
    # Body ring and dial.
    out.append(f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="{r * 1.16:.1f}" fill="url(#body)" '
               f'stroke="{BODY_DARK}" stroke-width="{sw * 0.7:.1f}"/>')
    out.append(f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="{r:.1f}" fill="url(#dial)"/>')
    # Numbers 1-12: big and clear (the story teaches reading them).
    for n in range(1, 13):
        a = math.radians(n * 30)
        nx, ny = cx + math.sin(a) * r * 0.79, cy - math.cos(a) * r * 0.79
        big = n in (12, 3, 6, 9, 7)
        fs = r * (0.25 if big else 0.21)
        out.append(f'<text x="{nx:.1f}" y="{ny + fs * 0.36:.1f}" font-size="{fs:.1f}" text-anchor="middle" '
                   f'font-family="Arial Rounded MT Bold, Arial, sans-serif" font-weight="bold" fill="{INK}">{n}</text>')
    out.append(face(cx, cy, r, mood))
    # Hands: long thin red one for minutes, short thick dark one for hours.
    ma = math.radians(mm * 6)
    ha = math.radians((hh % 12 + mm / 60) * 30)
    out.append(f'<line x1="{cx:.1f}" y1="{cy:.1f}" x2="{cx + math.sin(ma) * r * 0.66:.1f}" '
               f'y2="{cy - math.cos(ma) * r * 0.66:.1f}" stroke="{LONG}" stroke-width="{r * 0.065:.1f}" '
               f'stroke-linecap="round"/>')
    out.append(f'<line x1="{cx:.1f}" y1="{cy:.1f}" x2="{cx + math.sin(ha) * r * 0.42:.1f}" '
               f'y2="{cy - math.cos(ha) * r * 0.42:.1f}" stroke="{INK}" stroke-width="{r * 0.11:.1f}" '
               f'stroke-linecap="round"/>')
    out.append(f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="{r * 0.08:.1f}" fill="{BELL}" stroke="{INK}" '
               f'stroke-width="{sw * 0.4:.1f}"/>')
    out.append(effects(cx, cy, r, fx))
    return ''.join(out)


def face(cx, cy, r, mood) -> str:
    """Eyes above the centre pin, mouth low on the dial (clear of 7, 8, 9 o'clock hands)."""
    ex, ey, er = r * 0.3, cy - r * 0.3, r * 0.075
    sw = r * 0.045
    stroke = f'stroke="{INK}" stroke-width="{sw:.1f}" stroke-linecap="round" fill="none"'
    parts = []
    for side in (-1, 1):
        x = cx + side * ex
        if mood == 'swirly':
            parts.append(f'<path d="M{x:.1f},{ey:.1f} m{-er * 0.4:.1f},0 a{er * 0.4:.1f},{er * 0.4:.1f} 0 1 1 {er * 0.8:.1f},0 '
                         f'a{er * 0.9:.1f},{er * 0.9:.1f} 0 1 1 {-er * 1.7:.1f},0 a{er * 1.4:.1f},{er * 1.4:.1f} 0 1 1 {er * 2.6:.1f},0" {stroke}/>')
        elif mood == 'asleep':
            parts.append(f'<path d="M{x - er * 1.3:.1f},{ey:.1f} q{er * 1.3:.1f},{er * 1.3:.1f} {er * 2.6:.1f},0" {stroke}/>')
        elif mood == 'sleepy':
            parts.append(f'<path d="M{x - er * 1.3:.1f},{ey:.1f} h{er * 2.6:.1f}" {stroke}/>'
                         f'<path d="M{x - er:.1f},{ey:.1f} a{er:.1f},{er * 0.8:.1f} 0 0 0 {er * 2:.1f},0 z" fill="{INK}"/>')
        else:
            parts.append(f'<circle cx="{x:.1f}" cy="{ey:.1f}" r="{er:.1f}" fill="{INK}"/>'
                         f'<circle cx="{x + er * 0.35:.1f}" cy="{ey - er * 0.35:.1f}" r="{er * 0.3:.1f}" fill="#fff"/>')
        parts.append(f'<ellipse cx="{cx + side * r * 0.42:.1f}" cy="{cy + r * 0.3:.1f}" rx="{r * 0.1:.1f}" '
                     f'ry="{r * 0.06:.1f}" fill="{CHEEK}" opacity="0.8"/>')
    my, mw = cy + r * 0.48, r * 0.15
    if mood == 'big':
        parts.append(f'<path d="M{cx - mw:.1f},{my - mw * 0.3:.1f} a{mw:.1f},{mw:.1f} 0 0 0 {mw * 2:.1f},0 z" fill="{INK}"/>')
    elif mood == 'swirly':
        parts.append(f'<path d="M{cx - mw:.1f},{my:.1f} q{mw * 0.5:.1f},{-mw * 0.5:.1f} {mw:.1f},0 '
                     f't{mw:.1f},0" {stroke}/>')
    elif mood in ('asleep', 'sleepy'):
        parts.append(f'<path d="M{cx - mw * 0.6:.1f},{my:.1f} q{mw * 0.6:.1f},{mw * 0.5:.1f} {mw * 1.2:.1f},0" {stroke}/>')
    else:
        parts.append(f'<path d="M{cx - mw:.1f},{my - mw * 0.2:.1f} q{mw:.1f},{mw * 0.9:.1f} {mw * 2:.1f},0" {stroke}/>')
    return ''.join(parts)


def effects(cx, cy, r, fx) -> str:
    stroke = f'stroke="{BELL}" stroke-width="{r * 0.06:.1f}" stroke-linecap="round" fill="none"'
    if fx == 'ring':  # short shake lines beside each bell
        out = []
        for side in (-1, 1):
            for i, (a, l) in enumerate([(-58, 0.22), (-40, 0.28), (-22, 0.22)]):
                ang = math.radians(side * -a)
                x0, y0 = cx + math.sin(ang) * r * 1.5, cy - math.cos(ang) * r * 1.5
                x1, y1 = cx + math.sin(ang) * r * (1.5 + l), cy - math.cos(ang) * r * (1.5 + l)
                out.append(f'<line x1="{x0:.1f}" y1="{y0:.1f}" x2="{x1:.1f}" y2="{y1:.1f}" {stroke}/>')
        return ''.join(out)
    if fx == 'chime':  # soft sound arcs on one side
        return ''.join(f'<path d="M{cx + r * (1.3 + i * 0.22):.1f},{cy - r * (0.9 + i * 0.12):.1f} '
                       f'q{r * 0.18:.1f},{r * (0.25 + i * 0.08):.1f} 0,{r * (0.5 + i * 0.16):.1f}" {stroke} '
                       f'opacity="{0.9 - i * 0.25:.2f}"/>' for i in range(3))
    return ''


DEFS = (f'<defs>'
        f'<radialGradient id="body" cx="40%" cy="35%" r="70%"><stop offset="0" stop-color="#FFC2B4"/>'
        f'<stop offset="0.6" stop-color="{BODY}"/><stop offset="1" stop-color="{BODY_DARK}"/></radialGradient>'
        f'<radialGradient id="bell" cx="40%" cy="30%" r="80%"><stop offset="0" stop-color="#FFE7A8"/>'
        f'<stop offset="1" stop-color="{BELL}"/></radialGradient>'
        f'<radialGradient id="dial" cx="45%" cy="40%" r="65%"><stop offset="0" stop-color="#FFFFFF"/>'
        f'<stop offset="1" stop-color="{DIAL}"/></radialGradient>'
        f'<filter id="soft" x="-20%" y="-20%" width="140%" height="140%">'
        f'<feDropShadow dx="0" dy="6" stdDeviation="8" flood-color="#000" flood-opacity="0.25"/></filter>'
        f'</defs>')


def svg(body: str, w: int = W, h: int = H) -> str:
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">'
            f'{DEFS}{body}</svg>\n')


def placed(at, state) -> tuple[str, list[float]]:
    """Scene layer body + its tap box (fractions)."""
    x, feet, height = at
    # Whole clock spans from the top knob (cy - 1.39r) to the feet (cy + 1.21r).
    r = height * H / 2.6
    cx, cy = x * W, feet * H - r * 1.21
    body = (f'<ellipse cx="{cx:.1f}" cy="{feet * H:.1f}" rx="{r * 0.9:.1f}" ry="{r * 0.12:.1f}" '
            f'fill="#000" opacity="0.18"/>'
            f'<g filter="url(#soft)">{clock(cx, cy, r, **state)}</g>')
    box = [(cx - r * 1.5) / W, (cy - r * 1.4) / H, r * 3 / W, r * 2.61 / H]
    return body, [round(v, 4) for v in box]


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0],
                                 formatter_class=argparse.RawDescriptionHelpFormatter, epilog=__doc__)
    ap.add_argument('story')
    ap.add_argument('--preview', type=Path, help='render each clock over its picture to PNGs here')
    args = ap.parse_args()

    spec = json.loads((ROOT / 'docs/stories' / args.story / 'clock.json').read_text(encoding='utf-8'))
    images = ROOT / 'assets/stories' / args.story / 'images'
    manifest_path = images / 'layers.json'
    manifest = json.loads(manifest_path.read_text()) if manifest_path.exists() else {}

    for scene, cfg in spec.get('scenes', {}).items():
        name = next((f'{scene}{e}' for e in ('.webp', '.png', '.jpg')
                     if (images / f'{scene}{e}').exists()), None)
        if name is None:
            print(f'skip {scene}: no picture yet in images/')
            continue
        if 'at' not in cfg:
            sys.exit(f'{scene}: set "at" in clock.json (measure with tool/preview_hotspots.py)')
        states = {'default': cfg['default'], **cfg.get('poses', {})}
        files = {}
        for pose, state in states.items():
            body, box = placed(cfg['at'], state)
            fname = f'layers/{scene}_clock{"" if pose == "default" else "_" + pose}.svg'
            f = images / fname
            f.parent.mkdir(parents=True, exist_ok=True)
            f.write_text(svg(body), encoding='utf-8')
            files[pose] = fname
        x, feet, _ = cfg['at']
        layer = {'file': files.pop('default'), 'kind': 'clock', 'box': box,
                 'pivot': [x, feet], 'idle': 'sway', 'tap': 'wiggle'}
        if files:
            layer['poses'] = files
        entry = [l for l in manifest.get(name, []) if l.get('kind') != 'clock'] or [{'file': name}]
        manifest[name] = entry + [layer]
        print(f'{scene}: clock {cfg["default"]["time"]} + {len(files)} poses')

    if st := spec.get('sticker'):
        body = clock(300, 330, 170, st['time'], st.get('mood', 'smile'), st.get('fx', 'none'),
                     st.get('moon', False))
        # White sticker outline like tool/import_art.py stickers.
        outline = (f'<circle cx="300" cy="330" r="232" fill="#fff"/>'
                   f'<circle cx="300" cy="125" r="140" fill="#fff"/>')
        (images / st['file']).write_text(svg(outline + f'<g filter="url(#soft)">{body}</g>', 600, 600),
                                          encoding='utf-8')
        print(f'sticker: images/{st["file"]}')

    manifest_path.write_text(json.dumps(manifest, indent=1) + '\n', encoding='utf-8')

    if args.preview:
        preview(images, manifest, spec, args.preview)


def preview(images: Path, manifest: dict, spec: dict, out: Path):
    """Each clock pose over its scene picture, rendered with qlmanage."""
    import base64
    out.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        for scene in spec.get('scenes', {}):
            name = next((n for n in manifest if n.rsplit('.', 1)[0] == scene), None)
            clock_layer = next((l for l in manifest.get(name, []) if l.get('kind') == 'clock'), None)
            if not clock_layer:
                continue
            pic = images / name
            mime = 'image/webp' if pic.suffix == '.webp' else 'image/png'
            # qlmanage can't always read WebP inside SVG: convert to PNG first.
            from PIL import Image
            png = Path(tmp) / 'base.png'
            # The cut layers as they stand (parts may have been moved), else the picture.
            rasters = [l['file'] for l in manifest.get(name, []) if not l['file'].endswith('.svg')]
            composed = Image.open(pic).convert('RGBA').resize((W, H))
            rects = {l['file']: l.get('rect') for l in manifest.get(name, [])}
            for f in rasters:
                composed.alpha_composite(expand(Image.open(images / f), rects[f], (W, H)))
            composed.convert('RGB').save(png)
            data = base64.b64encode(png.read_bytes()).decode()
            del mime
            for f in [clock_layer['file'], *clock_layer.get('poses', {}).values()]:
                layer = (images / f).read_text(encoding='utf-8')
                inner = layer[layer.index('>') + 1:layer.rindex('</svg>')]
                src = Path(tmp) / f'{Path(f).stem}.svg'
                # qlmanage makes square thumbnails (cropping a 4:3 page), so
                # letterbox the picture into a square and crop it back after.
                pad = (W - H) // 2
                src.write_text(
                    f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" '
                    f'viewBox="0 0 {W} {W}" width="{W}" height="{W}"><g transform="translate(0 {pad})">'
                    f'<image width="{W}" height="{H}" xlink:href="data:image/png;base64,{data}"/>{inner}</g></svg>',
                    encoding='utf-8')
                subprocess.run(['qlmanage', '-t', '-s', '1000', '-o', tmp, str(src)], check=True, capture_output=True)
                dest = out / f'{src.stem}.png'
                with Image.open(Path(tmp) / f'{src.name}.png') as thumb:
                    s = thumb.width / W
                    thumb.crop((0, round(pad * s), thumb.width, round((pad + H) * s))).save(dest)
                print(dest)


if __name__ == '__main__':
    main()
