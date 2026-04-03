# Arcade Hacker Infiltration 2026

A grid-based stealth game where you infiltrate a facility as a hacker, avoiding guards and cameras while hacking terminals and collecting pickups.

## Build and Run

```bash
moon build --target native arcade_hacker_infiltration_2026/
./_build/native/debug/build/arcade_hacker_infiltration_2026/arcade_hacker_infiltration_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move on the grid (tile-by-tile)
- **Space**: Hack nearby terminal
- **J**: EMP pulse (stuns guards and disables cameras)
- **K**: Activate cloak (temporary invisibility)
- **R**: Restart

## How to Play

Navigate a tile-based facility map, hacking terminals while avoiding patrolling guards and rotating cameras. Use cloak to slip past enemies and EMP to stun them. Collect energy and health pickups scattered around the map. Build hack combos for bonus points. Clear all terminals to complete the level.

## Public API Reference

### Package `arcade_hacker_infiltration_2026`
> Single-package game. All structs, constants, helpers, and the main game loop live in `main.mbt`. There are no exported symbols; everything is package-private or file-scoped.

#### Constants
| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Window width in pixels |
| `sh` | `Int` | `760` | Window height in pixels |
| `map_w` | `Int` | `22` | Tile map width in cells |
| `map_h` | `Int` | `13` | Tile map height in cells |
| `tile` | `Int` | `48` | Tile size in pixels |
| `map_x` | `Int` | `112` | Pixel x-offset of the map's top-left corner |
| `map_y` | `Int` | `72` | Pixel y-offset of the map's top-left corner |
| `max_terminals` | `Int` | `20` | Object pool capacity for terminals |
| `max_guards` | `Int` | `64` | Object pool capacity for guards |
| `max_cameras` | `Int` | `30` | Object pool capacity for cameras |
| `max_pickups` | `Int` | `30` | Object pool capacity for pickups |
| `max_particles` | `Int` | `960` | Object pool capacity for particles |

#### Structs
| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Player` | `gx, gy, hp, energy, hack_cd, emp_cd, cloak_cd, cloak_t, hurt_cd, face_x, face_y, score, combo, hacked_total` | Complete player state including grid position, resource bars, ability cooldowns, facing direction, and scoring |
| `Terminal` | `active, gx, gy, hacked` | Data terminal that the player must hack; toggled by `hacked` flag on success |
| `Guard` | `active, kind, gx, gy, hp, move_cd, atk_cd, stun_t, alert_t, patrol_dir` | Enemy guard with kind-based behaviour (0=patrol, 1=heavy, 2=drone), stun and alert timers |
| `Camera` | `active, gx, gy, dir, rot_t, disable_t` | Rotating security camera; `dir` is 0-3 (up/right/down/left), disabled by EMP |
| `Pickup` | `active, gx, gy, kind` | Collectible item on a grid cell; kind 0-3 map to energy, health, and bonus variants |
| `Particle` | `active, x, y, vx, vy, size, t, life, kind` | Short-lived visual effect particle with velocity, lifetime, and colour kind |

#### Functions
| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Entry point: initialises the window, allocates all object pools, runs the monolithic game loop covering input, AI, physics, rendering, and state transitions |
| `idx` | `(Int, Int) -> Int` | Converts grid coordinates to a flat tile-array index |
| `in_bounds` | `(Int, Int) -> Bool` | Returns whether a grid cell is inside the map |
| `can_walk` | `(Array[Int], Int, Int) -> Bool` | Returns true when a cell is in bounds and not a wall tile |
| `cell_center_x` | `(Int) -> Float` | Returns the pixel x-centre of a grid column |
| `cell_center_y` | `(Int) -> Float` | Returns the pixel y-centre of a grid row |
| `line_clear` | `(Array[Int], Int, Int, Int, Int) -> Bool` | Axis-aligned line-of-sight test with no wall tiles between two cells |
| `visible_line` | `(Array[Int], Int, Int, Int, Int, Int) -> Bool` | Line-of-sight within a maximum tile distance |
| `camera_facing` | `(Camera, Int, Int) -> Bool` | Returns true when a target cell lies in the camera's current facing direction |
| `guard_at` | `(Array[Guard], Int, Int) -> Int` | Returns the index of the active guard occupying a cell, or -1 |
| `terminal_at` | `(Array[Terminal], Int, Int) -> Int` | Returns the index of an unhacked active terminal at a cell, or -1 |
| `pickup_at` | `(Array[Pickup], Int, Int) -> Int` | Returns the index of an active pickup at a cell, or -1 |
| `camera_at` | `(Array[Camera], Int, Int) -> Int` | Returns the index of an active camera at a cell, or -1 |
| `spawn_guard` | `(Array[Guard], Int, Int, Int, Int) -> Bool` | Activates a slot from the guard pool at the given cell with stage-scaled HP |
| `spawn_pickup` | `(Array[Pickup], Int, Int, Int) -> Bool` | Activates a slot from the pickup pool at the given cell |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Spawns n particles at a position with random velocities and a colour kind |
| `draw_guard` | `(Guard) -> Unit` | Renders a guard with kind-coloured body and stun/alert indicators |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer to an inclusive range |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to an inclusive range |
| `absi` | `(Int) -> Int` | Absolute value of an integer |
| `randf` | `(Float, Float) -> Float` | Uniform random float in [lo, hi] |

## Architecture

### Package Structure
```
arcade_hacker_infiltration_2026/
└── main.mbt              — all constants, structs, helper functions, and the complete game loop
```

### Data Flow
1. `main` allocates flat arrays for every object pool (terminals, guards, cameras, pickups, particles) and a tile array for the map.
2. `setup_stage` procedurally generates wall partitions with random gates, then scatters terminals, cameras, guards, and pickups by random cell sampling via `cell_free_for_spawn`.
3. Each frame the game loop polls raylib for input, updates timers (cooldowns, move repeat, alarm, mission time), runs guard AI (patrol, alert on line-of-sight, hunt towards player), rotates cameras, checks camera/guard detection against the player, and applies EMP/cloak/hack actions.
4. Collision and interaction results mutate the shared arrays in-place; defeated guards and consumed pickups are deactivated (pool slots returned).
5. The render pass iterates every pool and draws active elements directly with raylib primitives; no intermediate scene graph is constructed.

### Key Design Patterns
- **Flat object pools**: All entity arrays are pre-allocated at startup with fixed capacity. Entities are activated/deactivated in-place rather than heap-allocated per frame, avoiding GC pressure.
- **Grid-based movement**: The player moves one tile at a time with a repeat-delay, making all collision and line-of-sight checks simple integer comparisons rather than continuous physics.
- **Monolithic game loop**: All logic (input, AI, physics, rendering) runs in a single `fn main` loop. State is held in local variables and mutable struct fields; there are no separate update/draw function boundaries.
- **Line-of-sight via axis alignment**: `line_clear` only tests straight horizontal or vertical corridors, matching the tile-grid movement model and keeping detection checks O(n) in map dimension.
- **Stage progression**: Difficulty scales by incrementing `stage` (1–4), which increases terminal count (3+stage), camera count (3+stage*2), guard count (5+stage*3), and guard HP via `spawn_guard`.
- **Combo scoring**: Both hacking terminals and defeating guards increment `player.combo`, which multiplies score bonuses and resets on taking damage, rewarding efficient play.

## Improvement & Refinement Plan

- **Separate update and render phases**: Extract guard AI, player input, and particle simulation from `fn main` into dedicated top-level functions (e.g., `update_guards`, `update_player`, `draw_scene`). This would make each subsystem independently testable and easier to extend without navigating a 1000+ line loop.
- **Expand guard AI states**: Guards currently switch between patrol and alert/hunt. Adding a `search` state where alerted guards sweep the last-known player position before returning to patrol would create more dynamic and believable behaviour without requiring pathfinding.
- **Drone guard differentiation**: Guard `kind == 2` (drone) shares movement logic with other guards. Giving drones a distinct pattern, such as flying over walls (`can_walk` bypass) or a wider camera-like cone of vision, would make each guard type feel mechanically distinct.
- **Procedural map variety**: `setup_stage` places walls only at fixed x/y columns. Introducing room-based generation (e.g., a BSP split or prefab room stencils) would produce maps with corridors, dead ends, and chokepoints that better reward stealth routing.
- **Persistent best score across sessions**: `player.score` is reset by `reset_run`. Storing the all-time high score in a file or platform save slot would give players a long-term goal across multiple runs.
- **Audio feedback**: The game has no sound calls. Adding distinct audio cues for hack success, EMP activation, guard alert, and camera detection would significantly improve moment-to-moment game feel with minimal code change.
- **Pickup kind diversity**: Pickup kinds 0–3 are assigned randomly without labels. Defining named constants (e.g., `pickup_energy`, `pickup_health`, `pickup_emp_charge`, `pickup_cloak_charge`) and rendering distinct icons per kind would make pickups legible without the player needing to collect them first.
