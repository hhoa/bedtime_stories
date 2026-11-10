#!/usr/bin/env python3
"""Compose a story's scenes from kit sprites (one room + cut-out figures).

Kit art: the parent makes one empty room, a few sheets of hero / Lulu poses
and one sheet of props; tool/sprite_sheet.py cuts the sheets into sprites;
this tool places the sprites per scene from docs/stories/<id>/stage.json and
writes what the app already plays (SceneLayers): images/layers.json entries
with cropped part layers that share files across scenes.

stage.json:
  {"room": "kit/room.png",                    # under the art folder
   "crop": [0.05, 0.0, 0.80, 1.0],            # optional: part of the room file to use (then fit to 4:3)
   "erase_specks": [[0.0, 0.1, 0.2, 0.4]],    # optional: boxes where small bright specks are painted out
   "tint": 0.0,                              # 0..1: warm the sprites with the room's lamp tone
   "sheets": {"hero_a": {"scale": 0.9},       # sheet px -> picture px (picture = 1600x1200)
              "lulu_a": {"scale": 0.5, "anchor": "center"}},
   "sprites": {"hero_b/throw": {"anchor": [0.4, 1.0]}},   # optional per-sprite anchor
   "icons": {"icon_tidy": ["props/toybox_full"]},          # 400x400 choice icons from sprites
   "covers": {"bed_front": [[0.0, 0.62], [0.3, 0.6], [0.3, 0.8], [0.0, 0.9]]},   # room pieces drawn again on top
   "scenes": {"a1_toybox": {"parts": [
     {"kind": "blocks", "sprite": "props/blocks", "at": [0.40, 0.86], "size": 0.14},
     {"kind": "hero", "sprite": "hero_b/kneel_block", "at": [0.58, 0.86],
      "poses": {"drop": "hero_a/kneel_happy"}, "shadow": true},
     {"kind": "toybox", "sprite": "props/toybox_empty", "at": [0.42, 0.84], "size": 0.30,
      "poses": {"full": "props/toybox_full"}, "tap": "wiggle"}]}}}

A part: list order = draw order (later = on top). "at" = where the sprite's
anchor goes (picture fractions). Anchor: "feet" (default: middle of the
bottom edge of the figure) or "center", or [x, y] fractions of the sprite.
Size: "size" = height of the part's own sprite as a fraction of the picture
height; without it the sheet's "scale" applies (times the part's "scale"),
which keeps one body size across all poses of a sheet. "poses" switch on
`pose` cues and share the part's place and scale. "flip": true mirrors.
"shadow": true puts a soft floor shadow under it. "idle" / "tap" default by
kind (hero breathes, Lulu floats, props wiggle when tapped; "tap": null =
not tappable). {"cover": "bed_front"} in a scene's parts redraws that piece
of the room (a polygon, picture fractions) over everything listed before it:
a child sitting in bed goes behind the blanket, a ball rolls under the bed.
A `move` cue's "to" is where the part's pivot goes: the
pivot of every part is printed (feet for standing things, middle for Lulu).

Writes into assets/stories/<id>/images/:
  layers/kit_room.webp            the room, bottom layer of every staged scene
  layers/kit_<sheet>_<name>.webp  one file per sprite; sprites that swap with
                                  each other share one canvas, anchors lined up
  layers/kit_shadow.webp          the floor shadow
  layers/kit_cover_<name>.webp    room pieces from "covers"
  layers.json                     entries of the staged scenes (others kept)
  <scene>.webp                    small flat composite (fallback picture)
  icon_*.webp                     from "icons"
Old layers/kit_* files nothing uses any more are removed (only that prefix).

Usage:
  PY=tool/cutout/.venv/bin/python
  $PY tool/stage.py tidy_toys --preview <dir>           # write assets + stills to look at
  $PY tool/stage.py tidy_toys --preview <dir> --dry     # stills only, assets untouched
  $PY tool/stage.py tidy_toys --preview <dir> --dry --only a1_toybox --guides --tint 0.2
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageOps

sys.path.insert(0, str(Path(__file__).resolve().parent))
from check_assets import LAYER_MAX  # noqa: E402
from layer_crop import MOTION  # noqa: E402
from remove_watermark import remove_watermark  # noqa: E402
from webp_save import save_webp  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
ART_DIR = Path.home() / 'Downloads/story_art'
W, H = 1600, 1200
KB = 1024
FLAT = (800, 600)            # fallback picture: never shown while layers load, so small
FLAT_MAX = 45 * KB
ICON = 400
ICON_MAX = 40 * KB
ICON_BG = (62, 76, 120)      # the slate blue of the Gemini choice icons
SPRITE_Q = 78                # like cut layers (tool/cutout.py)
SOFT = 1.15                  # warn when a sprite is shown bigger than this x its sheet size
SHADOW = (40, 22, 18)
PROP_MOTION = ('none', 'wiggle')


# ---------- sprites ----------

class Sprite:
    """One cut figure, trimmed to its pixels, at sheet resolution."""

    def __init__(self, key: str, flip: bool, img: Image.Image, scale: float, anchor):
        self.key, self.flip, self.scale = key, flip, scale
        a = img.getchannel('A').point(lambda v: 255 if v > 60 else 0)
        img = img.crop(a.getbbox() or (0, 0, *img.size))
        self.img = ImageOps.mirror(img) if flip else img
        self.w, self.h = self.img.size
        self.ax, self.ay = self._anchor(anchor)

    def _anchor(self, mode) -> tuple[float, float]:
        solid = np.array(self.img.getchannel('A')) > 60
        if isinstance(mode, list):
            x = (1 - mode[0]) if self.flip else mode[0]
            return x * self.w, mode[1] * self.h
        if mode == 'center':
            ys, xs = np.nonzero(solid)
            return float(xs.mean()), float(ys.mean())
        if mode != 'feet':
            sys.exit(f'{self.key}: anchor must be "feet", "center" or [x, y], got {mode!r}')
        xs = np.nonzero(solid[int(self.h * 0.9):].any(axis=0))[0]
        return (xs.min() + xs.max() + 1) / 2, float(self.h)

    @property
    def file(self) -> str:
        return 'layers/kit_' + self.key.replace('/', '_') + ('_flip' if self.flip else '') + '.webp'

    def at_scale(self, k: float) -> Image.Image:
        size = (max(1, round(self.w * k)), max(1, round(self.h * k)))
        return self.img if size == self.img.size else self.img.resize(size, Image.LANCZOS)


class Kit:
    def __init__(self, spec: dict, art: Path, tint: float, tone: tuple[float, float, float]):
        self.spec, self.art, self.tint, self.tone = spec, art, tint, tone
        self.cache: dict[tuple[str, bool], Sprite] = {}
        self.missing: set[str] = set()

    def get(self, key: str, flip: bool) -> Sprite | None:
        if (key, flip) in self.cache:
            return self.cache[key, flip]
        conf = self.spec.get('sprites', {}).get(key, {})
        sheet = self.spec.get('sheets', {}).get(key.split('/')[0], {})
        anchor = conf.get('anchor', sheet.get('anchor', 'feet'))
        if 'from' in conf:
            img = self.combined(conf)
            if img is None:
                return None
        else:
            path = self.art / 'kit/sprites' / f'{key}.png'
            if not path.exists():
                self.missing.add(str(path))
                return None
            img = Image.open(path).convert('RGBA')
        if self.tint > 0:
            rgb = np.asarray(img.convert('RGB'), np.float32)
            rgb *= 1 - self.tint + self.tint * np.array(self.tone, np.float32)
            warm = Image.fromarray(rgb.clip(0, 255).astype(np.uint8)).convert('RGBA')
            warm.putalpha(img.getchannel('A'))
            img = warm
        s = Sprite(key, flip, img, float(sheet.get('scale', 1.0)), anchor)
        self.cache[key, flip] = s
        return s

    def combined(self, conf: dict) -> Image.Image | None:
        """A sprite made of sprites: "from" plus "add" items pasted on top
        ({"sprite", "at": centre as fractions of the base, "scale": sheet px factor}),
        e.g. the full toy box with the ball on the blocks. Same sheet, same scale."""
        paths = [self.art / 'kit/sprites' / f'{k}.png' for k in [conf['from']] + [a['sprite'] for a in conf.get('add', [])]]
        gone = [str(p) for p in paths if not p.exists()]
        if gone:
            self.missing.update(gone)
            return None
        base = Image.open(paths[0]).convert('RGBA')
        for item, path in zip(conf.get('add', []), paths[1:]):
            top = Image.open(path).convert('RGBA')
            sc = float(item.get('scale', 1.0))
            top = top.resize((max(1, round(top.width * sc)), max(1, round(top.height * sc))), Image.LANCZOS)
            x = round(item['at'][0] * base.width - top.width / 2)
            y = round(item['at'][1] * base.height - top.height / 2)
            # grow the canvas if the added piece sticks out (e.g. above the rim)
            l, t = max(0, -x), max(0, -y)
            r, b = max(0, x + top.width - base.width), max(0, y + top.height - base.height)
            if l or t or r or b:
                grown = Image.new('RGBA', (base.width + l + r, base.height + t + b), (0, 0, 0, 0))
                grown.paste(base, (l, t))
                base, x, y = grown, x + l, y + t
            base.alpha_composite(top, (x, y))
        return base


# ---------- layout ----------

class Part:
    """A placed part of one scene: its sprites and how big they are drawn."""

    def __init__(self, scene: str, raw: dict, kit: Kit):
        self.scene, self.raw = scene, raw
        self.kind = raw['kind']
        self.at = raw['at']
        flip = bool(raw.get('flip'))
        self.default = kit.get(raw['sprite'], flip)
        self.poses = {name: kit.get(key, flip) for name, key in raw.get('poses', {}).items()}
        self.f = 1.0   # picture px per (sheet px x sheet scale)
        if self.default is not None:
            if 'size' in raw:
                self.f = raw['size'] * H / (self.default.h * self.default.scale)
            else:
                self.f = float(raw.get('scale', 1.0))
        idle, tap = MOTION.get(self.kind, PROP_MOTION)
        self.idle = raw.get('idle', idle)
        self.tap = raw.get('tap', tap)

    def sprites(self) -> list[Sprite]:
        return [s for s in [self.default, *self.poses.values()] if s is not None]

    def px(self, s: Sprite) -> float:
        """Sheet px -> picture px for [s] in this part."""
        return s.scale * self.f

    def box(self, s: Sprite) -> list[float]:
        k = self.px(s)
        return [self.at[0] - s.ax * k / W, self.at[1] - s.ay * k / H, s.w * k / W, s.h * k / H]

    def pivot(self) -> list[float]:
        b = self.box(self.default)
        if self.idle == 'float':
            return [round(b[0] + b[2] / 2, 4), round(b[1] + b[3] / 2, 4)]
        return [round(self.at[0], 4), round(b[1] + b[3], 4)]


def union(a: list[float], b: list[float]) -> list[float]:
    x0, y0 = min(a[0], b[0]), min(a[1], b[1])
    x1, y1 = max(a[0] + a[2], b[0] + b[2]), max(a[1] + a[3], b[1] + b[3])
    return [x0, y0, x1 - x0, y1 - y0]


class Cover:
    """A piece of the room drawn again on top (the bed's front board, the
    blanket): parts listed before it in a scene go behind it."""

    def __init__(self, name: str, polygon: list[list[float]], room: Image.Image):
        mask = Image.new('L', (W, H), 0)
        ImageDraw.Draw(mask).polygon([(x * W, y * H) for x, y in polygon], fill=255)
        mask = mask.filter(ImageFilter.GaussianBlur(1.2))
        b = mask.getbbox()
        b = (max(0, b[0] - 2), max(0, b[1] - 2), min(W, b[2] + 2), min(H, b[3] + 2))
        pic = room.convert('RGBA')
        pic.putalpha(mask)
        self.img = pic.crop(b)
        self.xy = b[:2]
        self.rect = [round(b[0] / W, 6), round(b[1] / H, 6), round((b[2] - b[0]) / W, 6), round((b[3] - b[1]) / H, 6)]
        self.file = f'layers/kit_cover_{name}.webp'
        self.kind = 'cover'

    def layer(self) -> dict:
        r = self.rect
        return {'file': self.file, 'kind': self.kind, 'rect': r,
                'pivot': [round(r[0] + r[2] / 2, 4), round(r[1] + r[3] / 2, 4)]}


class Group:
    """Sprites that swap with each other: one canvas, anchors on one point."""

    def __init__(self):
        self.sprites: list[Sprite] = []
        self.f_max = 0.0

    def measure(self):
        s = self.sprites
        self.left = max(x.ax * x.scale for x in s)
        self.right = max((x.w - x.ax) * x.scale for x in s)
        self.top = max(x.ay * x.scale for x in s)
        self.bottom = max((x.h - x.ay) * x.scale for x in s)
        # Stored size: as big as the biggest use, never above sheet resolution.
        self.store = min(self.f_max, 1 / max(x.scale for x in s))

    def canvas(self, s: Sprite) -> Image.Image:
        g = self.store
        size = (max(1, round((self.left + self.right) * g)), max(1, round((self.top + self.bottom) * g)))
        out = Image.new('RGBA', size, (0, 0, 0, 0))
        pic = s.at_scale(s.scale * g)
        out.alpha_composite(pic, (max(0, round((self.left - s.ax * s.scale) * g)),
                                  max(0, round((self.top - s.ay * s.scale) * g))))
        return out

    def rect(self, part: Part) -> list[float]:
        f = part.f
        return [round(part.at[0] - self.left * f / W, 6), round(part.at[1] - self.top * f / H, 6),
                round((self.left + self.right) * f / W, 6), round((self.top + self.bottom) * f / H, 6)]


def build_groups(parts: list) -> dict[int, Group]:
    """Union the sprites of each part; returns id(sprite) -> its group."""
    parts = [p for p in parts if isinstance(p, Part)]
    parent: dict[int, int] = {}
    by_id: dict[int, Sprite] = {}

    def find(i: int) -> int:
        while parent[i] != i:
            parent[i] = parent[parent[i]]
            i = parent[i]
        return i

    for p in parts:
        ss = p.sprites()
        for s in ss:
            by_id[id(s)] = s
            parent.setdefault(id(s), id(s))
        for s in ss[1:]:
            parent[find(id(s))] = find(id(ss[0]))
    groups: dict[int, Group] = {}
    for i, s in by_id.items():
        groups.setdefault(find(i), Group()).sprites.append(s)
    out = {}
    for g in groups.values():
        for s in g.sprites:
            out[id(s)] = g
    for p in parts:
        if p.default is not None:
            g = out[id(p.default)]
            g.f_max = max(g.f_max, p.f)
    for g in groups.values():
        g.measure()
    return out


# ---------- drawing ----------

def shadow_box(part: Part) -> list[float]:
    """Ellipse under the part's feet, picture fractions."""
    b = part.box(part.default)
    wide = b[2] * (part.raw['shadow'] if isinstance(part.raw['shadow'], (int, float))
                   and not isinstance(part.raw['shadow'], bool) else 0.9)
    tall = wide * W / H * 0.22
    return [round(part.at[0] - wide / 2, 6), round(b[1] + b[3] - tall * 0.62, 6), round(wide, 6), round(tall, 6)]


def shadow_image() -> Image.Image:
    w, h = 320, 80
    a = Image.new('L', (w, h), 0)
    ImageDraw.Draw(a).ellipse([30, 16, w - 30, h - 16], fill=110)
    out = Image.new('RGBA', (w, h), SHADOW + (0,))
    out.putalpha(a.filter(ImageFilter.GaussianBlur(11)))
    return out


def paste_frac(canvas: Image.Image, pic: Image.Image, box: list[float]):
    size = (max(1, round(box[2] * canvas.width)), max(1, round(box[3] * canvas.height)))
    canvas.alpha_composite(pic.resize(size, Image.LANCZOS),
                           (round(box[0] * canvas.width), round(box[1] * canvas.height)))


def paste_clipped(canvas: Image.Image, pic: Image.Image, xy: tuple[int, int]):
    """alpha_composite that tolerates a sprite hanging over the picture edge."""
    layer = Image.new('RGBA', canvas.size, (0, 0, 0, 0))
    layer.paste(pic, xy)
    canvas.alpha_composite(layer)


def erase_specks(room: Image.Image, boxes: list[list[float]]) -> Image.Image:
    """Paint out small bright specks (leftover sparkles) inside boxes
    [x0, y0, x1, y1] (picture fractions) from the wall around them."""
    import cv2
    arr = np.asarray(room.convert('RGB')).copy()
    lum = arr.astype(np.float32).mean(2)
    mask = np.zeros(lum.shape, np.uint8)
    for x0, y0, x1, y1 in boxes:
        sl = (slice(round(y0 * H), round(y1 * H)), slice(round(x0 * W), round(x1 * W)))
        local = cv2.medianBlur(lum[sl].astype(np.uint8), 31).astype(np.float32)
        mask[sl] = ((lum[sl] - local) > 18).astype(np.uint8) * 255
    mask = cv2.dilate(mask, np.ones((7, 7), np.uint8))
    return Image.fromarray(cv2.inpaint(arr, mask, 9, cv2.INPAINT_TELEA))


def compose(room: Image.Image, parts: list[Part], shadow: Image.Image,
            pose: tuple[int, str] | None = None) -> Image.Image:
    """The scene as the app first shows it; [pose] = (part index, pose name) swapped in."""
    out = room.convert('RGBA')
    for i, p in enumerate(parts):
        if isinstance(p, Cover):
            out.alpha_composite(p.img, p.xy)
            continue
        if p.default is None:
            continue
        if p.raw.get('shadow'):
            paste_frac(out, shadow, shadow_box(p))
        s = p.poses[pose[1]] if pose and pose[0] == i else p.default
        if s is None:
            continue
        k = p.px(s)
        paste_clipped(out, s.at_scale(k), (round(p.at[0] * W - s.ax * k), round(p.at[1] * H - s.ay * k)))
    return out


def guides(img: Image.Image, parts: list[Part]) -> Image.Image:
    """10% grid, each part's tap box, pivot cross and name."""
    out = img.convert('RGB')
    d = ImageDraw.Draw(out)
    for i in range(1, 10):
        d.line([(i * W // 10, 0), (i * W // 10, H)], fill=(255, 255, 255), width=1)
        d.line([(0, i * H // 10), (W, i * H // 10)], fill=(255, 255, 255), width=1)
        d.text((i * W // 10 + 4, 4), f'{i / 10:.1f}', fill='white')
        d.text((4, i * H // 10 + 4), f'{i / 10:.1f}', fill='white')
    for p in parts:
        if isinstance(p, Cover):
            r = p.rect
            d.rectangle([r[0] * W, r[1] * H, (r[0] + r[2]) * W, (r[1] + r[3]) * H], outline=(80, 200, 255), width=2)
            continue
        if p.default is None:
            continue
        b = p.box(p.default)
        d.rectangle([b[0] * W, b[1] * H, (b[0] + b[2]) * W, (b[1] + b[3]) * H], outline=(255, 80, 80), width=2)
        x, y = p.pivot()[0] * W, p.pivot()[1] * H
        d.line([(x - 12, y), (x + 12, y)], fill=(255, 255, 0), width=3)
        d.line([(x, y - 12), (x, y + 12)], fill=(255, 255, 0), width=3)
        d.text((b[0] * W + 4, b[1] * H + 4), f'{p.kind} pivot {p.pivot()}', fill=(255, 255, 0))
    return out


def icon_image(items: list, kit: Kit) -> Image.Image | None:
    """Sprites on the choice-icon blue. An item: "sheet/name" or
    {"sprite", "at": [x, y] (anchor, icon fractions), "size": height fraction, "flip", "rot": degrees}."""
    out = Image.new('RGBA', (ICON, ICON), ICON_BG + (255,))
    glow = Image.new('L', (ICON, ICON), 0)
    ImageDraw.Draw(glow).ellipse([60, 60, ICON - 60, ICON - 60], fill=38)
    out.alpha_composite(Image.merge('RGBA', [Image.new('L', (ICON, ICON), 255)] * 3
                                    + [glow.filter(ImageFilter.GaussianBlur(50))]))
    for item in items:
        if isinstance(item, str):
            item = {'sprite': item}
        if 'line' in item:   # a soft white stroke [x0, y0, x1, y1]: speed lines
            x0, y0, x1, y1 = (v * ICON for v in item['line'])
            ImageDraw.Draw(out).line([(x0, y0), (x1, y1)], fill=(255, 255, 255, 230), width=item.get('width', 9))
            continue
        s = kit.get(item['sprite'], bool(item.get('flip')))
        if s is None:
            return None
        pic = s.img
        if item.get('rot'):
            pic = pic.rotate(item['rot'], expand=True, resample=Image.BICUBIC)
        k = item.get('size', 0.66) * ICON / pic.height
        k = min(k, 0.86 * ICON / pic.width)
        pic = pic.resize((max(1, round(pic.width * k)), max(1, round(pic.height * k))), Image.LANCZOS)
        cx, cy = item.get('at', [0.5, 0.5])
        paste_clipped(out, pic, (round(cx * ICON - pic.width / 2), round(cy * ICON - pic.height / 2)))
    return out.convert('RGB')


def tiles(pics: list[tuple[str, Image.Image]], cols: int, size: tuple[int, int]) -> Image.Image:
    rows = (len(pics) + cols - 1) // cols
    sheet = Image.new('RGB', (cols * size[0], rows * size[1]), (20, 18, 30))
    for i, (label, pic) in enumerate(pics):
        t = pic.convert('RGB').resize(size, Image.LANCZOS)
        d = ImageDraw.Draw(t)
        d.rectangle([0, 0, 9 * len(label) + 12, 20], fill=(20, 18, 30))
        d.text((6, 4), label, fill='white')
        sheet.paste(t, ((i % cols) * size[0], (i // cols) * size[1]))
    return sheet


# ---------- main ----------

def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0],
                                 formatter_class=argparse.RawDescriptionHelpFormatter, epilog=__doc__)
    ap.add_argument('story')
    ap.add_argument('--preview', type=Path, help='write stills here: <scene>.jpg, <scene>_poses.jpg, _all.jpg')
    ap.add_argument('--dry', action='store_true', help='stills only, change nothing under assets/')
    ap.add_argument('--only', type=lambda s: set(s.split(',')), help='stills for these scenes only')
    ap.add_argument('--guides', action='store_true', help='draw grid, tap boxes and pivots on the stills')
    ap.add_argument('--tint', type=float, help='override stage.json "tint" (0..1)')
    ap.add_argument('--art-dir', type=Path, help='default ~/Downloads/story_art/<id>')
    ap.add_argument('--spec', type=Path, help='another stage.json (trying things out; use with --dry)')
    args = ap.parse_args()
    if args.dry and not args.preview:
        ap.error('--dry needs --preview')

    spec_path = args.spec.expanduser() if args.spec else ROOT / 'docs/stories' / args.story / 'stage.json'
    if not spec_path.exists():
        sys.exit(f'missing {spec_path}')
    spec = json.loads(spec_path.read_text(encoding='utf-8'))
    art = (args.art_dir or ART_DIR / args.story).expanduser()
    room_src = Path(spec['room']).expanduser()
    room_src = room_src if room_src.is_absolute() else art / room_src
    if not room_src.exists():
        sys.exit(f'no room picture {room_src}')
    with Image.open(room_src) as im:
        room, _ = remove_watermark(ImageOps.exif_transpose(im).convert('RGB'))
    if spec.get('crop'):   # [x0, y0, x1, y1] fractions of the room file (Gemini may return 16:9)
        x0, y0, x1, y1 = spec['crop']
        room = room.crop((round(x0 * room.width), round(y0 * room.height),
                          round(x1 * room.width), round(y1 * room.height)))
    room = ImageOps.fit(room, (W, H), Image.LANCZOS)
    if spec.get('erase_specks'):
        room = erase_specks(room, spec['erase_specks'])
    mean = np.asarray(room.resize((32, 24)), np.float32).reshape(-1, 3).mean(axis=0)
    tint = spec.get('tint', 0.0) if args.tint is None else args.tint
    kit = Kit(spec, art, tint, tuple(mean / mean.max()))

    covers = {name: Cover(name, poly, room) for name, poly in spec.get('covers', {}).items()}

    def make(scene: str, raw: dict):
        if 'cover' in raw:
            if raw['cover'] not in covers:
                sys.exit(f'{scene}: no cover "{raw["cover"]}" in stage.json "covers"')
            return covers[raw['cover']]
        return Part(scene, raw, kit)

    scenes = {name: [make(name, raw) for raw in sc['parts']] for name, sc in spec['scenes'].items()}
    icons = {name: icon_image(items, kit) for name, items in spec.get('icons', {}).items()}
    if kit.missing:
        sys.exit('missing sprites (cut the sheets with tool/sprite_sheet.py):\n  ' + '\n  '.join(sorted(kit.missing)))
    groups = build_groups([p for ps in scenes.values() for p in ps])
    shadow = shadow_image()

    # Layer entries per scene.
    entries: dict[str, list[dict]] = {}
    for name, parts in scenes.items():
        entry = [{'file': 'layers/kit_room.webp'}]
        seen: dict[str, int] = {}
        for p in parts:
            if isinstance(p, Cover):
                entry.append(p.layer())
                continue
            seen[p.kind] = seen.get(p.kind, 0) + 1
            if p.raw.get('shadow'):
                sb = shadow_box(p)
                entry.append({'file': 'layers/kit_shadow.webp', 'kind': 'shadow', 'rect': sb,
                              'pivot': [round(sb[0] + sb[2] / 2, 4), round(sb[1] + sb[3] / 2, 4)]})
            box = p.box(p.default)
            for s in p.poses.values():
                box = union(box, p.box(s))
            layer = {'file': p.default.file, 'kind': p.kind, 'box': [round(v, 4) for v in box],
                     'pivot': p.pivot(), 'idle': p.idle, 'rect': groups[id(p.default)].rect(p)}
            if p.tap:
                layer['tap'] = p.tap
            if p.poses:
                layer['poses'] = {n: s.file for n, s in p.poses.items()}
            entry.append(layer)
            if p.px(p.default) > SOFT:
                print(f'  soft: {name} {p.kind} shows {p.default.key} at {p.px(p.default):.2f}x its sheet size')
        for kind, n in seen.items():
            if n > 1 and kind in MOTION:
                print(f'  warning: {name} has {n} parts of kind "{kind}": a cue moves them all')
        entries[name] = entry

    for name, parts in scenes.items():
        print(f'{name}: ' + ', '.join(f'{p.kind} pivot {p.pivot()}' for p in parts if isinstance(p, Part)))

    images = ROOT / 'assets/stories' / args.story / 'images'
    if not args.dry:
        layers_dir = images / 'layers'
        layers_dir.mkdir(parents=True, exist_ok=True)
        used = {'kit_room.webp'}
        _, q, size, over = save_webp(room, layers_dir / 'kit_room.webp', LAYER_MAX)
        print(f'layers/kit_room.webp  q{q}, {size // KB} KB' + ('  OVER budget' if over else ''))
        for c in {id(p): p for ps in scenes.values() for p in ps if isinstance(p, Cover)}.values():
            save_webp(c.img, images / c.file, LAYER_MAX, q_hi=92)
            used.add(Path(c.file).name)
        if any(isinstance(p, Part) and p.raw.get('shadow') for ps in scenes.values() for p in ps):
            shadow.save(layers_dir / 'kit_shadow.webp', 'WEBP', quality=80, method=6)
            used.add('kit_shadow.webp')
        total = 0
        for g in {id(g): g for g in groups.values()}.values():
            for s in g.sprites:
                dest = images / s.file
                _, q, size, over = save_webp(g.canvas(s), dest, LAYER_MAX, q_hi=SPRITE_Q)
                used.add(dest.name)
                total += size
                if over or q < SPRITE_Q:
                    print(f'  {s.file}: q{q}, {size // KB} KB' + ('  OVER budget' if over else ''))
        print(f'{len(used) - 1} sprite files, {total // KB} KB')
        for old in layers_dir.glob('kit_*.webp'):
            if old.name not in used:
                old.unlink()
                print(f'  removed unused layers/{old.name}')
        for name, parts in scenes.items():
            flat = compose(room, parts, shadow).convert('RGB').resize(FLAT, Image.LANCZOS)
            save_webp(flat, images / f'{name}.webp', FLAT_MAX)
        for name, pic in icons.items():
            _, q, size, over = save_webp(pic, images / f'{name}.webp', ICON_MAX)
            print(f'{name}.webp  q{q}, {size // KB} KB' + ('  OVER budget' if over else ''))
        manifest_path = images / 'layers.json'
        manifest = json.loads(manifest_path.read_text()) if manifest_path.exists() else {}
        for name, entry in entries.items():
            # Keep layers other tools drew on top (the SVG clock).
            kept = [l for l in manifest.get(f'{name}.webp', []) if l['file'].endswith('.svg')]
            manifest[f'{name}.webp'] = entry + kept
        manifest_path.write_text(json.dumps(manifest, indent=1) + '\n', encoding='utf-8')
        print(f'{manifest_path.relative_to(ROOT)}: {len(entries)} staged scene(s)')

    if args.preview:
        out = args.preview.expanduser()
        out.mkdir(parents=True, exist_ok=True)
        stills = []
        for name, parts in scenes.items():
            if args.only and name not in args.only:
                continue
            pic = compose(room, parts, shadow)
            if args.guides:
                pic = guides(pic, parts)
            pic.convert('RGB').save(out / f'{name}.jpg', quality=90)
            stills.append((name, pic))
            posed = [(f'{p.kind}={pose}', compose(room, parts, shadow, (i, pose)))
                     for i, p in enumerate(parts) if isinstance(p, Part) for pose in p.poses]
            if posed:
                tiles([('default', pic), *posed], min(3, len(posed) + 1), (800, 600)).save(
                    out / f'{name}_poses.jpg', quality=88)
        if stills:
            tiles(stills, 3, (640, 480)).save(out / '_all.jpg', quality=88)
        if icons:
            tiles([(n, p) for n, p in icons.items()], len(icons), (ICON, ICON)).save(out / '_icons.jpg', quality=90)
        print(f'stills: {out}/  ({len(stills)} scene(s))')


if __name__ == '__main__':
    main()
