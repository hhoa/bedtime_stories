#!/usr/bin/env python3
"""Cut the child and/or Lulu out of a flat AI picture into moving layers.

Each part is cut from a crop around its box in images/hotspots.json with a
local background-removal model (rembg `birefnet-general-lite`, ~200 MB,
downloaded once to ~/.rembg). The part becomes a transparent WebP layer
cropped to the part (plus its poses) with its spot in layers.json "rect"
(tool/layer_crop.py), so it decodes small; the bottom layer is the same picture with the part removed:
from a clean plate (the picture without the characters, made in Gemini:
"keep this picture exactly the same, remove Lulu, fill the space behind her
naturally") when given, else filled in locally (blurrier, fine for small moves).
Writes images/layers/<scene>_<i>.webp and merges the entry into
images/layers.json, so SceneLayers animates them like drawn art: Lulu floats,
the child breathes, both hop when tapped, cues work. Parts not cut keep their
hotspot (burst on tap).

Only cut parts nothing covers (a child seated behind a table would show a
cut edge when hopping).

Poses (docs/plans/pose-animation.md): --pose hero=yawn:<png> cuts the same
part from a Gemini edit of this scene where only its pose changed, into
layers/<scene>_<i>_<pose>.webp, listed under the part's "poses" in
layers.json; story cues {"action": "pose", "pose": "yawn"} switch to it.
--preview then also draws each pose over a faint default, to check they line
up (redo the Gemini edit if one drifts). Layers this tool doesn't make (the
SVG clock from tool/clock_layer.py) are kept on top when re-cutting.

Setup (once): tool/cutout/setup.sh

Usage:
  tool/cutout/.venv/bin/python tool/cutout.py eat_veggies s2_lulu_carrot --parts lulu \\
      [--plate ~/Downloads/story_art/eat_veggies/plates/s2_lulu_carrot.png] [--preview DIR] \\
      [--pose lulu=clap:~/Downloads/story_art/eat_veggies/poses/s2_lulu_carrot__lulu__clap.png]
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageFilter, ImageOps
from rembg import new_session, remove

sys.path.insert(0, str(Path(__file__).resolve().parent))
from layer_crop import crop_group, expand  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
MODEL = 'birefnet-general-lite'
CROP_PAD = 0.04      # extra room around the hotspot box, fraction of the picture
POSE_PAD = 0.1       # more room for poses (raised arms, waving paw)
FEATHER = 1.2        # px blur on the part's edge
PLATE_GROW = 40      # px the removed area grows into a clean plate (takes Lulu's glow too)
FILL_GROW = 14       # same without a plate (local fill smears, keep it small)
MOTION = {           # kind -> (idle, tap)
    'lulu': ('float', 'hop'),
    'hero': ('breathe', 'hop'),
}
QUALITY = 86


def part_mask(img: Image.Image, box: list[float], session, pad: float = CROP_PAD) -> Image.Image:
    w, h = img.size
    x, y, bw, bh = box
    crop = (max(0, int((x - pad) * w)), max(0, int((y - pad) * h)),
            min(w, int((x + bw + pad) * w)), min(h, int((y + bh + pad) * h)))
    m = remove(img.crop(crop), session=session, only_mask=True).convert('L')
    full = Image.new('L', (w, h), 0)
    full.paste(m, crop[:2])
    # Drop the faint haze the model leaves; keep only the biggest piece (a
    # crop can catch a hand or foot of the other character); soft edge.
    arr = np.array(full.point(lambda v: 0 if v < 40 else v))
    n, labels, stats, _ = cv2.connectedComponentsWithStats((arr > 0).astype(np.uint8), connectivity=8)
    if n > 2:
        biggest = 1 + int(np.argmax(stats[1:, cv2.CC_STAT_AREA]))
        arr[labels != biggest] = 0
    return Image.fromarray(arr).filter(ImageFilter.GaussianBlur(FEATHER))


def base_layer(img: Image.Image, cut: Image.Image, plate: Path | None,
               boxes: list[list[float]]) -> Image.Image:
    """The picture with the cut parts removed."""
    grow = PLATE_GROW if plate else FILL_GROW
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (2 * grow + 1, 2 * grow + 1))
    grown = Image.fromarray(cv2.dilate((np.array(cut) > 10).astype(np.uint8) * 255, kernel))
    if plate:
        clean = align(load_fit(plate, img.size), img, boxes, 'plate')
    else:
        arr = cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)
        filled = cv2.inpaint(arr, np.array(grown), 9, cv2.INPAINT_TELEA)
        clean = Image.fromarray(cv2.cvtColor(filled, cv2.COLOR_BGR2RGB))
    # Keep the original everywhere else, so nothing shifts; blend the seam.
    out = img.copy()
    out.paste(clean, mask=grown.filter(ImageFilter.GaussianBlur(6)))
    return out


def load_fit(path: Path, size) -> Image.Image:
    """A Gemini edit (plate or pose) scaled/cropped to the scene's size."""
    with Image.open(path.expanduser()) as p:
        return ImageOps.fit(ImageOps.exif_transpose(p).convert('RGB'), size, Image.LANCZOS)


def align(edit: Image.Image, ref: Image.Image, ignore: list[list[float]], label: str) -> Image.Image:
    """Shift/scale a Gemini edit so its room lines up with the scene picture.

    Gemini edits often come back slightly zoomed or moved. Matches features
    on the background only (the [ignore] boxes, where the edit changed
    things, are masked out) and fits a similarity transform. Keeps the edit
    as is when the match is weak or the fix would be implausibly big.
    """
    w, h = ref.size
    mask = np.full((h, w), 255, np.uint8)
    for x, y, bw, bh in ignore:
        mask[max(0, int((y - POSE_PAD) * h)):int((y + bh + POSE_PAD) * h),
             max(0, int((x - POSE_PAD) * w)):int((x + bw + POSE_PAD) * w)] = 0
    orb = cv2.ORB_create(6000)
    ka, da = orb.detectAndCompute(cv2.cvtColor(np.array(edit), cv2.COLOR_RGB2GRAY), mask)
    kb, db = orb.detectAndCompute(cv2.cvtColor(np.array(ref), cv2.COLOR_RGB2GRAY), mask)
    if da is None or db is None:
        print(f'  align {label}: no features, kept as is')
        return edit
    matches = cv2.BFMatcher(cv2.NORM_HAMMING, crossCheck=True).match(da, db)
    if len(matches) < 30:
        print(f'  align {label}: {len(matches)} matches, kept as is')
        return edit
    src = np.float32([ka[m.queryIdx].pt for m in matches])
    dst = np.float32([kb[m.trainIdx].pt for m in matches])
    m, inl = cv2.estimateAffinePartial2D(src, dst, method=cv2.RANSAC, ransacReprojThreshold=4)
    n = int(inl.sum()) if inl is not None else 0
    if m is None or n < 25:
        print(f'  align {label}: {n} inliers, kept as is')
        return edit
    scale = float(np.hypot(m[0, 0], m[1, 0]))
    shift = float(np.hypot(m[0, 2], m[1, 2])) / w
    if not 0.8 < scale < 1.25 or shift > 0.2:
        print(f'  align {label}: implausible (scale {scale:.3f}), kept as is')
        return edit
    out = cv2.warpAffine(np.array(edit), m, (w, h), flags=cv2.INTER_LANCZOS4, borderMode=cv2.BORDER_REPLICATE)
    print(f'  align {label}: scale {scale:.3f}, move {m[0, 2]:+.0f},{m[1, 2]:+.0f} px ({n} inliers)')
    return Image.fromarray(out)


def parse_pose(arg: str) -> tuple[str, str, Path]:
    try:
        part, rest = arg.split('=', 1)
        name, path = rest.split(':', 1)
    except ValueError:
        raise argparse.ArgumentTypeError(f'--pose wants part=name:png, got {arg!r}')
    if name == 'default':
        raise argparse.ArgumentTypeError('"default" is the scene picture itself')
    return part, name, Path(path)


def union_box(a: list[float], b: list[float]) -> list[float]:
    x0, y0 = min(a[0], b[0]), min(a[1], b[1])
    x1, y1 = max(a[0] + a[2], b[0] + b[2]), max(a[1] + a[3], b[1] + b[3])
    return [round(x0, 4), round(y0, 4), round(x1 - x0, 4), round(y1 - y0, 4)]


def frac_box(mask: Image.Image) -> list[float]:
    w, h = mask.size
    x0, y0, x1, y1 = mask.point(lambda v: 255 if v > 60 else 0).getbbox()
    return [round(x0 / w, 4), round(y0 / h, 4), round((x1 - x0) / w, 4), round((y1 - y0) / h, 4)]


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0],
                                 formatter_class=argparse.RawDescriptionHelpFormatter, epilog=__doc__)
    ap.add_argument('story')
    ap.add_argument('scene', help='picture name without extension, e.g. s2_lulu_carrot')
    ap.add_argument('--parts', required=True, help='comma list of hotspot kinds to cut, e.g. lulu,hero')
    ap.add_argument('--plate', type=Path, help='clean plate image (picture without the parts)')
    ap.add_argument('--preview', type=Path, help='also write a check image here')
    ap.add_argument('--pose', type=parse_pose, action='append', default=[], metavar='PART=NAME:PNG',
                    help='another pose of a cut part (Gemini edit of this scene), repeatable')
    args = ap.parse_args()

    images = ROOT / 'assets/stories' / args.story / 'images'
    name = f'{args.scene}.webp'
    src = images / name
    if not src.exists():
        sys.exit(f'no picture {src.relative_to(ROOT)}')
    spots = json.loads((images / 'hotspots.json').read_text()).get(name, [])
    wanted = args.parts.split(',')
    boxes = {h['kind']: h['box'] for h in spots}
    if missing := [k for k in wanted if k not in boxes]:
        sys.exit(f'no hotspot box for {missing} in hotspots.json[{name}]')
    if stray := [p for p, _, _ in args.pose if p not in wanted]:
        sys.exit(f'--pose for {stray}: add them to --parts too')

    img = Image.open(src).convert('RGB')
    session = new_session(MODEL)
    # Keep hotspots.json order: later = on top (Lulu last).
    kinds = [h['kind'] for h in spots if h['kind'] in wanted]
    masks = {k: part_mask(img, boxes[k], session) for k in kinds}
    cut = Image.new('L', img.size, 0)
    for m in masks.values():
        cut = Image.fromarray(np.maximum(np.array(cut), np.array(m)))

    out_dir = images / 'layers'
    out_dir.mkdir(parents=True, exist_ok=True)
    entry = []
    base = out_dir / f'{args.scene}_0.webp'
    base_layer(img, cut, args.plate.expanduser() if args.plate else None, list(boxes.values())).save(
        base, 'WEBP', quality=QUALITY, method=6)
    entry.append({'file': f'layers/{base.name}'})
    written = [base]
    for i, k in enumerate(kinds, start=1):
        layer = img.convert('RGBA')
        layer.putalpha(masks[k])
        f = out_dir / f'{args.scene}_{i}.webp'
        pics = [(f, layer)]
        box = frac_box(masks[k])
        idle, tap = MOTION.get(k, ('none', 'pulse'))
        # Hop and breathe pivot at the feet, float around the middle.
        pivot = [round(box[0] + box[2] / 2, 4),
                 round(box[1] + (box[3] / 2 if idle == 'float' else box[3]), 4)]
        layer_entry = {'file': f'layers/{f.name}', 'kind': k, 'box': box, 'pivot': pivot,
                       'idle': idle, 'tap': tap}
        poses = {}
        for part, pose, path in args.pose:
            if part != k:
                continue
            pimg = align(load_fit(path, img.size), img, list(boxes.values()), f'{k}={pose}')
            pmask = part_mask(pimg, boxes[k], session, pad=POSE_PAD)
            player = pimg.convert('RGBA')
            player.putalpha(pmask)
            pf = out_dir / f'{args.scene}_{i}_{pose}.webp'
            pics.append((pf, player))
            poses[pose] = f'layers/{pf.name}'
            # Tap anywhere any pose reaches; pivot stays the default's.
            layer_entry['box'] = union_box(layer_entry['box'], frac_box(pmask))
        if poses:
            layer_entry['poses'] = poses
        # One rect for the part and all its poses.
        rect, crops = crop_group([p for _, p in pics])
        for (pf, _), c in zip(pics, crops):
            c.save(pf, 'WEBP', quality=QUALITY, method=6)
            written.append(pf)
        layer_entry['rect'] = rect
        entry.append(layer_entry)

    manifest_path = images / 'layers.json'
    manifest = json.loads(manifest_path.read_text()) if manifest_path.exists() else {}
    # Keep layers made by other tools (SVG clock) on top.
    kept = [l for l in manifest.get(name, []) if l.get('kind') and l['kind'] not in MOTION]
    manifest[name] = entry + kept
    manifest_path.write_text(json.dumps(manifest, indent=1) + '\n', encoding='utf-8')
    for f in written:
        print(f'{f.relative_to(ROOT)} ({f.stat().st_size // 1024} KB)')
    print(f'{manifest_path.relative_to(ROOT)}: {name} -> {", ".join(kinds)}'
          f'{"" if args.plate else " (no plate: filled in locally)"}')

    if args.preview:
        args.preview.mkdir(parents=True, exist_ok=True)
        base_img = Image.open(base).convert('RGB')
        tiles = [img, base_img]
        rects = {l['file']: l.get('rect') for l in entry}

        def full(file: str) -> Image.Image:
            return expand(Image.open(out_dir / Path(file).name), rects.get(f'layers/{Path(file).name}'), img.size)

        for i, k in enumerate(kinds, start=1):
            # The part lifted a little, as when it hops: shows the hole it leaves.
            moved = base_img.copy()
            layer = full(f'{args.scene}_{i}.webp')
            moved.paste(layer, (0, -int(0.055 * img.height)), layer)
            tiles.append(moved)
        w, h = 640, 480
        sheet = Image.new('RGB', (w * len(tiles), h))
        for i, t in enumerate(tiles):
            sheet.paste(t.resize((w, h)), (i * w, 0))
        p = args.preview / f'{args.scene}_cutout.jpg'
        sheet.save(p, quality=85)
        print(f'preview: {p}')
        # Each pose over a faint default: the two should line up.
        ghosts = []
        for i, k in enumerate(kinds, start=1):
            default = full(f'{args.scene}_{i}.webp')
            faint = default.copy()
            faint.putalpha(default.getchannel('A').point(lambda v: v * 45 // 100))
            for part, pose, _ in args.pose:
                if part != k:
                    continue
                t = base_img.convert('RGBA')
                t.alpha_composite(expand(Image.open(out_dir / f'{args.scene}_{i}_{pose}.webp'),
                                         rects.get(f'layers/{args.scene}_{i}.webp'), img.size))
                t.alpha_composite(faint)
                ghosts.append(t.convert('RGB'))
        if ghosts:
            sheet = Image.new('RGB', (w * len(ghosts), h))
            for i, t in enumerate(ghosts):
                sheet.paste(t.resize((w, h)), (i * w, 0))
            p = args.preview / f'{args.scene}_poses.jpg'
            sheet.save(p, quality=85)
            print(f'poses preview: {p}')


if __name__ == '__main__':
    main()
