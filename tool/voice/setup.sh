#!/usr/bin/env bash
# One-time setup for the local voice clone: F5-TTS Vietnamese fine-tune
# (CC-BY-NC-SA) and the official English base model (CC-BY-NC).
# Everything lands in tool/voice/ and is never bundled into the app.
set -euo pipefail

cd "$(dirname "$0")"
MODEL_REPO=hynt/F5-TTS-Vietnamese-ViVoice
MODEL_DIR=models/F5-TTS-Vietnamese-ViVoice

command -v uv >/dev/null || { echo "Install uv first: brew install uv"; exit 1; }

if [ ! -d F5-TTS-Vietnamese ]; then
  git clone --depth 1 https://github.com/nguyenthienhy/F5-TTS-Vietnamese
fi

[ -d .venv ] || uv venv --python 3.11 .venv
uv pip install --python .venv/bin/python -e ./F5-TTS-Vietnamese
# The fork pins NumPy 1.x; pyarrow 18+ needs NumPy 2, and datasets 4+ needs
# a newer pyarrow. Keep all three on the NumPy 1 line.
# torchaudio 2.9+ needs torchcodec to read the reference wav; 2.8 does not.
uv pip install --python .venv/bin/python "pyarrow<18" "datasets<4" \
  "torch==2.8.*" "torchaudio==2.8.*"
.venv/bin/python -c "import f5_tts.api" || { echo "f5_tts import failed"; exit 1; }

mkdir -p "$MODEL_DIR"
for f in model_last.pt config.json; do
  if [ ! -s "$MODEL_DIR/$f" ]; then
    echo "Downloading $f ..."
    curl -fL --retry 3 -o "$MODEL_DIR/$f" \
      "https://huggingface.co/$MODEL_REPO/resolve/main/$f"
  fi
done
# The model card ships the vocab under the name config.json.
cp "$MODEL_DIR/config.json" "$MODEL_DIR/vocab.txt"

# English: official F5-TTS v1 base model (~1.3 GB) + its vocab.
EN_DIR=models/F5TTS_v1_Base
mkdir -p "$EN_DIR"
for f in model_1250000.safetensors vocab.txt; do
  if [ ! -s "$EN_DIR/$f" ]; then
    echo "Downloading English $f ..."
    curl -fL --retry 3 -o "$EN_DIR/$f" \
      "https://huggingface.co/SWivid/F5-TTS/resolve/main/F5TTS_v1_Base/$f"
  fi
done

echo "Voice clone ready."
echo "Reference voice: tool/voice/ref/ref.wav + ref.txt (Vietnamese),"
echo "                 tool/voice/ref/en/ref.wav + ref.txt (English, ~8-12 s, 24 kHz mono)."
