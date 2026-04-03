# Mine Cart Mayhem 2026

Mine Cart Mayhem 2026 is a single-file endless runner set in a dark underground mine shaft. The player rides a mine cart along three parallel horizontal rails while obstacles and coins scroll in from the right at ever-increasing speed. The visual style is minimalist -- brown rocks, maroon walls, gold coins, and a sky-blue cart rendered as rectangles and circles on a near-black background.

The core gameplay loop combines lane switching with jumping. Low rocks can be cleared by jumping (Space/J), while tall walls require the player to switch to a different rail (W/S or Up/Down). Coins sitting above the rails can be collected for bonus score. Speed increases linearly over time (`speed += dt * 8.0`), tightening reaction windows. Each hazard collision costs one of three lives and deducts points, and losing all lives ends the run. Score accumulates passively from distance traveled and actively from coin pickups.

The game is implemented entirely in a single `main.mbt` file with no internal packages, using a pre-allocated object pool of 120 `Hazard` structs with `alive` flags to avoid runtime allocation during play. Hazards spawn every 0.36 seconds with randomized lane and type distribution (16% coin, 42% low rock, 42% high wall).

## Build and Run

```bash
moon build --target native mine_cart_mayhem_2026/
./_build/native/debug/build/mine_cart_mayhem_2026/mine_cart_mayhem_2026.exe
```

## Controls

- **W / Up Arrow**: Switch to the upper rail
- **S / Down Arrow**: Switch to the lower rail
- **Space / J**: Jump (clears low rocks; high walls require a higher jump threshold)
- **R**: Restart the run (resets all state)

## How to Play

Your mine cart starts on the middle rail (lane 1 of 0-2) at x=220, rolling forward at 280 pixels/second. Speed increases by 8 units per second continuously, making hazards approach faster over time.

**Hazards** spawn every 0.36 seconds at the right edge of the screen on a random lane. There are three types:
- **Low rocks** (kind 0, 42% chance): Brown rectangles sitting on the rail. Jump over them -- your jump height (`jump_y`) must reach at least 24 pixels to clear them. Getting hit costs 1 life and 18 score.
- **High walls** (kind 1, 42% chance): Tall maroon rectangles. You need to either switch lanes to avoid them entirely, or have a jump height of at least 72 pixels (very high jump). Getting hit costs 1 life and 28 score.
- **Coins** (kind 2, 16% chance): Gold circles floating above the rail. Collecting one awards 1 coin and 35 bonus score.

**Jumping**: Pressing Space or J initiates a jump with an upward velocity of 520 units/second. Gravity pulls the cart back down at 980 units/second squared. The jump arc peaks around ~138 pixels, which clears both low rocks (threshold 24px) and high walls (threshold 72px) if timed well. You cannot double-jump -- a new jump can only start when `jump_y` is at or below 0.

**Scoring**: Score increases passively each frame by `speed * dt * 0.15`. Coin pickups add 35 points. Rock/wall hits subtract 18/28 points respectively. Distance is tracked separately in meters (`speed * dt` accumulated).

**Lives**: You start with 3 lives. Each collision removes 1 life. When lives reach 0, the run ends with a "RUN OVER" overlay. Press R to restart.

**HUD**: The top of the screen shows the title, score, distance in meters, coin count, and remaining lives (red when at 1 life, green otherwise). The bottom bar displays context messages about recent events.

## Public API Reference

### Package `mine_cart_mayhem_2026`

> Main entry point and complete game implementation in a single file.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1120` | Screen width in pixels |
| `sh` | `Int` | `720` | Screen height in pixels |
| `lane_count` | `Int` | `3` | Number of parallel rails |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Hazard` | `alive`, `x`, `lane`, `kind` | Object-pooled obstacle/coin entity with active flag, horizontal position, lane index, and type (0=rock, 1=wall, 2=coin) |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `lane_y` | `(Int) -> Float` | Converts a lane index (0-2) to the vertical pixel position of that rail: `250.0 + lane * 140.0` |
| `reset_hazards` | `(Array[Hazard]) -> Unit` | Deactivates all hazards in the pool by setting `alive` to false |
| `spawn_hazard` | `(Array[Hazard], Int, Int) -> Unit` | Activates the first inactive hazard in the pool, placing it at the right screen edge on the given lane with the given kind |
| `main` | `() -> Unit` | Entry point: creates a 1120x720 window at 60 FPS, allocates a 120-element hazard pool, runs the game loop with input handling, physics, spawning, collision detection, and rendering |

## Architecture

### Package Structure

```
mine_cart_mayhem_2026/
├── main.mbt              -- Complete game: entry point, logic, rendering
└── moon.pkg              -- Package config, raylib import
```

This game uses a single-file architecture with no internal packages. All game state is held in local variables within `main`, and all logic (input, physics, spawning, collision, rendering) runs sequentially in a single `while` loop. This is appropriate for the game's small scope.

### Data Flow

1. **Input**: Each frame, `is_key_pressed` checks detect lane-switch (W/S/Up/Down), jump (Space/J), and restart (R) inputs. Delta time is capped at 0.05s to prevent physics tunneling.
2. **Physics**: Jump velocity and position are updated with simple Euler integration (`jump_v -= 980 * dt`, `jump_y += jump_v * dt`). Speed increases linearly (`speed += dt * 8.0`).
3. **Spawning**: A `spawn_tick` timer accumulates delta time. Every 0.36 seconds, a random lane and type are selected via `get_random_value`, and `spawn_hazard` activates a pooled hazard.
4. **Movement & Collision**: All active hazards scroll left (`x -= speed * dt`). Off-screen hazards are deactivated. For hazards on the player's lane within 34 pixels of the cart, collision is checked against jump height thresholds (24px for rocks, 72px for walls). Coins are collected on contact.
5. **Rendering**: Rails are drawn as horizontal lines with brown background bands. Hazards are drawn as colored rectangles (rocks/walls) or gold circles (coins). The cart is drawn as layered rectangles with wheel circles, offset vertically by `jump_y`. HUD text overlays show score, distance, coins, and lives.

### Key Design Patterns

- **Object pool pattern**: The 120-element `Hazard` array is pre-allocated at startup. `spawn_hazard` scans for the first `alive == false` entry, reusing it rather than allocating new objects. This avoids garbage collection pressure during gameplay.
- **Delta-time capping**: `dt` is capped at 0.05s (20 FPS minimum equivalent) to prevent hazards from tunneling through the cart during frame rate drops.
- **Single-file simplicity**: All game state lives as local `mut` variables in `main`. This avoids struct overhead for a game with straightforward linear logic and no state machine beyond the `over` flag.
- **Threshold-based collision**: Rather than full AABB intersection, collision uses a simple distance check (`dx < 34.0`) combined with jump-height thresholds (24px for rocks, 72px for walls) to determine whether the cart clears an obstacle.

## Improvement & Refinement Plan

1. **Extract game state into a struct**: All game state (cart_lane, jump_y, speed, score, lives, etc.) is held in local variables within `main`. Extracting these into a `Game` struct would improve readability and enable splitting the code into separate functions for input, update, and rendering.
2. **Add visual lane-switch animation**: Lane changes are instantaneous (`cart_lane = cart_lane - 1`). Adding a smooth vertical interpolation between `lane_y(old)` and `lane_y(new)` would make switching feel more polished and give the player visual feedback.
3. **Vary spawn frequency with speed**: The spawn interval is fixed at 0.36 seconds regardless of speed. Reducing the interval as speed increases (e.g., `0.36 - speed * 0.0002`) would maintain difficulty scaling that matches the faster approach velocity.
4. **Add a high-score persistence system**: Score and distance reset completely on restart. Storing the best score in a file or global variable across runs would add replay motivation.
5. **Introduce coin streak bonus**: Collecting coins awards a flat 35 points each. Adding a streak multiplier for consecutive coins without taking damage would reward skilled play and create a risk/reward dynamic for chasing coins on dangerous lanes.
6. **Improve wall avoidance feedback**: The hint text says "High walls need lane switch or high jump timing" but the jump height threshold (72px) is very close to the jump peak (~138px), making the timing extremely tight. Consider either making walls unjumpable (forcing lane switches) or adding a visual indicator of whether the current jump height is sufficient.
7. **Add parallax background scrolling**: The background is a static dark color. Adding scrolling mine shaft elements (support beams, rock textures) at different parallax speeds would enhance the sense of forward motion and depth.
