VERDICT: PASS

Round 2 (2026-11-13). Re-rendered with `gen_image.py --story math_plus --kit --prompts-out` (hero_i, props_sheep) and `--dry` (cover, sticker); checked against `reference`, the outline Update, story.json (`math`, `counted`, end `ambient_origin`), docs/kit.md §1–2 and docs/math.md "Art".

## FIX

(none: all four round-1 items applied)

- Crop: `reference.room` fixes one crop [0.215, 0, 0.959, 1] for every scene (door and bed both in). `reference.rug` / `.door` give meadow, fence and door spots on the floor and rug. story.json `math.field` = [[0.18, 0.87], [0.28, 0.93], [0.38, 0.87], [0.48, 0.93], [0.58, 0.87]] and `math.wait` = [[0.77, 0.87], [0.86, 0.82], [0.84, 0.95]] match them. The end `ambient_origin` [0.1, 0.52] fits the asleep head in this crop.
- Sheep size: about one tenth of the picture wide, never smaller; the curled-up sheep is just as long and about two thirds as tall.
- props_sheep: 5 figures (sheep_stand, sheep_sleep, fence, sheep_stand_2, sheep_sleep_2), 3 columns × 2 rows, last cell empty. The sleeping sheep is a plump ball with its head clearly visible. With `--grid 3x2`, `sprite_sheet.py` groups by cell and skips the empty one, so the 5 names line up.
- Fence: gate-like, "runs from the back toward the front" in the sheet, `setting`, `reference.fence` and the cover. "standing," was dropped from the setting's sheep sentence, so the cover's leaping sheep no longer clashes with it.

## NOTES (not blocking)

- Cutting: `gen_image.py` prints the props_sheep cut command without `--grid 3x2`. Add it by hand (`reference.kit` already says so). Without the grid, the two-figure bottom row still reads in order by gap, but the grid is safer if the fence's posts come apart.
- The generator's sheet wording says "5 separate toys and things… each drawn once", while figures 4 and 5 are spares. The figure texts and the note ("second identical… (spares)") are explicit, so Gemini should follow them. If it draws only three things, just cut those three (`--names sheep_stand,sheep_sleep,fence`).
- When picking sprites, take `sheep_sleep` from the copy that matches the chosen `sheep_stand` (same wool, same face shade). Both become `math.icon` and five parts each, so a mismatch shows at d2.
- The sticker's fence is not told to stand at the gate angle. That is fine for a standalone sticker (the sheep leaps across it either way). Only add "turned at an angle across the sheep's path" if the sticker should match the cover exactly.
- `reference.door` still ends with "Then copy the measured spots into story.json… (current values are the old placeholders)". The copy is done; drop that sentence or keep it as a reminder to re-measure on the `--guides` still.
- From round 1, still true: no prompt relies on a count, digits or text (the cover and sticker show exactly one sheep). The word Lulu attaches her sheet only on the cover. Use `shadow: true` on sheep1–sheep5. Check the end still at phone width at the stills gate (the sleeping sheep is about 40 × 25 pt on a picture 390 pt wide).
