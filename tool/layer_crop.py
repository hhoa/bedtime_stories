"""Crop cut part layers to the part's own size (shared by cutout.py, move_part.py,
crop_layers.py, clock_layer.py).

A cut layer used to be a full 1600x1200 picture that is mostly transparent:
same decode memory as the whole scene. Now each part keeps only the rectangle
its pixels cover (plus a small margin), and images/layers.json gets
"rect": [x, y, w, h] as fractions of the picture, where SceneLayers draws it.
All poses of one part share one rect, so switching poses needs no lining up.
A layer without "rect" is full-canvas (SVG art, older cuts).
"""
from __future__ import annotations

from PIL import Image

MARGIN = 4  # px of transparent room around the part (smooth edges when scaled)


def crop_group(imgs: list[Image.Image]) -> tuple[list[float], list[Image.Image]]:
    """Crop full-canvas RGBA layers to the union of their visible pixels.
    Returns (rect as picture fractions, cropped images)."""
    w, h = imgs[0].size
    union = None
    for im in imgs:
        b = im.getchannel('A').getbbox()
        if b is None:
            continue
        union = b if union is None else (min(union[0], b[0]), min(union[1], b[1]),
                                         max(union[2], b[2]), max(union[3], b[3]))
    if union is None:
        union = (0, 0, w, h)
    box = (max(0, union[0] - MARGIN), max(0, union[1] - MARGIN),
           min(w, union[2] + MARGIN), min(h, union[3] + MARGIN))
    return frac(box, (w, h)), [im.crop(box) for im in imgs]


def frac(box: tuple[int, int, int, int], size: tuple[int, int]) -> list[float]:
    w, h = size
    return [round(box[0] / w, 6), round(box[1] / h, 6),
            round((box[2] - box[0]) / w, 6), round((box[3] - box[1]) / h, 6)]


def pixels(rect: list[float], size: tuple[int, int]) -> tuple[int, int, int, int]:
    w, h = size
    x0, y0 = round(rect[0] * w), round(rect[1] * h)
    return x0, y0, x0 + round(rect[2] * w), y0 + round(rect[3] * h)


def expand(img: Image.Image, rect: list[float] | None, size: tuple[int, int]) -> Image.Image:
    """Cropped layer back onto a full transparent canvas of [size]."""
    img = img.convert('RGBA')
    if rect is None:
        return img if img.size == size else img.resize(size)
    full = Image.new('RGBA', size, (0, 0, 0, 0))
    x0, y0, x1, y1 = pixels(rect, size)
    full.paste(img if img.size == (x1 - x0, y1 - y0) else img.resize((x1 - x0, y1 - y0)), (x0, y0))
    return full
