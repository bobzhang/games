# raylib_orbital_shield_command_2026

A circular defense game where you rotate a shield arc around a planet to deflect incoming enemies and fire shots to protect the planet from asteroid waves.

## Build and Run

```bash
cd examples && moon build --target native raylib_orbital_shield_command_2026/
cd examples && ./_build/native/debug/build/raylib_orbital_shield_command_2026/raylib_orbital_shield_command_2026.exe
```

## Controls

- **A/D or Left/Right**: Rotate shield around the planet
- **Space / J / K**: Fire shots outward
- **R**: Restart

## How to Play

- A planet sits at the center of the screen with a shield arc orbiting it
- Enemies of varying sizes approach from all directions
- Rotate the shield to block incoming enemies and fire shots to destroy them
- Larger enemies take more hits and award more points
- If enemies reach the planet, you take damage
- Survive as long as possible and rack up a high score with neon spark effects

## Public API Reference

### Package `raylib_orbital_shield_command_2026`

> Single-file game. All types and logic live directly in `main.mbt`.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Enemy` | `x`, `y`, `vx`, `vy`, `hp`, `kind`, `active` | An enemy entity approaching the planet; kind 0=small, 1=medium, 2=large |
| `Shot` | `x`, `y`, `vx`, `vy`, `ttl`, `active` | A player-fired projectile traveling outward from the shield position |
| `Spark` | `x`, `y`, `vx`, `vy`, `ttl`, `active`, `kind` | A short-lived neon particle emitted on enemy destruction or planet impact |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | 1280 | Screen width in pixels |
| `sh` | `Int` | 820 | Screen height in pixels |
| `cx` | `Float` | 640.0 | Horizontal center of the screen |
| `cy` | `Float` | 410.0 | Vertical center of the screen |
| `planet_r` | `Float` | 74.0 | Radius of the central planet |
| `shield_r` | `Float` | 148.0 | Orbital radius of the shield arc |
| `max_enemies` | `Int` | 96 | Maximum simultaneously active enemies |
| `max_shots` | `Int` | 180 | Maximum simultaneously active shots |
| `max_sparks` | `Int` | 220 | Maximum simultaneously active spark particles |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Returns whether a point lies within a rectangle |
| `deg2rad` | `(Float) -> Double` | Converts degrees to radians |
| `sinf_deg` | `(Float) -> Float` | Sine of an angle given in degrees |
| `cosf_deg` | `(Float) -> Float` | Cosine of an angle given in degrees |
| `enemy_radius` | `(Int) -> Float` | Collision radius for an enemy by kind |
| `enemy_score` | `(Int) -> Int` | Score awarded for destroying an enemy by kind |
| `enemy_damage` | `(Int) -> Int` | Planet HP damage dealt when an enemy reaches the planet |
| `enemy_hp` | `(Int) -> Int` | Starting hit-points for an enemy by kind |
| `clear_shots` | `(Array[Shot]) -> Unit` | Deactivates and resets all shots in the pool |
| `clear_enemies` | `(Array[Enemy]) -> Unit` | Deactivates and resets all enemies in the pool |
| `clear_sparks` | `(Array[Spark]) -> Unit` | Deactivates and resets all sparks in the pool |
| `spawn_spark` | `(Array[Spark], Float, Float, Float, Int) -> Unit` | Activates one spark from the pool with randomized velocity |
| `spawn_burst` | `(Array[Spark], Float, Float, Int, Float, Int) -> Unit` | Spawns n sparks to create an explosion burst effect |
| `spawn_shot` | `(Array[Shot], Float, Float, Float, Float) -> Unit` | Fires a new shot aimed toward a target position |
| `spawn_enemy` | `(Array[Enemy], Int) -> Unit` | Spawns a new enemy from a random screen edge aimed at the planet |

## Architecture

### Package Structure

```
raylib_orbital_shield_command_2026/
├── main.mbt    — All game state, logic, and rendering in a single file
└── moon.pkg    — Package config with imports
```

This game uses a flat single-file architecture. All constants, structs, helper functions, entity pool management, physics updates, collision detection, and rendering are contained within `main.mbt`. The main loop allocates three fixed-size pools (enemies, shots, sparks) as `Array` values, runs the full update-render cycle each frame, and restarts by clearing the pools and resetting local variables.

### Data Flow

1. **Input**: Keyboard state is read inline inside the main loop. Shield rotation from A/D, firing from Space/J/K, and restart from R are all handled with direct `@raylib.is_key_*` calls.
2. **Update**: The main loop advances shield angle, updates shot/enemy/spark positions, applies drag to sparks, performs shield deflection against enemies by angular proximity, checks shot-to-enemy collisions, handles planet impact when an enemy reaches within `planet_r`, and escalates the sector (difficulty) every 30 seconds.
3. **Render**: All drawing is inline in the main loop using raylib calls: background gradient, planet, shield arc, enemies (sized by kind), shots, spark particles, HUD text, and game-over/victory overlays.

### Key Design Patterns

- **Object pool**: Three pre-allocated `Array` pools (`enemies`, `shots`, `sparks`) are used throughout. Inactive slots have `active = false` and are reused without allocation.
- **Sector-based difficulty**: A `sector` counter increments every 30 seconds, passed to `spawn_enemy` to increase enemy base speed linearly.
- **Angular shield collision**: Enemy deflection is resolved by computing the angle of each enemy relative to the planet center and comparing it to the shield arc's angular range, avoiding per-pixel geometry.
- **Flat game-state variables**: No Game struct or state machine is used. All mutable state (`score`, `planet_hp`, `shield_angle`, `over`, `won`, etc.) is held as local `mut` variables in the main loop.
- **Delta-time clamping**: Frame time is capped at 0.05s to prevent large physics steps on slow frames.

## Improvement & Refinement Plan

1. **Introduce a `Game` struct to consolidate scattered state**: The game loop holds all mutable state as individual `mut` local variables (`score`, `planet_hp`, `shield_angle`, `sector`, `over`, etc.). Grouping these into a single `Game` struct would make reset logic and state inspection cleaner, and enable multi-state management like pause or high-score screens.

2. **Replace magic numbers with named constants**: Values such as planet HP (260), fire cooldown (0.14), shield arc span (40.0 degrees), and sector advancement period (30.0s) are scattered inline throughout the main loop. Extracting them as named `let` constants would improve readability and make tuning easier.

3. **Extract rendering into a separate file**: All drawing code currently lives inline in the main loop alongside logic. Separating it into a dedicated `render.mbt` with a `draw_frame` function would allow logic and rendering to evolve independently.

4. **Generalize enemy scaling formula**: `spawn_enemy` uses per-kind speed formulas (`110 + sector * 18`, `95 + sector * 16`, `78 + sector * 14`). Representing these as arrays of base speed and scale-per-sector per kind would make adding new enemy types trivial.

5. **Add a proper win condition**: The game currently sets `won = true` when sector reaches 11 (arbitrary) but there is no visual win state beyond a text message. Introducing a dedicated victory state with a score display and replay prompt would improve the player experience.

6. **Port angular math to use radians consistently**: `deg2rad` converts to radians for trig calls, but shield rotation is stored and updated in degrees. Keeping one canonical unit throughout would reduce conversion overhead and potential inconsistency.
