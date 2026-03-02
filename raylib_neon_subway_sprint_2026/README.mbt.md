# Neon Subway Sprint 2026

A three-lane side-scrolling runner set in neon-lit subway tunnels across a cyberpunk city. The player controls a runner sprinting through underground subway tracks, dodging obstacles, jumping over barriers, dashing through breakable objects, and avoiding express trains that barrel through lanes with a blinking warning. Coins of varying value and three types of power-ups (med packs, batteries, and magnets) are scattered along the tracks.

The game is structured around a three-sector campaign. Each sector has a target score quota that must be reached before a countdown timer expires. Sector 1 requires 1,450 points in 92 seconds at 360 speed; Sector 2 requires 2,050 in 98 seconds at 430 speed; Sector 3 requires 2,800 in 104 seconds at 500 speed. Clearing all three sectors wins the run. The runner has 6 HP; obstacles deal 1 damage, trains deal 2 damage, and med pack power-ups restore 1 HP. A boost meter (starting at 100%) powers the dash ability, which destroys obstacles on contact for bonus points.

The single-file implementation uses object pools for obstacles (150), coins (220), power-ups (32), and particles (420), with a dedicated TrainEvent struct for the express train hazard system.

## Build and Run

```bash
moon build --target native raylib_neon_subway_sprint_2026/
./_build/native/debug/build/raylib_neon_subway_sprint_2026/raylib_neon_subway_sprint_2026.exe
```

## Controls

- **W / Up**: Switch to upper lane
- **S / Down**: Switch to lower lane
- **K / Space**: Jump (when grounded)
- **J / Left Shift**: Dash (costs 35 boost, 0.24s duration, destroys obstacles on contact)
- **R**: Restart from Sector 1
- **Touch**: On-screen UP/DN buttons (left side), JUMP and DASH buttons (right side)

## How to Play

1. **Lane switching**: Use W/S or Up/Down to move between the three horizontal lanes (top at y=490, middle at y=580, bottom at y=670). There is a 0.15s cooldown between lane switches.
2. **Jump**: Press K/Space to jump with velocity -470. Gravity pulls you back down at 980 units/s^2. Use this to clear low obstacles (kind 0: barrels with y_off=-4, and kind 3: carts with y_off=-6).
3. **Dash**: Press J/Shift when boost >= 35% to activate a 0.24s dash. During dash, colliding with obstacles destroys them for +55 points. Boost regenerates at 24/s and coins add 4-8 boost per pickup.
4. **Avoid trains**: An express train event triggers periodically. A "EXPRESS INBOUND" warning blinks on the targeted lane for 1.2-2.0 seconds. After the warning, the train rushes through at 760-920+ speed dealing 2 HP damage. Switch lanes immediately when you see the warning.
5. **Collect coins**: Coins appear in all lanes at varying heights. Value 1 coins give 14 points, value 2 give 28, value 3 give 42. Coins also add to the star counter and restore boost.
6. **Power-ups**: Med pack (kind 0, green cross) restores 1 HP; Battery (kind 1, blue rectangle) adds 42% boost; Magnet (kind 2, purple circle) activates an 8-second coin magnet that attracts nearby coins.
7. **Sector progression**: Reach the target score before time runs out to clear the sector. Clearing awards bonus stars based on remaining HP and timer. After a brief transition, the next sector begins with faster speed and tighter spawn timing.
8. **Obstacle types**: Kind 0 (barrel, 52x52, 1 HP), Kind 1 (pillar, 64x86, 2 HP -- needs two dashes), Kind 2 (floating orb, 46x34, moves faster than base speed, 1 HP), Kind 3 (cart, 70x30, 1 HP).
9. **Win/Lose**: Clear all 3 sectors to win. Lose if HP reaches 0 or time expires before quota.

## Public API Reference

### Package `raylib_neon_subway_sprint_2026`

> Main entry point and complete game implementation in a single file.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width |
| `sh` | `Int` | `820` | Screen height |
| `lane_n` | `Int` | `3` | Number of horizontal lanes |
| `max_obstacles` | `Int` | `150` | Maximum obstacle pool size |
| `max_coins` | `Int` | `220` | Maximum coin pool size |
| `max_powerups` | `Int` | `32` | Maximum power-up pool size |
| `max_particles` | `Int` | `420` | Maximum particle pool size |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Runner` | `x`, `y`, `lane`, `vy`, `hp`, `lane_cd`, `dash_t`, `invuln_t` | Player runner with lane position, jump physics, HP, and dash state |
| `Obstacle` | `x`, `lane`, `kind`, `w`, `h`, `y_off`, `hp`, `active` | Lane obstacle with 4 kinds (barrel/pillar/orb/cart) and destructible HP |
| `Coin` | `x`, `lane`, `y_off`, `value`, `active` | Collectible coin with value 1-3 |
| `Powerup` | `x`, `lane`, `kind`, `y_off`, `active` | Power-up with 3 kinds (medpack/battery/magnet) |
| `Particle` | `x`, `y`, `vx`, `vy`, `ttl`, `kind`, `active` | Visual particle with time-to-live |
| `TrainEvent` | `active`, `lane`, `x`, `warning_t`, `speed` | Express train event with warning countdown and high-speed movement |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between lo and hi |
| `absf` | `(Float) -> Float` | Returns absolute value of a float |
| `sqdist` | `(Float, Float, Float, Float) -> Float` | Squared distance between two points |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Point-in-rectangle test for touch UI |
| `lane_y` | `(Int) -> Float` | Returns the Y coordinate for a lane (0=490, 1=580, 2=670) |
| `clear_obstacles` | `(Array[Obstacle]) -> Unit` | Resets all obstacles to inactive |
| `clear_coins` | `(Array[Coin]) -> Unit` | Resets all coins to inactive |
| `clear_powerups` | `(Array[Powerup]) -> Unit` | Resets all power-ups to inactive |
| `clear_particles` | `(Array[Particle]) -> Unit` | Resets all particles to inactive |
| `reset_runner` | `(Runner) -> Unit` | Resets runner to lane 1 with full HP |
| `burst_particle` | `(Array[Particle], Float, Float, Float, Int) -> Unit` | Spawns a single particle with random velocity |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Spawns n particles in a burst pattern |
| `set_obstacle_shape` | `(Obstacle, Int) -> Unit` | Sets obstacle dimensions and HP based on kind |
| `spawn_obstacle` | `(Array[Obstacle], Int, Float) -> Unit` | Spawns a random obstacle in a random lane |
| `spawn_coin` | `(Array[Coin], Int, Float) -> Unit` | Spawns a coin with level-dependent value |
| `spawn_powerup` | `(Array[Powerup]) -> Unit` | Spawns a random power-up in a random lane |
| `spawn_train` | `(TrainEvent, Int) -> Unit` | Initiates an express train event with warning |
| `setup_level` | `(Int, Runner, Array[Obstacle], Array[Coin], Array[Powerup], Array[Particle], TrainEvent) -> (Int, Float, Float, Float)` | Resets all state for a sector and returns (target_score, timer, speed, spawn_factor) |
| `obstacle_hit_center_y` | `(Obstacle) -> Float` | Calculates the Y center of an obstacle for collision |
| `main` | `() -> Unit` | Entry point: initializes window, runs game loop with input, update, and render |

## Architecture

### Package Structure

```
raylib_neon_subway_sprint_2026/
├── main.mbt    — Complete game: types, constants, utilities, spawning, game loop, rendering
└── moon.pkg    — Package config with raylib and math imports
```

This is a single-file game. The code is organized top-to-bottom: constants, struct definitions, utility functions, pool management (clear/reset), entity spawning functions, the main function with game loop containing input handling, physics, collision detection, spawning logic, and rendering.

### Data Flow

1. **Input**: Each frame reads keyboard state (W/S for lanes, K/Space for jump, J/Shift for dash) and checks mouse clicks against on-screen button rectangles for touch controls.

2. **Update**: When not in game-over or transition state: timer counts down, cooldowns tick, lane switching applies, jump physics (gravity at 980, landing detection), dash activation (costs 35 boost), entity spawning on cooldowns (obstacles, coins, power-ups, trains), entity scrolling (obstacles move left at `speed`, floating orbs move faster), collision detection (runner vs obstacles with AABB, runner vs coins with distance check, runner vs train with zone check), power-up effects (HP heal, boost refill, magnet activation), stage completion check.

3. **Rendering**: Draws in order: pulsing sky background, parallax city buildings, three lane tracks with scrolling ties, train (warning blink or physical train), obstacles by kind, coins with value labels, power-ups by kind, particles, runner (triangle body with head, dash trail lines), HUD (title, sector, scores, HP/boost/progress bars), touch controls, message bar, sector clear overlay, game over overlay.

### Key Design Patterns

- **Object pool pattern**: Pre-allocated arrays with `active` flags for obstacles, coins, power-ups, and particles. Spawning scans for the first inactive slot.
- **Sector-based campaign**: Three fixed difficulty levels with tuned parameters (target score, timer, speed, spawn factor) returned as a tuple from `setup_level`.
- **Train event system**: A dedicated `TrainEvent` struct with a warning countdown phase before the train appears physically, creating a telegraph-then-hazard pattern.
- **Cooldown-based spawning**: Each entity type has its own spawn cooldown with random jitter, producing varied but controlled pacing.
- **Magnet mechanic**: When active, coins within 210 pixels are attracted toward the runner at 360 units/s, creating a satisfying vacuum collection effect.

## Improvement & Refinement Plan

1. **Replace obstacle kind integers with an enum**: Obstacle kinds 0-3 are used as magic numbers in `set_obstacle_shape`, `spawn_obstacle`, collision logic, and rendering. An `ObstacleKind` enum with `Barrel`, `Pillar`, `FloatingOrb`, `Cart` would clarify the code.

2. **Add combo system**: Unlike most runners, there is no combo mechanic. Adding a combo multiplier for consecutive coin pickups without taking damage would reward skillful play and add scoring depth.

3. **Extract rendering into a separate function**: The `main` function is over 1100 lines with rendering interleaved after game logic. Moving all drawing code to a dedicated `draw_game` function would improve readability.

4. **Add lane-switching animation**: Currently the runner teleports between lanes instantly. Lerping `runner.y` toward `lane_y(runner.lane)` over a few frames would create smoother visual movement.

5. **Scale difficulty within sectors**: Speed and spawn rates are fixed per sector. Adding gradual ramp within each sector (e.g., increasing speed by 0.5/s) would create a more dynamic difficulty curve.

6. **Add sound effects**: There are no audio cues. Adding sounds for coin collection, obstacle smash, train warning, jump, dash, and sector clear would significantly improve the experience.

7. **Persist high scores**: Total score and stars are lost on restart. Writing them to a file would provide session-to-session progression.

8. **Add invulnerability visual feedback**: The runner blinks during invulnerability but there is no clear indicator of remaining invuln time. A shrinking shield outline or timer display would help players gauge when they become vulnerable again.
