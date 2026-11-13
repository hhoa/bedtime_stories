# Kit art (every story)

Since 2026-11-11 every story is a **kit story**: a few Gemini images instead of one per scene. The parent makes one empty room, sheets of poses (hero, Lulu) and props, plus cover and sticker. The app composes and animates every scene from those pieces. Worked examples: `tidy_toys` (one room, the first kit story), `clock_time` (day + night room, day-clothes sheet, SVG clock), `prepare_stuff_vacation` (two crops of one room, composite sprites). Their files: `docs/stories/<id>/` (`outline.md`, `art_prompts.json`, `stage.json`, `progress.json` notes) and `assets/stories/<id>/story.json` (cues).

The old picture-per-scene workflow (plates, pose edits, `cutout.py`) is gone (2026-11-12). A single scene a kit can't show well can still be one Gemini picture (see "Fallback").

## Who does what

| Step | Who | Files |
|---|---|---|
| Outline: layout + moves per scene, pose and prop lists | `story-planner` | `outline.md` |
| Script + cues on words | `story-writer` | `story.json` |
| Prompts: `kit` (room + sheets) + `pictures` (cover, sticker) | `art-director` → `art-reviewer` | `art_prompts.json` |
| Phone page with the prompts | main session | `gen_image.py --kit` + `--prompts-out`, `prompts_page.py` |
| 7 images in Gemini | parent | `~/Downloads/story_art/<id>/kit/*.png`, `cover.png`, `sticker.png` |
| Cut sheets, write `stage.json`, compose, stills | main session (`/story-art`) | `stage.json`, `images/layers*`, flat fallbacks, icons |
| ⏸ Stills gate, then play it | parent | |
| Cue moves / poses tuned to the stage, `at` timing | main session | `story.json` |

## 1. Planning a kit story (outline)

- **One room** for every scene (or two at most). Reuse a room the parent already made when it fits (every story so far uses the `tidy_toys` bedroom). The room has open floor in front for people and props, and any spot the story needs (a dark gap under the bed for a ball to roll into, a shelf to put things on).
  - Morning scenes: one Gemini edit of the night room into daylight (`clock_time` `day`).
  - Bed and door can't both fit one 4:3 picture: two crops of the same file (`prepare_stuff_vacation` `door` + `bed`).
- **Share sheets across stories**: same girl, same mint star pajamas, same Lulu, same room. Check the earlier stories' sheets (`docs/stories/*/art_prompts.json` `kit.sheets`) before asking for a new pose; new poses go on sheets every story can use.
- **Hero poses ≤ 12** (two sheets of 6), **Lulu poses ≤ 6** (one sheet), **props ≤ 12** (one sheet, 4 columns). Each pose has a short snake_case name.
- Each scene is described as a **layout** (who / what stands where, pose or state) plus **moves on words** (`hop`, `wiggle`, `pulse`, `move` to a named spot, `pose` switch). Name the spots once (`rug_left`, `by_box`, `air_mid`, `under_bed`) and reuse them.
- **Nothing appears or disappears inside a scene.** "Who holds what" changes between nodes (the hero holds the ball from the next node on). A thing that leaves mid-scene goes *behind* something drawn later (blocks slide behind the toy box front). Inside a node a toy can change state by a `pose` swap (empty box → full box → box with the ball on top).
- A `move` only holds for its node: the next node's layout starts where the last move ended.
- Things held in a hand are drawn in that pose's figure (`stand_ball`, `hug_teddy`); things lying around are props. A prop that is sometimes held needs both (prop `ball` + pose `stand_ball`), and the layout leaves the prop out while it is held.
- Sliding a person across the room looks like gliding: switch pose first (kneel, tummy), then a short slow move.
- Ending: the hero asleep in bed = `asleep` figure (lying on nothing) + the room's bed + a blanket prop on top + `zzz` at the head.
- Touching characters are fine when they are one figure (hero hugging teddy). Hero and Lulu never touch (separate sheets).
- Icons are composed from props (no Gemini); the cover and sticker are normal pictures.
- Write a **Pose and prop lists** section and a **Kit notes** section (beats changed to fit the kit, the parent approves them with the outline).

## 2. Prompts (`art_prompts.json`)

Keys: `hero`, `setting`, `reference`, `pictures` (only `cover`, `sticker`), `attach`, `kit`. Shape: `docs/stories/tidy_toys/art_prompts.json`. `gen_image.py` adds the style, the sheet rules (separate figures, plain pale-grey background, no touching, no text) and the character description to each sheet, so the `figures` text only says the pose.

- `kit.room`: `{"attach": "...", "prompt": "..."}`. Best as an **edit of a picture the parent already has** (same room, same light): remove people, Lulu and loose props, keep camera and furniture, add what the story needs. Or a new room prompt. Nothing on the floor; no text. Several rooms: `kit.rooms.<name>` with the same keys.
- `kit.sheets.<name>`: `{"who": "hero"|"lulu"|"props", "columns": 3|4, "note": "...", "figures": {"<pose>": "<one sentence>"}, "attach": "..."}`. Figure order = cut order. `"outfit": "a plain soft-yellow t-shirt and navy shorts"` = same child in other clothes (`clock_time` `hero_day`).
- A room or sheet made for another story: `"from": "<story>/kit/<file>.png"` (listed as "copy" in `story_status.py`, left out of the prompts page).
- Rules learned on `tidy_toys` (art review FIX items):
  - Hero sheets: "The child's head is exactly the same size in every figure; sitting, kneeling and lying figures are simply smaller in the cell, never enlarged to fill it."
  - The second hero sheet attaches the first (`"attach": "kit/hero_a.png (the sheet you made before this one)"`) and says "the same size as in the second attached sheet".
  - Lulu sheet: "Her soft glow stays on her own fur only: no halo, no glow cloud, no light rays, no sparkles, no stars and no shadow" (a halo can't be cut cleanly). Her look comes from her sheet; `glow` is a pose.
  - Props sheet: "No faces" on objects (only toys that have one); one shared angle ("from the front, slightly from above"); state changes of one thing are "the very same <thing> at the same size and angle"; give sizes relative to one prop ("the ball is about one fifth of the chest's width").
  - Directions match the room: say which way each figure faces and where the head is ("head to the LEFT") so it fits the bed / box spot without flipping.
  - Hands: a figure that puts something down or reaches has "open empty hands, nothing in or under the hands" (the prop is its own sprite).
  - Asleep / in-bed figures lie "on nothing: no pillow, no blanket, no bed"; the room's bed and a blanket prop go around them.
  - Call each recurring prop by the same words everywhere (`reference`, figures, cover).
  - Cover: `"attach": {"cover": ["kit/room.png", "kit/props.png"]}` plus "If a room picture or a props sheet is attached, the room, … look exactly like in them".
- **Reuse before making**: Lulu sheet and the room can come from an earlier kit story when the poses fit. Copy (never move) `~/Downloads/story_art/<other>/kit/<sheet>.png` into this story's `kit/` folder and note it in `progress.json`; keep the sheet entry so the cut names stay the same, and tell the parent to skip that prompt.

## 3. Cutting sheets

```bash
PY=tool/cutout/.venv/bin/python
python3 tool/gen_image.py --story <id> --kit --prompts-out <scratch>   # prints the exact cut command per sheet
$PY tool/sprite_sheet.py ~/Downloads/story_art/<id>/kit/<sheet>.png --names a,b,c,...   # Lulu: --fill-holes
```
Read `kit/sprites/<sheet>/_contact.jpg`. Count wrong → nothing saved: figures too close → `--grid 3x2` (columns x rows); one prop split in pieces → bigger `--gap`; Gemini drew extra figures → add names `extra_1,…` (unused). ✦ mark left on a figure (on the sprite in the contact sheet) → `--force-mark`. Read every sprite once on a dark background: whole figure, no background left, nothing of a neighbour, no bite out of a pale edge.
- Pale edge bitten off (straw hat brim on the beige wall) → `--solid` (keeps every pixel whose colour differs from the wall and touches the cut; strap loops and handles stay open).
- A sheet that comes back already transparent → put it on the wall colour `(215, 201, 190)` first, then cut it as usual.
- One bad figure (wrong gender, three hands): the parent redoes the sheet; cut it to a scratch folder and copy only that sprite over the old one. Two ✦ marks on a redone sheet: cut that figure from a crop away from them (`--keep-corner`). Keep the new sheet as `kit/<sheet>_fix.png`.

## 4. Staging (`stage.json`)

Copy `docs/stories/tidy_toys/stage.json` as the start, then:
```bash
$PY tool/stage.py <id> --preview <scratch> --dry --guides    # stills with a 10% grid, assets untouched
$PY tool/stage.py <id> --preview <scratch>                   # write layers, fallbacks, icons
```
- Picture = 1600×1200; every position is a fraction. Part `at` = feet (bottom middle) by default; `"anchor": "center"` for floating things (Lulu sheet). **Icon `at` = the sprite's centre.**
- **Draw order = list order: a later part is in front.** The child's hands go in front of what she reaches past (clothes before the hero); things she puts into a bag were wanted in front of it.
- Several rooms: `"rooms": {"day": {"file": "kit/room_day.png", "crop": [...], "erase_specks": [...]}, ...}` and `"room": "day"` per scene (output `layers/kit_room_<name>.webp`).
- Room came back 16:9 → `"crop": [x0, y0, x1, y1]` keeps the 4:3 part with the bed and the action. Leftover sparkles from the room edit → `"erase_specks": [[x0, y0, x1, y1]]`. Write the room's landmarks into `"_note"` (bed top, floor line, gap under the bed, rug) once measured with `--guides`.
- One `scale` per sheet keeps the body size equal across poses; check the hero against the furniture on a `--guides` still (sizes as in `reference`, e.g. the toy box reaches the standing child's waist). Per-part `scale` only for props whose size changes the reading.
- **Small toys the narration names must be easy to see on a phone**: about as big as the hero's head (the ball needed `scale` 0.75 after two "bigger" asks).
- "X goes in the box": composite sprite `"sprites": {"props/toybox_ball": {"from": "props/toybox_full", "add": [{"sprite": "props/ball", "at": [0.56, 0.17], "scale": 0.75}]}}`, used as a `pose` of the box and switched on the word.
- `covers` (room polygons redrawn on top) hide whatever is behind them, **hands too**. When a scene is about the hands (sitting in bed, reaching), don't cover the hero: put a blanket prop over the legs only, or move the hero onto the open floor.
- `shadow: true` for things standing on the floor; not for Lulu or things in bed.
- Every scene of one node graph path should continue the last one: same spots for things that didn't move.
- Each run prints every part's pivot: a `move` cue's `"to"` is where that pivot goes.
- Things AI draws badly (a clock face with the right time) are SVG layers drawn after staging: `clock_layer.py <id>` from `clock.json` (`at` = table top from `--guides`; `"icons"` = choice icons as SVG). `stage.py` keeps `.svg` layers.

Then show the stills (all scenes in one contact image is fine) and **⏸ the parent approves them** before cues are tuned. Layout fixes are number edits and a rerun.

## 5. Cues (`story.json`)

- Parts in cues = `kind`s in `stage.json`. `pose` names = the part's `poses` keys; node `"poses"` sets the start pose.
- `move` `"to"` = pivot target (feet / centre), from the stage run's printout; check the end spot on a `--guides` still.
- After audio (and after every re-recorded or re-cloned clip): `$PY tool/cue_times.py <id>` writes `"at"` per cue, so parts move on the word. It finds cue words in order: two cues on the same word lose the second's timing, so put them on neighbouring words. Keep each cue object on one line (`{"word": ...}`), as its parser expects.
- Then `python3 tool/check_story.py <id> --art`, `python3 tool/check_assets.py <id>`, `fvm flutter test`, play in Chrome (full restart after new layers).

## Fallback

A scene that still looks wrong as a kit after a layout round (crowded, needs a camera angle the room can't give) becomes a normal Gemini picture for that node: add it to `pictures`, import it with `/story-art`, drop the scene from `stage.json` and delete that scene's entry in `images/layers.json` by hand (`stage.py` leaves entries of scenes it no longer stages, and the kit layers would cover the new picture). A flat picture has no moving parts: give it `images/hotspots.json` boxes for tap bursts, and its cues can only `hop|wiggle|pulse` a hotspot. Staged and flat scenes mix in one story.
