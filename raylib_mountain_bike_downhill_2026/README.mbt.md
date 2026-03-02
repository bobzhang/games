# Mountain Bike Downhill 2026

A top-down scrolling downhill mountain biking game where you race through 68 procedurally-placed checkpoints across a lengthy course, dodging four types of terrain hazards, collecting pickups, and performing aerial tricks for combo points. The game features stamina management, a boost mechanic, and a tier progression system that increases base speed every 10 clean checkpoints.

The core gameplay loop has the rider automatically scrolling downhill at increasing speed while the player steers left/right, pedals to accelerate (draining stamina), brakes to slow down (recovering stamina), and uses jump and boost abilities to avoid hazards and score trick points. Checkpoints must be threaded through -- passing within the gate width earns clean credit and heals HP, while missing a checkpoint costs 16 HP and resets the combo counter. A 248-second timer adds urgency, and the run ends either at course end (success), HP depletion, or time expiration (failure).

The game supports both keyboard and touch input with an on-screen D-pad for steering/pedal/brake and circular buttons for jump and boost. Visual feedback includes particle bursts on tricks, crashes, and pickups, plus a flashing rider sprite on damage.

## Build and Run

```bash
moon build --target native raylib_mountain_bike_downhill_2026/
./_build/native/debug/build/raylib_mountain_bike_downhill_2026/raylib_mountain_bike_downhill_2026.exe
```

## Controls

- **A/D or Left/Right**: Steer left/right
- **W or Up**: Pedal (accelerate, drains stamina at 18/s)
- **S or Down**: Brake (decelerate, recovers stamina at 8/s)
- **J or Space**: Jump (bunny hop, costs 18 stamina, 0.62s air time)
- **K**: Boost (speed burst for 0.42s, costs 24 stamina, 1.5s cooldown)
- **Enter**: Start game / return to menu after run
- **R**: Restart run after win/loss
- **F11**: Toggle fullscreen

## How to Play

Press Enter on the title screen to begin a run. The rider automatically scrolls downhill; use steering to navigate through checkpoint gates (colored banners between two poles). Clean checkpoints (passing within the gate width) earn 128 + combo * 8 points and heal 4 HP. Missing a checkpoint costs 16 HP and resets your combo.

**Tricks**: Jump with J/Space, then steer left or right while airborne to build trick time. Landing with 0.24+ seconds of trick time awards trick_t * 520 + combo * 7 points and extends your combo. Boosting while airborne increases trick accumulation rate by 0.7/s.

**Pickups**: Three types scattered near checkpoints -- red repair kits (+28 HP), green energy drinks (+30 stamina), and blue coins (+52 score, reduces boost cooldown by 0.65s). All pickups also grant 24 base score.

**Hazards**: Four types scattered across the course -- rocks (round, gray, 14 dmg), trees (triangular, green, 22 dmg), crates (square, brown, 14 dmg), and puddles (round, blue, 18 dmg). Hitting a hazard damages HP, pushes the rider sideways, and resets combo.

**Progression**: Every 10 clean checkpoints increases the tier, adding 11 speed units to the base speed. Speed also increases naturally as the rider progresses further down the course.

**Win/Loss**: Reaching course end = success. HP reaching 0 or timer expiring = failure. Results show final score, clean checkpoints, misses, and coins.

## Public API Reference

### Package `raylib_mountain_bike_downhill_2026`

> Complete single-file game with all structs, logic, rendering, and entry point.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` / `sh` | `Int` | `1280` / `760` | Window dimensions |
| `world_w` | `Float` | `1280.0` | World width for hazard/pickup placement |
| `rider_screen_y` | `Float` | `538.0` | Fixed screen Y position of the rider |
| `max_checkpoints` | `Int` | `80` | Pool size for checkpoints |
| `max_hazards` | `Int` | `320` | Pool size for hazards |
| `max_pickups` | `Int` | `140` | Pool size for pickups |
| `max_particles` | `Int` | `980` | Pool size for particles |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Rider` | `x`, `y`, `vx`, `hp`, `stamina`, `speed`, `air_t`, `trick_t`, `boost_t`, `score`, `combo`, `coins` | Player rider with position, velocity, resources, and scoring state |
| `Checkpoint` | `active`, `x`, `y`, `width`, `state`, `pulse_t` | Gate checkpoint (state: 0=pending, 1=clean, 2=missed) |
| `Hazard` | `active`, `x`, `y`, `kind`, `size` | Terrain obstacle (kind: 0=rock, 1=tree, 2=crate, 3=puddle) |
| `Pickup` | `active`, `x`, `y`, `kind`, `t` | Collectible item (kind: 0=repair, 1=energy, 2=coin) |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `size`, `t`, `life`, `kind` | Visual particle with velocity, lifetime, and color type |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to [lo, hi] range |
| `absf` | `(Float) -> Float` | Returns absolute value of a float |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Returns squared distance between two points |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside an integer rectangle |
| `randf` | `(Float, Float) -> Float` | Returns a random float in [lo, hi] |
| `world_to_screen_y` | `(Float, Float) -> Float` | Converts world Y coordinate to screen Y relative to rider |
| `clear_checkpoints` | `(Array[Checkpoint]) -> Unit` | Deactivates and zeroes all checkpoints |
| `clear_hazards` | `(Array[Hazard]) -> Unit` | Deactivates and zeroes all hazards |
| `clear_pickups` | `(Array[Pickup]) -> Unit` | Deactivates and zeroes all pickups |
| `clear_particles` | `(Array[Particle]) -> Unit` | Deactivates and zeroes all particles |
| `spawn_particle` | `(Array[Particle], Float, Float, Float, Int) -> Unit` | Activates one inactive particle with random velocity |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Emits N particles at a position |
| `nearest_checkpoint_dy` | `(Array[Checkpoint], Int, Float) -> Float` | Returns distance to the nearest upcoming uncleared checkpoint |
| `generate_course` | `(Array[Checkpoint], Array[Hazard], Array[Pickup]) -> (Int, Float)` | Generates 68 checkpoints, all hazards, and pickups; returns (count, course_end_y) |
| `main` | `() -> Unit` | Entry point: initializes window, creates pools, runs game loop with input/update/render |

## Architecture

### Package Structure

```
raylib_mountain_bike_downhill_2026/
├── main.mbt              — Complete game: structs, course generation, logic, rendering (~1367 lines)
└── moon.pkg              — Package config with raylib and math imports
```

This is a single-file game. All struct definitions, procedural course generation, physics, collision detection, input handling, and rendering are in `main.mbt`.

### Data Flow

1. **Course Generation**: `generate_course` places 68 checkpoints at increasing Y positions with random X and width, fills all 320 hazard slots with random positions/types, and places pickups near every other checkpoint.
2. **Input**: Keyboard and touch D-pad inputs are merged via boolean OR. Touch hit testing uses `inside_rect` for the on-screen buttons.
3. **Physics**: The rider scrolls downhill at `speed` pixels/second (computed from base + pedal + boost + tier bonuses). Horizontal steering applies acceleration with drag. Jump sets `air_t` to 0.62s, during which steering builds `trick_t`.
4. **Collision**: Checkpoints check if `rider.y >= checkpoint.y` and `|rider.x - checkpoint.x| <= width/2`. Hazards use axis-aligned box overlap. Pickups use squared distance.
5. **Camera**: `world_to_screen_y` converts world coordinates to screen space by subtracting rider Y and adding the fixed `rider_screen_y` offset.
6. **Rendering**: Layered: striped ground -> vertical ridge lines -> checkpoints (poles + banner) -> hazards -> pickups -> particles -> rider -> HUD bars/text -> touch controls -> message bar -> state overlays.

### Key Design Patterns

- **Vertical scrolling with fixed rider position**: The rider stays at a fixed screen Y (`rider_screen_y = 538`), and all world objects are drawn relative to the rider's world Y position via `world_to_screen_y`.
- **Procedural course generation**: `generate_course` creates a complete course layout on each run with randomized checkpoint positions, hazard placements, and pickup distributions.
- **Tier-based difficulty scaling**: Every 10 clean checkpoints increases tier, which adds to base speed. Speed also naturally increases based on distance traveled (`rider.y / course_end * 128`).
- **Object pools**: Pre-allocated arrays for checkpoints (80), hazards (320), pickups (140), and particles (980) with `active` flags.
- **Trick combo system**: Air time + steering builds `trick_t`, which converts to score on landing with a minimum threshold of 0.24s.
- **Closure-based reset**: The `reset_run` closure captures all mutable game state for clean restarts.

## Improvement & Refinement Plan

1. **Extract game state into a struct**: The game uses 8+ mutable local variables (`state`, `time_left`, `clean_count`, `miss_count`, `tier`, etc.) in the `main` function. Grouping them with the `Rider` into a `Game` struct would reduce closure capture complexity.
2. **Use enums for state and hazard/pickup kinds**: `state` (0-3), `Hazard.kind` (0-3), `Pickup.kind` (0-2), and `Checkpoint.state` (0-2) are all raw integers. Enums would provide type safety and self-documenting code.
3. **Add parallax background layers**: The current background is flat striped. Adding mountain silhouettes at different scroll rates would create depth and improve the downhill feel.
4. **Implement hazard avoidance during air time**: Jumping currently has no immunity effect -- the rider can still collide with hazards while airborne. Adding partial or full invincibility during `air_t > 0` would make the jump mechanic more strategic.
5. **Scale hazard density with tier**: All 320 hazards are placed at course generation time with uniform distribution. Increasing density in later sections as tier increases would create a natural difficulty curve.
6. **Add high score persistence**: There is no score tracking between sessions. Saving the best score and displaying it on the title screen would add replay motivation.
7. **Improve checkpoint miss detection**: Currently, a checkpoint is marked missed the instant `rider.y >= checkpoint.y` if not within width. Adding a small grace zone (e.g., 40px past) would feel fairer.
