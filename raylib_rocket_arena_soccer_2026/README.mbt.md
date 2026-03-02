# Rocket Arena Soccer 2026

Rocket Arena Soccer 2026 is a physics-based car soccer game where the player controls a rocket-powered car in a 1v1 match against an AI opponent. Set on a top-down soccer pitch with goals on each side, the game blends driving skill with ball physics to create a fast-paced arcade experience reminiscent of Rocket League distilled into 2D.

The core gameplay loop revolves around driving your car into the ball to push it toward the opponent's goal while defending your own. Three special abilities add tactical depth: boost for sustained speed, dash for a quick forward lunge, and pulse strike for a ranged kick that launches the ball toward the opponent's net. Power-up pickups (Nitro cells, Cooldown chips, and Overdrive orbs) spawn periodically on the field, encouraging map control and risk-reward positioning. A 210-second match timer and first-to-7-goals win condition keep matches tight and exciting.

Technically, the game implements full circle-circle collision response between cars and ball, an AI driver with target-seeking steering, boost management, and randomized ability usage. A pre-allocated particle pool (980 particles) and pickup pool (30 slots) provide efficient object management without heap churn during gameplay.

## Build and Run

```bash
moon build --target native raylib_rocket_arena_soccer_2026/
./_build/native/debug/build/raylib_rocket_arena_soccer_2026/raylib_rocket_arena_soccer_2026.exe
```

## Controls

- **W / Up Arrow**: Throttle forward
- **S / Down Arrow**: Throttle backward (reverse)
- **A / Left Arrow**: Steer left
- **D / Right Arrow**: Steer right
- **J** (hold): Boost (consumes boost meter, increases engine power from 460 to 660)
- **K**: Dash (instant +230 speed burst, costs 12 boost, 1.26s cooldown)
- **L**: Pulse strike (launches ball toward opponent goal if within 226px range, costs 18 boost, 2.24s cooldown)
- **Enter**: Start match / return to title menu
- **R**: Replay (restart match from end screen)
- **F11**: Toggle fullscreen
- **Mouse/Touch**: On-screen D-pad (left side) and action buttons (right side) for mobile/touch play

## How to Play

Score 7 goals before the AI opponent, or hold the lead when the 210-second (3:30) match timer runs out. If the score is tied at the end and you have non-negative style points, you win.

Drive your triangular car into the ball to push it. The ball inherits velocity from the car upon collision, so faster hits produce harder shots. Your car has a boost meter (0-100) that regenerates at 9.5 units/second. Holding J activates boost mode which increases your engine power but drains boost at 25 units/second.

Dash (K) gives an instant speed burst of +230, costing 12 boost with a 1.26-second cooldown. Pulse strike (L) remotely launches the ball toward the opponent's goal when the ball is within range (226 pixels), costing 18 boost with a 2.24-second cooldown and awarding 8 style points.

Three types of pickups spawn on the field every 4.2-6.8 seconds and last 8-15 seconds:
- **Nitro Cell** (green): Restores 34 boost
- **Cooldown Chip** (blue): Reduces dash and pulse cooldowns by 0.9 seconds
- **Overdrive** (gold): Instant +120 speed boost, awards 24 style points

Cars that collide at high combined speed (>280) are stunned for 0.22 seconds. Wall collisions at speed >160 also cause brief stuns. The AI opponent has similar abilities (dash, pulse, boost) and uses target-seeking steering to chase and hit the ball.

After a goal, there is a 1.65-second kickoff pause before play resumes. Goals award 120 style points plus 30 bonus if the player scored directly.

## Public API Reference

### Package `raylib_rocket_arena_soccer_2026`

> Main entry point. Single-file game containing all types, logic, rendering, and the main loop.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width in pixels |
| `sh` | `Int` | `760` | Screen height in pixels |
| `field_l` | `Float` | `86.0` | Field left boundary x-coordinate |
| `field_t` | `Float` | `92.0` | Field top boundary y-coordinate |
| `field_r` | `Float` | `1194.0` | Field right boundary x-coordinate |
| `field_b` | `Float` | `668.0` | Field bottom boundary y-coordinate |
| `goal_h` | `Float` | `208.0` | Goal height in pixels |
| `goal_t` | `Float` | computed | Goal top y-coordinate (centered vertically) |
| `goal_b` | `Float` | computed | Goal bottom y-coordinate |
| `center_x` | `Float` | computed | Field horizontal center |
| `center_y` | `Float` | computed | Field vertical center |
| `car_r` | `Float` | `24.0` | Car collision radius |
| `max_pickups` | `Int` | `30` | Maximum simultaneous pickups on the field |
| `max_particles` | `Int` | `980` | Maximum simultaneous particles |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Car` | `x`, `y`, `angle`, `speed`, `boost`, `dash_cd`, `pulse_cd`, `stun_t`, `flash_t` | Represents a rocket car with position, heading, speed, boost meter, ability cooldowns, and stun/flash timers |
| `Ball` | `x`, `y`, `vx`, `vy`, `r`, `last_touch`, `fire_t` | The soccer ball with position, velocity, radius, last-touching player ID, and hit flash timer |
| `Pickup` | `active`, `x`, `y`, `kind`, `t`, `life` | A field pickup with type (0=Nitro, 1=Cooldown, 2=Overdrive), age, and lifetime |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `size`, `t`, `life`, `kind` | Visual particle with velocity, size, age, lifetime, and color kind |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value between low and high bounds |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `deg2rad` | `(Float) -> Double` | Converts degrees to radians |
| `sinf_deg` | `(Float) -> Float` | Returns the sine of an angle in degrees |
| `cosf_deg` | `(Float) -> Float` | Returns the cosine of an angle in degrees |
| `wrap_deg` | `(Float) -> Float` | Wraps an angle to the range [-180, 180] degrees |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Returns the squared distance between two points |
| `randf` | `(Float, Float) -> Float` | Returns a random float between low and high |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside a rectangle (for touch UI) |
| `clear_pickups` | `(Array[Pickup]) -> Unit` | Deactivates and zeroes all pickups in the array |
| `clear_particles` | `(Array[Particle]) -> Unit` | Deactivates and zeroes all particles in the array |
| `spawn_pickup` | `(Array[Pickup]) -> Bool` | Spawns a random pickup in an inactive slot; returns false if pool is full |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Emits N particles at position with given speed multiplier and color kind |
| `reset_round` | `(Car, Car, Ball, Bool) -> Unit` | Resets car and ball positions for a new kickoff round |
| `car_forward_x` | `(Car) -> Float` | Returns the x-component of the car's forward direction |
| `car_forward_y` | `(Car) -> Float` | Returns the y-component of the car's forward direction |
| `cap_car_in_field` | `(Car) -> Bool` | Constrains car position within field boundaries; returns true if a wall bounce occurred |
| `collide_car_ball` | `(Car, Ball, Int, Array[Particle]) -> Unit` | Handles circle-circle collision between a car and the ball with impulse transfer |
| `collide_cars` | `(Car, Car, Array[Particle]) -> Unit` | Handles collision between two cars with speed exchange and stun on high-speed impacts |
| `update_ball` | `(Ball, Float) -> Int` | Updates ball position and handles wall bounces; returns 0 (no goal), 1 (player scored), or 2 (AI scored) |
| `draw_car` | `(Car, Bool) -> Unit` | Draws a car as a triangle with glow circle; color depends on player/AI flag |
| `draw_field_lines` | `() -> Unit` | Renders the soccer field with stripes, center line, center circle, goals, and penalty areas |

## Architecture

### Package Structure

```
raylib_rocket_arena_soccer_2026/
├── main.mbt              -- Entry point: all game logic, rendering, and main loop
└── moon.pkg              -- Package config with raylib and math imports
```

This is a single-file game where all code lives in `main.mbt`. The file is organized into sections: constants and type definitions at the top, utility functions (math, collision), game logic functions (spawning, resetting, updating), rendering functions, and the main game loop at the bottom.

### Data Flow

1. **Input**: The main loop reads keyboard state (`is_key_down`, `is_key_pressed`) and mouse/touch position each frame for both keyboard controls and on-screen touch UI buttons.
2. **Update**: Player input is translated to steering and throttle values. The AI computes its own steering via `atan2` toward a target position near the ball. Both cars update position using forward vector times speed. `collide_cars` and `collide_car_ball` handle physics. `update_ball` moves the ball and returns goal events.
3. **Pickup system**: `spawn_pickup` periodically adds items; proximity checks in the main loop handle collection by either player or AI.
4. **Particles**: `burst` emits particles on impacts; particles update position with gravity and drag, fading over their lifetime.
5. **Render**: `draw_field_lines`, `draw_car`, pickup circles, ball circle, particle circles, HUD elements (score, timer, boost bar, messages), and touch UI are drawn each frame.

### Key Design Patterns

- **Object pool pattern**: Both `pickups` (30 slots) and `particles` (980 slots) use pre-allocated arrays with `active` boolean flags, avoiding dynamic allocation during gameplay.
- **State machine**: An integer `state` variable (0=Title, 1=Play, 2=Win, 3=Lose) drives the main loop's behavior branching.
- **Circle-circle collision**: `collide_car_ball` and `collide_cars` use squared-distance checks against combined radii, then compute separation and impulse along the collision normal.
- **Delta-time physics**: All movement uses `dt` (capped at 0.033s) for frame-rate-independent behavior. Speed damping uses exponential decay (`speed * (1 - dt * drag)`).
- **AI driver**: The AI uses `atan2` to compute the desired heading toward the ball, applies proportional steering, and has randomized ability usage (dash when close, pulse with 8% chance per frame when in range).
- **Dual input**: Both keyboard and touch/mouse input are unified into the same `steer_l`, `steer_r`, `throttle_f`, `throttle_b`, `boost_down`, `dash_press`, `pulse_press` flags using `inside_rect` checks.

## Improvement & Refinement Plan

1. **Extract game state into a struct**: The main function uses many `let mut` local variables (`state`, `match_time`, `player_score`, `ai_score`, `style_pts`, `goal_pause_t`, `pickup_spawn_cd`). Consolidating these into a `GameState` struct would improve readability and make it easier to pass state between functions.

2. **Separate rendering from logic**: Currently `main` contains interleaved update and draw code exceeding 1600 lines. Extracting rendering into dedicated functions like `draw_hud`, `draw_title_screen`, `draw_end_screen` would improve maintainability.

3. **Improve AI difficulty scaling**: The AI uses fixed parameters (engine power 430/620, dash threshold 124px, pulse 8% chance). Adding difficulty levels that tune these values would improve replayability.

4. **Add ball trail rendering**: The `fire_t` timer on `Ball` already tracks recent hits. A trail of previous positions stored in a ring buffer would make fast-moving shots more visually dramatic.

5. **Replace integer state with enum**: The `state` variable uses magic integers (0, 1, 2, 3). A proper `GameState` enum would make the code self-documenting and prevent invalid state values.

6. **Add goal replay or slow-motion**: When `update_ball` returns a goal event, the game could briefly reduce `dt` or replay the last few frames to celebrate the scoring moment before the kickoff pause.

7. **Normalize AI pulse direction vector**: In the AI pulse logic (line ~999), the direction vector uses Manhattan distance normalization (`absf(dx) + absf(dy)`) rather than Euclidean length. Using proper vector normalization would make pulse shots more consistent across different ball positions.
