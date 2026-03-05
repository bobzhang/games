# Harbor Defense 2026

A side-scrolling harbor defense shooter where you control a cannon defending the waterfront against waves of enemy ships while protecting civilian boats.

## Build and Run

```bash
cd examples && moon build --target native harbor_defense_2026/
cd examples && ./_build/native/debug/build/harbor_defense_2026/harbor_defense_2026.exe
```

## Controls

- **A/D or Left/Right**: Move cannon along the harbor
- **Mouse**: Aim turret direction
- **Space or Left Click**: Fire projectile
- **B**: Launch bomb (area damage, cooldown)
- **F**: Activate shield (temporary protection, cooldown)
- **R**: Restart game

## How to Play

Defend the harbor from incoming enemy ships of varying types. Fire at enemies while avoiding civilian boats for bonus points. Manage your cannon's heat gauge -- overheating temporarily disables firing. Collect pickups that drop from destroyed enemies for repairs, cooldown resets, and score bonuses. Build combos by chaining kills. Survive through escalating waves with increasingly aggressive enemies.

## Public API Reference

### Package `harbor_defense_2026`

> Main entry point.

The `main` function initializes a 1280x760 window, creates all game object arrays pre-allocated to fixed capacities, defines a `reset_run` closure and an `on_harbor_hit` closure, then runs the frame loop that handles input, physics, collision, and rendering.

#### Types

| Type | Description |
|------|-------------|
| `Cannon` | Player-controlled harbor cannon with position, velocity, HP, heat gauge, cooldowns for fire/bomb/shield, overheat flag, score, kill count, and combo multiplier. |
| `EnemyShip` | Enemy vessel that descends from above; tracks activation, type (0-2), position, velocity, HP, fire cooldown, and elapsed time for phase-drift movement. |
| `CivilianBoat` | Friendly boat that crosses the harbor waterline; tracks activation, position, velocity, HP, point value, and panic timer. |
| `Projectile` | Active ballistic entity; stores position, velocity, damage, remaining lifetime, owner flag (enemy vs. player), and visual kind. |
| `Pickup` | Falling collectible dropped by destroyed enemies; stores position, downward velocity, type (repair/coolant/bomb-charge/intel), and elapsed time for blinking. |
| `Particle` | Short-lived visual spark; stores position, velocity, size, elapsed and total lifetime, and color kind. |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value to the inclusive `[lo, hi]` range. |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float. |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Returns the squared Euclidean distance between two points. |
| `randf` | `(Float, Float) -> Float` | Returns a random float uniformly sampled from `[lo, hi]`. |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests whether a float point lies inside an integer-defined rectangle. |
| `clear_enemies` | `(Array[EnemyShip]) -> Unit` | Deactivates and zeroes all enemy ship slots. |
| `clear_boats` | `(Array[CivilianBoat]) -> Unit` | Deactivates and zeroes all civilian boat slots. |
| `clear_projectiles` | `(Array[Projectile]) -> Unit` | Deactivates and zeroes all projectile slots. |
| `clear_pickups` | `(Array[Pickup]) -> Unit` | Deactivates and zeroes all pickup slots. |
| `clear_particles` | `(Array[Particle]) -> Unit` | Deactivates and zeroes all particle slots. |
| `spawn_enemy` | `(Array[EnemyShip], Int) -> Bool` | Finds a free slot, initialises a random enemy ship for the current wave, and returns whether spawning succeeded. |
| `spawn_boat` | `(Array[CivilianBoat]) -> Bool` | Finds a free slot and spawns a civilian boat entering from a random side. |
| `spawn_projectile` | `(Array[Projectile], Float, Float, Float, Float, Float, Bool, Int, Float) -> Bool` | Finds a free slot and initialises a projectile with the given position, velocity, damage, owner flag, kind, and lifetime. |
| `spawn_pickup` | `(Array[Pickup], Float, Float) -> Bool` | Finds a free slot and spawns a randomly-typed pickup near the given position. |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Emits `n` particles at the given position with random velocities scaled by `speed` and the specified `kind`. |
| `draw_enemy` | `(EnemyShip) -> Unit` | Draws an active enemy ship using layered rectangles; no-ops if inactive. |
| `draw_boat` | `(CivilianBoat) -> Unit` | Draws an active civilian boat with a panic tint when recently hit; no-ops if inactive. |
| `draw_cannon` | `(Cannon) -> Unit` | Draws the player cannon body, turret barrel, wheel, and shield ring when the shield is active. |
| `main` | `() -> Unit` | Entry point: initialises Raylib, allocates all arrays, runs the game loop, and closes the window on exit. |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width in pixels. |
| `sh` | `Int` | `760` | Screen height in pixels. |
| `world_w` | `Float` | `1280.0` | World width matching screen width. |
| `world_h` | `Float` | `760.0` | World height matching screen height. |
| `harbor_y` | `Float` | `632.0` | Y-coordinate of the harbor waterline. |
| `max_enemies` | `Int` | `120` | Maximum number of simultaneous enemy ships. |
| `max_boats` | `Int` | `42` | Maximum number of simultaneous civilian boats. |
| `max_projectiles` | `Int` | `520` | Maximum number of simultaneous projectiles. |
| `max_pickups` | `Int` | `92` | Maximum number of simultaneous pickups. |
| `max_particles` | `Int` | `980` | Maximum number of simultaneous particles. |

## Architecture

All game logic resides in `main.mbt`. Key design patterns:
- Fixed-capacity arrays for all entity types (enemies, boats, projectiles, pickups, particles) avoid heap allocation per frame; slots are reused via linear scan for an inactive entry.
- A local `reset_run` closure encapsulates full game state reset without needing a separate struct.
- A local `on_harbor_hit` closure centralises damage application, combo-breaking, and particle emission when the harbor battery is struck.
- Integer-encoded game states (title=0, playing=1, victory=2, game_over=3) drive a flat `if/else` dispatch in the main loop.
- Delta-time updates for frame-rate independence with a hard cap of 33 ms to prevent physics tunnelling.
- Wave scaling: `wave = kills / 10 + 1` drives enemy spawn rate, HP, speed, and shot velocity.
- Heat gauge on the cannon prevents indefinite rapid fire; overheating locks firing until heat cools below 36.
- Combo multiplier is incremented on each kill and reset on civilian hits or harbor damage, rewarding precise fire.

## Improvement & Refinement Plan

1. Extract the `reset_run` and `on_harbor_hit` closures into named top-level functions to improve readability and testability.
2. Replace the integer `state` variable with a dedicated `GameState` enum (Title, Playing, Victory, GameOver) to eliminate magic-number comparisons.
3. Split the monolithic `main` function into separate `update` and `draw` functions to enable headless unit tests for collision and spawn logic.
4. Add difficulty levels or an endless survival mode; currently the single 82-kill target ends the run with no further challenge.
5. Introduce a high-score persistence mechanism using Raylib's `save_storage_value`/`load_storage_value` so the best score survives between sessions.
6. Add audio cues (cannon fire, explosion, pickup collect) using Raylib's audio API to improve game feel.
7. Parameterise pickup drop probability (currently hard-coded at 23%) and pickup kinds so they can be tuned or expanded without changing logic code.
