# Shadow Puppet Theater 2026

Shadow Puppet Theater 2026 is a rhythm-action game set on a traditional theater stage where the player controls a shadow puppet. The game presents sequences of target silhouette poses that must be matched before a cue timer expires. With a warm, theatrical aesthetic featuring red curtains, a glowing spotlight, an animated audience, and puppet figures drawn with articulated limbs, the game evokes the atmosphere of a live shadow puppet performance.

The core gameplay loop is pose matching: each "scene" generates a random sequence of 3-8 target poses (increasing with stage number). Each pose is defined by two axis values (ax, ay) ranging from -2 to 2, which control the puppet's arm positions, leg spread, and fan angle. The player adjusts their puppet's pose with directional inputs and presses J to lock it in. Correct matches earn score (48 + stage*10 + combo*5), build combos (up to 99x), and restore the spotlight and excitement meters. Mismatches drain spotlight (18 units) and excitement (15 units), reset combo, and reduce the remaining cue time. A timeout penalty is even harsher (24 spotlight, 20 excitement).

The game features two constantly-draining resources: spotlight (drains at 2.55 + combo*0.22 per second) which ends the game at zero, and excitement (drains at 3.15/s) which drives the audience animation intensity. A "spotlight burst" ability (Space) temporarily slows time by 54% for 1.8 seconds on a 9-second cooldown, helping with difficult sequences.

## Build and Run

```bash
moon build --target native raylib_shadow_puppet_theater_2026/
./_build/native/debug/build/raylib_shadow_puppet_theater_2026/raylib_shadow_puppet_theater_2026.exe
```

## Controls

- **Left Arrow / A**: Decrease horizontal pose axis (ax)
- **Right Arrow / D**: Increase horizontal pose axis (ax)
- **Up Arrow / W**: Decrease vertical pose axis (ay)
- **Down Arrow / S**: Increase vertical pose axis (ay)
- **J**: Lock current pose (confirm match attempt)
- **K**: Undo last locked pose (costs 5.5 spotlight, 3.0 excitement, resets combo)
- **Space**: Activate spotlight burst (46% time slow for 1.8s, 9s cooldown)
- **P**: Pause / resume show
- **R**: Restart the show
- **Enter / J / Space**: Start game from title screen
- **F11**: Toggle borderless windowed mode

## How to Play

From the title screen, press Enter, J, or Space to begin the show. Each scene presents a sequence of target silhouettes displayed as cards at the top of the screen. The currently active target is highlighted in gold.

Use arrow keys/WASD to adjust your puppet's pose axes. Each axis ranges from -2 to 2, controlling arm height, spread, twist, and leg stance. A faded "ghost" silhouette shows the target pose behind your puppet on the main stage. When your pose matches the target, press J to lock it in.

Key mechanics:
- **Cue timer**: Each target must be matched before time runs out. Starts at 3.25 seconds and decreases by 0.11 per stage (minimum 1.05s). Timeout regenerates the entire sequence.
- **Combo**: Consecutive correct matches build combo (max 99x). Combo decays over time (2.4s hold timer). Higher combos increase score per match but also increase spotlight drain rate.
- **Spotlight**: Your primary health resource (starts at 78/100). Drains at 2.55 + combo*0.22 per second. Correct matches restore 3.6 + combo*0.2. When spotlight reaches 0, the show ends.
- **Excitement**: Audience engagement meter (max 100). Drains at 3.15/s. Correct matches restore 8.0 + combo*0.7. Drives audience bounce animation.
- **Burst**: Press Space to slow time to 46% for 1.8 seconds (9s cooldown). Also adds 8 excitement.
- **Undo**: Press K to undo the last locked pose (costs 5.5 spotlight, 3 excitement, resets combo).
- **Scene completion**: Matching all poses in a sequence awards a bonus (160 + stage*30 + combo*8), advances the stage, and generates a new longer sequence.

## Public API Reference

### Package `raylib_shadow_puppet_theater_2026`

> Main entry point. Initializes window, creates game state, and runs the main loop.

No public types or functions beyond the `main` entry point.

### Package `raylib_shadow_puppet_theater_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `Paused`, `Result` | Game state machine states |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Pose` | `ax`, `ay` | A puppet pose defined by two integer axes (-2 to 2) |
| `Input` | `axis_dx`, `axis_dy`, `lock_pressed`, `undo_pressed`, `burst_pressed`, `pause_pressed`, `restart_pressed`, `start_pressed` | Frame input state with directional deltas and action booleans |
| `Game` | `input`, `sequence`, `history`, `state`, `stage`, `score`, `best_score`, `combo`, `best_combo`, `excitement`, `spotlight`, `cue_time_left`, `cue_time_limit`, `target_idx`, `current_pose`, `burst_t`, `burst_cd`, `combo_t`, `beat_t`, `scene_t`, `result_t`, `hit_count`, `miss_count`, `message`, `message_t` | Main game state container with all gameplay and UI state |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1600` | Screen width |
| `screen_h` | `Int` | `960` | Screen height |
| `target_fps` | `Int` | `120` | Target frame rate |
| `pose_axis_min` | `Int` | `-2` | Minimum pose axis value |
| `pose_axis_max` | `Int` | `2` | Maximum pose axis value |
| `max_sequence_len` | `Int` | `8` | Maximum poses in a sequence |
| `spotlight_max` | `Float` | `100.0` | Maximum spotlight value |
| `spotlight_start` | `Float` | `78.0` | Starting spotlight value |
| `excitement_max` | `Float` | `100.0` | Maximum excitement value |
| `cue_base_time` | `Float` | `3.25` | Base cue timer duration |
| `cue_drop_per_stage` | `Float` | `0.11` | Cue time reduction per stage |
| `cue_min_time` | `Float` | `1.05` | Minimum cue timer duration |
| `combo_hold_time` | `Float` | `2.4` | Time before combo decays |
| `burst_duration` | `Float` | `1.8` | Burst slow-motion duration |
| `burst_cooldown` | `Float` | `9.0` | Burst ability cooldown |
| `burst_slow_factor` | `Float` | `0.46` | Time multiplier during burst |
| `spotlight_drain` | `Float` | `2.55` | Base spotlight drain per second |
| `excitement_drain` | `Float` | `3.15` | Excitement drain per second |
| `mistake_spotlight_loss` | `Float` | `18.0` | Spotlight lost per incorrect match |
| `timeout_spotlight_loss` | `Float` | `24.0` | Spotlight lost per timeout |
| `mistake_excitement_loss` | `Float` | `15.0` | Excitement lost per mistake |
| `correct_spotlight_gain` | `Float` | `3.6` | Spotlight gained per correct match |
| `correct_excitement_gain` | `Float` | `8.0` | Excitement gained per correct match |
| `stage_screen_x` | `Int` | `248` | Stage screen x-offset |
| `stage_screen_y` | `Int` | `126` | Stage screen y-offset |
| `stage_screen_w` | `Int` | `980` | Stage screen width |
| `stage_screen_h` | `Int` | `682` | Stage screen height |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Pose::new` | `(Int, Int) -> Pose` | Creates a new pose with given ax, ay values |
| `Input::new` | `() -> Input` | Creates a new input state with all values zeroed |
| `Game::new` | `() -> Game` | Creates a new game instance with default state |
| `cue_time_for_stage` | `(Int) -> Float` | Calculates cue timer duration for a given stage |
| `sequence_len_for_stage` | `(Int) -> Int` | Calculates sequence length for a given stage (3 + (stage-1)/2, max 8) |
| `maxi` | `(Int, Int) -> Int` | Returns the maximum of two integers |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between bounds |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between bounds |
| `minf` | `(Float, Float) -> Float` | Returns the minimum of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns the maximum of two floats |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `sinf` | `(Float) -> Float` | Returns the sine of a radian angle as Float |
| `same_pose` | `(Pose, Pose) -> Bool` | Returns true if two poses have identical ax and ay values |
| `set_message` | `(Game, String, Float) -> Unit` | Sets the message banner text and display duration |
| `add_score` | `(Game, Int) -> Unit` | Adds delta to score (minimum 0) and updates best score |
| `reset_current_pose` | `(Game) -> Unit` | Resets the current pose to (0, 0) |
| `target_pose` | `(Game) -> Pose` | Returns the current target pose from the sequence |
| `active_slow_factor` | `(Game) -> Float` | Returns the time multiplier (0.46 during burst, 1.0 otherwise) |

### Package `raylib_shadow_puppet_theater_2026/internal/game`

> Game logic, input sampling, and state update systems.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `init_game` | `(Game) -> Unit` | Initializes the game to the title scene state |
| `update_game` | `(Game, Float) -> Unit` | Main update function: samples input, updates timers, and dispatches to state-specific update functions |

### Package `raylib_shadow_puppet_theater_2026/internal/render`

> Rendering and drawing routines.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main rendering entry point: draws backdrop, spotlight, stage, poses, audience, sequence strip, HUD panel, controls, messages, and state-specific overlays |

## Architecture

### Package Structure

```
raylib_shadow_puppet_theater_2026/
├── main.mbt                          -- Entry point: window init, game loop
├── moon.pkg                          -- Root package config
└── internal/
    ├── types/
    │   ├── types.mbt                 -- GameState enum, Pose/Input/Game structs, constructors
    │   ├── constants.mbt             -- All tuning constants and stage-scaling functions
    │   └── utils.mbt                 -- Math utilities, pose comparison, message/score helpers
    ├── game/
    │   ├── input.mbt                 -- Input sampling from keyboard
    │   └── logic.mbt                 -- Sequence generation, state updates, pose locking, burst, undo
    └── render/
        └── render.mbt               -- All drawing: backdrop, spotlight, puppet shadows, HUD, overlays
```

The game follows a clean types/game/render separation. The `types` package defines all data structures and constants with no dependencies on raylib (except for `sinf` via `@math`). The `game` package handles input and logic, and the `render` package handles all drawing.

### Data Flow

1. **Input**: `sample_input` reads keyboard state into the `Input` struct each frame, then `clear_input` resets it.
2. **State dispatch**: `update_game` dispatches to `update_title_state`, `update_play_state`, `update_paused_state`, or `update_result_state` based on `GameState`.
3. **Play update**: `apply_pose_axis_input` adjusts current pose, `lock_current_pose` compares against `target_pose`, advancing `target_idx` on match or calling `apply_mistake` on mismatch. `complete_sequence` triggers on full sequence match, advancing the stage and generating a new sequence.
4. **Resource drains**: Each frame during Play, spotlight and excitement drain by their respective rates multiplied by `active_slow_factor` (reduced during burst). Combo decays via `combo_hold_time`.
5. **Rendering**: `draw_frame` layers backdrop, spotlight glow, stage screen, puppet shadows (target ghost + player puppet via `draw_pose_shadow`), audience row, sequence card strip, HUD panel with meters, control strip, message banner, and state overlays.

### Key Design Patterns

- **ECS-like separation**: Types, game logic, and rendering are cleanly separated into three packages with one-way dependencies (game -> types, render -> types).
- **State machine**: `GameState` enum with `match` dispatch drives all behavior branching.
- **Pose as 2D discrete grid**: Poses use integer axes (-2 to 2), creating 25 distinct poses that are easy to compare (`same_pose`) and display.
- **Dual resource pressure**: Spotlight (health) and excitement (performance quality) create tension between survival and showmanship.
- **Burst ability as time manipulation**: `active_slow_factor` multiplies into `sim_dt`, elegantly slowing all gameplay timers during burst without changing individual timer logic.
- **Sequence card strip**: Visual sequence display at top shows progress through the current act, with color-coded cards (green=completed, gold=active, gray=pending).

## Improvement & Refinement Plan

1. **Add touch controls**: Unlike other games in this collection, Shadow Puppet Theater has no on-screen touch buttons. Adding a 5x5 pose grid that can be tapped directly, plus lock/undo/burst buttons, would enable mobile play.

2. **Implement pose preview matching**: Currently the player must compare their puppet pose visually against the ghost silhouette. Adding a numeric match indicator (e.g., "1/2 axes matched") or color-coding correct axes would reduce frustration.

3. **Add audience reaction variety**: The `draw_audience` function shows 22 identical bouncing circles. Varying sizes, adding arm-raising on high excitement, or showing standing ovations on sequence completion would enhance theatrical atmosphere.

4. **Implement difficulty modes**: All tuning is in named constants (`spotlight_drain`, `cue_base_time`, etc.). Exposing easy/normal/hard presets that adjust these values would broaden accessibility.

5. **Add combo decay visualization**: Combo decays after `combo_hold_time` (2.4s) but there is no visual indication of remaining hold time. Adding a shrinking indicator next to the combo counter would help players maintain combos.

6. **Persist best scores**: `best_score` and `best_combo` reset when the game restarts. Saving these to a file would provide persistent high scores across sessions.

7. **Add sequence preview phase**: New sequences appear immediately with the cue timer running. A brief "preview" phase showing all target poses before the timer starts would reduce the trial-and-error feel of new sequences.
