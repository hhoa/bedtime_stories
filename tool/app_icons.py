"""Make every app icon (web, iOS, Android) from one square logo.

Usage: tool/cutout/.venv/bin/python tool/app_icons.py [docs/app_logo.png]

The logo must be square, opaque and full-bleed (background to the edges,
subject inside the middle ~75% so the round/maskable crops keep it).
Favicon, web icons and Android icons come out round (transparent corners);
iOS and web maskable icons stay square and opaque.
Run remove_watermark.py on a Gemini picture first.
"""

import json
import sys
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
IOS_SET = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
ANDROID_RES = ROOT / "android/app/src/main/res"
ANDROID = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
# Web: favicon + normal icons round; maskable stay square (the OS crops them).
WEB = {
    "web/favicon.png": (64, True),
    "web/icons/Icon-192.png": (192, True),
    "web/icons/Icon-512.png": (512, True),
    "web/icons/Icon-maskable-192.png": (192, False),
    "web/icons/Icon-maskable-512.png": (512, False),
}


def circle(img: Image.Image) -> Image.Image:
    """Round icon: transparent outside the circle, smooth edge."""
    big = img.width * 4
    mask = Image.new("L", (big, big), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, big - 1, big - 1), fill=255)
    out = img.convert("RGBA")
    out.putalpha(mask.resize(img.size, Image.LANCZOS))
    return out


def save(logo: Image.Image, size: int, path: Path, round_: bool = False) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    img = logo.resize((size, size), Image.LANCZOS)
    (circle(img) if round_ else img).save(path, optimize=True)
    print(f"{path.relative_to(ROOT)}  {size}px{' round' if round_ else ''}")


def main() -> int:
    src = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "docs/app_logo.png"
    logo = Image.open(src).convert("RGB")  # iOS rejects alpha in app icons
    if logo.width != logo.height:
        print(f"{src}: not square ({logo.width}x{logo.height})")
        return 1

    for rel, (size, round_) in WEB.items():
        save(logo, size, ROOT / rel, round_)
    # Android: legacy icons drawn as-is, so round them.
    for density, size in ANDROID.items():
        save(logo, size, ANDROID_RES / f"mipmap-{density}/ic_launcher.png", True)
    # iOS: square, opaque (iOS rounds the corners itself).
    for image in json.loads((IOS_SET / "Contents.json").read_text())["images"]:
        name = image.get("filename")
        if not name:
            continue
        points = float(image["size"].split("x")[0])
        scale = int(image["scale"].rstrip("x"))
        save(logo, round(points * scale), IOS_SET / name)
    return 0


if __name__ == "__main__":
    sys.exit(main())
