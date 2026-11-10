# tidy_toys: outline (v2 port of v1, first "kit" story)

Port of v1 `../bedtime_story/docs/stories/tidy_toys/` (plot approved by the parent). Plot, beats, both choices, option ids, node ids, graph, `offer_rewind_to`, ambient and moral are **kept as in v1**. The Vietnamese text is v1's `story.json` word for word, except where v2's `{name}` rule forces a fix (the name is the first or last word of the whole line, once per line; elsewhere "bé" / "the little one") and one beat that the kit cannot show (d2's lid closing moves to the end of d1, see Kit notes). Each node says **unchanged from v1** or **changed**.

**First kit story.** No picture per scene: the app composes every scene from one empty bedroom background + cut-out hero poses + cut-out Lulu poses + cut-out props, and moves them by code (`hop`, `wiggle`, `pulse`, `move` to a spot, `pose` switch). Each scene below gives a layout (who/what stands where, starting pose / state) and the moves on cue words. Scene ids (`s1_toys`, …) are kept from v1 as composition names; no `s1_toys.webp` is drawn.

- **Title:** vi `{name} và những bạn đồ chơi về nhà` (unchanged) · en `{name} Helps the Toys Go Home`
- **Theme:** tidiness
- **Hero:** girl (`tool/image_refs/girl.png`). Text never gives a gender: "bé" / "the little one".
- **Moral:** vi: Cất từng bạn đồ chơi nhẹ nhàng về nhà, mình tìm lại dễ ơi là dễ và ngủ thật ngon. · en: When every toy goes gently back to its home, we find what we love easily and sleep with a light, happy heart.
- **Cast:** the hero, Lulu, and **Gấu Bông / Teddy**, a small round teddy bear (a toy: never talks, only lies, sits, hops, gets hugged). No grown-ups.
- **Not repeated:** `prepare_stuff_vacation` (packing only what you need, folding) and `clock_time` (reading the clock, getting up / going to bed on time). This story is about *where* toys go and *how*: every toy has a home, put it there gently. It shares the vacation story's room and its blocks and ball (same kit look), not its plot.

## Choices

### c1: Lulu says the toys are sleepy
Question: vi `{name} ơi, đồ chơi buồn ngủ rồi. Mình làm gì nhỉ?` · en `{name}, the toys are sleepy. What should we do?`
- **Kind (`tidy`)**: vi `Cất đồ chơi về nhà` · en `Put the toys back home`. The hero sits Gấu Bông on the bed, then puts the blocks in the toy box with Lulu (a1).
- **Learn (`leave`)**: vi `Để đó, mai cất` · en `Leave them for tomorrow`. The hero goes straight to bed and wants to cuddle Gấu Bông, but it's lost among the toys (b1). The hero climbs down and searches and searches, getting sleepy (b2). Lulu glows on the block pile: there's Gấu Bông (b3). Lulu: vi **"Mỗi bạn đồ chơi đều có một ngôi nhà. Cất về nhà rồi, mình tìm bạn ấy dễ ơi là dễ."** · en **"Every toy has a home. When toys are home, they're easy to find."** → rewind offer to c1, then a1.

### c2: the ball is the last toy
Question: vi `{name} cho quả bóng vào hộp thế nào?` · en `{name}, how does the ball go into the box?`
- **Kind (`gentle`)**: vi `Đặt nhẹ vào hộp` · en `Put it in gently`. Plop, the ball is home; the lid closes, the floor is clean (d1).
- **Learn (`toss`)**: vi `Ném vèo vào hộp` · en `Throw it in, whoosh!`. The ball hits the box's edge, bounces out and rolls far under the bed; the hero crawls and reaches and reaches, arm tired (e1). Lulu glows under the bed and the ball rolls out (e2). Lulu: vi **"Mình đặt nhẹ nhàng nhé. Bạn bóng sẽ về nhà ngay, không bị lạc đường."** · en **"Let's put it in gently. Then the ball goes right home and never gets lost."** → rewind offer to c2, then d1.

## Node graph (unchanged from v1)

| id | type | next / options | offer_rewind_to | ambient |
|---|---|---|---|---|
| s1 | scene | s2 | | stars |
| s2 | scene | c1 | | sparkles |
| c1 | choice | tidy → a1 (kind), leave → b1 (learn) | | sparkles |
| b1 | scene | b2 | | stars |
| b2 | scene | b3 | | stars |
| b3 | scene | a1 | c1 | sparkles |
| a1 | scene | c2 | | stars |
| c2 | choice | gentle → d1 (kind), toss → e1 (learn) | | stars |
| e1 | scene | e2 | | stars |
| e2 | scene | d1 | c2 | sparkles |
| d1 | scene | d2 | | stars |
| d2 | scene | end | | sparkles |
| end | ending (sticker `images/sticker.webp`) | | | zzz, `ambient_origin` at the sleeping head (about [0.25, 0.50]; take it from the hero's `asleep` placement) |

13 nodes. Paths: kind-kind = 8 nodes, learn-learn = 13. Stickers: up to 2.

Continuity:
- Gấu Bông is on the floor in s1/s2 (half behind the block pile) and deeper behind it in b1/b2 (only one ear peeks out). From a1 on, on both paths, it sits on the bed; in d2 it is in the hero's arms; in end it lies next to the hero's head.
- Ball: on the rug until a1, in the hero's hands in c2 and at the start of d1 (the pick-up happens between a1 and c2), inside the closed box from d1 on.
- Lulu is absent in s1, b1, b2, e1 (as in v1); in b3 and e2 she flies in from the window on her first cue.

## Spots (same camera in every scene)

Approximate centres on the 1600×1200 canvas (x, y from 0 to 1); confirm on the final background.

| spot | where | about |
|---|---|---|
| `on_bed` | on the bed, middle of its length (sitting up or lying, head on the pillow) | head ≈ [0.25, 0.50] |
| `by_bed` | floor in front of the bed's side, left | [0.30, 0.78] |
| `under_bed` | the dark gap under the bed, near its foot (front-left) | [0.17, 0.82] |
| `rug_left` / `rug_mid` / `rug_right` | on the round cream rug | [0.40, 0.76] / [0.52, 0.77] / [0.63, 0.75] |
| `box` | toy box spot, on the floor right, just left of the door | [0.80, 0.66] |
| `by_box` | just left of the toy box, on the rug's right edge | [0.68, 0.72] |
| `window` | in the air in front of the window | [0.50, 0.28] |
| `air_mid` | in the air above the rug | [0.56, 0.45] |
| `air_bed` | in the air beside the bed, by the pillow | [0.36, 0.42] |

Draw order (back to front), the same in every scene: background → teddy → blocks → hero → toy box → blanket lump → ball → Lulu. This is what hides things without a "hide" action: the teddy behind the block pile (b1, b2), the blocks behind the box front when they slide in (a1), the hero's hands behind the box rim (d1), the hero's legs/body under the blanket lump (b1, end).

## Scenes

Hero outfit in every scene: soft mint-green pajamas with tiny white stars (same as the vacation story, so the hero poses can be reused by later kit stories). Cue suggestions are for the writer; parts: `hero`, `lulu`, `teddy`, `blocks`, `ball`, `toybox`, `blanket`. Every part is a cut-out, so no `hotspots.json` boxes are needed except bursts (d2 hearts).

### s1 — `s1_toys` — stars — **changed**
- **Lời kể (vi):** {name} ngồi chơi trong phòng. Trời tối rồi. Khối gỗ nằm chỗ này, quả bóng nằm chỗ kia. Gấu Bông cũng nằm dưới sàn. Còn hộp đồ chơi thì trống trơn.
  - changed: `Buổi tối, {name} ngồi chơi trong phòng.` → `{name} ngồi chơi trong phòng. Trời tối rồi.` (name to the start of the line)
- **Narration (en):** {name} is playing in the bedroom. It's dark outside now. Blocks over here, the ball over there. Teddy is on the floor too. And the toy box is empty.
- **Layout:** hero `sit_play` at `rug_left`. Blocks `scattered` at `rug_mid`; teddy `lying` just behind the blocks (head and one arm show); ball on the rug in front-left of the hero, apart from the blocks; toy box `open_empty` at `box`. No Lulu.
- **Moves:** vi `Khối gỗ` → blocks wiggle, `quả bóng` → ball hop, `Gấu Bông` → teddy hop, `hộp đồ chơi` → toybox wiggle · en `Blocks`, `ball`, `Teddy`, `toy box`.

### s2 — `s2_lulu` — sparkles — **changed**
- **Lời kể (vi):** Vù! Lulu bay vào qua cửa sổ, sáng lấp lánh. "Các bạn đồ chơi buồn ngủ rồi. Các bạn ấy muốn về nhà đấy, {name}."
  - changed: `"{name} ơi, các bạn đồ chơi…` (name mid-line) → name moved to the end of Lulu's last sentence.
- **Narration (en):** Whoosh! Lulu flies in through the window, all sparkly. "The toys are sleepy now. They want to go home, {name}."
- **Layout:** as s1, plus Lulu `float` at `window`. Hero starts `sit_play`.
- **Moves:** `Vù` → lulu move to `air_mid`; `Lulu` → hero pose `sit_look_up`; `Các bạn` (quote) → lulu pose `talk`; `đồ chơi` → blocks wiggle; `về nhà` → toybox wiggle · en `Whoosh`, `Lulu`, `The toys`, `toys`, `home`.

### c1 — reuses `s2_lulu` (end state) — sparkles — **changed**
- **Câu hỏi (vi):** {name} ơi, đồ chơi buồn ngủ rồi. Mình làm gì nhỉ?
  - changed: `Đồ chơi buồn ngủ rồi. {name} sẽ làm gì?` (name mid-line) → name first.
- **Question (en):** {name}, the toys are sleepy. What should we do?
- **Layout:** s2's end: hero `sit_look_up` at `rug_left`, Lulu `talk` at `air_mid` (node `poses`), props as s1.
- Options: `tidy` (kind) vi `Cất đồ chơi về nhà` · en `Put the toys back home`, icon `icon_toybox.webp`; `leave` (learn) vi `Để đó, mai cất` · en `Leave them for tomorrow`, icon `icon_mess.webp`. Labels unchanged from v1.

### b1 — `b1_where` — stars — **unchanged from v1**
- **Lời kể (vi):** {name} leo lên giường, ngồi trong chăn. Ơ, Gấu Bông đâu rồi nhỉ? Bé muốn ôm Gấu Bông ngủ cơ. Dưới sàn toàn khối gỗ với bóng.
- **Narration (en):** {name} climbs into bed and sits under the blanket. Oh, where is Teddy? The little one wants to hug Teddy to sleep. The floor is covered in blocks and the ball.
- **Layout:** hero `bed_sit` at `on_bed`, blanket lump over the legs. Blocks `scattered` at `rug_mid`; teddy `lying` tucked right behind the blocks so only one ear peeks over them; ball on the rug; toy box `open_empty` at `box`. No Lulu.
- **Moves:** `leo` → hero hop; `Gấu Bông` (1st) → teddy wiggle (the ear wiggles: a hint for the child); `khối gỗ` → blocks wiggle; `bóng` → ball hop · en `climbs`, `Teddy`, `blocks`, `ball`.

### b2 — `b2_search` — stars — **unchanged from v1**
- **Lời kể (vi):** {name} trèo xuống, tìm mãi, tìm mãi. Lật khối này, lật khối kia, chẳng thấy đâu. Oáp! Bé mỏi quá, buồn ngủ díp cả mắt.
- **Narration (en):** {name} climbs down and looks and looks. Under this block? Under that one? Not there! Yaaawn! The little one is so tired, eyes so heavy.
- **Layout:** hero `kneel_search` at `rug_left` (front side of the blocks, away from the teddy's ear). Blanket lump alone on the bed (a messy, empty blanket). Blocks, teddy (ear only), ball, toy box `open_empty` as b1. No Lulu.
- **Moves:** `trèo xuống` → hero hop; `Lật` → blocks wiggle; `lật` → blocks wiggle; `Oáp` → hero pose `kneel_yawn` · en `climbs`, `this block`, `that one`, `Yaaawn`.

### b3 — `b3_found` — sparkles — **unchanged from v1 (one vi sentence split optional)** (offer_rewind_to c1)
- **Lời kể (vi):** Lulu tỏa sáng, soi vào đống khối gỗ. A, Gấu Bông đây rồi! Lulu nói: "Mỗi bạn đồ chơi đều có một ngôi nhà. Cất về nhà rồi, mình tìm bạn ấy dễ ơi là dễ."
- **Narration (en):** Lulu glows bright and shines on the blocks. Oh, there's Teddy! Lulu says, "Every toy has a home. When toys are home, they're easy to find."
- **Layout:** as b2 end: hero `kneel_yawn` at `rug_left`, blanket lump on the bed, blocks + hidden teddy at `rug_mid`, ball, toy box `open_empty`. Lulu `float` at `window`.
- **Moves:** `Lulu` (1st) → lulu move to `air_mid`, just above the blocks; `tỏa sáng` → lulu pose `glow`; `soi` → blocks move a little right (uncovering the teddy); `Gấu Bông` → teddy hop; `đây rồi` → hero pose `kneel_happy`; `nói` → lulu pose `talk` · en `Lulu`, `glows`, `shines`, `Teddy`, `there's`, `says`.

### a1 — `a1_toybox` — stars — **unchanged from v1**
- **Lời kể (vi):** {name} đặt Gấu Bông ngồi lên giường. Rồi bé cùng Lulu cất khối gỗ vào hộp. Lạch cạch, lạch cạch! Giờ chỉ còn quả bóng thôi.
- **Narration (en):** {name} sits Teddy up on the bed. Then, with Lulu, the blocks go into the box. Clatter, clatter! Now there's only the ball left.
- **Layout (same start on both paths):** hero `bend_place` at `by_bed`, hands just letting go of the teddy; teddy `sitting` on the bed edge in front of her hands; blanket lump not shown (bed made). Blocks `scattered` at `rug_mid`; ball on the rug at `rug_right`; toy box `open_empty` at `box`. Lulu `float` at `air_mid`.
- **Moves:** `Gấu Bông` → teddy hop; `cất` → hero pose `kneel_search` + hero move to `rug_left` (short, slow shuffle); `Lulu` → lulu pose `point` (toward the box); `Lạch cạch` → blocks move to `box` (they vanish behind the box front); `lạch cạch` → toybox pose `open_full` + wiggle; `quả bóng` → ball hop · en `Teddy`, `Then`, `Lulu`, `Clatter`, `clatter`, `ball`.

### c2 — `a1_toybox` end state, ball now in hand — stars — **unchanged from v1**
- **Câu hỏi (vi):** {name} cho quả bóng vào hộp thế nào?
- **Question (en):** {name}, how does the ball go into the box?
- **Layout:** a1's end with one change made between the nodes: the hero has picked up the ball. Hero `stand_ball` at `by_box`; no ball prop. Toy box `open_full`, teddy `sitting` on the bed, Lulu `float` at `air_mid` (node `poses`: hero `stand_ball`, lulu `float`).
- Options: `gentle` (kind) vi `Đặt nhẹ vào hộp` · en `Put it in gently`, icon `icon_gentle.webp`; `toss` (learn) vi `Ném vèo vào hộp` · en `Throw it in, whoosh!`, icon `icon_toss.webp`. Labels unchanged from v1.

### e1 — `e1_roll` — stars — **changed**
- **Lời kể (vi):** Vèo! Quả bóng đập vào thành hộp, nảy ra ngoài. Bóng lăn tít vào gầm giường. Bé bò xuống, với mãi, với mãi. Tối quá, bé mỏi tay rồi.
  - changed: `{name} bò xuống,…` (name mid-line) → `Bé bò xuống,…`
- **Narration (en):** Whoosh! The ball hits the edge of the box and bounces out. It rolls far away, under the bed. The little one crawls down and reaches and reaches. It's so dark, and the little arm is tired.
- **Layout:** hero `throw` at `rug_right` (facing the box, hands empty, just after the throw); ball in the air right in front of her hand; toy box `open_full`; teddy `sitting` on the bed. No Lulu.
- **Moves:** `Vèo` → ball move to the box rim; `nảy` → ball hop; `lăn` → ball move to `under_bed` (rolls across the front of the rug); `bò` → hero pose `tummy_reach`; `xuống` → hero move to just right of `under_bed`, arm toward the gap; `với mãi` → hero wiggle (both times) · en `Whoosh`, `bounces`, `rolls`, `crawls`, `down`, `reaches`.

### e2 — `e2_glow` — sparkles — **unchanged from v1, vi Lulu line split in two** (offer_rewind_to c2)
- **Lời kể (vi):** Lulu tỏa sáng, soi vào gầm giường. A, quả bóng kia rồi! Lulu nói: "Mình đặt nhẹ nhàng nhé. Bạn bóng sẽ về nhà ngay, không bị lạc đường."
  - changed: v1's one 16-word sentence `"Mình đặt nhẹ nhàng, bạn bóng sẽ…"` → `"Mình đặt nhẹ nhàng nhé. Bạn bóng sẽ…"` (≤ 12 words per sentence).
- **Narration (en):** Lulu glows bright and shines under the bed. Oh, there's the ball! Lulu says, "Let's put it in gently. Then the ball goes right home and never gets lost."
- **Layout:** e1's end: hero `tummy_reach` in front of `under_bed`; ball in `under_bed`; toy box `open_full`; teddy `sitting` on the bed. Lulu `float` at `window`.
- **Moves:** `Lulu` (1st) → lulu move to `air_bed` (low, beside the hero, not touching); `tỏa sáng` → lulu pose `glow`; `quả bóng` → ball move out onto the rug next to the hero + hop; `A` → hero pose `kneel_happy`; `nói` → lulu pose `talk` · en `Lulu`, `glows`, `ball`, `Oh`, `says`.

### d1 — `d1_gentle` — stars — **changed**
- **Lời kể (vi):** {name} cầm bóng thật nhẹ, đặt vào hộp. Bộp! Bạn bóng về nhà rồi. Bé đóng nắp hộp lại. Cạch! Sàn nhà sạch tinh tươm.
  - changed: `Bé đóng nắp hộp lại. Cạch!` moved here from the start of v1's d2 (see Kit notes).
- **Narration (en):** {name} holds the ball softly and puts it in the box. Plop! The ball is home. The little one closes the lid. Click! The floor is all clean and tidy.
- **Layout (same start on both paths):** hero `stand_ball` at `by_box`; toy box `open_full`; teddy `sitting` on the bed; floor clean (no blocks, no ball prop). Lulu `float` at `air_mid`.
- **Moves:** `đặt` → hero pose `bend_place` (hands go down behind the box rim); `Bộp` → toybox wiggle; `về nhà` → lulu pose `clap`; `đóng nắp` → toybox pose `closed`; `Cạch` → toybox hop · en `puts`, `Plop`, `home`, `closes`, `Click`.

### d2 — `d2_tidy` — sparkles — **changed**
- **Lời kể (vi):** {name} ôm Gấu Bông thật chặt. Các bạn đồ chơi ngủ ngon trong nhà. Lulu khen: "Phòng gọn gàng quá, bạn giỏi lắm!"
  - changed: v1 `Cạch! {name} đóng nắp hộp lại.` (name mid-line) moved to d1; the line now opens with the hug.
- **Narration (en):** {name} gives Teddy a big, tight hug. All the toys are asleep in their home. Lulu says, "What a tidy room! You did so well!"
- **Layout:** hero `hug_teddy` at `rug_left` (the teddy is in her arms: no teddy prop); toy box `closed` at `box`; floor clean. Lulu `float` at `air_mid`, not touching. Hero hotspot burst `hearts`.
- **Moves:** `ôm` → hero pulse; `ngủ ngon` → toybox pulse; `khen` → lulu pose `clap` · en `hug`, `asleep`, `says`.

### end — `end_asleep` — zzz — **changed**
- **Lời kể (vi):** Bé chui vào chăn, Gấu Bông nằm ngay bên cạnh. Đồ chơi đã về nhà, lòng bé vui sướng. Lulu thì thầm: "Ngủ ngon nhé, {name}."
  - changed: v1 had the name twice; the first `{name}` → `Bé`, the good-night keeps the name as the last word of the line.
- **Narration (en):** The little one snuggles under the blanket, with Teddy close by. The toys are home, and the little heart is happy. Lulu whispers, "Good night, {name}."
- **Layout:** hero `asleep` at `on_bed`, head on the pillow, blanket lump over the body; teddy `lying` on the pillow beside her head; toy box `closed` at `box`; floor clean. Lulu `float` at `air_bed`.
- **Ambient:** `zzz`, `ambient_origin` at the hero's head (≈ [0.25, 0.50]).
- **Moves:** `Gấu Bông` → teddy pulse; `về nhà` → toybox pulse; `thì thầm` → lulu pose `whisper` · en `Teddy`, `home`, `whispers`.

### cover — `cover.webp` (800×600)
Kit layout rendered once (or one AI picture of the same layout): hero `kneel_happy` at `rug_mid`, toy box `open_full` at `box`, teddy `sitting` on the bed, Lulu `float` at `air_mid`, night window.

## Setting (the kit background `bg_bedroom`)

The same cozy kid bedroom at night as `prepare_stuff_vacation`, **empty**: no people, no Lulu, no toys, no suitcase. Soft warm peach walls, wooden floor, warm lamp light, absolutely no text, letters or numbers.
- **Left wall:** low wooden bed along the wall, pillow end at the back, lavender blanket lying flat, soft white pillow. The bed stands on short legs with a clearly visible dark gap under its room-facing side, tall enough for the ball.
- **Back wall:** window in the middle (dark blue sky, crescent moon, a few stars); between the bed and the window a small warm glowing lamp on a little wooden shelf.
- **Floor:** soft round cream rug in the middle; plain free floor at the right, just left of the door (toy box spot).
- **Right wall:** rounded light-wood door.
- Bottom-right corner: plain floor, nothing important (Gemini watermark).

Kit pieces (cut-outs, soft 3D, lit like the background, each on its own; one size per spot):
- **Toy box:** a rounded wooden toy chest painted soft sky-blue, a yellow star on the front, lid hinged at the back; about the hero's waist height, wider than the block pile. States: `open_empty` (lid tilted up behind, inside empty), `open_full` (lid up, colourful blocks peeking over the rim), `closed` (lid down).
- **Blocks:** a few colourful wooden blocks (red, yellow, blue, green), the same as the vacation story's. State: `scattered` = a loose low cluster of five blocks lying together, one leaning on another, narrower and lower than the toy box front, big enough to hide a lying teddy except one ear.
- **Ball:** a small red-and-white ball (same as the vacation story's). One state.
- **Teddy (Gấu Bông):** a small round light-brown teddy bear, round ears, peach tummy and muzzle, little smile, about the size of the hero's forearm. States: `lying` (on its back, arms out), `sitting` (sitting up, legs forward).
- **Blanket lump:** a rumpled mound of the lavender blanket that sits on the bed and covers the hero's legs (`bed_sit`) or body up to the chest (`asleep`); alone it reads as a messy blanket (b2).
- **Hero:** the girl sheet in mint-green pajamas with white stars, barefoot; 12 poses below.
- **Lulu:** the Lulu sheet, about the size of a cat; 6 poses below.

## Choice icons

Not from the room: one clear object on a plain soft background, no hero (can be rendered from the kit props or drawn by AI).

| choice | option | kind | icon | shows |
|---|---|---|---|---|
| c1 | tidy | kind | `icon_toybox.webp` | The sky-blue toy box with the yellow star, open, colourful blocks and the red-and-white ball peeking over the rim. |
| c1 | leave | learn | `icon_mess.webp` | Colourful blocks and the red-and-white ball scattered on a strip of wooden floor. |
| c2 | gentle | kind | `icon_gentle.webp` | The red-and-white ball resting softly inside the open toy box, a small pink heart above. |
| c2 | toss | learn | `icon_toss.webp` | The red-and-white ball flying in a high arc, soft motion lines behind it. |

## Sticker

`sticker.webp`: the closed sky-blue toy box with the yellow star, a sleepy happy face on its front, Gấu Bông sitting on the lid; round sticker with a white border. No hero.

## SVG overlays

None. Nothing needs exact counts, numbers or text (the narration never counts the blocks).

## Kit notes

1. **d2's "close the lid" moved to d1 (only beat change).** v1 d2 had the hero close the lid at the box (right) and then hug Gấu Bông, which sits on the bed (left). In one composed scene that would need the teddy prop to vanish when it jumps into her arms, and the kit has no hide/show. So d1 ends with `Bé đóng nắp hộp lại. Cạch!` (hero is already at the box) and d2 starts with the hero hugging the teddy (teddy prop left out of d2). Same story, same order of events.
2. **No part appears or disappears inside a scene.** Changes of "who holds what" happen between nodes: the ball goes from the rug to the hero's hands between a1 and c2 (like v1, where c2's picture already showed it), and e1 starts just after the throw with the ball in the air. Things that leave mid-scene go *behind* something, using the fixed draw order: blocks slide behind the toy box front (a1), the hero's hands go behind the box rim (d1). If the kit can't keep a per-part draw order, the smallest fix is an empty pose `gone` for `blocks`.
3. **"Under the bed":** the bed is part of the background, so the ball can't go behind its frame. The background must show a dark gap under the bed; the ball slides into that gap (drawn on top of it). Lulu's light beam from v1 e2 is just her `glow` pose (bigger halo), no separate beam piece.
4. **Teddy hidden in the pile (b1, b2):** done by draw order (teddy behind blocks) and placement, not a new prop. b3 reveals it by sliding the blocks a little aside.
5. **Hero sliding across the room** (a1 `by_bed` → `rug_left`; e1 `rug_right` → `under_bed`): switch the pose first (kneeling / on the tummy), then a short slow move, so it reads as shuffling / crawling, not gliding. e1's move is the longest; if it looks odd, start e1's hero at `rug_mid` instead.
6. **Dropped from v1 pictures:** b2's "room dim" (one background, one light) and d2's "small hearts" as drawn art (now a tap burst `hearts` on the hero).
7. **Sizes:** each spot has one scale per piece (the hero is a little smaller at the back spots than at the front); `by_bed` and `under_bed` are front-left, `box`/`by_box` front-right.

## Pose and prop lists

**Hero poses (12):**
1. `sit_play` — sits cross-legged, one wooden block held up in one hand, happy, playing (s1, s2 start)
2. `sit_look_up` — sits cross-legged, hands on the knees, looking up, surprised happy face (s2, c1)
3. `bed_sit` — sits up in bed, legs forward (under the blanket lump), palms up at the sides, puzzled "where is it?" face, no tears (b1)
4. `kneel_search` — kneels, leaning forward, lifting one block in one hand, peering down (b2, a1)
5. `kneel_yawn` — kneels sitting back on the heels, big yawn, one fist rubbing an eye (b2, b3 start)
6. `kneel_happy` — kneels upright, hands clasped at the chest, happy relieved smile (b3, e2, cover)
7. `bend_place` — stands bending forward, both arms down, open hands low, just setting something down gently (a1, d1)
8. `stand_ball` — stands holding the red-and-white ball with both hands at the chest, smiling (c2, d1 start)
9. `throw` — stands, one arm swung forward high just after a throw, hands empty, one foot forward (e1 start)
10. `tummy_reach` — lies on the tummy, one arm stretched forward reaching, tired face (e1, e2 start)
11. `hug_teddy` — stands hugging Gấu Bông tight to the chest with both arms, eyes closed, happy (d2)
12. `asleep` — lies with the head on the pillow, eyes closed, small smile, arms tucked (end; body under the blanket lump)

**Lulu poses (6):**
1. `float` — floats, paws soft at the sides, gentle smile (s2, b3, a1, c2, e2, d1, d2, end start)
2. `talk` — one paw raised gently, mouth open, kind face (s2, c1, b3, e2)
3. `glow` — paws open wide, eyes closed, much brighter glow with a big soft halo (b3, e2)
4. `point` — points one paw toward the toy box (a1)
5. `clap` — claps the paws in front of the chest, laughing (d1, d2)
6. `whisper` — leans forward, one paw by the mouth, sleepy soft eyes (end)

**Props and states:**
- `toybox`: `open_empty` (s1–b3, a1 start), `open_full` (a1 end, c2, e1, e2, d1 start, cover), `closed` (d1 end, d2, end)
- `blocks`: `scattered` (s1–b3, a1 start); after a1 inside the box (shown by `open_full`)
- `ball`: one state; on the rug (s1–a1), in the air / at the box rim / under the bed / back on the rug (e1, e2); in the hero's hands = part of `stand_ball` (c2, d1)
- `teddy`: `lying` (s1–b3, end), `sitting` (a1–d1, on the bed); in the hero's arms = part of `hug_teddy` (d2)
- `blanket` (lump): one state; over the legs (b1), alone on the bed (b2, b3), over the body (end)

## Summary of vi changes vs v1

- Unchanged: title, b1, b2, b3, a1, c2 (question), all four option labels.
- Changed: s1, s2, c1, e1, e2 (Lulu's line split), d1, d2, end.
- All English lines are new.
