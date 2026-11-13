# Math stories (`"section": "math"`)

The app has sections, picked on the first page after the welcome (`SectionsScreen`, `/`): **behavior** ("Bé ngoan" / "Being good", the original stories) and **math** ("Học toán" / "Numbers"). A story's `story.json` says which with `"section"` (missing = `behavior`); the section list is `/learn/<section>`. Stickers share one book; the profile groups them by section.

A math story is a normal story: same player, same JSON, same kit art, same audio pipeline, same `{name}` rule. Only the meaning of the two options changes.

## How a question works

| Story JSON | Behavior story | Math story |
|---|---|---|
| choice `text` | "What should we do?" | the question: "Có mấy quả táo nhỉ?" |
| option `kind` | the kind choice | **the right answer** |
| option `learn` | small natural consequence | **a near miss** (one more or one less, the other side…) |
| learn path | consequence → Lulu comforts → `offer_rewind_to` | **count again together** → `offer_rewind_to` → right answer |
| sticker | kind picked first | right answer picked first |

- The learn path never says "sai" / "wrong", never sounds disappointed. It is "Mình cùng đếm lại nhé!": Lulu or the hero counts slowly (`{count:c}`: each object hops on its number), then the rewind offer. If the kid says no, the story continues into the right-answer path (Lulu says the answer).
- The right-answer path celebrates the counting, not the kid being clever: "{c} quả táo đây rồi! {count:c}!"
- 1 or 2 questions per story (stickers and the `sticker_<n>` lines stop at 2).
- Option labels are the spoken answer, short: "{n} quả táo" / "{n} sheep". No `{name}`.

## New numbers every play (`"math"` block)

A math story is a **template**: each time it is opened (or "read again") the app draws new numbers, so the kid can play it again and again. A rewind keeps the numbers of that play. The cards swap sides at random, so the kid has to count, not remember "left".

```json
"math": {
  "counter": "sheep",                       // counted parts are sheep1, sheep2, … (left to right = counting order)
  "icon": "images/layers/kit_sheep.webp",   // one counted object, transparent: drawn N times on the answer cards
  "vars": {"a": [1, 3], "b": [1, "4 - a"], "c": "a + b", "d": [1, "5 - c"], "e": "c + d"},
  "field": [[0.33, 0.80], [0.41, 0.75], [0.49, 0.80], [0.57, 0.75], [0.65, 0.80]],   // spot of object k (pivot)
  "wait":  [[0.80, 0.74], [0.85, 0.69], [0.90, 0.74]]                                 // where newcomers wait
}
```

- `vars` in order: a range `[min, max]` (ends may use the vars above) or a fixed expression. Only `+`, `-`, whole numbers and vars. `check_story.py` tries every combination: each must stay 1…10, answers 1…(number of field spots), and every `counted` must fit.
- Text tokens (both languages, in lines and labels):
  - `{a}`: the number, read from the shared clip `assets/audio/ui/<lang>/num_<n>.m4a` ("hai" / "two"). Shown as a word, capitalised at a sentence start.
  - `{count:c}`: "một, hai, ba" up to c; object k hops on number k (exact, no cue timing needed). `{count:c:sleep}`: object k switches to pose `sleep` instead.
  - `{n}`: only in option labels: that card's own number (`"label": {"vi": "{n} bạn cừu", "en": "{n} sheep"}`).
- Node `"counted": {"field": "a", "wait": "b"}`: objects 1…a stand on their field spots, the next b on the waiting spots, the rest are hidden. A choice reusing a scene's picture sets its own `counted`.
- Cue `{"word": "nhảy qua", "part": "sheep", "action": "arrive"}`: every waiting object walks to its field spot, one after another.
- Options: `"answer": "c"` on the `kind` option (right), `"answer": "near:c"` on the `learn` option (one more or one less, never 0, never above the field). `icon` may be left out (the cards draw `math.icon` N times under the digit).
- **Write so any number fits.** English never agrees with the number: "{b} more sheep wait by the door", not "is waiting"; nouns that don't change (sheep, fish) or "{n} of them"… Vietnamese numbers need no agreement. Don't write a count in words ("hai bạn cừu nữa"): use `{b}`.
- Each line is cut at every token; the words between tokens are separate clips (`<node>_p0`, `_p1`…). Fewer tokens = smoother voice: say the numbers where they matter (question, the count, Lulu's lesson), and let other lines speak generally ("các bạn cừu", "the sheep").
- **Recording**: the parent reads each number line **in one go** with the example numbers `gen_audio.py --list` prints (`<key>_full.m4a`, name left out). `tool/split_numbers.py <id>` lines the known words up with the recording (torchaudio MMS_FA forced alignment, on this machine), cuts at the quietest moment around each number and writes the pieces (`<key>_p<i>.wav`); the full take goes to `audio_backup/`. Then `clean_audio.py` as usual. `num_1` … `num_10` are recorded once per language (UI lines). If the joins sound too choppy for a line, the fallback is the cloned voice reading every number variant of it (more clips to check, bigger story).

## Curriculum (one topic per story, in this order)

1. **Đếm 1-5 / Counting 1-5**: how many? (objects in a row, then scattered)
2. **Đếm 6-10 / Counting 6-10**
3. **Nhiều hơn / ít hơn — more / fewer**: two groups, which has more? (counts differ by ≥ 2 at first)
4. **To / nhỏ — big / small**: same prop at two sizes (stage `size`), which is bigger / smaller?
5. **Cộng trong phạm vi 5 — adding within 5**: "2 apples, Lulu brings 1 more: how many now?" (the new object `move`s in on its word)
6. **Trừ trong phạm vi 5 — taking away within 5**: "3 cookies, Lulu eats 1" (the eaten one moves behind something drawn later; nothing disappears inside a scene)
7. **Chia đều — sharing equally**: "4 strawberries for the hero and Lulu: how many each?" (objects `move` to two plates one by one, "một cho bé, một cho Lulu…")

Later topics build on earlier ones; `story-idea-checker` compares a new math idea with the other math stories (same topic + same objects = DUPLICATE).

## Writing rules (on top of CLAUDE.md)

- Numbers ≤ 10 for counting, sums and differences ≤ 5. Both options plausible, but clearly different to a 3-year-old (2 vs 3, not 7 vs 8; never 0).
- **The picture must match the words exactly.** Every counted object is its own part on the stage; no AI picture ever shows a count (AI miscounts). Say the number in the line and show it on screen at the same moment.
- Objects are familiar, countable at a glance, all the same kind in one question: apples, stars, cookies, ducks, blocks. Spread out, never overlapping.
- Numbers in the text are tokens (`{a}`, `{count:c}`), never digits or fixed words, so every play can use new numbers.
- Still a bedtime app: night or evening, calm, warm. A sleepy ending is welcome (count the stars, count the sheep) but not required.
- 10-14 nodes like any story.

## Art (kit)

- One **counting-objects sheet**: the object alone, several times, apart on a plain background (`sprite_sheet.py` cuts them; use one clean sprite). Size variants only for big/small (or use stage `size`).
- `stage.json`: one part per object, kinds numbered left to right in counting order (`apple1`, `apple2`, …), **all of them in every scene at their field spots** (the app hides, places and moves them per node from `counted`). Several parts with the same sprite share one layer file. Read the field / waiting spots off a `--guides` still into `math.field` / `math.wait`.
- Answer cards are drawn by the app (`math.icon` × N under the digit). For a fixed-number picture elsewhere, `stage.py` icons can still compose objects plus a big digit, e.g.
  `"icon_three": [{"sprite": "props/apple", "at": [0.25, 0.62], "size": 0.3}, {"sprite": "props/apple", "at": [0.5, 0.62], "size": 0.3}, {"sprite": "props/apple", "at": [0.75, 0.62], "size": 0.3}, {"numeral": 3, "at": [0.5, 0.24], "size": 0.3}]`
  (`numeral`: amber Baloo 2 digit with a dark outline, centred on `at`, `size` = height fraction; `tool/stage.py`).
- Cover and sticker as usual (the sticker may be the object with a star, never a number).

## Section cards

`AppConstants.sectionArt`: behavior uses `tidy_toys`' cover and math `assets/images/section_math.svg` until the Gemini section cards are made (800×600, saved as `assets/images/section_<name>.webp`). Tapping a card says its name (`assets/audio/ui/<lang>/section_<name>.m4a`, lines in `tool/gen_audio.py` `UI_LINES`).

Adding a third section: a value in `StorySection` (`lib/core/models/story_section.dart`), its strings (`sectionTitle`, `sectionSubtitle`, `sectionEmpty`), art in `sectionArt`, `UI_LINES` + clip, `SECTIONS` in `tool/check_story.py`.
