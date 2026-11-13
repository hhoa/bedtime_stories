# tell_truth: outline (v2 port of v1, kit story)

> **Update 2026-11-11 (parent): the vase BREAKS, it does not spill.** Text, cues and layouts below that say spill / puddle / `vase_spilled` / `vase_empty` / "lau khô sàn" are out of date; `assets/stories/tell_truth/story.json` and `docs/stories/tell_truth/stage.json` are the truth. Now: s1 "Bình hoa rơi xuống đất. Choang! Ối, vỡ mất rồi! Hoa rơi khắp sàn." (vase pose `vase_broken` = `props_broken/vase_shards` + loose flowers); c1 label "Nói thật: mình làm vỡ"; a2 Lulu's magic makes the pieces float away (`shards` → `gone`), then the flowers go in the cup; from n1 only the cup of flowers stands on the table.


Port of v1 `../bedtime_story/docs/stories/tell_truth/` (the parent approved the port; the duplicate check found v1 only). The plot, the moral, both choices, the option ids, the `offer_rewind_to` and the learn-path beats are **kept from v1**. Changes are for v2's `{name}` rule, the 14-node limit, and the kit (no picture per scene: one empty room + cut-out hero / Lulu / prop sprites, moved on words). Each node is marked **unchanged from v1** or **changed**, and every beat change is listed under **Kit notes**.

- **Title:** vi `{name} và bình hoa của Lulu` (unchanged) · en `{name} and Lulu's Flower Vase`
- **Theme:** honesty
- **Hero:** boy (`tool/image_refs/boy.png`; changed from kid on 2026-11-11, Gemini can't make a unisex sheet). The text never gives a gender: "bé" / "the little one".
- **Moral:** vi: Khi mình làm sai, nói thật thì hòn đá trong bụng bay đi mất, và bạn bè càng thương mình vì mình dũng cảm. · en: When we make a mistake, telling the truth makes the heavy feeling go away, and friends love us for being brave.
- **Cast:** the hero, Lulu, and one extra simple character: **bạn sâu răng tí hon / the tiny tooth germ** (round, soft, sleepy, friendly; only in e1–e2). Lulu's vase is an object (no face). No grown-ups.
- **Not repeated:** `tidy_toys` (toys go home, ball under the bed), `clock_time` (reading the clock, bedtime on time), `prepare_stuff_vacation` (packing). This story is about saying what really happened. It shares only the bedroom, the striped ball and the blanket lump (kit reuse), not their beats: here the ball just bumps a table leg once.

## Choices

### c1: Lulu asks who spilled her vase
Question: vi `{name} nên nói gì với Lulu?` (unchanged) · en `{name}, what should you tell Lulu?`
- **Kind (`truth`)**: vi `Nói thật: mình làm đổ` · en `Tell the truth: I spilled it`. The hero quietly owns up and says sorry. Lulu swoops close, thanks them and says they are brave (a1). Then together they stand the empty vase back up and put the flowers in a cup beside it, as in v1 (a2).
- **Learn (`notme`)**: vi `Nói: không phải mình` · en `Say: it wasn't me`. Lulu sadly searches the room and guesses it was the wind (b1). The hero's tummy feels heavy, like a little stone, and they don't want to play anymore (b2). Lulu floats down beside them (b3): vi **"Khi mình làm sai, cứ nói thật nhé. Nói thật thì hòn đá trong bụng sẽ bay đi mất."** · en **"When we make a mistake, let's tell the truth. Then the little stone in the tummy floats away."** → rewind offer to c1, then a1.

### c2: Lulu asks if the teeth are brushed (the hero forgot)
Question: vi `{name} trả lời Lulu thế nào?` (unchanged) · en `{name}, what do you tell Lulu?`
- **Kind (`forgot`)**: vi `Nói thật: mình quên rồi` · en `Tell the truth: I forgot`. The hero brushes for real in the bathroom. Teeth are white and fresh, and Lulu praises the truth and the doing (d1).
- **Learn (`fib`)**: vi `Nói: mình đánh rồi` · en `Say: I already did`. In bed the teeth feel sticky, and one tiny germ cheers that it gets to stay tonight (e1). Lulu floats to the pillow and the hero admits it (e2): vi **"Quên cũng không sao đâu. Bạn nói thật, mình giúp ngay."** · en **"It's okay to forget. When you tell the truth, I can help right away."** → rewind offer to c2, then d1.

## Node graph

| id | type | next / options | offer_rewind_to | ambient |
|---|---|---|---|---|
| s1 | scene | s2 | | stars |
| s2 | scene | c1 | | sparkles |
| c1 | choice | truth → a1 (kind), notme → b1 (learn) | | sparkles |
| b1 | scene | b2 | | stars |
| b2 | scene | b3 | | stars |
| b3 | scene | a1 | c1 | sparkles |
| a1 | scene | a2 | | sparkles |
| a2 | scene | n1 | | stars |
| n1 | scene | c2 | | stars |
| c2 | choice | forgot → d1 (kind), fib → e1 (learn) | | stars |
| e1 | scene | e2 | | stars |
| e2 | scene | d1 | c2 | sparkles |
| d1 | scene | end | | sparkles |
| end | ending (sticker `images/sticker.webp`) | | | zzz, `ambient_origin` at the sleeping head (≈ [0.18, 0.44]; take it from the hero's `asleep` placement) |

14 nodes (v1 had 15: its s1 + s2 are now one scene, see Kit notes 1). Paths: kind-kind = 9 nodes, learn-learn = 14. Stickers: up to 2. Start `s1`.

**Continuity**
- Ball: in front of the hero on the rug at the start of s1. It rolls to the table leg (`by_table`) in s1 and stays there in every bedroom scene after that.
- Vase: upright with flowers on the table (s1 start, at `table_top`). It falls and spills (`vase_spilled` at `spill`) in s1 and stays spilled through s2, c1, b1–b3 and a1. Between a1 and a2 the floor is dried and the empty vase stands on the table again (`vase_empty` at `vase_side`, whole), with an empty `cup` beside it at `cup_spot` and the loose `flowers` on the floor at `spill`. In a2 the flowers go into the cup (`cup_flowers`). The empty vase and the cup of flowers then stay side by side on the table in n1, c2, e1, e2 and end (as in v1, where the cup of flowers is still on the table at the end).
- Lulu: absent in s1 and e1 (as in v1). She enters through the window in s2 and in e2. In b2 she is still far away at the window, searching.
- Germ: only in e1 and e2, floating just above the pillow. It is not in d1 (bathroom) or end.

## Spots

**Bedroom** = tidy_toys' room with tidy_toys' crop (bed on the left, pillow at the LEFT end, window in the middle of the back wall, rug, door cropped out). Approximate points on the 1600×1200 canvas (feet for standing things, centre for floating ones); confirm with `stage.py --guides`.

| spot | where | about |
|---|---|---|
| `rug_left` | hero on the rug, left of centre, facing right | [0.40, 0.96] |
| `rug_mid` | hero on the rug, middle, facing right | [0.52, 0.96] |
| `table` | the little bedside table on the floor, front right (tidy's toy-box spot) | [0.85, 0.89] |
| `table_top` | the middle of the table's top: where the vase stands in s1 | ≈ [0.85, 0.66] (measure) |
| `vase_side` | the right half of the table's top: the empty vase from a2 on | ≈ [0.88, 0.66] (measure) |
| `cup_spot` | the left half of the table's top, beside the vase (toward the room): the cup from a2 on | ≈ [0.81, 0.66] (measure) |
| `spill` | the floor just in front of the table, to its left: the spilled vase, puddle, loose flowers | [0.70, 0.94] |
| `by_table` | the floor right in front of the table legs: the ball | [0.82, 0.97] |
| `window` | in the air in front of the window: Lulu enters here | [0.50, 0.26] |
| `air_spill` | in the air above the spill, a little to the left | [0.66, 0.52] |
| `air_table` | in the air above the table, on its left | [0.70, 0.38] |
| `by_hero` | in the air just right of the hero at `rug_left`, low, not touching | [0.56, 0.62] |
| `peek_bed` | low beside the dark gap under the bed | [0.32, 0.76] |
| `in_bed` | the hero lying in bed, head on the pillow (tidy's `asleep` spot) | [0.29, 0.575] |
| `germ_spot` | in the air just above the pillow, by the hero's face | [0.24, 0.40] |
| `air_pillow` | in the air above and to the right of the pillow (tidy's end Lulu spot) | [0.42, 0.32] |

**Bathroom** (`room_bath`, d1 only): `by_sink` = the hero standing just right of the sink, ≈ [0.50, 0.95]. `air_bath` = Lulu in the air on the right, ≈ [0.76, 0.42].

**Bedroom draw order** (back to front, the same in every scene): background → `flowers` → `table` → `vase` → `cup` → `ball` → `hero` → `blanket` → `germ` → `lulu`. The loose flowers are drawn before the table, the vase and the cup, so when they slide up to `cup_spot` in a2 they disappear behind the table top and the cup (end the move a little low so nothing of them peeks out; check on the still). Then the cup switches to `cup_flowers`.

## Scenes

Hero outfit in every scene: the boy sheet's mint-green pajamas with little white stars, barefoot. Parts: `hero`, `lulu`, `ball`, `table`, `vase`, `cup`, `flowers`, `blanket`, `germ`. Every part is a cut-out, so `hotspots.json` is only needed for tap bursts (a1: hearts on the hero).

### s1 — `s1_spill` — stars — **changed** (v1 s1 + s2 merged)
- **Lời kể (vi):** {name} đang lăn bóng trong phòng. Trên bàn là bình hoa Lulu yêu nhất. Bộp! Bóng lăn trúng chân bàn. Bình hoa đổ nghiêng. Ối! Đổ rồi! Nước và hoa tràn ra khắp sàn.
  - changed: v1 `Buổi tối, {name} đang chơi bóng…` (name mid-line) → name first; v1 s2's spill lines joined on.
- **Narration (en):** {name} is rolling a ball in the bedroom. On the table is Lulu's favourite flower vase. Bump! The ball rolls into the table leg. The vase tips over. Oops! It spilled! Water and flowers go all over the floor.
- **Layout:** hero `kneel_roll` at `rug_left`; ball on the rug just in front of the hero's hands; table at `table`, vase `vase_flowers` at `table_top`. No Lulu.
- **Moves:** vi `Bộp` → ball move to `by_table`; `chân bàn` → table wiggle; `đổ nghiêng` → vase move to `spill` (it falls); `Ối` → hero pose `stand_oops`; `Đổ rồi` → vase pose `vase_spilled`; `tràn ra` → vase wiggle · en `Bump`, `table leg`, `tips`, `Oops`, `spilled`, `Water`.

### s2 — `s2_lulu` — sparkles — **vi unchanged from v1** (v1 s3)
- **Lời kể (vi):** Tưng, tưng! Thỏ Lulu nhảy vào phòng. "Ôi, bình hoa của mình! Ai làm đổ thế nhỉ?"
- **Narration (en):** Boing, boing! Lulu the bunny hops into the room. "Oh, my flower vase! Who knocked it over?"
- **Layout:** s1's end: hero `stand_oops` at `rug_left`; ball at `by_table`; table; vase `vase_spilled` at `spill`. Lulu `float` at `window`.
- **Moves:** `Tưng` → lulu move to `air_spill`; `tưng` → lulu hop; `bình hoa của mình` → lulu pose `sad`; `Ai` → vase wiggle · en `Boing`, `boing`, `my flower vase`, `Who`.

### c1 — `c1_ask` (s2's end state) — sparkles
- **Câu hỏi (vi):** {name} nên nói gì với Lulu? (unchanged)
- **Question (en):** {name}, what should you tell Lulu?
- **Layout:** hero `stand_oops` at `rug_left`, Lulu `sad` at `air_spill`, ball, table, vase `vase_spilled`. It is staged on its own (like tidy_toys' `c1_ask`) because Lulu moved in s2, so reusing `s2_lulu` would show her back at the window.
- **Options:** `truth` (kind) vi `Nói thật: mình làm đổ` · en `Tell the truth: I spilled it`, icon `icon_truth.webp`. `notme` (learn) vi `Nói: không phải mình` · en `Say: it wasn't me`, icon `icon_notme.webp`.

### b1 — `b1_notme` — stars — **changed**
- **Lời kể (vi):** {name} nói: "Không phải mình đâu!" Lulu buồn thiu, đi tìm khắp phòng. "Vậy ai làm đổ nhỉ? Chắc tại cơn gió..."
  - changed: v1 `"Không phải mình đâu!" {name} nói.` (name mid-line) → the name opens the line.
- **Narration (en):** {name} says, "It wasn't me!" Lulu feels sad and looks all around the room. "Then who spilled it? Maybe it was the wind..."
- **Layout:** hero `say_no` at `rug_left`; Lulu `sad` at `air_spill`; ball, table, vase `vase_spilled` as before.
- **Moves:** `Không phải` → hero wiggle (a little head shake); `đi tìm` → lulu pose `peek`; `khắp phòng` → lulu move to `peek_bed` (looks under the bed); `cơn gió` → lulu move to `window` · en `wasn't`, `looks`, `around`, `wind`.

### b2 — `b2_heavy` — stars — **vi unchanged from v1**
- **Lời kể (vi):** {name} thấy trong bụng nặng trĩu, như có một hòn đá nhỏ. Bé chẳng muốn chơi bóng nữa. Bé không vui chút nào.
- **Narration (en):** {name} has a heavy feeling in the tummy, like a little stone inside. The little one doesn't want to play ball anymore. It's no fun at all.
- **Layout:** hero `sit_tummy` at `rug_left` (sat down between the nodes); Lulu `peek` at `window`, far away and still searching; ball at `by_table`; table; vase `vase_spilled`.
- **Moves:** `hòn đá nhỏ` → hero pulse; `chơi bóng` → ball hop (the ball waits, nobody plays) · en `little stone`, `play ball`.

### b3 — `b3_lulu` — sparkles — **changed** (offer_rewind_to c1)
- **Lời kể (vi):** Lulu sà xuống ngay cạnh bé. "Khi mình làm sai, cứ nói thật nhé. Nói thật thì hòn đá trong bụng sẽ bay đi mất."
  - changed: v1 `Lulu ngồi xuống cạnh bé.` → `Lulu sà xuống ngay cạnh bé.` (Lulu floats low; no sitting pose). Lulu's key line is unchanged.
- **Narration (en):** Lulu floats down right beside the little one. "When we make a mistake, let's tell the truth. Then the little stone in the tummy floats away."
- **Layout:** hero `sit_tummy` at `rug_left`; Lulu `float` at `window`; ball, table, vase `vase_spilled`.
- **Moves:** `Lulu` → lulu move to `by_hero` (low, not touching); `cạnh bé` → hero pose `sit_look_up`; `Khi mình` → lulu pose `talk`; `bay đi mất` → hero pulse · en `Lulu`, `beside`, `When`, `floats away`.

### a1 — `a1_sorry` — sparkles — **changed**
- **Lời kể (vi):** {name} nói nhỏ: "Lulu ơi, mình làm đổ bình hoa. Mình xin lỗi." Lulu sà tới, cười thật tươi. "Cảm ơn bạn đã nói thật. Bạn dũng cảm lắm!"
  - changed: the second `{name}` (`Cảm ơn {name}…`) → `bạn`. `Lulu ôm bé.` → `Lulu sà tới, cười thật tươi.` (no hug, see Kit notes 3).
- **Narration (en):** {name} says softly, "Lulu, I spilled your vase. I'm sorry." Lulu swoops close with a big smile. "Thank you for telling the truth. You're so brave!"
- **Layout (the same start on both paths):** hero `stand_sorry` at `rug_left`; Lulu `sad` at `air_spill` (where she asked); ball, table, vase `vase_spilled`. Hero hotspot burst `hearts` (tap).
- **Moves:** `xin lỗi` → vase pulse; `sà tới` → lulu move to `by_hero` (at the standing hero's shoulder height, not touching); `cười` → lulu pose `float` (her smile comes back); `dũng cảm` → hero pose `stand_proud` + hop; `Bạn` (2nd) → lulu pose `clap` · en `sorry`, `swoops`, `smile`, `brave`, `You're`.

### a2 — `a2_flowers` — stars — **changed**
- **Lời kể (vi):** Hai bạn lau khô sàn, dựng bình hoa lên bàn. Rồi cùng nhặt hoa lên, cắm vào một chiếc cốc. Ồ, đẹp quá! Bụng bé nhẹ tênh, vui ơi là vui.
  - changed: `Hai bạn lau khô sàn, dựng bình hoa lên bàn.` added in front (on screen the floor is dry and the empty vase stands again). v1's cup is kept: `Hai bạn cùng nhặt hoa lên, cắm vào một chiếc cốc.` → `Rồi cùng nhặt hoa lên, cắm vào một chiếc cốc.` `Trong bụng {name}…` (name mid-line) → `Bụng bé…`. No `{name}` in this line.
- **Narration (en):** Together they dry the floor and stand the vase back up. Then they pick up the flowers and put them in a little cup. Oh, so pretty! The little one's tummy feels light and happy.
- **Layout:** the drying and standing up happen between the nodes: the floor is dry, vase `vase_empty` at `vase_side`, an empty `cup` at `cup_spot` beside it, `flowers` lying on the floor at `spill`. Hero `stand_proud` at `rug_mid`; Lulu `float` at `air_table`; ball at `by_table`.
- **Moves:** `nhặt hoa` → hero pose `stand_place` (reaching toward the flowers, hands empty); `cắm vào` → flowers move to `cup_spot` (they slide up behind the table top and the cup); `chiếc cốc` → cup pose `cup_flowers`; `đẹp quá` → lulu pose `clap`; `vui ơi là vui` → hero pose `stand_proud` + hop · en `pick up`, `put them`, `cup`, `pretty`, `happy`.

### n1 — `n1_teeth` — stars — **changed**
- **Lời kể (vi):** Đến giờ đi ngủ rồi. Lulu hỏi: "Bạn đã đánh răng chưa?" Ôi, bé mải chơi nên quên mất!
  - changed: v1 `"{name} đã đánh răng chưa?"` (name mid-line) → `"Bạn đã đánh răng chưa?"`. c2 says the name right after.
- **Narration (en):** It's time for bed. Lulu asks, "Have you brushed your teeth?" Oh! The little one was busy playing and forgot!
- **Layout:** hero `stand_proud` at `rug_mid`; Lulu `float` at `air_table`; on the table vase `vase_empty` at `vase_side` and cup `cup_flowers` at `cup_spot`; ball at `by_table`. No moves, only pose switches, so c2 can reuse this composition.
- **Moves:** `hỏi` → lulu pose `talk`; `quên mất` → hero pose `stand_oops` · en `asks`, `forgot`.

### c2 — reuses `n1_teeth` — stars
- **Câu hỏi (vi):** {name} trả lời Lulu thế nào? (unchanged)
- **Question (en):** {name}, what do you tell Lulu?
- **Layout:** node `poses`: hero `stand_oops`, lulu `talk`. Vase `vase_empty` and cup `cup_flowers` on the table as in n1.
- **Options:** `forgot` (kind) vi `Nói thật: mình quên rồi` · en `Tell the truth: I forgot`, icon `icon_toothbrush.webp`. `fib` (learn) vi `Nói: mình đánh rồi` · en `Say: I already did`, icon `icon_germ.webp`.

### e1 — `e1_germ` — stars — **changed**
- **Lời kể (vi):** {name} nằm xuống giường. Ơ, răng nhớp nháp quá. Một bạn sâu răng tí hon hò reo. "Hoan hô, tối nay mình được ở lại rồi!"
  - changed: v1 `Bé nằm xuống giường. {name} thấy răng nhớp nháp quá.` (name mid-line) → `{name} nằm xuống giường. Ơ, răng nhớp nháp quá.`
- **Narration (en):** {name} lies down in bed. Hmm, the teeth feel all sticky. A tiny tooth germ cheers. "Hooray, I get to stay tonight!"
- **Layout:** hero `lie_sticky` at `in_bed`, with the blanket lump over the body up to the chest; germ `germ_sleepy` at `germ_spot` (not touching the hero); on the table vase `vase_empty` at `vase_side` and cup `cup_flowers` at `cup_spot`; ball at `by_table`. No Lulu.
- **Moves:** `nhớp nháp` → hero wiggle; `hò reo` → germ pose `germ_cheer`; `Hoan hô` → germ hop; `ở lại` → germ pulse · en `sticky`, `cheers`, `Hooray`, `stay` (parent edit 2026-11-11: no yawn).

### e2 — `e2_truth` — sparkles — **changed** (offer_rewind_to c2)
- **Lời kể (vi):** Lulu bay tới bên gối, cười hiền. Bé nói nhỏ: "Lulu ơi, thật ra mình chưa đánh răng." Lulu nói: "Quên cũng không sao đâu. Bạn nói thật, mình giúp ngay. Mình cùng đi đánh răng nhé!"
  - changed: v1 had `{name}` twice (mid-line) → none; `ngồi xuống bên giường, xoa tóc {name}` → `bay tới bên gối, cười hiền` (no touching). Lulu's key line is unchanged.
- **Narration (en):** Lulu floats over to the pillow with a kind smile. The little one whispers, "Lulu, I didn't really brush my teeth." Lulu says, "It's okay to forget. When you tell the truth, I can help right away. Let's go brush together!"
- **Layout:** e1's end: hero `lie_sticky` at `in_bed` + blanket lump; germ `germ_sleepy` at `germ_spot`; Lulu `float` at `window`; vase `vase_empty`, cup `cup_flowers` and ball as e1.
- **Moves:** `Lulu` (1st) → lulu move to `air_pillow` (right of the germ, not touching); `nói nhỏ` → hero pose `bed_sit_shy`; `Lulu nói` → lulu pose `talk`; `đi đánh răng` → germ wiggle · en `Lulu`, `whispers`, `says`, `brush together`.

### d1 — `d1_brush` — sparkles — bathroom — **changed**
- **Lời kể (vi):** {name} đánh răng thật sạch. Xoạt, xoạt! Răng trắng tinh, thơm mát. Lulu khen: "Nói thật và làm thật, giỏi quá!"
  - changed: v1 `Xoạt, xoạt! {name} đánh răng…` (name mid-line) → name first.
- **Narration (en):** {name} brushes really well. Swish, swish! Teeth all white and minty fresh. Lulu cheers, "You told the truth, and you did it too. Well done!"
- **Layout (the same start on both paths):** room `room_bath`. Hero `brush` at `by_sink` (the toothbrush is in the figure); Lulu `float` at `air_bath`. No germ.
- **Moves:** `Xoạt` → hero wiggle; `xoạt` → hero wiggle; `trắng tinh` → hero pulse; `khen` → lulu pose `clap` · en `Swish`, `swish`, `white`, `cheers`.

### end — `end_asleep` — zzz — **changed**
- **Lời kể (vi):** Bé chui vào chăn ấm, nhắm mắt lại. Nói thật xong, lòng bé thấy nhẹ tênh. Lulu thì thầm: "Ngủ ngon nhé, {name}."
  - changed: v1 had `{name}` twice. The first one → `Bé`; the good night keeps the name as the last word.
- **Narration (en):** The little one snuggles under the warm blanket and closes both eyes. After telling the truth, the little heart feels light. Lulu whispers, "Good night, {name}."
- **Layout:** hero `asleep` at `in_bed` + blanket lump; on the table vase `vase_empty` at `vase_side` and the cup of flowers `cup_flowers` at `cup_spot` (as in v1's end picture); ball at `by_table`; Lulu `float` at `air_pillow`.
- **Ambient:** `zzz`, `ambient_origin` at the hero's head (≈ [0.18, 0.44]).
- **Moves:** `chui vào chăn` → blanket pulse; `nhẹ tênh` → cup pulse (the cup of flowers); `thì thầm` → lulu pose `whisper` · en `snuggles`, `light`, `whispers`.

## Setting

**Bedroom (`room`, reused):** tidy_toys' `kit/room.png`, copied into this story's `kit/`. It is the same cozy kid bedroom at night: soft warm peach walls, wooden floor, warm lamp light, no text. A low wooden bed along the left with a lavender blanket and a white pillow at the LEFT end, and a dark gap under it (Lulu peeks there in b1). A window in the middle of the back wall (dark blue sky, crescent moon, stars), and a lamp on a little shelf. A round cream rug, with open floor in front for the hero, the spill and the ball. Plain floor at the front right for the table. The door is cropped out. Nothing on the floor.

**Bathroom (`room_bath`, new Gemini image, d1 only):** a small cozy bathroom at night in the same soft 3D style and warm lamp light. Warm cream wall tiles with a pale-blue stripe at the sink rim, light warm-beige floor tiles, no green or mint. A low white sink at a small child's chest height on the left half of the back wall, with nothing on it but a small pale-blue cup. A small round window on the right with a dark night sky, crescent moon and stars. A soft towel on a hook. Plain tiled floor in front, open (nothing on it). **No mirror** (an empty mirror would need the hero's reflection). The same camera height and distance as the bedroom, so the hero sprite fits at the same scale. The bottom-right corner is plain floor. No people, no Lulu, no text.

**Props** (soft 3D, from the front and a little from above, lit from the upper left):
- **Bedside table:** a small round light-wood table on three short straight legs, its top empty, about the height of a standing child's waist. Reused from clock_time's `props_clock` sheet (`bedside_table`). From a2 on its top holds the empty vase and the cup side by side (check on the `--guides` still that both fit; if tight, the cup stands a little forward on the left edge).
- **Lulu's vase:** a round-bellied pale-pink ceramic vase with a small amber crescent moon painted on its front (Lulu's moon). It stands about half as tall as the table. It holds three flowers (one yellow, one pink, one white daisy) that reach about as high again above its rim. The vase is always whole: no cracks, no pieces. States:
  - `vase_flowers`: upright, with the flowers.
  - `vase_spilled`: the very same vase lying on its side, its mouth toward the viewer's left, a solid, opaque sky-blue puddle with a darker edge (no shine, no drops) spreading in front of it and the three flowers lying on it; last figure on the sheet. The whole piece is about one and a half times the table's width.
  - `vase_empty`: the very same vase upright, empty.
- **Flowers (`flowers`):** the same three flowers lying together on the floor, no water, about as long as the vase is tall.
- **Cup (v1's amber cup with a heart):** a small round amber ceramic cup with a little handle on the right and a small pink heart painted on its front, about half as tall as the vase and a little narrower. States:
  - `cup`: upright, empty.
  - `cup_flowers`: the very same cup with the same three flowers (yellow, pink, white daisy) standing in it, the blooms reaching about as high again above its rim.
- **Ball:** tidy_toys' small ball with wide red and white stripes, about as big as the hero's head on screen (kit lesson: narrated small things must read on a phone).
- **Blanket lump:** tidy_toys' lavender blanket mound (covers the lying hero's body; the sitting hero's legs in e2).
- **Tooth germ (`germ_sleepy`, `germ_cheer`):** a tiny round soft lime-green blob with tiny nubby arms and feet, rosy cheeks and a friendly face. About two thirds of the hero's head on screen. Sleepy: half-closed eyes and a small smile. Cheer: tiny arms up, eyes happily closed, small open-mouth cheer. Never scary: no teeth, no horns, no spikes.
- **Heart (`heart`, icon only):** a soft puffy pink heart.

## Choice icons

Composed from sprites by `stage.py` (`icons` in `stage.json`), no Gemini.

| choice | option | kind | icon | built from |
|---|---|---|---|---|
| c1 | truth | kind | `icon_truth.webp` | hero `stand_sorry` + `heart` floating above the head (owning up with love) |
| c1 | notme | learn | `icon_notme.webp` | hero `say_no` + `vase_spilled` on the floor beside |
| c2 | forgot | kind | `icon_toothbrush.webp` | hero `brush` figure, big, alone (no separate toothbrush sprite) |
| c2 | fib | learn | `icon_germ.webp` | `germ_cheer`, big, alone |

## Cover and sticker (normal Gemini pictures)

- **Cover (`cover.webp`):** the night bedroom (attach the room and the props sheet so they look the same). The hero kneels on the rug and Lulu floats beside them, not touching. Both smile at Lulu's pale-pink vase with its three flowers, upright on the little bedside table. One soft pink heart floats above the vase.
- **Sticker (`sticker.webp`, no hero):** Lulu's pale-pink vase with the amber moon, upright with its three flowers, a small soft pink heart above it and a tiny happy face on the vase's belly. A round sticker with a white border.

## Pose and prop lists

**Hero poses (12, boy; two new sheets).** No boy pose sheets exist yet, so both are new. Facing right toward the table unless the pose says otherwise.

`hero_a` (standing):
1. `stand_oops`: stands, both hands on the cheeks, mouth a small round "O", surprised but not scared (s1 end, s2, c1, n1 end, c2)
2. `say_no`: stands, both hands up with the palms out, head turned away to the left, eyes looking aside, a small fib face (b1, `icon_notme`)
3. `stand_sorry`: stands, hands clasped in front, head a little bowed, a shy small smile (a1, `icon_truth`)
4. `stand_proud`: stands tall, a big bright smile showing clean white teeth, arms a little open, happy (a1 end, a2, n1)
5. `stand_place`: stands leaning forward to the right, both arms reaching forward and down at waist height, open empty hands, nothing in them, a careful smile (a2)
6. `brush`: stands turned a little to the LEFT (toward the sink), brushing with the bright yellow toothbrush in one hand at the mouth, a little white foam at the lips, happy eyes (d1)

`hero_b` (kneeling, sitting, lying; lying figures lie on nothing, head to the LEFT):
7. `kneel_roll`: kneels on the rug, both arms pushed forward low to the right, open hands, as if they just rolled a ball, happy (s1)
8. `sit_tummy`: sits with the knees up, both hands on the tummy, shoulders down, a small sad frown, no tears (b2, b3 start)
9. `sit_look_up`: sits the same way, hands in the lap, looking up to the right with a small hopeful face (b3)
10. `lie_sticky`: lies on the back or side, head to the LEFT, a small frown, lips pressed together, one hand near the mouth (e1, e2 start)
11. `bed_sit_shy`: sits up, legs stretched straight out to the RIGHT, turned a little toward the viewer, a shy little smile, hands together (e2)
12. `asleep`: lies on one side facing the viewer, head to the LEFT, eyes closed, a peaceful small smile (end)

**Lulu poses (6):**
- from tidy_toys' `lulu_a` (copy): `float` (s2, b3, a1 end, a2, n1, e2, d1, end start), `talk` (b3, n1, c2, e2), `clap` (a1, a2, d1), `whisper` (end)
- new `lulu_c` (2 figures):
  - `sad`: floats with her ears drooping, a small sad frown, paws together at the chest, looking down to the left (s2, c1, b1, a1 start)
  - `peek`: floats low, leaning forward to the LEFT, one paw shading her eyes, looking for something, ears a little down (b1, b2)

**Props (12 sprites; the new sheet holds 9, see Kit notes 5):**
- new `props_truth` sheet: `vase_flowers`, `vase_spilled`, `vase_empty`, `flowers`, `cup`, `cup_flowers`, `germ_sleepy`, `germ_cheer`, `heart`, `bedside_table` (10; clock_time's props_clock not made yet)
- reused from tidy_toys' `props` (copy): `ball`, `blanket_lump`
- reused from clock_time's `props_clock` (copy once made): `bedside_table`. If tell_truth is drawn first, `bedside_table` goes on `props_truth` with clock_time's exact words (11 figures).

**Prop states by scene:**
- `vase`:
  - `vase_flowers`: s1 start
  - `vase_spilled`: s1 end, s2, c1, b1–b3, a1
  - `vase_empty`: a2, n1, c2, e1, e2, end (at `vase_side`)
- `cup` (at `cup_spot`):
  - `cup`: a2 start
  - `cup_flowers`: a2 end, n1, c2, e1, e2, end
- `flowers`: a2 only (on the floor, then behind the table top and the cup)
- `ball`: on the rug at the start of s1, then at `by_table` from s1 on
- `germ`: `germ_sleepy` (e1 start, e2), `germ_cheer` (e1 end)
- `blanket`: e1, e2, end

**Gemini images for this story:** `room_bath`, `hero_a`, `hero_b`, `lulu_c`, `props_truth`, `cover`, `sticker` (7). The hero sheet `boy.png` already exists. Copied: `room`, `lulu_a`, tidy `props`, and `props_clock` (when made).

## Kit notes (beats changed to fit the kit; the parent approves them with this outline)

1. **v1 s1 and s2 merged into s1.** v1 had 15 nodes, but the limit is 14. Rolling the ball and the spill are now one scene with three visible actions (ball rolls, vase falls and spills, hero "oops"). v1's s3 (Lulu hops in) is now s2. Node ids b*, a*, n1, e*, d1 and end are unchanged.
2. **The spill:** the vase part moves from the table top to `spill` (it falls), then switches to `vase_spilled` on "Đổ rồi" / "spilled". The puddle and flowers are part of that one state, so nothing new pops in. The vase is never broken (as in the v1 revision).
3. **No hug in a1:** hero and Lulu are on separate sheets and never touch. `Lulu ôm bé` → `Lulu sà tới, cười thật tươi`: Lulu moves right next to the hero, smiles (her `sad` pose → `float`) and claps on "dũng cảm". Hearts are a tap burst on the hero, not drawn art.
4. **e2:** Lulu no longer strokes the hero's hair (touching). She floats to the pillow and smiles, and the hero sits up (`lie_sticky` → `bed_sit_shy`) to admit it. If the sitting figure doesn't fit under the lying-sized blanket lump, start e2 already in `bed_sit_shy` with the lump over the legs (as tidy_toys' b1).
5. **The cup (a2), kept from v1:** the flowers go into a small cup, and the whole empty vase stands beside it on the table. Drying the floor and standing the vase up happen between a1 and a2 (the narration says so first); the empty `cup` is already on the table at the start of a2. On "cắm vào" / "put them" the loose flowers slide up behind the table top and the cup (drawn before them, so nothing vanishes in the open), and on "chiếc cốc" / "cup" the cup switches to `cup_flowers`. The cup of flowers and the empty vase then stay on the table through the end (v1's end picture has the cup of flowers on the table). This adds two sprites (`cup`, `cup_flowers`): the new `props_truth` sheet holds 9 (10 if `bedside_table` is drawn here); the story uses 12 prop sprites in all (`ball`, `blanket_lump`, `bedside_table` copied from other stories' sheets). Parent approved (2026-11-11): no `toothbrush` sprite; `icon_toothbrush` is built from the hero's `brush` figure.
6. **No grey cloud or floating stone (b2):** the heavy tummy is the hero's `sit_tummy` pose (hands on the tummy) plus a pulse on "hòn đá nhỏ". No metaphor prop is needed.
7. **n1:** Lulu doesn't hold a toothbrush up (that would need another Lulu pose). The toothbrush appears only in the hero's `brush` figure (`icon_toothbrush` is made from that figure).
8. **d1 in a second room, the bathroom (`room_bath`),** the only new room. It has no mirror and is drawn at the bedroom's camera distance. The germ isn't there: brushing has sent it off.
9. **Germ:** in place from the start of e1 (no fade-in), still sleepy in e2, and gone from d1 on (between nodes). It talks once, softly. It is the story's one extra character.
10. **Ambient:** v1 s1 and a2 were `motes` (daytime), but these scenes are in the night room, so they are now `stars`.
11. **Choices:** c1 is its own staged scene `c1_ask` (s2's end state) because Lulu moves in s2. c2 reuses `n1_teeth` with node poses, because n1 only switches poses.
12. **Boy hero** (was kid until 2026-11-11): `tool/image_refs/boy.png` exists. No boy pose sheets exist, so `hero_a` / `hero_b` are new (12 poses). Lulu, the bedroom, the ball and the blanket lump are copied from tidy_toys. `lulu_c` has only the 2 poses this story lacks (6 Lulu poses in total).
13. **Labels** follow the v1 outline (`Nói thật: …` / `Nói: …`), not v1's story.json (`Thật ra, mình làm đổ` / `Không phải mình!`, `Thật ra, mình quên rồi` / `Mình đánh rồi ạ`).
14. **SVG overlays:** none. There are no numbers, clocks or text, and the narration never counts the flowers.
