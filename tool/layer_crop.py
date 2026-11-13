"""Helpers for cropped part layers (shared by stage.py and clock_layer.py).

A part layer keeps only the rectangle its pixels cover, and images/layers.json
gives "rect": [x, y, w, h] as fractions of the picture, where SceneLayers
draws it (a full 1600x1200 layer would decode like a whole scene). All poses
of one part share one rect. A layer without "rect" is full-canvas (SVG art).
"""
from __future__ import annotations

from PIL import Image

MOTION = {   # part kind -> (idle, tap) for layers.json (stage.py)
    'lulu': ('float', 'hop'),
    'hero': ('breathe', 'hop'),
}


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
