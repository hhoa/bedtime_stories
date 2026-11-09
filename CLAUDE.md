# CLAUDE.md

## Project: Bedtime Stories (v2)

Interactive bedtime stories for a 3-5 year old who can't read yet. Every scene is narrated; at choice points the kid taps one of two big picture cards. "Kind" and "learn" choices both end happily; a learn path shows a gentle natural consequence, then offers to rewind and try the other option. **One sticker per good answer** (kind option picked first time at a choice); the profile page shows the sticker book. Languages: **Vietnamese (default) and English**, switched on the welcome and profile pages. Platforms: Web, iOS, Android (phone + tablet).

v2 of `../bedtime_story` (v1). Differences from v1: welcome page never scrolls + mic-permission guide; `{name}` only in questions; stickers per good answer + profile page; one hero per story (no girl/boy art folders); AI art only (clock_time workflow, no SVG-code art); bilingual stories and audio; lazy home grid + small covers + asset budgets. Plan: `~/.claude/plans/review-bedtime-story-and-create-mutable-prism.md`.

**Phase 1: local only.** Stories are bundled assets (none yet: make them with `/new-story`). Only Firebase piece is Analytics, in a **new Firebase project (not created yet)**: `lib/firebase_options.dart` is a placeholder that throws, so the app runs with `NoopAnalytics`. When the project exists: `flutterfire configure --project=<id> --platforms=ios,android,web` (adds the gradle plugin lines too), then `firebase.json`/`.firebaserc` for hosting.

## Commands

Always prefix with `fvm` (Flutter 3.47.9, pinned in `.fvmrc`):

```bash
fvm flutter pub get
fvm dart run build_runner build -d   # after editing @freezed / @JsonSerializable
fvm dart format .
fvm flutter analyze
fvm flutter test
fvm flutter run -d chrome            # or an iPad / iPhone simulator

python3 tool/check_story.py <id> [--art]      # lint story.json (both languages, {name} rule, graph, rewind); --art: images, layers, cue parts, poses
python3 tool/check_assets.py [<id>]           # size budgets (covers, scenes, layers, audio, story total); exit 1 when over
python3 tool/gen_image.py --refs [--only kid] [--prompts-out <dir>]   # character sheets in tool/image_refs/
python3 tool/gen_image.py --story <id> [--dry] [--only s1] [--force] [--prompts-out <dir>]   # from docs/stories/<id>/art_prompts.json
python3 tool/gen_image.py --story <id> --plates|--poses --prompts-out <dir>   # Gemini edit prompts for clean plates / poses
python3 tool/import_art.py <id> <file|dir> [--as s1_toys]   # AI picture → WebP (scene 1600×1200, cover 800×600, icon 400², sticker 600²)
python3 tool/preview_hotspots.py <id> <dir>   # hotspot boxes + 10% grid on each picture
tool/cutout/.venv/bin/python tool/cutout.py <id> <scene> --parts lulu[,hero] [--plate <png>] [--pose hero=yawn:<png>] [--preview <dir>]
tool/cutout/.venv/bin/python tool/move_part.py <id> <scene> lulu --to x,y [--scale 0.7]
python3 tool/crop_layers.py <id> [--dry]      # crop old full-canvas cut layers
python3 tool/clock_layer.py <id> [--preview <dir>]   # SVG clock part over AI pictures (docs/stories/<id>/clock.json)
python3 tool/gen_audio.py --list [--lang vi|en] [--story <id>]   # recording script: filename → line
python3 tool/gen_audio.py --missing [--story <id>]               # clips not recorded yet
python3 tool/gen_audio.py [--lang vi|en] [--story <id>]          # fill missing clips (cloned voice if set up, else macOS say)
python3 tool/gen_audio.py --story <id> --lang vi --force --only s2,c1_p1 [--seed 7] [--out <dir>]   # redo some clips
python3 tool/boost_audio.py --check           # soft clips; without --check boosts toward -16 LUFS (--restore undoes)
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
  core/       theme/ router/ services/(narrator|analytics|name_voice|mic_permission_*) utils/ widgets/ models/
  features/
    profile/  data: ProfileStorage (name, gender, language), StickerStorage
              cubit: ProfileCubit, LanguageCubit, StickerCubit (app-wide), WelcomeCubit
              WelcomeScreen, ProfileScreen (sticker book)
    stories/  domain (Story, StoryNode union, StoryRepository), data (StoryModel JSON + validation, AssetStoryRepository)
              presentation (HomeScreen, StoryListCubit, StoryCard)
    player/   PlayerCubit (narration, choices, rewind, first picks), StoryPlayerScreen, ScenePicture, SceneLayers, StoryPanel
    ending/   EndingScreen (stickers), EndingCubit (reads the sticker line), SleepScreen
assets/
  stories/index.json                     list of bundled story ids
  stories/<id>/story.json                node graph, both languages
  stories/<id>/images/*.webp             scenes, cover, icons, sticker (one folder, no hero split)
  stories/<id>/images/layers/            cut parts + poses + SVG overlays; images/layers.json, images/hotspots.json
  stories/<id>/audio/<vi|en>/<clip>.m4a
  audio/ui/<vi|en>/<key>.m4a             rewind, be (name fallback), sticker_0|1|2
  images/hero_<girl|boy>.svg             kid avatar (home, profile)
tool/       image, audio and check scripts (above)
docs/stories/<id>/   outline.md, review.md, art_prompts.json[, clock.json]
docs/examples/       clock_time prompts from v1 (style reference)
.claude/    skills/new-story, skills/story-audio; agents/ story-planner, story-writer, story-reviewer
test/fixtures/stories/demo/   test-only bilingual story (tiny WebPs, a cut part with a pose, hotspots)
```

### Story JSON

```json
{"id": "...", "theme": "sleep", "hero": "girl|boy|kid",
 "title": {"vi": "...", "en": "..."}, "cover": "images/cover.webp", "start": "s1", "nodes": [...]}
```
Every `text` (node) and `label` (option) is `{"vi": "...", "en": "..."}`; the parser and `check_story.py` reject a story missing either language anywhere. `cues` are per language: `{"vi": [{"word", "part", "action"}], "en": [...]}` (words differ). `AssetStoryRepository.getStory(id, language)` builds a `Story` for one language (text, cues, `audioDir = audio/<lang>`); pictures are shared.

Nodes: `scene` (`next`, optional `offer_rewind_to` = a choice id), `choice` (`text` = question, 2 `options` with `kind: kind|learn`, `icon`, `label`, `next`), `ending` (`sticker`). Any node may set `ambient` (`stars|sparkles|zzz|motes`); `ambient_origin: [x, y]` (0–1) puts `zzz` at the sleeping head. Cue `action`: `hop|wiggle|pulse` (any part or hotspot), `pose` + `"pose": "<name>"` (switch picture, holds), `move` + `"to": [x, y]` (slide, holds); pose/move need a moving layer. Node `"poses": {"hero": "sit_up"}` = starting pose. `StoryModel.toEntity` rejects broken links, duplicate ids, missing ending, unknown poses.

Ambient per picture: night room/sky → `stars`; Lulu or magic → `sparkles`; asleep → `zzz` + origin; daytime → `motes`; busy/tense → none. A choice reusing the scene's picture uses the same ambient.

### The `{name}` rule

The child's name is said only when the kid is asked something. Scenes and the ending say "bé" / "the little one". `{name}` may appear in a choice question (any sentence) or in a scene sentence ending with `?`, and must **start or end** its sentence ("{name} ơi, …?", "…, {name}?"), never twice in a sentence, never in option labels. So each line is the name plus one clip, easy to record. Enforced by `namePlacementError` (story.dart, used by the parser) and `check_story.py` (same rule; keep them in sync). Title may contain `{name}` (text only, not narrated).

Playback: `gen_audio.py` splits a line at `{name}` into `_p0`, `_p1`… (letter-less parts skipped); `PlayerCubit` plays the parent's recording (`NameVoice`) or, without one, `audio/ui/<lang>/be.m4a` ("bé" / "sweetie"). Never device TTS (iOS Safari can mute the page's Web Audio). The name text is typed on the welcome page; renaming without re-recording deletes the old recording.

### Stickers

Good answer = the **first** option picked at a choice node is `kind` (`PlayerState.firstPicks`, kept across rewinds; a rewind then the kind option doesn't count). On finish the player screen adds `goodCount` stickers to `StickerCubit` (prefs `stickers_v1` = `{storyId: count}`; replays add more) and opens the ending with `EndingArgs(story, goodCount, choiceCount)`. Ending: `goodCount` copies of the story's sticker pop in, or no sticker + a gentle "try another choice next time"; `EndingCubit` reads `audio/ui/<lang>/sticker_<n>.m4a`. Profile (`/profile`, from the home avatar, which shows the total): total, each story's sticker ×count (not earned = faded grey), language toggle, "edit profile" → `/welcome`.

### Welcome page

Shown only while no profile is saved (router redirect); name, gender (avatar only) and language persist in SharedPreferences (= localStorage on web; private windows / cleared site data lose them), the name recording in a file (device) or prefs `data:` URI (web). Layout never scrolls: `Expanded` hero picker whose avatars shrink; phone landscape = picker beside the form; keyboard up on a short screen = name + start only; the voice hint hides below 640 px height. Mic flow: `NameVoice.micStatus()` → `granted` records straight away; `ask` shows the "your phone will ask, tap Allow" dialog first, then the system prompt; `blocked` (or refused) shows `showMicHelp` with per-platform steps + Open Settings (device) / Retry (web). The `?` button opens the help any time. Web status uses the Permissions API (`mic_permission_web.dart`; Firefox can't tell → `ask`).

### Home performance

`GridView.builder` (lazy: only visible cards build and decode covers); covers are 800×600 WebP drawn once at box size (`StoryImage(bitmap: true)`), behind `RepaintBoundary`; one `TwinkleField` painter for the stars. `tool/check_assets.py` budgets: cover ≤ 800 px / 60 KB, scene ≤ 1600 px / 150 KB, icon ≤ 400 px / 40 KB, sticker ≤ 600 px / 80 KB, cut layer cropped and ≤ 120 KB, clip ≤ 150 KB, story ≤ 4 MB. Tell the user about anything over budget and offer to downsize.

### Art (clock_time workflow)

Pictures are AI-made (Gemini app or `gen_image.py`), soft 3D style, from `docs/stories/<id>/art_prompts.json` (`setting`, `pictures`, `outfits`, `plates`, `poses`; see `docs/examples/clock_time_art_prompts.json`). `{hero}` in a prompt = the story's hero sheet `tool/image_refs/<hero>.png` (`kid.png` not made yet). Only drawn sheets and text are sent: never photos of the child or the name. Never commit or print an API key (`.env` or `~/.zshrc`; Claude's Bash skips `~/.zshrc`, use `zsh -ic`).

Moving parts: give flat pictures tap areas in `images/hotspots.json` (`[{"kind": "lulu"|"hero"|..., "box": [x, y, w, h], "burst": "sparkles"|"hearts"}]`, Lulu last). `cutout.py` cuts listed parts (rembg) from a crop around their hotspot into `images/layers/<scene>_<i>.webp`, cropped to the part (`"rect"`, ~7× less decode memory), over a base with the parts removed (use a Gemini clean plate; without one the hole smears). Poses: one Gemini edit per pose (`gen_image.py --poses`), cut with `--pose part=name:png`, auto-aligned; check `<scene>_poses.jpg`. Cut only parts nothing covers; touching characters stay one part or flat with hotspots. Things AI draws badly become SVG layers (`clock_layer.py`); no tool may overwrite `layers/` wholesale. `SceneLayers` animates parts (idle `breathe|float|sway|glow`, blink, tap reactions, cue poses/moves); reduced motion turns motion off. AI pictures carry Gemini's ✦ watermark bottom-right; crop or cover it at import.

### Player flow

`PlayerCubit` enters a node → plays its audio → scene auto-advances after `autoAdvanceDelay` (or shows the rewind offer); a choice reads the question then each option (card glows) with `choiceOptionGap` before each; ending → `finished` → stickers saved → `/story/:id/end`. Each node entry bumps a token so stale narration never advances. Missing audio falls back to `silentSceneDuration`. Narrators: `JustAudioNarrator` (iOS/Android), `WebAudioNarrator` (web: one tap-unlocked `AudioContext`, clips preloaded one step ahead, `audio/ui/` kept across stories). Test audio changes on a release build or deployed site.

### Audio

All clips `.m4a`, per language. The parent records most lines by hand: `gen_audio.py --list` (script), record, save under the filename, trim silence. Then `gen_audio.py --missing` lists gaps: **tell the user what's missing** and offer the cloned voice (`gen_audio.py --lang <l> --story <id>`, never overwrites existing clips without `--force`). Workflow: `/story-audio <id>`.

Cloned voice (`tool/voice/`): Vietnamese = F5-TTS ViVoice fine-tune with `ref/` (calm) and `ref/lively/` (for `!` sentences); English = official F5-TTS v1 base (`models/F5TTS_v1_Base/`) with `ref/en/` (parent's English reference, still to record). `clone_tts.py --lang` splits lines at punctuation with set pauses; Vietnamese only pads `?` pieces so the last tone isn't cut. The model can mis-tone or blur a word: the parent listens to every cloned clip; redo with seeds 4–7 or record by hand. **License: CC-BY-NC(-SA), personal/family use only; replace cloned clips before selling.** Reference voice and models are personal data: never upload, never bundle. Placeholder English UI clips were made with macOS `say` (Samantha); replace them.

**Check loudness after new recordings**: `python3 tool/boost_audio.py --check`; if soft, offer `boost_audio.py` (backs up to `audio_backup/`, `--restore` undoes; `gen_audio.py --force` overwrites clips, so the backup is the only copy of real recordings).

### Analytics

`core/services/analytics.dart`: `Analytics` interface, `FirebaseAppAnalytics` (best-effort), `NoopAnalytics` (Firebase not configured / failed). Events: `story_start {story_id, lang}`, `story_choice {story_id, node_id, option_id, kind}`, `story_rewind {story_id, node_id}`, `story_complete {story_id, ending_id, good_answers}`; user property `hero_gender` (avatar). Tests use `FakeAnalytics`.

**Kids app privacy:** never send the child's name or any identifier (GA terms + COPPA / Play Families / Apple Kids). Ad id, SSAID, IDFV and ad personalization are off in `AndroidManifest.xml` and `Info.plist`; don't add AdSupport/ATT.

### Tests

Run from the project root. The app ships with no stories, so tests use `test/fixtures/stories/demo` (`loadFixtureStory(language:)`), drawn through `DiskAssetBundle` (fixture files from disk, the rest from the app bundle). Bundled stories (from `index.json`) get the asset-exists test in both languages automatically. Welcome layout is tested at 5 screen sizes × 2 languages for no overflow and no scrolling.
