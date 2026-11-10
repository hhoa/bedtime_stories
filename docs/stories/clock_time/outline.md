# clock_time: outline (v2 port of v1)

Port of v1 `../bedtime_story/docs/stories/clock_time/` (approved by the parent). Plot, beats, choices, option ids, node ids, graph, `offer_rewind_to`, ambient and moral are **kept as in v1**. Pictures are v1's (the girl and boy folders were identical: one girl hero drawn), Gemini's ✦ inpainted (the originals are gone, so the exact undo can't run). All audio is re-recorded.

- **Title:** vi `{name} và Bác Đồng Hồ tích tắc` · en `{name} and Mr. Tick-Tock`
- **Theme:** time
- **Hero:** girl (`tool/image_refs/girl.png`). The text never gives a gender: "bé" / "the little one".
- **Moral:** vi: Kim ngắn chỉ số bảy là giờ dậy, chỉ số chín là giờ ngủ; vặn kim không làm thay đổi giờ. · en: The clock tells us when it's time: short hand on seven, we get up; on nine, we go to bed. Turning the hands doesn't change the time.
- **Cast:** the hero, Lulu, and **Bác Đồng Hồ / Mr. Tick-Tock**, a round alarm clock with two bells, small feet and a face, on the bedside table in every scene. In scenes it is an SVG layer (`clock.json`, `tool/clock_layer.py`) so the numbers and hands are exact; AI draws it only on the cover and `icon_turn`. No grown-ups.
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

## Pictures

v1's 17 pictures, cut layers, poses and clock SVGs are reused (same layout and moves as v1: Lulu sits on the windowsill in b1, floats by the window in a2/n1). Redo:
- **s2_lulu_clock** (+ its plate and the `sit_up`, `point` poses): the clock had to sit on the windowsill because Lulu took the table, the `point` pose doesn't point, and the Lulu cut-out carries a piece of the table. New prompt: Lulu on the right half of the table, left half empty for the clock.
- **icon_turn**: two arrows going clockwise ("refresh"), not one arrow going backwards.
- **sticker** (new): the clock asleep with a tiny moon on one bell.
