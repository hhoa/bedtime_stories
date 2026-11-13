VERDICT: PASS

## check_story.py
```
tell_truth: 0 errors, 0 warnings
```

## FIX
(none)

Checked by hand as well:
- **Name rule, every node, both languages:** `{name}` appears once at most, always as the first word (s1, c1, b1, b2, a1, c2, e1, d1) or the last word (end, inside Lulu's quote). It is not used in s2, b3, a2, n1 or e2, and never in a label. No gender anywhere ("bé" / "the little one").
- **Outline fit:** the 14 nodes, images, ambients, `ambient_origin`, option ids, kinds, icons, `next` links, `offer_rewind_to` (b3 → c1, e2 → c2) and c2's start poses all match the outline.
- **Cues:** matching is in order and case-sensitive, so the repeated words land on the intended spot ("Tưng"/"tưng", "Boing"/"boing", "Xoạt"/"xoạt", "Swish"/"swish", a1's capital "Bạn" = the 2nd one, a1 en "so" found after "You're", not inside "softly"/"sorry").
- **Both paths happy:** b1–b3 (Lulu is briefly sad, the hero has a "stone" in the tummy, Lulu comforts with the moral, then rewind and on into a1) and e1–e2 (sticky teeth, a sleepy friendly germ, Lulu: "it's okay to forget", rewind, then d1). Both are gentle, short and not shaming. The vase never breaks, and the wet floor gets dried.

## NOTES (optional, not blocking)
- **c1 / c2 labels (vi): both start with "Nói".** "Nói thật: …" and "Nói: …" only differ from the second syllable on. The outline keeps them on purpose (Kit note 13, approved), and the icons plus the glowing cards help tell them apart. If the parent wants a sharper difference when heard, v1's story.json labels start differently: c1 "Thật ra, mình làm đổ" / "Không phải mình!" and c2 "Thật ra, mình quên rồi" / "Mình đánh rồi ạ". The English labels are fine as they are ("Tell…" / "Say…").
- **s1 and e2 run long:** about 12–14 s in vi and about 15–17 s in en, against the ~10 s target. s1 is the approved merge of two v1 scenes, and e2 holds the key line. If they feel long when recorded, the en text could be trimmed without losing a beat:
  - s1: "{name} is rolling a ball. On the table is Lulu's favourite vase. Bump! The ball hits the table leg. The vase tips over. Oops! It spilled! Water and flowers go all over the floor." (cue "table leg" stays)
  - e2: drop "with a kind smile" → "Lulu floats to the pillow."
- **b2 (en):** "{name} feels heavy in the tummy" is a little awkward. The outline's "{name} has a heavy feeling in the tummy, like a little stone inside." is more natural (the cues are unaffected).
- **e1 (en):** "Hmm, the teeth feel all sticky." → "Hmm, those teeth feel all sticky." would sound a bit more natural (the cue "sticky" is unaffected).
- **d1 (en):** "You told the truth, and you did it too." is a bit vague. A clearer option: "You told the truth, and you really brushed. Well done!" (the cue "cheers" is unaffected).
- **s1 (en) spelling:** "favourite" is British, but another bundled story uses US "color". "favorite" would make them consistent.
- **a1:** the Lulu move goes to [0.56, 0.55], not `by_hero` [0.56, 0.62]. This is intended (shoulder height of the standing hero, as the outline says). Confirm it on the still.
