# keep_promise: outline (new v2 story, kit)

New story (not a v1 port). Kit art (`docs/kit.md`): no picture per scene. The app builds every scene from one empty bedroom, cut-out hero / Lulu poses and cut-out props, and moves them on words. Each scene below is a **layout** (who / what stands where, starting pose or state) plus **moves on cue words**. The narration lines are drafts for `story-writer`, who sets the final wording and cue words. The vi line comes first, then en.

- **Title:** vi `{name} và lời hứa ngón út` · en `{name} and the Pinky Promise`
- **Theme:** promise
- **Hero:** girl (`tool/image_refs/girl.png`). The text never gives a gender: "bé" / "the little one".
- **Moral:** vi: Đã hứa thì mình làm trước, dù có điều vui hơn đang chờ; giữ lời hứa thì bạn bè tin mình, ai cũng vui. · en: When we make a promise, we keep it first, even when something more fun comes along. Then friends can trust us, and everyone is happy.
- **Cast:** the hero, Lulu, and one extra simple character: **Mầm Nhỏ / Little Sprout**, a sprout in a small clay pot. Its face is on the pot. It never talks: it only droops, perks up and smiles. The red balloon is a plain object with no face. No grown-ups.
- **Not repeated (AVOID list from the checker):**
  - The promise is not a tidy-up promise (that is `tidy_toys`).
  - Breaking it leads to no lie and no broken object (that is `tell_truth`). The consequences are a thirsty, drooping sprout and a friend left waiting.
  - It is not a bedtime "five more minutes" promise (that is v1 `sleep_late` / `clock_time`). Both promises are about doing something for someone else (watering, giving a turn), not about bedtime.
- **Shared with other stories:** only kit pieces (the bedroom, the girl sheets of tidy_toys / clock_time, Lulu sheets, the blanket lump). No beats are shared. New: the sprout, the watering can, the balloon, turn-taking.

## Choices

### c1: water Little Sprout or chase the balloon? (promise to Lulu, made while she goes away)
Question: vi `{name} ơi, mình làm gì trước đây?` · en `{name}, what should we do first?`
- **Kind (`water`)**: vi `Tưới cho Mầm Nhỏ trước` · en `Water Little Sprout first`.
  - The hero waters Little Sprout. It drinks, lifts its leaves and smiles, and Lulu claps: the promise is kept even though nobody was watching (a1).
- **Learn (`play`)**: vi `Chơi bóng bay trước` · en `Play with the balloon first`.
  - The hero bumps the balloon around and forgets. Little Sprout waits and waits, then droops right over (b1).
  - The hero turns and sees it bent over and limp, and feels a bit sad inside (b2).
  - Lulu comes back and floats down by the pot (b3). Lulu: vi **"Mầm Nhỏ tin lời bạn hứa, nên chờ bạn mãi đấy. Mình hứa gì thì làm trước, rồi mới chơi nhé."** · en **"Little Sprout trusted your promise, so it waited and waited. When we promise something, we do it first, and then we play."** Then Little Sprout lifts its head a little, still waiting. → rewind offer to c1, then a1.

### c2: whose turn with the balloon? (promise to Lulu: "I go first, then it's your turn")
Question: vi `Đến lượt Lulu rồi. Mình làm gì đây, {name}?` · en `Now it's Lulu's turn. What will you do, {name}?`
- **Kind (`turn`)**: vi `Tâng bóng sang Lulu` · en `Bump it over to Lulu`.
  - The balloon goes over to Lulu. She bumps it back with her long ears, over and back, and the two friends giggle (d1).
- **Learn (`keep`)**: vi `Giữ bóng chơi một mình` · en `Keep playing by myself`.
  - The hero keeps bumping the balloon, and Lulu waits with drooping ears.
  - A bump that is too hard sends the balloon up to the ceiling, out of reach. Playing alone isn't much fun (e1).
  - Lulu floats up and nudges the balloon back down (e2). Lulu: vi **"Không sao đâu. Bạn hứa, nên mình tin và chờ bạn đấy. Giữ lời hứa thì chơi cùng nhau vui hơn nhiều."** · en **"It's okay. You promised, so I trusted you and waited. When we keep our promises, playing together is much more fun."** → rewind offer to c2, then d1.

## Node graph

| id | type | next / options | offer_rewind_to | ambient |
|---|---|---|---|---|
| s1 | scene | s2 | | sparkles |
| s2 | scene | c1 | | stars |
| c1 | choice | water → a1 (kind), play → b1 (learn) | | stars |
| b1 | scene | b2 | | stars |
| b2 | scene | b3 | | stars |
| b3 | scene | a1 | c1 | sparkles |
| a1 | scene | n1 | | stars |
| n1 | scene | c2 | | stars |
| c2 | choice | turn → d1 (kind), keep → e1 (learn) | | stars |
| e1 | scene | e2 | | stars |
| e2 | scene | d1 | c2 | sparkles |
| d1 | scene | d2 | | stars |
| d2 | scene | end | | sparkles |
| end | ending (sticker `images/sticker.webp`) | | | zzz, `ambient_origin` at the sleeping head (≈ [0.18, 0.44], the girl `hero_b/asleep` placement as in prepare_stuff_vacation; tidy_toys used [0.17, 0.42]; take it from the stage run) |

14 nodes. Paths: kind-kind = 9 nodes, learn-learn = 14. Stickers: up to 2. Start `s1`.

**Name lines** (first or last word of the whole line, once): s1, b2, a1, d1 start with `{name}`; c1 starts with it; c2 and end end with it. Every other line says "bé" / "the little one".

**Continuity**
- **Little Sprout** (`pot`, always at `pot_spot`):
  - `sprout_thirsty`: s1, s2, c1, b1 start
  - `sprout_droopy`: b1 end, b2, b3 start
  - b3 ends back at `sprout_thirsty` (it lifts its head, still waiting), so **a1 starts thirsty on both paths**
  - `sprout_happy`: a1 end, then n1 to d2
  - `sprout_flower`: d2 end and end
- **Watering can:** on the floor at `can_spot` from s1 to b3. In a1 it is in the hero's hands (part of the `kneel_water` figure, no can prop). From n1 on it stands on the floor at `can_by_pot` (put down between a1 and n1).
- **Balloon:**
  - at `bed_foot` (tied) in s1
  - between s1 and s2 it comes loose: at `air_mid` from s2 on (b1 only hops it, so a1 starts with it at `air_mid` on both paths)
  - e1 sends it up to `ceiling`, e2 brings it back to `air_mid`
  - d2 floats it back to `bed_foot`, where it stays in end
- **Lulu:**
  - s1: at `air_pot`, then she leaves through the window and stays at `window` until s1 ends
  - absent in s2, c1, b1, b2
  - b3: she comes back from `window` to `air_pot`
  - at `air_pot` from a1 to d2 (the same spot on both paths into a1 and d1; e2 ends her back there)
  - end: at `air_pillow`
- **Hero:**
  - on the rug at `rug_mid` in every scene but two: a1 (kneeling at `by_pot` to water) and end (in bed)
  - no sliding across the room inside a scene

## Spots (same camera in every scene)

Room = tidy_toys' `kit/room.png` with tidy_toys' crop (as tell_truth, clock_time's `room_night` and prepare_stuff_vacation's `bed` crop): bed on the left, pillow at the LEFT end ≈ [0.18, 0.50], mattress top y ≈ 0.49–0.56, floor y 0.80–1.0, rug x 0.25–0.98, window in the middle of the back wall, door cropped out. All points are approximate (feet for standing things, centre for floating things). Confirm them with `stage.py --guides`.

| spot | where | about |
|---|---|---|
| `rug_mid` | hero on the rug, a little right of centre, facing right | [0.58, 0.96] |
| `by_pot` | hero kneeling just left of the pot, facing right, can spout over the pot | [0.72, 0.96] |
| `pot_spot` | Little Sprout's pot on the floor, front right (tidy's toy-box spot) | [0.86, 0.95] |
| `can_spot` | watering can on the floor, front left of the rug, in front of the bed | [0.32, 0.97] |
| `can_by_pot` | watering can on the floor just left of and in front of the pot | [0.76, 0.98] |
| `bed_foot` | balloon floating above the foot (right end) of the bed, string down to the bed's corner | ≈ [0.47, 0.30] (measure) |
| `air_mid` | balloon in the air right above the hero at `rug_mid` | [0.58, 0.40] |
| `ceiling` | balloon pressed against the top edge, right of the window: clearly out of reach | [0.68, 0.08] |
| `by_lulu` | balloon just above Lulu at `air_pot` | [0.78, 0.24] |
| `window` | Lulu in the air in front of the window (leaves / comes back here) | [0.50, 0.26] |
| `air_pot` | Lulu in the air above and a little left of the pot, not over the hero's head | [0.80, 0.44] |
| `by_ceiling` | Lulu just below-right of the balloon at `ceiling` | [0.76, 0.18] |
| `in_bed` | hero lying in bed, head on the pillow: the girl `hero_b/asleep` spot used in tidy_toys, clock_time and prepare_stuff_vacation (blanket lump at [0.425, 0.61], scale 1.3) | [0.29, 0.575] |
| `air_pillow` | Lulu in the air above and right of the sleeping head, left of the balloon | [0.36, 0.34] |

**Draw order** (back to front, the same in every scene): background → `can` → `pot` → `hero` → `blanket` → `balloon` → `lulu`. The balloon is drawn over the hero, so it sits over her raised hands when she bumps it. In end, if the balloon's string end floats loose above the bed's foot, put `balloon` before `blanket` so the string end tucks behind the lump (end only).

## Scenes

The hero wears the girl sheets' mint-green long-sleeve pajamas with little white stars, barefoot, in every scene (the outfit of the reused `hero_a`, `hero_b`, `hero_d`, `hero_e`; the new `hero_f` sheet draws the same). Parts: `hero`, `lulu`, `pot`, `can`, `balloon`, `blanket`. Every part is a cut-out, so hotspots are only needed for tap bursts (a1 and d1: `hearts` on the pot).

### s1 — `s1_promise` — sparkles
- **Lời kể (vi):** {name} ngồi bên chậu cây nhỏ. Mầm Nhỏ khát nước, hai chiếc lá rũ xuống. Lulu nói: "Mình đi thắp sao đây. Bạn nhớ tưới cho Mầm nhé!" Bé đứng dậy, giơ ngón út: "Mình hứa!" Vù, Lulu bay ra cửa sổ.
- **Narration (en):** {name} sits by a little flower pot. Little Sprout is thirsty, its two leaves drooping. Lulu says, "I'm off to light the stars. Please water Little Sprout!" The little one stands up and holds out a pinky: "I promise!" Whoosh, Lulu flies out the window.
- **Layout:**
  - hero `sit_look_up` at `rug_mid` (looking up right at Lulu)
  - pot `sprout_thirsty` at `pot_spot`
  - can at `can_spot`
  - balloon at `bed_foot`
  - Lulu `float` at `air_pot`
- **Moves:**
  - vi `Mầm Nhỏ` → pot wiggle
  - `nói` → lulu pose `talk`
  - `giơ ngón út` → hero pose `pinky`
  - `Vù` → lulu move to `window` (she stays there to the end of the node; she is absent in s2)
  - en words: `Little Sprout`, `says`, `pinky`, `Whoosh`

### s2 — `s2_balloon` — stars
- **Lời kể (vi):** Bé định đi lấy bình tưới. Ơ kìa! Quả bóng bay đỏ tuột dây, bay lơ lửng giữa phòng. Bồng bềnh, bồng bềnh. Trông vui quá đi!
- **Narration (en):** The little one is about to get the watering can. Oh, look! The red balloon has come loose and floats in the middle of the room. Bob, bob. It looks like so much fun!
- **Layout:**
  - hero `stand_proud` at `rug_mid`
  - can at `can_spot`
  - pot `sprout_thirsty`
  - balloon at `air_mid` (it came loose between the nodes: the line says so)
  - no Lulu
- **Moves (pose switches and hops only, so c1 can reuse this scene):**
  - vi `bình tưới` → can pulse
  - `Ơ kìa` → hero pose `stand_look_up`
  - `Bồng bềnh` → balloon hop
  - `bồng bềnh` → balloon hop
  - en words: `watering can`, `Oh, look`, `Bob`, `bob`

### c1 — reuses `s2_balloon` — stars
- **Câu hỏi (vi):** {name} ơi, mình làm gì trước đây?
- **Question (en):** {name}, what should we do first?
- **Layout:** s2's end state. Node `poses`: hero `stand_look_up`.
- **Options:**
  - `water` (kind): vi `Tưới cho Mầm Nhỏ trước` · en `Water Little Sprout first`, icon `icon_water.webp`
  - `play` (learn): vi `Chơi bóng bay trước` · en `Play with the balloon first`, icon `icon_balloon.webp`

### b1 — `b1_play` — stars
- **Lời kể (vi):** Bé chạy theo quả bóng bay. Tâng! Bóng bay lên cao. Tâng! Bóng lại bay lên. Vui quá, bé quên mất lời hứa. Mầm Nhỏ chờ mãi, chờ mãi.
- **Narration (en):** The little one runs after the balloon. Bump! Up it goes. Bump! Up again. It's so much fun, the little one forgets the promise. Little Sprout waits and waits.
- **Layout:**
  - hero `tap_up` at `rug_mid`
  - balloon at `air_mid`
  - pot `sprout_thirsty`
  - can at `can_spot`
  - no Lulu
- **Moves:**
  - vi `chạy theo` → hero hop
  - `Tâng` (1st) → balloon hop
  - `Tâng` (2nd) → balloon hop
  - `chờ mãi` → pot pose `sprout_droopy`
  - en words: `runs`, `Bump`, `Bump`, `waits`

### b2 — `b2_droopy` — stars
- **Lời kể (vi):** {name} quay lại nhìn. Ôi, Mầm Nhỏ gục đầu, lá rũ cả xuống. Bình tưới vẫn nằm im chỗ cũ. Bé thấy buồn buồn trong lòng.
- **Narration (en):** {name} turns around to look. Oh! Little Sprout is bent right over, its leaves all limp. The watering can is still in the same spot. The little one feels a bit sad inside.
- **Layout:**
  - hero `tap_up` at `rug_mid`
  - balloon at `air_mid`
  - pot `sprout_droopy`
  - can at `can_spot`
  - no Lulu
- **Moves:**
  - vi `quay lại` → hero pose `stand_oops`
  - `Mầm Nhỏ` → pot wiggle
  - `Bình tưới` → can pulse
  - `buồn buồn` → hero pose `kneel_sad`
  - en words: `turns`, `Little Sprout`, `watering can`, `sad`

### b3 — `b3_lulu` — sparkles — offer_rewind_to c1
- **Lời kể (vi):** Vù! Lulu bay về, sà xuống bên Mầm Nhỏ. "Mầm Nhỏ tin lời bạn hứa, nên chờ bạn mãi đấy. Mình hứa gì thì làm trước, rồi mới chơi nhé. Kìa, Mầm vẫn đang chờ bạn!"
- **Narration (en):** Whoosh! Lulu flies back and floats down by Little Sprout. "Little Sprout trusted your promise, so it waited and waited. When we promise something, we do it first, and then we play. Look, it's still waiting for you!"
- **Layout:**
  - hero `kneel_sad` at `rug_mid`
  - Lulu `float` at `window`
  - pot `sprout_droopy`
  - can at `can_spot`
  - balloon at `air_mid`
- **Moves:**
  - vi `Vù` → lulu move to `air_pot`
  - `sà xuống` → hero pose `sit_look_up`
  - `tin lời` → lulu pose `talk`
  - `vẫn đang chờ` → pot pose `sprout_thirsty` + hop (it lifts its head, hopeful)
  - en words: `Whoosh`, `floats down`, `trusted`, `still waiting`

### a1 — `a1_water` — stars
- **Lời kể (vi):** {name} tưới nước cho Mầm Nhỏ. Róc rách, róc rách! Mầm Nhỏ uống no, vươn hai chiếc lá, cười thật tươi. Lulu vỗ tay: "Bạn giữ lời hứa rồi!"
- **Narration (en):** {name} waters Little Sprout. Trickle, trickle! Little Sprout drinks it all up, lifts its two leaves and smiles a big smile. Lulu claps, "You kept your promise!"
- **Layout (the same start on both paths):**
  - hero `kneel_water` at `by_pot` (the can is in her hands: no can prop)
  - pot `sprout_thirsty`
  - balloon at `air_mid`
  - Lulu `float` at `air_pot` (already back when a1 starts, on the kind path too: kit note 2)
  - pot hotspot burst `hearts` (tap)
- **Moves:**
  - vi `Róc rách` → hero wiggle
  - `vươn` → pot pose `sprout_happy`
  - `cười` → pot hop
  - `vỗ tay` → lulu pose `clap`
  - en words: `Trickle`, `lifts`, `smiles`, `claps`

### n1 — `n1_turn` — stars
- **Lời kể (vi):** Giờ thì chơi bóng bay thôi! Lulu hỏi: "Cho mình chơi với nhé?" Bé giơ ngón út: "Mình tâng trước, rồi đến lượt Lulu. Mình hứa!" Tâng, tâng! Vui ơi là vui.
- **Narration (en):** Now it's balloon time! Lulu asks, "Can I play too?" The little one holds out a pinky: "I'll go first, then it's your turn, Lulu. I promise!" Bump, bump! What fun!
- **Layout:**
  - hero `stand_proud` at `rug_mid`
  - balloon at `air_mid`
  - pot `sprout_happy`
  - can at `can_by_pot`
  - Lulu `float` at `air_pot`
- **Moves (pose switches and hops only, so c2 can reuse this scene):**
  - vi `hỏi` → lulu pose `talk`
  - `giơ ngón út` → hero pose `pinky`
  - `Tâng` → hero pose `tap_up` + balloon hop
  - `tâng` → balloon hop
  - en words: `asks`, `pinky`, `Bump`, `bump`

### c2 — reuses `n1_turn` — stars
- **Câu hỏi (vi):** Đến lượt Lulu rồi. Mình làm gì đây, {name}?
- **Question (en):** Now it's Lulu's turn. What will you do, {name}?
- **Layout:** n1's end state. Node `poses`: hero `tap_up`, lulu `float` (she waits for her turn).
- **Options:**
  - `turn` (kind): vi `Tâng bóng sang Lulu` · en `Bump it over to Lulu`, icon `icon_turn.webp`
  - `keep` (learn): vi `Giữ bóng chơi một mình` · en `Keep playing by myself`, icon `icon_alone.webp`

### e1 — `e1_alone` — stars
- **Lời kể (vi):** Bé tâng mãi, tâng mãi. Lulu chờ mãi, đôi tai cụp xuống. Vèo! Bóng bay vút lên trần nhà. Bé với mãi không tới. Chơi một mình chẳng vui gì cả.
- **Narration (en):** The little one bumps and bumps the balloon. Lulu waits and waits, her ears drooping. Whoosh! The balloon zooms up to the ceiling. The little one reaches and reaches, but it's too high. Playing alone isn't much fun.
- **Layout:**
  - hero `tap_up` at `rug_mid`
  - balloon at `air_mid`
  - Lulu `float` at `air_pot`
  - pot `sprout_happy`
  - can at `can_by_pot`
- **Moves:**
  - vi `cụp xuống` → lulu pose `sad`
  - `Vèo` → balloon move to `ceiling`
  - `với mãi` → hero hop
  - `chẳng vui` → hero pose `kneel_sad`
  - en words: `drooping`, `Whoosh`, `reaches`, `isn't much fun`

### e2 — `e2_lulu` — sparkles — offer_rewind_to c2
- **Lời kể (vi):** Lulu bay lên, khẽ đẩy quả bóng xuống cho bé. Lulu nói: "Không sao đâu. Bạn hứa, nên mình tin và chờ bạn đấy. Giữ lời hứa thì chơi cùng nhau vui hơn nhiều."
- **Narration (en):** Lulu floats up and gently nudges the balloon back down. Lulu says, "It's okay. You promised, so I trusted you and waited. When we keep our promises, playing together is much more fun."
- **Layout:**
  - hero `kneel_sad` at `rug_mid`
  - balloon at `ceiling`
  - Lulu `sad` at `air_pot`
  - pot `sprout_happy`
  - can at `can_by_pot`
- **Moves:**
  - vi `bay lên` → lulu move to `by_ceiling` (pose stays `sad`; next cue changes it)
  - `đẩy` → balloon move to `air_mid`
  - `Lulu nói` → lulu move back to `air_pot`
  - `Không sao` → lulu pose `talk` + hero pose `sit_look_up`
  - en words: `floats up`, `nudges`, `says`, `okay`
- If four moves feel busy, drop the move back to `air_pot`: Lulu talks from `by_ceiling`, and d1 starts her at `air_pot` (a small jump between nodes).

### d1 — `d1_together` — stars
- **Lời kể (vi):** {name} tâng quả bóng sang cho Lulu. Lulu tâng lại bằng đôi tai dài. Tâng qua, tâng lại! Hai bạn cười khúc khích.
- **Narration (en):** {name} bumps the balloon over to Lulu. Lulu bumps it back with her long ears. Over and back, over and back! The two friends giggle and giggle.
- **Layout (the same start on both paths):**
  - hero `tap_up` at `rug_mid`
  - balloon at `air_mid`
  - Lulu `float` at `air_pot`
  - pot `sprout_happy`
  - can at `can_by_pot`
- **Moves:**
  - vi `sang cho Lulu` → balloon move to `by_lulu`
  - `tâng lại` (1st) → lulu hop + balloon move to `air_mid`
  - `Tâng qua` → balloon move to `by_lulu`
  - `tâng lại` (2nd) → balloon move to `air_mid`
  - `cười khúc khích` → lulu pose `clap` + hero pose `stand_proud`
  - en words: `over to Lulu`, `back`, `Over`, `back` (2nd), `giggle`

### d2 — `d2_flower` — sparkles
- **Lời kể (vi):** Lulu tỏa sáng thật dịu. Kìa, Mầm Nhỏ nở một bông hoa nhỏ xíu! Bóng bay cũng bồng bềnh về chân giường nghỉ. Oáp! Bé buồn ngủ rồi.
- **Narration (en):** Lulu glows, soft and warm. Look, Little Sprout has opened one tiny flower! The balloon bobs back to the foot of the bed to rest. Yaaawn! The little one is sleepy now.
- **Layout:**
  - hero `stand_proud` at `rug_mid`
  - balloon at `air_mid`
  - Lulu `float` at `air_pot`
  - pot `sprout_happy`
  - can at `can_by_pot`
- **Moves:**
  - vi `tỏa sáng` → lulu pose `glow`
  - `nở` → pot pose `sprout_flower` + hop
  - `chân giường` → balloon move to `bed_foot`
  - `Oáp` → hero pose `stand_yawn`
  - en words: `glows`, `opened`, `foot of the bed`, `Yaaawn`

### end — `end_asleep` — zzz
- **Lời kể (vi):** Bé chui vào chăn ấm, nhắm mắt lại. Mầm Nhỏ ngủ, bóng bay cũng ngủ. Lulu thì thầm: "Hai lời hứa, bạn đều giữ cả. Ngủ ngon nhé, {name}."
- **Narration (en):** The little one snuggles under the warm blanket and closes both eyes. Little Sprout sleeps, and the balloon sleeps too. Lulu whispers, "You kept both your promises. Good night, {name}."
- **Layout:**
  - hero `asleep` (girl `hero_b`) at `in_bed`, with `blanket_lump` over the body
  - pot `sprout_flower` at `pot_spot` (its closed happy eyes read as asleep)
  - can at `can_by_pot`
  - balloon at `bed_foot`
  - Lulu `float` at `air_pillow`
- **Ambient:** `zzz`, `ambient_origin` at the hero's head (≈ [0.18, 0.44], as in prepare_stuff_vacation with the same girl sprite and spot).
- **Moves:**
  - vi `chui vào chăn` → blanket pulse
  - `Mầm Nhỏ` → pot pulse
  - `bóng bay` → balloon wiggle
  - `thì thầm` → lulu pose `whisper`
  - en words: `snuggles`, `Little Sprout`, `balloon`, `whispers`

## Setting

**Room (`room`, reused, no new Gemini image):** tidy_toys' `kit/room.png` (copy, as tell_truth, clock_time and prepare_stuff_vacation did) with tidy_toys' crop. It is the cozy kid bedroom at night:
- soft warm peach walls, wooden floor, warm lamp light, no text
- **Left / back wall:** a low wooden bed seen from its long side, with the headboard and white pillow at the LEFT end, a smooth lavender blanket, and a dark gap under it. The foot (right end) of the bed must be in frame: the balloon is tied there in s1 and rests there in end.
- **Back wall:** a window in the middle (dark blue sky, crescent moon, stars), where Lulu leaves and comes back. A small warm lamp on a little wooden shelf.
- **Floor:** a round cream rug with open floor in front. The left front (`can_spot`) and the right front (`pot_spot`, tidy's toy-box spot) are plain floor.
- **Air:** open air above the rug and up to the top edge, right of the window, for the balloon (`air_mid`, `ceiling`) and Lulu.
- The door is cropped out. Nothing is on the floor.

**Recurring props.** All are soft 3D, seen from the front and a little from above, lit from the upper left. Sizes are compared with the pot.
- **Little Sprout (`pot`):**
  - **Pot:** a small round terracotta-orange clay pot, a little wider than tall, with a rolled rim. Its simple cute face is on the front: two dot eyes, rosy cheeks, a small mouth.
  - **Sprout:** one thin green stem with two round green leaves, about as tall as the pot.
  - **Size:** the pot is about 1.5× the hero's head wide. Pot plus sprout come up to about the kneeling hero's chin. It must read on a phone (kit lesson: narrated things at least head-sized).
  - **States**, the very same pot at the same size; the leaves stay fresh green in every state (never brown, dry or dead):
    - `sprout_thirsty`: leaves hang down a little, a small worried-hopeful "o" mouth
    - `sprout_droopy`: the stem bends over so the leaves hang down over the rim; eyes closed, small sad mouth, no tears
    - `sprout_happy`: stem straight, both leaves lifted up like little arms, eyes open, big smile
    - `sprout_flower`: as happy, plus one tiny yellow five-petal flower open at the top of the stem between the leaves; eyes closed in a happy curve
- **Watering can (`can`):** a small rounded sunny-yellow watering can with a long thin spout and a handle on top. It is about as tall as the pot and stands upright with its spout pointing RIGHT. The very same can is in the hero's `kneel_water` figure.
- **Balloon (`balloon`):** one round bright-red balloon with a small knot and a thin curly white string hanging straight down, about twice as long as the balloon is tall. The balloon is about as wide as the pot. One sprite placed at every spot.
- **Blanket lump (`blanket`):** tidy_toys' lavender `blanket_lump` (copied), over the sleeping hero in end.

## Choice icons

Built from sprites by `stage.py` (`icons` in `stage.json`). No Gemini. Icons may show the hero and Lulu; only the sticker must be hero-free.

| choice | option | kind | icon | built from |
|---|---|---|---|---|
| c1 | water | kind | `icon_water.webp` | `watering_can` on the left, spout toward `sprout_happy` on the right |
| c1 | play | learn | `icon_balloon.webp` | `balloon` alone, big |
| c2 | turn | kind | `icon_turn.webp` | Lulu `float` with the `balloon` just above her ears (the balloon goes to Lulu) |
| c2 | keep | learn | `icon_alone.webp` | hero `tap_up` alone with the `balloon` above her hands, no Lulu |

## Cover and sticker (normal Gemini pictures)

- **Cover (`cover.webp`, 800×600):** the night bedroom (attach `kit/room.png` and `kit/props_promise.png` so they look the same).
  - The hero stands on the rug, turned right, holding up one pinky with a big earnest smile.
  - Lulu floats above the rug to her right, smiling, one paw raised. She does not touch the hero.
  - In front right, Little Sprout's terracotta pot with its happy face, both leaves up and one tiny yellow flower.
  - The round red balloon bobs above them on its curly white string.
- **Sticker (`sticker.webp`, no hero):** Little Sprout: the terracotta pot with its happy face (eyes closed in a smile, rosy cheeks), two green leaves up and one tiny yellow flower on top. A small red balloon on a curly white string is tied to the pot's rim and floats beside the flower, touching it so everything makes one sticker shape. A round sticker with a white border.

## Pose and prop lists

**Hero poses (10 of 12; girl, mint-green long-sleeve pajamas with little white stars, barefoot).** Four are reused from the girl sheets (copied, never moved) and six are on one new sheet. Figures face right unless noted. All girl sheets use `scale` 0.68 in `stage.json`; the new sheet must match.

Reused, copied from `~/Downloads/story_art/<story>/kit/` (sheet + its sprites):
1. `sit_look_up` (`hero_a`, tidy_toys): sits cross-legged, head tilted up, looking up right, eyes wide, delighted, hands on the knees (s1 start, b3 end, e2 end)
2. `asleep` (`hero_b`, tidy_toys): lies on one side, head to the LEFT, eyes closed, on nothing (end)
3. `kneel_sad` (`hero_d`, clock_time; also in prepare_stuff_vacation): kneels sitting back on the heels, turned right, looking down to the right, a little sad (eyebrows up, small frown), hands in the lap (b2 end, b3 start, e1 end, e2 start)
4. `stand_yawn` (`hero_e`, clock_time; also in prepare_stuff_vacation): stands facing a little right, huge yawn, one fist rubbing an eye, the other arm hanging down (d2)

No pajama girl match for the rest (the girl's only standing figures are `stand_ball` with a striped ball, `throw`, `bend_place`, `reach`, `stand_sleepy`, `pull`; `hero_day/oops` is in day clothes), so they go on a new sheet `hero_f` (6 figures, girl; `{hero}` = `tool/image_refs/girl.png`, attaches `kit/hero_e.png` for the size and `kit/props_promise.png` for the can's look, so `props_promise` is made first: the standing girl `stand_yawn` is the match, and the kneeling figure matches `hero_d`'s kneeling girl; head the same size in every figure). Named `hero_f` so it never clashes with clock_time's `hero_c`:
5. `pinky`: stands facing a little right, one hand raised at shoulder height with only the little finger up (a pinky promise), earnest happy smile, the other arm relaxed (s1, n1)
6. `stand_look_up`: stands, looking up with a delighted open-mouth smile, one arm pointing straight up (s2, c1)
7. `tap_up`: stands on tiptoe, both arms stretched up, open empty palms facing up as if bumping a balloon, laughing, looking up; nothing in the hands (b1, b2 start, n1, c2, e1, d1, `icon_alone`)
8. `kneel_water`: kneels turned right, holding the small sunny-yellow watering can (the very same can as `props_promise`'s `watering_can`) in both hands, tilted forward, a short stream of water joined to the spout, gentle smile (a1)
9. `stand_proud`: stands tall, big bright smile, arms a little open (s2 start, n1 start, d1 end, d2 start)
10. `stand_oops`: stands, hands on the cheeks, mouth a small "O", surprised but not scared (b2)

**Lulu poses (6; no new sheet):**
- from tidy_toys' `lulu_a` (copy):
  - `float`: s1, b3, a1, n1, c2, e1, d1, d2, end start
  - `talk`: s1, b3, n1, e2
  - `clap`: a1, d1
  - `glow`: d2
  - `whisper`: end
- from tell_truth's `lulu_c` (copy):
  - `sad`: ears drooping, paws together; e1 end, e2 start

**Props (7 sprites):**
- new sheet `props_promise` (3 columns, 6 figures; made before `hero_f`): `sprout_thirsty`, `sprout_droopy`, `sprout_happy`, `sprout_flower`, `watering_can`, `balloon`
- reused: tidy_toys' `props` (copy): `blanket_lump`

**Prop states by scene:**
- `pot`:
  - `sprout_thirsty`: s1, s2, c1, b1 start, b3 end, a1 start
  - `sprout_droopy`: b1 end, b2, b3 start
  - `sprout_happy`: a1 end, n1, c2, e1, e2, d1, d2 start
  - `sprout_flower`: d2 end, end
- `can`: `can_spot` s1–b3; held (in `kneel_water`) a1; `can_by_pot` n1–end
- `balloon`: `bed_foot` s1 and end; `air_mid` s2–e1 start, e2 end–d2 start; `ceiling` e1 end, e2 start; `by_lulu` / `air_mid` back and forth in d1
- `blanket`: end only

**Gemini images for this story: 4.**
- New: `props_promise` (first), `hero_f` (girl), `cover`, `sticker`.
- Copied (tell the parent to skip those prompts): `room` (tidy_toys), `hero_a` + `hero_b` (tidy_toys, girl), `hero_d` + `hero_e` (clock_time, girl; the same files are in prepare_stuff_vacation), `lulu_a` (tidy_toys), `lulu_c` (tell_truth), `props` (tidy_toys, only `blanket_lump` is used). tell_truth's `hero_a` / `hero_b` are the boy: never copy them here.

## Kit notes (beats shaped to fit the kit; the parent approves them with this outline)

1. **Lulu leaves in s1 without vanishing.** On "Vù" she moves to `window` and stays drawn there until s1 ends. She is absent from s2 to b2 (a change between nodes) and comes back from `window` in b3. Her trip to "light the stars" makes c1 a promise kept when nobody is watching.
2. **a1 starts the same on both paths (decided by the parent: Lulu is already back in a1).** Lulu is at `air_pot` when a1 starts and claps there. On the learn path she is already there (b3). On the kind path she is simply back when a1 starts, which the narration doesn't mention.
3. **Little Sprout's states line up for a1.** On the learn path the sprout droops (b1). In b3, on "vẫn đang chờ" / "still waiting", it lifts back to `sprout_thirsty`. So a1 starts thirsty on both paths, and the watering visibly brings it to `sprout_happy`.
4. **The balloon comes loose between s1 and s2.** s2's line says "tuột dây" / "has come loose", but the balloon is already at `air_mid` when s2 starts. That keeps s2 to pose switches and hops, so c1 can reuse `s2_balloon` (same for n1 → c2).
5. **Bumping the balloon:**
   - The hero holds a `tap_up` pose and the balloon hops or moves above her hands.
   - "Lulu bumps it back with her ears" = a Lulu hop plus a balloon move to `by_lulu` / `air_mid`.
   - In e2, Lulu "nudges" the balloon down: she floats next to it and it moves.
   - Hero and Lulu never touch, and nobody holds the balloon.
6. **The pinky promise is one-sided.** The hero raises a pinky (`pinky` pose). There is no hooked-finger "móc ngoéo", because hero and Lulu are separate sheets and never touch.
7. **Watering can:** a floor prop until a1. In a1 it is drawn inside the `kneel_water` figure, with a short stream of water joined to the spout (the stream's tip lands over the pot's soil when staged); there is no water sprite. It is put down at `can_by_pot` between a1 and n1.
8. **Ending:** the balloon floats to the foot of the bed by itself in d2 ("về chân giường nghỉ" / "bobs back to rest"), so no tying pose is needed. The tiny flower opens on Lulu's `glow` as a pose swap (`sprout_happy` → `sprout_flower`).
9. **Mid-scene pose swaps between standing and sitting or kneeling** (b2 `stand_oops` → `kneel_sad`, b3 `kneel_sad` → `sit_look_up`, e1 `tap_up` → `kneel_sad`, e2 `kneel_sad` → `sit_look_up`) happen at the same feet point. No slides. The only position change of the hero (`rug_mid` → `by_pot`) happens between nodes.
10. **Leaves never die.** Droopy is bent and limp but still fresh green: a gentle consequence that one drink of water undoes.
11. **SVG overlays:** none. No numbers, clocks, text or counts. The narration says "one tiny flower" and "two leaves", which AI draws reliably. If the sheet gets the leaf count wrong, the text can say "lá" without a number.
12. **Girl hero, reused poses.** The hero is the girl (parent's choice), so every pose that already exists on a girl pajama sheet is copied (`sit_look_up`, `asleep`, `kneel_sad`, `stand_yawn`). e1's "isn't much fun" uses the same `kneel_sad` as b2 instead of a new sitting-sad figure, so only six new figures are drawn (`hero_f`). Mixing sheets is safe because all girl sheets share the scale (0.68) and outfit; check the new sheet's head size against `hero_e` in the stage stills.
