# Ink Scroll Detective 2026

A deduction and investigation game set in an ink-wash city. Navigate a 10x6 grid of districts, discover clues linked to four suspects, resolve timed incidents, and build evidence chains to unmask the culprit.

## Build and Run

```bash
cd examples && moon build --target native raylib_ink_scroll_detective_2026/
cd examples && ./_build/native/debug/build/raylib_ink_scroll_detective_2026/raylib_ink_scroll_detective_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Move cursor between city districts
- **J or Space**: Inspect current district (discover clues / resolve incidents)
- **K**: Cancel / mark suspect
- **L**: Focus mode (reveals hidden clues nearby, cooldown)
- **P**: Pause
- **R**: Restart case
- **F11**: Toggle borderless windowed

## How to Play

Explore city districts to find clues scattered across the map. Each clue belongs to one of four suspects and forms part of an evidence chain. Complete chains to unlock deduction milestones that raise suspicion levels. Timed incidents spawn across the city -- reach and resolve them before they expire to maintain public trust. Wrong accusations cost trust heavily. Manage the 210-second case timer and keep trust above zero to solve the case.

## Public API Reference

### Package `raylib_ink_scroll_detective_2026` (main)

Entry point only; no exported symbols.

| Symbol | Kind | Description |
|--------|------|-------------|
| `main` | fn | Initializes the window (1440x900, 120 fps), creates the game, and runs the draw/update loop. |

---

### Package `raylib_ink_scroll_detective_2026/internal/types`

Owns all constants, data types, constructors, and utility helpers. Everything other packages import.

#### Structs

| Struct | Visibility | Fields (mutable marked `mut`) | Description |
|--------|------------|-------------------------------|-------------|
| `Clue` | `pub(all)` | `x`, `y`, `suspect`, `chain`: Int; `mut discovered`: Bool; `mut glow_t`: Float | One clue marker placed in the city grid. |
| `Suspect` | `pub(all)` | `name`: String; `home_x`, `home_y`: Int; `mut deduction_unlocked`: Bool; `mut suspicion`: Float | Suspect profile and deduction progress state. |
| `Incident` | `pub(all)` | `mut active`: Bool; `mut x`, `mut y`, `mut culprit`, `mut severity`: Int; `mut timer`, `mut pulse_t`: Float | Active incident state that can be resolved by the player. |
| `DistrictPulse` | `pub(all)` | `mut heat`: Float; `drift`: Float | Ambient district heat value used for visual pulse effects. |
| `Game` | `pub(all)` | See `types.mbt` for full field list | Complete runtime state for one detective case session. |

#### Enum

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Playing`, `Paused`, `GameOver` | High-level flow state for the detective game. Derives `Eq`. |

#### Constructors

| Function | Signature | Description |
|----------|-----------|-------------|
| `Clue::new` | `(index: Int) -> Clue` | Creates a clue at a deterministic grid position for `index`. |
| `Suspect::new` | `(index: Int) -> Suspect` | Creates a suspect profile from a suspect index. |
| `Incident::new` | `() -> Incident` | Creates an inactive incident with default values. |
| `DistrictPulse::new` | `(index: Int) -> DistrictPulse` | Creates a district pulse state seeded by district index. |
| `Game::new` | `() -> Game` | Creates a new case state with clues, suspects, and timers initialized. |

#### Utility Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `city_w_i` | `() -> Int` | Returns total city grid width in pixels. |
| `city_h_i` | `() -> Int` | Returns total city grid height in pixels. |
| `clampi` | `(v, lo, hi: Int) -> Int` | Clamps an integer to the inclusive `[lo, hi]` range. |
| `clampf` | `(v, lo, hi: Float) -> Float` | Clamps a float to the inclusive `[lo, hi]` range. |
| `clamp01` | `(v: Float) -> Float` | Clamps a float into the `[0.0, 1.0]` range. |
| `maxf` | `(a, b: Float) -> Float` | Returns the larger of two floating-point values. |
| `minf` | `(a, b: Float) -> Float` | Returns the smaller of two floating-point values. |
| `maxi` | `(a, b: Int) -> Int` | Returns the larger of two integers. |
| `sinf` | `(v: Float) -> Float` | Computes sine via the core math backend. |
| `randf` | `(lo, hi: Float) -> Float` | Returns a random float sampled uniformly from `[lo, hi]`. |
| `randi` | `(lo, hi: Int) -> Int` | Returns a random integer sampled uniformly from `[lo, hi]`. |
| `cell_index` | `(cell_x, cell_y: Int) -> Int` | Converts a cell coordinate to a linear district index. |
| `cell_left_i` | `(cell_x: Int) -> Int` | Returns left pixel position of a district cell. |
| `cell_top_i` | `(cell_y: Int) -> Int` | Returns top pixel position of a district cell. |
| `cell_center_x` | `(cell_x: Int) -> Float` | Returns center x-position of a district cell. |
| `cell_center_y` | `(cell_y: Int) -> Float` | Returns center y-position of a district cell. |
| `chain_slot` | `(suspect, chain: Int) -> Int` | Converts `(suspect, chain)` to a flattened chain-progress index. |
| `incident_need_score` | `(severity: Int) -> Int` | Returns required evidence score for an incident severity. |
| `incident_timer_for_severity` | `(severity: Int) -> Float` | Returns countdown duration for an incident severity. |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | Int | 1440 | Game window width in pixels. |
| `screen_h` | Int | 900 | Game window height in pixels. |
| `target_fps` | Int | 120 | Target frame rate. |
| `city_cols` | Int | 10 | Number of district columns in the city grid. |
| `city_rows` | Int | 6 | Number of district rows in the city grid. |
| `district_count` | Int | 60 | Total districts (`city_cols * city_rows`). |
| `city_origin_x_i` | Int | 120 | X-origin of the city grid in screen pixels. |
| `city_origin_y_i` | Int | 148 | Y-origin of the city grid in screen pixels. |
| `cell_w_i` | Int | 116 | Width of one district cell in pixels. |
| `cell_h_i` | Int | 102 | Height of one district cell in pixels. |
| `suspect_count` | Int | 4 | Number of suspects in the case. |
| `chains_per_suspect` | Int | 3 | Number of evidence chains per suspect. |
| `clue_steps_per_chain` | Int | 2 | Clues required to complete one chain. |
| `clue_count` | Int | 24 | Total clues generated per case (`4 * 3 * 2`). |
| `max_incidents` | Int | 8 | Maximum simultaneous active incidents. |
| `trust_max` | Float | 100.0 | Maximum trust value. |
| `trust_decay_base` | Float | 0.95 | Base per-second trust decay during play. |
| `time_limit_s` | Float | 210.0 | Case time limit in seconds. |
| `incident_spawn_base` | Float | 4.9 | Base incident spawn interval in seconds. |
| `incident_spawn_floor` | Float | 2.2 | Minimum incident spawn interval in seconds. |
| `incident_timer_base` | Float | 19.0 | Base countdown timer for new incidents. |
| `incident_timer_drop` | Float | 2.9 | Timer reduction per severity step above 1. |
| `focus_duration` | Float | 1.7 | Focus ability active duration in seconds. |
| `focus_cooldown` | Float | 7.0 | Focus ability cooldown in seconds. |
| `score_clue` | Int | 45 | Score awarded for discovering a clue. |
| `score_chain_complete` | Int | 80 | Score awarded for completing a chain. |
| `score_deduction_unlock` | Int | 130 | Score awarded for unlocking a deduction. |
| `score_incident_resolve` | Int | 180 | Score awarded for resolving an incident. |
| `score_wrong_accuse_penalty` | Int | 95 | Score penalty for a wrong accusation. |
| `evidence_per_clue` | Int | 5 | Evidence points granted per discovered clue. |
| `evidence_focus_bonus` | Int | 3 | Bonus evidence points while focus is active. |
| `deduction_chains_to_unlock` | Int | 2 | Chains needed to unlock a suspect's deduction. |
| `trust_gain_clue` | Float | 0.9 | Trust gained from discovering a clue. |
| `trust_gain_chain` | Float | 1.8 | Trust gained from completing a chain. |
| `trust_gain_deduction` | Float | 4.2 | Trust gained from unlocking a deduction. |
| `trust_gain_resolve` | Float | 5.4 | Trust gained from resolving an incident. |
| `trust_penalty_missed_incident` | Float | 7.8 | Trust lost when an incident times out. |
| `trust_penalty_wrong_accuse` | Float | 12.0 | Trust lost for accusing the wrong suspect. |
| `tau` | Float | 6.283... | Circle constant `2*pi` used by animation math. |

---

### Package `raylib_ink_scroll_detective_2026/internal/game`

Owns the keyboard input reader and all gameplay simulation logic.

| Function | Signature | Visibility | Description |
|----------|-----------|------------|-------------|
| `update_game` | `(game: Game, dt: Float) -> Unit` | `pub` | Advances one frame of detective gameplay: reads input, ticks all subsystems, and drives state transitions. |

All other functions in this package (`clear_input`, `update_input`, `set_message`, `reset_case`, `move_cursor`, `handle_inspect`, `discover_clue`, `spawn_incident`, `update_incidents`, `update_district_pulses`, `update_runtime_meters`, etc.) are package-private.

---

### Package `raylib_ink_scroll_detective_2026/internal/render`

Owns the entire rendering pipeline; reads `Game` state but never mutates it.

| Function | Signature | Visibility | Description |
|----------|-----------|------------|-------------|
| `draw_frame` | `(game: Game) -> Unit` | `pub` | Draws the full frame for the current detective case state: background, districts, clues, suspects, incidents, cursor, HUD, evidence board, and any active overlay. |

All helper functions (`draw_background`, `draw_districts`, `draw_clues`, `draw_suspects`, `draw_incidents`, `draw_cursor`, `draw_hud`, `draw_suspect_board`, `draw_meter`, `draw_center_text`, `draw_right_text`, overlay functions, etc.) are package-private.

---

## Architecture

```
raylib_ink_scroll_detective_2026/
├── main.mbt                          # Entry point: window + game loop
└── internal/
    ├── types/                        # Shared data model (no game logic)
    │   ├── constants.mbt             # All pub let constants
    │   ├── types.mbt                 # Structs, enum, constructors, private layout helpers
    │   └── utils.mbt                 # Pure math / grid / randomness helpers
    ├── game/                         # Simulation
    │   ├── input.mbt                 # Keyboard polling -> Game input fields
    │   └── logic.mbt                 # All state mutation; exposes update_game
    └── render/                       # Presentation
        └── render.mbt                # Read-only draw calls; exposes draw_frame
```

### Dependency graph

```
main  -->  game (update_game)
      -->  render (draw_frame)
      -->  types (Game::new, constants)

game  -->  types (all constants, structs, utils)

render  -->  types (all constants, structs, utils)
        -->  raylib (drawing primitives)

types  -->  math (sin)
       -->  raylib (get_random_value)
```

### Frame loop

Each frame produced by the Raylib loop in `main.mbt` executes in this order:

1. `get_frame_time()` -- raw delta, clamped to `[0, 0.05]` seconds.
2. `update_game(game, dt)` -- mutates the shared `Game` record:
   a. `update_input` -- polls keyboard and writes input fields.
   b. Global restart check (`input_restart_press`).
   c. Message timer tick.
   d. State dispatch (`match game.state`) to one of `update_title_state`, `update_playing_state`, `update_paused_state`, `update_game_over_state`.
3. `begin_drawing()` / `draw_frame(game)` / `end_drawing()` -- renders the current state with no further mutation.

### Data model

`Game` is the single mutable record shared by all subsystems. It holds:

- **Spatial collections** -- `clues: Array[Clue]` (24), `suspects: Array[Suspect]` (4), `incidents: Array[Incident]` (up to 8), `pulses: Array[DistrictPulse]` (60).
- **Progress tables** -- `chain_progress: Array[Int]` (12 slots, one per `suspect x chain`), `evidence_score: Array[Int]` (4, one per suspect).
- **Session meters** -- `trust: Float`, `case_time: Float`, `score: Int`, `best_score: Int`, `focus_t: Float`, `focus_cd: Float`.
- **Per-frame input snapshot** -- `input_dx`, `input_dy`, `input_inspect_press`, `input_cancel_press`, `input_focus_press`, `input_pause_press`, `input_restart_press`.
- **UI state** -- `message: String`, `message_t: Float`, `marked_suspect: Int`, `state: GameState`.

`types` provides all pure helpers that `game` and `render` call without reaching back upward, keeping the dependency graph acyclic.

### Playing-state simulation order (per frame)

```
move_cursor
handle_cancel_or_mark
handle_focus_input
handle_inspect  -->  attempt_incident_resolution | discover_clue | inspect_suspect
update_runtime_meters  (focus timer, focus cooldown, case timer, trust decay)
update_spawn_timer     (incident spawning interval)
update_incidents       (countdown timers, timeout penalties)
update_clue_glow       (post-discover glow fade)
update_district_pulses (heat values for rendering)
update_suspect_suspicion
win/loss checks        (trust <= 0 or case_time <= 0)
```

---

## Improvement & Refinement Plan

1. **Persist and display the accusation solution.** Currently `Game.marked_suspect` is the only mechanism linking a suspect to an incident resolution. There is no end-screen breakdown showing which suspect was guilty for each incident. Adding a `culprit_log: Array[Int]` field to `Game` and populating it in `attempt_incident_resolution` would let the game-over screen display a full case summary, rewarding players who solved every incident correctly.

2. **Eliminate duplicated helper functions between `game` and `render`.** `completed_chains` and `suspect_confidence` are defined twice -- once in `internal/game/logic.mbt` and once in `internal/render/render.mbt` -- because `render` cannot call into `game`. Moving these two pure query functions to `internal/types/utils.mbt` (which both packages already import) would remove the duplication without creating a circular dependency.

3. **Replace the deterministic clue-placement formula with seeded random placement.** `Clue::new` derives positions from a fixed arithmetic expression (`index * 7 + suspect * 3 + ...`), so clue positions are identical every run. Passing a `seed: Int` parameter to `Game::new` and using `randi`-based placement would give each case a different layout, extending replay value at minimal code cost.

4. **Add per-severity incident spawn weighting tied to case progress.** The severity roll in `spawn_incident` uses a static probability split (48 % / 34 % / 18 %). Scaling the probability of severity-2 and severity-3 incidents with `game.solved_incidents` or elapsed case time would create a natural difficulty curve instead of a flat one throughout the 210-second session.

5. **Introduce a short cooldown after cursor movement.** `move_cursor` fires on every key-press frame. Holding down a direction key at 120 fps can skip multiple cells in one keypress repeat burst. Adding a `move_cd: Float` field to `Game` and enforcing a minimum 100 ms between moves would make navigation feel more deliberate and reduce accidental over-movement.

6. **Surface clue ownership in the grid without focus mode.** Undiscovered clues currently render as plain colored dots; only the suspect color hints at ownership, and all colors look similar under the dark ink-wash palette. Drawing a small one-letter initial (M / I / S / D) inside the dot would let players plan routes without needing to activate focus, reducing the burden on a mechanic with a 7-second cooldown.

7. **Add a minimum trust floor that prevents instant game-over on the first missed high-severity incident.** `trust_penalty_missed_incident` is 7.8 and severity can add 2.1 * 3 = 6.3 more, totalling up to 14.1 per missed incident. Early in the game when trust is still building, one unlucky high-severity timeout can end the run immediately. Introducing a `trust_floor: Float = 8.0` constant and flooring the penalty so trust cannot drop below the floor in a single tick would soften early-game punishments while keeping late-game stakes high.
