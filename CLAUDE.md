# CLAUDE.md

## Project: Bedtime Stories (v2)

Interactive bedtime stories for a 3-5 year old who can't read yet. Every scene is narrated; at choice points the kid taps one of two big picture cards. "Kind" and "learn" choices both end happily; a learn path shows a gentle natural consequence, then offers to rewind and try the other option. **One sticker per good answer** (kind option picked first time at a choice); the profile page shows the sticker book. Languages: **Vietnamese (default) and English**, switched on the welcome and profile pages. **Sections** (2026-11-13): after the welcome the kid picks a section card on `/` (`SectionsScreen`): **behavior** ("Bé ngoan", the kind/learn stories) or **math** ("Học toán": counting, more/fewer, big/small, adding/taking away within 5, sharing; same player, kind = right answer, learn = near miss → count again → rewind; rules and curriculum in `docs/math.md`). Math stories are **templates**: a `"math"` block draws new numbers each play (`{a}`, `{count:c}`, option `{n}` + `"answer"`, node `"counted"`, cue `arrive`; shared clips `audio/ui/<lang>/num_1..10`), answer cards drawn by the app (`CountIcon`) and shuffled. Each section lists its stories on `/learn/<section>`. Platforms: Web, iOS, Android (phone + tablet).

v2 of `../bedtime_story` (v1). Differences from v1: welcome page never scrolls + mic-permission guide; `{name}` at most once per line, as its first or last word; stickers per good answer + profile page; one hero per story (no girl/boy art folders); AI art only (kit workflow for every story since 2026-11-11; SVG only for clocks); bilingual stories and audio; lazy home grid + small covers + asset budgets. Plan: `~/.claude/plans/review-bedtime-story-and-create-mutable-prism.md`.

**Making a story takes days**: pictures and recordings arrive in batches. Resume with `/story-continue [<id>]`; each session starts with a one-line status per unfinished story (`tool/story_status.py --brief`, a SessionStart hook in `.claude/settings.json`). `docs/stories/<id>/progress.json` keeps what files can't show: approvals (`gates`), the prompts page link, pictures marked `redo`, cloned clips the parent `listened` to. v1's agents and skills (`art-coder`, `bedtime_story:*`) may show up because `../bedtime_story` is sometimes an extra folder: never use them here.

**Phase 1: local only.** Stories are bundled assets (make them with `/new-story`). Only Firebase pieces are Analytics + web Hosting, in project **`bedtime-stories-3605d`** ("Bedtime Stories", shared with v1; v1's Android/iOS apps deleted 2026-11-13, v2 replaced v1 on the web). Apps: Android `com.bedtimestory.bedtime_stories`, iOS `com.bedtimestory.bedtimeStories`, web app `bedtime-stories-web` (v1's `bedtime_story (web)` stays separate). Web: https://bedtime-stories-3605d.web.app. Deploy: `fvm flutter build web --release && firebase deploy --only hosting`. Reconfigure: `flutterfire configure` needs fvm's dart on PATH (`PATH="$HOME/fvm/versions/3.47.9/bin:$PATH"`). If Firebase init fails, the app falls back to `NoopAnalytics`.

## Commands

Always prefix with `fvm` (Flutter 3.47.9, pinned in `.fvmrc`):

```bash
fvm flutter pub get
fvm dart run build_runner build -d   # after editing @freezed / @JsonSerializable
fvm dart format .
fvm flutter analyze
fvm flutter test
fvm flutter run -d chrome            # or an iPad / iPhone simulator

python3 tool/story_status.py [<id>] [--brief|--json]   # where each story is (pictures, kit saved / cut / staged, audio per language, wired, blockers) + next step; read-only
python3 tool/wire_story.py <id> [--check]     # add the story to index.json + pubspec.yaml (idempotent)
python3 tool/check_story.py <id> [--art]      # lint story.json (both languages, {name} rule, graph, rewind); --art: images, layers, cue parts, poses
python3 tool/check_story.py --selftest        # shared {name} cases (test/fixtures/name_rule_cases.json, also run by the Dart test)
# tool/story_text.py: line tokens ({name}, {a}, {count:a}) + math expressions shared by gen_audio / cue_times / check_story (mirrors math.dart)
python3 tool/check_assets.py [<id>]           # size budgets (covers, scenes, layers, audio, story total); exit 1 when over
python3 tool/gen_image.py --refs [--only kid] [--prompts-out <dir>]   # character sheets in tool/image_refs/
python3 tool/gen_image.py --story <id> [--dry] [--only cover] [--force] [--prompts-out <dir>]   # cover, sticker (fallback scenes) from docs/stories/<id>/art_prompts.json
python3 tool/gen_image.py --story <id> --kit --prompts-out <dir>   # room + sheet prompts (art_prompts.json "kit")
tool/cutout/.venv/bin/python tool/sprite_sheet.py <sheet.png> --names a,b,c [--out DIR] [--grid 3x2] [--gap 0.02] [--fill-holes|--solid] [--force-mark|--keep-corner]   # one sheet → one sprite per figure (+ _contact.jpg)
tool/cutout/.venv/bin/python tool/stage.py <id> --preview <dir> [--dry] [--only scene] [--guides] [--tint 0.2]   # stage.json → layers.json, shared sprite layers, flat fallbacks, icons (+ {"numeral": n} digits), stills
python3 tool/prompts_page.py <id> <out.html> [--title T]   # phone page of all Gemini prompts (copy + tick), publish as Artifact
tool/cutout/.venv/bin/python tool/import_art.py <id> <file|dir> [--as s1_toys] [--new] [--keep-corner]   # AI picture → watermark removed → WebP (a folder takes only names in art_prompts.json) (scene 1600×1200, cover 800×600, icon 400², sticker 600²), best quality under budget
tool/cutout/.venv/bin/python tool/remove_watermark.py <file|dir> [--out DIR] [--check]   # Gemini sparkle off (copies, never in place)
python3 tool/clock_layer.py <id> [--preview <dir>]   # SVG clock part per scene + clock choice icons (docs/stories/<id>/clock.json); after stage.py
python3 tool/gen_audio.py --list [--lang vi|en] [--story <id>]   # recording script: filename → line
python3 tool/gen_audio.py --missing [--story <id>]               # clips not recorded yet
tool/voice/.venv/bin/python tool/split_numbers.py <id> [--lang vi] [--dry] [--force]   # math lines recorded in one go (<key>_full) -> word pieces (MMS forced alignment, local); before clean_audio
python3 tool/gen_audio.py [--lang vi|en] [--story <id>]          # fill missing clips (cloned voice if set up, else macOS say)
python3 tool/gen_audio.py --story <id> --lang vi --force --only s2,c1_p1 [--seed 7] [--out <dir>]   # redo some clips
python3 tool/clean_audio.py --story <id>      # new recordings: trim, denoise, -16 LUFS (originals in audio_backup/)
python3 tool/clean_audio.py --check [--story <id>]   # loudness / noise / edge silence / not cleaned yet; exit 1 if any
python3 tool/clean_audio.py --story <id> --redo|--restore   # re-clean all from originals | put originals back
tool/cutout/.venv/bin/python tool/cue_times.py <id> [--lang vi] [--dry]   # time cues to the real clips ("at" in story.json); rerun after any clip changes
tool/cutout/.venv/bin/python tool/app_icons.py [docs/app_logo.png]   # web favicon + icons, iOS AppIcon set, Android mipmaps from the logo (Lulu on the moon, Gemini, watermark removed)
tool/voice/setup.sh                           # one-time: F5-TTS venv + Vietnamese fork + English base model
tool/cutout/setup.sh                          # one-time: rembg + OpenCV venv
```

Setup state: `tool/voice/.venv`, `tool/voice/F5-TTS-Vietnamese` and `tool/cutout/.venv` are **symlinks to v1's** (`../bedtime_story/tool/...`); `tool/voice/models/` and `ref/` are APFS clones of v1's. If v1 is moved or deleted, delete the symlinks and run both `setup.sh`. The English model and `tool/voice/ref/en/` are not there yet.

## Architecture

Feature-based clean architecture, Cubit only (freezed states), manual constructor DI, `Either<Failure, T>` (dartz), go_router with `AppRoutes`, absolute `package:bedtime_stories/...` imports, no `setState` in screens, `log()` not `print`, constants in `AppConstants`, colors in `AppColors`. Same conventions as NhàLog (`../my_home/nha_log/CLAUDE.md`), except:
- **Night theme only.** Kid screens are always dark and warm (bedtime).
- **No `static route()` per screen.** Routes in `core/router/app_router.dart`.
- **UI text via `context.strings`** (`AppStrings.of(language)`: `AppStringsVi`, `AppStringsEn` in `core/utils/app_strings.dart`). `context.strings` is reactive (build only); in callbacks/dialogs use `context.readStrings`.
- **Story content is data**, in story JSON, both languages.
- **Kid touch targets ≥ 96px** (`AppConstants.kidMinTarget`), max 2 choices, no reading required: every line the kid needs is also spoken.

```
lib/
  core/       theme/ router/ services/(narrator|analytics|name_voice|mic_permission_*) utils/ widgets/ models/ (incl. StorySection)
  features/
    sections/ SectionsScreen (avatar + one card per StorySection, never scrolls), SectionsCubit (says the section name, logs section_open)
    profile/  data: ProfileStorage (name, gender, language), StickerStorage
              cubit: ProfileCubit, LanguageCubit, StickerCubit (app-wide), WelcomeCubit
              WelcomeScreen, ProfileScreen (sticker book)
    stories/  domain (Story, StoryNode union, StoryRepository), data (StoryModel JSON + validation, AssetStoryRepository)
              presentation (HomeScreen = one section's list, StoryListCubit(section), StoryCard)
    player/   PlayerCubit (narration, choices, rewind, first picks), StoryPlayerScreen, ScenePicture, SceneLayers, StoryPanel
    ending/   EndingScreen (stickers), EndingCubit (reads the sticker line), SleepScreen
assets/
  stories/index.json                     list of bundled story ids
  stories/<id>/story.json                node graph, both languages
  stories/<id>/images/*.webp             flat scene fallbacks, cover, icons, sticker (one folder, no hero split)
  stories/<id>/images/layers/            kit_* room + sprite layers, SVG overlays; images/layers.json[, images/hotspots.json for flat scenes]
  stories/<id>/audio/<vi|en>/<clip>.m4a
  audio/ui/<vi|en>/<key>.m4a             rewind, be (name fallback), sticker_0|1|2, section_behavior|math, num_1..10
  images/section_math.svg                section card (placeholder; behavior uses tidy_toys' cover)
  images/hero_<girl|boy>.svg             kid avatar (home, profile)
tool/       image, audio and check scripts (above)
docs/stories/<id>/   outline.md, review.md, art_prompts.json (incl. reference), art_review.md, progress.json, stage.json[, clock.json]
docs/kit.md          kit art guide: planning, prompt wording, cutting, staging, cues, lessons
docs/math.md         math section: question pattern, curriculum, writing + art rules, adding a section
.claude/    settings.json (allow-list, session-start status line, v1 skills off)
            skills/ new-story (whole pipeline), story-continue (resume: what's new → import/clean/wire → what the parent does next),
                    story-art (each picture batch: cut sheets, stage scenes, stills, cover/sticker import), story-audio (clean, missing, clone)
            agents/ story-idea-checker (new idea vs. v1 + v2 stories; DUPLICATE stops /new-story), story-planner, story-writer, story-reviewer, art-director (art_prompts.json, kit room + sheets), art-reviewer (prompts or pictures), story-tracker (read-only status)
test/fixtures/stories/demo/   test-only bilingual story (tiny WebPs, a cut part with a pose, hotspots)
```

### Story JSON

```json
{"id": "...", "theme": "sleep", "section": "behavior|math", "hero": "girl|boy|kid",
 "title": {"vi": "...", "en": "..."}, "cover": "images/cover.webp", "start": "s1", "nodes": [...]}
```
Every `text` (node) and `label` (option) is `{"vi": "...", "en": "..."}`; the parser and `check_story.py` reject a story missing either language anywhere. `cues` are per language: `{"vi": [{"word", "part", "action"}], "en": [...]}` (words differ). `section` missing = `behavior`; unknown = rejected (parser + `check_story.py`); `getStories(language, section:)` filters. `AssetStoryRepository.getStory(id, language)` builds a `Story` for one language (text, cues, `audioDir = audio/<lang>`); pictures are shared.

Nodes: `scene` (`next`, optional `offer_rewind_to` = a choice id), `choice` (`text` = question, 2 `options` with `kind: kind|learn`, `icon`, `label`, `next`), `ending` (`sticker`). Any node may set `ambient` (`stars|sparkles|zzz|motes`); `ambient_origin: [x, y]` (0–1) puts `zzz` at the sleeping head. Cue `action`: `hop|wiggle|pulse` (any part or hotspot), `pose` + `"pose": "<name>"` (switch picture, holds), `move` + `"to": [x, y]` (slide, holds); pose/move need a moving layer. Node `"poses": {"hero": "sit_up"}` = starting pose. `StoryModel.toEntity` rejects broken links, duplicate ids, missing ending, unknown poses.

Ambient per picture: night room/sky → `stars`; Lulu or magic → `sparkles`; asleep → `zzz` + origin; daytime → `motes`; busy/tense → none. A choice reusing the scene's picture uses the same ambient.

### The `{name}` rule

`{name}` appears **at most once per line** (the text of a scene, choice or ending) and only as the **first or last word of the whole line** ("{name} kéo quai ba lô. …", "{name} ơi, bảy giờ rồi! Mình làm gì nhỉ?", "… Mình ngủ chưa nhỉ, {name}?"), never starting or ending a later sentence ("Reng reng! {name} ngáp."), never mid-sentence, never in option labels. Lines where it doesn't fit say "bé" / "the little one" instead; not every line needs the name. (Earlier v2: name only in questions; 2026-11-09: start/end of any sentence; 2026-11-10 the parent set this rule.) So each line is the name plus one clip, easy to record. Enforced by `namePlacementError` (story.dart, used by the parser) and `check_story.py` (same rule; keep them in sync). Title may contain `{name}` (text only, not narrated).

Playback: `gen_audio.py` splits a line at `{name}` into `_p0`, `_p1`… (letter-less parts skipped); `PlayerCubit` plays the parent's recording (`NameVoice`) or, without one, `audio/ui/<lang>/be.m4a` ("bé" / "sweetie"). Never device TTS (iOS Safari can mute the page's Web Audio). The name text is typed on the welcome page; renaming without re-recording deletes the old recording.

### Stickers

Good answer = the **first** option picked at a choice node is `kind` (`PlayerState.firstPicks`, kept across rewinds; a rewind then the kind option doesn't count). On finish the player screen adds `goodCount` stickers to `StickerCubit` (prefs `stickers_v1` = `{storyId: count}`; replays add more) and opens the ending with `EndingArgs(story, goodCount, choiceCount)`. Ending: `goodCount` copies of the story's sticker pop in, or no sticker + a gentle "try another choice next time"; `EndingCubit` reads `audio/ui/<lang>/sticker_<n>.m4a`. Profile (`/profile`, from the avatar on the sections page, which shows the total): total, each story's sticker ×count grouped under its section's name (not earned = faded grey), language toggle, "edit profile" → `/welcome`.

### Welcome page

Shown only while no profile is saved (router redirect); name, gender (avatar only) and language persist in SharedPreferences (= localStorage on web; private windows / cleared site data lose them), the name recording in a file (device) or prefs `data:` URI (web). Layout never scrolls: `Expanded` hero picker whose avatars shrink; phone landscape = picker beside the form; keyboard up on a short screen = name + start only; the voice hint hides below 640 px height. Mic flow: `NameVoice.micStatus()` → `granted` records straight away; `ask` shows the "your phone will ask, tap Allow" dialog first, then the system prompt; `blocked` (or refused) shows `showMicHelp` with per-platform steps + Open Settings (device) / Retry (web). The `?` button opens the help any time. Web status uses the Permissions API (`mic_permission_web.dart`; Firefox can't tell → `ask`).

### Home performance

`GridView.builder` (lazy: only visible cards build and decode covers); covers are 800×600 WebP drawn once at box size (`StoryImage(bitmap: true)`; decoded at a fixed 400 px or native width, never the exact box width, so resizing doesn't refetch them on web), behind `RepaintBoundary`; 2 columns once the content is ≥ 800 px; screens ≥ 1280 px keep 160 px rails per side free for future ads (`homeSidePadding`); a language switch keeps the old cards up until the new list loads; one `TwinkleField` painter for the stars. `tool/check_assets.py` budgets: cover ≤ 800 px / 60 KB, scene ≤ 1600 px / 150 KB, icon ≤ 400 px / 40 KB, sticker ≤ 600 px / 80 KB, part layer cropped and ≤ 120 KB, clip ≤ 150 KB, story ≤ 4 MB. Image tools save WebP at the highest quality (92 down to 72; sprite layers from 78) that fits these budgets (`tool/webp_save.py`). Tell the user about anything still over budget and offer to downsize.

### Art (kit)

Pictures are AI-made (Gemini app or `gen_image.py`), soft 3D style, from `docs/stories/<id>/art_prompts.json` (`hero`, `setting`, `reference`, `pictures` = cover + sticker, `attach`, `kit`; see `docs/stories/tidy_toys/art_prompts.json`). `reference` (written by `art-director`) is the canonical room/furniture/prop look and per-scene state that reviews and picture checks compare against; tools ignore it. `{hero}` in a prompt = the story's hero sheet `tool/image_refs/<hero>.png` (`kid.png` not made yet). Only drawn sheets and text are sent: never photos of the child or the name. Never commit or print an API key (`.env` or `~/.zshrc`; Claude's Bash skips `~/.zshrc`, use `zsh -ic`).

Moving parts are kit sprites (below). Flat pictures (fallback scenes) get tap areas in `images/hotspots.json` (`[{"kind": "lulu"|"hero"|..., "box": [x, y, w, h], "burst": "sparkles"|"hearts"}]`, Lulu last). Things AI draws badly become SVG layers (`clock_layer.py`); no tool may overwrite `layers/` wholesale (`stage.py` keeps `.svg` layers). `SceneLayers` animates parts (idle `breathe|float|sway|glow`, blink, tap reactions, cue poses/moves); reduced motion turns motion off. AI pictures carry Gemini's ✦ watermark (white at ≤50% opacity, 96 px, 64 px from the bottom-right corner, map in `tool/gemini_watermark_alpha.png`); `remove_watermark.py` undoes it exactly and `import_art.py` / `sprite_sheet.py` run it on every picture. `/story-art <id>` handles each batch the parent saves.

**Kit (every story since 2026-11-11; examples `tidy_toys`, `clock_time`, `prepare_stuff_vacation`; full guide `docs/kit.md`)**: a few Gemini images per story instead of one per scene (the old picture-per-scene workflow with plates, pose edits and `cutout.py` was removed 2026-11-12). The parent makes one empty room (or a day edit / second crop of it), sheets of hero / Lulu poses and props (figures apart on a plain background), plus cover and sticker; prompts live under `"kit"` in `art_prompts.json` (`gen_image.py --kit`); rooms and sheets made for another story are reused with `"from"` (same girl, pajamas, Lulu and room in every story). `sprite_sheet.py` cuts a sheet into sprites in `~/Downloads/story_art/<id>/kit/sprites/<sheet>/` (not in the repo). `docs/stories/<id>/stage.json` says where every part stands per scene (`at` = anchor point, `size` or the sheet's `scale`, `poses`, `shadow`, `flip`, `covers` = room pieces redrawn on top so parts go behind the bed or blanket); `stage.py` compiles it into the normal `layers.json` (shared `layers/kit_*.webp`, one canvas per group of sprites that swap), small flat fallback pictures and icons. Also in `stage.json`: `rooms` + per-scene `room` (several rooms or crops), `crop` (Gemini may return the room 16:9), `erase_specks` (paint out leftover sparkles), `sprites` with `from` + `add` (a sprite made of sprites, e.g. the full toy box with the ball on top, for a `pose` cue). Parts draw in list order (later = in front). `sprite_sheet.py --force-mark` when the ✦ sits on a figure and isn't detected; `--solid` when a pale edge gets bitten off. Layout fixes are number edits; a scene that looks wrong as a kit can still be a normal Gemini picture. `/new-story`, `/story-art`, `/story-continue` and the agents (planner, writer, art-director, art-reviewer, tracker) all follow the kit; the parent approves the composed stills (⏸ stills gate) before cues are tuned. `story_status.py` shows `kit n/m saved, sheets cut, scenes staged`.

### Player flow

`PlayerCubit` enters a node → plays its audio → scene auto-advances after `autoAdvanceDelay` (or shows the rewind offer); a choice reads the question then each option (card glows) with `choiceOptionGap` before each; ending → `finished` → stickers saved → `/story/:id/end`. The player's home button goes to the story's section list; the sleep screen goes to `/`. Each node entry bumps a token so stale narration never advances. Missing audio falls back to `silentSceneDuration`. Narrators: `JustAudioNarrator` (iOS/Android), `WebAudioNarrator` (web: one tap-unlocked `AudioContext`, clips preloaded one step ahead, `audio/ui/` kept across stories). Test audio changes on a release build or deployed site.

### Audio

All clips `.m4a`, per language. The parent records most lines by hand: `gen_audio.py --list` (script), record, save under the filename (`.m4a/.wav/.mp3/.aiff/.caf`, no trimming needed). Then `gen_audio.py --missing` lists gaps: **tell the user what's missing** and offer the cloned voice (`gen_audio.py --lang <l> --story <id>`, never overwrites existing clips without `--force`). Workflow: `/story-audio <id>`.

Cloned voice (`tool/voice/`): Vietnamese = F5-TTS ViVoice fine-tune with `ref/` (calm) and `ref/lively/` (for `!` sentences); English = official F5-TTS v1 base (`models/F5TTS_v1_Base/`) with `ref/en/` (parent's English reference, still to record). `clone_tts.py --lang` splits lines at punctuation with set pauses; Vietnamese only pads `?` pieces so the last tone isn't cut. The model can mis-tone or blur a word: the parent listens to every cloned clip; redo with seeds 4–7 or record by hand. **License: CC-BY-NC(-SA), personal/family use only; replace cloned clips before selling.** Reference voice and models are personal data: never upload, never bundle. Placeholder English UI clips were made with macOS `say` (Samantha); replace them.

**Clean every new recording (pipeline step, no asking)**: whenever the parent says they recorded / added / saved clips, or new audio files appear in a story's `audio/<lang>/`, run `python3 tool/clean_audio.py --story <id>` then `--check` **before** the missing-clip check, the clone or tests. Order: record → drop files → clean → missing? → clone fills gaps → `cue_times.py` → parent listens → test. (Cue `at` = fraction of its clip where the word is said, found from the clip's pauses lined up with the text's sentence/comma breaks; without it the player guesses from the word's place in the text, which runs early on real speech.) `clean_audio.py` high-passes at 60 Hz, denoises with `tool/denoise.py` (learns the steady noise from the clip's own pauses, measured in float, digital silence skipped; Wiener-style subtraction, voice ≤ 0.5 dB quieter, pauses ~15–20 dB), trims edges (keeps 0.05 s / 0.15 s), levels toward -16 LUFS with a -2 dB limiter that shaves at most 6 dB (sharp clips stay down to -20 LUFS), encodes mono AAC 64k with Apple's `aac_at` (keeps a bilingual story small). It only touches clips not yet in `audio_backup/cleaned.json` (by hash, so a new take under the same name is cleaned again); `gen_audio.py` registers clips it makes there. Every finished clip also carries the m4a tag `comment=bedtime_stories_cleaned`: `audio_backup/` isn't in git, so on a fresh clone the tag is what stops a second clean. Originals go to `audio_backup/` (gitignored; `gen_audio.py --force` overwrites clips, so it is the only copy of real recordings; `--restore` puts them back). Report each clip's before → after, and any flagged line (noisy, clipped, still soft): suggest re-recording it.

### Analytics

`core/services/analytics.dart`: `Analytics` interface, `FirebaseAppAnalytics` (best-effort), `NoopAnalytics` (Firebase not configured / failed). Events: `section_open {section}`, `story_start {story_id, lang, section}`, `story_choice {story_id, node_id, option_id, kind}`, `story_rewind {story_id, node_id}`, `story_complete {story_id, ending_id, good_answers}`; user property `hero_gender` (avatar). Tests use `FakeAnalytics`.

**Kids app privacy:** never send the child's name or any identifier (GA terms + COPPA / Play Families / Apple Kids). Ad id, SSAID, IDFV and ad personalization are off in `AndroidManifest.xml` and `Info.plist`; don't add AdSupport/ATT.

### Tests

Run from the project root. The app ships with no stories, so tests use `test/fixtures/stories/demo` (`loadFixtureStory(language:)`), drawn through `DiskAssetBundle` (fixture files from disk, the rest from the app bundle). Bundled stories (from `index.json`) get the asset-exists test in both languages automatically. Welcome and sections layouts are tested at 5 screen sizes × 2 languages for no overflow and no scrolling.
