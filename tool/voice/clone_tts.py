"""Read lines in the parent's cloned voice (F5-TTS).

Vietnamese uses the ViVoice fine-tune, English the official F5-TTS v1 base
model; both copy the voice of a short reference clip in the same language.
Runs inside tool/voice/.venv (made by setup.sh), called by gen_audio.py.
Reads JSON lines {"text": ..., "out": "/abs/path.wav"} on stdin, loads the
model once and writes one WAV per line. Prints "ok <out>" per clip.

  tool/voice/.venv/bin/python tool/voice/clone_tts.py --lang vi|en [--ref <dir>]
"""

import argparse
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent

# Per language: model config name, checkpoint, vocab, lowercase input.
# Keep paths in sync with CLONE_MODELS in tool/gen_audio.py.
MODELS = {
    'vi': {
        'model': 'F5TTS_Base',
        'ckpt': HERE / 'models' / 'F5-TTS-Vietnamese-ViVoice' / 'model_last.pt',
        'vocab': HERE / 'models' / 'F5-TTS-Vietnamese-ViVoice' / 'vocab.txt',
        'lower': True,  # the fine-tune was trained on lowercase text
    },
    'en': {
        'model': 'F5TTS_v1_Base',
        'ckpt': HERE / 'models' / 'F5TTS_v1_Base' / 'model_1250000.safetensors',
        'vocab': HERE / 'models' / 'F5TTS_v1_Base' / 'vocab.txt',
        'lower': False,
    },
}

SEED = 1234  # same text -> same take, so re-runs are stable

# Voice style per sentence. The model copies the mood of its reference clip,
# so excited sentences (ending in "!") use a lively take of the parent's
# voice, everything else the calm one. Missing ref folder -> calm.
STYLES = {
    'calm': {'ref': '', 'speed': 0.9},  # bedtime pace
    'lively': {'ref': 'lively', 'speed': 1.0},
}
SENTENCE_ENDS = '.!?…'
NFE_STEP = 32

# Each line is read piece by piece, split at punctuation, then joined with a
# pause that fits the mark. The model alone blurs sentences together.
PAUSES = {  # seconds after a piece ending in this mark
    ',': 0.25,
    ';': 0.35,
    ':': 0.35,
    '.': 0.55,
    '!': 0.55,
    '?': 0.6,
    '…': 0.75,
}
END_PAUSE = 0.0  # gen_audio.py trims the ends anyway

# Vietnamese only: said after question pieces, so the model has room to
# finish the last word: without it "nhỉ?" often lost its hỏi tone ("nhi").
# Do not add it to other pieces: on short or lively ones ("Tưng,", "Ối!") the
# model voices the dots as a strange sound, swallows the word or crams the
# line together. English has no tones, so no pad.
TAIL_PAD = ' ...'
PAD_MARKS = '?'
PIECE = re.compile(r'.+?(?:\.\.\.|…|[.!?,;:])+["”»)]*\s*|.+$', re.S)
QUOTES = re.compile(r'["“”«»]')


def split_pieces(text: str) -> list[tuple[str, float, str]]:
    """Splits a line at punctuation into (piece, pause after, style).

    Quotes are dropped (they are not spoken); the mark at the end of each
    piece stays in its text so the model still hears it (rising "?" etc).
    A piece takes the style of the mark ending its sentence, so the "Hoan hô,"
    in "Hoan hô, tối nay mình được ở lại rồi!" is lively too.
    """
    pieces = []
    for m in PIECE.finditer(text):
        raw = m.group(0).strip()
        spoken = QUOTES.sub('', raw).strip()
        if not any(c.isalnum() for c in spoken):
            continue
        tail = QUOTES.sub('', raw).rstrip()
        mark = '…' if tail.endswith(('...', '…')) else tail[-1]
        pieces.append([spoken, PAUSES.get(mark, 0.0), mark])
    if not pieces:
        return []
    pieces[-1][1] = END_PAUSE
    style = 'calm'
    for piece in reversed(pieces):
        if piece[2] in SENTENCE_ENDS:
            style = 'lively' if piece[2] == '!' else 'calm'
        piece[2] = style
    return [tuple(p) for p in pieces]


def trim(wav, sr: int, margin: float = 0.04):
    """Cuts quiet edges off one piece so the set pause is the only gap."""
    import numpy as np

    frame = int(sr * 0.01)
    if len(wav) < frame * 3:
        return wav
    n = len(wav) // frame
    rms = np.sqrt((wav[: n * frame].reshape(n, frame) ** 2).mean(axis=1))
    loud = np.nonzero(rms > rms.max() * 0.05)[0]
    if len(loud) == 0:
        return wav
    pad = int(sr * margin)
    start = max(loud[0] * frame - pad, 0)
    end = min((loud[-1] + 1) * frame + pad, len(wav))
    return wav[start:end]


def load_newer_model(f5tts_cls, spec: dict, device: str):
    """F5TTS for a model the Vietnamese fork's api.py doesn't name (F5TTS_v1_Base).

    The fork ships the v1 config and its DiT supports it; only F5TTS.__init__
    refuses names it has no default checkpoint for. We pass our own
    checkpoint, so build the same object without that check.
    """
    from importlib.resources import files

    from f5_tts.infer.utils_infer import load_model, load_vocoder
    from f5_tts.model import DiT
    from omegaconf import OmegaConf

    cfg = OmegaConf.load(str(files('f5_tts').joinpath(f'configs/{spec["model"]}.yaml')))
    tts = f5tts_cls.__new__(f5tts_cls)
    tts.mel_spec_type = cfg.model.mel_spec.mel_spec_type
    tts.target_sample_rate = cfg.model.mel_spec.target_sample_rate
    tts.ode_method = 'euler'
    tts.use_ema = True
    tts.device = device
    tts.vocoder = load_vocoder(tts.mel_spec_type, False, None, device, None)
    tts.ema_model = load_model(DiT, cfg.model.arch, str(spec['ckpt']), tts.mel_spec_type,
                               str(spec['vocab']), tts.ode_method, tts.use_ema, device)
    return tts


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--lang', choices=sorted(MODELS), default='vi')
    parser.add_argument('--ref', help='folder with ref.wav + ref.txt (calm); lively/ inside it '
                        'for "!". Default ref/ (vi) or ref/en/ (en)')
    parser.add_argument('--seed', type=int, default=SEED,
                        help='another number = another take of the same text')
    args = parser.parse_args()
    spec = MODELS[args.lang]
    ref = Path(args.ref) if args.ref else HERE / ('ref' if args.lang == 'vi' else 'ref/en')
    for f in (ref / 'ref.wav', ref / 'ref.txt', spec['ckpt'], spec['vocab']):
        if not f.exists():
            print(f'missing {f} (run tool/voice/setup.sh)', file=sys.stderr)
            return 1
    refs = {}  # style -> (wav path, transcript)
    for name, style in STYLES.items():
        folder = ref / style['ref']
        if (folder / 'ref.wav').exists() and (folder / 'ref.txt').exists():
            refs[name] = (str(folder / 'ref.wav'),
                          (folder / 'ref.txt').read_text(encoding='utf-8').strip())

    import numpy as np
    import soundfile as sf
    import torch
    from f5_tts.api import F5TTS

    device = 'mps' if torch.backends.mps.is_available() else 'cpu'
    if spec['model'] in ('F5TTS_Base', 'E2TTS_Base'):
        tts = F5TTS(
            model=spec['model'],
            ckpt_file=str(spec['ckpt']),
            vocab_file=str(spec['vocab']),
            device=device,
        )
    else:
        tts = load_newer_model(F5TTS, spec, device)
    # The fork only stores a seed it picks itself; set ours so infer(seed=...) uses it.
    tts.seed = args.seed

    for raw in sys.stdin:
        if not raw.strip():
            continue
        job = json.loads(raw)
        out = Path(job['out'])
        out.parent.mkdir(parents=True, exist_ok=True)
        parts = []
        sr = 24000
        for piece, pause, style in split_pieces(job['text']):
            vi = args.lang == 'vi'
            pad = TAIL_PAD if vi and piece.rstrip()[-1:] in PAD_MARKS else ''
            if style not in refs:
                style = 'calm'
            ref_wav, ref_text = refs[style]
            text = piece.lower() if spec['lower'] else piece
            wav, sr, _ = tts.infer(
                ref_file=ref_wav,
                ref_text=ref_text,
                gen_text=text + pad,
                seed=args.seed,
                speed=STYLES[style]['speed'],
                nfe_step=NFE_STEP,
                show_info=lambda *_: None,
            )
            parts.append(trim(np.asarray(wav, dtype=np.float32), sr))
            if pause:
                parts.append(np.zeros(int(sr * pause), dtype=np.float32))
        if not parts:
            continue
        sf.write(str(out), np.concatenate(parts), sr)
        print(f'ok {out}', flush=True)
    return 0


if __name__ == '__main__':
    sys.exit(main())
