---
name: new-story
description: Create a new bundled bedtime story end to end — idea, outline, bilingual script (Vietnamese + English), review, AI art with moving cut-out parts, wiring, tests, audio — with parent approval after the outline and after the script. Use when the user says "/new-story", "new story", "make a story about X".
argument-hint: <idea or theme> [story_id] [hero girl|boy|kid]
---

# /new-story

Pipeline: plan → ⏸ approve → script → review → ⏸ approve → art (with the parent) → wire + test → audio (parent records, clone fills gaps).

You (main session) orchestrate. Subagents hand work over through files:

| File | Owner |
|---|---|
| `docs/stories/<id>/outline.md` | story-planner |
| `assets/stories/<id>/story.json` | story-writer (you may set `ambient_origin`, `cues`, `poses` after art) |
| `docs/stories/<id>/review.md` | story-reviewer |
| `docs/stories/<id>/art_prompts.json`, `images/` | you, with the parent |

## 0. Setup
- Parse idea, optional id and hero from `$ARGUMENTS`. No idea → ask.
- Pick a snake_case id if none. If `assets/stories/<id>/` exists, stop and ask: never overwrite a story.

## 1. Outline
Run `story-planner` with idea, id, hero. Show the user the outline (title vi/en, hero, moral, both paths per choice, scene list) short, with the file link.

**⏸ Gate 1.** Approve or change. Changes go back to `story-planner`. Do not continue without approval.

## 2. Script
1. Run `story-writer` with the id.
2. Run `story-reviewer` with the id.
3. FIX → `story-writer` again ("revise from docs/stories/<id>/review.md"), then `story-reviewer` once more. Max 2 rounds, then show remaining FIX items to the user.

Show the full narration (node by node, vi then en, options indented) plus NOTES.

**⏸ Gate 2.** Approve or edit lines. Small wording edits: do them in story.json yourself, rerun `python3 tool/check_story.py <id>`. Bigger changes → `story-writer`.

## 3. Art (clock_time workflow, with the parent)
Read CLAUDE.md "Art" first. Steps:
1. Write `docs/stories/<id>/art_prompts.json` from the outline: `setting`, `pictures` (cover, every scene, icons, sticker), `outfits` if any, `plates` (scenes with parts to cut) and `poses` (one per action word in the script). Copy the style of `docs/examples/clock_time_art_prompts.json`. Character sheet for the hero must exist in `tool/image_refs/<hero>.png` (`kid.png` for unisex): if missing, `python3 tool/gen_image.py --refs --only <hero> --prompts-out <dir>` first.
2. Prompts for the parent (no API cost): `python3 tool/gen_image.py --story <id> --prompts-out ~/Downloads/art_prompts/<id>`. Or with a key: `--dry` first, then without. The parent makes pictures in the Gemini app and saves them to `~/Downloads/story_art/<id>/`.
3. `python3 tool/import_art.py <id> ~/Downloads/story_art/<id>` (scenes 1600×1200, cover 800×600, icons 400², sticker 600²).
4. Hotspots: `python3 tool/preview_hotspots.py <id> <scratch>` (10% grid), look, write `images/hotspots.json`.
5. Plates + poses: `python3 tool/gen_image.py --story <id> --plates --prompts-out <dir>` and `--poses --prompts-out <dir>`; parent makes them; then `tool/cutout/.venv/bin/python tool/cutout.py <id> <scene> --parts lulu[,hero] --plate <png> --pose hero=yawn:<png> --preview <scratch>` per scene. Look at every `_poses.jpg`; redo drifting edits.
6. SVG overlays for what AI draws badly (clocks, numbers): like `tool/clock_layer.py` (`docs/examples/clock_time_clock.json`).
7. Set `ambient_origin` on the ending from the real picture; add `cues` (`pose` on action words) and node `poses`.
8. `python3 tool/check_story.py <id> --art` and `python3 tool/check_assets.py <id>`. **Report every OVER line to the user** and offer to downsize (re-import, `crop_layers.py`, lower WebP quality). Busiest scene under ~15 MB decoded.

## 4. Wire + test (yourself)
1. Add the id to `assets/stories/index.json`.
2. Add to `pubspec.yaml` assets:
   ```
   - assets/stories/<id>/
   - assets/stories/<id>/images/
   - assets/stories/<id>/images/layers/      # only if it has cut/SVG layers
   - assets/stories/<id>/audio/vi/
   - assets/stories/<id>/audio/en/
   ```
3. Audio before tests (the asset test checks every clip, both languages): run `/story-audio <id>` steps 1–3.
4. `fvm flutter analyze` and `fvm flutter test`. On failure route the exact error to the file's owner. Max 2 rounds, then report.

## 5. Report
- Title (vi/en), id, hero, scenes, choices (= max stickers).
- Files created (links), test result, `check_assets.py` summary.
- Audio: which clips the parent recorded, which the clone made (per language), loudness check.
- Manual step left: play it in both languages (`fvm flutter run -d chrome`): ambient calm, z's at the head, cues move the right part on the right word, taps react, ending gives the right number of stickers, profile shows them.

Do not commit unless the user asks.
