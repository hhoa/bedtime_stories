# prepare_stuff_vacation: outline (v2 port of v1)

Port of v1 `../bedtime_story/docs/stories/prepare_stuff_vacation/` (approved by the parent). Plot, beats, choices, option ids, node ids, graph, `offer_rewind_to`, ambient and moral are **kept as in v1**. The Vietnamese text is v1's `story.json` word for word, except where v2's `{name}` rule needs a fix (name only in a question to the kid, at the start or end of its sentence; elsewhere "bé"). Each node says **unchanged from v1** (v1 vi clip can be reused) or **changed** (re-record).

- **Title:** vi `{name} và chiếc ba lô nhỏ` (unchanged) · en `{name} and the Little Backpack`
- **Theme:** preparation
- **Hero:** girl (`tool/image_refs/girl.png`). The text never gives a gender: "bé" / "the little one".
- **Moral:** vi: Mình chỉ mang đồ cần và gấp gọn gàng, ba lô nhỏ sẽ nhẹ, bé tự đeo được. · en: When we pack only what we need and fold it neatly, our little backpack is light and ready, and we can carry it ourselves.
- **Cast:** the hero and Lulu. No extra character: ba mẹ are only mentioned kindly in the text; their big suitcase by the door is the only sign of them.
- **Not repeated:** no v2 stories exist yet. (v1 neighbours: `tidy_toys` = putting toys back home, `sleep_late`, `tell_truth`; this one is about getting ready: choosing what you need, folding neatly.)

## Choices

### c1: what goes into the little backpack?
Question: vi `{name} cho gì vào ba lô?` · en `{name}, what goes in the backpack?`

- **Kind (`need`)**: label vi `Chỉ lấy đồ cần thôi` · en `Just what we need`. The hero packs the water bottle, the sand bucket, and the sun hat goes on last (a1). The backpack stays small and light.
- **Learn (`all`)**: label vi `Mang hết đồ chơi` · en `All the toys`. The hero stuffs in all the toys (blocks, ball, one more block); the backpack bulges, is too heavy to budge, and the hero plops down, tired and puffing. Lulu sits beside her, they take the toys out together. Lulu: vi **"Mình chỉ mang đồ cần thôi. Ba lô nhẹ thì mình mới tự đeo được. Đi chơi vui hơn nhiều!"** · en **"We only bring what we need. When it's light, we can carry it ourselves. Then the trip is much more fun!"** → rewind offer to c1, then a1.

### c2: how do the clothes go in?
Question: vi `{name} cho áo quần vào thế nào?` · en `{name}, how do the clothes go in?`

- **Kind (`fold`)**: label vi `Gấp gọn từng cái` · en `Fold each one`. The hero folds the shirt into a small square with Lulu's help; the clothes lie flat and there is room for the hat.
- **Learn (`stuff`)**: label vi `Nhét vội vào` · en `Stuff them in fast`. The hero scrunches the clothes and pushes down hard: the clothes crumple and the sun hat gets squashed flat; the hero feels a little sad. Lulu pats the hat round again. Lulu: vi **"Mình gấp gọn từng chiếc nhé. Áo quần phẳng phiu, ba lô còn chỗ cho mũ nữa."** · en **"Let's fold each one neatly. Smooth, flat clothes leave room for the hat too."** → rewind offer to c2, then d1.

## Node graph

| id | type | next / options | offer_rewind_to | ambient |
|---|---|---|---|---|
| s1 | scene | s2 | | stars |
| s2 | scene | c1 | | sparkles |
| c1 | choice | need → a1 (kind), all → b1 (learn) | | sparkles |
| b1 | scene | b2 | | stars |
| b2 | scene | b3 | | stars |
| b3 | scene | a1 | c1 | sparkles |
| a1 | scene | c2 | | stars |
| c2 | choice | fold → d1 (kind), stuff → e1 (learn) | | stars |
| e1 | scene | e2 | | stars |
| e2 | scene | d1 | c2 | sparkles |
| d1 | scene | d2 | | stars |
| d2 | scene | end | | sparkles |
| end | ending (sticker `images/sticker.webp`) | | | zzz, `ambient_origin` at the sleeping head (planned about [0.25, 0.50]; confirm from the final picture) |

13 nodes (same as v1). Paths: kind-kind = 9 nodes, learn-learn = 13. Stickers: up to 2.

**Where the name is said (parent edit, 2026-11-09):** c1, c2 (questions), and at the start of b2, a1, d1 and end (`{name} kéo quai ba lô.`, `{name} cho chai nước…`, `{name} gấp áo…`, `{name} chui vào chăn ấm…`). s2 says "Bé sắp đi biển à?", Lulu's good-night has no name. The node notes below still say "bé" for those lines: story.json is the source of truth. Vietnamese identical to v1 (clips reusable): c1, c2, b2, b3, a1, e2, d1.

Continuity (from v1):
- In a1 the toys are out of the backpack on both paths (learn: taken out in b3). a1 = bottle and bucket go in, hat waits beside, then the clothes are noticed.
- The hat sits beside the backpack in a1/c2. In e1 it is squashed on top of the crumpled clothes; e2 makes it round again, so d1 starts with a round hat.
- Ba mẹ never appear and never scold; they are excited and trust the child.

## Kit (since 2026-11-11: replaces the per-scene pictures)

prepare_stuff_vacation is now a **kit story** (docs/kit.md). Its room is the one tidy_toys' room was made from (this story's `end_asleep` with everything removed), so the kit reuses that room in two crops, the shared girl / Lulu sheets made for clock_time and tidy_toys, and one new props sheet. Story text unchanged (vi recorded and approved): only cues, node `poses`, `ambient_origin` and c2's picture change. Cover and sticker (AI pictures) are kept. The **Scenes** section below keeps the v1-era picture notes for the beats and the prop states; the layouts here replace them.

### Rooms and spots (`kit/room_night.png` = copy of tidy_toys' `room.png`, night only)
- **door** crop (right three quarters: foot of the bed on the left, window, rug, door on the right): s1 → d2.
- **bed** crop (tidy_toys' crop: whole bed, door out of frame): end.
- `suitcase_spot`: floor just left of the door. `rug_mid`: hero on the rug. `rug_right`: the backpack, right of the hero. `rug_front`: bottle, bucket, hat in front. `rug_left`: toys (blocks + ball). `air`: Lulu above the rug.
- end: backpack (zipped, hat on top) and suitcase on the floor at the right edge of the bed crop, just where the door begins (the door itself is out of frame: "bên cửa").

### Scenes (layout → moves on words)
| node | room | layout (default) | cues |
|---|---|---|---|
| s1 `s1_backpack` | door | hero `sit_backpack` rug_mid; blocks + ball rug_left; bottle, bucket, hat rug_front; suitcase; no Lulu | "Vali" suitcase wiggle; "giơ" hero → `lift_backpack` |
| s2 `s2_lulu` | door | hero `sit_look_up` rug_mid; backpack `backpack_empty` rug_right; props as s1; Lulu `float` air | "Vèo" Lulu hop; "xếp" Lulu → `point`; "ba lô" backpack wiggle |
| c1 (reuses s2) | door | node poses Lulu `point` | |
| b1 `b1_stuffed` | door | hero `kneel_push` rug_mid; backpack `backpack_toys` (blocks + ball are inside: no toy parts); bottle, bucket, hat, suitcase | "Nhét" hero hop; "nhét" backpack wiggle; "phồng" backpack pulse |
| b2 `b2_heavy` | door | hero `pull` left of the backpack, fists at its top strap; `backpack_toys`; others as b1 | "kéo" backpack wiggle; "Hự" / "hự" hero hop; "phịch" hero → `plop` |
| b3 `b3_lulu_help` | door | hero `plop`; Lulu `sit` beside her on the rug; blocks + ball back on the rug next to `backpack_empty` | "Lulu" Lulu hop; "lấy" blocks wiggle; "Mình" Lulu → `talk` |
| a1 `a1_pack` | door | hero `sit_play` rug_mid; `backpack_empty` rug_right; bottle and bucket in front of the backpack (drawn before it); hat beside; clothes `clothes_flat` rug_front; toys far left; Lulu `float` air | "chai nước" hero → `kneel_place` and bottle moves behind the backpack's top (in); "xô cát" bucket wiggle, then moves in the same way; "mũ" hat hop; "áo" Lulu → `point` (at the clothes); "quần đùi" clothes wiggle |
| c2 `c2_pack` (new staged scene = a1's end state) | door | hero `kneel_place`; bottle and bucket gone (in the backpack); hat, clothes, Lulu `point` | |
| e1 `e1_squash` | door | hero `kneel_press`; `backpack_lumpy`; clothes `clothes_crumpled` on its top; hat `hat_round` on top of the clothes; no Lulu | "vo" clothes wiggle; "Bẹp" hat → `hat_squashed` + pulse; "nhăn" clothes wiggle; "nhìn" hero → `kneel_sad` |
| e2 `e2_hat` | door | hero `kneel_sad`; hat `hat_squashed` on the rug in front; Lulu `float` low beside the hat; `clothes_crumpled` on the rug; `backpack_empty` | "bộp" Lulu → `pat` + hop; "tròn" hat → `hat_round`; "gấp" clothes wiggle |
| d1 `d1_fold` | door | hero `kneel_fold` (hands smoothing on the floor); `clothes_flat` in front of her; hat beside `backpack_empty`; Lulu `float` | "gấp" hero wiggle; "Lulu" Lulu hop; "Gấp" clothes → `clothes_folded` + wiggle; "xong" hero → `kneel_happy`; "rồi" Lulu → `clap` |
| d2 `d2_ready` | door | hero `kneel_place`; `backpack_zipped` next to the suitcase; hat on the rug beside it; Lulu `float` | "Rẹt" backpack wiggle; "mũ" hat moves onto the backpack's top + hop; "vali" suitcase wiggle; "reo" Lulu → `cheer`; "giỏi" hero → `kneel_happy` |
| end `end_asleep` | bed | hero `asleep` in bed + blanket; Lulu `whisper` at the pillow; `backpack_ready` (zipped + hat on top, one sprite) and suitcase at the right edge | "Ba lô" backpack pulse; "Lulu" Lulu → `whisper`; zzz at the head |

### Kit notes
- Things put into the backpack slide behind its front (drawn before it): nothing vanishes mid-scene.
- c2 gets its own staged picture (`c2_pack`) so the choice shows a1's end state (a choice reusing a1 would show the bottle and bucket back on the rug).
- end: the door is just out of frame; the backpack stands at the edge where the door begins.
- Lulu's paws never hold the hat (sheets never touch): she pats the air above it.

### Pose and prop lists
- reused from tidy_toys (copy): room (`room_night`), `hero_a` (`sit_look_up`, `sit_play`, `kneel_happy`), `hero_b` (`asleep`), `lulu_a` (`float`, `point`, `talk`, `clap`, `whisper`), `props` (`blocks`, `ball`, `blanket_lump`).
- shared with clock_time (copy once clock_time's are made): `hero_c` (`plop`), `hero_d` (`kneel_place`, `kneel_push`, `kneel_press`, `kneel_sad`, `kneel_fold`), `hero_e` (`sit_backpack`, `lift_backpack`, `pull`), `lulu_b` (`sit`, `pat`, `cheer`).
- `props_trip` (new, the only Gemini image): `suitcase`, `backpack_empty`, `backpack_toys`, `backpack_lumpy`, `backpack_zipped`, `hat_round`, `hat_squashed`, `bottle`, `bucket`, `clothes_flat`, `clothes_crumpled`, `clothes_folded`. `backpack_ready` = `backpack_zipped` + `hat_round` (stage.json `sprites`).
- Icons from sprites: `icon_backpack` (`backpack_zipped` + `bottle` + `hat_round`), `icon_toys` (`backpack_toys` + `blocks`), `icon_fold` (`clothes_folded`), `icon_scrunch` (`clothes_crumpled` + speed lines).

## Scenes

Every picture uses the **Setting** below. Hero outfit in every picture: soft mint-green pajamas with tiny white stars (night before the trip). Props stay the same in every picture:
- **little backpack**: a small rounded soft-orange kid backpack with a yellow star on its front pocket and two straps;
- **big suitcase** (ba mẹ's): a big upright teal suitcase with a handle, little wheels and a small red heart tag, standing beside the door;
- **sun hat**: a round straw sun hat with a wide brim and a pink ribbon;
- **water bottle**: a light-blue kid water bottle with a white cap;
- **sand bucket**: a small red sand pail with a handle and a little yellow spade;
- **clothes**: a light-blue t-shirt and yellow shorts;
- **toys**: a few colourful wooden blocks and a small red-and-white ball.

(v1-era picture notes: beats and prop states. Layouts and cues: **Kit** above.)

### s1 — `s1_backpack.webp` — stars — **changed**
- **Lời kể (vi):** Mai cả nhà mình đi biển! Vali to của ba mẹ đã xếp xong rồi. Ba mẹ tin bé tự xếp được ba lô nhỏ. Bé giơ ba lô lên, vui quá!
  - changed: `Ba mẹ tin {name} tự xếp…` → `Ba mẹ tin bé tự xếp…`
- **Narration (en):** Tomorrow the whole family goes to the beach! Mom and Dad's big suitcase is all packed. They trust the little one to pack the small backpack. Up goes the backpack, hooray!
- **Picture:** Night, crescent moon in the window, warm lamp light. {hero} sits cross-legged in the middle of the soft rug, happy, holding the empty little orange backpack (open, flap back) in both hands on the lap. Ba mẹ's big teal suitcase stands upright beside the door on the right. On the rug around {hero}: a few wooden blocks and the red-and-white ball on one side; the straw sun hat, the light-blue water bottle and the red sand bucket on the other side. Lulu is not in the picture.
- **Cut:** `hero` (the backpack in her hands is cut with her). Plate: hero.
- **Poses:** hero `lift` — holds the open backpack high above the head with both hands, beaming, mouth open in a happy laugh.
- **Hotspots:** `suitcase`.
- **Cues:** vi `Vali` → suitcase wiggle, `giơ` → hero pose `lift` · en `suitcase`, `Up`.

### s2 — `s2_lulu.webp` — sparkles — **changed**
- **Lời kể (vi):** Vèo! Lulu lấp lánh bay vào phòng. "Ồ! {name} sắp đi biển à? Mình cùng xếp ba lô nhé!"
  - changed: `"Ồ, {name} sắp đi biển à?` → `"Ồ! {name} sắp đi biển à?` (comma → "!" so the name starts its question)
- **Narration (en):** Whoosh! Lulu flies into the room, all sparkly. "Oh! {name}, are you off to the beach? Let's pack the backpack together!"
- **Picture:** Night, crescent moon in the window. Lulu floats in the air near the window, softly glowing, happy, a few tiny sparkles trailing behind her. {hero} sits on the soft rug, looking up at Lulu with a surprised, happy face, hands resting on the knees; the empty open little backpack stands on the rug in front of {hero}, not touched. The sun hat, water bottle, sand bucket, blocks and ball still lie on the rug. The big suitcase by the door.
- **Cut:** `hero`, `lulu` (not touching). Plate: hero, lulu.
- **Poses:** lulu `wave` — waves one paw high, smiling big; lulu `point` — points one paw down at the open backpack. hero `clap` — claps both hands in front of the chest, delighted.
- **Hotspots:** `backpack`, then `lulu`.
- **Cues:** vi `Vèo` → lulu hop (or pose `wave`), `xếp` → lulu pose `point` + backpack wiggle · en `Whoosh`, `pack`.

### c1 — reuses `s2_lulu.webp` — sparkles — **unchanged from v1**
- **Câu hỏi (vi):** {name} cho gì vào ba lô?
- **Question (en):** {name}, what goes in the backpack?
- Options: `need` (kind) vi `Chỉ lấy đồ cần thôi` · en `Just what we need`, icon `icon_backpack.webp`; `all` (learn) vi `Mang hết đồ chơi` · en `All the toys`, icon `icon_toys.webp`. Labels unchanged from v1.

### b1 — `b1_stuffed.webp` — stars — **changed**
- **Lời kể (vi):** Nào khối gỗ, nào quả bóng, bé nhét hết vào ba lô. Nhét, nhét! Thêm một khối gỗ nữa. Ba lô phồng to, tròn vo!
  - changed: `…, {name} nhét hết vào ba lô.` → `…, bé nhét hết vào ba lô.`
- **Narration (en):** A block, a ball, the little one pushes everything in. Push, push! One more block. The backpack gets big and round!
- **Picture:** Night, warm lamp light. {hero} kneels on the soft rug beside the little orange backpack, which is bulging round and fat, wooden blocks and the red-and-white ball poking out of its open top. {hero} holds one last wooden block up in one hand, determined and cheerful, not touching the backpack. The rug is now empty of toys. The sun hat, bottle and bucket lie a little further away. Lulu is not in the picture.
- **Cut:** `hero`. Plate: hero.
- **Poses:** hero `push` — leans forward and pushes the block into the top of the bulging backpack with both hands, cheeks puffed with effort.
- **Hotspots:** `backpack`.
- **Cues:** vi `Nhét` → hero pose `push`, `nhét` → backpack wiggle, `phồng` → backpack pulse · en `Push`, `push`, `big`.

### b2 — `b2_heavy.webp` — stars — **changed**
- **Lời kể (vi):** Bé kéo quai ba lô. Hự, hự! Ba lô nặng quá, chẳng nhúc nhích gì cả. Bé ngồi phịch xuống, thở phì phò, mệt ơi là mệt.
  - changed: `{name} kéo quai ba lô.` → `Bé kéo quai ba lô.`
- **Narration (en):** The little one tugs the strap. Huff, huff! It's so heavy, it won't move at all. Plop! The little one sits down, puffing, oh so tired.
- **Picture:** Night, warm lamp light. The fat bulging little backpack (blocks and ball poking out) sits on the rug, not moved. {hero} sits on the rug right beside it, plopped down with legs out, hands resting on the rug behind, a tired face with puffed-out cheeks (sleepy-tired, not crying), three tiny soft white puff clouds near the mouth; {hero} does not touch the backpack. Lulu is not in the picture.
- **Cut:** `hero`. Plate: hero.
- **Poses:** hero `pull` — standing beside the backpack, leaning back, both hands gripping its top handle and pulling hard, cheeks puffed, eyes squeezed (starting pose, node `"poses": {"hero": "pull"}`); hero `plop` — sitting exactly as in the base picture, tired and puffing (so a cue can switch back).
- **Hotspots:** `backpack`.
- **Cues:** vi `kéo` → backpack wiggle, `Hự` / `hự` → hero hop, `phịch` → hero pose `plop` · en `tugs`, `Huff`, `huff`, `Plop`.

### b3 — `b3_lulu_help.webp` — sparkles — **unchanged from v1** (offer_rewind_to c1)
- **Lời kể (vi):** Lulu ngồi xuống cạnh bé. Hai bạn cùng lấy đồ chơi ra. "Mình chỉ mang đồ cần thôi. Ba lô nhẹ thì mình mới tự đeo được. Đi chơi vui hơn nhiều!"
- **Narration (en):** Lulu sits down beside the little one. Together they take the toys out. "We only bring what we need. When it's light, we can carry it ourselves. Then the trip is much more fun!"
- **Picture:** Night, soft glow. Lulu sits on the rug, softly glowing, beside the bulging little backpack, lifting one wooden block out of its top with both paws, a gentle smile. {hero} sits on the other side of the backpack, holding the red-and-white ball in both hands, a calm small smile. They do not touch each other. A few wooden blocks already lie back on the rug in front.
- **Cut:** `hero`, `lulu` (the block in Lulu's paws goes with Lulu). Plate: hero, lulu.
- **Poses:** lulu `explain` — holds one paw up gently as if explaining, warm smile; hero `nod` — smiles and nods, ball in the lap.
- **Hotspots:** `blocks` (the blocks on the rug), `backpack`, then `lulu`.
- **Cues:** vi `Lulu` → lulu hop, `lấy` → blocks wiggle, then lulu pose `explain` on `Mình` · en `Lulu`, `take`.

### a1 — `a1_pack.webp` — stars — **changed**
- **Lời kể (vi):** Bé cho chai nước và xô cát vào ba lô. Chiếc mũ để bên cạnh, cho vào sau cùng. Ơ, còn áo với quần đùi nữa!
  - changed: `{name} cho chai nước…` → `Bé cho chai nước…`
- **Narration (en):** The little one puts in the water bottle and the sand bucket. The sun hat waits beside it, to go in last. Oh, there's still the shirt and shorts!
- **Picture:** Night, warm lamp light. The little orange backpack stands open and slim on the rug; the red sand bucket peeks out of its top. {hero} kneels beside it holding the light-blue water bottle in both hands at the chest, smiling, not touching the backpack. The straw sun hat lies on the rug on the other side of the backpack. The light-blue t-shirt and yellow shorts lie flat, unfolded, on the rug in front. Lulu sits on the rug a little apart, smiling. The toys are in a small heap far to the side.
- **Cut:** `hero` (the bottle in her hands goes with her), `lulu`. Plate: hero, lulu.
- **Poses:** hero `put_in` — leans forward and puts the water bottle into the open backpack; lulu `point` — points one paw at the t-shirt and shorts, eyebrows up, "oh!".
- **Hotspots:** `bucket`, `hat`, `clothes`, `backpack`, then `lulu`. (The bottle is in the hero's hands: its cue uses the hero pose.)
- **Cues:** vi `chai nước` → hero pose `put_in`, `xô cát` → bucket wiggle, `mũ` → hat hop, `áo` → lulu pose `point` + clothes wiggle · en `bottle`, `bucket`, `hat`, `shirt`.

### c2 — reuses `a1_pack.webp` — stars — **unchanged from v1**
- **Câu hỏi (vi):** {name} cho áo quần vào thế nào?
- **Question (en):** {name}, how do the clothes go in?
- Options: `fold` (kind) vi `Gấp gọn từng cái` · en `Fold each one`, icon `icon_fold.webp`; `stuff` (learn) vi `Nhét vội vào` · en `Stuff them in fast`, icon `icon_scrunch.webp`. Labels unchanged from v1.

### e1 — `e1_squash.webp` — stars — **changed**
- **Lời kể (vi):** Bé vo áo quần lại, ấn thật mạnh xuống. Bẹp! Áo nhăn nhúm, chiếc mũ cũng bẹp dí. Bé nhìn chiếc mũ, thấy hơi buồn.
  - changed: `{name} vo áo quần lại,…` → `Bé vo áo quần lại,…`
- **Narration (en):** The little one scrunches up the clothes and pushes down hard. Squish! The clothes are all crumpled, and the hat is squashed flat. The little one looks at the hat and feels a bit sad.
- **Picture:** Night, warm lamp light. The little orange backpack on the rug, a lumpy ball of crumpled light-blue and yellow clothes bulging out of its top, the straw sun hat squashed flat like a pancake on top of the lump. {hero} kneels beside it, hands in the lap, looking at the flat hat with a small sad pout (a little sad, no tears), not touching the backpack. Lulu is not in the picture.
- **Cut:** `hero`. Plate: hero.
- **Poses:** hero `press` — leans over and presses down hard on top of the backpack with both hands, cheeks puffed (starting pose, node `"poses": {"hero": "press"}`); hero `sad` — kneeling as in the base picture, looking at the flat hat, small sad pout.
- **Hotspots:** `clothes`, `hat`, `backpack`.
- **Cues:** vi `vo` → clothes wiggle, `Bẹp` → hat pulse, `nhăn` → clothes wiggle, `nhìn` → hero pose `sad` · en `scrunches`, `Squish`, `crumpled`, `looks`.

### e2 — `e2_hat.webp` — sparkles — **unchanged from v1** (offer_rewind_to c2)
- **Lời kể (vi):** Lulu vỗ nhẹ, bộp bộp, chiếc mũ tròn lại như cũ. "Mình gấp gọn từng chiếc nhé. Áo quần phẳng phiu, ba lô còn chỗ cho mũ nữa."
- **Narration (en):** Lulu pats it gently, pat, pat, and the hat is round again. "Let's fold each one neatly. Smooth, flat clothes leave room for the hat too."
- **Picture:** Night, soft glow. Lulu sits on the rug, softly glowing, holding the straw sun hat round and good as new in both paws, smiling. {hero} sits close beside Lulu (not touching), a small relieved smile. The light-blue t-shirt and yellow shorts lie unrolled, a bit wrinkled, on the rug in front of them; the little backpack stands open behind.
- **Cut:** `hero`, `lulu` (the hat in Lulu's paws goes with Lulu). Plate: hero, lulu.
- **Poses:** lulu `pat` — pats the top of the hat with one paw, eyes happily closed; hero `smile` — smiles wide, hands together.
- **Hotspots:** `clothes`, then `lulu`. (The hat is in Lulu's paws: hat cues use lulu.)
- **Cues:** vi `bộp` → lulu pose `pat`, `bộp` → lulu hop, `gấp` → clothes wiggle · en `pat`, `pat`, `fold`.

### d1 — `d1_fold.webp` — stars — **changed**
- **Lời kể (vi):** Bé gấp áo thành một hình vuông nhỏ. Lulu giúp một tay. Gấp, gấp, xong rồi! Áo quần nằm phẳng phiu, còn chỗ cho mũ.
  - changed: `{name} gấp áo…` → `Bé gấp áo…`
- **Narration (en):** The little one folds the shirt into a small square. Lulu lends a paw. Fold, fold, all done! The clothes lie nice and flat, with room for the hat.
- **Picture:** Night, warm lamp light. {hero} sits on the rug folding the light-blue t-shirt in half on the lap with both hands, concentrating with a little smile. Lulu sits beside {hero} (not touching), one paw pressing a neatly folded square of yellow shorts flat on the rug. The little orange backpack stands open next to them; the round straw sun hat beside it.
- **Cut:** `hero` (the shirt in her hands goes with her), `lulu`. Plate: hero, lulu.
- **Poses:** hero `done` — holds up the t-shirt folded into a neat small square with both hands, proud big smile; lulu `clap` — claps her paws in front of her chest, laughing.
- **Hotspots:** `clothes` (folded shorts), `backpack`, then `lulu`.
- **Cues:** vi `gấp` → hero wiggle, `Lulu` → lulu hop, `Gấp` → clothes wiggle, `xong` → hero pose `done` + lulu pose `clap` · en `folds`, `Lulu`, `Fold`, `done`.

### d2 — `d2_ready.webp` — sparkles — **changed**
- **Lời kể (vi):** Rẹt! Bé kéo khóa ba lô, đặt chiếc mũ tròn lên trên. Ba lô nhỏ đứng cạnh vali to của ba mẹ. Lulu reo lên: "Bé tự xếp giỏi quá!"
  - changed: `Rẹt! {name} kéo khóa…` → `Rẹt! Bé kéo khóa…`; `"{name} tự xếp giỏi quá!"` → `"Bé tự xếp giỏi quá!"`
- **Narration (en):** Zip! The little one zips up the backpack and puts the round hat on top. The small backpack stands next to Mom and Dad's big suitcase. Lulu cheers, "You packed it all by yourself!"
- **Picture:** Night, crescent moon in the window. The little orange backpack, zipped and slim, with the round straw sun hat on top, stands on the floor right next to ba mẹ's big teal suitcase beside the door. {hero} stands on the rug a little in front of them, happy, arms down. Lulu floats nearby, softly glowing, a few small pink hearts around her. Nobody touches anyone.
- **Cut:** `hero`, `lulu`. Plate: hero, lulu.
- **Poses:** hero `cheer` — both arms up high, big happy smile; lulu `cheer` — both paws up high, laughing.
- **Hotspots:** `backpack`, `hat`, `suitcase`, then `lulu`.
- **Cues:** vi `Rẹt` → backpack wiggle, `mũ` → hat hop, `vali` → suitcase wiggle, `reo` → lulu pose `cheer` + hero pose `cheer` · en `Zip`, `hat`, `suitcase`, `cheers`.

### end — `end_asleep.webp` — zzz — **changed**
- **Lời kể (vi):** Bé chui vào chăn ấm, nhắm mắt lại. Ba lô nhỏ đã sẵn sàng bên cửa. Lulu thì thầm: "Ngủ ngon nhé, bé. Mai mình đi biển!"
  - changed: `{name} chui vào chăn ấm,…` → `Bé chui vào chăn ấm,…`; `"Ngủ ngon nhé, {name}.` → `"Ngủ ngon nhé, bé.`
- **Narration (en):** The little one snuggles under the warm blanket and closes both eyes. The small backpack is ready by the door. Lulu whispers, "Good night, little one. Tomorrow we go to the beach!"
- **Picture:** Night, crescent moon and stars in the window, very soft dim warm light. {hero} sleeps peacefully in the bed on the left under the lavender blanket, a small smile, head on the pillow at the left-middle of the picture. Lulu is curled up and softly glowing on the far corner of the pillow, not touching {hero}. By the door on the right, the little packed backpack with the sun hat on top stands next to the big teal suitcase.
- **Cut:** `lulu` only (the hero is under the blanket: stays in the base). Plate: lulu.
- **Poses:** lulu `whisper` — leans toward the sleeping child, one paw by her mouth as if whispering, eyes soft.
- **Hotspots:** `backpack`, `suitcase`, then `lulu`.
- **Ambient:** `zzz`, `ambient_origin` at the hero's head (about [0.25, 0.50]; confirm from the final picture).
- **Cues:** vi `Lulu` → lulu pose `whisper` (or pulse) · en `Lulu`.

### cover — `cover.webp`
- **Picture:** Night, crescent moon in the window. {hero} and Lulu sit on the soft rug, one on each side of the little orange backpack, which is zipped with the round straw sun hat on top; both smile at it. The big teal suitcase stands by the door behind. Not touching.

## Setting

The same cozy kid bedroom at night in every picture: a low wooden bed with a lavender blanket and a soft white pillow against the left wall, a window on the back wall showing a dark blue night sky with a crescent moon and a few stars, a small warm glowing lamp on a little wall shelf, a soft round cream rug in the middle of the wooden floor, and a rounded light-wood door on the right wall with ba mẹ's big upright teal suitcase (handle, little wheels, small red heart tag) standing on the floor just left of the door. Few props, soft warm light, gentle shadows. The bottom-right corner of the picture is plain wooden floor with nothing important in it. Absolutely no text, letters or numbers anywhere in the picture.

## Choice icons

| choice | option | kind | icon | shows |
|---|---|---|---|---|
| c1 | need | kind | `icon_backpack.webp` | The small slim soft-orange backpack (zipped, yellow star on the pocket) with the straw sun hat and the light-blue water bottle beside it. |
| c1 | all | learn | `icon_toys.webp` | The same backpack bulging round and fat, colourful wooden blocks and a red-and-white ball spilling out of its top. |
| c2 | fold | kind | `icon_fold.webp` | A neatly folded light-blue t-shirt square, a small pink heart above it. |
| c2 | stuff | learn | `icon_scrunch.webp` | A crumpled light-blue t-shirt rolled into a lumpy ball, little squiggle lines around it. |

No hero in the icons (one clear object each), plain soft background.

## Sticker

`sticker.webp`: the little soft-orange backpack, zipped, with the round straw sun hat on top and the yellow star on its pocket, a small happy face on the pocket, round sticker with a white border. No hero.

## SVG overlays

None. Nothing needs exact counts, numbers or text (the narration never says how many blocks; the prompts say "a few"). The v1 "New props needed" SVG section is dropped: every prop is drawn by the AI.

## Summary of vi changes vs v1 (for audio reuse)

- Unchanged (reuse v1 vi clips if text matches): c1 (question + labels), c2 (question + labels), b3, e2. Title also unchanged.
- Changed (re-record vi): s1, s2, b1, b2, a1, e1, d1, d2, end.
- All English lines are new.
