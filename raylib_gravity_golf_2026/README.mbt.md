# Gravity Golf 2026

A physics-based puzzle golf game where the player launches a ball across a field dotted with gravity wells that bend the ball's trajectory. The objective is to sink the ball into a green hole across three progressively harder levels, each introducing more gravity wells with varying mass and radius. The game is played on a 1200x760 pixel field with a dark space-themed aesthetic.

The core mechanic centers on aiming with the mouse cursor and adjusting launch power with W/S keys between 220 and 760 units. Once launched, the ball is subject to Newtonian gravitational attraction from each active well, with force proportional to the well's mass divided by the squared distance. The ball bounces off screen edges with 72% energy retention and settles when speed drops below 36 units after at least 0.9 seconds of flight. If the ball enters a gravity well (within well radius + 8 pixels), it collapses and resets to the tee position, costing the player a shot.

Each level provides a fixed number of shots (8, 9, and 10 respectively) and arranges gravity wells in configurations that require the player to use gravitational slingshot curves to reach the hole. Scoring rewards efficiency: completing a hole awards 120 base points plus 20 points per remaining shot.

## Build and Run

```bash
moon build --target native raylib_gravity_golf_2026/
./_build/native/debug/build/raylib_gravity_golf_2026/raylib_gravity_golf_2026.exe
```

## Controls

- **Mouse**: Aim shot direction (line drawn from ball to cursor)
- **W / Up Arrow** (hold): Increase shot power (capped at 760)
- **S / Down Arrow** (hold): Decrease shot power (minimum 220)
- **Space**: Launch the ball toward the mouse cursor
- **R**: Restart the entire course from level 1

## How to Play

1. **Aim**: Move the mouse cursor to set the shot direction. A yellow guide line is drawn from the ball to the cursor while aiming.

2. **Adjust power**: Hold W/Up to increase power or S/Down to decrease it. Power ranges from 220 to 760, adjusting at 260 units/second. The current power value is displayed in the HUD.

3. **Shoot**: Press Space to launch the ball. The ball flies in the direction of the mouse cursor at the selected power. Each shot decrements the shot counter.

4. **Gravity wells**: Purple circles on the field attract the ball with gravitational force. The force follows an inverse-square law: `force = mass / distance^2`. Use these fields to curve the ball around obstacles and toward the hole. If the ball gets too close to a well's core (within its radius + 8 pixels), it collapses and resets to the tee.

5. **Bouncing and settling**: The ball bounces off the screen edges (left at x=20, right at x=1180, top at y=90, bottom at y=740) with 72% velocity retention. After 0.9 seconds of flight, if the ball's speed drops below 36 units, it settles in place. You can then re-aim and shoot again.

6. **Sinking the hole**: When the ball comes within 18 pixels of the green hole, the hole is cleared. You earn 120 + (shots_remaining * 20) points and advance to the next level.

7. **Level progression**: Level 1 has 2 gravity wells and 8 shots. Level 2 has 3 wells and 9 shots. Level 3 has 4 wells and 10 shots. Completing level 3 ends the course.

8. **Game over**: The round ends when you complete all 3 levels or run out of shots. Press R to restart from level 1.

## Public API Reference

### Package `raylib_gravity_golf_2026`

> Main entry point and complete game implementation (single-file architecture).

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1200` | Window width in pixels |
| `sh` | `Int` | `760` | Window height in pixels |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Well` | `x`, `y`, `mass`, `r` | Gravity well with position, gravitational mass, and visual/collision radius |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `set_well` | `(Array[Well], Int, Float, Float, Float, Float) -> Unit` | Sets the gravity well at index i with position (x, y), mass, and radius |
| `clear_wells` | `(Array[Well]) -> Unit` | Resets all wells in the array to zero values |
| `setup_level` | `(Int, Array[Well]) -> (Float, Float, Float, Float, Int)` | Configures gravity wells for the given level (1-3) and returns (start_x, start_y, hole_x, hole_y, shots_allowed) |
| `main` | `() -> Unit` | Entry point: initializes window, runs game loop with input handling, physics simulation, collision detection, level progression, and rendering |

## Architecture

### Package Structure

```
raylib_gravity_golf_2026/
├── main.mbt              -- Complete game: Well struct, level setup, physics,
│                            input handling, rendering, and game loop
└── moon.pkg              -- Package config: raylib import, is-main option
```

### Data Flow

1. **Input**: Each frame, the game checks W/S/Up/Down keys for power adjustment (continuous hold), Space for shot launch (single press), R for restart (single press), and mouse position for aim direction.

2. **Shot launch**: When Space is pressed while the ball is stationary and shots remain, the direction vector from the ball to the mouse cursor is normalized and scaled by `power` to set `bvx` and `bvy`.

3. **Physics simulation**: While the ball is `moving`, each frame applies gravitational acceleration from all active wells using `force = mass / distance^2` with direction toward the well center. The ball's position is then integrated with `bx += bvx * dt` and `by += bvy * dt`.

4. **Collision detection**: Three types of collision are checked each frame: (a) ball entering a well's core (distance <= well.r + 8) causes collapse and reset to tee, (b) ball hitting screen edges causes velocity reflection with 0.72 damping, (c) ball reaching the hole (distance <= 18) triggers level completion.

5. **Settling**: After 0.9 seconds of flight (`shot_time > 0.9`) with speed below 36 units, the ball stops and the player can re-aim.

6. **Rendering**: The frame draws gravity wells (dark blue halos with purple cores), the green hole with black center, the aim line (yellow, when stationary), the ball (white circle), HUD text (level, shots, power, score), instructions, status message bar, and game-over overlay when applicable.

### Key Design Patterns

- **Tuple-based level configuration**: `setup_level` returns a 5-tuple `(start_x, start_y, hole_x, hole_y, shots)` to configure each level, using `set_well` calls for gravity well placement. This keeps level definitions compact and self-contained.

- **Fixed well pool**: Wells are stored in a pre-allocated `Array[Well]` of size 4 (the maximum needed for level 3). Unused wells have `mass <= 0.0` and are skipped during physics and rendering. `clear_wells` zeroes the entire pool before each level setup.

- **Newtonian gravity simulation**: The gravitational force calculation uses the standard inverse-square formula `a = mass / distance^2` with normalized direction vectors, producing physically intuitive curved trajectories that players can learn to predict.

- **Edge bouncing with energy loss**: Wall collisions reverse the relevant velocity component and multiply by 0.72, simulating inelastic bouncing. This prevents the ball from bouncing indefinitely while allowing trick shots off walls.

- **Delta-time clamped updates**: The frame delta is clamped to 0.05 seconds maximum to prevent physics instabilities during frame rate drops.

## Improvement & Refinement Plan

1. **Add trajectory preview**: The game only shows a straight aim line from ball to cursor. Drawing a dotted curve that simulates the first second of flight (accounting for gravity wells) would help players visualize how wells will bend their shot.

2. **Add more levels**: The game has only 3 hardcoded levels in `setup_level`. Adding a level editor or procedural level generation that places wells and holes randomly with guaranteed solvability would greatly extend replayability.

3. **Implement par scoring**: Currently scoring is just `shots_left * 20 + 120` per hole. Adding a par system (target number of shots per level) with under-par bonuses and over-par penalties would make scoring more meaningful and encourage replay.

4. **Add visual effects for ball movement**: The ball is a plain white circle with no trail or motion indicators. Adding a fading trail of previous positions or particle emission during flight would make the gravity-bending physics more visually dramatic.

5. **Implement gravity field visualization**: Wells are shown as static purple circles but their gravitational influence range is not visible. Drawing concentric field lines or gradient rings proportional to `mass` would help players intuit the strength and reach of each well.

6. **Add obstacle barriers**: The levels currently only have gravity wells. Introducing solid rectangular or circular barriers that block the ball's path would add geometric puzzle elements that complement the gravity mechanics.

7. **Save high scores**: The `score` variable resets on restart. Persisting the best score per session or to a file would give players a target to beat across multiple attempts.
