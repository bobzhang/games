# Rooftop Volleyball 2026

Rooftop Volleyball 2026 is a 1v1 arcade volleyball game set on an urban rooftop court at night, with a neon-lit city skyline scrolling in the background. The player faces an AI rival in a best-of-three-sets match with full physics-driven ball movement, spin mechanics, and periodic wind gusts that add unpredictability to rallies.

The core gameplay loop is rally-based: serve the ball, position your athlete with lateral movement and jumps, then time hits to send the ball over the net onto the opponent's side. Hitting while airborne and above the ball produces a downward spike. A dash ability provides a burst of speed for positioning at the cost of energy, and hits during a dash are powered up (790 vs 680 base speed). The ball features spin physics that curve its trajectory, and net collisions reverse spin. Wind gusts of increasing strength appear between calm intervals, pushing the ball sideways and forcing tactical adjustments.

The scoring follows real volleyball rules: sets are played to 11 points with a 2-point lead required. The first player to win 2 sets claims the championship. The AI uses predictive ball tracking with falloff-time estimation and triggers jumps, dashes, and hits reactively.

## Build and Run

```bash
moon build --target native raylib_rooftop_volleyball_2026/
./_build/native/debug/build/raylib_rooftop_volleyball_2026/raylib_rooftop_volleyball_2026.exe
```

## Controls

- **A / Left Arrow**: Move left
- **D / Right Arrow**: Move right
- **W / Up Arrow / Space**: Jump (when on ground, 0.16s cooldown)
- **J**: Hit the ball (when within 88px range, 0.22s cooldown, costs 14 energy)
- **K / Left Shift**: Dash (0.22s burst of speed, costs 32 energy)
- **R**: Restart match
- **Touch/Mouse**: On-screen LEFT/RIGHT buttons (bottom-left), JUMP/HIT/DASH buttons (bottom-right)

## How to Play

Win 2 sets to claim the championship. Each set is played to 11 points, and you must lead by at least 2 points to close a set.

At the start of each rally, the ball is held by the serving player. If you are serving, press J (hit) or W (jump) to serve. The AI serves automatically after the rally wait timer.

During play, move left/right to position under the ball and press J to hit it. The ball is hit toward the opponent's side with randomized targeting. Key mechanics:
- **Aerial spikes**: Hitting while airborne and with the ball below head level produces a downward spike toward the opponent's floor
- **Dash hits**: Hitting during a dash increases ball launch speed from 680 to 790
- **Spin**: Each hit adds spin to the ball, curving its trajectory. Spin decays over time and reverses on net contact
- **Wind**: Periodic wind gusts push the ball sideways. Wind strength increases with set number (36+set*8 to 86+set*11). Wind lasts 1.8-4.2 seconds with 5.6-9.8 second calm intervals
- **Energy**: Regenerates at 20 units/second (max 100). Dashing costs 32 energy, hitting costs 14 energy

The ball hits the ground when it reaches y >= ground_y. If it lands on your side (left of net), the rival scores; if on the rival's side, you score. Stars are awarded (+2 per point won by the player).

## Public API Reference

### Package `raylib_rooftop_volleyball_2026`

> Main entry point. Single-file game with all types, physics, AI, rendering, and main loop.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width in pixels |
| `sh` | `Int` | `820` | Screen height in pixels |
| `ground_y` | `Float` | `700.0` | Y-coordinate of the court floor |
| `net_x` | `Int` | `640` | X-coordinate of the net center |
| `net_h` | `Int` | `172` | Net height in pixels |
| `set_points` | `Int` | `11` | Points needed to win a set (with 2-point lead) |
| `max_particles` | `Int` | `460` | Maximum particle pool size |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Athlete` | `x`, `y`, `vx`, `vy`, `on_ground`, `energy`, `hit_cd`, `jump_cd`, `dash_t`, `flash_t`, `score`, `sets` | A volleyball player with position, velocity, ground state, energy meter, ability cooldowns, and match scoring |
| `Ball` | `x`, `y`, `vx`, `vy`, `r`, `spin`, `active`, `serve_owner` | The volleyball with position, velocity, radius (16), spin value, active state, and current serve owner (1=player, 2=bot) |
| `Particle` | `x`, `y`, `vx`, `vy`, `ttl`, `kind`, `active` | A visual particle with velocity, time-to-live, and color kind |
| `Wind` | `dir`, `strength`, `ttl`, `cd` | Wind gust state with direction (-1/+1), horizontal force strength, active duration, and cooldown timer |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value between low and high bounds |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `sqdist` | `(Float, Float, Float, Float) -> Float` | Returns the squared distance between two points |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside an integer rectangle (for touch UI) |
| `clear_particles` | `(Array[Particle]) -> Unit` | Deactivates and zeroes all particles |
| `spawn_particle` | `(Array[Particle], Float, Float, Float, Int) -> Unit` | Spawns a single particle with random velocity scaled by speed |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Emits N particles at position with given speed and kind |
| `reset_athlete` | `(Athlete, Float) -> Unit` | Resets an athlete to starting position with full energy and cleared cooldowns |
| `setup_rally` | `(Athlete, Athlete, Ball, Int) -> Unit` | Resets positions and prepares ball for serve by the specified owner |
| `setup_match` | `(Athlete, Athlete, Ball, Wind, Array[Particle]) -> Unit` | Fully resets match: scores, sets, positions, wind, and particles |
| `tick_athlete` | `(Athlete, Float) -> Unit` | Updates an athlete's cooldown timers and energy regeneration |
| `update_athlete_movement` | `(Athlete, Float, Bool, Bool, Bool, Bool, Float, Float) -> Unit` | Handles athlete physics: acceleration, dash, jumping, gravity, ground clamping, and boundary constraints |
| `attempt_hit_ball` | `(Athlete, Ball, Int, Array[Particle]) -> Bool` | Attempts to hit the ball if within range and off cooldown; applies velocity, spin, and aerial spike logic |
| `spawn_wind` | `(Wind, Int) -> Unit` | Activates a new wind gust with set-scaled strength and random direction |
| `update_wind` | `(Wind, Float, Int) -> Unit` | Ticks wind duration or cooldown, spawning new gusts when cooldown expires |
| `set_no` | `(Athlete, Athlete) -> Int` | Returns the current set number (sum of both players' sets won + 1) |
| `resolve_point` | `(Int, Athlete, Athlete, Ball, Array[Particle], Ref[String], Ref[Float], Ref[Bool], Ref[Bool]) -> Unit` | Awards a point, checks for set/match completion, and sets up the next rally |

## Architecture

### Package Structure

```
raylib_rooftop_volleyball_2026/
├── main.mbt              -- Entry point: all types, physics, AI, rendering, and main loop
└── moon.pkg              -- Package config with raylib and math imports
```

This is a single-file game (~1370 lines) with all code in `main.mbt`. Sections flow from type definitions, utilities, game logic functions, AI logic, to the main loop with interleaved update and rendering.

### Data Flow

1. **Input**: Keyboard keys and touch/mouse buttons are unified into boolean flags (`p_left`, `p_right`, `p_jump`, `p_hit`, `p_dash`) via `inside_rect` checks.
2. **Player movement**: `update_athlete_movement` applies acceleration, dash burst, jumping with gravity (980 px/s^2), ground clamping, and boundary enforcement (player: 70 to net_x-36, bot: net_x+36 to sw-70).
3. **AI**: The bot computes a target x-position using ball trajectory prediction (estimating fall time), moves toward it, and triggers jump/dash/hit when conditions are met.
4. **Ball physics**: Gravity (980), spin curving (spin * 2.4), wind force, wall bounces (0.85 restitution), ceiling bounce (0.78), and net collision with spin reversal.
5. **Scoring**: When ball hits ground, `resolve_point` awards the point, checks set completion (11+ points with 2-point lead), checks match completion (2 sets), and sets up the next rally.
6. **Rendering**: Layered drawing: animated city skyline, court floor with moving texture, net with mesh lines, stick-figure athletes with dash trails, ball with cross-pattern, particles, HUD with scores/energy/wind, and touch controls.

### Key Design Patterns

- **Ref-based output parameters**: `resolve_point` uses `Ref[String]`, `Ref[Float]`, `Ref[Bool]` to return multiple values (message, rally wait, game over state, win state) since MoonBit functions return a single value.
- **Set-scaled difficulty**: Wind strength increases with `set_no`, making later sets more unpredictable. The AI also benefits from stronger wind when it aligns with its side.
- **Aerial spike mechanic**: `attempt_hit_ball` checks if the athlete is airborne and the ball is below head level, switching from a high lob to a downward spike -- a core skill differentiator.
- **Energy economy**: Energy regenerates passively (20/s) but is consumed by both dashing (32) and hitting (14), forcing players to manage resources between offensive and defensive actions.
- **Particle pool**: 460 pre-allocated particles with `active` flags for hit effects, point celebrations, and set victory bursts.

## Improvement & Refinement Plan

1. **Add ball shadow on ground**: The ball lacks a ground shadow, making it difficult to judge landing position. Drawing an ellipse at (ball.x, ground_y) that shrinks as the ball rises would improve depth perception.

2. **Implement rally counter and stats**: There is no tracking of rally length or match statistics. Adding a rally hit counter and post-match stats (longest rally, total spikes, etc.) would add replay value.

3. **Improve AI difficulty progression**: The bot uses fixed parameters (jump threshold 260, dash threshold 180). Scaling these by set number or implementing difficulty levels would provide better progression.

4. **Add serve direction control**: Player serves use random targeting (`get_random_value`). Allowing the player to aim serves with directional input would add a skill element to the serve phase.

5. **Extract rendering into separate functions**: Player and bot rendering use nearly identical inline code (~50 lines each). A `draw_athlete` function parameterized by position and color would eliminate duplication.

6. **Replace magic numbers with named constants**: Physics constants like gravity (980.0), drag (7.6), jump velocity (-536.0), and hit ranges (88.0) are inline. Extracting these as named `let` bindings would improve readability and tuning.

7. **Add deuce indicator**: When both players are at 10+ points, there is no special visual indicator for the deuce state. Highlighting the score or adding "DEUCE" text when within 1 point would improve match tension.
