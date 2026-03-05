# Pinball Workshop 2026

Pinball Workshop 2026 is a classic arcade-style pinball game featuring a single table with two flippers and three circular bumpers. The player controls left and right flippers to keep a physics-simulated ball in play, bouncing it off bumpers for points while preventing it from draining through the bottom of the table.

The core gameplay loop is simple and satisfying: launch the ball with Space, then rapidly alternate between the A and D keys to swing the flippers upward and redirect the ball toward the three bumpers positioned in the upper portion of the table. The ball experiences realistic gravity (680 units/s^2), wall bouncing with 4% energy loss, and velocity-dependent flipper rebounds. Bumpers apply outward impulse with a slight speed boost on contact. The game awards 150-200 points per bumper hit and 25 points per flipper contact, continuing until all 3 lives are drained.

The physics implementation uses segment-based collision for flippers (projecting the ball onto the flipper line segment and reflecting with a configurable boost) and circle-circle collision for bumpers, both with minimum/maximum speed clamping to maintain playability.

## Build and Run

```bash
moon build --target native pinball_workshop_2026/
./_build/native/debug/build/pinball_workshop_2026/pinball_workshop_2026.exe
```

## Controls

- **Space**: Launch the ball (when ball is not live)
- **A**: Activate left flipper (hold to swing upward)
- **D**: Activate right flipper (hold to swing upward)
- **R**: Restart the game (resets score, lives, and ball)

## How to Play

The game starts with the ball positioned at the upper-right area of the table (780, 120) in an inactive state. Press Space to launch the ball with an initial velocity of (-190, -260), sending it across the table.

Use the A key to swing the left flipper upward (from its rest angle of -0.20 radians to its active angle of -0.85 radians) and the D key to swing the right flipper upward. When a key is released, the flipper returns to its rest position. Flippers swing at a rate of 12 radians per second.

The table has three bumpers:
- Left bumper at (300, 240), radius 26, awards 150 points
- Center bumper at (450, 190), radius 30, awards 200 points
- Right bumper at (605, 260), radius 24, awards 150 points

Flipper contact awards 25 points. When the flipper is actively swinging (key held), it imparts a 160-unit speed boost; when at rest, only a 20-unit boost.

The ball is bounded by walls on the left (x=70), right (x=830), and top (y=40). If the ball falls below the drain line (y=650), one life is lost and the ball resets. With 3 starting lives, losing all of them ends the game with a "GAME OVER" overlay. Press R at any time to restart with fresh score and lives.

## Public API Reference

### Package `pinball_workshop_2026`

> Single-file game containing all types, physics, and rendering in main.mbt.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Ball` | `x`, `y`, `vx`, `vy`, `live` | Ball position, velocity, and active state |
| `Flipper` | `pivot_x`, `pivot_y`, `rest_angle`, `active_angle`, `angle` | Flipper with pivot point, rest/active angle limits, and current angle |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value to a [lo, hi] range |
| `seg_end_x` | `(Flipper) -> Float` | Computes the X endpoint of a flipper segment using cosine of its angle |
| `seg_end_y` | `(Flipper) -> Float` | Computes the Y endpoint of a flipper segment using sine of its angle |
| `reset_ball` | `(Ball) -> Unit` | Resets ball to launch position (780, 120) with initial velocity and sets live to false |
| `collide_ball_with_segment` | `(Ball, Flipper, Float) -> Bool` | Tests and resolves ball-flipper collision using segment projection, applies speed boost |
| `ball_vs_bumper` | `(Ball, Float, Float, Float) -> Bool` | Tests and resolves ball-bumper circle collision, applies outward impulse |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | 900 | Window width in pixels |
| `screen_h` | `Int` | 700 | Window height in pixels |
| `gravity` | `Float` | 680.0 | Gravitational acceleration in units/s^2 |
| `ball_r` | `Float` | 10.0 | Ball radius in pixels |
| `table_left` | `Float` | 70.0 | Left wall X position |
| `table_right` | `Float` | 830.0 | Right wall X position |
| `table_top` | `Float` | 40.0 | Top wall Y position |
| `drain_y` | `Float` | 650.0 | Y threshold below which ball is drained |
| `flipper_len` | `Float` | 110.0 | Length of each flipper in pixels |
| `flipper_speed` | `Float` | 12.0 | Flipper angular velocity in radians/s |
| `pi` | `Float` | 3.141592653589793 | Mathematical constant pi |

## Architecture

### Package Structure

```
pinball_workshop_2026/
├── main.mbt    — Single file: constants, structs, physics, game loop, rendering
└── moon.pkg    — Package config with imports
```

This is a compact single-file game. All game constants, data structures, physics functions, game logic, input handling, and rendering are contained in `main.mbt`. The `main` function initializes the window and runs the game loop directly, managing game state through local mutable variables (`score`, `lives`, `game_over`).

### Data Flow

1. **Input**: Keyboard state is checked directly in the game loop via `is_key_pressed` (for Space, R) and `is_key_down` (for A, D flippers).
2. **Physics update**: Each frame applies gravity to `ball.vy`, integrates position, resolves wall collisions with energy loss, tests flipper collisions via `collide_ball_with_segment`, and tests bumper collisions via `ball_vs_bumper`. Scoring is applied inline.
3. **Flipper animation**: Flipper angles are interpolated toward their active angle (when key held) or rest angle (when released) at `flipper_speed` radians/s, clamped to their min/max range.
4. **Drain detection**: When `ball.y > drain_y`, a life is deducted and the ball resets, or the game ends if lives reach zero.
5. **Render**: Drawing occurs inline in the game loop: table border, bumper circles, flipper line segments, ball circle, HUD text, and game-over overlay.

### Key Design Patterns

- **Segment-based flipper collision**: `collide_ball_with_segment` projects the ball position onto the flipper line segment, finds the closest point, and reflects the ball with a configurable speed boost when the flipper is actively swinging.
- **Circle-circle bumper collision**: `ball_vs_bumper` computes distance between ball and bumper centers, resolves overlap by pushing the ball outward, and applies an outward impulse with speed clamping (260-900).
- **Delta-time clamped physics**: Frame time is clamped to 0.05s to prevent tunneling or physics explosion on lag spikes.
- **Speed clamping**: Both collision functions clamp the ball's post-collision speed to prevent runaway velocity while maintaining minimum energy.
- **Simple state management**: Game state is managed through three local variables (`score`, `lives`, `game_over`) rather than a state machine, appropriate for this game's simplicity.

## Improvement & Refinement Plan

1. **Add more table elements**: The table currently has only 3 bumpers. Adding ramps, lanes, rollover targets, or slingshots near the flippers would increase depth and scoring variety. The existing `ball_vs_bumper` and `collide_ball_with_segment` functions could be extended for new element types.

2. **Implement a plunger/launcher mechanic**: The ball launch uses fixed velocity (-190, -260) on Space press. Adding a charge-based plunger (hold Space to charge, release to launch with variable power) would add skill to the launch and is a standard pinball feature.

3. **Extract structs and physics into separate packages**: For maintainability, the Ball/Flipper structs and collision functions (`collide_ball_with_segment`, `ball_vs_bumper`) could be moved to `internal/types` and `internal/physics` packages respectively, following the pattern used by other games in this collection.

4. **Add visual effects for bumper hits**: Currently bumper collisions only update the score. Adding a brief flash/scale animation on the bumper circles, or particle effects similar to those in other games, would improve feedback.

5. **Implement ball spin or angular velocity**: The physics model treats the ball as a point mass with no rotation. Adding angular velocity affected by flipper contact angle would create more realistic ball behavior and add tactical depth.

6. **Add a high score display**: The score resets on R with no persistence. Tracking and displaying the session high score would give players a target to beat, requiring only an additional local variable in `main`.

7. **Fix the table drain gap**: Currently the drain extends across the full table width since there are no side gutters or drain guides. Adding angled walls from the flipper pivots to the table edges would create a proper drain funnel, which is standard in pinball table design.
