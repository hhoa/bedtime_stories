VERDICT: PASS

Kit story re-review after the art-director applied the first review's 14 FIX items. Checked art_prompts.json `setting`, `reference`, `pictures` (cover, sticker), `kit.room` and `kit.sheets` (hero_a, hero_b, lulu_a, props) against story.json, outline.md and stage.json (DRAFT). I read the regenerated prompts from `gen_image.py --story tidy_toys --kit --prompts-out` and `--prompts-out`.

## Earlier FIX items: all confirmed in the generated prompts
1. kit.room: teal suitcase with the red heart tag, the bunny and its glow and sparkles, the backpack with the star and the hat with the ribbon are all named for removal; the bed stays in place and keeps its size, headboard against the left wall. ✓
2. hero_a.bed_sit: sits on the floor, three-quarter view facing right, legs straight out to the RIGHT. ✓
3. hero_a.sit_play: hands open, palms up, empty, looking down to the right. ✓
4. hero_b.throw: no ball named, "nothing in the air". ✓
5. hero_b.bend_place: hands empty at waist height, "nothing in or under the hands". ✓
6. hero_b.asleep: "lying on nothing: no pillow, no blanket, no bed". ✓
7. hero_b.hug_teddy: teddy worded exactly like the props teddy. ✓
8. hero_a / hero_b notes: same head size in every figure. hero_b also attaches kit/hero_a.png. Its Attach line lists it second, and the note says "second attached sheet", so the two agree. ✓
9. lulu_a.note: the glow stays on her fur; no halo, rays, sparkles, stars or shadow, and the note says this holds even though the reference shows them. ✓
10. props.note: no faces except the teddy's own; sizes are given relative to the chest. ✓
11. props.blanket_lump: folded edge at the LEFT end, flatter to the right, nobody under or out of it. ✓
12. The striped beach-ball look is the same in props.ball, hero_b.stand_ball, setting and reference.ball. ✓
13. pictures.cover: box to the right of the hero, just left of the door and away from the bottom-right corner; teddy on the bed on the left; the striped ball; the sentence about using an attached room or props sheet. ✓
14. pictures.sticker: face on the front with the star above it; teddy worded like the kit's. ✓

Also confirmed: stage.json `icon_gentle` now uses props/toybox_full, which matches the full box at c2.

New conflicts checked:
- Sizes: the block pile ("about as wide as the lying teddy and a little taller than it") still fits "one low loose cluster".
- Shared style text vs. the edits: STYLE's "big expressive eyes" is overridden by the explicit "no faces" in the props note and by the closed eyes on the sticker.
- Lulu's sheet text still says "softly glowing", but the note that follows now limits the glow to her fur.
- Cross-file consistency: the props, reference, setting, cover and sticker describe the toy box, blocks, ball and teddy the same way. The hero outfit and the light from the upper left are the same in every sheet.
- Coverage: still complete. Every pose cue has a figure under the name stage.json uses. All 26 figures are used, no flips are needed, and nothing held is drawn twice (c2 and d1 have no ball part, d2 has no teddy part, kneel_search's block is the hero's own).
- Only drawn sheets and text are attached. No photo, no name.

## FIX
(none)

## NOTES (not blocking the prompts)

Prompts / workflow:
- Cover: the Attach line still lists only girl.png and lulu.png. Attaching kit/room.png and kit/props.png as well (made by then) makes the cover's room and toys match the kit. The prompt already says what to do with them. If gen_image.py supports `attach` for `pictures` the way it does for sheets, add it there.
- hero_b: with kit/hero_a.png attached, Gemini may copy hero_a's poses or grid. Check that the six hero_b figures are the new poses.
- The room lamp is left of centre (x ≈ 0.32), so figures on the bed (bed_sit, asleep, the teddy on the pillow) really get their light from the upper right. Soft enough to ignore; use `tint` if they look pasted on.
- The blanket lump's lavender may not match the room's blanket exactly. Compare after cutting.
- The outline's pose list (sit_play with a block, kneel_happy hands clasped, hug_teddy standing, asleep arms tucked) differs from the sheet text. The sheets are the source of truth; update the outline for the record.
- tummy_reach has "tongue tip out with effort" while the narration says she is tired. Optionally add "a little tired".

Stage / cue numbers (still open, to tune once kit/room.png exists):
- Move targets in story.json come from the outline's spot table, which gives **centres**. stage.py moves a part's **pivot**, which is the feet for the hero, the props and the ball. With the current numbers:
  - a1: hero → [0.40, 0.76] puts her feet at the bed front.
  - a1: blocks → [0.80, 0.66] leaves the pile floating above the box rim, visible, not behind the box front (should be about [0.80, 0.86]).
  - b3: blocks → [0.60, 0.77] slides them far back instead of "a little right" (should be about [0.60, 0.94]).
  - e1: ball → [0.78, 0.58] sits above the box.

  Re-derive every `move` "to" in feet coordinates.
- Jumps between nodes: e1 ends with the hero at [0.27, 0.80] and the ball at [0.17, 0.82], but stage e2 starts them at [0.48, 0.98] and [0.30, 0.89]. At [0.48, 0.98] the hero is also to the right of Lulu at air_bed [0.36, 0.42], so Lulu's `talk` (looking left) would face away from her. s2 ends Lulu at [0.56, 0.45], c1 has [0.60, 0.48]. Start each node where the previous one ended.
- s1 and b1 put the teddy at the same spot behind the blocks ([0.50, 0.90] / [0.53, 0.94]). In b1/b2 only one ear should show, so "where is Teddy?" works; in s1 its head and an arm show.
- end_asleep: the hero's head (ambient_origin [0.25, 0.50]) is right of the room's pillow (about x 0.08–0.20). Place her head on the pillow and the teddy beside it.
- The outline puts the blanket lump in b2/b3 (messy empty bed); stage.json shows a made bed. Either is fine.
- a1: kneel_search still holds a red block while the pile slides into the box. That's fine: she is carrying one in.
