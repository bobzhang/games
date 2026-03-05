# Lunar Lander Ops 2026

A classic lunar lander physics game where you pilot a spacecraft through gravity to land softly on designated pads across procedural terrain, while coping with wind and meteor hazards.

## Build and Run

```bash
cd examples && moon build --target native lunar_lander_ops_2026/
cd examples && ./_build/native/debug/build/lunar_lander_ops_2026/lunar_lander_ops_2026.exe
```

## Controls

- **A/D or Left/Right**: Rotate the lander
- **W or Up**: Fire main thruster (costs fuel)
- **R**: Restart from level 1

## How to Play

Guide your lander down to the highlighted landing pad on the lunar surface. Gravity pulls you down constantly -- use thrust to slow your descent, but fuel is limited. Wind pushes the craft sideways and shifts over time. Meteors rain from above in later levels. You must touch down on the pad with low enough velocity to land safely. Each of the 4 levels features different terrain, pad placement, and wind conditions. Crashing costs a life; run out of lives and the mission ends.

## Public API Reference

### Package `lunar_lander_ops_2026`

> Main entry point and single-file game implementation.

The `main` function initializes a 1280x820 window, allocates a `heights` terrain array and a `meteors` pool, calls `set_level` to configure level 1, and runs the full game loop as local mutable state. Physics, input, rendering, and state transitions are all inlined in the loop body.

#### Types

| Type | Description |
|------|-------------|
| `Meteor` | Active meteor with position (`x`, `y`), downward velocity (`vy`), and an `active` pooling flag. |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `absf` | `(Float) -> Float` | Returns the absolute value of `x`. |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps `v` to `[lo, hi]`. |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside a rectangle for touch input. |
| `deg2rad` | `(Float) -> Double` | Converts degrees to radians. |
| `sinf_deg` | `(Float) -> Float` | Computes the sine of an angle given in degrees. |
| `cosf_deg` | `(Float) -> Float` | Computes the cosine of an angle given in degrees. |
| `sinf` | `(Float) -> Float` | Computes the sine of an angle in radians. |
| `set_height` | `(Array[Float], Int, Float) -> Unit` | Sets a terrain height sample at index `i`. |
| `sample_height` | `(Array[Float], Float) -> Float` | Returns the interpolated terrain height at horizontal position `x`. |
| `clear_meteors` | `(Array[Meteor]) -> Unit` | Deactivates all meteors in the pool. |
| `spawn_meteor` | `(Array[Meteor], Int) -> Unit` | Activates an inactive meteor at a random x with level-scaled downward speed. |
| `set_level` | `(Int, Array[Float]) -> (Float, Float, Float, Float, Float, Float)` | Configures terrain for the given level (1–4) and returns spawn x/y, pad x/width/y, and base wind. |
| `main` | `() -> Unit` | Entry point: initializes window, runs the full game loop with physics, input, rendering. |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width in pixels. |
| `sh` | `Int` | `820` | Screen height in pixels. |
| `points` | `Int` | `17` | Number of terrain height sample points. |
| `max_meteors` | `Int` | `24` | Meteor pool size. |

## Architecture

All game logic is in `main.mbt`. Key patterns:
- **State machine**: Two boolean variables (`over`, `won`) and a `respawn_t` timer manage game state transitions (playing, respawning, game over, mission complete) without an explicit enum.
- **Main data structures**: The lander is represented purely as local mutable scalar variables (`x`, `y`, `vx`, `vy`, `angle`, `fuel`) in the main loop. The `heights` array stores the piecewise-linear terrain. The `meteors` array pool stores active meteor objects.
- **Physics model**: Each frame applies wind-scaled horizontal acceleration and gravity vertically. Thrust adds sinf/cosf-projected acceleration in the lander's facing direction. Velocity is then integrated to position. Boundaries bounce with damping.
- **Landing detection**: On ground contact, the game checks whether the lander is over the pad and whether `|vx| <= 34`, `|vy| <= 46`, and `|angle| <= 12` simultaneously. Failure costs a life; success awards a fuel bonus and advances the level.
- **Delta-time updates**: All physics are scaled by `dt`, capped at 50 ms to prevent simulation explosions on frame drops.

## Improvement & Refinement Plan

1. **Replace scalar lander state with a struct**: The lander's position, velocity, angle, and fuel are currently five separate mutable variables in `main`. Grouping them into a `Lander` struct would improve readability and make it easier to add features like multiple landers or replay recording.

2. **Add a wind arrow indicator**: Wind is shown as a numeric value in the HUD but has no visual direction indicator. A simple arrow on screen pointing in the wind direction with length proportional to strength would give the player more intuitive feedback.

3. **Implement a fuel warning flash**: The fuel bar changes color but there is no screen-level feedback when fuel runs critically low. Adding a pulsing border tint when fuel drops below 15% would improve urgency communication.

4. **Add more terrain variety**: All four levels use piecewise-linear terrain with the same 17 sample points. Introducing overhanging rocks, tunnels, or craters would create distinct visual identities per level.

5. **Persist high score across sessions**: The score is tracked within a run but lost on exit. Writing it to a local file would give players a long-term goal.

6. **Add meteor warning indicators**: Meteors appear silently from above. Adding a brief on-screen flash or warning icon at the meteor's x-coordinate before it enters the screen would give players a chance to react.

7. **Extract level definitions to data structures**: Currently `set_level` contains four large if/else blocks with hardcoded terrain arrays and constants. Representing each level as an array of height values and parameters would make adding new levels straightforward.
