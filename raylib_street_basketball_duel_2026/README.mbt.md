# Street Basketball Duel 2026

Street Basketball Duel 2026 is a 1-on-1 arcade basketball game set on a neon-lit urban court with a scrolling cityscape backdrop. The player controls a blue athlete competing against a pink AI-controlled rival, shooting hoops on opposite ends of the court in a race to reach 21 points.

The core gameplay combines side-scrolling platformer movement with basketball mechanics. Athletes can run, jump, dash (consuming energy), and shoot the ball toward the opponent's hoop. The ball has realistic physics with gravity, spin, wall bounces, rim collisions, and backboard deflections. When the ball is loose, both players can grab it based on proximity. The player can also attempt steals when close to the rival who has possession (46% success chance). Shots from beyond 430 pixels score 3 points; closer shots score 2 points. After each basket, possession resets with a brief inbound countdown.

The game features an energy system that regenerates at 20 units per second and is consumed by dashing (30 energy). A match timer counts down from 145 seconds, with 24-second overtime rounds if scores are tied. Victory requires reaching the target score of 21 with at least a 2-point lead, or having the higher score when time expires.

## Build and Run

```bash
moon build --target native raylib_street_basketball_duel_2026/
./_build/native/debug/build/raylib_street_basketball_duel_2026/raylib_street_basketball_duel_2026.exe
```

## Controls

- **A / Left Arrow**: Move left
- **D / Right Arrow**: Move right
- **W / Up Arrow / Space**: Jump
- **J**: Shoot ball (when holding) / Attempt steal (when rival has ball)
- **K / Left Shift**: Dash (costs 30 energy, boosts speed for 0.22 seconds)
- **R**: Restart match
- **Touch controls**: On-screen LEFT/RIGHT buttons (bottom-left), JUMP/SHOOT/DASH buttons (bottom-right)

## How to Play

The match starts with the player holding the ball at center-left court. After a brief inbound countdown (0.9 seconds), the timer begins counting down from 145 seconds.

Move toward the right hoop and press J to shoot. The ball travels toward the rim area with slight randomization. During a dash, shots get a +130 speed boost, making them harder to defend. Shots from far away (over 430 pixels from the hoop) score 3 points; closer shots score 2 points. Own-basket shots by the wrong team always count as 2 points.

The ball interacts physically with the environment: it bounces off the ground, walls, and backboards. Rim collision uses circle-based physics with velocity reflection and damping. A basket is scored when the ball crosses downward through the rim zone (within 12 pixels of hoop center, moving downward, crossing the rim Y threshold).

When the ball is loose (no owner), both players can catch it if within 46 pixels and their catch cooldown has expired. The closer player wins contested rebounds. Press J when near the rival to attempt a steal (46% success rate, requires being within 68 pixels).

The AI rival has three behavioral modes: when holding the ball, it moves to an optimal shooting position (x=828) and shoots when ready; when defending, it positions at x=904 and dashes when far from the player; when the ball is loose, it chases the ball and jumps for aerial rebounds.

The first player to reach 21 points with a 2-point lead wins. If tied at the end of regulation time, 24-second overtime rounds are added until a winner emerges.

## Public API Reference

### Package `raylib_street_basketball_duel_2026`

> Main entry point and complete game implementation.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width in pixels |
| `sh` | `Int` | `820` | Screen height in pixels |
| `ground_y` | `Float` | `706.0` | Ground level Y coordinate |
| `left_hoop_x` | `Float` | `186.0` | Left hoop X center position |
| `right_hoop_x` | `Float` | `1094.0` | Right hoop X center position |
| `rim_y` | `Float` | `458.0` | Rim Y coordinate for both hoops |
| `set_target` | `Int` | `21` | Points needed to win |
| `max_particles` | `Int` | `520` | Maximum particle pool size |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Athlete` | `x`, `y`, `vx`, `vy`, `on_ground`, `energy`, `dash_t`, `shoot_cd`, `catch_cd`, `flash_t`, `score` | Player or rival athlete with position, velocity, ground state, energy, cooldowns, and score |
| `Ball` | `x`, `y`, `vx`, `vy`, `r`, `spin`, `owner`, `shooter`, `shot_from_x`, `last_y`, `active` | Basketball with physics state, radius, spin, ownership tracking, shot origin, and active flight flag |
| `Particle` | `x`, `y`, `vx`, `vy`, `ttl`, `kind`, `active` | Visual particle with position, velocity, time-to-live, color kind, and active flag |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value between lower and upper bounds |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `sqdist` | `(Float, Float, Float, Float) -> Float` | Computes squared Euclidean distance between two 2D points |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside a rectangle (for touch control hit-testing) |
| `clear_particles` | `(Array[Particle]) -> Unit` | Deactivates and zeroes all particles in the pool |
| `spawn_particle` | `(Array[Particle], Float, Float, Float, Int) -> Unit` | Activates one particle at a position with random velocity scaled by speed |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Emits N particles as a burst at a position with given speed and color kind |
| `reset_athlete` | `(Athlete, Float) -> Unit` | Resets an athlete to ground level at given X with full energy and cleared cooldowns |
| `setup_possession` | `(Athlete, Athlete, Ball, Int) -> Unit` | Resets both athletes to starting positions, assigns ball possession, and clears ball physics |
| `tick_athlete` | `(Athlete, Float) -> Unit` | Decrements cooldown timers and regenerates energy for an athlete each frame |
| `update_athlete_move` | `(Athlete, Float, Bool, Bool, Bool, Bool, Float, Float) -> Unit` | Applies movement physics including acceleration, drag, jumping, gravity, dashing, and boundary clamping |
| `release_shot` | `(Athlete, Int, Ball, Float, Float, Float) -> Unit` | Releases the ball from a shooter toward a target position with optional speed boost |
| `resolve_rim_collision` | `(Ball, Float, Float) -> Unit` | Resolves circle-circle collision between ball and rim, applying velocity reflection and damping |
| `draw_hoop` | `(Float, Int) -> Unit` | Draws a basketball hoop with backboard, support, rim ring, and net lines |

## Architecture

### Package Structure

```
raylib_street_basketball_duel_2026/
├── main.mbt              -- Entry point, game loop, physics, AI, rendering
└── moon.pkg              -- Package config with raylib and math imports
```

Single-file game with all physics, AI, input handling, and rendering in `main.mbt`.

### Data Flow

1. **Input**: Keyboard keys and touch button hit-testing set boolean flags (`p_left`, `p_right`, `p_jump`, `p_action`, `p_dash`). Touch controls use `inside_rect` for button regions.

2. **Update**:
   - `tick_athlete` decrements cooldowns and regenerates energy for both athletes
   - `update_athlete_move` applies physics: acceleration/drag for horizontal movement, gravity for vertical, jump impulse, dash boost, boundary clamping
   - Ball physics when unowned: gravity, spin-induced horizontal drift, wall/ground/backboard bounces, rim collision via `resolve_rim_collision`
   - Scoring detection: ball crosses rim Y threshold downward within 12 pixels of hoop center. Awards 2 or 3 points based on shot distance
   - Rebound/catch: both athletes check proximity to loose ball; closer one wins ties
   - Steal: J pressed near rival with ball gives 46% chance via `get_random_value`
   - AI decision: three modes based on ball ownership (offense at x=828, defense at x=904, loose ball chase)

3. **Render**: Background with animated city skyline and crowd glow, court floor with markings, hoops via `draw_hoop`, stick-figure athletes with body/arm/leg lines, ball with cross-seam lines, particles, HUD with scores/energy/timer, touch controls, and game-over overlay.

### Key Design Patterns

- **Object pool for particles**: Pre-allocated `Array[Particle]` with `active` flags; `spawn_particle` finds first inactive slot.
- **Possession-based state machine**: `ball.owner` (0=loose, 1=player, 2=rival) drives both gameplay logic and AI behavior.
- **Rally wait system**: After each basket, a `rally_wait` timer prevents immediate action, simulating an inbound play.
- **Circle-circle rim collision**: `resolve_rim_collision` computes penetration depth and reflects velocity using the normal vector, with 0.84 restitution damping.
- **AI behavior modes**: The rival AI uses three distinct strategies depending on ball ownership, with position targets and action thresholds.
- **Delta-time physics**: All movement, gravity, and timer updates multiply by `dt` with a 0.05 cap.

## Improvement & Refinement Plan

1. **Add shot arc preview**: Currently the player shoots blindly toward the hoop. Drawing a dotted trajectory arc when the player holds the ball would help gauge shot timing and positioning.

2. **Implement difficulty scaling for AI**: The AI always targets x=828 for shooting and has fixed behavior thresholds. Adding difficulty levels that vary the AI's shooting accuracy, defensive positioning, and steal resistance would improve replayability.

3. **Add block/contest mechanic**: There is no way to contest a shot in flight. Adding a block action when jumping near the ball trajectory would create more defensive depth beyond just stealing.

4. **Refactor AI behavior into functions**: The AI logic is inline in the main loop with nested conditionals. Extracting `ai_offense(rival, ball)`, `ai_defense(rival, player)`, and `ai_chase_ball(rival, ball)` would improve readability.

5. **Add 3-point line visual**: Shots beyond 430 pixels earn 3 points but there is no court marking indicating the 3-point range. Drawing an arc on the court floor would help the player position for long-range shots.

6. **Implement dunk/layup mechanic**: When an athlete is close to the hoop and jumping, a direct dunk animation with guaranteed scoring would reward aggressive driving play and add variety to the shot system.

7. **Add match history tracking**: The game resets completely on R press. Tracking win/loss records and best scores across matches would provide long-term motivation.
