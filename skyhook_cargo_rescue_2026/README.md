# Skyhook Cargo Rescue

A helicopter rescue game set in a dangerous storm corridor. The player pilots a helicopter equipped with an extendable skyhook to lift stranded civilians from a hazard-filled zone and deliver them to a safe rescue pad. The mission succeeds when 18 survivors are extracted before the 210-second timer expires.

The core gameplay loop involves flying through a storm-wracked play area, extending the hook to grab panicking survivors, then retracting the hook and delivering them to the rescue pad in the upper-right corner. Three types of hazards -- storm clouds, homing drones, and ice shards -- constantly spawn from the edges and must be avoided or deflected by the rapidly-moving hook. Pickups for fuel, hull repair, and turbo boost drift through the field, requiring the player to balance rescue priorities with resource collection.

The game features a wave-scaling difficulty system where hazard spawn rates increase and wind forces grow stronger over time. Fuel drains continuously (faster when boosting), and running out damages the hull. A combo system rewards consecutive rescues, and a hint system helps locate survivors or fuel when the player is lost.

## Build and Run

```bash
moon build --target native skyhook_cargo_rescue_2026/
./_build/native/debug/build/skyhook_cargo_rescue_2026/skyhook_cargo_rescue_2026.exe
```

## Controls

- **W / Up Arrow**: Move helicopter up
- **A / Left Arrow**: Move helicopter left
- **S / Down Arrow**: Move helicopter down
- **D / Right Arrow**: Move helicopter right
- **Space**: Toggle hook extend/retract
- **Shift (Left/Right) / J**: Boost (increased speed, higher fuel consumption)
- **E**: Repair hull (requires proximity to rescue pad and 8+ fuel)
- **H**: Use hint (marks nearest survivor, fuel pickup, or safe zone; 3 hints per run, costs 5 score)
- **R**: Restart current run
- **Escape**: Return to title screen
- **Enter / Space**: Start game / retry after result
- **Touch controls**: On-screen buttons for L/R/U/D movement, HOOK, BST (boost), HNT (hint), RST (restart), RPR (repair)

## How to Play

Fly the helicopter through the 1120x940 play area during a raging storm. Extend your skyhook (Space) to grab a civilian below, then retract and fly to the rescue pad (marked "RESCUE PAD" in the upper right). When you retract the hook inside the safe zone while carrying a survivor, they are rescued and you earn points plus a combo bonus.

Avoid three types of hazards: storm clouds (slow-moving, moderate damage), homing drones (track helicopter or carried survivor), and ice shards (fast-falling). If a hazard hits a carried survivor, you lose them. If it hits your helicopter, you take hull damage. When hull reaches zero, you lose a life (3 total) and the helicopter resets.

Fuel drains at 1.2/s (2.7/s while boosting), scaling up with wave number. When fuel runs out, hull takes passive damage. Collect fuel pickups (orange, +30 fuel), medkits (pink, +28 hull), and turbo boosts (purple, 7s turbo). Use the repair ability (E) near the rescue pad to convert 8 fuel into 32 hull.

Win by rescuing 18 survivors. Lose if all 3 lives are lost or the 210-second timer expires.

## Public API Reference

### Package `skyhook_cargo_rescue_2026`

> Main entry point. Initializes the window, creates the game state, and runs the game loop.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Entry point: sets up 1720x980 window at 120 FPS, creates Game, runs update/draw loop |

### Package `skyhook_cargo_rescue_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1720` | Screen width in pixels |
| `screen_h` | `Int` | `980` | Screen height in pixels |
| `target_fps` | `Int` | `120` | Target frame rate |
| `state_title` | `Int` | `0` | Title screen state |
| `state_play` | `Int` | `1` | Active gameplay state |
| `state_result` | `Int` | `2` | Result/game over screen state |
| `hazard_cloud` | `Int` | `0` | Storm cloud hazard type |
| `hazard_drone` | `Int` | `1` | Homing drone hazard type |
| `hazard_ice` | `Int` | `2` | Ice shard hazard type |
| `pickup_fuel` | `Int` | `0` | Fuel pickup type |
| `pickup_medkit` | `Int` | `1` | Medkit (hull repair) pickup type |
| `pickup_turbo` | `Int` | `2` | Turbo boost pickup type |
| `max_survivors` | `Int` | `90` | Maximum concurrent survivors |
| `max_hazards` | `Int` | `160` | Maximum concurrent hazards |
| `max_pickups` | `Int` | `80` | Maximum concurrent pickups |
| `max_particles` | `Int` | `1400` | Maximum concurrent particles |
| `world_x0` | `Int` | `24` | World area left offset |
| `world_y0` | `Int` | `20` | World area top offset |
| `world_w` | `Int` | `1120` | World area width |
| `world_h` | `Int` | `940` | World area height |
| `panel_x0` | `Int` | `world_x0 + world_w + 24` | Side panel left offset |
| `panel_w` | `Int` | `screen_w - panel_x0 - 24` | Side panel width |
| `heli_r` | `Float` | `24.0` | Helicopter collision radius |
| `survivor_r` | `Float` | `15.0` | Survivor collision radius |
| `rescue_target` | `Int` | `18` | Number of rescues needed to win |
| `run_time_goal` | `Float` | `210.0` | Mission time limit in seconds |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Survivor` | `active`, `x`, `y`, `vx`, `vy`, `carried`, `panic`, `phase` | Stranded civilian with panic level affecting drift behavior |
| `Hazard` | `active`, `x`, `y`, `vx`, `vy`, `r`, `hp`, `kind`, `phase` | Environmental hazard (cloud, drone, or ice) with type-specific behavior |
| `Pickup` | `active`, `x`, `y`, `vx`, `vy`, `kind`, `phase` | Collectible item (fuel, medkit, or turbo) drifting through the field |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | Visual effect particle with type-based coloring |
| `Game` | `state`, `heli_x`, `heli_y`, `hook_len`, `carrying_idx`, `lives`, `hull`, `fuel`, `score`, `rescued`, `wave`, `combo`, ... | Main game state container with helicopter, hook, scoring, spawning, and UI state |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Survivor::new` | `() -> Survivor` | Creates an inactive survivor with default fields |
| `Hazard::new` | `() -> Hazard` | Creates an inactive hazard with default fields |
| `Pickup::new` | `() -> Pickup` | Creates an inactive pickup with default fields |
| `Particle::new` | `() -> Particle` | Creates an inactive particle with default fields |
| `Game::new` | `() -> Game` | Creates a new game instance with all arrays allocated and title state |
| `mini` | `(Int, Int) -> Int` | Returns the minimum of two integers |
| `maxi` | `(Int, Int) -> Int` | Returns the maximum of two integers |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between low and high bounds |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between low and high bounds |
| `minf` | `(Float, Float) -> Float` | Returns the minimum of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns the maximum of two floats |
| `absf` | `(Float) -> Float` | Returns absolute value of a float |
| `sinf` | `(Float) -> Float` | Sine function (Float precision via math.sin) |
| `cosf` | `(Float) -> Float` | Cosine function (Float precision via math.cos) |
| `randf` | `(Float, Float) -> Float` | Random float in range using raylib RNG |
| `world_left` | `() -> Float` | Left boundary of world area as float |
| `world_right` | `() -> Float` | Right boundary of world area as float |
| `world_top` | `() -> Float` | Top boundary of world area as float |
| `world_bottom` | `() -> Float` | Bottom boundary of world area as float |
| `safe_cx` | `() -> Float` | Center X of the safe zone |
| `safe_cy` | `() -> Float` | Center Y of the safe zone |
| `safe_zone_x` | `() -> Int` | Safe zone left X coordinate |
| `safe_zone_y` | `() -> Int` | Safe zone top Y coordinate |
| `safe_zone_w` | `() -> Int` | Safe zone width (184) |
| `safe_zone_h` | `() -> Int` | Safe zone height (142) |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two 2D points |
| `point_in_rectf` | `(Float, Float, Float, Float, Float, Float) -> Bool` | Point-in-rect test with float parameters |
| `point_in_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Point-in-rect test with integer rect parameters |
| `inside_safe_zone` | `(Float, Float) -> Bool` | Tests if a point is inside the rescue pad safe zone |
| `hook_tip_x` | `(Game) -> Float` | Returns X position of the hook tip (same as heli_x) |
| `hook_tip_y` | `(Game) -> Float` | Returns Y position of the hook tip (heli_y + hook_len) |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Tests mouse and all touch points against a rectangle |
| `start_button_rect` | `() -> (Int, Int, Int, Int)` | Returns title screen start button bounds |
| `retry_button_rect` | `() -> (Int, Int, Int, Int)` | Returns result screen retry button bounds |
| `btn_left` | `() -> (Int, Int, Int, Int)` | Touch control: left movement button bounds |
| `btn_right` | `() -> (Int, Int, Int, Int)` | Touch control: right movement button bounds |
| `btn_up` | `() -> (Int, Int, Int, Int)` | Touch control: up movement button bounds |
| `btn_down` | `() -> (Int, Int, Int, Int)` | Touch control: down movement button bounds |
| `btn_hook` | `() -> (Int, Int, Int, Int)` | Touch control: hook toggle button bounds |
| `btn_boost` | `() -> (Int, Int, Int, Int)` | Touch control: boost button bounds |
| `btn_hint` | `() -> (Int, Int, Int, Int)` | Touch control: hint button bounds |
| `btn_restart` | `() -> (Int, Int, Int, Int)` | Touch control: restart button bounds |
| `btn_repair` | `() -> (Int, Int, Int, Int)` | Touch control: repair button bounds |

### Package `skyhook_cargo_rescue_2026/internal/game`

> Game logic, input handling, and update systems.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Top-level update: polls mouse/touch, dispatches to state-specific input and update handlers |

### Package `skyhook_cargo_rescue_2026/internal/render`

> Rendering and visual effects.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main render entry: draws background, world, hazards, pickups, survivors, helicopter, HUD panel, touch controls, and overlays |

## Architecture

### Package Structure

```
skyhook_cargo_rescue_2026/
├── main.mbt                          — Entry point: window init, game loop
├── moon.pkg                          — Root package config
└── internal/
    ├── types/
    │   ├── types.mbt                 — Structs (Survivor, Hazard, Pickup, Particle, Game) and constructors
    │   ├── constants.mbt             — Screen dimensions, pool sizes, safe zone geometry, button rects
    │   ├── utils.mbt                 — Math helpers, world bounds, collision tests, pointer hit testing
    │   └── moon.pkg                  — Types package config
    ├── game/
    │   ├── input.mbt                 — Input polling for title, play, and result states
    │   ├── logic.mbt                 — Game state transitions, spawning, hook/heli physics, collision, resource management
    │   └── moon.pkg                  — Game package config
    └── render/
        ├── render.mbt                — All drawing: background, world, entities, HUD panel, touch controls, overlays
        └── moon.pkg                  — Render package config
```

The code follows a clean three-layer architecture. `types` defines all data structures and pure utility functions with no side effects. `game` contains all mutable state manipulation including physics, spawning, collision resolution, and state transitions. `render` is purely a read-only consumer of game state for drawing.

### Data Flow

1. **Input**: `update_game` polls mouse/touch state into `Game` fields, then delegates to `update_title_input`, `update_play_input`, or `update_result_input` based on `game.state`. Play input maps keyboard keys and touch button regions to movement, boost, hook toggle, repair, and hint actions.
2. **Update**: `update_play` orchestrates all simulation. It ticks timers (combo, turbo, repair cooldown, shake), manages wave progression (`wave = 1 + game_t / 24`), spawns survivors/hazards/pickups on timers, then calls `update_heli` (physics with wind), `update_hook` (extend/retract, grab/deliver survivor), `update_survivors` (panic drift), `update_hazards` (movement, collision with heli/hook/survivor), and `update_pickups` (drift, collection). Fuel drains continuously; empty fuel damages hull.
3. **Rendering**: `draw_frame` draws layers in order: background, world grid, storm effect, safe zone, hazards, pickups, survivors, hint indicator, particles, helicopter with hook, side panel HUD, touch controls, message bar, then state overlays (title or result).

### Key Design Patterns

- **ECS-like separation**: Types, game logic, and rendering are cleanly separated into distinct packages with unidirectional dependencies.
- **Object pool pattern**: Survivors, hazards, pickups, and particles all use pre-allocated `Array` pools with `active` flags.
- **Integer state machine**: Game state uses integer constants (`state_title`, `state_play`, `state_result`) to drive logic and rendering branches.
- **Touch-first input abstraction**: `pointer_on_rect` unifies mouse clicks and multi-touch input, and all UI buttons are defined as rectangle tuples returned by functions.
- **Wind simulation**: Sinusoidal wind forces vary by position and time, creating a feeling of turbulence that scales with wave number.
- **Hook physics**: The skyhook has a target length that smoothly extends/retracts at fixed speeds (520/580 units/s), and hook speed is tracked to enable hazard deflection when moving fast enough (>260 units/s).

## Improvement & Refinement Plan

1. **Replace integer states and kinds with enums**: `state`, `hazard.kind`, and `pickup.kind` are all integers compared to constants. Using MoonBit enums would provide type safety and eliminate magic numbers throughout `logic.mbt` and `render.mbt`.

2. **Add survivor despawn/fall mechanic**: Currently survivors persist indefinitely once spawned, only removed when rescued or dropped. Adding a fall-off-screen mechanic (like hazards going out of bounds) would increase urgency and penalize slow play.

3. **Separate input handling from game logic**: `update_play_input` in `input.mbt` directly calls `start_run`, `try_toggle_hook`, and `try_repair` from `logic.mbt`. Using an intermediate input command buffer would decouple input from side effects.

4. **Add difficulty settings**: The current `rescue_target` (18) and `run_time_goal` (210s) are hardcoded constants. Exposing these as difficulty presets (easy/normal/hard) would broaden accessibility.

5. **Improve hook-hazard interaction**: The fast-hook deflection mechanic (`hook_speed > 260.0`) in `update_hazards` is subtle and undiscoverable. Adding visual feedback (flash or sound) and documenting it in the HUD would make it a more intentional mechanic.

6. **Optimize hazard spawn distribution**: All three hazard types spawn from random edges with fixed probability (52% cloud, 30% drone, 18% ice). Adjusting distribution based on wave and player position would create more dynamic encounters.

7. **Add survivor count display in world**: Survivors on the field have no count indicator. Adding a small "3 stranded" counter near the world area would help players decide when to search versus return to base.
