# neon_air_hockey_2026

A neon-styled player-vs-AI air hockey game with generated table art, sprite-backed paddles, spark effects on puck collisions, sector progression, and goal scoring.

## Build and Run

```bash
cd examples && moon build --target native neon_air_hockey_2026/
cd examples && ./_build/native/debug/build/neon_air_hockey_2026/neon_air_hockey_2026.exe
```

## Controls

- **WASD**: Move the player paddle
- **Space / J / K**: Power strike
- **R**: Restart match
- **Touch controls**: On-screen movement buttons and STRIKE button

## How to Play

- You control the cyan left paddle; the AI controls the red right paddle
- Hit the puck into the AI goal to score points
- The puck bounces off table walls and paddles with physics-based collisions
- A pulsing boost zone alternates sides and accelerates the puck when crossed
- Clear three sectors with increasing target scores and AI speed to win
- Spark particles burst on contact for visual feedback
- If the AI reaches a sector target first, the match ends in defeat

## Public API Reference

### Package `neon_air_hockey_2026`

> Main entry point.

The `main` function initializes the window, loads generated air hockey art, creates the game state, and runs the frame loop.

#### Types

| Type | Description |
|------|-------------|
| `GameArt` | Generated Raylib textures for the table surface and entity sprite sheet |
| `Spark` | Particle emitted on puck collisions; holds position, velocity, time-to-live, and active flag |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
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
| `load_game_art` | `() -> GameArt` | Loads generated table and sprite textures from `resources/` |
| `unload_game_art` | `(GameArt) -> Unit` | Releases generated textures before shutdown |
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

All game logic is in `main.mbt`, with generated texture helpers in `art.mbt`. Key patterns:

- Small package design: constants, physics helpers, and the game loop live in `main.mbt`; generated art loading and sprite helpers live in `art.mbt`
- Generated assets: `resources/air_hockey_table.png` backs the playfield; `resources/air_hockey_sprites.png` provides player/AI paddles, puck, goal gates, and boost ring cells
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
