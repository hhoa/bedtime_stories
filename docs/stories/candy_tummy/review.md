VERDICT: PASS

## check_story.py
```
candy_tummy: 0 errors, 0 warnings
```

## FIX
(none)

## NOTES (optional, not blocking)
- Round 2. All first-round items are in story.json:
  - c2 vi labels now start differently: "Trên bàn nhỏ, mai ăn" and "Ngủ chung giường với bé".
  - b2 is trimmed to 40 words in each language, and the "little tears" wording is gone. The cues were updated to match: vi `hũ lại`, en `tears`.
  - b1 en: "It feels grumpy from too much candy."
  - a1 en: "just right". d1 en: "You saved them for tomorrow!"
- Name rule, checked by hand on all 12 nodes in both languages:
  - `{name}` opens the line in s1, c1, a1, b1, c2, e1 and d1.
  - It closes the line in end (inside the quote).
  - s2, b2, n1 and e2 use "bé" / "the little one".
  - The name is never in a label and never appears twice in a line. The hero has no gender anywhere. OK.
- Graph:
  - b2 has `offer_rewind_to: c1` and goes to n1.
  - e2 has `offer_rewind_to: c2` and goes to d1.
  - Both learn consequences are gentle, and Lulu fixes each one in the next scene.
  - Images and ambients are unchanged from round 1 and match the outline.
- Sentence length: every sentence is 12 words or fewer in both languages. One idea per sentence. Each scene can be followed by ear alone.
- Outline sync: outline.md still has the old wording in four places. These are deliberate review changes and the story beats are unchanged. Optional: update outline.md lines 22/162 (b2 vi + en), 26 (d1 "great saving!"), 27/196 (c2 vi learn label) and 145 (b1 en) so later agents and the recording script compare against the current text.
- c2 vi learn label "Ngủ chung giường với bé" uses "bé" as the child talking about themself. That is natural for a small child, and the en label says "me". Fine.
