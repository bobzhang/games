# Asteroid Salvage 2026

Asteroid Salvage 2026 is a classic Asteroids-style arcade space shooter set in a deep-space salvage zone. The player pilots a triangular ship through a starfield, rotating, thrusting, and firing bullets to destroy drifting asteroids across increasingly difficult waves.

The core gameplay loop revolves around clearing each wave of asteroids: large rocks split into medium rocks, which split into small rocks, each awarding escalating point values (30, 60, and 120 points respectively). The screen wraps toroidally -- objects leaving one edge reappear on the opposite side. The player starts with 3 lives and must survive contact with asteroids; after a collision, the ship respawns at the center with a 2-second invulnerability window indicated by a blinking effect.

Technically, the game uses a pre-allocated object pool pattern for both bullets (max 80) and rocks (max 96), avoiding dynamic allocation during gameplay. Delta time is clamped to 50ms to prevent physics tunneling on frame drops, and velocity damping provides a satisfying drifting-in-space feel.

## Build and Run

```bash
moon build --target native raylib_asteroid_salvage_2026/
./_build/native/debug/build/raylib_asteroid_salvage_2026/raylib_asteroid_salvage_2026.exe
```

## Controls

- **Left Arrow / A**: Rotate ship counter-clockwise
- **Right Arrow / D**: Rotate ship clockwise
- **Up Arrow / W**: Thrust forward
- **Space / X**: Fire bullet
- **R**: Restart game (only when game over)

## How to Play

Rotate your ship with the arrow keys or A/D, and thrust forward with Up or W. Fire bullets with Space or X to destroy asteroids. Large asteroids (size 2, radius 34) split into two medium asteroids (size 1, radius 22) when hit, and medium asteroids split into two small asteroids (size 0, radius 13). Small asteroids are destroyed outright. Scoring is inversely proportional to asteroid size: large = 30, medium = 60, small = 120 points.

Each wave spawns (4 + wave number) large asteroids from random screen edges. Asteroids move faster as waves progress (base speed 30-95, increasing by 8 per wave). Clear all asteroids in a wave to advance to the next one.

Colliding with an asteroid costs one life. The ship respawns at the center of the screen with 2 seconds of invulnerability (shown by blinking). When all 3 lives are lost, the game displays "MISSION FAILED" and prompts for restart with the R key. There is a fire cooldown of 0.14 seconds between shots, and bullets have a time-to-live of 1.35 seconds.

## Public API Reference

### Package `raylib_asteroid_salvage_2026`

> Main entry point. Initializes the window, creates the game state, and runs the game loop.

No public types or functions are exported from this package.

### Package `raylib_asteroid_salvage_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Game` | `ship_x`, `ship_y`, `ship_vx`, `ship_vy`, `ship_angle`, `fire_cooldown`, `ship_invuln`, `thrusting`, `bullets`, `rocks`, `score`, `lives`, `wave`, `game_over` | Main game state container holding ship physics, entity pools, and game progression |
| `Bullet` | `active`, `x`, `y`, `vx`, `vy`, `ttl` | Projectile entity with position, velocity, and time-to-live |
| `Rock` | `active`, `x`, `y`, `vx`, `vy`, `radius`, `size` | Asteroid entity with position, velocity, collision radius, and size tier (0-2) |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_width` | `Int` | `960` | Window width in pixels |
| `screen_height` | `Int` | `640` | Window height in pixels |
| `pi` | `Float` | `3.141592653589793` | Mathematical constant pi |
| `bullet_max` | `Int` | `80` | Maximum number of bullets in the object pool |
| `rock_max` | `Int` | `96` | Maximum number of rocks in the object pool |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Bullet::new` | `() -> Bullet` | Creates a new inactive bullet with zeroed fields |
| `Rock::new` | `() -> Rock` | Creates a new inactive rock with zeroed fields |
| `Game::new` | `() -> Game` | Creates a new game instance with ship centered, 3 lives, wave 1, and pre-allocated entity pools |
| `random01` | `() -> Float` | Returns a random float in [0, 1] using raylib's RNG |
| `random_range` | `(Float, Float) -> Float` | Returns a random float in [min, max] |
| `wrap_x` | `(Float) -> Float` | Wraps an x-coordinate to stay within screen bounds (toroidal) |
| `wrap_y` | `(Float) -> Float` | Wraps a y-coordinate to stay within screen bounds (toroidal) |
| `length_sq` | `(Float, Float) -> Float` | Returns the squared length of a 2D vector (used for distance checks without sqrt) |
| `ship_reset` | `(Game) -> Unit` | Resets ship to screen center with zero velocity and 2s invulnerability |
| `clear_entities` | `(Game) -> Unit` | Deactivates all bullets and rocks in the entity pools |
| `spawn_rock` | `(Game, Int, Float, Float, Float, Float) -> Unit` | Spawns a rock of given size at position (x, y) with velocity (vx, vy) using the first available pool slot |
| `spawn_wave` | `(Game) -> Unit` | Spawns (4 + wave) large asteroids from random screen edges with random velocities |
| `reset_game` | `(Game) -> Unit` | Resets entire game state: score, lives, wave, entities, ship position, and spawns wave 1 |

### Package `raylib_asteroid_salvage_2026/internal/game`

> Game logic, input handling, and update systems.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main update entry point: handles game-over restart input, then delegates to ship, bullet, rock, and collision updates |

### Package `raylib_asteroid_salvage_2026/internal/render`

> Rendering and visual effects.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main rendering entry point: clears screen, draws starfield, rocks, bullets, ship, and HUD |

## Architecture

### Package Structure

```
raylib_asteroid_salvage_2026/
├── main.mbt              -- Entry point: window init, game loop with clamped delta time
├── moon.pkg              -- Package config, imports
└── internal/
    ├── types/
    │   ├── types.mbt     -- Game, Bullet, Rock structs and constructors
    │   ├── constants.mbt -- Screen dimensions, pool sizes, pi
    │   └── utils.mbt     -- RNG helpers, coordinate wrapping, entity spawning, game reset
    ├── game/
    │   ├── input.mbt     -- Ship rotation/thrust/fire input handling
    │   └── logic.mbt     -- Bullet/rock movement, collision detection, wave advancement
    └── render/
        └── render.mbt    -- Starfield, ship, rock, bullet, and HUD drawing
```

The project follows a clean three-package internal architecture: `types` owns all data definitions and utility functions, `game` handles input and state updates, and `render` handles all drawing. The main package simply wires them together in a standard init-loop-cleanup pattern.

### Data Flow

1. **Initialization**: `main` creates a `Game` via `Game::new()` and calls `reset_game()` to populate the initial wave.
2. **Input**: Each frame, `update_game` calls `update_ship`, which reads key states via `@raylib.is_key_down` for rotation (Left/Right/A/D), thrust (Up/W), and firing (Space/X). Fire input creates bullets through `fire_bullet`, which scans the bullet pool for an inactive slot.
3. **Physics**: `update_bullets` and `update_rocks` move entities by velocity * delta time, wrapping positions toroidally. Bullets decrement their `ttl` and deactivate when expired.
4. **Collision**: `bullet_vs_rocks` performs O(n*m) circle-circle collision between active bullets and rocks using squared-distance checks. Hits deactivate both entities and call `split_rock` to spawn children. `ship_vs_rocks` checks ship-rock collisions (ship radius = 11), deducting lives on hit.
5. **Wave progression**: `maybe_advance_wave` counts active rocks; if zero, it increments the wave counter and spawns a new wave.
6. **Rendering**: `draw_frame` clears the screen with a dark blue-black background, then layers starfield, rocks (circle outlines colored by size), bullets (small yellow circles), ship (triangle outline with optional thrust flame), and the HUD overlay.

### Key Design Patterns

- **Object pool pattern**: Both `bullets` (80 slots) and `rocks` (96 slots) are pre-allocated arrays. Spawning scans for the first `active == false` slot, avoiding heap allocation during gameplay.
- **Toroidal wrapping**: `wrap_x` and `wrap_y` implement screen-edge wrapping for all entities, creating the classic Asteroids infinite-space feel.
- **Clamped delta time**: `dt` is capped at 0.05s (50ms) in `main` to prevent physics tunneling when the frame rate drops.
- **Velocity damping**: Ship velocity is multiplied by `(1.0 - 0.35 * dt)` each frame, simulating gentle space drag and preventing infinite acceleration.
- **Invulnerability timer**: After losing a life, a 2-second `ship_invuln` countdown prevents immediate re-death, with a visual blink effect in the renderer.
- **Squared distance collision**: `length_sq` avoids expensive square root operations for circle-circle collision checks.

## Improvement & Refinement Plan

1. **Add particle effects for asteroid destruction**: The `split_rock` function in `logic.mbt` currently spawns child rocks silently. Adding a particle burst at `(hit_x, hit_y)` would provide satisfying visual feedback for each destruction.

2. **Implement screen-wrap ghost rendering for rocks**: `draw_rocks` in `render.mbt` only draws each rock once. When a large rock (radius 34) straddles a screen edge, it appears to pop in/out. Drawing ghost copies at wrapped positions would fix this visual artifact.

3. **Add sound effects**: The game is entirely silent. Adding audio for thrust (`game.thrusting`), firing (`fire_bullet`), rock destruction (`split_rock`), and ship death (`ship_vs_rocks` collision) would significantly improve game feel.

4. **Introduce extra lives at score milestones**: The `Game` struct in `types.mbt` tracks `score` and `lives` but never awards bonus lives. A check in `split_rock` or `update_game` could grant an extra life every 10,000 points.

5. **Improve starfield rendering**: `draw_starfield` uses a deterministic hash of loop index to position 70 fixed stars. A parallax scrolling starfield stored as data in the `Game` struct would add depth and visual polish.

6. **Add high score persistence**: The `game_over` state in `logic.mbt` simply waits for R to restart. Tracking and displaying a session-best or persistent high score would increase replayability.

7. **Refine asteroid splitting direction**: In `split_rock`, child rocks receive random velocities with only 20% inheritance from the parent (`rock.vx * 0.2`). Making children fly outward from the bullet impact direction would create more realistic physics.
