VERDICT: PASS

Round 2. Re-rendered `gen_image.py --story keep_promise --kit --prompts-out` (`01_kit_props_promise`, `02_kit_hero_f`) and `--dry` (cover, sticker) and compared them with `reference`, `outline.md` and round 1.

## FIX
(none)

Round 1 fixes are all in:
- `props_promise` now comes before `hero_f` (01 / 02 on the prompts page).
- `hero_f` attaches girl.png, kit/hero_e.png and kit/props_promise.png. Its note points to the "second attached sheet" for size and the "third attached sheet" for the can, which matches the attach order. It also says "the very same … watering can" and "draw no plant pots and no balloon".
- `kneel_water` head size is pinned to the yawning child's head in hero_e.
- `sprout_droopy`: "the leaves hang beside the face, not over it".
- `balloon`: the string is now "a little thicker than a thread, softly shaded … unbroken".
- Cover: "the pot about one and a half times as wide as the girl's head".
- Lamp: `setting` and `reference.lamp` now say the same thing ("between the bed's headboard and the window").
- Outline: 3 columns for props, short stream instead of drops.

## NOTES (optional, not blocking)
- `setting` (used only by the cover) still names "a rounded light-wood door on the right wall", but the attached room.png has the door cropped out. With the room attached and the closing "look exactly like in them" line, Gemini should follow the picture. If a door shows up on the cover, it is harmless (same as tidy_toys).
- Staging a1: the stream's tip must land over the pot's soil at `by_pot` / `pot_spot`. Check the `kneel_water` head against `kneel_sad` (b3 → a1) on a `stage.py --guides` still.
- After cutting `props_promise`, check on `_contact.jpg` that the balloon string is whole.
