---
name: new-story
description: Create a new bundled bedtime story end to end — idea, outline, bilingual script (Vietnamese + English), review, AI art with moving cut-out parts, wiring, tests, audio — with parent approval after the outline and after the script. Use when the user says "/new-story", "new story", "make a story about X".
argument-hint: <idea or theme> [story_id] [hero girl|boy|kid]
---

# /new-story

Pipeline: duplicate check (stop + warn if the idea exists) → plan → ⏸ approve → script → review → ⏸ approve → art-director ↔ art-reviewer → tracking page → parent makes pictures, `/story-art <id>` after each batch (watermark off, best quality under budget, consistency look, cut-outs) → wire + test → audio (parent records → clean (trim, denoise, loudness) → missing? clone fills gaps → parent listens → test).

You (main session) orchestrate. Subagents hand work over through files:

| File | Owner |
|---|---|
| `docs/stories/<id>/outline.md` | story-planner |
| `assets/stories/<id>/story.json` | story-writer (you may set `ambient_origin`, `cues`, `poses` after art) |
| `docs/stories/<id>/review.md` | story-reviewer |
| `docs/stories/<id>/art_prompts.json` (incl. `reference`) | art-director |
| `docs/stories/<id>/art_review.md` | art-reviewer |
| `docs/stories/<id>/progress.json` | you (gates, prompts page link) and /story-art, /story-audio |
| `images/` | /story-art, with the parent |

The story is made over days (pictures and recordings come in batches). Any later session resumes with `/story-continue <id>`; `python3 tool/story_status.py <id>` shows where it is. Use only this project's agents and skills, never v1's (`art-coder`, `bedtime_story:*`).

## 0. Setup
- Parse idea, optional id and hero from `$ARGUMENTS`. No idea → ask.
- Pick a snake_case id if none. If `assets/stories/<id>/` or `docs/stories/<id>/` exists, stop: never overwrite a story. Show `python3 tool/story_status.py <id>` and offer `/story-continue <id>`.
- **Duplicate check, before anything is written:** run `story-idea-checker` with the idea (and id, hero if given).
  - `DUPLICATE` → **stop.** Warn the parent: the matching story (id, title, moral, its choices), what is the same, and the options it gave (`/story-continue <id>`, port the v1 story, or a twist that makes it new). Do not run the planner and create no files. Continue only if the parent picks a new idea (check it again) or says to go ahead anyway.
  - `SIMILAR` → go on, but show the parent the match in one line and pass the `AVOID` list to `story-planner`.
  - `NEW` → go on.
- Warn early about blockers: hero sheet `tool/image_refs/<hero>.png` missing (`kid.png` isn't made yet), English cloned voice not set up (`tool/voice/ref/en/`).

## 1. Outline
Run `story-planner` with idea, id, hero (and the checker's `AVOID` list if SIMILAR). If it replies `DUPLICATE: <id>`, stop and warn the parent as in step 0. Show the user the outline (title vi/en, hero, moral, both paths per choice, scene list) short, with the file link.

**⏸ Gate 1.** Approve or change. Changes go back to `story-planner`. Do not continue without approval. On approval write `docs/stories/<id>/progress.json` with `"gates": {"outline": "<YYYY-MM-DD>"}` (shape in the `story-continue` skill).

## 2. Script
1. Run `story-writer` with the id.
2. Run `story-reviewer` with the id.
3. FIX → `story-writer` again ("revise from docs/stories/<id>/review.md"), then `story-reviewer` once more. Max 2 rounds, then show remaining FIX items to the user.

Before showing it, check the name rule yourself in both languages: `{name}` at most once per line and only as the **first or last word of the whole line** (not of a later sentence), never in labels; `python3 tool/check_story.py <id>` enforces it, and `python3 tool/gen_audio.py --story <id> --list` must show at most one clip beside each `[tên bé]`.

Show the full narration (node by node, vi then en, options indented) plus NOTES.

**⏸ Gate 2.** Approve or edit lines. Small wording edits: do them in story.json yourself, rerun `python3 tool/check_story.py <id>`. Bigger changes → `story-writer`. On approval set `gates.script` in progress.json. The parent can start recording now (`/story-audio <id>` step 1 gives the script), in parallel with the art.

## 3. Art (clock_time workflow, with the parent)
Read CLAUDE.md "Art" first. Steps:
1. Character sheet for the hero must exist in `tool/image_refs/<hero>.png` (`kid.png` for unisex): if missing, `python3 tool/gen_image.py --refs --only <hero> --prompts-out <dir>` first.
2. Run `art-director` with the id: it writes `docs/stories/<id>/art_prompts.json` (`setting`, `reference`, `pictures`, `outfits`, `plates`, `poses`).
3. Run `art-reviewer` with the id (mode prompts). FIX → `art-director` again ("revise from docs/stories/<id>/art_review.md"), then `art-reviewer` once more. Max 2 rounds, then show remaining FIX items to the user.
4. Prompts for the parent (no API cost): `python3 tool/gen_image.py --story <id> --prompts-out ~/Downloads/art_prompts/<id>`. Or with a key: `--dry` first, then without. The parent makes pictures in the Gemini app and saves them to `~/Downloads/story_art/<id>/`. Also build the tracking page: `python3 tool/prompts_page.py <id> <scratch>/<id>_prompts.html --title '<Short> Story Prompts'` and publish it as an Artifact (pictures, plates, poses with copy buttons and ticks; each prompt starts with its file name). Save its link in progress.json `prompts_page` and set `gates.art_prompts` once the parent has seen it. After any prompt change, rebuild and republish to that same URL.
5. After each batch the parent saves ("I saved the images"): run `/story-art <id>` (in a later session: `/story-continue <id>`) (inventory, watermark removal, best-quality compression under budget, a look at every picture for consistency, hotspots, plates + poses cut-out, asset check). Repeat until nothing is missing. Never import pictures any other way: `/story-art` is what removes the watermark and fits the budgets. Do not go on to step 4 (wire + test) while a picture is missing or marked redo, unless the parent says so.
6. SVG overlays for what AI draws badly (clocks, numbers): like `tool/clock_layer.py` (`docs/examples/clock_time_clock.json`).
7. Set `ambient_origin` on the ending from the real picture; add `cues` (`pose` on action words) and node `poses`.
8. `python3 tool/check_story.py <id> --art` and `python3 tool/check_assets.py <id>`. **Report every OVER line to the user** and offer to downsize (the tools already pick the best quality that fits, so: re-import a simpler picture, `crop_layers.py`, a smaller cut part). Busiest scene under ~15 MB decoded.

## 4. Wire + test (yourself)
1. `python3 tool/wire_story.py <id>`: adds the id to `assets/stories/index.json` and the story's folders to `pubspec.yaml` (`images/layers/` only if it exists). Safe to re-run; rerun after cutting the first layers.
2. Audio before tests (the asset test checks every clip, both languages): run `/story-audio <id>` steps 1–4. Whenever the parent says recordings are in, clean them first (`clean_audio.py --story <id>` + `--check`, no asking), then the missing check and clone.
3. `fvm flutter analyze` and `fvm flutter test`. On failure route the exact error to the file's owner. Max 2 rounds, then report.

## 5. Report
- Title (vi/en), id, hero, scenes, choices (= max stickers).
- Files created (links), test result, `check_assets.py` summary.
- Audio: which clips the parent recorded, which the clone made (per language); cleaned clips (silence cut, noise before → after, LUFS before → after), anything flagged to re-record; `clean_audio.py --check` result.
- Manual step left: play it in both languages (`fvm flutter run -d chrome`): ambient calm, z's at the head, cues move the right part on the right word, taps react, ending gives the right number of stickers, profile shows them.

Do not commit unless the user asks.
