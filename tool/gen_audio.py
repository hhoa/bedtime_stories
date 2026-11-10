#!/usr/bin/env python3
"""Generate narration audio (m4a) for bundled stories, Vietnamese and English.

The parent records most clips by hand (`--list` = recording script). What is
still missing (`--missing`) is filled with the cloned voice.

Two engines:
  clone  the parent's own voice, cloned locally with F5-TTS: the Vietnamese
         fork for `vi`, the official English base model for `en`
         (tool/voice/, set up once with tool/voice/setup.sh). Default when set up.
  say    macOS `say` (Linh / Samantha). Fallback placeholder.
New clone clips get silence trimmed and a loudness boost, and are
registered in audio_backup/cleaned.json so tool/clean_audio.py (which cleans
hand recordings) leaves them alone. Listen to each one: the model can get a
tone wrong; re-record a bad line by hand under the same filename.

Files follow the naming the app expects
(`Story.nodeNarration` in story.dart):

  assets/stories/<id>/audio/<lang>/<nodeId>[_p<i>].m4a              node text / prompt
  assets/stories/<id>/audio/<lang>/<nodeId>_<optionId>[_p<i>].m4a   choice option label
  assets/audio/ui/<lang>/<key>.m4a                                  shared UI lines

The child's name is never baked in. `{name}` appears at most once
per line, as its first or last word (check_story.py), so a line is the name
plus one clip (`_p1` after a leading name, `_p0` before a trailing one). Parts with no letters (e.g.
"?") are skipped. The app plays the parent's recording, or "bé" / "sweetie".

Own voice: run with `--list` to get the recording script, record each line,
save it under the listed filename, then run tool/clean_audio.py (trim,
denoise, loudness). Without `--force` this tool only fills in
missing clips, so recordings are never overwritten.

Usage:
  python3 tool/gen_audio.py                 # generate missing clips only (both languages)
  python3 tool/gen_audio.py --missing       # list clips not recorded yet, make nothing
  python3 tool/gen_audio.py --force         # regenerate every clip with TTS
  python3 tool/gen_audio.py --list          # print the recording script
  python3 tool/gen_audio.py --lang en       # one language only
  python3 tool/gen_audio.py --story <id>
  python3 tool/gen_audio.py --engine say    # force the macOS voice
  python3 tool/gen_audio.py --story <id> --force --out <dir>
                                            # trial: write elsewhere, assets untouched
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from clean_audio import CLEAN_TAG, boost, mark_cleaned  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
LANGS = ('vi', 'en')  # keep in sync with AppLanguage
SAY_VOICES = {'vi': 'Linh', 'en': 'Samantha'}
RATE = 150

VOICE_DIR = ROOT / 'tool' / 'voice'
CLONE_PY = VOICE_DIR / '.venv' / 'bin' / 'python'
# Keep in sync with MODELS in tool/voice/clone_tts.py.
CLONE_MODELS = {
    'vi': VOICE_DIR / 'models' / 'F5-TTS-Vietnamese-ViVoice' / 'model_last.pt',
    'en': VOICE_DIR / 'models' / 'F5TTS_v1_Base' / 'model_1250000.safetensors',
}
# Reference voice per language: Vietnamese in ref/, English in ref/en/.
REF_SUB = {'vi': '', 'en': 'en'}
NAME_SLOT = {'vi': '[tên bé]', 'en': '[child name]'}
# Trim quiet edges (the model can leave a breath or a gap at either end).
TRIM = ('silenceremove=start_periods=1:start_threshold=-45dB:start_silence=0.05,'
        'areverse,silenceremove=start_periods=1:start_threshold=-45dB:start_silence=0.15,'
        'areverse')
NAME = '{name}'
EXT = 'm4a'  # keep in sync with AppConstants.audioExt

# Shared lines per language. Keep `rewind` in sync with
# AppStrings.rewindQuestion; `sticker_<n>` is read on the ending page
# (AppConstants.stickerAudio); `be` replaces the name when the parent hasn't
# recorded it (AppConstants.nameFallbackAudio). The v1 Vietnamese `be` clip
# was pitched ~3 semitones down by hand (ffmpeg asetrate 0.917 + atempo,
# applied twice); redo that after --force.
UI_LINES = {
    'vi': {
        'rewind': 'Mình thử chọn cách khác xem sao nhé?',
        'be': 'bé',
        'sticker_0': 'Lần sau mình thử chọn cách khác để nhận sticker nhé!',
        'sticker_1': 'Bé nhận được một sticker!',
        'sticker_2': 'Bé nhận được hai sticker! Giỏi quá!',
    },
    'en': {
        'rewind': 'Shall we try the other choice?',
        'be': 'sweetie',
        'sticker_0': 'Next time, try another choice to get a sticker!',
        'sticker_1': 'You got a sticker!',
        'sticker_2': 'You got two stickers! Great job!',
    },
}


def speak(text: str, out: Path, lang: str) -> None:
    out.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        aiff = Path(tmp) / 'line.aiff'
        subprocess.run(['say', '-v', SAY_VOICES[lang], '-r', str(RATE), '-o', str(aiff), text],
                       check=True)
        subprocess.run(
            ['ffmpeg', '-y', '-loglevel', 'error', '-i', str(aiff),
             '-ac', '1', '-codec:a', 'aac', '-b:a', '64k',
             '-metadata', f'comment={CLEAN_TAG}', str(out)],
            check=True,
        )
    mark_cleaned(out)
    print(f'  {shown(out)}')


def speakable(text: str) -> bool:
    return any(c.isalnum() for c in text)


def line_clips(text: str, key: str, lang: str):
    """Yields (filename or None for the name slot, text to read)."""
    pieces = text.split(NAME)
    if len(pieces) == 1:
        yield f'{key}.{EXT}', text
        return
    for i, piece in enumerate(pieces):
        if i > 0:
            yield None, NAME_SLOT[lang]
        if speakable(piece):
            yield f'{key}_p{i}.{EXT}', piece.strip()


def story_lines(story: dict, lang: str):
    """(text, clip key) for every narrated line in [lang]."""
    for node in story['nodes']:
        yield node['text'][lang], node['id']
        for opt in node.get('options', []):
            yield opt['label'][lang], f'{node["id"]}_{opt["id"]}'


def shown(path: Path) -> Path:
    return path.relative_to(ROOT) if path.is_relative_to(ROOT) else path


def lang_ref(ref: Path, lang: str) -> Path:
    return ref / REF_SUB[lang] if REF_SUB[lang] else ref


def clone_ready(ref: Path, lang: str) -> bool:
    return (CLONE_PY.exists() and CLONE_MODELS[lang].exists()
            and (lang_ref(ref, lang) / 'ref.wav').exists())


def clone_speak(jobs: list[tuple[str, Path]], ref: Path, lang: str,
                seed: int | None = None) -> None:
    """Reads every (text, out) line in the cloned voice, loading the model once."""
    with tempfile.TemporaryDirectory() as tmp:
        wavs = {out: Path(tmp) / f'{i}.wav' for i, (_, out) in enumerate(jobs)}
        stdin = ''.join(json.dumps({'text': text, 'out': str(wavs[out])}, ensure_ascii=False) + '\n'
                        for text, out in jobs)
        cmd = [str(CLONE_PY), str(VOICE_DIR / 'clone_tts.py'), '--lang', lang,
               '--ref', str(lang_ref(ref, lang))]
        if seed is not None:
            cmd += ['--seed', str(seed)]
        subprocess.run(cmd, input=stdin, text=True, check=True, stdout=subprocess.DEVNULL)
        for _, out in jobs:
            out.parent.mkdir(parents=True, exist_ok=True)
            subprocess.run(
                ['ffmpeg', '-y', '-loglevel', 'error', '-i', str(wavs[out]), '-af', TRIM,
                 '-ac', '1', '-codec:a', 'aac', '-b:a', '64k', str(out)],
                check=True,
            )
            boost(out, out)
            mark_cleaned(out)
            print(f'  {shown(out)}')


def produce(clips, folder: Path, force: bool, listing: bool, jobs: list, only=None,
            missing: list | None = None) -> None:
    """Prints the script, collects missing clips, or queues (text, out) to make."""
    for name, text in clips:
        if only and (name is None or Path(name).stem not in only):
            continue
        if listing:
            print(f'  {name or "":<16} {text}')
            continue
        if name is None:
            continue
        out = folder / name
        if out.exists() and not force:
            continue
        if missing is not None:
            missing.append((text, out))
            continue
        jobs.append((text, out))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--story', help='only this story id')
    parser.add_argument('--lang', choices=LANGS, help='only this language (default both)')
    parser.add_argument('--force', action='store_true', help='overwrite existing clips (incl. recordings)')
    parser.add_argument('--list', action='store_true', help='print the recording script, generate nothing')
    parser.add_argument('--missing', action='store_true',
                        help='list clips not recorded/generated yet, generate nothing')
    parser.add_argument('--engine', choices=['clone', 'say'],
                        help='clone = parent voice (default when tool/voice is set up), say = macOS voice')
    parser.add_argument('--ref', default=str(VOICE_DIR / 'ref'),
                        help='clone reference folder (ref.wav + ref.txt; English in its en/)')
    parser.add_argument('--out', help='write clips under this folder instead of assets (for trials)')
    parser.add_argument('--only', help='comma-separated clip names (e.g. s2,e1_p1) to make; use with --force to redo')
    parser.add_argument('--seed', type=int, help='clone: another number = another take (default fixed)')
    args = parser.parse_args()

    ref = Path(args.ref).resolve()
    out_root = Path(args.out).resolve() if args.out else None

    def target(folder: Path) -> Path:
        return out_root / folder.relative_to(ROOT) if out_root else folder

    only = {n.strip().removesuffix(f'.{EXT}') for n in args.only.split(',')} if args.only else None
    quiet = args.list or args.missing
    stories = sorted(p for p in (ROOT / 'assets/stories').iterdir()
                     if (p / 'story.json').exists() and (not args.story or p.name == args.story))
    if args.story and not stories:
        sys.exit(f'No story {args.story}')
    missing: list[tuple[str, Path]] = []

    for lang in ([args.lang] if args.lang else LANGS):
        jobs: list[tuple[str, Path]] = []
        engine = args.engine or ('clone' if clone_ready(ref, lang) else 'say')
        if engine == 'clone' and not clone_ready(ref, lang) and not quiet:
            sys.exit(f'Voice clone ({lang}) not set up: run tool/voice/setup.sh and add '
                     f'{shown(lang_ref(ref, lang))}/ref.wav + ref.txt')
        if not quiet:
            print(f'[{lang}] engine: {engine}')
        ui = ROOT / 'assets/audio/ui' / lang
        if args.list:
            print(f'[{lang}] UI lines -> {shown(target(ui))}')
        produce(((f'{k}.{EXT}', t) for k, t in UI_LINES[lang].items()), target(ui),
                args.force, args.list, jobs, only, missing if args.missing else None)

        for story_dir in stories:
            story = json.loads((story_dir / 'story.json').read_text(encoding='utf-8'))
            audio = story_dir / 'audio' / lang
            if args.list:
                print(f'[{lang}] Story {story["id"]} -> {shown(target(audio))}')
            for text, key in story_lines(story, lang):
                produce(line_clips(text, key, lang), target(audio), args.force, args.list, jobs,
                        only, missing if args.missing else None)

        if quiet or not jobs:
            continue
        if engine == 'clone':
            clone_speak(jobs, ref, lang, args.seed)
        else:
            for text, out in jobs:
                speak(text, out, lang)

    if args.missing:
        if not missing:
            print('Every clip exists.')
            return
        print(f'{len(missing)} clip(s) missing:')
        for text, out in missing:
            print(f'  {shown(out)}\n      {text}')
        print('\nRecord them (same filename), or fill them with the cloned voice:')
        langs = sorted({out.parent.name for _, out in missing})
        story = f' --story {args.story}' if args.story else ''
        for lang in langs:
            print(f'  python3 tool/gen_audio.py --lang {lang}{story}')


if __name__ == '__main__':
    main()
