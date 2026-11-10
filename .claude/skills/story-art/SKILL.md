---
name: story-art
description: Bring the parent's Gemini pictures for a story into the app, one batch at a time — check what's saved vs. what's needed, remove Gemini's watermark, compress to the asset budgets at the best quality, look at every picture for consistency (room, hero, Lulu, props, no text), cut out moving parts with plates and poses, and report what's left. Use for "/story-art", "import the pictures", "I saved the images", "check the art for <story>", or the art import step of /new-story.
argument-hint: <story_id> [picture names]
---

# /story-art

The parent makes pictures in the Gemini app (prompts on the tracking page from `tool/prompts_page.py`) and saves them to `~/Downloads/story_art/<id>/`: pictures at the top, `plates/<scene>.png`, `poses/<scene>__<part>__<pose>.png`. They come in batches; run this after each one. Read CLAUDE.md "Art" first. Use `tool/cutout/.venv/bin/python` (has numpy, OpenCV, rembg) for every image tool below; call it `$PY`.

Never rename, move or delete the parent's files in Downloads. Never import over a picture without saying so.

## 1. Inventory
`python3 tool/story_status.py <id>` compares the folder with `docs/stories/<id>/art_prompts.json`: `pictures` keys → `<name>.png`; `plates` keys → `plates/<scene>.png`; `poses` → `poses/<scene>__<part>__<pose>.png` (any of png/jpg/webp). It lists imported, waiting (new or redone since the import), missing, redo (from `progress.json`), unknown files, and scenes ready to cut. Show a short table from it.
- Unknown names (`Gemini_Generated_Image_*`, `image (3).png`, typos): Read the image, say which picture it most likely is, and import it with `--as <name>` only after the parent agrees.
- A file in the wrong folder (a plate at the top): say so; import from where it is with `--as` if the parent agrees.

## 2. Import new pictures
```bash
$PY tool/import_art.py <id> ~/Downloads/story_art/<id> --new
```
It removes Gemini's sparkle watermark (`tool/remove_watermark.py`: undoes the known white overlay, texture comes back), crops to shape (scene 1600×1200, cover 800×600, icon 400², sticker 600² with the white background cut away) and saves WebP at the highest quality that fits the budget. Each line prints quality, KB and "watermark removed". `--new` skips pictures already imported and unchanged; a redone picture (newer file) is imported again. A folder import takes only names in `art_prompts.json` `pictures` and lists the rest as skipped (step 1 handles them with `--as`). Report any `OVER` line.

## 3. Look at every new picture
Run the `art-reviewer` agent in mode "pictures" with the id and the list of pictures imported in step 2. It reads each one against its prompt, the `reference` block in `art_prompts.json` (room, hero, Lulu, props and their state per scene), story.json (text, cues), the character sheets and earlier pictures, and replies **OK** or **redo** per picture with the reason and one sentence to add to the Gemini prompt. Don't Read the pictures yourself unless the parent asks about one: it keeps this session small for the next batches.

Show the parent the redo items. A redo is the parent's call: offer, don't insist on small things. When the parent agrees, add it to `docs/stories/<id>/progress.json` `redo` (`"<name>": "<reason> → add: <sentence>"`); when a redone picture is imported and comes back OK, remove its entry. If the sentence should go into the prompt itself, edit `art_prompts.json` (via `art-director` for anything beyond one picture) and republish the prompts page.

## 4. Cut out moving parts (per scene, when ready)
A scene is ready when it is imported, OK, and its plate plus all its poses are saved.
1. Hotspots: `$PY tool/preview_hotspots.py <id> <scratch>`; look at the grid; add or update the scene's boxes in `assets/stories/<id>/images/hotspots.json` for every part and tapped prop the story's cues use (Lulu last). Boxes of cut parts must also hold their poses.
2. Cut: the exact command for each scene is printed by `python3 tool/gen_image.py --story <id> --poses --prompts-out <scratch>` ("then: ..."); run it with `$PY` and `--preview <scratch>`. Layers are saved at the best quality under 120 KB.
3. Read `<scratch>/<scene>_poses.jpg`: every pose must line up over the default (same spot and size). One that drifts → ask the parent to redo that pose edit.
4. Plates and poses keep their watermark only outside the cut area, so they need no cleaning.

## 5. Check
```bash
python3 tool/check_assets.py <id>
python3 tool/check_story.py <id> --art      # once every picture the story uses exists
```
Report every `OVER` line and the fix (re-import, `crop_layers.py`, smaller part). When the ending picture exists, set the ending's `ambient_origin` at the sleeping head (from the hotspot grid) and rerun `check_story.py`.

## 6. Report
Short table: picture, quality/KB, watermark, OK or redo, cut (yes/no). Then `python3 tool/story_status.py <id>` and what's still missing, in the order the parent should make them (pictures before their plates/poses). If prompts changed, rebuild and republish the tracking page (`tool/prompts_page.py`) to the link in `progress.json` `prompts_page`. Once cut layers exist, rerun `python3 tool/wire_story.py <id>` if the story is already wired (adds `images/layers/`).
