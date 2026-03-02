# Paper Lantern Patrol 2026

A night festival escort game where you patrol the streets guiding paper lanterns to shrines before their flames go out. Protect lanterns from wind gusts, sparks, and thieves while chaining deliveries for combo bonuses.

## Build and Run

```bash
cd examples && moon build --target native raylib_paper_lantern_patrol_2026/
cd examples && ./_build/native/debug/build/raylib_paper_lantern_patrol_2026/raylib_paper_lantern_patrol_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move the patrol character
- **J**: Interact -- pick up/escort a nearby lantern, stabilize its flame, or deliver it at a shrine
- **K**: Release escorted lantern, or raise a guard stance that pushes thieves away
- **Space**: Deploy a calm-wind field (cooldown-based) that slows gusts, sparks, and thieves
- **P**: Pause
- **R**: Restart

## How to Play

Lanterns spawn at the gate on the left and must be delivered to one of four shrines on the right side of the field. Each lantern has a flame meter that constantly drains and is further reduced by wind gusts, sparks, and thief attacks. Escort a lantern by moving near it and pressing J, then guide it to its target shrine for delivery. Chain consecutive deliveries within the combo window to earn increasing bonus points. The run ends when too many lanterns are extinguished (7 total). Use the guard stance (K) to repel thieves and the calm-wind field (Space) to dampen environmental hazards in a radius around you.

## Public API Reference

### Package `raylib_paper_lantern_patrol_2026`

> Main entry point. Initializes the window, creates the game state, and runs the main loop.

No additional public types or functions beyond the `main` entry point.

### Package `raylib_paper_lantern_patrol_2026/internal/types`

> Core type definitions, constants, utility functions, and world-layout helpers.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Playing`, `Paused`, `GameOver` | Game state machine controlling the active update and render path |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `InputState` | `move_x`, `move_y`, `press_interact`, `press_cancel`, `press_calm`, `press_pause`, `press_restart`, `press_start` | Per-frame input snapshot for all action and movement inputs |
| `Patrol` | `x`, `y`, `vx`, `vy`, `escort`, `guard_t`, `calm_t`, `calm_cd` | Player character with position, velocity, current escort index, and ability timers |
| `Lantern` | `active`, `x`, `y`, `vx`, `vy`, `flame`, `target_shrine`, `escorting`, `wobble` | A paper lantern entity with position, flame meter, and escort state |
| `Gust` | `active`, `x`, `y`, `vx`, `vy`, `radius`, `power`, `life` | Wind gust hazard with position, influence radius, drain power, and lifetime |
| `Spark` | `active`, `x`, `y`, `vx`, `vy`, `life`, `power`, `size` | Drifting ember hazard with position, drain power, and lifetime |
| `Thief` | `active`, `x`, `y`, `vx`, `vy`, `speed`, `target`, `steal_cd`, `life` | Enemy thief that chases active lanterns and periodically steals flame |
| `Game` | `input`, `patrol`, `lanterns`, `gusts`, `sparks`, `thieves`, `state`, `score`, `deliveries`, `extinguished`, `combo`, `combo_t`, `run_time` | Aggregates all mutable state needed to run one game session |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `InputState::new` | `() -> InputState` | Creates a default input state with all fields zeroed/false |
| `Patrol::new` | `() -> Patrol` | Creates a patrol starting near the gate with zeroed velocity and no escort |
| `Lantern::new` | `() -> Lantern` | Creates an inactive lantern with all fields zeroed |
| `Gust::new` | `() -> Gust` | Creates an inactive gust with all fields zeroed |
| `Spark::new` | `() -> Spark` | Creates an inactive spark with all fields zeroed |
| `Thief::new` | `() -> Thief` | Creates an inactive thief with all fields zeroed |
| `Game::new` | `() -> Game` | Creates a full game state with pre-allocated entity pools and title state |
| `active_lantern_count` | `(Game) -> Int` | Returns the number of currently active lanterns |
| `active_gust_count` | `(Game) -> Int` | Returns the number of currently active gusts |
| `active_thief_count` | `(Game) -> Int` | Returns the number of currently active thieves |
| `gate_position` | `() -> (Float, Float)` | Returns the world-space position of the lantern spawn gate |
| `shrine_position` | `(Int) -> (Float, Float)` | Returns the world-space position of the given shrine index (0–3) |

#### Constants (selected)

| Constant | Type | Description |
|----------|------|-------------|
| `screen_w` | `Int` | Window width (1440 pixels) |
| `screen_h` | `Int` | Window height (860 pixels) |
| `target_fps` | `Int` | Target frame rate (120) |
| `max_lanterns` | `Int` | Maximum simultaneously active lanterns (20) |
| `max_gusts` | `Int` | Maximum simultaneously active gusts (24) |
| `max_sparks` | `Int` | Maximum simultaneously active sparks (180) |
| `max_thieves` | `Int` | Maximum simultaneously active thieves (18) |
| `shrine_count` | `Int` | Number of delivery shrines (4) |
| `patrol_radius` | `Float` | Collision radius for the patrol character |
| `lantern_base_drain` | `Float` | Passive flame drain rate per second |
| `lantern_escort_regen` | `Float` | Flame regeneration rate while being escorted |
| `extinguish_limit` | `Int` | Maximum lanterns extinguished before game over (7) |
| `delivery_score_base` | `Int` | Base score per successful delivery (128) |
| `combo_window` | `Float` | Time window in seconds to maintain a delivery combo |
| `combo_bonus_step` | `Int` | Extra score per combo level |

#### Utility Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer to `[lo, hi]` |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to `[lo, hi]` |
| `minf` | `(Float, Float) -> Float` | Returns the smaller of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns the larger of two floats |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Returns squared distance between two 2D points |
| `randf` | `(Float, Float) -> Float` | Returns a pseudo-random float in `[lo, hi]` |
| `randi` | `(Int, Int) -> Int` | Returns a pseudo-random integer in `[lo, hi]` |
| `sinf` | `(Float) -> Float` | Sine of an angle in radians |
| `cosf` | `(Float) -> Float` | Cosine of an angle in radians |
| `a_col` | `(@raylib.Color, Int) -> @raylib.Color` | Returns a color with modified alpha |
| `lantern_flame_col` | `(Float) -> @raylib.Color` | Returns a color interpolated from orange to white based on flame level |

### Package `raylib_paper_lantern_patrol_2026/internal/game`

> Game logic, input handling, entity spawning, and state transitions.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(@types.Game, Float) -> Unit` | Main per-frame update: samples input, advances timers, updates all entities, and dispatches to the active state handler |

### Package `raylib_paper_lantern_patrol_2026/internal/render`

> Rendering for all game entities, HUD, and overlays.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(@types.Game) -> Unit` | Main rendering entry point: draws background, playfield, all entities, HUD, and active state overlays |

## Architecture

### Package Structure

```
raylib_paper_lantern_patrol_2026/
├── main.mbt              — Entry point: window init, game loop, frame clamping
├── moon.pkg              — Package config with imports
└── internal/
    ├── types/
    │   ├── types.mbt     — GameState enum, all entity structs, Game struct, constructors, derived metrics
    │   ├── constants.mbt — Screen dimensions, pool sizes, tuning values, gate/shrine position helpers
    │   └── utils.mbt     — Math helpers, color utilities, random sampling
    ├── game/
    │   ├── logic.mbt     — State machine update, entity spawning/simulation, delivery/escort logic
    │   └── input.mbt     — Per-frame keyboard sampling into InputState
    └── render/
        └── render.mbt    — Background, playfield, entities, HUD, overlays
```

The `types` package defines all shared data structures and provides constants and utility functions. Both `game` and `render` depend on `types` but not on each other, enforcing a clean one-directional data flow.

### Data Flow

1. **Input**: `update_input` in `input.mbt` reads keyboard state via raylib and writes to `game.input` (an `InputState` snapshot), providing a clean per-frame view of all button presses.
2. **Update**: `update_game` in `logic.mbt` processes the current state. In the Playing state it advances the patrol character's physics (`update_patrol`), processes J/K/Space actions (`handle_actions`), updates the combo timer (`update_combo_timer`), spawns new entities with accelerating intervals (`update_spawning`), advances all gusts/sparks/thieves/lanterns, and checks the extinguish limit for game over. The title/paused/game-over states handle simpler input-driven transitions.
3. **Render**: `draw_frame` in `render.mbt` reads the `Game` struct and draws the background gradient, playfield borders, shrine targets, gate, all active gusts, sparks, thieves, lanterns (with flame glow), the patrol character (with calm-field and guard-flash effects), the status strip, HUD panel, and state-specific overlays (title, paused, game-over).

### Key Design Patterns

- **Fixed-size entity pools**: All entities (lanterns, gusts, sparks, thieves) are stored in pre-allocated `Array` pools of maximum size. Slots with `active = false` are available for reuse without dynamic allocation.
- **Input snapshot**: `InputState` is cleared and re-sampled each frame, preventing double-processing and isolating input from logic.
- **Combo window timer**: `combo_t` counts down from `combo_window` seconds after each delivery. A delivery before it expires increments the combo multiplier; expiry resets it to zero, giving players a tangible chain mechanic.
- **Accelerating spawn intervals**: Each hazard type has a `spawn_cd` countdown and an interval that shrinks toward a floor value as `run_time` increases, creating escalating difficulty without explicit difficulty levels.
- **Escort pull physics**: When a lantern is being escorted, its velocity is updated each frame by a pull force toward the patrol character (`escort_pull * dist`), so it follows smoothly with natural lag rather than teleporting.
- **State machine dispatch**: `GameState` drives both the update logic path and the overlay rendering selection, keeping each state's code localized.

## Improvement & Refinement Plan

1. **Represent entity pools as typed pool structs**: Each entity type (Lantern, Gust, Spark, Thief) is managed as a raw `Array` with a manual active-flag scan. A generic pool abstraction with `spawn`, `free`, and `each_active` methods would reduce duplication across the five pool management sites.

2. **Add a shrines-queue display**: The current HUD shows a delivery count but not which shrines have lanterns en route. Displaying each shrine's queue depth or a progress indicator per shrine would help players prioritize which lanterns to escort.

3. **Introduce progressive difficulty tiers instead of continuous scaling**: Hazard spawn intervals shrink continuously as `run_time` increases. Replacing the linear ramp with explicit difficulty tiers (e.g., every 60 seconds a new hazard type unlocks or increases in count) would give players clearer milestones and a more varied experience arc.

4. **Extract the calm-wind field into its own visual system**: The calm-wind effect (`calm_t` and radius) reduces hazard intensity but has minimal visual distinction from normal play. Adding a visible ripple or particle ring while the calm field is active would give players better feedback on when and where it is effective.

5. **Add a high-score persistence layer**: `best_score` is tracked per session in the `Game` struct but is never persisted to disk. Saving and loading a persistent best score via a file would give the endless-runner format a meaningful long-term goal.

6. **Reduce duplication between `start_new_run` and `Game::new`**: The constructor and `start_new_run` both initialize overlapping sets of fields. Centralizing initialization in `start_new_run` and calling it from `Game::new` would eliminate the risk of the two drifting out of sync.
