# Games Project Memory

## Project Overview
- MoonBit + Raylib game examples repo at `/Users/hongbozhang/git/games`
- Module: `tonyfettes/raylib-examples`
- Build: `moon build --target native <game>/`
- Check: `moon check`, Test: `moon test`

## Quality Improvement Campaign
Working on 50-51 games per batch, alphabetically by game name suffix.

### Batch 1 (first 50 _2026 games) — COMPLETE
- README sections: all 50 done
- Docstrings multi-file: commit a71c7e9 (73 files, 929 insertions)
- Docstrings single-file: commit 8e692ef (33 files, 942 insertions)
- Codex review: both commits passed clean

### Batch 2 (games 51–101: harbor_defense → power_grid_operator) — COMPLETE
- README sections: commit b9f4192 (21 READMEs, 2640 insertions)
- Docstrings: commit ebf1cd5 (119 files, 2108 insertions)
- Pushed to remote: main branch up to date at ebf1cd5
- Codex review: running (bqb6rioak, bi8otlxvl)

### Batch 3 — NOT STARTED

## MoonBit Doc Comment Format
```
///|
/// Description of what this does.
fn function_name(...) -> ... {
```
- `///|` is a visibility marker (not a bare blank doc line)
- "Bare marker" = `///|` followed directly by declaration (no `/// description`)
- Fix: insert `/// description text` between `///|` and the declaration

## README Required Sections
1. `## Public API Reference` — tables of public types, functions, constants
2. `## Architecture` — package structure diagram + data flow + design patterns
3. `## Improvement & Refinement Plan` — 5–7 numbered improvements

Good README example: `hotpot_empire_rush_2026/README.mbt.md`

## Workflow
- After each commit: run `codex review --commit <SHA>`
- Separate commits: READMEs first, then docstrings
- Parallel agents: group games 4-5 per agent for README+docstring work

## Architecture Patterns
- Multi-file game structure:
  ```
  <game>_2026/
  ├── main.mbt          — Entry, game loop
  ├── moon.pkg
  └── internal/
      ├── types/        — Structs, constants, utils
      ├── game/         — Logic, input, state machine
      └── render/       — Drawing routines
  ```
- Single-file game: only main.mbt + moon.pkg + pkg.generated.mbti + README.mbt.md
- State machine: state_title(0), state_playing(1), state_paused(2), state_game_over(3)
- Integer-encoded enums for game states/types
- Delta-time updates for frame-rate independence
