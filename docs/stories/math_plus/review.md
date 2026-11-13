VERDICT: FIX

## check_story.py
```
math_plus: 0 errors, 0 warnings
```

## FIX
- end (vi + en, node field): `ambient_origin` is `[0.5, 0.5]`, which is the middle of the room above the sheep meadow. The outline puts it at the sleeping hero's head, about [0.25, 0.50] on the bed by the left wall. The zzz would rise from the sheep, not from the child. → `"ambient_origin": [0.25, 0.50]` (re-measure from the hero's `asleep` placement once `stage.json` exists).

## NOTES (optional, not blocking)
- How I checked: I read every line in both languages with a=b=d=1 (c=2, e=3), with a=3,b=1,d=1 (c=4, e=5), with a=1,b=3,d=1 (c=4, e=5), and with a=1,b=1,d=3 (c=2, e=5). The arithmetic is right every time: c = a+b is 2 to 4 and e = c+d is 3 to 5. No number is 0. `near:c` and `near:e` stay between 1 and 5. The waiting spots (at most 3) and the field spots (5) are always enough. English stays grammatical for every number because "sheep" doesn't change and the lines use "they" / "make" only when there are 2 or more sheep (c ≥ 2, e ≥ 3). Numbers that start a sentence, including right after an opening quote, are capitalised by `spellNumbers`.
- How `counted` matches the text, per node:
  - s1 `{0, a}`: "cừu bông … chờ" with no number, which works for any a.
  - s2: the newcomers arrive on "nhảy qua" / "Over the fence", then `{count:a}`.
  - s3 `{a, b}`: they arrive on "nhảy qua" / "over the fence".
  - c1, b1, a1 `{c}`.
  - n1 `{c, d}`: they arrive on "nhảy qua" / "over the fence".
  - c2 through end `{e}`.
  - Every question is "every sheep you can see".
- Learn paths b1 and e1 say "Mình cùng đếm lại nhé" / "Let's count again together". They count with `{count:…}` and Lulu says the sum. They never say "sai" or "wrong", and `offer_rewind_to` is c1 / c2. Good.
- The `{name}` rule holds in every node and both languages: first word in s1, c1 and c2, last word in a1 and end, never in labels. The hero has no gender.
- s3 (vi): "Bên cửa **còn** {b} bạn cừu nữa" means they were there all along. But on screen the door is empty at the end of s2, and the b sheep only appear at the start of s3. The English ("Look, {b} more sheep by the door!") avoids this. Optional: "Nhìn kìa, bên cửa có {b} bạn cừu nữa!" (then move the Lulu `point` cue from "còn" to "Nhìn kìa").
- a1 (en): "wagging at {name}" leaves out what is wagging. More natural: "The sheep stand by the bed and wag their tails at {name}." (cue word "wag" instead of "wagging").
- s2: with a=3, the `arrive` walk (one sheep after another) has to finish before `{count:a}` starts hopping sheep 1…3. Check this when tuning cues on the real clips.
- I can't check poses yet because there is no art: hero `bed_awake`, `bed_point`, `bed_think`, `bed_clap`, `lie_yawn`, `asleep`, Lulu `float`, `glow`, `talk`, `point`, `clap`, `whisper`, and sheep `sleep`. Run `check_story.py --art` after staging. The flat fallback pictures (`a1_three`, `d1_five`, …) are staged with all five sheep, so they show a fixed count if the layers ever fail. That is an app/fallback concern, not a text one.
- Some quoted lesson lines run to about 13 Vietnamese syllables (b1, e1: `Lulu cười: "{a} bạn cừu, thêm {b} bạn nữa là {c} bạn cừu."`). That's fine because the speech is short and has a rhythm.
