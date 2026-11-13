---
name: story-audio
description: Narration audio for a bundled story, Vietnamese and English. The parent records most clips by hand; this cleans every new recording (trim, denoise, even loudness), lists what's missing, fills gaps with the parent's cloned voice (F5-TTS, local), lets the parent listen, redoes bad clips. Use for "/story-audio", "I recorded / added / saved my recordings", "make audio for <story>", "what audio is missing", "redo clip X", or the audio step of /new-story.
argument-hint: <story_id> [vi|en] [clip names to redo]
---

# /story-audio

The parent records most lines by hand. Your job: give the script, **clean every new recording**, find what's still missing, offer the cloned voice for gaps, check quality.

**Every run starts with step 2** (clean new recordings): it's a no-op when nothing is new, and the parent may have dropped files in since last time. `python3 tool/story_status.py <id>` shows per language: done, not cleaned yet, cloned but not listened to, missing. Read CLAUDE.md "Audio" first. Never `--force` without `--only` or `--out` unless the user asked: it overwrites hand recordings.

## 1. Recording script
```bash
python3 tool/gen_audio.py --story <id> --list            # both languages
python3 tool/gen_audio.py --story <id> --list --lang en
```
Give the parent the folders (`assets/stories/<id>/audio/vi/`, `.../en/`) and the list (filename → line). `[tên bé]` / `[child name]` = don't record, the app inserts the name (`_p1` clips start right after it). Recordings: same filename, `.m4a` (or `.wav/.mp3/.aiff/.caf`); no trimming needed. **Math stories** (`"math"` block): each line with numbers shows once as `<key>_full.m4a` with example numbers; the parent reads the whole line in one go (no name, as printed). The UI part lists `num_1` … `num_10` (record once, shared by every math story). Tips: quiet room (fan / air con off if possible), phone ~20 cm from the mouth (past recordings came in very soft, ~-40 LUFS, so room noise showed after the boost), calm bedtime voice, a second of quiet before and after is fine (the pauses teach the denoiser what the room sounds like).

## 2. Clean new recordings (mandatory, no asking)
Whenever the parent says they recorded / added / saved clips, or new files are in `audio/<lang>/`, before anything else:
```bash
tool/voice/.venv/bin/python tool/split_numbers.py <id>   # math stories, first: cut every *_full into its _p pieces (full take -> audio_backup/)
python3 tool/clean_audio.py --story <id>           # only clips not cleaned yet
python3 tool/clean_audio.py --check --story <id>
```
What it does per clip (60 Hz high-pass, `tool/denoise.py`, trim, toward -16 LUFS, mono AAC 64k via Apple `aac_at`; numbers in CLAUDE.md "Audio" and the tool's docstring). Other formats become `.m4a`.

**Approved sound (parent, 2026-11-10): keep the recording's own quality, remove only the background noise.** Every clip, every story, both languages, no asking:
- Denoise = `tool/denoise.py` (needs `tool/cutout/.venv`): learns the steady noise (fan, air con, hum, hiss) from the clip's own pauses and subtracts it per frequency (Wiener-style, `OVER = 3`, at most `--denoise 24` dB). Voice stays within ~0.5 dB; pauses drop ~15–20 dB. Don't swap in ffmpeg `afftdn` / `anlmdn` / `agate`: on these recordings they either changed nothing or ate the words.
- Noise is measured in float, skipping digital silence (< -100 dB). Phones start a recording with exact zeros; the old cleaner read those as "no noise, 85 dB SNR" and skipped the denoise, then boosted the hum +25 dB with the voice. If a report says "clean already" or SNR > 50 for a phone recording, suspect this again.
- Limiter shaves the loudest word by at most 6 dB (`MAX_SQUASH`); a peaky clip stays a little soft (down to -20 LUFS) instead of sounding flattened. Don't raise it to hit -16 exactly.
- Bitrate 64k is not the problem (the phone records at 64k); don't raise it to "fix" noise.
- Any change to the cleaner: run it on scratch copies first (`clean_audio.clean(orig, scratch_dst, 24)` from the originals in `audio_backup/`), measure voice change (must stay ≤ ~0.5 dB) and pause level, and make an old-vs-new file for the parent (pairs with 1 s gaps in the scratchpad) before `--redo` on the story. Keep the old clips in the scratchpad until the parent approves.
- If the parent says a clip sounds noisy: compare original vs cleaned (pause level, voice level) before touching settings; a clip with noise < ~15 dB under the voice needs a re-take, not stronger denoise. Originals → `audio_backup/` (only copy of real recordings; `--restore` puts them back, `--redo` re-cleans from them). Each finished clip carries a `bedtime_stories_cleaned` tag inside the file, so a fresh clone (no `audio_backup/`) doesn't clean it twice. A clip whose file changed after cleaning without the tag counts as a new take and is cleaned again.

Report to the parent, per language: how many cleaned, typical change (e.g. "-38 → -16 LUFS, 1 s silence cut, noise 28 → 37 dB under voice"), and every `!!` / `--check` line with the line's text:
- `noisy`: background still close to the voice (fan, TV, street) → suggest re-recording in a quieter spot.
- `peak` / `loud`: original was clipped (too close / shouting) → re-record a bit further away.
- No `noisy` flag possible for clips with no silence ("no silence: not denoised"): fine for cloned clips; for a hand recording it means the background is almost as loud as the voice → listen.
- `soft` / silence at start or end: odd file (very short, mostly silence) → listen, re-record.
- Very soft originals (≈ -35 to -42 LUFS in the report): the boost makes room noise easier to hear → tip for next time: phone ~20 cm from the mouth, or a little louder.
Never push the denoise past the default 24 dB to save a bad take: voice goes underwater; a re-take is better.

## 3. What's missing (after cleaning)
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
- Cloned clips are trimmed and boosted by `gen_audio.py` and registered in `audio_backup/cleaned.json`, so `clean_audio.py` leaves them alone.

## 4. Parent listens to cloned clips (required)
Never call cloned audio done before the parent listened. When the parent approves clips, add their names to `docs/stories/<id>/progress.json` `listened.<lang>` (so a later session knows; `story_status.py` shows the rest as "cloned, not heard"). A redone clip leaves the list until heard again. Point at the risky ones: short lines, exclamations, questions, quotes, words ending in hỏi/ngã tone (nhỉ, nhé, rồi, ngủ).

Known clone behaviour (Vietnamese, learned in v1):
- Pauses follow punctuation (`PAUSES` in clone_tts.py); never enable the model's `remove_silence`.
- `!` sentences use `ref/lively/` at speed 1.0; others calm at 0.9.
- Lost tone / mumbled word: make 4 takes, seeds 4–7: `--story <id> --lang vi --force --only <clip> --seed N --out <scratch>/seedN`; join into one file with 1 s gaps; the parent picks; redo that seed for real. Still bad → the parent records it by hand.
- Test any global change (PAUSES, STYLES, padding) on a mixed set with `--out` first.
- English: no tone padding; if a line sounds rushed, lower `speed` for `en` only.

## 5. Finish
- `tool/cutout/.venv/bin/python tool/cue_times.py <id>` whenever any clip was added, re-recorded or re-cloned: times each cue to its real clip (`"at"` in story.json) so parts move on the word, not early.
- `fvm flutter test` (asset test checks every clip in both languages).
- `python3 tool/clean_audio.py --check --story <id>` passes (exit 0).
- Report per language: recorded by hand (cleaned, anything flagged) / made by clone (seed) / still missing.
- Remind once: cloned clips are non-commercial (CC-BY-NC / CC-BY-NC-SA). Before selling, replace them.
