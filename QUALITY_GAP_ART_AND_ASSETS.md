# Games Codebase Quality Evaluation: The Art & Asset Gap

Date: 2026-04-07

## Scope of what was scanned

- ~330 packages: ~50 raylib examples (`core_*`, `shaders_*`, `textures_*`, `models_*`, `audio_*`, `text_*`, `shapes_*`) + ~280 original games (mostly the `*_2026` series plus titles like `super_mario_1985_lite`, `xiaoxiaole`, `2048`, `asteroid_salvage_2026`).
- Top-rated games per the existing `QUALITY_REPORT_ALL_GAMES.md` (super_mario_1985_lite=76, 2048=69, asteroid_salvage_2026=67, xiaoxiaole=63).
- Sampled `internal/render`, `internal/game`, and `main.mbt` from several top-rated games to verify the report against actual code.
- Searched the whole tree for binary assets, audio, shader, and texture loading.

## TL;DR: yes — assets/美工 is the dominant gap, by a wide margin

The engineering scaffolding (architecture, types, package isolation, tests in some games, docs) is reasonable. What's missing is everything a player actually *experiences*. Raylib has all the relevant APIs (sprites, sound, music, shaders, fonts) but the original games use almost none of them.

## The hard evidence

**1. Zero binary assets in any original game.**
A repo-wide search for `*.png *.wav *.ogg *.mp3 *.ttf` returns hits **only** in the raylib tutorial examples (`textures_*`, `audio_*`, `shaders_*`, `models_*`, `text_*`). Not a single original game (`super_mario_1985_lite`, `xiaoxiaole`, `asteroid_salvage_2026`, the entire `*_2026` series, etc.) ships any sprite, sound, font, or music file. Everything is drawn from primitives at runtime.

**2. Zero audio in original games.**
Searching for `load_sound|play_sound|init_audio|load_music` finds matches only in:
- `audio_*` raylib tutorial examples,
- `abyssal_rift/internal/audio/audio.mbt` — but it's a stub (`pub fn init_audio() -> Unit { () }`, `pub fn process_events(_events) -> Unit { () }`).

So **every original game is silent**. No SFX on hits, no music, no UI feedback sounds.

**3. Zero shaders, render textures, or blend modes in original games.**
`load_shader|begin_shader_mode|begin_blend_mode|render_texture` only appears in `shaders_*` tutorials. No bloom, no glow, no post-processing, no lighting, no particles via additive blending — nothing beyond `draw_rectangle`/`draw_circle`/`draw_line`.

**4. Rendering = primitive painting.**
Concrete look at `super_mario_1985_lite/internal/render/render_world.mbt:1`: the sky is a 4-pixel-tall vertical color lerp loop, hills are colored rectangles, clouds are three overlapping `draw_circle` calls in white, the brick tile is a brown rectangle with four `draw_line` calls for grout. `xiaoxiaole/internal/render/render.mbt:60` does its whole "scene backdrop" with two gradients and three semi-transparent circles. `asteroid_salvage_2026/internal/render/render.mbt:1` draws the starfield as 70 single pixels, the ship as `draw_triangle_lines`, the thrust as one orange `draw_circle`. This is a representative, not cherry-picked, sample.

**5. Fonts are the engine default.**
No custom font loading anywhere outside the `text_*` examples. All text is the raylib built-in pixel font, which is the strongest visible "this is a tech demo" tell.

**6. The existing quality report doesn't even measure this.**
`QUALITY_REPORT_ALL_GAMES.md` scores on architecture/maintainability/testability/docs/robustness — purely engineering axes. The dimensions a commercial player would care about (art direction, audio, juice/feel, UX polish, content depth, accessibility) aren't in the rubric. So the "Good/Fair" ratings overstate the player-facing quality considerably.

## Gap inventory vs. commercial 2D games

Ranked by how much each gap separates the repo from a commercial title:

| # | Gap | Severity | Repo today | Commercial baseline |
|---|---|---|---|---|
| 1 | **Art assets (美工)** | Critical | 0 sprites, primitives only | Hand-drawn or pixel sprite sheets, tilesets, animated frames, parallax bg |
| 2 | **Audio** | Critical | Total silence | SFX per action, looping music, mixing, ducking |
| 3 | **Custom fonts/typography** | High | raylib default pixel font everywhere | At least one display + one body font, kerning, drop shadows |
| 4 | **Juice / game feel** | High | Some screen shake exists; no hitstop, particle bursts via blend modes, easing on UI | Hitstop, freeze frames, particle bursts, tweened HUDs, controller rumble |
| 5 | **Post-processing & shaders** | High | None used | Bloom, CRT, color grade, vignette, screen-space distortions |
| 6 | **Animation systems** | High | No skeletal/sprite animation; movement is direct state→position | Sprite atlases, easing curves, IK or sprite hierarchies |
| 7 | **Content depth** | Medium | Most games are one screen / one mechanic loop; very few have meta-progression | Levels, bosses, unlocks, save systems |
| 8 | **UX polish** | Medium | Functional HUD; no menus, options, pause overlays, settings persistence | Title screen, options menu, key remap, accessibility toggles |
| 9 | **Onboarding** | Medium | Controls printed on the play field as instructions | Tutorial level or contextual prompts |
| 10 | **Test coverage** | Medium | 328/330 games have no tests | Logic-layer unit tests for ship-able games |
| 11 | **Long render functions** | Low–Medium | 239 games have one >120-line function (mostly `render.mbt`) | Decomposed render passes per layer |
| 12 | **Localization** | Low | Hard-coded English | i18n string tables |

The rest — module structure, type separation, build hygiene, doc comments — is in better shape than most commercial indie codebases. **The gap is the surface, not the structure.**

## Why "美工" looks even bigger than it is

Three secondary effects amplify the visual gap:

1. **Shape-based art forces a flat color palette.** Without textures you can't get gradients/normals/noise cheaply, so everything reads as "vector art." The existing palettes are tasteful (xiaoxiaole's gem rendering at `render.mbt:112` is a good example of layering circles for a faux-3D jewel) but they hit a ceiling fast.
2. **Render functions are huge precisely because there's no asset pipeline.** The 277-LOC `dragon_boat_sprint_2026/internal/render/render.mbt` function exists because each visual element needs ~10 primitive calls. With sprites, that becomes 1 line each. The "complexity" P0 in the existing remediation plan is partially a *symptom* of the asset gap.
3. **Silence is jarring.** A weak art game with great audio reads as "stylized." A great art game without audio reads as broken. The repo gets neither lift.

## Recommendations, in priority order

These are aimed at *highest player-perceived quality lift per unit of work*, not engineering elegance.

### P0 — Stand up an asset pipeline (do this once, all games benefit)

1. **Create `assets/shared/`** at the repo root with: 1 display font, 1 body font, ~20 generic SFX (click, hit, explode, pickup, fail, success, step, swoosh×3, etc.), 2–3 ambient music loops. CC0 sources: Kenney.nl, OpenGameArt, freesound.org, Google Fonts. License each in `ASSETS.md`.
2. **Create `utils/audio`** as a new shared package mirroring `utils/draw`: `init_audio()`, `play_sfx(name)`, `play_music(name)`, `set_volume(...)`. Wire it to `@raylib.load_sound`/`load_music_stream`. Right now `utils/draw/draw.mbt` already centralizes font loading — copy that pattern.
3. **Create `utils/sprite`** with one helper to load and cache a texture and one to draw an atlas frame. Without this, no game can opt into sprites without rewriting its render loop.

### P1 — Pick 5 flagship games and fully art them (don't try to upgrade all 280)

Realistically you cannot reskin 280 games. Pick the 5 with the strongest gameplay loops (per the existing scores: `super_mario_1985_lite`, `2048`, `xiaoxiaole`, `asteroid_salvage_2026`, plus one *_2026 game like `peking_opera_duel_2026`) and:

- Replace primitive draws with a sprite atlas.
- Add 6–10 SFX hooked to game events.
- Add 1 music loop with volume mixing.
- Add a title screen + pause overlay using the new font.
- Add screen shake + hitstop + 1 particle system.

This is the credible "commercial-feel" demo. The other 275 stay as the engineering portfolio they already are.

### P2 — Juice without assets (cheap wins for the long tail)

For games you don't reskin, you can still add a lot of perceived quality with code only:

- **Tweening helpers** (`utils/ease`): linear/quad/cubic ease for HUD numbers, panel slides, color flashes. One small package, every game uses it.
- **Particle system** (`utils/particles`): pooled particles drawn with `draw_circle` + alpha fade. Hook to "thing died" events.
- **Camera shake helper** (`utils/shake`): trauma-based shake (Squirrel Eiserloh's model). Some games have ad-hoc shake; standardize it.
- **Hitstop helper**: skip 2–3 update frames on big events. Trivial code, huge feel impact.
- **Default UI kit** (`utils/ui`): button, panel, slider, toggle drawn from primitives but with proper hover/press states and easing. Removes the "raw raylib HUD" smell.

### P3 — Art direction guideline doc

Write one short `ART.md` defining: palette guidance, font usage rules, recommended sprite size (e.g., 16×16 or 32×32), atlas naming convention, shader presets. Without it, contributing assets becomes a snowflake exercise per game.

### P4 — Re-rank the quality report

Add `art`, `audio`, `feel`, and `content_depth` axes to `QUALITY_REPORT_ALL_GAMES.md`. The current rubric will keep scoring games "Fair" forever even after they get reskinned, because it doesn't see surface quality. Until the rubric measures it, it won't get prioritized.

### Things that are *not* the highest leverage right now

- **Splitting long render functions**: cosmetic refactor; the LOC will collapse naturally once primitives become sprite calls. Don't pre-refactor.
- **ARCHITECTURE.md per game**: 329 games are missing it but the architecture is already templated and predictable. Diminishing returns.
- **More tests on long-tail games**: useful for engineering hygiene but invisible to players. Test the 5 flagships well; let the rest stay at smoke level.

## Bottom line

The engineering side of this codebase is already past the "tech demo" line — separated `types/game/render`, consistent package layout, good doc comments, an in-house quality report, even a remediation plan with waves and lanes. **What it lacks is the entire art and audio surface that players actually perceive as "a game."** Raylib can do all of it; the code just never asks raylib to. The fastest way to close the gap is not fixing 280 games but standing up a shared asset/audio/sprite pipeline once, using it to fully reskin a small flagship set, then letting code-only juice helpers lift the long tail by ~30%.
