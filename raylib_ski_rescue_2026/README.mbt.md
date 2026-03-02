# Ski Rescue 2026

A lane-based downhill skiing game where the player navigates across five lanes to rescue stranded civilians while dodging trees and rocks. The game presents a simple but compelling risk-reward loop: civilians appear in the same lanes as obstacles, forcing the player to weave aggressively to maximize rescues while preserving their three lives.

The slope auto-scrolls downward at an ever-increasing speed (starting at 280 units/s, gaining 7 units/s per second). Four object types spawn every 0.27 seconds: trees (38% chance), rocks (25%), civilians to rescue (23%), and speed boost pickups (14%). Rescuing a civilian awards 120 points, speed boosts grant 45 points and a 3.2-second 45% speed multiplier, while hitting obstacles costs a life and 40 points. The game has a brief 1.1-second invulnerability window after each collision.

The visual style features a snowy mountain backdrop with faint lane guidelines forming an X-pattern across the slope. Trees are rendered as green triangles with brown trunks, rocks as dark gray circles, civilians as orange circles with exclamation marks, and boosts as lime circles with plus signs. Mountain peaks decorate the background behind the snow field.

## Build and Run

```bash
moon build --target native raylib_ski_rescue_2026/
./_build/native/debug/build/raylib_ski_rescue_2026/raylib_ski_rescue_2026.exe
```

## Controls

- **A / Left Arrow**: Move one lane to the left
- **D / Right Arrow**: Move one lane to the right
- **R**: Restart the game

## How to Play

Ski downhill across 5 evenly-spaced lanes (centered at x=180, 360, 540, 720, 900). You start in the middle lane (lane 2). Lane changes are instantaneous -- press once to shift one lane.

**Objects**: Four types scroll toward you from the top of the screen:
- **Trees** (green triangles): Collision costs 1 life and 40 points. 38% spawn rate.
- **Rocks** (gray circles): Collision costs 1 life and 40 points. 25% spawn rate.
- **Civilians** (orange circles with "!"): Rescue for 120 points. 23% spawn rate.
- **Speed boosts** (lime circles with "+"): Collect for 45 points and a 3.2-second 45% speed increase. 14% spawn rate.

**Collision**: Objects in your current lane that come within 36 pixels vertically trigger interaction. After hitting an obstacle, you get 1.1 seconds of invulnerability (shown by yellow player color).

**Scoring**: Distance traveled contributes roughly 0.12 points per pixel traveled. Civilians give 120 points, boosts give 45 points, and obstacles subtract 40 points.

**Speed**: Base speed starts at 280 units/s and increases by 7 units/s each second. During a speed boost, effective speed is multiplied by 1.45x.

**Lose condition**: All 3 lives are lost.

## Public API Reference

### Package `raylib_ski_rescue_2026`

> Main entry point and complete game implementation in a single file.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1080` | Screen width in pixels |
| `sh` | `Int` | `720` | Screen height in pixels |
| `lane_count` | `Int` | `5` | Number of ski lanes |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Obj` | `alive`, `x`, `y`, `lane`, `kind` | A slope object (tree, rock, civilian, or boost) |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `lane_x` | `(Int) -> Float` | Returns the center x-position for a given lane index (180 + lane * 180) |
| `reset_objs` | `(Array[Obj]) -> Unit` | Deactivates all objects in the pool |
| `spawn_obj` | `(Array[Obj], Int, Int) -> Unit` | Allocates an object in the pool at the given lane with the given kind |
| `main` | `() -> Unit` | Entry point: window init, game loop, input, physics, collision, rendering |

## Architecture

### Package Structure

```
raylib_ski_rescue_2026/
├── main.mbt              -- Complete game: entry point, types, logic, rendering
└── moon.pkg              -- Package config with raylib import
```

This is a single-file game with all logic, types, and rendering in `main.mbt`. Game state is managed through local mutable variables in the `main` function.

### Data Flow

1. **Input**: Lane changes are triggered by `is_key_pressed` (not held), ensuring one lane shift per keypress. The player's x-position is immediately set to `lane_x(player_lane)` after each lane change. Restart (R) resets all state.

2. **Object spawning**: Every 0.27 seconds, one object is spawned in a random lane from the pool of 150 pre-allocated `Obj` slots. The kind is chosen by a random roll: 0-37 = tree, 38-62 = rock, 63-85 = civilian, 86-99 = boost.

3. **Object movement**: All alive objects scroll downward at `run_speed * dt`, where `run_speed` is the base speed (possibly boosted by 1.45x). Objects are deactivated when they pass below the screen (y > sh + 60).

4. **Collision**: Only objects in the same lane as the player are checked. If `|obj.y - player_y| < 36`, the object interacts with the player based on its kind: obstacles (0, 1) subtract a life and 40 points unless invulnerable; civilians (2) add 120 points and increment the rescue counter; boosts (3) start a 3.2-second speed boost and add 45 points.

5. **Rendering**: Background is a light blue snow field. Two mountain triangles are drawn behind the slope. Lane guidelines form X-patterns. Objects are rendered by kind. The player is a red circle (yellow during invulnerability) with blue ski rectangles below. HUD shows title, score, rescue count, distance, lives, and boost status.

### Key Design Patterns

- **Object pool pattern**: 150 pre-allocated `Obj` slots with `alive` flags. `spawn_obj` scans for the first inactive slot.
- **Lane-based movement**: Rather than free horizontal movement, the player snaps to discrete lane positions (multiples of 180 pixels), simplifying collision to a single-lane check.
- **Invulnerability frames**: A 1.1-second `invuln_timer` prevents chain damage from multiple obstacles, giving the player time to recover after each hit.
- **Single-file architecture**: All game code in one file with no packages, using local mutable variables for state.
- **Delta-time clamped updates**: Frame time is capped at 0.05s to prevent physics issues on lag spikes.

## Improvement & Refinement Plan

1. **Extract a Game struct**: All state is spread across local `mut` variables in `main`. Grouping them into a `Game` struct would improve organization and make it possible to pass state to helper functions.

2. **Add lane transition animation**: Currently, lane changes are instant teleportation. Adding a short interpolation between lanes (lerp over 0.1s) would make movement feel smoother and help players track their position during rapid lane switches.

3. **Implement difficulty tiers**: Speed increases linearly forever. Introducing named difficulty zones (e.g., "Green slope" at 280 speed, "Blue slope" at 400, "Black diamond" at 550) with different obstacle densities and spawn rates would give players clear progression milestones.

4. **Add civilian rescue streak bonus**: Consecutive civilian rescues without hitting obstacles could multiply the 120-point reward (e.g., x2 for 3 in a row, x3 for 5). This would reward skilled play and add strategic depth to lane choices.

5. **Create visual snow particle effects**: The snowy setting lacks particle effects. Adding falling snowflakes and spray particles when the skier moves between lanes would enhance the atmosphere significantly.

6. **Add multiple object spawns per interval**: Currently only one object spawns every 0.27 seconds. At higher speeds, spawning 2-3 objects simultaneously in different lanes would create more interesting dodge patterns and force the player to plan ahead.

7. **Implement a high score system**: The game tracks score but has no persistence or high score display. Showing the best score on the game-over screen and title screen would motivate repeat play.
