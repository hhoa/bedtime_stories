# clock_time: outline (v2 port of v1)

Port of v1 `../bedtime_story/docs/stories/clock_time/` (approved by the parent). Plot, beats, choices, option ids, node ids, graph, `offer_rewind_to`, ambient and moral are **kept as in v1**. Art: kit since 2026-11-11 (see **Kit** below; v1's per-scene pictures retired). All audio is re-recorded.

- **Title:** vi `{name} và Bác Đồng Hồ tích tắc` · en `{name} and Mr. Tick-Tock`
- **Theme:** time
- **Hero:** girl (`tool/image_refs/girl.png`). The text never gives a gender: "bé" / "the little one".
- **Moral:** vi: Kim ngắn chỉ số bảy là giờ dậy, chỉ số chín là giờ ngủ; vặn kim không làm thay đổi giờ. · en: The clock tells us when it's time: short hand on seven, we get up; on nine, we go to bed. Turning the hands doesn't change the time.
- **Cast:** the hero, Lulu, and **Bác Đồng Hồ / Mr. Tick-Tock**, a round alarm clock with two bells, small feet and a face, on the bedside table in every scene. In scenes it is an SVG layer (`clock.json`, `tool/clock_layer.py`) so the numbers and hands are exact; AI draws it only on the cover; `icon_turn` / `icon_bed` are SVG clocks. No grown-ups.
- **Clock-reading rule (said the same way every time):** vi "Kim ngắn chỉ số bảy, kim dài chỉ số mười hai. Vậy là bảy giờ đúng!" · en "The short hand is on seven. The long hand is on twelve. That means seven o'clock!" (and the same with nine). Lulu says it in the morning; in the evening Lulu asks and the child answers.

## Choices

### c1: 7:00, the clock rings
Question: vi `Bảy giờ rồi! {name} ơi, mình làm gì nhỉ?` · en `It's seven o'clock! What should we do, {name}?`
- **Kind (`up`)**: vi `Dậy thôi!` · en `Up we get!` → a1 (stretch, good morning to the clock) → a2 (slow breakfast, backpack, wave).
- **Learn (`snooze`)**: vi `Ngủ thêm chút nữa` · en `Sleep a bit more` → b1 (blanket over the head, long hand goes to six) → b2 (rush: shirt back to front, one sock, bread not eaten) → b3 (Lulu turns the shirt round; lesson) → rewind offer to c1, then a1.

### c2: 9:00, the clock chimes
Question: vi `Chín giờ rồi! {name} ơi, mình làm gì đây?` · en `It's nine o'clock! What should we do now, {name}?`
- **Kind (`bed`)**: vi `Chúc Bác Đồng Hồ ngủ ngon` · en `Say goodnight to Mr. Tick-Tock` → d1 (crayons in the cup, goodnight, into bed) → end.
- **Learn (`turn`)**: vi `Vặn kim lùi để chơi thêm` · en `Turn the hands back to play` → e1 (short hand back to eight, clock dizzy, moon still out, big yawn) → e2 (Lulu: turning the hands doesn't change the night; hand back to nine) → rewind offer to c2, then d1.

## Node graph (unchanged from v1)

| id | type | next / options | offer_rewind_to | ambient |
|---|---|---|---|---|
| s1 | scene | s2 | | motes |
| s2 | scene | c1 | | sparkles |
| c1 | choice | up → a1 (kind), snooze → b1 (learn) | | sparkles |
| b1 | scene | b2 | | motes |
| b2 | scene | b3 | | motes |
| b3 | scene | a1 | c1 | sparkles |
| a1 | scene | a2 | | motes |
| a2 | scene | n1 | | motes |
| n1 | scene | c2 | | stars |
| c2 | choice | bed → d1 (kind), turn → e1 (learn) | | stars |
| e1 | scene | e2 | | stars |
| e2 | scene | d1 | c2 | sparkles |
| d1 | scene | end | | stars |
| end | ending (sticker `images/sticker.webp`) | | | zzz, origin [0.6, 0.36] |

14 nodes. Stickers: up to 2.

## Text changes from v1 (v2 rules)

- c1, c2: name was mid-sentence ("Bảy giờ rồi, {name} làm gì nhỉ?") → "Bảy giờ rồi! {name} ơi, mình làm gì nhỉ?".
- a1: "Chào {name}, chào buổi sáng!" (name mid-sentence) → "Chào buổi sáng, {name}!".
- b3: the lesson now says who speaks ("Lulu nói: …"), "không phải vội" kept as the plain explanation of "thong thả".
- e2: Lulu calls the hero "bạn" (v1: "{name} vặn kim rồi… mắt bé…") → "Bạn vặn kim rồi, nhưng trời vẫn tối. Mắt bạn vẫn buồn ngủ."
- n1: 45 → 36 words ("ngồi vẽ bằng bút màu" → "ngồi tô màu", kept the full clock-reading rule).
- English is new for every node. The sticker is now an AI picture (v1: SVG).

## Kit (since 2026-11-11: replaces v1's per-scene pictures)

clock_time is now a **kit story** (docs/kit.md): one bedroom (tidy_toys' `kit/room.png`, plus a daytime edit of it), sheets of poses and props, scenes composed by `stage.py`. Bác Đồng Hồ stays an SVG part (`clock.json`, `tool/clock_layer.py`) standing on a bedside-table prop; `icon_turn` and `icon_bed` are SVG clocks too (exact hands, one backwards arrow). Story text unchanged (vi recorded): only cues, node `poses`, `ambient_origin` change. Cover (v1 AI picture) and sticker (SVG-rendered clock) are kept.

### Rooms and spots (both rooms use tidy_toys' crop: bed on the left, window, door out of frame)
- **day** (`kit/room_day.png`, new Gemini edit of tidy_toys' room: morning sun through the window, lamp off): s1 s2 c1 b1 b2 b3 a1 a2.
- **night** (`kit/room_night.png` = copy of tidy_toys' `room.png`): n1 c2 e1 e2 d1 end.
- `in_bed`: hero lying / sitting in bed, head at the pillow (≈ tidy end_asleep [0.29, 0.575]); a blanket prop over the body or the legs.
- `bed_foot`: on the blanket near the foot of the bed. `pillow`: just above the pillow, left of the hero's head.
- `table`: the bedside table stands on the floor right of the bed's foot (≈ tidy's toy-box spot [0.85, 0.89]); the SVG clock stands on its top.
- `rug_mid` / `rug_left`: floor on the rug in front of the bed. `by_table`: floor just left of the table. `air_table`: in the air above-left of the clock.

### Scenes (layout → moves on words)
| node | room | layout (default) | cues |
|---|---|---|---|
| s1 `s1_ring` | day | hero `asleep` in_bed + blanket; table + clock 7:00 ring | "Reng reng" clock wiggle; "ngáp" hero → `lie_yawn`; "dụi mắt" → `lie_rub_eye` |
| s2 `s2_lulu_clock` | day | hero `lie_rub_eye` in_bed + blanket; Lulu `float` air_table; clock 7:00 | "Tưng" Lulu hop; "ngồi dậy" hero → `bed_sit_up`; "chỉ vào" Lulu → `point` (down right, at the clock) |
| c1 (reuses s2) | day | node poses hero `bed_sit_up`, Lulu `point` | |
| b1 `b1_snooze` | day | no hero part: `blanket_hidden` (child-sized mound, hair tuft at the pillow end) in bed; Lulu `float` over bed_foot; clock 7:00 | "Tích tắc" clock wiggle; "số sáu" clock → pose `half` (7:30); "chống cằm" Lulu → `chin` |
| b2 `b2_rush` | day | hero (day clothes) `oops` rug_mid; breakfast table (bread + milk, untouched) rug_left; clock 7:30 | "Ối" hero hop; "giơ chiếc tất" → `sock_up` |
| b3 `b3_lulu_fix` | day | hero `backwards_calm` rug_mid; Lulu `float` beside her shoulder (not touching); breakfast table; clock 7:30 | "xoay áo" Lulu → `glow` and hero → `front_smile`; "mỉm cười" hero hop |
| a1 `a1_stretch` | day | hero `bed_sit_up` in_bed + blanket over legs; Lulu `float` at pillow; clock 7:00 | "vươn vai" hero → `bed_stretch`; "mỉm cười" clock → `big`; "vỗ tay" Lulu → `clap`; "nhảy" Lulu hop |
| a2 `a2_ready` | day | hero (day clothes) `eat` by the breakfast table rug_left; Lulu `float` air mid; clock 7:30 | "đeo ba lô" hero → `backpack_wave`; "vẫy tay" hero hop; 2nd "vẫy tay" Lulu → `wave` |
| n1 `n1_nine` | night | hero `sit_color` rug_mid, paper + crayons in front; Lulu `float` air_table; clock 9:00 chime | "Boong" clock pulse; "hỏi" Lulu → `talk`; "ngẩng lên" hero → `sit_look_up` |
| c2 (reuses n1) | night | node poses hero `sit_look_up` | |
| e1 `e1_turn` | night | hero `reach` by_table, hands at the clock; paper + crayons on the rug; clock 9:00; no Lulu | "Cạch" clock → `turned` (8:00, swirly eyes); "ngáp" hero → `stand_yawn` |
| e2 `e2_lulu_back` | night | hero `stand_sleepy` by_table, one hand out to the left; Lulu `hold_hand` just left of her, paw at her hand (two sprites, not touching); clock 8:00 swirly | "Cạch" clock → `back` (9:00) |
| d1 `d1_goodnight` | night | hero `kneel_place` rug_mid; crayon cup (empty) + paper with crayons in front; Lulu `float` over bed_foot; clock 9:00 sleepy chime | "cất" cup → `cup_full`, paper → `paper_only`; "vẫy tay" hero → `kneel_wave`; "Boong" clock pulse |
| end `end_asleep` | night | hero `asleep` in_bed + blanket; Lulu `whisper` above and a little right of the head (≈ [0.47, 0.30]), leaning left toward it; cup (full) + paper on the rug; clock 9:00 asleep | "Tích tắc" clock wiggle; zzz origin at the head |

### Kit notes (beats shown differently; text unchanged)
- b1: the child under the blanket = the `blanket_hidden` prop (a child-sized mound with a hair tuft), no hero part. The long hand going from 12 to 6 is now a clock pose on "số sáu".
- b3: Lulu turns the shirt with magic (`glow`) instead of with her paws; the hero's pose swaps from backwards to front on the same word.
- e2: "Lulu nắm tay bé" = Lulu's paw drawn right at the hero's open hand (sheets never touch).
- d1: "Bé leo lên giường" ends the scene; the next node shows her in bed.
- c1/c2 keep reusing s2/n1 with node poses (no moves in those scenes, so the default state is right).

### Pose and prop lists
Shared with prepare_stuff_vacation (the same girl, pajamas, Lulu and room): sheets `hero_c`, `hero_d`, `hero_e`, `lulu_b` are made once, from this story's prompts, and copied into the vacation kit.
- reused from tidy_toys (copy): `hero_a` (`sit_look_up`), `hero_b` (`asleep`), `lulu_a` (`float`, `point`, `clap`, `glow`, `talk`, `whisper`), `props` (`blanket_lump`), `room` (night).
- `hero_c` (new, shared): `lie_yawn`, `lie_rub_eye`, `bed_sit_up`, `bed_stretch`, `sit_color`, `plop` (vacation).
- `hero_d` (new, shared): `kneel_place`, `kneel_wave`, `kneel_push`, `kneel_press`, `kneel_sad`, `kneel_fold` (last four vacation).
- `hero_e` (new, shared): `reach`, `stand_yawn`, `stand_sleepy`, `sit_backpack`, `lift_backpack`, `pull` (last three vacation).
- `hero_day` (new, day clothes: plain soft-yellow t-shirt, navy shorts): `oops`, `sock_up`, `backwards_calm`, `front_smile`, `eat`, `backpack_wave`.
- `lulu_b` (new, shared): `chin`, `hold_hand`, `wave`, `sit`, `pat`, `cheer` (last three vacation).
- `props_clock` (new): `bedside_table`, `breakfast`, `paper_crayons`, `paper_only`, `cup_empty`, `cup_full`, `blanket_hidden`.
- Icons: `icon_stretch` = `bed_stretch` sprite; `icon_snooze` = `asleep` + `blanket_lump`; `icon_bed` (sleepy clock with a moon) and `icon_turn` (8:00 clock + one anticlockwise arrow) = SVG from `clock.json`.
- New Gemini images: `room_day`, `hero_c`, `hero_d`, `hero_e`, `hero_day`, `lulu_b`, `props_clock` (7; vacation then needs only its props sheet).
