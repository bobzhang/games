# Arctic Signal Relay 2026

A mission-based delivery game where you drive a rover across a frozen landscape, picking up power cells from a depot and delivering them to signal relay towers while battling storms and managing energy and heat.

## Build and Run

```bash
moon build --target native arctic_signal_relay_2026/
./_build/native/debug/build/arctic_signal_relay_2026/arctic_signal_relay_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Drive rover
- **Space / J**: Action (pick up cells at depot, deliver to towers)
- **R**: Restart
- **Enter / Space**: Start / next stage
- Touch buttons available on-screen

## How to Play

Drive your rover from the central depot to scattered relay towers. Load power cells at the depot, then deliver them to each tower until its demand is met. Storms blow across the map, pushing your rover and draining energy. Watch your energy and heat gauges -- returning to the depot recharges both. Complete all tower deliveries before the mission timer runs out to advance to the next stage.

## Public API Reference

### Package `arctic_signal_relay_2026/internal/types`
> Defines all shared game data types, game-wide constants, and stateless utility functions. All other packages depend on this package; it has no dependency on `game` or `render`.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `Result` | High-level phase of a relay session. |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Game` | `towers`, `storms`, `state`, `stage`, `best_stage`, `mission_limit_s`, `timer_s`, `objective_total`, `objective_done`, `rover_x/y/vx/vy`, `rover_energy`, `rover_heat`, `cargo_cells`, `storm_intensity`, `in_depot`, `nearby_tower`, `result_win`, `result_note`, `ui_t`, `flash_t`, `hint_t/text`, `input_*`, `mouse_*`, `touch_*` | Full mutable game state including rover physics, resource gauges, input state, and UI timers. |
| `Tower` | `active`, `x`, `y`, `need`, `delivered`, `pulse_t` | A relay tower that the rover must charge with power cells. `need` is the total cells required; `delivered` tracks progress; `pulse_t` drives the visual pulse animation. |
| `Storm` | `active`, `x`, `y`, `r`, `vx`, `vy`, `phase`, `strength` | A moving storm circle. `strength` scales drain and wind force; `phase` drives sinusoidal drift; `r` grows with stage. |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Tower::new` | `() -> Tower` | Constructs an inactive, zeroed Tower. |
| `Storm::new` | `() -> Storm` | Constructs an inactive, zeroed Storm. |
| `Game::new` | `() -> Game` | Constructs the initial game state with rover at depot, full energy/heat, and Title state. |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer to `[lo, hi]`. |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to `[lo, hi]`. |
| `maxf` | `(Float, Float) -> Float` | Returns the larger of two floats. |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float. |
| `sinf` | `(Float) -> Float` | Float sine via `@math.sin`. |
| `cosf` | `(Float) -> Float` | Float cosine via `@math.cos`. |
| `randf` | `(Float, Float) -> Float` | Uniform random float in `[lo, hi]` using `@raylib.get_random_value`. |
| `world_left/right/top/bottom` | `() -> Float` | Float edges of the play area derived from `world_x0/y0/w/h`. |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared Euclidean distance between two points. |
| `depot_x/y` | `() -> Float` | World position of the central depot (lower-left region of the map). |
| `depot_r` | `() -> Float` | Interaction radius of the depot (70.0). |
| `tower_hit_r` | `() -> Float` | Visual collision radius of a tower (30.0). |
| `tower_interact_r` | `() -> Float` | Delivery interaction radius of a tower (66.0). |
| `point_in_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests whether a point lies inside an axis-aligned rectangle. |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Returns true if a mouse hold or any active touch point hits the given rectangle. |
| `title_start_rect` | `() -> (Int, Int, Int, Int)` | Screen rectangle for the Start button on the title screen. |
| `result_primary_rect` | `() -> (Int, Int, Int, Int)` | Primary (Next / Retry) button rectangle on the result screen. |
| `result_secondary_rect` | `() -> (Int, Int, Int, Int)` | Secondary (Restart Run) button rectangle on the result screen. |
| `touch_left/right/up/down_rect` | `() -> (Int, Int, Int, Int)` | D-pad button rectangles in the side panel for touch input. |
| `touch_action_rect` | `() -> (Int, Int, Int, Int)` | ACT button rectangle in the side panel for touch input. |

#### Constants

| Constant | Type | Description |
|----------|------|-------------|
| `screen_w` | `Int` | Window width: 1440 px. |
| `screen_h` | `Int` | Window height: 900 px. |
| `target_fps` | `Int` | Target frame rate: 120 fps. |
| `world_x0`, `world_y0` | `Int` | Top-left origin of the play area (24, 24). |
| `world_w`, `world_h` | `Int` | Play area size: 980 x 852 px. |
| `panel_x0`, `panel_w` | `Int` | X origin and width of the right-side HUD panel. |
| `max_towers` | `Int` | Maximum tower slots: 6. |
| `max_storms` | `Int` | Maximum storm slots: 5. |
| `rover_r` | `Float` | Rover radius: 22.0 px. |
| `rover_accel` | `Float` | Rover acceleration: 760.0 px/s². |
| `rover_drag` | `Float` | Linear drag coefficient: 5.0. |
| `rover_max_speed` | `Float` | Maximum rover speed: 280.0 px/s. |
| `rover_wind_force` | `Float` | Storm wind force multiplier: 180.0. |
| `storm_control_penalty` | `Float` | Control reduction per unit storm intensity: 0.45. |
| `cargo_capacity` | `Int` | Maximum power cells the rover can carry: 3. |
| `energy_max`, `heat_max` | `Float` | Maximum energy and heat: 100.0 each. |
| `energy_idle_drain` | `Float` | Energy drain per second at rest: 1.6. |
| `energy_move_drain` | `Float` | Energy drain per unit speed: 0.008. |
| `energy_storm_drain` | `Float` | Energy drain per unit intensity per second: 7.4. |
| `energy_recharge_rate` | `Float` | Energy recharge rate at depot: 29.0 per second. |
| `heat_idle_drain` | `Float` | Heat drain per second at rest: 2.0. |
| `heat_storm_drain` | `Float` | Heat drain per unit intensity per second: 10.8. |
| `heat_recharge_rate` | `Float` | Heat recharge rate at depot: 34.0 per second. |
| `timer_base` | `Float` | Mission timer for stage 1: 92.0 s. |
| `timer_floor` | `Float` | Minimum mission timer at high stages: 48.0 s. |
| `timer_step` | `Float` | Timer reduction per stage: 5.0 s. |
| `tower_online_bonus_base` | `Float` | Timer bonus for completing a tower at stage 1: 3.0 s. |
| `tower_online_bonus_step` | `Float` | Additional bonus per stage level: 0.9 s. |

### Package `arctic_signal_relay_2026/internal/game`
> Contains all game logic: scene initialisation, input polling for each state, rover physics, storm simulation, resource management, cargo/delivery actions, and win/loss detection. Exports `init_title_scene` and `update_game`.

| Function | Signature | Description |
|----------|-----------|-------------|
| `init_title_scene` | `(@types.Game) -> Unit` | Resets state to `Title`, places decorative towers and storms for the title screen backdrop. |
| `update_game` | `(@types.Game, Float) -> Unit` | Main per-frame entry point. Clamps `dt` to 50 ms, ticks UI/flash/hint timers, then dispatches to state-specific input and logic. |

### Package `arctic_signal_relay_2026/internal/render`
> Stateless rendering layer. Reads only from `@types.Game` and issues raylib draw calls. Exports `draw_frame`.

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(@types.Game) -> Unit` | Renders a full frame: starfield background, world grid, signal link lines, storms, towers, depot, rover, whiteout fog, HUD panel, touch controls, and state overlays. |

## Architecture

### Package Structure

```
arctic_signal_relay_2026/
├── main.mbt          — window init, game loop, input polling into Game fields
└── internal/
    ├── types/        — Game/Tower/Storm structs, all constants, math/geometry utilities
    ├── game/         — scene setup, input handling, physics, resource logic, win/loss
    └── render/       — stateless raylib draw calls reading from Game
```

### Data Flow

`main.mbt` owns the single `Game` value and runs the loop. Each frame it reads raw raylib input (mouse position, mouse button hold, touch point count) directly into `game.mouse_*`, `game.mouse_hold`, and `game.touch_count`, then calls `@game.update_game(game, dt)`. The `game` package translates that raw input into normalised `input_*` fields (direction floats, boolean press edges) inside state-specific input handlers (`update_title_input`, `update_play_input`, `update_result_input`), which fire once per frame before any logic runs.

All simulation happens inside `update_play_state`. Storms are stepped with wrap-around wall bouncing and sinusoidal drift, then `storm_effect_at` computes the aggregate intensity and wind vector at the rover's position using squared-distance falloff. The rover velocity is updated with directional acceleration (scaled by control penalty), wind force, and drag, then clamped to `rover_max_speed`. Resource drain (energy and heat) is proportional to speed plus storm intensity, with depot recharge applied when `in_depot` is true.

The `@types` package is the sole dependency shared by both `game` and `render`. It deliberately contains no logic beyond pure math helpers and layout geometry, ensuring rendering can read game state without coupling to simulation code. All mutable state lives in the `Game` struct; neither `game` nor `render` hold module-level mutable variables.

Rendering in `draw_frame` is a straightforward sequential paint: background and world grid first, then signal link lines (alpha proportional to delivery progress), storms, towers with slot indicator dots, depot, rover (colour reflects energy/heat ratios), whiteout fog overlay (visibility vignette around rover when intensity is high), side-panel HUD with bars, on-screen touch buttons, and finally a full-screen overlay for `Title` or `Result` states.

### Key Design Patterns

- **Flat mutable struct**: All game state is stored in a single `Game` struct passed by reference. There are no sub-objects with their own update methods; every field is directly accessible to both `game` and `render` packages.
- **Separation of input and logic**: Each frame clears all `input_*` fields then repopulates them from keyboard + pointer state. Logic functions read the normalised `input_*` fields and never query raylib directly.
- **Fixed-size arena arrays**: `towers` and `storms` are fixed-length arrays (size `max_towers` = 6 and `max_storms` = 5). Slots are activated/deactivated via the `active` flag rather than dynamic allocation.
- **Stage-scaling formulas**: Timer limit, tower count, storm count, tower demand, and storm radius all scale with `stage` using simple arithmetic clamped to safe ranges, making balance tunable by editing constants in `types/constants.mbt`.
- **Stateless render package**: `draw_frame` and all its helpers are pure functions from `Game` to side-effects. No render state is persisted between frames; animation is driven by accumulated time fields (`ui_t`, `pulse_t`, `phase`) stored in `Game`.

## Improvement & Refinement Plan

1. **Animated rover orientation**: Currently the rover is drawn as a circle with a fixed heading dot offset by velocity. Storing an explicit `rover_angle` field and rotating a directional glyph would give clearer movement feedback, especially at low speeds.
2. **Storm spawning and lifecycle**: Storms are placed once per stage and never die. Adding a lifetime or split-on-collision behaviour (a large storm splitting into two smaller ones) would make later stages more dynamic without increasing base storm count.
3. **Cargo carry animation**: Power cells are drawn as floating rectangles above the rover but have no pickup or drop animation. A brief scaling flash on pick-up and a particle burst on delivery would reinforce the core interaction loop.
4. **Persistent best-stage across sessions**: `best_stage` is stored in `Game` and resets when the process exits. Serialising it to a file (or a platform save slot) would give players a meaningful long-term goal.
5. **Progressive difficulty curve tuning**: The timer reduction of 5 s per stage causes the floor of 48 s to be reached at stage 9. Adding a second axis of difficulty -- such as increasing `cargo_capacity` demand or reducing `energy_recharge_rate` -- would sustain challenge beyond that point.
6. **Sound and haptic feedback**: There are no audio calls. Adding short raylib sound effects for cell pickup, delivery, and low-energy warnings would make the resource management loop more legible.
7. **Touch control layout scaling**: Touch button positions are hardcoded relative to `panel_x0`. Adapting them to `screen_h` would allow the game to run correctly at non-standard resolutions or on portrait-oriented mobile devices.
