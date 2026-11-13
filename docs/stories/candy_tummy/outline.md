# candy_tummy: outline (new v2 story, kit)

New story (not a v1 port). Kit art (`docs/kit.md`): no picture per scene. The app builds every scene from tidy_toys' empty night bedroom, cut-out hero / Lulu poses and cut-out props, and moves them on words. Each scene is a **layout** (who / what stands where, starting pose or state) plus **moves on cue words**. Narration lines are drafts for `story-writer` (vi first, then en).

- **Title:** vi `{name} và hũ kẹo cầu vồng` · en `{name} and the Rainbow Candy Jar`
- **Theme:** treats
- **Hero:** girl (`tool/image_refs/girl.png`). The text never gives a gender: "bé" / "the little one".
- **Moral:** vi: Kẹo ngọt một viên là đủ vui, phần còn lại để dành; bụng nhỏ cần đồ ăn thật như canh rau, và nghỉ ngơi. · en: One candy is enough for fun, and the rest can wait; a little tummy needs real food like veggie soup, and rest.
- **Cast:** the hero and Lulu. No extra character: the candy jar and the soup bowl are plain objects with no face (only the sticker gives the bowl a face). No grown-ups.
- **Not repeated** (checker's AVOID list, v1 `eat_veggies`):
  - No "try a veg bite?" choice: both choices are about the **candy** (how many; where the jar sleeps). Vegetables are a gentle food beat (n1), never an option, and refusing them is never shown.
  - No chew-slowly / big-spoonful choice, no full cheeks, no carrots or broccoli (the soup is a soft-cooked pumpkin soup with a few green peas), no dinner-table opening (the story opens with Lulu's gift on the rug), no Lulu nibbling as a role model.
  - Consequence 1 is a mild "grumpy tummy" ache from too much candy: no "ọc ọc", no stone metaphor (tell_truth), and Lulu does **not** sit close to comfort: she stays in the air, glows and points the way (rest a bit, then warm soup; the tummy gets better little by little). Her line is new ("one candy is enough for fun; too much makes a tummy grumpy").
  - Consequence 2 (candy jar in bed: candies spill in the blanket, lumpy, can't get comfy) shares nothing with tidy_toys' lost teddy / ball. No teeth or brushing beat (that is tell_truth's c2).
- **Shared with other stories:** only kit pieces (bedroom, girl sheets, `lulu_a`, the blanket lump, the bedside table). New: candy jar, soup bowl, four candy/soup poses.

## Choices

### c1: how many rainbow candies?
Question: vi `{name} ơi, mình ăn mấy viên kẹo nhỉ?` · en `{name}, how many candies should we eat?`
- **Kind (`one`)**: vi `Một viên thôi` · en `Just one`. The hero picks one red candy: yum, so sweet; one is just right. The lid goes back on, the rest saved for tomorrow (a1).
- **Learn (`lots`)**: vi `Thật nhiều viên` · en `Lots and lots`. One candy, then another, green, yellow, purple… The little tummy starts to ache a bit, grumpy from too much candy, and a small tear rolls down (b1). The hero puts the lid back on; Lulu glows softly from the air, soothes the tears first, then gives the lesson and a gentle, gradual recovery (b2): vi **"Không sao đâu, nước mắt khô ngay thôi. Một viên kẹo là đủ vui. Nhiều quá, bụng nhỏ nhăn nhó đấy. Mình nghỉ chút, rồi ăn canh rau ấm nhé. Bụng sẽ đỡ dần."** · en **"It's okay. The tears will dry soon. One candy is enough for fun. Too much makes a tummy grumpy. Let's rest, then have warm veggie soup. Little by little, you'll feel better."** → rewind offer to c1, then n1 (the warm, gentle soup; the tummy is fully calm only at bedtime, in end).

### c2: where does the candy jar sleep tonight?
Question: vi `{name} ơi, hũ kẹo ngủ ở đâu đêm nay?` · en `{name}, where will the candy jar sleep tonight?`
- **Kind (`table`)**: vi `Trên bàn nhỏ, mai ăn` · en `On the little table, for tomorrow`. The hero sets the closed jar on the bedside table, Lulu claps "You saved them for tomorrow!", big yawn (d1).
- **Learn (`bed`)**: vi `Ngủ chung giường với bé` · en `In bed with me`. The hero takes the jar into bed for one more candy; the jar tips, candies roll all over the blanket, lumpy, bumpy, can't get comfy (e1). Lulu glows, the candies hop back into the jar, the lid clicks shut (e2): vi **"Giường là chỗ để ngủ. Kẹo cũng cần chỗ ngủ riêng, trên bàn nhỏ nhé."** · en **"Beds are for sleeping. Candy needs its own sleepy spot, on the little table."** → rewind offer to c2, then d1.

## Node graph

| id | type | next / options | offer_rewind_to | ambient |
|---|---|---|---|---|
| s1 | scene | s2 | | sparkles |
| s2 | scene | c1 | | sparkles |
| c1 | choice | one → a1 (kind), lots → b1 (learn) | | sparkles |
| a1 | scene | n1 | | stars |
| b1 | scene | b2 | | stars |
| b2 | scene | n1 | c1 | sparkles |
| n1 | scene | c2 | | stars |
| c2 | choice | table → d1 (kind), bed → e1 (learn) | | stars |
| e1 | scene | e2 | | stars |
| e2 | scene | d1 | c2 | sparkles |
| d1 | scene | end | | stars |
| end | ending (sticker `images/sticker.webp`) | | | zzz, `ambient_origin` at the sleeping head (≈ [0.18, 0.44], girl `hero_b/asleep` at `in_bed` as in keep_promise; take it from the stage run) |

12 nodes. Paths: kind-kind = 8 nodes, learn-learn = 11. Stickers: up to 2. Start `s1`.

**Why b2 goes to n1, not a1:** a1 is "eat one candy, lid on". After eating lots, that would contradict. n1 (the soup) is on the kind path's trunk, so the learn path continues into the kind path at n1, where the warm soup Lulu suggested (after a little rest) arrives. A child who takes the rewind also meets the soup (via a1 → n1), so **every path shows the veg soup**. n1 is neutral on both paths (warm, gentle, cozy tummy; never "the ache is gone"): soup is good food, not medicine. The tummy is fully calm only in end, after sleep.

**Name lines** (first or last word of the whole line, once): s1, a1, b1, e1, d1 start with `{name}`; c1 and c2 start with it; end ends with it. s2, b2, n1, e2 have no name ("bé" / "the little one").

**Continuity**
- **Candy jar** (`jar`):
  - s1: `jar_closed` floats in beside Lulu (at `window_low`) and lands on the rug at `jar_spot`
  - s2: swaps to `jar_open` (Lulu opens it)
  - a1 / b1: `jar_open` at `jar_spot`; both a1 and b2 end with `jar_closed`
  - n1, c2: `jar_closed` at `jar_spot`
  - e1: `jar_open` on the blanket at `bed_jar` (carried to bed between c2 and e1) → `jar_tipped`; e2 → `jar_closed` (still at `bed_jar`)
  - d1, end: `jar_closed` at `table_top` (picked up between nodes; d1 starts with the hero's hands at it)
  - The jar is opaque: how many candies are left is never shown (Kit notes 3).
- **Soup bowl** (`soup`): only in n1 and c2, at `bowl_spot` in front of the hero's lap. `soup_full` at the start of n1 (Lulu "brings it out": it is in place when n1 starts), `soup_empty` from "Hết veo" on. Gone from d1 / e1 on (between nodes).
- **Bedside table** (`table`): at `table` in every scene, top empty until d1.
- **Lulu:** at `window` at the start of s1, then `air_mid` from s1 to d1 (a1, b1, b2, n1, c2, d1). Absent in e1; back from `window` to `air_bed` in e2. `air_bed` in end.
- **Hero:** sits at `rug_left` from s1 to c2 (sit / kneel swaps at the same point, no slides); in bed at `on_bed` in e1 / e2; standing at `by_table` in d1; asleep at `in_bed` in end.
- **Tears:** only in the `sit_ouch` pose (b1 from "đau đau" / "ache", b2 on "nước mắt" / "tears"). They are gone when b2 swaps to `sit_look_up` on "đỡ dần" / "better", and no later pose has them (n1 ends with `kneel_happy`, a big smile).

## Spots (same camera in every scene)

Room = tidy_toys' `kit/room.png` with tidy_toys' crop (as tell_truth and keep_promise): bed on the left with the pillow at the LEFT end, window in the middle of the back wall, rug, open floor front right, door cropped out. Approximate points on the 1600×1200 canvas (feet / bottom for standing and sitting things, centre for floating ones); confirm with `stage.py --guides`.

| spot | where | about |
|---|---|---|
| `rug_left` | hero sitting / kneeling on the rug, facing right | [0.40, 0.96] |
| `bowl_spot` | soup bowl on the rug right in front of the sitting hero's lap | [0.49, 0.99] |
| `jar_spot` | candy jar on the rug, just right of the hero, within arm's reach | [0.58, 0.96] |
| `window` | Lulu in the air in front of the window | [0.50, 0.26] |
| `window_low` | the jar floating just below-right of Lulu at `window` (s1 start) | [0.56, 0.38] |
| `air_mid` | Lulu in the air above and right of the jar, not over the hero's head | [0.66, 0.48] |
| `table` | the bedside table on the floor, front right (tidy's toy-box spot, tell_truth's table spot) | [0.85, 0.89] |
| `table_top` | middle of the table's top: the jar in d1 / end | ≈ [0.85, 0.66] (measure) |
| `by_table` | hero standing just left of the table, facing right, hands at the table top | [0.73, 0.96] |
| `on_bed` | hero sitting up in bed, legs under the blanket lump (tidy b1 `bed_sit` placement) | ≈ [0.27, 0.58] (measure) |
| `bed_jar` | the jar on the blanket, right of the hero's covered legs | ≈ [0.45, 0.56] (measure) |
| `in_bed` | hero lying in bed, head on the pillow (girl `hero_b/asleep`, blanket lump at [0.425, 0.61], scale 1.3) | [0.29, 0.575] |
| `air_bed` | Lulu in the air above the bed, right of the pillow (tell_truth's `air_pillow`) | [0.42, 0.32] |

**Draw order** (back to front, the same in every scene): background → `table` → `hero` → `soup` → `blanket` → `jar` → `lulu`. The jar is in front of the hero, so in a1 / b1 her reaching hand goes behind the jar's rim (into the jar), and in d1 her hands sit behind the jar on the table (she is just letting go). The bowl is in front of her lap in n1. The jar is in front of the blanket lump in e1 / e2 (lying on the bed).

## Scenes

Hero outfit in every scene: the girl sheets' mint-green long-sleeve pajamas with little white stars, barefoot. Parts: `hero`, `lulu`, `jar`, `soup`, `table`, `blanket`. Every part is a cut-out, so hotspots are only needed for tap bursts (n1: `hearts` on the hero).

### s1 — `s1_gift` — sparkles
- **Lời kể (vi):** {name} ngồi trên thảm, sắp đến giờ đi ngủ. Vù! Lulu bay vào qua cửa sổ. Theo sau Lulu là một hũ nhỏ, bay lơ lửng. Lulu cười: "Quà của các vì sao đây!"
- **Narration (en):** {name} is sitting on the rug. It's almost bedtime. Whoosh! Lulu flies in through the window. Behind Lulu floats a little jar, bobbing in the air. Lulu smiles, "A present from the stars!"
- **Layout:**
  - hero `sit_look_up` at `rug_left`
  - Lulu `float` at `window`
  - jar `jar_closed` at `window_low` (floating beside Lulu)
  - table at `table` (empty)
- **Moves:**
  - vi `Vù` → lulu move to `air_mid`
  - `hũ nhỏ` → jar move to `jar_spot` (floats down onto the rug)
  - `lơ lửng` → jar hop
  - `Quà` → lulu pose `talk`
  - en words: `Whoosh`, `little jar`, `bobbing`, `present`

### s2 — `s2_open` — sparkles
- **Lời kể (vi):** Lulu chỉ vào hũ, nắp mở ra. Ồ! Kẹo cầu vồng đầy ắp: đỏ, vàng, xanh, tím. Mắt bé sáng long lanh. Lulu nói: "Kẹo ngọt lắm đấy!"
- **Narration (en):** Lulu points at the jar, and the lid pops open. Oh! It's full of rainbow candies: red, yellow, green and purple. The little one's eyes shine. Lulu says, "Candy is very sweet!"
- **Layout:** s1's end: hero `sit_look_up` at `rug_left`; jar `jar_closed` at `jar_spot`; Lulu `talk` at `air_mid`; table.
- **Moves (pose switches and hops only, so c1 can reuse this scene):**
  - vi `chỉ` → lulu pose `point`
  - `nắp` → jar pose `jar_open`; `mở ra` → jar hop
  - `sáng long lanh` → hero pose `kneel_happy`
  - `Lulu nói` → lulu pose `talk`
  - en words: `points`, `lid` / `pops open`, `shine`, `says`

### c1 — reuses `s2_open` — sparkles
- **Câu hỏi (vi):** {name} ơi, mình ăn mấy viên kẹo nhỉ?
- **Question (en):** {name}, how many candies should we eat?
- **Layout:** s2's end state. Node `poses`: hero `kneel_happy`, lulu `talk`, jar `jar_open`.
- **Options:**
  - `one` (kind): vi `Một viên thôi` · en `Just one`, icon `icon_one.webp`
  - `lots` (learn): vi `Thật nhiều viên` · en `Lots and lots`, icon `icon_lots.webp`

### a1 — `a1_one` — stars
- **Lời kể (vi):** {name} chọn một viên kẹo đỏ. Măm! Ngọt ơi là ngọt! Một viên là đủ vui miệng rồi. Bé đậy nắp hũ lại, để dành mai ăn tiếp.
- **Narration (en):** {name} picks one red candy. Yum! So sweet! One is just right for a happy mouth. The little one puts the lid back on. The rest can wait for tomorrow.
- **Layout:**
  - hero `sit_reach` at `rug_left` (hand at the jar's rim, behind its front)
  - jar `jar_open` at `jar_spot`
  - Lulu `float` at `air_mid`
  - table
- **Moves:**
  - vi `chọn` → jar wiggle
  - `Măm` → hero pose `eat_candy`
  - `đủ vui` → lulu pose `clap`
  - `đậy` → hero pose `kneel_place`; `nắp hũ` → jar pose `jar_closed`
  - `để dành` → jar pulse
  - en words: `picks`, `Yum`, `just right`, `puts` / `lid`, `wait`

### b1 — `b1_lots` — stars
- **Lời kể (vi):** {name} ăn một viên, rồi thêm một viên nữa. Viên xanh, viên vàng, viên tím… Ăn mãi, ăn mãi. Ơ, bụng bé hơi đau đau. Bụng nhỏ nhăn nhó vì nhiều kẹo quá. Bé rơm rớm nước mắt.
- **Narration (en):** {name} eats one candy, then one more. A green one, a yellow one, a purple one… More and more. Oh! The little tummy starts to ache a bit. It feels grumpy from too much candy. A little tear rolls down.
- **Layout:**
  - hero `eat_candy` at `rug_left`
  - jar `jar_open` at `jar_spot`
  - Lulu `float` at `air_mid` (she watches quietly; no moves until b2)
  - table
- **Moves:**
  - vi `thêm` → hero pose `sit_reach`
  - `Viên xanh` → hero pose `eat_candy`
  - `Ăn mãi` → jar wiggle
  - `đau đau` → hero pose `sit_ouch` (arms around the tummy, small tears)
  - `nhăn nhó` → hero wiggle (small)
  - `rơm rớm` → hero wiggle (small, soft: the gentle crying beat; the tears are already in `sit_ouch`)
  - en words: `one more`, `green`, `More`, `ache`, `grumpy`, `tear`

### b2 — `b2_glow` — sparkles — offer_rewind_to c1
- **Lời kể (vi):** Bé đậy hũ lại. Lulu tỏa sáng thật dịu. "Không sao, nước mắt khô ngay thôi. Một viên kẹo là đủ vui. Nhiều quá, bụng nhăn nhó đấy. Mình nghỉ chút, ăn canh rau ấm nhé. Bụng sẽ đỡ dần."
- **Narration (en):** The little one puts the lid back on. Lulu glows softly. "It's okay. The tears will dry soon. One candy is plenty. Too much makes tummies grumpy. Let's rest, then have warm veggie soup. Little by little, you'll feel better."
- Lesson + gradual recovery: rest a bit, then warm gentle food; the tummy gets better little by little ("đỡ dần"), never "right away". No warm-water cup (no new prop).
- **Layout:** b1's end: hero `sit_ouch` (teary) at `rug_left`; jar `jar_open` at `jar_spot`; Lulu `float` at `air_mid` (she stays in the air the whole scene, soothing with words and glow only: no sitting close, no touching); table.
- **Moves:**
  - vi `đậy` → hero pose `kneel_place`; `hũ lại` → jar pose `jar_closed`
  - `tỏa sáng` → lulu pose `glow`
  - `Không sao` → lulu pose `talk`
  - `nước mắt` → hero pose `sit_ouch` (still a little teary while Lulu soothes)
  - `đỡ dần` → hero pose `sit_look_up` (hopeful; tears gone)
  - en words: `puts` / `lid`, `glows`, `It's okay`, `tears`, `better`

### n1 — `n1_soup` — stars
- **Lời kể (vi):** Lulu bưng bát canh bí đỏ, có đậu Hà Lan xanh xanh. Canh nấu nhừ, mềm và ấm. Bé húp từng thìa nhỏ, chậm rãi. Hết veo! Bụng bé ấm áp, dễ chịu ghê.
- **Narration (en):** Lulu brings out a bowl of pumpkin soup, with little green peas. It's soft and warm. The little one sips it, spoon by spoon. All gone! The little tummy feels warm and cozy.
- Works on both paths, so the line is neutral: after a1 it is a cozy evening soup; after b2 it is the warm, gentle food Lulu suggested after a little rest. It says warm and cozy, never "the pain is gone" or "right away" (no "êm ru ngay"); soup is good food, not medicine. The tummy is fully calm only in end (sleep). No tears in any n1 pose; `kneel_happy` on "ấm áp" / "warm" is contentment. "đậu Hà Lan" = green peas (not "đậu xanh", which is mung bean).
- **Layout (the same start on both paths):**
  - hero `sit_look_up` at `rug_left`
  - soup `soup_full` at `bowl_spot` (already in place)
  - jar `jar_closed` at `jar_spot`
  - Lulu `float` at `air_mid`
  - table
  - hero hotspot burst `hearts` (tap)
- **Moves (pose switches and hops only, so c2 can reuse this scene):**
  - vi `canh bí đỏ` → soup hop
  - `đậu Hà Lan` → soup pulse
  - `húp` → hero pose `sit_spoon`
  - `Hết veo` → soup pose `soup_empty`
  - `ấm áp` → hero pose `kneel_happy`
  - `dễ chịu` → lulu pose `clap`
  - en words: `pumpkin soup`, `peas`, `sips`, `All gone`, `warm and cozy` → `warm` (hero), `cozy` (lulu)

### c2 — reuses `n1_soup` — stars
- **Câu hỏi (vi):** {name} ơi, hũ kẹo ngủ ở đâu đêm nay?
- **Question (en):** {name}, where will the candy jar sleep tonight?
- **Layout:** n1's end state. Node `poses`: hero `kneel_happy`, lulu `talk`, soup `soup_empty`, jar `jar_closed`.
- **Options:**
  - `table` (kind): vi `Trên bàn nhỏ, mai ăn` · en `On the little table, for tomorrow`, icon `icon_table.webp`
  - `bed` (learn): vi `Ngủ chung giường với bé` · en `In bed with me`, icon `icon_bed.webp`

### e1 — `e1_lumpy` — stars
- **Lời kể (vi):** {name} mang hũ kẹo lên giường, định ăn thêm một viên. Ối, hũ kẹo đổ nghiêng! Kẹo lăn khắp chăn. Chỗ nào cũng lộm cộm, cấn ơi là cấn. Bé chẳng ngủ được.
- **Narration (en):** {name} takes the candy jar into bed for one more candy. Oops, the jar tips over! Candies roll all over the blanket. Lumpy, bumpy everywhere! The little one can't get comfy to sleep.
- **Layout:**
  - hero `bed_sit` at `on_bed`, blanket lump over the legs
  - jar `jar_open` at `bed_jar` (on the blanket)
  - table at `table` (empty)
  - no Lulu
- **Moves:**
  - vi `Ối` → jar pose `jar_tipped` (the spilled candies are part of this state)
  - `lăn` → jar wiggle
  - `lộm cộm` → hero wiggle
  - `chẳng ngủ được` → hero wiggle
  - en words: `Oops`, `roll`, `Lumpy`, `comfy`
- The hero stays sitting the whole scene (her puzzled "where can I lie?" face), so no lying/sitting swap under one blanket lump.

### e2 — `e2_magic` — sparkles — offer_rewind_to c2
- **Lời kể (vi):** Vù! Lulu bay tới, tỏa sáng. Từng viên kẹo nhảy tưng tưng về hũ. Nắp đậy lại. Lulu nói: "Giường là chỗ để ngủ. Kẹo cũng cần chỗ ngủ riêng, trên bàn nhỏ nhé."
- **Narration (en):** Whoosh! Lulu flies over, glowing. One by one, the candies hop back into the jar. The lid closes. Lulu says, "Beds are for sleeping. Candy needs its own sleepy spot, on the little table."
- **Layout:** e1's end: hero `bed_sit` at `on_bed` + blanket lump; jar `jar_tipped` at `bed_jar`; Lulu `float` at `window`; table.
- **Moves:**
  - vi `Vù` → lulu move to `air_bed`
  - `tỏa sáng` → lulu pose `glow`
  - `nhảy` → jar pose `jar_closed`; `tưng tưng` → jar hop (upright again, candies inside)
  - `cạch` → jar hop
  - `Lulu nói` → lulu pose `talk`
  - `bàn nhỏ` → table pulse
  - en words: `Whoosh`, `glowing`, `hop back` / `into the jar`, `click`, `says`, `little table`

### d1 — `d1_table` — stars
- **Lời kể (vi):** {name} đặt hũ kẹo lên bàn nhỏ, thật ngay ngắn. Kẹo nằm yên trong hũ, chờ đến mai. Lulu vỗ tay: "Để dành giỏi quá!" Oáp! Bé buồn ngủ rồi.
- **Narration (en):** {name} sets the candy jar on the little table, nice and neat. The candies rest in their jar until tomorrow. Lulu claps, "You saved them for tomorrow!" Yaaawn! The little one is sleepy now.
- **Layout (the same start on both paths):**
  - hero `bend_place` at `by_table` (hands just letting go, behind the jar)
  - jar `jar_closed` at `table_top`
  - Lulu `float` at `air_mid`
  - no soup bowl
- **Moves:**
  - vi `đặt` → jar wiggle (settles)
  - `nằm yên` → jar pulse
  - `vỗ tay` → lulu pose `clap`
  - `Oáp` → hero pose `stand_yawn`
  - en words: `sets`, `rest`, `claps`, `Yaaawn`

### end — `end_asleep` — zzz
- **Lời kể (vi):** Bé chui vào chăn ấm, bụng nhỏ êm ru. Hũ kẹo ngủ trên bàn, bé ngủ trên giường. Lulu thì thầm: "Ngủ ngon nhé, {name}."
- **Narration (en):** The little one snuggles under the warm blanket, tummy calm and cozy. The candy jar sleeps on the table. The little one sleeps in bed. Lulu whispers, "Good night, {name}."
- This is where the tummy is fully calm ("êm ru"): after rest, warm food and sleep.
- **Layout:**
  - hero `asleep` (girl `hero_b`) at `in_bed`, `blanket_lump` over the body
  - jar `jar_closed` at `table_top`
  - Lulu `float` at `air_bed`
- **Ambient:** `zzz`, `ambient_origin` ≈ [0.18, 0.44].
- **Moves:**
  - vi `chui vào chăn` → blanket pulse
  - `Hũ kẹo` → jar pulse
  - `thì thầm` → lulu pose `whisper`
  - en words: `snuggles`, `candy jar`, `whispers`

## Setting

**Room (`room`, reused, no new Gemini image):** tidy_toys' `kit/room.png` (copy) with tidy_toys' crop, as tell_truth and keep_promise. The cozy kid bedroom at night: soft warm peach walls, wooden floor, warm lamp light, no text.
- **Left wall:** low wooden bed seen from its long side, white pillow at the LEFT end, smooth lavender blanket. The blanket top must have room right of the sitting hero's legs for the jar (`bed_jar`).
- **Back wall:** window in the middle (dark blue sky, crescent moon, stars), where Lulu comes in; small warm lamp on a little wooden shelf.
- **Floor:** round cream rug with open floor in front: room for the sitting hero, the bowl in front of her and the jar to her right. Front right is plain floor for the bedside table.
- The door is cropped out. Nothing on the floor.

**Recurring props** (soft 3D, from the front and a little from above, lit from the upper left). Sizes compared with the hero's head:
- **Candy jar (`jar`):** a round, chubby ceramic jar, pastel pink, opaque (you can't see inside), a little rainbow arc painted on its front, a round lid with a small knob. About 1.5× the hero's head tall and as wide; it reads on a phone. No face. States, the very same jar:
  - `jar_closed`: upright, lid on.
  - `jar_open`: upright, lid off (no lid shown), a heap of small round wrapped candies peeking over the rim: red, yellow, green, purple, wrappers twisted at both ends.
  - `jar_tipped`: the jar lying on its side, mouth to the RIGHT, lid off, a small loose cluster of the same candies spilled out in front of the mouth (one piece: like tell_truth's `vase_spilled`). About twice as wide as the upright jar.
- **Single candy (`candy_one`, icon only):** one of the same red wrapped candies, drawn big.
- **Soup bowl (`soup`):** a round cream ceramic bowl with a thin sky-blue rim, about as wide as the hero's head, a little lower. No spoon in it (the spoon is in the hero's `sit_spoon` hand). No steam (it can't be cut out). States, the very same bowl:
  - `soup_full`: smooth orange pumpkin soup (soft-cooked, canh bí đỏ nấu nhừ) with a few green peas on top for colour; no tomato, no corn, no carrots, no broccoli.
  - `soup_empty`: the same bowl, clean and empty.
- **Bedside table (`table`):** clock_time's `props_clock/bedside_table` (small round light-wood table on three short legs, top empty, about a standing child's waist high). The jar on its top fills about half its width.
- **Blanket lump (`blanket`):** tidy_toys' lavender `blanket_lump` (over the legs of the sitting hero in e1 / e2, over the body in end).

## Choice icons

Composed from sprites by `stage.py` (`icons` in `stage.json`), no Gemini.

| choice | option | kind | icon | built from |
|---|---|---|---|---|
| c1 | one | kind | `icon_one.webp` | `candy_one`, big, alone (one candy) |
| c1 | lots | learn | `icon_lots.webp` | `jar_open`, big, candies heaped up |
| c2 | table | kind | `icon_table.webp` | `bedside_table` with `jar_closed` on its top |
| c2 | bed | learn | `icon_bed.webp` | `blanket_lump` with `jar_open` sitting on top of it |

## Cover and sticker (normal Gemini pictures)

- **Cover (`cover.webp`, 800×600):** the night bedroom (attach `kit/room.png` and `kit/props_candy.png` so they look the same). The hero sits on the rug holding up one red wrapped candy with a happy smile. In front of her the cream bowl of orange pumpkin soup with a few green peas; beside her the pink candy jar with the lid on. Lulu floats above to the right, smiling, not touching the hero.
- **Sticker (`sticker.webp`, no hero):** the cream bowl (sky-blue rim) of smooth orange pumpkin soup with a few green peas, with a sleepy happy face on its front (eyes closed in curves, rosy cheeks), and one red wrapped candy leaning against the bowl, touching it so it is one sticker shape. A round sticker with a white border.

## Pose and prop lists

**Hero poses (11 of 12; girl, mint-green long-sleeve pajamas with white stars, barefoot).** Seven reused (copied sheets + sprites, never moved), four on one new sheet.

Reused:
1. `sit_look_up` (`hero_a`, tidy_toys): sits cross-legged, looking up right, delighted (s1, s2 start, b2 end, n1 start)
2. `kneel_happy` (`hero_a`, tidy_toys): kneels up tall, arms thrown up wide, big smile (s2 end, c1, n1 end, c2)
3. `bed_sit` (`hero_a`, tidy_toys): sits with legs straight out to the right, palms up, puzzled face (e1, e2)
4. `bend_place` (`hero_b`, tidy_toys): stands bending forward, open empty hands at waist height (d1)
5. `asleep` (`hero_b`, tidy_toys): lies on one side, head to the LEFT, eyes closed (end)
6. `kneel_place` (`hero_d`, clock_time): kneels leaning forward to the right, open empty hands low (a1 end, b2: putting the lid on)
7. `stand_yawn` (`hero_e`, clock_time): stands, huge yawn, fist rubbing an eye (d1 end)

New sheet `hero_h` (4 figures, 2 columns; girl; attach `kit/hero_a.png` for the size of the sitting child and `kit/props_candy.png` for the candy's look, so `props_candy` is made first; named `hero_h` because keep_promise has `hero_g`). All sit cross-legged on the floor, turned a little to the right, same head size as `hero_a`:
8. `sit_reach`: leans forward to the right, one arm reaching forward and down to the right at knee height, fingers ready to pick something, an eager little smile; nothing in the hand (a1 start, b1)
9. `eat_candy`: pops one small red wrapped candy into the mouth with two fingers, eyes closed in delight, the other hand on the knee (a1, b1)
10. `sit_ouch`: sits with the knees up, both arms wrapped softly around the tummy, eyes a little teary, one or two small clear tears on the cheeks, mouth in a small wobbly frown, eyebrows tilted up. Gentle and sad, not sobbing, not scary (no open crying mouth, no streams of tears) (b1 end, b2)
11. `sit_spoon`: holds a small cream spoon up at the mouth, sipping, eyes closed, a warm content smile, the other hand on the knee; nothing else in the hands (n1)

**Lulu poses (6; no new sheet):** all from tidy_toys' `lulu_a` (copy): `float` (everywhere), `talk` (s1, s2, c1, b2, c2, e2), `point` (s2), `glow` (b2, e2), `clap` (a1, n1, d1), `whisper` (end).

**Props (8 sprites):**
- new sheet `props_candy` (3 columns, 6 figures, made first): `jar_closed`, `jar_open`, `jar_tipped`, `soup_full`, `soup_empty`, `candy_one`
- reused: tidy_toys' `props` (copy): `blanket_lump`; clock_time's `props_clock` (copy): `bedside_table`

**Prop states by scene:**
- `jar`: `jar_closed` s1, s2 start; `jar_open` s2 end, c1, a1, b1, b2 start; `jar_closed` a1 end, b2 end, n1, c2; `jar_open` e1 start; `jar_tipped` e1 end, e2 start; `jar_closed` e2 end, d1, end
- `soup`: `soup_full` n1 start; `soup_empty` n1 end, c2
- `table`: every scene, empty top until d1
- `blanket`: e1, e2, end

**Gemini images for this story: 4.** New: `props_candy` (first), `hero_h`, `cover`, `sticker`. Copied (tell the parent to skip those prompts): `room`, `hero_a`, `hero_b`, `props`, `lulu_a` (tidy_toys), `hero_d`, `hero_e`, `props_clock` (clock_time). Never copy tell_truth's `hero_a` / `hero_b` (the boy).

## Kit notes (beats shaped to fit the kit; the parent approves them with this outline)

1. **One room, soup on the rug.** No kitchen (a second Gemini room for one scene): Lulu serves the soup as a little evening picnic on the rug. n1 says she "brings it out", but the bowl is already in place when n1 starts (nothing appears mid-scene).
2. **The jar arrives with Lulu.** It floats in beside her (s1), lands on the rug on a cue, and opens on Lulu's point (s2) by a pose swap. Nobody holds the jar: in a1 / b1 the hero's hand reaches behind its rim (draw order), and in d1 her hands are behind it on the table.
3. **Opaque jar, no counting.** The jar is ceramic, so eating "lots" never has to show fewer candies, and a1 / n1 look the same on both paths. The narration names colours, not numbers; nothing needs an SVG overlay.
4. **Candies in hand live in the figures** (`eat_candy`); the lid going on is a jar pose swap with the hero's `kneel_place`. The spill in e1 is one state (`jar_tipped` with its candy cluster), and Lulu's magic in e2 swaps it back to `jar_closed`.
5. **The tummyache (b1) is mild, with a small cry (parent's choice at gate 1).** It is the `sit_ouch` pose: arms softly around the tummy, eyes a little teary, one or two small tears, a small wobbly frown (gentle, not sobbing). b1 adds one short line, vi "Bé rơm rớm nước mắt." / en "A little tear rolls down.", with a small soft wiggle; the tears are drawn into the pose, so nothing appears mid-scene. In b2 Lulu first soothes the tears ("Không sao đâu, nước mắt khô ngay thôi." / "It's okay. The tears will dry soon."), then gives her lesson and a gradual recovery (rest a bit, then warm veggie soup; "Bụng sẽ đỡ dần." / "Little by little, you'll feel better."), still from the air. The tears go with the swap to `sit_look_up` on "đỡ dần" / "better", and n1 ends with `kneel_happy` smiling. Still apart from v1's "hand on tummy, tired, Lulu sits close and comforts": the hero is not tired, no sound effect, and Lulu stays in the air (no sitting close, no touching), glows and points the way (rest, then warm soup). The "rest" is in the words only (the hero stays sitting on the rug; no warm-water cup, no new prop).
6. **Rest and warm soup, not a cure (parent's change 2026-11-12).** Soup is not a quick fix for a candy tummyache: rest and something warm and gentle help, and vegetables are good food for the body over time. So b2 promises "better little by little", n1 is neutral on both paths (warm, gentle, a cozy tummy; never "the pain is gone" or "right away"), and the tummy is fully calm ("êm ru") only in end, after sleep. The learn path for c1 joins the trunk at n1 (not a1); a child who rewinds goes a1 → n1 and gets the same soup as a cozy evening bowl. No choice is about eating vegetables.
7. **c2 learn stays sitting.** e1 keeps the hero in `bed_sit` (legs under the lump) the whole scene: "can't get comfy" is wiggles plus her puzzled face, so no lying/sitting swap under one blanket lump.
8. **No teeth beat.** Candy at bedtime invites "brush your teeth", but that is tell_truth's c2; the story leaves it out.
9. **Hero moves only between nodes:** rug (s1–c2) → bed (e1, e2) → table (d1) → bed (end). Inside a scene only sit / kneel / stand swaps at the same point.
10. **Colour motif (no longer a "rainbow soup", 2026-11-12):** the rainbow belongs to the candies and the jar's painted arc only. The soup is a plain, gentle orange pumpkin soup with a few green peas: everyday real food, warm and soft, the calm counterpart to the bright candy. The sticker joins both (the sleepy soup bowl with one red candy leaning on it).
11. **SVG overlays:** none. No numbers, clocks, text or counts.
