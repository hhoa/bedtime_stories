---
name: story-audio
description: Narration audio for a bundled story, Vietnamese and English. The parent records most clips by hand; this lists what's missing, fills gaps with the parent's cloned voice (F5-TTS, local), lets the parent listen, redoes bad clips, checks loudness. Use for "/story-audio", "make audio for <story>", "what audio is missing", "redo clip X", or the audio step of /new-story.
argument-hint: <story_id> [vi|en] [clip names to redo]
---

# /story-audio

The parent records most lines by hand. Your job: give the script, find what's still missing, offer the cloned voice for gaps, check quality. Read CLAUDE.md "Audio" first. Never `--force` without `--only` or `--out` unless the user asked: it overwrites hand recordings.

## 1. Recording script
```bash
python3 tool/gen_audio.py --story <id> --list            # both languages
python3 tool/gen_audio.py --story <id> --list --lang en
```
Give the parent the folders (`assets/stories/<id>/audio/vi/`, `.../en/`) and the list (filename → line). `[tên bé]` / `[child name]` = don't record, the app inserts the name. Recordings: m4a, same filename, trim silence at both ends.

## 2. What's missing (after the parent records)
```bash
python3 tool/gen_audio.py --story <id> --missing
python3 tool/gen_audio.py --missing                       # also shared UI lines
```
If anything is listed, **tell the user which clips are missing** (filename + line) and suggest the cloned voice. Only generate after they agree:
```bash
python3 tool/gen_audio.py --story <id> --lang vi          # only missing clips
python3 tool/gen_audio.py --story <id> --lang en
```
- Output must say `[vi] engine: clone` / `[en] engine: clone`. `say` = setup incomplete (fine only as a labelled placeholder).
- English needs `tool/voice/models/F5TTS_v1_Base/` (from `tool/voice/setup.sh`) and the parent's English reference `tool/voice/ref/en/ref.wav` + `ref.txt` (8–12 s clean speech, 24 kHz mono, exact transcript). If missing, ask the parent to record one: `ffmpeg -i in.m4a -ac 1 -ar 24000 tool/voice/ref/en/ref.wav`.
- Never run setup with sudo. Past setup fixes are pinned in setup.sh.
- ~15 s a sentence; run a whole story in the background.

## 3. Loudness
`python3 tool/boost_audio.py --check --story <id>`. Hand recordings usually come in soft (~-41 LUFS). If soft clips are listed, tell the user and offer `python3 tool/boost_audio.py --story <id>` (backs up originals in `audio_backup/`, `--restore` undoes).

## 4. Parent listens to cloned clips (required)
Never call cloned audio done before the parent listened. Point at the risky ones: short lines, exclamations, questions, quotes, words ending in hỏi/ngã tone (nhỉ, nhé, rồi, ngủ).

Known clone behaviour (Vietnamese, learned in v1):
- Pauses follow punctuation (`PAUSES` in clone_tts.py); never enable the model's `remove_silence`.
- `!` sentences use `ref/lively/` at speed 1.0; others calm at 0.9.
- Lost tone / mumbled word: make 4 takes, seeds 4–7: `--story <id> --lang vi --force --only <clip> --seed N --out <scratch>/seedN`; join into one file with 1 s gaps; the parent picks; redo that seed for real. Still bad → the parent records it by hand.
- Test any global change (PAUSES, STYLES, padding) on a mixed set with `--out` first.
- English: no tone padding; if a line sounds rushed, lower `speed` for `en` only.

## 5. Finish
- `fvm flutter test` (asset test checks every clip in both languages).
- Report per language: recorded by hand / made by clone (seed) / still missing, loudness result.
- Remind once: cloned clips are non-commercial (CC-BY-NC / CC-BY-NC-SA). Before selling, replace them.
