VERDICT: PASS

Round 2. I checked the revised `art_prompts.json` and the rendered kit prompts (`gen_image.py --story tell_truth --kit --prompts-out`, plus `--dry` for the cover) against the round 1 FIX list. Every FIX is applied as written, and nothing new is broken.

- **props_truth.vase_spilled:** it uses the solid, opaque sky-blue puddle wording and asks for no shine, no drops, one piece. It is now last in `figures`, so the rows are 4 / 4 / 2 and the wide piece shares the last row only with `heart`. `reference.vase` uses the same words.
- **hero_b.kneel_roll:** no ball is named any more. It says "nothing in, under or in front of the hands".
- **lulu_c.peek:** the visor wording is gone. The paw shades the eyes, and it says "nothing on her head".
- **rooms.bath:** the walls are warm cream tiles with a pale-blue stripe and the floor is warm-beige tiles, with "no green or mint anywhere". The cup is pale blue. A ban on bedroom pieces (bed, pillow, blanket, rug, shelf, door) comes right after the first sentence. `reference.bathroom` matches.
- **Smaller notes:**
  - The cover's Lulu sits between the hero and the table, lower than the flower heads and not in front of the vase.
  - The flower lengths are consistent. Stems are about as long as the vase is tall: in the vase the blooms stand about half the vase's height above the rim, and in the cup they stand about as high again as the cup. The loose flowers are about as long as the vase is tall.
  - `reference.flowers` notes the swap into the cup.

## FIX
(none)

## NOTES (optional, not blocking)
- **outline.md is behind the prompts.** None of this affects the pictures, but tidying it avoids false flags in later checks:
  - Line 181 still says "Pale mint and cream tiles". It should say cream wall tiles with a pale-blue stripe, beige floor and a pale-blue cup.
  - Line 187 still says "a light-blue water puddle". It should say the solid opaque sky-blue puddle.
  - Line 241 lists 9 props_truth figures without `bedside_table`. The sheet has 10, with `vase_spilled` last.
  - e1 still says the germ yawns.
- **Cutting props_truth:** cut it with the default gap grouping (connected pieces in reading order), not `--grid 4x3`. The spilled vase is about 1.5× the table's width, so it will spill over its grid cell in the 2-figure last row. `--names bedside_table,vase_flowers,vase_empty,flowers,cup,cup_flowers,germ_sleepy,germ_cheer,heart,vase_spilled`.
- **Cover attachments:** `--dry` shows only kid.png and lulu.png because the kit files don't exist yet. `attach.cover` (room + props_truth) is added in `--prompts-out` once they are made. Make the cover after the room and props_truth.
- These staging items are logged in progress.json and are not prompt issues:
  - The germ spot: above the headboard, about [0.12, 0.36], in e1 and e2.
  - The flowers' `in_cup` pose and the extra pose cue on "cốc" / "cup".
  - The `lulu_c` scale from the head width of `lulu_a`.
  - The `lie_sticky` → `bed_sit_shy` head jump in e2.
  - The d1 hero scale from the sink rim, plus `crop` if the bathroom comes back 16:9.

## Pictures (2026-11-11)

PICTURES: 1 redo (room_bath, a quick Gemini edit). Everything else is OK, with the staging notes below.

| picture | OK or redo | reason | sentence to add to the Gemini prompt (redo only) |
|---|---|---|---|
| kit/room_bath.png | **redo (edit this picture)** | It has no mirror, no mint, no people, no text, and plain tiled floor at the bottom right. The sink, towel, window and lamp are where `reference.bathroom` puts them, and the floor is open from the middle to the right. But the stripe of tiles at sink height and the cup on the sink are **light blue**, not lavender, which the prompt and reference forbid. The stripe sits right at the hero's chest, behind the mint pajamas. | "Edit this picture: repaint only the light-blue stripe of wall tiles and the small cup on the sink in soft lavender; keep everything else exactly the same." |
| kit/hero_a (6) | OK | This is the boy from boy.png: same hair, face, mint pajamas with white stars, barefoot. All 6 poses are there, whole and readable. `brush` holds a clearly visible bright-red toothbrush with white bristles, and there is foam at the lips. `stand_place` has empty hands, and `say_no` looks aside to the left. Note: `brush` faces the front rather than "a little to the LEFT", but the brush handle points left toward the sink, so this is fine. | |
| kit/hero_b (6) | OK (stage fix) | Same boy, and all 6 poses are readable. `kneel_roll` has open empty hands with nothing in front. `lie_sticky` and `asleep` have the head to the LEFT and lie on nothing. `bed_sit_shy` has the legs out to the right. **But the heads are about 11% bigger than on hero_a** (hair area: hero_b about 222 px against hero_a about 199 px). In stage.json both sheets have scale 0.68, so the boy would grow in s1 (`kneel_roll` → `stand_oops`) and between scenes. | |
| kit/lulu_c (2) | OK (notes) | No halo, rays, sparkles or shadow. `peek` has nothing on her head: the paw shades her eyes and she leans to the left. `sad` has drooping ears, a frown and paws at the chest. She is about 1.35× lulu_a on the sheet, which stage.json's scale 0.245 already handles. Her look is close to tool/image_refs/lulu.png but not quite tidy's lulu_a: no wrist cuffs, a plain white belly patch and smaller eyes. At Lulu's size on screen that should read as a change of mood. Check the s2 (`float` → `sad`) and a1 (`sad` → `float`) swaps on the stills. | |
| kit/props_truth (10) | OK (notes) | All 10 figures are there, in order, whole, with no faces except the two germs. The germs are friendly and fuzzy lime-green with no teeth, spikes or horns. The `vase_spilled` puddle is solid, opaque sky-blue with a clean edge: only its outline is soft (768 of about 19.5k blue pixels), and it is cut as one piece. The three vases match each other, and so do the two cups and the three sets of flowers. Things that differ from the prompt but don't need a redo: <br>• the table has four legs and is about as wide as it is tall (it matches the cover's table); <br>• the cup has no handle; <br>• the spilled vase's mouth points RIGHT, not left; <br>• on the sheet the vase is about 0.8 of the table's height and the cup about 0.9 of the vase's height. stage.json's per-part sizes (table ×1.8, cup ×0.78) give, on the canvas: vase about 0.46 of the table's height, and vase (about 106 px) plus cup (about 102 px) side by side on a table top of about 335 px, so they fit. | |
| kit/room.png, lulu_a, props (reused) | OK | Already approved in tidy_toys. Only `ball` and `blanket_lump` are used from `props`. | |
| cover.webp | OK (note) | No text. It shows the same boy, kneeling, smiling and facing right. Lulu floats between him and the table, does not touch him, and is not in front of the vase. The table has the vase with its moon and three flowers, with the heart just above. The bottom-right corner is plain floor. **But the room is not kit/room.png**: the window is round with a cross and the door is arched (from `setting`'s "rounded door"), and the room is lighter peach and wood. tidy_toys' cover shows that same bedroom with the square four-pane window. This is noticeable only next to tidy's cover; redo if the parent minds (prompt sentence in NOTES). | |
| sticker.webp | OK | One sticker shape: the vase with its happy face and amber moon, three flowers and a heart touching the flower heads. No text, no hero, and it reads well at small size. | |

### Pictures: staging notes (stage.json, not prompts)
- **hero_b scale:** set `sheets.hero_b.scale` to about **0.61** (0.68 / 1.11). Confirm by matching head widths on `stage.py --guides`, especially in s1 (`kneel_roll` → `stand_oops`) and e2.
- **vase_spilled direction:** the mouth points right, so as it is, the flowers spread toward the table and the ball at `by_table`. Either add `flip` for the spilled state (if stage.py can flip one pose; flipping the whole vase part also mirrors `vase_flowers`' moon, which is harmless), or keep it and check on the s1/s2 stills that the flowers don't overlap the ball. Then update `reference.vase` to match.
- **lulu_c `sad` speck:** a small grey patch of sheet background is left between her chin, her right paw and her right ear (about x 520–560, y 450–480 in `sprites/lulu_c/sad.png`). On the night room it shows as a pale triangle. Re-cut lulu_c without `--fill-holes`, or erase that patch by hand.
- **Bathroom crop** `[0, 0.125, 1, 0.875]` keeps the top of the lamp and the window (y ≥ about 0.15 of the square) and the sink base (about 0.84). Good. The camera is closer than in the bedroom: the sink rim comes out at about 39% of the canvas height, so scale the d1 hero from the rim at chest height (that puts the boy at about 60% of the canvas height). Lulu at `air_bath` should use the same factor.
- **reference updates** (art-director, so later checks don't false-flag): the bedside table has 4 legs and is about as wide as it is tall; the cup has no handle; the spilled vase's mouth points right (unless flipped); the bathroom stripe and cup are lavender after the edit.
- **progress.json note (e)** still says "yellow brush": the toothbrush is red.

### Pictures: NOTES
- Cover redo sentence, if wanted: "The bedroom looks exactly like the attached room picture: a square four-pane window with a wooden frame in the middle of the back wall and a plain rectangular wooden door; no round window and no arched door."
