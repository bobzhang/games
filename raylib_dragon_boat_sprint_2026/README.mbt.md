# raylib_dragon_boat_sprint_2026

A rhythm-based dragon boat racing game. Paddle in time with the beat to build speed, steer around river hazards, and race against AI rivals to the finish line through multiple checkpoints.

## Build and Run

```bash
moon build --target native raylib_dragon_boat_sprint_2026/
./_build/native/debug/build/raylib_dragon_boat_sprint_2026/raylib_dragon_boat_sprint_2026.exe
```

## Controls

- **A/D or Left/Right**: Steer between lanes
- **Space/J**: Paddle (time with the rhythm beat for bonus speed)
- **S/K**: Stabilize / reduce wobble
- **L**: Burst (temporary speed boost)
- **P**: Pause
- **R**: Restart
- **F11**: Toggle borderless windowed

## How to Play

- Paddle in sync with the rhythm indicator for "Perfect" or "Good" timing to build speed and streaks
- Steer to avoid debris and waves that slow you down
- Build rhythm meter to unlock burst ability for a speed boost
- Pass through checkpoints and finish before your rivals
- Hit count and streak affect your final ranking

## Public API Reference

### Package `tonyfettes/raylib-examples/raylib_dragon_boat_sprint_2026`

Entry point. Initialises a 1720x980 window at 120 fps, allocates `Game::new()`, and drives the game loop by calling `update_game` and `draw_frame` each frame inside `@raylib.begin_drawing` / `@raylib.end_drawing`.

### Package `tonyfettes/raylib-examples/raylib_dragon_boat_sprint_2026/internal/types`

#### Enums

| Enum | Variants |
|---|---|
| `GameState` | `Title`, `Play`, `Paused`, `Result` |

#### Structs

| Struct | Key fields |
|---|---|
| `Input` | `steer : Float`, `paddle_pressed`, `stabilize_down`, `burst_pressed`, `pause_pressed`, `restart_pressed`, `start_pressed` |
| `Hazard` | `active`, `kind : Int`, `lane`, `dist`, `size`, `drift`, `phase` |
| `Rival` | `active`, `id`, `lane`, `dist`, `speed_bias`, `stroke_t` |
| `Game` | `input`, `hazards : Array[Hazard]`, `rivals : Array[Rival]`, `state`, `distance`, `speed`, `lane`, `rhythm_t`, `stroke_cd`, `streak`, `rhythm_meter`, `burst_t`, `wobble`, `checkpoint_idx`, `score`, `hit_count`, `finish_rank`, `finish_time`, `game_t`, `ui_t`, `msg`, `msg_t` |

#### Functions

| Function | Description |
|---|---|
| `pub fn Input::new() -> Input` | Returns a zeroed input snapshot |
| `pub fn Hazard::new() -> Hazard` | Returns an inactive hazard placeholder |
| `pub fn Rival::new() -> Rival` | Returns an inactive rival placeholder |
| `pub fn Game::new() -> Game` | Allocates a full race session with pre-built object pools |
| `pub fn checkpoint_distance(index : Int) -> Float` | World distance for checkpoint at given index |

#### Constants

| Constant | Value | Description |
|---|---|---|
| `screen_w` | `1720` | Window width in pixels |
| `screen_h` | `980` | Window height in pixels |
| `target_fps` | `120` | Target frame rate |
| `river_x` | `56` | Left edge of river playfield |
| `river_y` | `56` | Top edge of river playfield |
| `river_w` | `1188` | River playfield width |
| `river_h` | `868` | River playfield height |
| `hud_x` | `river_x + river_w + 24` | Left edge of HUD panel |
| `hud_w` | `screen_w - hud_x - 24` | HUD panel width |
| `boat_y` | `river_y + river_h - 138` | Fixed screen Y of the player boat |
| `lane_span_px` | `430.0` | Pixels per lane unit |
| `distance_to_px` | `0.34` | Scale from distance units to screen pixels |
| `visible_distance` | `2320.0` | Look-ahead distance rendered |
| `finish_distance` | `5200.0` | Total race length |
| `checkpoint_gap` | `1040.0` | Distance between checkpoints |
| `checkpoint_count` | `4` | Number of checkpoints |
| `beat_period` | `0.62` | Rhythm beat period in seconds |
| `beat_perfect_window` | `0.08` | Timing window for a Perfect stroke |
| `beat_good_window` | `0.16` | Timing window for a Good stroke |
| `base_speed` | `132.0` | Baseline forward speed |
| `max_hazards` | `96` | Hazard object-pool capacity |
| `max_rivals` | `4` | Number of rival boats |
| `hazard_debris` | `0` | Hazard kind: floating debris |
| `hazard_wave` | `1` | Hazard kind: destabilising wave ring |

Utility functions (`mini`, `maxi`, `minf`, `maxf`, `clampi`, `clampf`, `absf`, `sinf`, `cosf`, `randf`) provide math helpers used across the game and render packages.

### Package `tonyfettes/raylib-examples/raylib_dragon_boat_sprint_2026/internal/game`

#### Functions

| Function | Description |
|---|---|
| `pub fn update_game(@types.Game, Float) -> Unit` | Samples input, ticks message timer, dispatches per-state logic, and drives the full simulation step |

Internal helpers (not exported): `sample_input`, `clear_input`, `reset_run`, `setup_rivals`, `clear_hazards`, `update_rhythm`, `apply_paddle`, `try_burst`, `update_wave_lane`, `update_speed_distance`, `update_hazard_spawning`, `update_hazards`, `update_rivals`, `update_checkpoints`, `finish_run`, `tick_message`, `add_score`, `set_message`, `current_rank`, `spawn_hazard`.

### Package `tonyfettes/raylib-examples/raylib_dragon_boat_sprint_2026/internal/render`

#### Functions

| Function | Description |
|---|---|
| `pub fn draw_frame(@types.Game) -> Unit` | Renders background, river, checkpoints, hazards, rivals, player boat, HUD panel, message banner, and any state overlay |

Internal helpers (not exported): `draw_background`, `draw_river_surface`, `draw_checkpoint_lines`, `draw_hazards`, `draw_boat`, `draw_rivals`, `draw_player_boat`, `draw_hud_panel`, `draw_message_banner`, `draw_title_overlay`, `draw_pause_overlay`, `draw_result_overlay`, `lane_to_x`, `world_y`, `rival_hull_color`, `current_rank`.

## Architecture

### Package Structure

```
raylib_dragon_boat_sprint_2026/
├── main.mbt                  # Entry point: window init, game loop
└── internal/
    ├── types/
    │   ├── constants.mbt     # Screen, river, timing, race constants
    │   ├── types.mbt         # Structs, enum, constructor functions
    │   └── utils.mbt         # Math helpers: clamp, min, max, trig, rand
    ├── game/
    │   ├── input.mbt         # Keyboard sampling into Input snapshot
    │   └── logic.mbt         # update_game: rhythm, physics, AI, scoring
    └── render/
        └── render.mbt        # draw_frame: river world, boats, HUD, overlays
```

### Data Flow

Each frame the main loop calls `update_game(game, dt)` followed by `draw_frame(game)`. Inside `update_game`, raw keyboard state is sampled into the flat `Input` sub-struct stored inside `Game`. The per-state dispatcher then routes control: the `Play` branch runs rhythm timing, paddle evaluation, burst gating, wave/lane physics, hazard spawning and collision, rival AI, checkpoint detection, and speed integration, all of which write back into `Game` fields. When the race ends, the state transitions to `Result` and a final score is tallied.

`draw_frame` is read-only with respect to game state. It converts distance and lane values into screen coordinates via `lane_to_x` and `world_y`, walks the hazard and rival pools, and draws the right-side HUD panel containing the rhythm meter, beat-lane indicator, and live race stats. Overlay functions for `Title`, `Paused`, and `Result` states are drawn last so they appear above the world.

### Key Design Patterns

- **Object pools with fixed capacity**: `hazards` (96 slots) and `rivals` (4 slots) are allocated once in `Game::new()` and reused by toggling the `active` flag, avoiding allocation during gameplay.
- **Flat mutable state struct**: All game state lives in a single `Game` record passed by reference, making the update/render split straightforward with no ownership friction.
- **Input as a sub-struct snapshot**: Keyboard state is captured once per frame into `game.input`, decoupling hardware polling from all downstream logic.
- **Rhythm gating for paddle actions**: `apply_paddle` evaluates `rhythm_t` against `beat_perfect_window` and `beat_good_window` each time a stroke is pressed, rewarding timing with speed and streak bonuses without any separate event queue.
- **Speed as a smoothed target**: `update_speed_distance` computes a target speed from streak, rhythm, burst, wobble, and stabilise contributions, then lerps `game.speed` toward it each frame, giving organic acceleration rather than instant transitions.
- **Separation of update and render packages**: The `game` package never imports `render`, and the `render` package reads but never writes `Game` fields, enforcing a clear simulation/presentation boundary.

## Improvement & Refinement Plan

1. **Dynamic lane count**: Replace the fixed ±1.08 lane clamp with a configurable `lane_count` constant and compute lane positions procedurally, enabling 3- or 5-lane variants without touching physics code.
2. **Hazard pool exhaustion feedback**: When `spawn_hazard` returns `false` because all 96 slots are occupied, surface a debug metric or automatically deactivate the oldest distant hazard to prevent silent spawn failure at high distances.
3. **Rival finish detection**: Rivals currently run forever past `finish_distance`; tracking each rival's finish time would enable accurate final ranking and podium display on the Result screen.
4. **Rhythm streak persistence across checkpoints**: Reset `rhythm_meter` partially rather than fully on checkpoint passage so skilled players do not lose burst momentum as a punishment for progress.
5. **Wobble visual feedback in the river**: Modulate the player boat's screen-space horizontal offset by `game.wobble` so instability is readable at a glance rather than only through the numeric HUD.
6. **Configurable difficulty preset**: Expose `base_speed`, `beat_period`, and hazard spawn rate as a small difficulty struct selected at the title screen, allowing novice and expert modes without code changes.
7. **Deterministic replay via seed**: Thread a PRNG seed through `Game::new()` and replace `@raylib.get_random_value` calls with a local LCG so any run can be reproduced exactly for testing or leaderboard verification.
