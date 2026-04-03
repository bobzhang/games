# Dungeon Courier Escape 2026

A stealth-action delivery game set in a procedurally populated dungeon. You play as an underground courier who must collect parcels scattered across a guarded floor and deliver them to glowing exit markers before time runs out. Guards patrol with vision cones, floor traps deal damage and alert nearby enemies, and smoke decoys provide temporary cover.

The core loop involves picking up parcels with the interact key, navigating past patrolling guards while managing a stealth meter, and delivering parcels at exit rings. Sprinting increases speed at the cost of stealth and generates noise pressure that draws guard attention. Each wave adds more guards, traps, and tighter deadlines. Clearing a wave's delivery target advances to the next wave with health recovery and a score bonus. The stealth system is pressure-based: guard detection cones, traps, and sprinting all generate detection pressure that drains stealth, and when stealth hits zero the player takes continuous health damage.

The game features a multi-layered detection system where guard vision cones have angle-and-distance falloff, smoke bombs lure guards away from patrol routes, and a global alarm flash provides visual feedback. Wave difficulty scales through guard speed, cone range, trap damage, and time constraints controlled by extensive tuning constants.

## Build and Run

```bash
moon build --target native dungeon_courier_escape_2026/
./_build/native/debug/build/dungeon_courier_escape_2026/dungeon_courier_escape_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move the courier
- **Space**: Sprint (faster movement, but louder and drains stealth)
- **J**: Interact (pick up parcel / deliver at exit / drop parcel)
- **K**: Deploy smoke decoy at current position
- **Enter / Space / J**: Start game from title screen
- **R / Enter / Space**: Retry after failure
- **F11**: Toggle borderless windowed mode

## How to Play

Each wave requires delivering a target number of parcels to any of three exit markers within a time limit (starting at 74 seconds, decreasing per wave).

1. **Collect parcels**: Walk near a yellow parcel and press J to pick it up. You can carry one parcel at a time. Carrying a parcel reduces your movement speed to 83%.
2. **Deliver to exits**: Carry a parcel near a glowing blue EXIT ring and press J to deliver. Each delivery scores 110 + (wave x 24) points and restores some stealth.
3. **Avoid guards**: Red guards patrol between two waypoints with visible vision cones. If you enter a guard's cone, detection pressure builds based on distance and angle. Guards in alert state chase the player at 135% speed.
4. **Watch for traps**: Pink blinking circles on the floor deal damage on contact (16 base + 2.5 per wave), drain 24 stealth, trigger a global alarm flash, and alert all guards. Traps have a 1.15-second cooldown between triggers.
5. **Use smoke decoys**: Press K to deploy a smoke bomb (limited stock per wave, starts at 2). Smoke clouds last 4.8 seconds, reduce detection pressure by 62% when standing inside, and lure guards within 250 units toward the smoke position.
6. **Manage stealth**: Stealth recovers at 16/sec when not under pressure. When stealth hits zero under pressure, you take 19 damage/sec. Sprinting burns 8 stealth/sec and adds 10 noise pressure.
7. **Wave progression**: Meet the delivery target to advance. You gain a score bonus (160 base + 38 per wave + time bonus) and 12 health recovery. Guard count, trap count, and delivery targets increase each wave.

**Lose conditions**: Health reaches zero (overwhelmed by guards/traps) or time expires.

## Public API Reference

### Package `dungeon_courier_escape_2026`

> Main entry point.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Entry point: initializes window (1440x900), creates Game, runs update/render loop |

### Package `dungeon_courier_escape_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `Retry` | Game state machine states |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Player` | `x`, `y`, `vx`, `vy`, `facing_deg`, `health`, `stealth`, `carrying_parcel` | Player courier with position, velocity, health/stealth meters, and carried parcel index (-1 = none) |
| `Parcel` | `active`, `delivered`, `x`, `y`, `pulse` | Collectible parcel with delivery tracking and visual pulse timer |
| `ExitMarker` | `active`, `x`, `y`, `radius` | Delivery destination ring |
| `Guard` | `active`, `x`, `y`, `vx`, `vy`, `dir_deg`, `patrol_a_x/y`, `patrol_b_x/y`, `to_b`, `speed`, `cone_range`, `cone_half_angle`, `alert_t`, `investigate_t`, `target_x/y` | Patrolling enemy with vision cone, alert/investigate states, and patrol waypoints |
| `Trap` | `active`, `x`, `y`, `radius`, `blink_t`, `cooldown` | Floor trap with damage cooldown and blink animation timer |
| `Smoke` | `active`, `x`, `y`, `radius`, `life` | Smoke decoy cloud with lifetime decay |
| `InputState` | `move_x`, `move_y`, `interact_press`, `smoke_press`, `sprint_hold`, `start_press`, `retry_press` | Per-frame input state |
| `Game` | `player`, `parcels`, `exits`, `guards`, `traps`, `smokes`, `input`, `state`, `wave`, `score`, `delivered_total`, `delivered_wave`, `target_deliveries`, `smoke_stock`, `time_left`, `wave_clock`, `alarm_flash`, `info_t`, `hint`, `fail_reason`, `best_wave` | Main game state container |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1440` | Window width |
| `screen_h` | `Int` | `900` | Window height |
| `target_fps` | `Int` | `120` | Target frame rate |
| `max_parcels` | `Int` | `12` | Maximum parcel pool size |
| `max_exits` | `Int` | `3` | Number of exit markers |
| `max_guards` | `Int` | `16` | Maximum guard pool size |
| `max_traps` | `Int` | `28` | Maximum trap pool size |
| `max_smokes` | `Int` | `8` | Maximum smoke pool size |
| `player_base_speed` | `Float` | `210.0` | Base movement speed |
| `player_sprint_mult` | `Float` | `1.62` | Sprint speed multiplier |
| `player_carry_speed_mult` | `Float` | `0.83` | Speed multiplier when carrying a parcel |
| `player_health_max` | `Float` | `100.0` | Maximum health |
| `player_stealth_max` | `Float` | `100.0` | Maximum stealth |
| `guard_speed_base` | `Float` | `96.0` | Base guard patrol speed |
| `guard_cone_range_base` | `Float` | `214.0` | Base vision cone range |
| `guard_cone_half_angle_base` | `Float` | `27.0` | Base vision cone half-angle in degrees |
| `trap_damage_base` | `Float` | `16.0` | Base trap damage per trigger |
| `smoke_radius_base` | `Float` | `154.0` | Base smoke cloud radius |
| `smoke_life_secs` | `Float` | `4.8` | Smoke cloud lifetime |
| `wave_time_base` | `Float` | `74.0` | Starting wave time limit |
| `pi` | `Float` | `3.141592653589793` | Mathematical constant pi |
| `deg_to_rad` | `Float` | `pi / 180.0` | Degrees to radians conversion factor |
| `rad_to_deg` | `Float` | `180.0 / pi` | Radians to degrees conversion factor |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Player::new` | `() -> Player` | Creates a player at spawn position with full health/stealth |
| `Parcel::new` | `() -> Parcel` | Creates an inactive parcel |
| `ExitMarker::new` | `(Float, Float) -> ExitMarker` | Creates an active exit marker at the given position |
| `Guard::new` | `() -> Guard` | Creates an inactive guard with base stats |
| `Trap::new` | `() -> Trap` | Creates an inactive trap |
| `Smoke::new` | `() -> Smoke` | Creates an inactive smoke cloud |
| `InputState::new` | `() -> InputState` | Creates a zeroed input state |
| `Game::new` | `() -> Game` | Creates a new game with all entity pools and default state |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between bounds |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between bounds |
| `minf` | `(Float, Float) -> Float` | Returns the minimum of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns the maximum of two floats |
| `absf` | `(Float) -> Float` | Returns absolute value of a float |
| `sqrtf` | `(Float) -> Float` | Computes square root |
| `sinf` | `(Float) -> Float` | Computes sine with float conversion |
| `cosf` | `(Float) -> Float` | Computes cosine with float conversion |
| `randf` | `(Float, Float) -> Float` | Random float in [lo, hi] |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two 2D points |
| `normalize_deg` | `(Float) -> Float` | Normalizes an angle to [-180, 180] degrees |
| `angle_delta_deg` | `(Float, Float) -> Float` | Absolute angular difference in degrees |
| `heading_deg` | `(Float, Float) -> Float` | Heading angle from dx/dy in degrees via atan2 |
| `world_w` | `() -> Float` | Returns playable world width |
| `world_h` | `() -> Float` | Returns playable world height |
| `world_center_x` | `() -> Float` | Returns horizontal center of the world |
| `player_spawn_x` | `() -> Float` | Returns player spawn X (world center) |
| `player_spawn_y` | `() -> Float` | Returns player spawn Y (near bottom) |
| `default_exit_pos` | `(Int) -> (Float, Float)` | Returns default position for exit marker by index |
| `col_bg_top` | `() -> @raylib.Color` | Dark blue-black background top gradient color |
| `col_bg_bottom` | `() -> @raylib.Color` | Dark blue-black background bottom gradient color |
| `col_floor` | `() -> @raylib.Color` | Dungeon floor color |
| `col_floor_grid` | `() -> @raylib.Color` | Floor grid line color |
| `col_wall` | `() -> @raylib.Color` | Decorative wall/pillar color |
| `col_player` | `() -> @raylib.Color` | Player circle color (teal green) |
| `col_guard` | `() -> @raylib.Color` | Guard circle color (red) |
| `col_parcel` | `() -> @raylib.Color` | Parcel rectangle color (yellow) |
| `col_exit` | `() -> @raylib.Color` | Exit marker ring color (blue) |
| `col_trap` | `() -> @raylib.Color` | Trap indicator color (pink) |
| `col_health` | `() -> @raylib.Color` | Health meter fill color |
| `col_stealth` | `() -> @raylib.Color` | Stealth meter fill color |

### Package `dungeon_courier_escape_2026/internal/game`

> Game logic, input handling, and state management.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Top-level update: reads input, dispatches to state-specific logic (Title/Play/Retry) |

### Package `dungeon_courier_escape_2026/internal/render`

> Rendering and visual effects.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main render entry point: draws background, entities, HUD, and state overlays |

## Architecture

### Package Structure

```
dungeon_courier_escape_2026/
├── main.mbt              — Entry point: window init, game loop
├── moon.pkg              — Package config, imports
└── internal/
    ├── types/
    │   ├── types.mbt     — Enums (GameState), structs (Player, Guard, Game, etc.), constructors
    │   ├── constants.mbt — Tuning constants (speeds, ranges, damages, pool sizes, colors)
    │   └── utils.mbt     — Math utilities (clamp, trig, distance, angle normalization, world helpers)
    ├── game/
    │   ├── input.mbt     — Keyboard input reading into InputState
    │   └── logic.mbt     — Wave setup, entity spawning, movement, detection, combat, state transitions
    └── render/
        └── render.mbt    — All drawing: background, entities, HUD, title/retry overlays
```

The `types` package is the shared foundation with no game logic. The `game` package imports `types` and handles all simulation. The `render` package imports `types` (but not `game`) and performs read-only rendering from the `Game` struct.

### Data Flow

1. **Input**: `update_input` in `input.mbt` reads keyboard state and populates `game.input` (an `InputState` struct) each frame.
2. **Update**: `update_game` dispatches based on `game.state`. In `Play` mode, `update_play` sequences: smoke deployment, parcel interaction (`try_interact`), player motion (`update_player_motion`), smoke lifetime decay, guard AI (`update_guards`), trap checks (`update_traps`), stealth/health pressure resolution, and win/lose checks.
3. **Guard AI**: Each guard chooses a target: smoke lure (highest priority), player chase (if alerted), investigation point, or patrol waypoint toggle. Detection pressure is computed per-guard using cone geometry (distance factor x angle factor x wave scale).
4. **Render**: `draw_frame` layers: background with scrolling grid, exits, traps, parcels, smoke clouds, guards (with vision cone sectors), player, alarm overlay, HUD meters, and state-specific overlays (title or retry).

### Key Design Patterns

- **Object pool pattern**: All entity arrays (parcels[12], guards[16], traps[28], smokes[8]) are pre-allocated with `active` flags. Placement functions retry up to 48-64 attempts with distance constraints.
- **State machine**: `GameState` enum (Title, Play, Retry) with clean transitions via `start_new_run`, `advance_wave`, and `fail_mission`.
- **Pressure-based detection**: Instead of binary detection, guards, traps, and sprinting contribute additive pressure. Smoke cover applies a multiplicative factor. Stealth drains proportionally to total pressure.
- **Wave scaling**: Guard speed/range, trap damage, delivery targets, time limits, and smoke stock all scale with wave number through explicit formulas using tuning constants.
- **Separation of concerns**: Input, logic, and rendering are cleanly separated. The render package only reads game state and never modifies it.

## Improvement & Refinement Plan

1. **Add wall/obstacle collision**: The decorative pillars drawn in `draw_background` are purely visual. Adding collision checks against pillar positions in `update_player_motion` and guard patrol logic would create meaningful terrain navigation.
2. **Replace integer parcel indices with Option type**: `Player.carrying_parcel` uses -1 as a sentinel value. Using `Option[Int]` would be more idiomatic and prevent potential index errors.
3. **Add guard state enum**: Guard behavior uses `alert_t > 0.0` and `investigate_t > 0.0` checks. A `GuardState::Patrol | Alert | Investigate | Lured` enum would make the AI state machine explicit.
4. **Implement line-of-sight for guards**: Currently guards detect the player purely by cone angle and distance. Adding raycast checks against pillar positions would create hiding spots and more strategic gameplay.
5. **Add parcel value variation**: All parcels are identical. Adding different reward values or special parcels (e.g., fragile parcels that break on trap contact) would add depth to collection decisions.
6. **Optimize trap collision checks**: `update_traps` checks all 28 traps every frame against the player. A spatial hash or grid-based broad phase could reduce unnecessary distance calculations, especially as trap count grows with waves.
7. **Add touch/mobile input support**: Unlike some other games in this collection, the input system only handles keyboard. Adding touch controls would enable mobile play.
