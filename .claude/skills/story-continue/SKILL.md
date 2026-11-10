---
name: story-continue
description: Pick up a bedtime story where it stopped. Pictures and recordings arrive over days, in batches; this checks what's new (pictures saved in Downloads, recordings in audio/), does the waiting work (import, clean, cut out, wire, test) and says exactly what the parent should make or record next. Use for "/story-continue", "continue the story", "where did we stop", "what's left", "I added the images / pictures", "I recorded / saved the audio", "I'm back".
argument-hint: [story_id]
---

# /story-continue

Resume a story that is mid-way. The parent works in batches over days; this session may know nothing about the last one. Read CLAUDE.md first.

## 1. Where are we
- No id: `python3 tool/story_status.py --brief`. One unfinished story → that one. Several → ask which (list them with their one-line status). None → say so and offer `/new-story`.
- Run the `story-tracker` agent with the id. Show the parent its report short: NEW, DONE, LEFT, BLOCKERS (skip empty lines).

## 2. Do the waiting work, in this order
Loop: do the tracker's NEXT, then `python3 tool/story_status.py <id>` again, until NEXT needs the parent.
1. **New recordings** (`not_cleaned`): `/story-audio <id>` steps 2–3 (clean, then the missing list). Cleaning never needs asking.
2. **New pictures / unknown files / scenes ready to cut**: `/story-art <id>` (it asks before importing a file under a guessed name).
3. **Approval pending** (Gate 1, Gate 2, art prompts): show what's needed and ask. Record the answer in `docs/stories/<id>/progress.json` `gates` (date `YYYY-MM-DD`).
4. **Art prompts not written / review FIX**: `/new-story <id>` step 3 (art-director ↔ art-reviewer). Prompts changed → rebuild the prompts page and republish to the link in `progress.json` `prompts_page`.
5. **Everything made**: wire + test (`/new-story` step 4: `python3 tool/wire_story.py <id>`, `fvm flutter analyze`, `fvm flutter test`), then the `/new-story` step 5 report.

Stop and hand over when the only steps left are the parent's. Never generate cloned audio without the parent's yes (`/story-audio` step 3 asks).

## 3. Hand over
End with what the parent should do next, concrete and in order, at most ~5 lines:
- Pictures to make, by name, pictures before their plates and poses, plus the prompts page link from `progress.json`; folder `~/Downloads/story_art/<id>/` (`plates/`, `poses/` inside).
- Redo items with the sentence to add to the Gemini prompt.
- Clips to record (count per language; the full script with `python3 tool/gen_audio.py --story <id> --list`), or cloned clips to listen to.
- Blockers (e.g. English voice reference missing).
- "Next time just say *I added the pictures* (or run /story-continue)."

## progress.json
`docs/stories/<id>/progress.json` holds what files can't show. Keep it current; the skills write their parts:
```json
{"gates": {"outline": "2026-11-09", "script": "2026-11-09", "art_prompts": "2026-11-09"},
 "prompts_page": "https://claude.ai/artifact/...",
 "redo": {"s1_backpack": "Lulu too big → add: Lulu about the size of a cat"},
 "listened": {"vi": ["s1", "c1_p1"], "en": []},
 "notes": []}
```
`redo`: written by `/story-art` when the parent agrees to redo, removed when the new picture is imported and OK. `listened`: cloned clips the parent approved (`/story-audio` step 4). `notes`: anything a later session must know (one line each). No names, photos or voice data.
