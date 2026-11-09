# Plan: character pose animation (background + moving characters)

Status: built 2026-11-08 (model, player, `gen_image.py --poses`, `cutout.py --pose`, checks, tests). Pilot story: clock_time (waiting on Gemini pictures). Extra: `tool/clock_layer.py` draws the clock as an SVG part with poses over the AI pictures.

## Why

The parent wants more action in scenes: the child lifts the spoon to her mouth, chews, Lulu claps, and so on. Today a raster scene can only move whole cut-out parts with `hop | wiggle | pulse` (see `SceneLayers`), which reads as a stiff puppet.

Ruled out (tested 2026-11-08 on eat_veggies frames, 1200×900, 3 s):

| Clip | MP4 (24 fps) | anim WebP (12 fps) | GIF (12 fps) |
|---|---|---|---|
| only Lulu hops | 0.07 MB | 0.24 MB | 1.6 MB |
| whole picture moves | 0.16 MB | 1.5 MB | 10.8 MB |

- **GIF:** 10–60× bigger. Only 256 colors, so cheeks turn blotchy and the night sky gets dotted. Every frame is decoded into memory, and it can't be paused or started on a word. No.
- **AI video (Veo, Kling, Hailuo, Luma, Grok):** every option needs payment. Not now. If it comes back, use MP4 H.264, never GIF.

Chosen: **a background plate plus character cut-outs in several poses, animated by Flutter.** It costs only Gemini app image edits (no video, no API spend), files are tiny, and it runs smoothly on web, iOS and Android.

## Idea

Each animated scene is built from:
1. **Plate:** the scene with no characters (the existing `gen_image.py --plates` flow).
2. **Pose pictures:** Gemini app *edits of the same scene* where only the pose changes. Because they're edits, each character stays in the same place. Examples: "girl lowers the spoon to the plate", "girl chewing with puffy cheeks", "Lulu clapping".
3. **Cut-outs:** `tool/cutout.py` cuts each character from each pose picture into a transparent WebP; all poses of a part share one crop rect (`"rect"` in layers.json, `tool/layer_crop.py`), so they line up on the plate automatically.
4. **Flutter:**
   - On a narrated word, a part **switches pose** with a quick cross-fade plus a small squash/bounce.
   - A part can also **move** to a new spot (Lulu hops across the table).
   - Idle loops, blink and tap reactions keep working.

The motion feels like keyframe cartoon steps, not video. That's enough for age 3–5.

## Design scene art for this from the start (new story)

- Write the script with **visible actions on clear words** ("xúc", "cắn", "nhai", "vỗ tay", "nhảy"), 1–3 per scene.
- Compose pictures so characters are **not covered** by tables or blankets where they'll move. A pose change in place is fine behind a table; a jump is not, because the cut edge shows.
- Keep the poses in one scene small and similar (same spot, same size). Big changes need `move`.
- Per scene, plan in `docs/stories/<id>/art_prompts.json`:
  - `"plates": {scene: [parts]}` (exists)
  - new `"poses": {scene: {part: {pose_name: "edit instruction"}}}`. The base picture counts as pose `default`.

## Build steps

### 1. Prompts: `tool/gen_image.py`
- Add a `--poses --prompts-out <dir>` mode next to `run_plates` (`tool/gen_image.py:316`).
- One prompt file per pose. Prompt: "Keep this picture exactly the same. Only change: <instruction>. Same position, size, lighting and style." Save target: `poses/<scene>__<part>__<pose>.png`.

### 2. Cut: `tool/cutout.py`
- New `--pose <part>=<name>:<png>` (repeatable). Cut the part from that pose picture using the same hotspot crop and write `layers/<scene>_<i>_<pose>.webp`.
- Add the poses to the part's entry in `images/layers.json`: `"poses": {"default": "layers/..._1.webp", "chew": "layers/..._1_chew.webp"}`.
- The base layer still comes from `--plate`.
- Keep the girl→boy copy rule (`copy_to_boy`).
- Check that the poses line up: overlay them in `--preview`.

### 3. Model (`lib/features/stories/domain/entities/story.dart`, `lib/features/stories/data/models/story_model.dart`)
- `SceneLayer`: add `Map<String, String> poses` (name → asset, may contain `{hero}`).
- `PartAction`: add `pose` and `move`.
- `StoryCue`: add an optional `pose` (pose name, used with action `pose`) and an optional `to: [x, y]` (0–1 canvas fractions, used with action `move`).
- Story node: add optional `"poses": {"hero": "chew"}`, the starting pose for that node. Use it when a choice node reuses the previous picture, so the pose doesn't jump back.
- Validation:
  - Unknown pose names are rejected (`_byName` style errors at `story_model.dart:163`).
  - A `move` cue needs `to`.
- Rerun `fvm dart run build_runner build -d`.

### 4. Player (`lib/features/player/presentation/widgets/scene_layers.dart`)
- A part with poses stacks all of its pose images. They're kept loaded (like the blink copy at `scene_layers.dart:159-174`), and only the current one is shown.
- On a `pose` cue: cross-fade about 150 ms to the new pose and add a small squash (the reuse of `_Motion` hop squash at `scene_layers.dart:236-242`). The pose holds until the next cue or the next node.
- On a `move` cue: tween the part's translation to `to` over about 600 ms with an ease-in-out curve and a small arc, then hold there. The tap box (`hitPart`) follows the offset.
- Taps and idle loops stay as they are. Blink uses the current pose only, or skip blink while the part has poses.
- Reduced motion: pose switches happen with no cross-fade or squash (the change carries meaning), and `move` jumps straight to the end spot.
- Precache: `_precacheNext` also loads every pose asset of the next nodes.

### 5. Checks
- `tool/check_story.py --art`: each `pose` cue names a pose that exists in `layers.json`, and each `move` has `to` inside 0–1.
- Tests:
  - Parser accepts and rejects the new fields.
  - Asset test: every pose file exists.
  - Widget test: a `pose` cue switches the visible layer.

### 6. Docs
- Update CLAUDE.md: the "AI raster art" and "Story JSON" sections, plus the commands list (`--poses`, `cutout.py --pose`).
- Update the `/new-story` skill: when writing the script, mark the action words and add `poses` to `art_prompts.json`.

## Verification

- `fvm flutter analyze` and `fvm flutter test` pass.
- `python3 tool/check_story.py <id> --art` passes.
- `fvm flutter run -d chrome`: each pose switches on its word, the character doesn't shift between poses, the choice node keeps its starting pose, and the narration timing is unchanged.
- On the deployed site, iPhone Safari: smooth, no flicker on the first switch (poses precached).
- Size: each pose layer about 100–200 KB, so a scene with 3 poses is under 1 MB.

## Session notes

- The test clips and compare sheet from 2026-11-08 were in the session scratchpad and may be gone. The table above has the numbers.
- Gemini edits can drift slightly in position and light. If a pose doesn't line up in the `cutout.py --preview` overlay, redo that edit rather than adding auto-alignment.
