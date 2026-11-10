"""Save a picture as WebP at the highest quality that fits a size budget.

A fixed quality wastes sharpness on simple pictures and still goes over
budget on busy ones. save_webp() tries qualities from q_hi down to q_lo
(binary search, encoded in memory) and writes the best one that fits once.
Pixel size never changes: the caller sizes the picture (see CLAUDE.md).

    from webp_save import save_webp
    path, quality, size, over = save_webp(img, dest, 150 * 1024)
"""
from __future__ import annotations

import io
from pathlib import Path

from PIL import Image


def _encode(img: Image.Image, quality: int) -> bytes:
    b = io.BytesIO()
    img.save(b, 'WEBP', quality=quality, method=6)
    return b.getvalue()


def save_webp(img: Image.Image, dest: Path, max_bytes: int, q_hi: int = 92,
              q_lo: int = 72) -> tuple[Path, int, int, bool]:
    """Write [img] to [dest] (.webp). Returns (path, quality, bytes, over),
    over = True when even q_lo is bigger than max_bytes (written at q_lo)."""
    dest = Path(dest).with_suffix('.webp')
    best = _encode(img, q_hi)
    quality = q_hi
    if len(best) > max_bytes:
        lo, hi, best, quality = q_lo, q_hi - 1, None, None
        while lo <= hi:
            mid = (lo + hi) // 2
            data = _encode(img, mid)
            if len(data) <= max_bytes:
                best, quality, lo = data, mid, mid + 1
            else:
                hi = mid - 1
        if best is None:
            best, quality = _encode(img, q_lo), q_lo
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_bytes(best)
    return dest, quality, len(best), len(best) > max_bytes
