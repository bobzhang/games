# raylib_neon_air_hockey_2026

A neon-styled air hockey game for two players sharing one keyboard, with spark effects on puck collisions and goal scoring.

## Build and Run

```bash
cd examples && moon build --target native raylib_neon_air_hockey_2026/
cd examples && ./_build/native/debug/build/raylib_neon_air_hockey_2026/raylib_neon_air_hockey_2026.exe
```

## Controls

- **WASD**: Move left paddle (Player 1)
- **Space / J / K**: Strike puck (Player 1)
- **R**: Restart match

## How to Play

- Each player controls a paddle on their side of the table
- Hit the puck into the opponent's goal to score points
- The puck bounces off table walls and paddles with physics-based collisions
- Spark particles burst on contact for visual feedback
- First player to reach the score limit wins the match

## Public API Reference

### Package `raylib_neon_air_hockey_2026`

> Main entry point.

The `main` function initializes the window, creates the game state, and runs the frame loop.

#### Types

| Type | Description |
|------|-------------|
| `Spark` | Particle emitted on puck collisions; holds position, velocity, time-to-live, and active flag |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value to the inclusive `[lo, hi]` range |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests whether a point lies inside an axis-aligned rectangle |
| `table_left` | `() -> Float` | Returns the left edge X coordinate of the play table |
| `table_right` | `() -> Float` | Returns the right edge X coordinate of the play table |
| `table_top` | `() -> Float` | Returns the top edge Y coordinate of the play table |
| `table_bottom` | `() -> Float` | Returns the bottom edge Y coordinate of the play table |
| `goal_top` | `() -> Float` | Returns the top Y coordinate of the goal opening |
| `goal_bottom` | `() -> Float` | Returns the bottom Y coordinate of the goal opening |
| `clear_sparks` | `(Array[Spark]) -> Unit` | Deactivates all spark particles in the pool |
| `spawn_spark` | `(Array[Spark], Float, Float, Float, Int) -> Unit` | Activates one idle spark with randomized velocity and lifetime |
| `spawn_burst` | `(Array[Spark], Float, Float, Int, Float, Int) -> Unit` | Spawns `n` sparks at a position for collision feedback |
| `reset_round` | `() -> (Float, Float, Float, Float, Float, Float, Float, Float, Float)` | Returns initial positions and velocities for both paddles and the puck |
| `goal_opening` | `(Float) -> Bool` | Returns true when a Y coordinate falls within the goal slot |
| `paddle_hit` | `(Float, Float, Float, Float, Float) -> Bool` | Returns true when the puck overlaps a paddle |
| `main` | `() -> Unit` | Initializes the window, runs the game loop, and cleans up on exit |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width in pixels |
| `sh` | `Int` | `800` | Screen height in pixels |
| `table_x` | `Int` | `80` | Left edge of the table in screen coordinates |
| `table_y` | `Int` | `110` | Top edge of the table in screen coordinates |
| `table_w` | `Int` | `1120` | Width of the play table in pixels |
| `table_h` | `Int` | `620` | Height of the play table in pixels |
| `goal_h` | `Int` | `220` | Vertical height of each goal opening |
| `paddle_r` | `Float` | `34.0` | Radius of each paddle circle |
| `puck_r` | `Float` | `14.0` | Radius of the puck circle |
| `max_sparks` | `Int` | `180` | Maximum number of spark particles in the pool |

## Architecture

All game logic is in `main.mbt`. Key patterns:

- Single-file design: constants, helper functions, and the game loop all live in one file with no internal packages
- State machine via flags: `over`, `won`, and `faceoff_t` control which phase of the game is active (faceoff countdown, live play, or end screen)
- Physics model: puck velocity is deflected on paddle collisions using a relative-velocity impulse formula that incorporates paddle movement speed; friction reduces puck speed each frame
- AI paddle: the right paddle tracks the puck's predicted Y position and maintains a fixed X zone, with speed scaling per sector
- Sector progression: three sectors increase difficulty (AI speed, goal target) and award bonus score on sector clear
- Boost zone: a pulsing circular region alternates sides and slightly amplifies puck speed when the puck passes through it
- Touch overlay: on-screen directional buttons and a STRIKE button are drawn and tested each frame for mobile or pointer input
- Delta-time updates for frame-rate independence

## Improvement & Refinement Plan

1. Extract constants (`sw`, `sh`, `paddle_r`, etc.) into a dedicated constants block or module to avoid magic numbers scattered across the game loop
2. Introduce a proper state enum (`Faceoff`, `Live`, `StageClear`, `Over`) instead of multiple boolean flags to simplify branching
3. Replace the flat variable list inside `main` with a `GameState` struct so reset logic can be a single function call
4. Add two-player keyboard support (arrow keys for the right paddle) so the AI opponent becomes optional
5. Implement puck speed capping to prevent physics instability at high sector levels
6. Add audio cues (wall bounce, paddle hit, goal scored) using the raylib audio API for stronger game feel
7. Allow the boost zone to influence paddle AI strategy, making higher sectors genuinely harder rather than just faster
