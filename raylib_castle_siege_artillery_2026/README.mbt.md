# Castle Siege Artillery 2026

A turn-based artillery strategy game set on a medieval battlefield where two opposing castles face off across a mountainous divide. Players command a cannon on the left castle, lobbing projectiles over a central mountain obstacle to destroy the enemy fortress on the right, while an AI opponent retaliates each turn with its own calculated shots.

The core gameplay loop centers on adjusting two parameters -- launch angle (16 to 82 degrees) and power (260 to 740 units) -- then firing a projectile that follows a realistic parabolic trajectory influenced by gravity and a randomly shifting wind value. Each shot arcs over or around a central mountain barrier, and explosion damage is calculated based on proximity to each castle's center. The wind changes every turn, forcing constant re-evaluation of firing solutions. The game alternates between player and AI turns, with the AI estimating its own power using physics-based calculations with a randomized error margin.

Technically, the game implements a full ballistic physics simulation with wind drag, gravity integration, and blast-radius damage falloff. The trajectory preview system draws 24 predicted positions accounting for wind and gravity, giving the player visual feedback before firing. The AI opponent uses an inverse ballistic formula to estimate required power from distance and angle, adding randomness for difficulty variation.

## Build and Run

```bash
moon build --target native raylib_castle_siege_artillery_2026/
./_build/native/debug/build/raylib_castle_siege_artillery_2026/raylib_castle_siege_artillery_2026.exe
```

## Controls

- **A / Left Arrow**: Decrease cannon angle
- **D / Right Arrow**: Increase cannon angle
- **W / Up Arrow**: Increase shot power
- **S / Down Arrow**: Decrease shot power
- **Space**: Fire projectile
- **R**: Restart / rematch
- **Mouse Click (Touch UI)**: On-screen buttons for ANG-, ANG+, POW-, POW+, and FIRE

## How to Play

You control the left (blue-gray) castle and must destroy the right (red) enemy castle. Both castles start with 240 HP. Each round, you adjust your cannon's angle and power, then fire. A trajectory preview (dotted arc) shows the predicted path of your shot based on current angle, power, and wind.

After you fire, the projectile follows a physics-simulated arc affected by gravity (360 units/s^2) and wind. On impact with the ground, the mountain, or a castle, an explosion occurs. Damage is calculated based on distance from each castle's center -- closer hits deal more damage (up to about 50 damage), while shots landing more than 134 units away deal none.

After your shot resolves, the AI enemy calculates its own angle (random 30-60 degrees) and power (estimated from distance, angle, and wind with some randomness), then fires back. Wind changes randomly each turn (range -130 to +130), so you must constantly adapt.

The game ends when either castle reaches 0 HP. If both are destroyed simultaneously, it is a draw. Press R to restart at any time.

## Public API Reference

### Package `raylib_castle_siege_artillery_2026`

> Main entry point and complete game implementation (single-file architecture).

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width in pixels |
| `sh` | `Int` | `820` | Screen height in pixels |
| `ground_y` | `Int` | `640` | Y coordinate of the ground level |
| `gravity` | `Float` | `360.0` | Gravitational acceleration for projectile physics |
| `castle_w` | `Int` | `120` | Castle width in pixels |
| `castle_h` | `Int` | `130` | Castle height in pixels |
| `player_x` | `Int` | `90` | X position of the player's castle |
| `enemy_x` | `Int` | `1070` | X position of the enemy's castle (sw - 210) |
| `mountain_x` | `Int` | `568` | X position of the central mountain (sw/2 - 72) |
| `mountain_w` | `Int` | `144` | Mountain width in pixels |
| `mountain_h` | `Int` | `220` | Mountain height in pixels |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value between a low and high bound |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point (px, py) is inside a rectangle (rx, ry, rw, rh) |
| `deg2rad` | `(Float) -> Double` | Converts degrees to radians |
| `sinf_deg` | `(Float) -> Float` | Returns the sine of an angle given in degrees |
| `cosf_deg` | `(Float) -> Float` | Returns the cosine of an angle given in degrees |
| `random_wind` | `() -> Float` | Generates a random wind value between -130 and 130 |
| `launch` | `(Bool, Float, Float, Float, Float) -> (Float, Float, Float, Float)` | Computes initial projectile position and velocity from origin, angle, and power; `from_left` determines direction |
| `blast_damage` | `(Float, Float, Float, Float) -> Int` | Calculates explosion damage based on distance from blast point to castle center; 0 beyond 134 units |
| `estimate_enemy_power` | `(Float, Float, Float) -> Float` | AI function estimating required power from distance, angle, and wind with randomized error |
| `main` | `() -> Unit` | Entry point: initializes window, runs the game loop with input, physics, AI, and rendering |

## Architecture

### Package Structure

```
raylib_castle_siege_artillery_2026/
├── main.mbt              — Complete game: constants, math utilities, physics, AI, input, rendering, game loop
└── moon.pkg              — Package config with raylib and math imports
```

This is a single-file game with all logic contained in `main.mbt`. Constants are defined as top-level `let` bindings, utility functions handle math operations, and the `main` function contains the entire game loop with mutable local state variables.

### Data Flow

1. **Input Phase**: During the player's turn, `is_key_down` checks for A/D/W/S/Arrow keys modify `player_angle` and `player_power`. Mouse clicks on the on-screen touch buttons provide an alternative input method. Pressing Space or clicking FIRE triggers `launch()`.
2. **Physics Phase**: When `shot_active` is true, the projectile's velocity is updated each frame with wind drag (`shot_vx += wind * dt * 0.20`) and gravity (`shot_vy += gravity * dt`), then position is integrated. Collision checks test against screen bounds, ground, mountain, and both castles using `inside_rect`.
3. **Impact Phase**: On collision, `blast_damage` computes damage to both castles based on proximity. HP is reduced, win/loss conditions are checked, and turns alternate. Wind is re-randomized.
4. **AI Phase**: When `player_turn` is false, the enemy waits 0.95 seconds, then calls `estimate_enemy_power` to calculate its shot parameters and fires via `launch()`.
5. **Render Phase**: Each frame draws the sky gradient, ground, sun, mountain with triangular peak, both castles with turrets, wind indicator, HP bars, trajectory preview dots, active projectile, blast effect, touch UI panel, and status message bar.

### Key Design Patterns

- **Turn-based state machine**: A simple `player_turn` boolean alternates control between player input and AI computation, with `enemy_wait` providing a delay timer before the AI fires.
- **Physics simulation**: Euler integration of projectile motion with gravity and wind forces, capped delta time (`dt > 0.05` guard) for stability.
- **Proximity-based damage**: `blast_damage` uses a linear falloff from 134-unit radius, providing area-of-effect damage that rewards accuracy without requiring direct hits.
- **AI difficulty tuning**: `estimate_enemy_power` uses the inverse ballistic range formula with added random noise (+/-28 units), making the AI competent but imperfect.
- **Trajectory preview**: 24 predicted positions are drawn using the same physics formula, giving the player a visual guide that accounts for wind.

## Improvement & Refinement Plan

1. **Extract game state into a struct**: All game state is stored as mutable local variables in `main` (e.g., `player_hp`, `shot_x`, `wind`, `over`). Encapsulating these into a `Game` struct would improve readability and enable save/load functionality.

2. **Add terrain variety**: The mountain is a fixed rectangle at `mountain_x` with dimensions `mountain_w x mountain_h`. Randomizing mountain position, width, or adding multiple terrain features would increase replayability.

3. **Improve AI sophistication**: `estimate_enemy_power` uses a single inverse formula with uniform random noise. Adding difficulty levels that adjust the noise range (currently +/-28) or implementing learning from previous shots would create more engaging opponents.

4. **Add projectile trail rendering**: The projectile is drawn as two concentric circles at `shot_x, shot_y`. Adding a fading trail of previous positions would improve visual feedback and help players understand wind effects.

5. **Implement damage visualization on castles**: Castle HP is only shown via the HP bar. Drawing cracks, removing turret rectangles, or changing castle color as HP decreases would provide clearer visual feedback of damage state.

6. **Add sound effects**: The game has no audio. Adding firing, explosion (`blast_t > 0.0` events), and wind sounds would significantly enhance the experience.

7. **Refactor collision detection**: The `inside_rect` function performs point-in-rectangle tests sequentially. The mountain collision could be improved to use the actual triangular peak shape rather than just the rectangular base, matching the visual representation.
