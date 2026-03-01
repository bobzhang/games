# Peking Opera Duel 2026

Peking Opera Duel 2026 is a rhythm-action duel game set on a traditional Chinese opera stage. Two troupes face off in a 90-second performance where the player must match incoming rhythm prompts by moving to the correct lane position on a 3x3 grid and adopting the correct martial stance -- Spear Lift, Fan Sweep, Guard Frame, or Sleeve Arc -- all in time with an accelerating drum beat.

The core gameplay loop revolves around reading incoming prompts that shrink toward a target lane, moving the player's focus cursor to the matching grid cell, selecting the correct stance through directional input, and pressing the hit key within a tight timing window for Perfect or Good ratings. Successful hits build a combo multiplier that amplifies acclaim gains and recovers health and harmony, while misses and mistimed strikes drain both meters. A defensive deflect mechanic allows the player to cancel dangerous prompts at a small harmony cost, and a cooldown-gated Focus Burst ability temporarily slows the tempo for breathing room.

The game features a dual-resource system (health and harmony) that constantly drains over time and accelerates with misses, creating escalating pressure. The beat interval shrinks from 1.02 seconds down to a minimum of 0.54 seconds as the duel progresses, and final performance is graded from "Crowd Unconvinced" to "Legendary Curtain Call" based on accumulated acclaim.

## Build and Run

```bash
moon build --target native raylib_peking_opera_duel_2026/
./_build/native/debug/build/raylib_peking_opera_duel_2026/raylib_peking_opera_duel_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move lane focus on the 3x3 grid and select stance (Up = Spear Lift, Right = Fan Sweep, Down = Guard Frame, Left = Sleeve Arc)
- **J**: Beat hit / confirm selection on title and game over screens
- **K**: Defensive transition (deflect active prompt near impact, or switch to Guard Frame stance)
- **Space**: Activate Focus Burst (slows tempo by 46% for 1.7 seconds; 8-second cooldown)
- **P**: Pause / unpause the duel
- **R**: Restart the duel immediately
- **Enter**: Confirm on title screen (alternative to J)
- **F11**: Toggle borderless windowed mode

## How to Play

On the title screen, press J or Enter to begin the 90-second duel. Rhythm prompts appear as shrinking circles on the 3x3 lane grid. Each prompt specifies a target lane position and a stance (shown by name and color). Move your focus cursor to the correct lane using WASD or arrow keys, which also sets your stance based on the last directional input.

Press J when the prompt circle converges on its target to score a hit. Timing within 0.07 seconds of the beat center earns a Perfect rating (32 base acclaim plus combo bonus), while timing within 0.15 seconds earns Good (22 base acclaim plus combo bonus). Timing beyond 0.15 seconds but within 0.28 seconds results in a miss. Hitting J when no prompt is active or when timing is too far off triggers an off-beat penalty that costs harmony and resets your combo.

If you cannot reach the correct lane or stance in time, press K to deflect. A deflect within 0.20 seconds of the beat cancels the prompt safely with a small harmony cost and earns 8 acclaim, but reduces your combo by one. Pressing K outside deflect range switches your stance to Guard Frame.

Activate Focus Burst with Space to slow the game tempo to 46% for 1.7 seconds, giving more time to react. This has an 8-second cooldown and also restores 8 harmony on activation.

Health drains at 0.34 per second and harmony drains at 0.48 per second (plus 0.02 per accumulated miss), creating constant pressure. Successful hits recover both meters. If either health or harmony reaches zero, the duel ends immediately. If the 90-second timer expires, the outcome depends on your acclaim score: 1200+ is a victory, 800-1199 is a draw, and below 800 is a defeat. Final grades range from "Crowd Unconvinced" (below 800) to "Legendary Curtain Call" (1700+).

## Public API Reference

### Package `raylib_peking_opera_duel_2026`

> Main entry point. Initializes the window, creates the game state, and runs the main loop.

No additional public types or functions beyond the `main` entry point.

### Package `raylib_peking_opera_duel_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Playing`, `Paused`, `GameOver` | Game state machine states controlling which update and render path is active |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `InputState` | `axis_x`, `axis_y`, `hit_pressed`, `defend_pressed`, `burst_pressed`, `pause_pressed`, `restart_pressed`, `confirm_pressed` | Aggregated per-frame input snapshot |
| `Prompt` | `lane_x`, `lane_y`, `stance`, `time_left` | A rhythm prompt with target position, required stance, and countdown timer |
| `Game` | `state`, `lane_x`, `lane_y`, `stance`, `health`, `harmony`, `acclaim`, `combo`, `duel_time_left`, `prompt`, `burst_t`, `burst_cd` | Main game state container holding all player, prompt, and timing data |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `InputState::new` | `() -> InputState` | Creates a default input state with all fields zeroed |
| `Prompt::new` | `(Int, Int, Int, Float) -> Prompt` | Creates a new prompt with the given lane_x, lane_y, stance, and time_left |
| `Game::new` | `() -> Game` | Creates a new game instance with default values (title state, full health/harmony) |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | 1600 | Window width in pixels |
| `screen_h` | `Int` | 960 | Window height in pixels |
| `target_fps` | `Int` | 120 | Target frame rate |
| `stance_spear` | `Int` | 0 | Spear Lift stance identifier |
| `stance_fan` | `Int` | 1 | Fan Sweep stance identifier |
| `stance_guard` | `Int` | 2 | Guard Frame stance identifier |
| `stance_sleeve` | `Int` | 3 | Sleeve Arc stance identifier |
| `stance_count` | `Int` | 4 | Total number of stances |
| `lane_axis_min` | `Int` | -1 | Minimum lane axis value |
| `lane_axis_max` | `Int` | 1 | Maximum lane axis value |
| `duel_duration` | `Float` | 90.0 | Duration of one duel in seconds |
| `prompt_lead_time` | `Float` | 1.18 | Seconds of warning before a prompt hits |
| `beat_start_interval` | `Float` | 1.02 | Initial beat interval at duel start |
| `beat_min_interval` | `Float` | 0.54 | Fastest possible beat interval |
| `beat_accel_per_sec` | `Float` | 0.0042 | Rate at which beat interval decreases per second |
| `timing_perfect` | `Float` | 0.07 | Timing window for perfect rating |
| `timing_good` | `Float` | 0.15 | Timing window for good rating |
| `timing_deflect` | `Float` | 0.20 | Timing window for successful deflect |
| `timing_miss` | `Float` | 0.28 | Maximum timing window before auto-miss |
| `health_max` | `Float` | 100.0 | Maximum health value |
| `harmony_max` | `Float` | 100.0 | Maximum harmony value |
| `health_drain_per_sec` | `Float` | 0.34 | Passive health drain per second |
| `harmony_drain_per_sec` | `Float` | 0.48 | Passive harmony drain per second |
| `offbeat_harmony_penalty` | `Float` | 4.5 | Harmony lost on off-beat strike |
| `miss_health_penalty` | `Float` | 8.5 | Health lost on missed prompt |
| `miss_harmony_penalty` | `Float` | 12.0 | Harmony lost on missed prompt |
| `mismatch_harmony_extra` | `Float` | 3.0 | Extra harmony penalty for wrong lane/stance |
| `deflect_harmony_penalty` | `Float` | 4.2 | Harmony cost of a deflect |
| `deflect_acclaim_gain` | `Int` | 8 | Acclaim earned from a deflect |
| `good_acclaim_gain` | `Int` | 22 | Base acclaim for a Good hit |
| `perfect_acclaim_gain` | `Int` | 32 | Base acclaim for a Perfect hit |
| `combo_acclaim_step` | `Int` | 3 | Extra acclaim per combo level |
| `hit_health_recover` | `Float` | 1.6 | Health recovered on successful hit |
| `hit_harmony_recover` | `Float` | 2.2 | Harmony recovered on successful hit |
| `burst_duration` | `Float` | 1.7 | Duration of Focus Burst slow effect |
| `burst_cooldown` | `Float` | 8.0 | Cooldown period for Focus Burst |
| `burst_slow_factor` | `Float` | 0.46 | Time scale during Focus Burst |
| `stage_left` | `Int` | 140 | Stage area left edge in pixels |
| `stage_top` | `Int` | 110 | Stage area top edge in pixels |
| `stage_w` | `Int` | 1320 | Stage area width in pixels |
| `stage_h` | `Int` | 740 | Stage area height in pixels |
| `lane_step_x` | `Int` | 220 | Horizontal distance between lane cells |
| `lane_step_y` | `Int` | 120 | Vertical distance between lane cells |

#### Utility Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `maxi` | `(Int, Int) -> Int` | Returns the maximum of two integers |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer to a [lo, hi] range |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to a [lo, hi] range |
| `minf` | `(Float, Float) -> Float` | Returns the minimum of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns the maximum of two floats |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `sinf` | `(Float) -> Float` | Computes the sine of a float via `@math.sin` |
| `stance_name` | `(Int) -> String` | Returns a human-readable name for a stance ID |
| `grade_for_acclaim` | `(Int) -> String` | Returns the grade string for a given acclaim score |
| `set_message` | `(Game, String, Float) -> Unit` | Sets the on-screen message with a time-to-live |
| `col` | `(Int, Int, Int, Int) -> @raylib.Color` | Shorthand to create an RGBA Color |
| `stance_color` | `(Int, Int) -> @raylib.Color` | Returns the signature color for a stance at the given alpha |
| `lane_to_x` | `(Int) -> Int` | Converts a lane X index (-1..1) to pixel X coordinate |
| `lane_to_y` | `(Int) -> Int` | Converts a lane Y index (-1..1) to pixel Y coordinate |
| `draw_center_text` | `(String, Int, Int, @raylib.Color) -> Unit` | Draws text horizontally centered at the given Y position |

### Package `raylib_peking_opera_duel_2026/internal/game`

> Game logic, input handling, and state transitions.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `init_game` | `(@types.Game) -> Unit` | Initializes the game to the title state with default values |
| `update_game` | `(@types.Game, Float) -> Unit` | Main per-frame update: samples input, updates timers, and dispatches to the active state handler |

### Package `raylib_peking_opera_duel_2026/internal/render`

> Rendering and visual effects for all game states.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(@types.Game) -> Unit` | Main rendering entry point: draws backdrop, actors, grid, prompts, HUD, overlays, and message banner |

## Architecture

### Package Structure

```
raylib_peking_opera_duel_2026/
├── main.mbt              — Entry point: window init, game loop, frame clamping
├── moon.pkg              — Package config with imports
└── internal/
    ├── types/
    │   ├── types.mbt     — GameState enum, InputState/Prompt/Game structs, constructors
    │   ├── constants.mbt — Tuning values (timing windows, drain rates, dimensions)
    │   └── utils.mbt     — Math helpers, stance names, color utilities, text drawing
    ├── game/
    │   ├── logic.mbt     — State machine update, prompt spawning, hit/miss/deflect logic
    │   └── input.mbt     — Per-frame keyboard sampling into InputState
    └── render/
        └── render.mbt    — All drawing: backdrop, duelists, lane grid, prompts, HUD, overlays
```

The `types` package provides all shared data structures and constants, forming the foundation that both `game` and `render` depend on. The `game` package owns all state mutation, while `render` is a pure read-only consumer of game state. The main entry point ties them together with a simple init-update-draw loop.

### Data Flow

1. **Input**: `sample_input` in `input.mbt` reads keyboard state via raylib and writes to `game.input` (an `InputState` struct), providing a clean per-frame snapshot.
2. **Update**: `update_game` in `logic.mbt` dispatches to the current state handler (`update_title_state`, `update_playing_state`, `update_paused_state`, `update_game_over_state`). The playing state processes movement via `apply_axis_focus_and_stance`, handles hits via `try_hit_prompt`, deflects via `try_deflect`, and burst via `try_activate_burst`, then advances timers, drains resources, and spawns new prompts.
3. **Render**: `draw_frame` in `render.mbt` reads the `Game` struct and draws the backdrop, stage actors (both duelists), lane grid, active prompt with shrinking circle, HUD meters, and state-specific overlays (title, pause, game over).

### Key Design Patterns

- **State machine**: The `GameState` enum (Title, Playing, Paused, GameOver) drives both update logic dispatch and render overlay selection.
- **Input buffering**: A dedicated `InputState` struct is sampled once per frame and cleared before sampling, preventing double-reads and decoupling input from logic.
- **Dual-resource pressure**: Health and harmony drain passively and are penalized on mistakes, creating escalating difficulty without spawning more enemies.
- **Accelerating cadence**: `cadence_for_elapsed` linearly decreases the beat interval from 1.02s toward 0.54s, making prompts arrive faster as the duel progresses.
- **Prompt uniqueness**: `spawn_prompt` ensures consecutive prompts differ by adjusting stance and lane if a duplicate is generated.
- **Delta-time with clamping**: Frame time is clamped to a 0.05s maximum in `main.mbt` to prevent large jumps, and Focus Burst applies a slow factor to the simulation timestep.
- **ECS-like separation**: Types, game logic, and rendering are cleanly separated into their own packages with one-directional dependencies.

## Improvement & Refinement Plan

1. **Use an enum for stances instead of integer constants**: The four stances (Spear Lift, Fan Sweep, Guard Frame, Sleeve Arc) are represented as `Int` constants (`stance_spear` through `stance_sleeve`). Converting these to a proper `Stance` enum would provide type safety and eliminate magic-number comparisons throughout `utils.mbt`, `logic.mbt`, and `render.mbt`.

2. **Extract timing evaluation into a dedicated function**: The hit timing logic in `try_hit_prompt` uses nested if-else branches comparing `absf(game.prompt.time_left)` against multiple thresholds. A `evaluate_timing(Float) -> TimingGrade` function returning an enum (Perfect, Good, Miss, TooEarly) would reduce duplication and make the grading system easier to tune.

3. **Add visual feedback for combo milestones**: The combo system in `apply_hit_success` drives significant acclaim gains through `combo_acclaim_step` but has no visual representation beyond the HUD counter. Adding particle effects or screen flash at combo thresholds (e.g., 5x, 10x) would improve player feedback.

4. **Separate HUD drawing into its own module**: `render.mbt` contains all rendering code including `draw_hud`, `draw_meter`, overlay functions, and actor drawing. Splitting HUD elements into a dedicated `internal/hud/` package would improve maintainability as the UI grows.

5. **Implement difficulty scaling options**: The cadence acceleration is controlled by `beat_accel_per_sec` (0.0042) with fixed start/end intervals. Adding difficulty presets that adjust these constants along with `health_drain_per_sec` and `harmony_drain_per_sec` would broaden accessibility.

6. **Add a prompt queue for look-ahead**: Currently only one prompt can be active at a time (`prompt_active` is a single boolean). Implementing a queue of 2-3 upcoming prompts would let players plan ahead and enable more complex choreography patterns.

7. **Reduce duplication between `init_title_state` and `start_duel`**: Both functions in `logic.mbt` reset nearly identical fields on the `Game` struct. Extracting a shared `reset_game_fields` helper would eliminate the duplicated initialization code.
