#!/usr/bin/env bash
# One-time setup for tool/cutout.py (rembg birefnet-general-lite + OpenCV).
# Models download to ~/.rembg on first use.
set -euo pipefail
cd "$(dirname "$0")"
command -v uv >/dev/null || { echo "Install uv first: brew install uv"; exit 1; }
[ -d .venv ] || uv venv --python 3.11 .venv
uv pip install --python .venv/bin/python rembg onnxruntime opencv-python-headless pillow numpy
.venv/bin/python -c "import rembg, cv2" && echo "Cutout ready."
