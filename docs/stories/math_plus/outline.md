# math_plus: outline (first math story, kit)

- **Title:** vi `{name} đếm cừu bông` · en `{name} Counts the Little Sheep`
- **Theme:** addition · **Section:** `math` · **Curriculum step 5:** Cộng trong phạm vi 5 / Adding within 5 (`docs/math.md`)
- **Hero:** girl (`tool/image_refs/girl.png`). Text never gives a gender: "bé" / "the little one".
- **Moral:** vi: Có mấy bạn, thêm mấy bạn nữa, mình đếm lại từng bạn một là biết bây giờ có bao nhiêu. · en: When more friends come along, we count them all, one by one, to find how many there are now.
- **Cast:** the hero, Lulu, and five small **cừu bông / little woolly sheep** (plush toy sheep, all the same; Lulu's glow makes them hop). They are the counted objects, not a talking character: they only wag, hop, slide and curl up to sleep.
- **Not repeated:** no story uses counting, sheep or a fence. Not used (AVOID list): blocks, ball, teddy, toy box, balloons, candy, cups, clock, flowers; no tidy-up, promise, treat or rule beat. The hero stays in bed the whole story (a bedtime "counting sheep" story); nothing breaks or hides.
- **Questions:** c1 = 2 + 1 (answer 3, near miss 2: forgetting the one that just came); c2 = 3 + 2 (answer 5, near miss 4). Sums ≤ 5, never 0. Sheep is the only kind of object in both questions.

## Choices

### c1: two sheep, one more hops over
Question: vi `{name} ơi, hai bạn cừu thêm một bạn nữa. Bây giờ có mấy bạn cừu nhỉ?` · en `{name}, two sheep and one more. How many sheep are there now?`
- **Right answer (kind, `three`)**: vi `Ba bạn cừu` · en `Three sheep`. a1: the three sheep hop on "một, hai, ba", the hero and Lulu clap.
- **Near miss (learn, `two`)**: vi `Hai bạn cừu` · en `Two sheep`. b1: "Mình cùng đếm lại nhé!" Lulu points to each sheep, each hops on its number: one, two, three. Lulu: vi **"Hai bạn cừu, thêm một bạn nữa là ba bạn cừu."** · en **"Two sheep and one more make three sheep."** → rewind offer to c1, then a1.

### c2: three sheep, two more hop over
Question: vi `{name} ơi, ba bạn cừu thêm hai bạn nữa. Bây giờ có mấy bạn cừu nhỉ?` · en `{name}, three sheep and two more. How many sheep are there now?`
- **Right answer (kind, `five`)**: vi `Năm bạn cừu` · en `Five sheep`. d1: the five sheep hop on "một … năm", Lulu claps.
- **Near miss (learn, `four`)**: vi `Bốn bạn cừu` · en `Four sheep`. e1: "Mình cùng đếm lại nhé, thật chậm thôi." The hero points, Lulu counts along, each sheep hops on its number up to five. Lulu: vi **"Ba bạn cừu, thêm hai bạn nữa là năm bạn cừu."** · en **"Three sheep and two more make five sheep."** → rewind offer to c2, then d1.

Never "sai" / "wrong"; the right-answer scenes celebrate the counting ("Ba bạn cừu đây rồi! Một, hai, ba!"), so they also fit after a near miss when the child skips the rewind.

## Node graph

| id | type | next / options | offer_rewind_to | ambient |
|---|---|---|---|---|
| s1 | scene | s2 | | sparkles |
| s2 | scene | s3 | | stars |
| s3 | scene | c1 | | stars |
| c1 | choice | three → a1 (kind), two → b1 (learn) | | stars |
| b1 | scene | a1 | c1 | stars |
| a1 | scene | n1 | | stars |
| n1 | scene | c2 | | stars |
| c2 | choice | five → d1 (kind), four → e1 (learn) | | stars |
| e1 | scene | d1 | c2 | stars |
| d1 | scene | d2 | | stars |
| d2 | scene | end | | stars |
| end | ending (sticker `images/sticker.webp`) | | | zzz, `ambient_origin` at the sleeping head (about [0.25, 0.50]; take it from the hero's `asleep` placement) |

12 nodes. Paths: right-right = 10 nodes, near miss both times = 12. Stickers: up to 2 (right answer picked first).

Ambient: only s1 gets `sparkles` (Lulu flies in glowing); every counting scene keeps the calm `stars` so nothing flies across the sheep while the child counts; the ending `zzz`.

Continuity:
- The hero is in bed in every scene (no walking, no gliding); the blanket lump lies over her legs from s1 to d2 and over her body in end.
- Lulu flies in from the window in s1 and then stays at `air_count` until d2 (both paths start every node with her there); in end she floats down to `air_bed`.
- Sheep: s1 three at the door (`door_1`–`door_3`); s2 sheep1 and sheep2 hop over; s3 sheep3 hops over; from c1 on, sheep1–3 stand at `meadow_1`–`meadow_3`. sheep4 and sheep5 stand at `door_1` / `door_2` at the start of n1 (they arrive between a1 and n1, see Kit notes), hop over in n1, and from c2 on all five stand at `meadow_1`–`meadow_5`. In d2 they switch to `sleep` one by one and stay asleep in end.
- At each question every sheep on screen is a counted sheep: nobody waits by the door, so "how many now?" = every sheep the child can see.

## Spots (same camera in every scene)

Approximate pivots on the 1600×1200 canvas (x, y from 0 to 1); confirm on a `--guides` still of the `tidy_toys` room.

| spot | where | about |
|---|---|---|
| `on_bed` | on the bed (left wall), sitting up or lying, head by the pillow | head ≈ [0.25, 0.50] |
| `meadow_1` … `meadow_5` | the "sheep meadow": floor and rug between the foot of the bed and the fence, left to right, alternating a little front / back so no two sheep overlap | [0.33, 0.80] / [0.41, 0.75] / [0.49, 0.80] / [0.57, 0.75] / [0.65, 0.80] |
| `fence` | the little fence on the rug's right edge | [0.73, 0.78] |
| `door_1` / `door_2` / `door_3` | waiting spots on the free floor in front of the door (right), `door_1` nearest the fence | [0.80, 0.74] / [0.85, 0.69] / [0.90, 0.74] |
| `window` | in the air in front of the window | [0.50, 0.28] |
| `air_count` | in the air above the meadow, a little right of the bed (Lulu's counting spot) | [0.47, 0.42] |
| `air_bed` | in the air beside the bed, by the pillow | [0.36, 0.42] |

Keep the bottom-right corner (Gemini watermark) clear: `door_3` sits above it.

Draw order (back to front), the same in every scene: background → hero → blanket lump → fence → sheep5 → sheep4 → sheep3 → sheep2 → sheep1 → Lulu. Sheep are in front of the fence, so a sheep sliding across it reads as hopping over it.

Counting order = left to right: `sheep1` lands leftmost (`meadow_1`), `sheep5` nearest the fence (`meadow_5`), so every count runs left → right.

## Scenes

Hero outfit: the shared mint-green pajamas with tiny white stars. Parts: `hero`, `lulu`, `blanket`, `fence`, `sheep1` … `sheep5` (one shared sprite per state). Cues are suggestions for the writer; every number word has a `hop` (or the `sleep` pose in d2) on its sheep. Two cues never share a word (cue_times finds words in order).

### s1 — `s1_awake` — sparkles
- **Lời kể (vi):** {name} ngồi trong chăn, mắt vẫn tròn xoe. Vù! Lulu bay vào, sáng lấp lánh. Lulu cười: "Chưa buồn ngủ à? Mình cùng đếm cừu nhé!" Bên cửa, các bạn cừu bông vẫy đuôi.
- **Narration (en):** {name} sits up under the blanket, eyes still wide open. Whoosh! Lulu flies in, all aglow. Lulu smiles, "Not sleepy yet? Let's count sheep together!" By the door, the little woolly sheep wag their tails.
- **Layout:** hero `bed_awake` at `on_bed`, blanket lump over the legs; fence at `fence`; sheep1 `stand` at `door_1`, sheep2 at `door_2`, sheep3 at `door_3`; Lulu `float` at `window`.
- **Moves:** `Vù` → lulu move to `air_count`; `lấp lánh` → lulu pose `glow`; `cười` → lulu pose `talk`; `đếm cừu` → hero pose `bed_point`; `cửa` → sheep1 wiggle; `cừu bông` → sheep2 wiggle; `vẫy đuôi` → sheep3 wiggle · en `Whoosh`, `aglow`, `smiles`, `count sheep`, `door`, `woolly`, `wag`.

### s2 — `s2_jump` — stars
- **Lời kể (vi):** Bạn cừu đầu tiên nhảy qua hàng rào, đến bên giường. Một! Bạn cừu tiếp theo cũng nhảy qua. Hai! Bé chỉ tay đếm theo: một, hai.
- **Narration (en):** The first sheep hops over the fence, over by the bed. One! The next sheep hops over too. Two! The little one points and counts along: one, two.
- **Layout:** s1's end: hero `bed_point`, Lulu `float` at `air_count` (node `poses`), sheep1–3 at `door_1`–`door_3`.
- **Moves:** `nhảy` → sheep1 hop; `hàng rào` → sheep1 move to `meadow_1`; `Một` → sheep1 hop; `tiếp theo` → sheep2 hop; `nhảy qua` (2nd) → sheep2 move to `meadow_2`; `Hai` → sheep2 hop; `một` → sheep1 hop; `hai` → sheep2 hop · en `first sheep hops`, `fence`, `One`, `next`, `hops over`, `Two`, `one`, `two`. (`chỉ tay` / `points` → hero pulse if the writer wants a hero beat; she already points.)

### s3 — `s3_one_more` — stars
- **Lời kể (vi):** Bên cửa còn một bạn cừu nữa. Bạn ấy nhún nhún chân, rồi nhảy qua hàng rào. Thế là hai bạn cừu, thêm một bạn nữa!
- **Narration (en):** One more sheep is waiting by the door. It bounces, bounces, then hops over the fence. So that's two sheep, and one more!
- **Layout:** s2's end: sheep1 at `meadow_1`, sheep2 at `meadow_2`, sheep3 at `door_3`; hero `bed_point`; Lulu `float` at `air_count`.
- **Moves:** `còn` → lulu pose `point` (down right, at sheep3); `nhún` → sheep3 wiggle; `nhảy` → sheep3 hop; `hàng rào` → sheep3 move to `meadow_3`; `hai` → sheep1 hop; `bạn cừu` → sheep2 hop; `thêm một` → sheep3 hop; end → hero pose `bed_think` (on `nữa`) · en `One more`, `bounces`, `hops`, `fence`, `two`, `sheep`, `one more`, `more`.

### c1 — reuses `s3_one_more` (end state) — stars
- **Câu hỏi (vi):** {name} ơi, hai bạn cừu thêm một bạn nữa. Bây giờ có mấy bạn cừu nhỉ?
- **Question (en):** {name}, two sheep and one more. How many sheep are there now?
- **Layout:** s3's end: hero `bed_think`, Lulu `talk` at `air_count` (node `poses`), sheep1–3 at `meadow_1`–`meadow_3`, nobody at the door.
- **Moves (optional):** `hai` → sheep1 hop, `bạn cừu` → sheep2 hop, `một` → sheep3 hop (the question shows the 2 + 1 again) · en `two`, `sheep`, `one`.
- Options: `three` (kind) vi `Ba bạn cừu` · en `Three sheep`, icon `icon_three.webp`; `two` (learn) vi `Hai bạn cừu` · en `Two sheep`, icon `icon_two.webp`.

### b1 — `b1_count` — stars (offer_rewind_to c1, next a1)
- **Lời kể (vi):** Mình cùng đếm lại nhé! Lulu chỉ vào từng bạn cừu. Một, hai, ba! Lulu cười: "Hai bạn cừu, thêm một bạn nữa là ba bạn cừu."
- **Narration (en):** Let's count again together! Lulu points to each sheep. One, two, three! Lulu smiles, "Two sheep and one more make three sheep."
- **Layout:** as c1: hero `bed_think` at `on_bed`, Lulu `float` at `air_count`, sheep1–3 at `meadow_1`–`meadow_3`.
- **Moves:** `đếm lại` → hero pose `bed_point`; `chỉ` → lulu pose `point` (flip if she must point down-left); `Một` → sheep1 hop; `hai` → sheep2 hop; `ba` → sheep3 hop; `cười` → lulu pose `talk`; `thêm một` → sheep3 wiggle; `ba bạn cừu` → sheep2 pulse · en `count again`, `points`, `One`, `two`, `three`, `smiles`, `one more`, `three sheep`.

### a1 — `a1_three` — stars
- **Lời kể (vi):** Ba bạn cừu đây rồi! Một, hai, ba! Bé vỗ tay, Lulu cũng vỗ tay. Ba bạn cừu đứng bên giường, vẫy đuôi chào {name}.
- **Narration (en):** Three sheep, here they are! One, two, three! The little one claps, and Lulu claps too. The three sheep stand by the bed and wag their tails at {name}.
- **Layout (same start on both paths):** hero `bed_think` at `on_bed`, Lulu `float` at `air_count`, sheep1–3 at `meadow_1`–`meadow_3`.
- **Moves:** `Một` → sheep1 hop; `hai` → sheep2 hop; `ba` → sheep3 hop; `vỗ tay` → hero pose `bed_clap`; `cũng` → lulu pose `clap`; `vẫy đuôi` → sheep2 wiggle · en `One`, `two`, `three`, `claps`, `too`, `wag`.

### n1 — `n1_late` — stars
- **Lời kể (vi):** Lóc cóc, lóc cóc! Hai bạn cừu nữa chạy tới bên cửa. Bạn này nhảy qua hàng rào. Bạn kia cũng nhảy qua!
- **Narration (en):** Clip-clop, clip-clop! Two more sheep trot up to the door. This one hops over the fence. That one hops over too!
- **Layout:** hero `bed_awake` at `on_bed` (looking toward the door), Lulu `float` at `air_count`, sheep1–3 at `meadow_1`–`meadow_3`; **sheep4 at `door_1`, sheep5 at `door_2`** (here from the start of the node).
- **Moves:** `Lóc cóc` → sheep4 wiggle; `lóc cóc` → sheep5 wiggle; `Hai` → sheep4 hop; `cửa` → sheep5 hop; `Bạn này` → sheep4 hop; `hàng rào` → sheep4 move to `meadow_4`; `Bạn kia` → sheep5 hop; `nhảy qua` (2nd) → sheep5 move to `meadow_5`; `cũng` → hero pose `bed_point` · en `Clip-clop`, `clip-clop`, `Two`, `door`, `This one`, `fence`, `That one`, `over too`.

### c2 — reuses `n1_late` (end state) — stars
- **Câu hỏi (vi):** {name} ơi, ba bạn cừu thêm hai bạn nữa. Bây giờ có mấy bạn cừu nhỉ?
- **Question (en):** {name}, three sheep and two more. How many sheep are there now?
- **Layout:** n1's end: hero `bed_think`, Lulu `talk` at `air_count` (node `poses`), sheep1–5 at `meadow_1`–`meadow_5`, nobody at the door.
- **Moves (optional):** `ba` → sheep2 pulse (the first three), `hai` → sheep5 pulse (the two new ones), or hop sheep4/5 on `hai bạn nữa` · en `three`, `two`.
- Options: `five` (kind) vi `Năm bạn cừu` · en `Five sheep`, icon `icon_five.webp`; `four` (learn) vi `Bốn bạn cừu` · en `Four sheep`, icon `icon_four.webp`.

### e1 — `e1_count` — stars (offer_rewind_to c2, next d1)
- **Lời kể (vi):** Mình cùng đếm lại nhé, thật chậm thôi. Bé chỉ tay, Lulu đếm theo. Một, hai, ba, bốn, năm! Lulu nói: "Ba bạn cừu, thêm hai bạn nữa là năm bạn cừu."
- **Narration (en):** Let's count again together, nice and slow. The little one points, and Lulu counts along. One, two, three, four, five! Lulu says, "Three sheep and two more make five sheep."
- **Layout:** as c2: hero `bed_think`, Lulu `float` at `air_count`, sheep1–5 at `meadow_1`–`meadow_5`.
- **Moves:** `chỉ tay` → hero pose `bed_point`; `đếm theo` → lulu pose `point`; `Một` → sheep1 hop; `hai` → sheep2 hop; `ba` → sheep3 hop; `bốn` → sheep4 hop; `năm` → sheep5 hop; `nói` → lulu pose `talk` · en `points`, `counts along`, `One`, `two`, `three`, `four`, `five`, `says`.

### d1 — `d1_five` — stars
- **Lời kể (vi):** Năm bạn cừu đây rồi! Một, hai, ba, bốn, năm! Bé vỗ tay, Lulu cũng vỗ tay. Các bạn cừu bông dụi dụi mắt, buồn ngủ rồi.
- **Narration (en):** Five sheep, here they are! One, two, three, four, five! The little one claps, and Lulu claps too. The woolly sheep rub their sleepy eyes.
- **Layout (same start on both paths):** hero `bed_think`, Lulu `float` at `air_count`, sheep1–5 at `meadow_1`–`meadow_5`.
- **Moves:** `Một` → sheep1 hop; `hai` → sheep2 hop; `ba` → sheep3 hop; `bốn` → sheep4 hop; `năm` → sheep5 hop; `vỗ tay` → hero pose `bed_clap`; `cũng` → lulu pose `clap`; `dụi` → sheep3 wiggle · en `One` … `five`, `claps`, `too`, `rub`.

### d2 — `d2_sleepy` — stars
- **Lời kể (vi):** Từng bạn cừu nằm cuộn tròn, ngủ ngoan. Một, hai, ba, bốn, năm. Bé cũng ngáp một cái thật dài. Oáp!
- **Narration (en):** One by one, the sheep curl up and go to sleep. One, two, three, four, five. The little one gives a big, long yawn. Yaaawn!
- **Layout:** hero `bed_clap` at `on_bed`, Lulu `float` at `air_count`, sheep1–5 `stand` at `meadow_1`–`meadow_5`.
- **Moves:** `Một` → sheep1 pose `sleep`; `hai` → sheep2 pose `sleep`; `ba` → sheep3 pose `sleep`; `bốn` → sheep4 pose `sleep`; `năm` → sheep5 pose `sleep`; `ngáp` → hero pose `lie_yawn` (lies down under the blanket lump); `Oáp` → lulu pose `whisper` · en `One` … `five`, `yawn`, `Yaaawn`. (The pose switch is the counting beat here: each sheep curls up on its own number.)

### end — `end_asleep` — zzz
- **Lời kể (vi):** Bé nằm xuống, chăn ấm ôm lấy bé. Năm bạn cừu ngủ say bên giường. Lulu thì thầm: "Ngủ ngon nhé, {name}."
- **Narration (en):** The little one lies down, snug under the warm blanket. Five sheep sleep soundly by the bed. Lulu whispers, "Good night, {name}."
- **Layout:** hero `asleep` at `on_bed`, blanket lump over the body; sheep1–5 `sleep` at `meadow_1`–`meadow_5`; fence; Lulu `float` at `air_count`.
- **Ambient:** `zzz`, `ambient_origin` at the hero's head (≈ [0.25, 0.50]).
- **Moves:** `Bé` → lulu move to `air_bed`; `ngủ say` → sheep3 pulse; `thì thầm` → lulu pose `whisper` · en `lies down`, `sleep soundly`, `whispers`.

## Setting (reuse `tidy_toys/kit/room.png`, night)

The shared cozy kid bedroom at night, empty, no text or numbers (`"from": "tidy_toys/kit/room.png"`): low wooden bed with a white pillow and lavender blanket along the **left wall**; window with dark blue sky and crescent moon in the middle of the **back wall**, small glowing lamp on a shelf between bed and window; round cream rug in the middle of the wooden floor; rounded light-wood door on the **right wall** with free floor in front of it (the old toy box spot, now the sheep's waiting place). The story needs: open floor from the foot of the bed across the rug to the door (five sheep side by side plus the fence), and a clear bottom-right corner. No new room.

Recurring props (sizes compared with the sheep):
- **Little woolly sheep (`sheep`):** a small plush toy sheep, round body of soft white curly wool, cream face and ears, small dark-grey legs, tiny smile, dot eyes, a little tuft of wool on its head; seen from the side, **facing LEFT** (they walk from the door toward the bed). On stage about as tall as the hero's head is wide, a bit more than knee-high to a standing child. All five sheep are the same sprite. States: `stand` (standing on four legs), `sleep` (the very same sheep lying curled up, legs tucked in, eyes closed, head to the LEFT).
- **Fence (`fence`):** one short piece of a low white wooden toy fence, three rounded posts and two rails, seen from the front a little turned; about as tall as the standing sheep's back and about one and a half sheep wide.
- **Blanket lump (`blanket_lump`):** from `tidy_toys/kit/props.png` (the lavender mound): over the hero's legs when she sits up, over her body when she lies down.

## Choice icons (composed from the kit, no Gemini)

Each card = the `stand` sheep sprite, spread out, never overlapping, plus an amber `numeral` above (`docs/math.md`).

| choice | option | kind | icon | built from |
|---|---|---|---|---|
| c1 | three | kind | `icon_three.webp` | 3 sheep in a row (size ≈ 0.28) + `numeral` 3 |
| c1 | two | learn | `icon_two.webp` | 2 sheep in a row (size ≈ 0.30) + `numeral` 2 |
| c2 | five | kind | `icon_five.webp` | 5 sheep: 3 in front, 2 behind (size ≈ 0.20; no overlap) + `numeral` 5 |
| c2 | four | learn | `icon_four.webp` | 4 sheep in a row (size ≈ 0.21) + `numeral` 4 |

## Cover and sticker (normal Gemini pictures)

- **Cover (`cover.webp`, 800×600):** night, crescent moon in the window. The girl sits up in bed under the lavender blanket, smiling and pointing at **one** little woolly sheep leaping over the small white fence on the rug; Lulu floats nearby, glowing. Only one sheep, so the cover never shows a count; no digits, no text. Hero and Lulu do not touch.
- **Sticker (`sticker.webp`, 600×600):** one little woolly sheep mid-leap over the small white fence, a small yellow star above it; round sticker with a white border. No hero, no numbers.

## Pose and prop lists

**Hero poses (6).** Bed figures all sit on nothing, legs stretched straight out to the RIGHT (like `bed_sit_up` in `clock_time` hero_c), so the room's bed and the blanket lump go around them.
1. `bed_awake` — **new, sheet hero_h**: sits up, legs to the right, wide-awake bright round eyes, small happy smile, both hands resting on the legs (s1, n1)
2. `bed_point` — **new, hero_h**: sits up the same way, one arm stretched forward to the right, index finger pointing down to the right, mouth open as if counting aloud (s1–s3, b1, n1, e1)
3. `bed_think` — **new, hero_h**: sits up the same way, one finger on the chin, looking down to the right, thinking, small smile (s3 end, c1, b1, a1, c2, e1, d1)
4. `bed_clap` — **new, hero_h**: sits up the same way, clapping both hands in front of the chest, big happy smile, eyes closed (a1, d1, d2 start)
5. `lie_yawn` — reused from `clock_time` hero_c: lies on one side, head to the LEFT, big sleepy yawn (d2 end)
6. `asleep` — reused from `tidy_toys` hero_b: lies on one side, head to the LEFT, eyes closed (end)

New sheet: `hero_h`, 4 figures (2 columns), attaches `kit/hero_c.png` for the size of the sitting-in-bed child.

**Lulu poses (6), all from `tidy_toys` lulu_a (copy, no new sheet):** `float`, `talk`, `glow` (s1), `point` (s3, b1, e1), `clap` (a1, d1), `whisper` (d2, end).

**Props (4 sprites):**
- `sheep_stand` and `sheep_sleep` — **new sheet `props_sheep`** (the very same sheep at the same size and angle in both); used by parts `sheep1`–`sheep5` with poses `stand` / `sleep`.
- `fence` — **new, `props_sheep`**, one state.
- `blanket_lump` — reused from `tidy_toys/kit/props.png`.

Gemini work for this story: one hero sheet (4 figures), one props sheet (3 figures), cover, sticker. Room, Lulu, `lie_yawn`, `asleep` and the blanket are copies.

## Kit notes (for the parent to approve)

1. **Hopping over the fence = a hop, then a slide.** The app has no arc: a sheep `hop`s on one word and `move`s across the fence to its meadow spot on the next. Sheep are drawn in front of the fence so the slide reads as going over it.
2. **The two late sheep (n1) are already by the door when n1 starts.** Nothing may appear inside a scene, so sheep4 and sheep5 arrive between a1 and n1; n1 opens with "Lóc cóc, lóc cóc!" and wiggles them, so the child's eye goes to them first. If the stage can start a part just past the right edge of the picture, they could slide in on "Lóc cóc" instead (staging choice, same words).
3. **No waiting sheep at question time.** In c1 only the three counted sheep are on screen, in c2 the five: the answer is always "every sheep you can see", so the near miss is only about forgetting the one(s) that just came.
4. **The hero never leaves the bed.** Every hero pose is a bed figure (sits on nothing, legs right), so there is no sliding across the room; the blanket lump covers only the legs while she sits (her hands stay visible for pointing and clapping).
5. **Falling asleep (d2) is a pose switch** `stand` → `sleep` on each sheep's number word; the sheep stay in their spots.
6. **Lulu stays at `air_count`** from s1 to d2 so both paths start every node the same; she points from there (`point`, flipped if she has to point down-left at sheep1–2).
7. **No AI picture shows a count.** Every counted sheep is its own part; the cover and sticker show one sheep. Digits appear only on the choice cards (`numeral` in `stage.py`). **No SVG overlays** are needed.
8. **Sheep size vs. space:** five sheep plus the fence must fit between the foot of the bed and the door; the meadow spots alternate front/back to keep them apart. If they still crowd, make the sheep a little smaller (each must stay easy to see on a phone, about the hero's head size or bigger) before moving the fence.

## Update 2026-11-13: new numbers every play (parent's request)

The story is now a number **template** (`docs/math.md` "New numbers every play"); the fixed 2 + 1 / 3 + 2 above are just one possible play.
- Vars: `a` 1–3 sheep hop over first; `b` 1–(4 − a) more; `c = a + b` (c1 answer); `d` 1–(5 − c) more late sheep; `e = c + d` (c2 answer). Near miss = right ± 1 (never 0, never above 5). Cards swap sides at random.
- Every node sets `counted`: s1/s2 `{field 0, wait a}`, s3 `{field a, wait b}`, c1/b1/a1 `{field c}`, n1 `{field c, wait d}`, c2/e1/d1/d2/end `{field e}`. Newcomers walk in on an `arrive` cue; counts (`{count:c}`) make each sheep hop on its number, d2 `{count:e:sleep}` curls them up.
- Stage: all five sheep in every scene at `meadow_1`–`meadow_5` (the app hides / places / moves them); `math.field` = meadow spots, `math.wait` = `door_1`–`door_3`.
- **Answer cards are drawn by the app** from one transparent sheep (`math.icon`, the sheep sprite layer): `icon_three/two/five/four` are no longer needed.
- Audio: shared number clips `num_1`…`num_10` (once per language); question and lesson lines are recorded in pieces between the numbers.
