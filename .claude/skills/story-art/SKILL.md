---
name: story-art
description: Bring the parent's Gemini pictures for a story into the app, one batch at a time — check what's saved vs. what's needed, cut the kit's pose/prop sheets into sprites, compose the scenes (stage.json, stage.py, stills), import cover and sticker (watermark off, compressed to budget), look at every picture for consistency (room, hero, Lulu, props, no text); report what's left. Use for "/story-art", "import the pictures", "I saved the images", "check the art for <story>", or the art import step of /new-story.
argument-hint: <story_id> [picture names]
---

# /story-art

The parent makes pictures in the Gemini app (prompts on the tracking page from `tool/prompts_page.py`) and saves them to `~/Downloads/story_art/<id>/`: room and sheets in `kit/<name>.png`, cover and sticker at the top. They come in batches; run this after each one. Read CLAUDE.md "Art" and `docs/kit.md` first.

Use `tool/cutout/.venv/bin/python` (has numpy, OpenCV, rembg) for every image tool below; call it `$PY`.

Never rename, move or delete the parent's files in Downloads (copy them). Never import over a picture without saying so.

## 1. Inventory
`python3 tool/story_status.py <id>` compares the folder with `docs/stories/<id>/art_prompts.json`: `kit` → `kit/<room>.png`, `kit/<sheet>.png` (saved, cut into sprites, scenes staged; shared sheets made for another story are listed as "copy"); `pictures` keys → `<name>.png` (any of png/jpg/webp). It lists imported, waiting (new or redone since the import), missing, redo (from `progress.json`), unknown files. Show a short table from it.
- Unknown names (`Gemini_Generated_Image_*`, `image (3).png`, typos): Read the image, say which picture it most likely is, and use it under that name only after the parent agrees (copy into `kit/`, or import with `--as`).
- A file in the wrong folder (a sheet outside `kit/`): say so; copy it to the right place if the parent agrees.
- Shared sheets: copy (never move) them from the story they were made for into this story's `kit/`, with their `sprites/<sheet>/` folder.

## 2. Import cover and sticker
```bash
$PY tool/import_art.py <id> ~/Downloads/story_art/<id> --new
```
It removes Gemini's sparkle watermark (`tool/remove_watermark.py`), crops to shape (cover 800×600, icon 400², sticker 600² with the white background cut away, a fallback scene 1600×1200) and saves WebP at the highest quality that fits the budget. `--new` skips pictures already imported and unchanged. A folder import takes only names in `art_prompts.json` `pictures` and lists the rest as skipped. Report any `OVER` line.

## 3. Cut sheets
Rules and lessons: `docs/kit.md` §3. Never edit the parent's sheets; sprites go to `~/Downloads/story_art/<id>/kit/sprites/<sheet>/`.
1. `python3 tool/gen_image.py --story <id> --kit --prompts-out <scratch>` prints the exact `sprite_sheet.py` command per sheet ("then: ..."); run it with `$PY`. Read `_contact.jpg`.
   - Wrong count: `--grid CxR` (figures close), bigger `--gap` (a prop in pieces), `extra_*` names (Gemini drew more).
   - ✦ left on a figure: `--force-mark`. Two ✦ marks, or a mark the tool can't undo: cut the one figure from a crop of the sheet away from the marks (`--keep-corner`).
   - A pale edge bitten off (straw brim on the beige wall): `--solid` (props only).
   - Lulu's ears hollow: `--fill-holes` (never for the child: an arm can enclose real background).
   - A sheet that arrives already transparent: put it on the wall colour first (`(215, 201, 190)`), then cut as usual.
   - One figure redone on a new sheet: cut that sheet to a scratch folder, copy only that sprite over the old one; keep a copy of the new sheet in `kit/` as `<sheet>_fix.png`.
2. Run `art-reviewer` mode "pictures" with the room, each new sheet's `_contact.jpg` and the cover/sticker: every pose there and readable, one body size, right gender and outfit, no extra hands, Lulu without halo, props in the right sizes and states, room matches `reference`. Don't Read the pictures yourself unless the parent asks about one.
3. Show the parent the redo items. A redo is the parent's call: offer, don't insist on small things. When the parent agrees, add it to `progress.json` `redo` (`"<name>": "<reason> → add: <sentence>"`); remove it when the redone picture comes back OK. If the sentence belongs in the prompt itself, edit `art_prompts.json` (via `art-director` beyond one sheet) and republish the prompts page.

## 4. Stage scenes
Once the room and every sheet a scene needs are cut (`docs/kit.md` §4):
1. Write `docs/stories/<id>/stage.json` from another kit story's (`tidy_toys`; several rooms or crops: `clock_time`, `prepare_stuff_vacation`) and the outline's layouts. First `$PY tool/stage.py <id> --preview <scratch> --dry --guides` to measure the room (crop, bed, floor line; write them in `"_note"`), then place parts, then `$PY tool/stage.py <id> --preview <scratch>` (writes `layers/kit_*`, `layers.json`, flat fallbacks, icons).
2. Parts are drawn in list order: a later part is in front. Things the child holds or reaches past go behind the hand; things put into a bag go in front of it unless the parent says otherwise.
3. Story with a clock (`docs/stories/<id>/clock.json`): `python3 tool/clock_layer.py <id> --preview <scratch>` after every `stage.py` run that changes the table's place.
4. Read every still (`<scratch>/<scene>.jpg` and `<scene>_poses.jpg`): feet on the floor, nobody floating or cut off, sizes as in `reference`, small named toys easy to see, hands not hidden, nothing in the bottom-right corner that matters, each scene continues the one before it. Fix numbers and rerun.
5. **⏸ Stills gate**: show the parent the stills (one contact image of all scenes is fine) and ask for changes. Then set cues on the stage (`docs/kit.md` §5), run `cue_times.py`, and record the approval in `progress.json` `notes`.
6. `python3 tool/wire_story.py <id>` if the story is already wired (adds `images/layers/`).

A scene a kit can't show well can still be one Gemini picture (`docs/kit.md` "Fallback"): import it in step 2 under the scene's name, give it `images/hotspots.json` boxes for tap bursts, and leave it out of `stage.json`.

## 5. Check
```bash
python3 tool/check_assets.py <id>
python3 tool/check_story.py <id> --art      # once every picture the story uses exists
```
Report every `OVER` line and the fix (re-import, smaller `size` in stage.json, re-encode a clip). Set the ending's `ambient_origin` at the sleeping head (from the `--guides` still) and rerun `check_story.py`.

## 6. Report
Short table: picture or sheet, sprites cut / quality and KB, OK or redo, staged (yes/no). Then `python3 tool/story_status.py <id>` and what's still missing, in the order the parent should make them (room, sheets in page order, cover and sticker, stills to approve). If prompts changed, rebuild and republish the tracking page (`tool/prompts_page.py`) to the link in `progress.json` `prompts_page`.
