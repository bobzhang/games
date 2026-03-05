# Snowboard Slalom

A downhill snowboard racing game where the rider descends a procedurally generated course of 66 slalom gates, dodging obstacles and collecting pickups while performing aerial tricks for bonus points. The rider automatically moves downhill at increasing speed, and the player steers left/right to thread gates, jump for tricks, and boost for bursts of speed.

The core loop combines gate threading, obstacle avoidance, and trick scoring. Passing through a gate within its width earns 120+ combo-scaled points and restores HP. Missing a gate costs 16 HP and resets the combo. Three obstacle types (rocks, trees, crates) deal varying damage. Three pickup types (medkit, energy, turbo cell) scattered near gates help sustain the run. The course is cleared by reaching the end; the run fails if HP reaches zero or the 240-second timer expires.

## Build and Run

```bash
moon build --target native snowboard_slalom_2026/
./_build/native/debug/build/snowboard_slalom_2026/snowboard_slalom_2026.exe
```

## Controls

- **A / Left Arrow**: Steer left
- **D / Right Arrow**: Steer right
- **J / Space**: Jump (costs 16 stamina, 0.58s airtime; steer during air for tricks)
- **K**: Boost (costs 24 stamina, 0.40s speed burst, 1.55s cooldown)
- **R**: Restart run (from result screen)
- **Enter**: Start game / return to menu (from result screen)
- **F11**: Toggle fullscreen
- **Touch controls**: LEFT/RIGHT pad (bottom-left), JUMP/BOOST buttons (bottom-right)

## How to Play

The rider descends automatically at a speed that increases with distance and wave number. Base speed starts around 226 units/s and scales up to 350+ with progression. Boost adds 220 units/s for 0.40 seconds.

**Steering**: A/D applies horizontal acceleration (760 on ground, 440 in air) with drag. Maximum horizontal speed is 280 normally, 390 while boosting. The rider is clamped to the world width (28 to 1252 pixels).

**Gates**: 66 gates are placed at random x positions with variable widths (180-248) along the course. If the rider passes a gate's y-coordinate within half the gate's width from center, it counts as a clean pass (green). Otherwise it is a miss (red). Clean gates: +120 + combo*8 points, +4 HP, +1 combo. Missed gates: -16 HP, combo reset to 0. Every 11 clean gates, the wave number increases, accelerating speed.

**Jumping and tricks**: Press J/Space to jump (requires 16+ stamina). During 0.58s of airtime, steering left/right accumulates trick time at 1.22x rate (faster with boost). On landing, if trick time exceeds 0.26s, trick points are awarded: `trick_t * 480 + combo * 7`. This rewards extended aerial steering.

**Obstacles**: 280 obstacles (rocks=circles, trees=triangles, crates=rectangles) are randomly scattered along the course. Collision with an obstacle deals 14-22 damage, applies a horizontal push, resets combo, and destroys the obstacle. Obstacles behind the rider are deactivated.

**Pickups**: Placed near every other gate. Medkit (kind 0, pink): +30 HP. Energy (kind 1, green): +30 stamina. Turbo cell (kind 2, blue): -0.6s boost cooldown + 38 points. All pickups also give +24 base points. Collected within 28 units distance.

**Stamina**: Regenerates at 21/s, capped at 100. Used for jumps (16) and boosts (24).

**Win**: Reach the course end (last gate y + 500). **Lose**: HP reaches 0 or timer (240s) expires.

## Public API Reference

### Package `snowboard_slalom_2026`

> Main entry point and sole package. Contains all types, game logic, rendering, and input handling in a single file.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width |
| `sh` | `Int` | `760` | Screen height |
| `world_w` | `Float` | `1280.0` | World horizontal extent |
| `rider_screen_y` | `Float` | `540.0` | Fixed screen y-position for the rider |
| `max_gates` | `Int` | `72` | Maximum gate pool size |
| `max_obstacles` | `Int` | `280` | Maximum obstacle pool size |
| `max_pickups` | `Int` | `120` | Maximum pickup pool size |
| `max_particles` | `Int` | `920` | Maximum particle pool size |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Rider` | `x`, `y`, `vx`, `hp`, `stamina`, `speed`, `air_t`, `trick_t`, `boost_t`, `boost_cd`, `flash_t`, `score`, `combo` | Player character with position, physics, resources, trick/boost state, and scoring |
| `Gate` | `active`, `x`, `y`, `w`, `state`, `pulse_t` | Slalom gate with position, width, pass/miss/pending state (0=pending, 1=clean, 2=missed) |
| `Obstacle` | `active`, `x`, `y`, `kind`, `size` | Course obstacle (kind 0=rock, 1=tree, 2=crate) with collision radius |
| `Pickup` | `active`, `x`, `y`, `kind`, `t` | Collectible item (kind 0=medkit, 1=energy, 2=turbo) with blink timer |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `size`, `t`, `life`, `kind` | Visual effect particle with type-based coloring |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between bounds |
| `absf` | `(Float) -> Float` | Returns absolute value of a float |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two points |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Point-in-rectangle test |
| `randf` | `(Float, Float) -> Float` | Random float in range |
| `clear_gates` | `(Array[Gate]) -> Unit` | Resets all gates to inactive |
| `clear_obstacles` | `(Array[Obstacle]) -> Unit` | Resets all obstacles to inactive |
| `clear_pickups` | `(Array[Pickup]) -> Unit` | Resets all pickups to inactive |
| `clear_particles` | `(Array[Particle]) -> Unit` | Resets all particles to inactive |
| `spawn_particle` | `(Array[Particle], Float, Float, Float, Int) -> Unit` | Creates a particle with random velocity |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Emits multiple particles at a position |
| `nearest_gate_y` | `(Array[Gate], Int, Float) -> Float` | Finds the y-distance to the nearest upcoming uncleared gate |
| `setup_course` | `(Array[Gate], Array[Obstacle], Array[Pickup]) -> (Int, Float)` | Generates the full course: 66 randomized gates, 280 obstacles, pickups near alternating gates. Returns (gate_count, course_end_y) |
| `main` | `() -> Unit` | Entry point: window init, rider/pool creation, closure-based reset, game loop with state machine (0=menu, 1=play, 2=win, 3=lose) |

## Architecture

### Package Structure

```
snowboard_slalom_2026/
├── main.mbt              -- All game code in a single file
└── moon.pkg              -- Package config with raylib and math imports
```

This is a single-file game where all types, constants, utility functions, course generation, simulation logic, input handling, and rendering coexist in `main.mbt`. The main function uses a closure-based `reset_game` for initialization and a monolithic game loop with an integer state machine.

### Data Flow

1. **Input**: Keyboard keys (A/D, J/Space, K) and touch regions are polled each frame. Touch LEFT/RIGHT pads use `inside_rect` with `touching` (hold) state. Touch JUMP/BOOST buttons use `pressed` (press) state.

2. **Simulation**: The rider's speed is computed from y-position, wave number, boost state, and HP level. Horizontal velocity is accelerated by steering input with separate acceleration and drag values for ground vs air. Gates are checked sequentially: when the rider's y passes a gate's y, distance from gate center determines clean/miss. Obstacles use axis-aligned proximity detection with destruction on hit. Pickups use squared-distance detection within 28 units.

3. **Tricks**: Jumping sets `air_t` to 0.58s. While airborne, steering accumulates `trick_t`. On landing, if `trick_t >= 0.26`, trick points are calculated and combo is incremented. This creates a risk/reward: steering during air scores tricks but may cause missed gates.

4. **Course generation**: `setup_course` creates 66 gates at random x positions with progressive y spacing (170-220 between gates). 280 obstacles are scattered randomly across the course. Pickups are placed near every other gate.

5. **Rendering**: Layers drawn in order: striped snow background with parallax ridges, gates with colored poles and banners, obstacles (circles/triangles/rectangles), pickups (blinking circles), particles, rider (board + body + boost indicators), HUD bar (score, combo, gates, time, HP bar, stamina bar, distance, next gate), touch controls, message bar, and state overlays (menu/win/lose panels).

### Key Design Patterns

- **Fixed camera at rider**: Camera y follows the rider with the rider pinned at `rider_screen_y` (540px), creating a natural downhill scrolling effect.
- **Closure-based reset**: `reset_game` captures all game state variables in a closure, allowing clean reinitalization without a formal game struct.
- **Progressive difficulty**: Speed increases with both distance (y-position) and wave number (incremented every 11 clean gates), creating dual-axis difficulty scaling.
- **Risk/reward trick system**: Jumping sacrifices steering control (reduced acceleration in air) but enables trick scoring, creating a moment-to-moment decision between safety and score.
- **Object pool pattern**: Gates, obstacles, pickups, and particles all use pre-allocated arrays with `active` flags, scanned linearly for rendering and collision.

## Improvement & Refinement Plan

1. **Extract game state into a struct**: All game state is stored in loose local variables within `main`. A `Game` struct would improve organization, enable methods, and eliminate the closure-based reset pattern.

2. **Replace integer state and kind with enums**: `state` (0-3), `gate.state` (0-2), `obstacle.kind` (0-2), `pickup.kind` (0-2), and `particle.kind` (0-3) all use integers. MoonBit enums would provide type safety and pattern matching.

3. **Add leaderboard persistence**: Scores are lost between sessions. Storing the top scores and displaying them on the title screen would add replay motivation.

4. **Implement course variety**: Currently all courses use the same generation parameters. Adding difficulty levels that vary gate width, obstacle density, course length, and time limit would extend content.

5. **Add wind mechanic**: A periodic crosswind that pushes the rider horizontally would create an additional challenge at higher waves and make steering more strategic.

6. **Improve trick system depth**: Currently tricks only require steering during air. Adding directional trick types (left spin vs right spin) with different point values and a trick chain mechanic would deepen the aerial gameplay.

7. **Separate rendering from game logic**: The monolithic game loop interleaves input, simulation, and rendering. Splitting into `update` and `draw` functions (or better, separate packages) would improve maintainability and testability.
