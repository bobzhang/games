# Sky Convoy Defense 2026

A turret defense game where the player controls a ground-based anti-air turret protecting a moving convoy from waves of hostile drones across three escalating sectors. The game combines classic artillery mechanics (angle-based aiming with projectile physics) with an escort mission structure, requiring the player to balance turret positioning with precise aim as drones approach from both sides of the screen.

The convoy consists of three trucks that move rightward along a highway, progressing through the level as a progress bar fills. Three drone types -- small scouts (1 HP), medium bombers (2 HP), and heavy gunships (3 HP) -- spawn from screen edges and seek the convoy's position. Drones periodically drop bombs that fall with gravity toward the highway, and any drone that reaches the convoy directly also deals significant collision damage. Between sectors, the convoy partially heals, but drone spawn rates and bomb speeds increase.

The game supports both keyboard and touch/mouse controls, with on-screen buttons for left/right movement, aim adjustment, and firing. A mountainous landscape with a gradient sky, sun, and highway provide the visual backdrop, while explosion effects mark drone kills and bomb impacts.

## Build and Run

```bash
moon build --target native sky_convoy_defense_2026/
./_build/native/debug/build/sky_convoy_defense_2026/sky_convoy_defense_2026.exe
```

## Controls

- **A / Left Arrow**: Move turret left
- **D / Right Arrow**: Move turret right
- **W / Up Arrow**: Increase aim angle (aim higher)
- **S / Down Arrow**: Decrease aim angle (aim lower)
- **Space / J / K**: Fire bullet
- **R**: Restart mission
- **Mouse/Touch**: On-screen LEFT, RIGHT, AIM-, AIM+, and FIRE buttons

## How to Play

Defend a three-truck convoy as it progresses through 3 sectors of increasing difficulty. The convoy travels along a highway near the bottom of the screen, and your turret sits on the road surface.

**Turret**: The turret moves horizontally at 300 units/s (clamped to x=42 through x=1238). The aim angle adjusts at 96 degrees/s and is clamped between 20 and 160 degrees (where 90 is straight up). Bullets fire from the barrel tip at 660 units/s in the aimed direction with a 0.16s cooldown and 1.7s lifetime.

**Drones**: Three types spawn from screen edges:
- **Small drones** (kind 0, yellow circles): 1 HP, 146+ speed, 16 collision damage, drop bombs every 0.7-1.35s. Worth 35 points.
- **Medium drones** (kind 1, orange rectangles): 2 HP, 118+ speed, 24 collision damage, drop bombs every 0.7-1.35s. Worth 55 points.
- **Heavy drones** (kind 2, red rectangles): 3 HP, 96+ speed, 32 collision damage, drop bombs every 0.45-0.95s. Worth 85 points.

Drone speed increases with sector number. Drones seek the convoy's center position with steering behavior, adjusting their velocity toward a point above the convoy.

**Bombs**: Dropped by drones, bombs fall with 62 units/s^2 gravity acceleration and a base downward speed that increases per sector. Bombs that hit the convoy area deal 10-20 random damage and trigger a hit flash. Bombs that miss the convoy are deactivated on passing the highway.

**Convoy**: Starts with 300 HP. Progress fills based on distance (56 + sector*12 units/s). When progress reaches 1000 units, the sector advances. Between sectors, convoy HP is restored by 60 (capped at 320), and all projectiles are cleared. If convoy HP reaches 0, the mission fails. Completing all 3 sectors wins the game.

**Spawn timing**: Drones spawn at intervals starting around 0.58-1.12s, decreasing by 0.08-0.10 per sector, with a minimum of 0.26-0.48s.

## Public API Reference

### Package `sky_convoy_defense_2026`

> Main entry point and complete game implementation in a single file.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width in pixels |
| `sh` | `Int` | `800` | Screen height in pixels |
| `ground_y` | `Int` | `642` | Y-position of the ground/highway |
| `max_bullets` | `Int` | `140` | Maximum bullet pool size |
| `max_drones` | `Int` | `64` | Maximum drone pool size |
| `max_bombs` | `Int` | `96` | Maximum bomb pool size |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Bullet` | `x`, `y`, `vx`, `vy`, `ttl`, `active` | A turret projectile with velocity and time-to-live |
| `Drone` | `x`, `y`, `vx`, `vy`, `hp`, `kind`, `drop_cd`, `active` | An enemy drone with movement, health, type, and bomb drop cooldown |
| `Bomb` | `x`, `y`, `vy`, `active` | A falling bomb with vertical velocity |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value between low and high bounds |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Point-in-rectangle test for touch controls |
| `deg2rad` | `(Float) -> Double` | Converts degrees to radians |
| `sinf_deg` | `(Float) -> Float` | Sine of an angle in degrees |
| `cosf_deg` | `(Float) -> Float` | Cosine of an angle in degrees |
| `clear_bullets` | `(Array[Bullet]) -> Unit` | Deactivates and resets all bullets |
| `clear_drones` | `(Array[Drone]) -> Unit` | Deactivates and resets all drones |
| `clear_bombs` | `(Array[Bomb]) -> Unit` | Deactivates and resets all bombs |
| `spawn_bullet` | `(Array[Bullet], Float, Float, Float) -> Unit` | Fires a bullet from position at the given angle in degrees |
| `spawn_bomb` | `(Array[Bomb], Float, Float, Int) -> Unit` | Creates a falling bomb at position with sector-scaled speed |
| `spawn_drone` | `(Array[Drone], Int) -> Unit` | Spawns a random drone type from a random screen edge |
| `random_spawn_cd` | `(Int) -> Float` | Calculates next spawn interval based on current sector |
| `convoy_center` | `(Float) -> Float` | Returns convoy center x-position based on progress |
| `main` | `() -> Unit` | Entry point: window init, game loop, input, physics, combat, rendering |

## Architecture

### Package Structure

```
sky_convoy_defense_2026/
├── main.mbt              -- Complete game: entry point, types, logic, rendering
└── moon.pkg              -- Package config with raylib and math imports
```

This is a single-file game with all types, helper functions, game logic, and rendering in `main.mbt`. Game state is managed through local mutable variables in the `main` function. The `math` package is imported for trigonometric functions used in angle-based aiming.

### Data Flow

1. **Input**: Movement and aim keys (WASD/Arrows) are polled with `is_key_down` for continuous input. Fire keys (Space/J/K) are also polled with `is_key_down`. Touch/mouse input overlays: clicking on-screen button rectangles sets the corresponding input flags. All inputs are combined with OR logic, so keyboard and touch work simultaneously.

2. **Turret mechanics**: The turret moves horizontally at 300 units/s. The aim angle (20-160 degrees) determines the barrel orientation. Bullets spawn from the barrel tip (40 pixels from turret center in the aimed direction) and travel at 660 units/s using `cosf_deg(aim)` and `-sinf_deg(aim)` for x and y velocity.

3. **Drone AI**: Drones spawn from screen edges with a random y-position (78-290) and seek the convoy center. A steering behavior blends current velocity toward a desired velocity aimed at the convoy, creating curved approach paths. Each drone maintains a `drop_cd` timer; when it reaches zero, a bomb is spawned below the drone and the timer resets based on drone kind.

4. **Collision**: Bullet-drone collision uses squared-distance checks against kind-dependent radii (15/19/23). Drone-convoy collision checks if the drone's x is within the convoy bounds and y has reached the highway. Bomb-convoy collision checks if the bomb has fallen to highway level and is within convoy bounds.

5. **Sector progression**: Progress advances each frame at a sector-dependent rate. At 1000 units of progress, the sector increments, convoy HP is partially restored (+60, cap 320), all entities are cleared, and the spawn timer resets. After completing sector 3, the mission succeeds.

6. **Rendering**: Layers from back to front: gradient sky with sun circle, three mountain triangles, highway with dashes, convoy trucks with windows and taillights, turret base and barrel, drones by type, falling bombs, bullets, explosion effects, HUD bar (sector, score, aim angle, convoy HP, route progress), on-screen touch controls, and game-over/victory overlay.

### Key Design Patterns

- **Object pool pattern**: Bullets (140), drones (64), and bombs (96) use pre-allocated arrays with `active` flags. Spawning scans for the first inactive slot.
- **Angle-based projectile physics**: Unlike most games in this collection that use Cartesian velocities, this game uses degree-based aim angles converted via `sinf_deg`/`cosf_deg` for turret barrel orientation and bullet velocity calculation.
- **Sector-based difficulty**: Three sectors with increasing drone speed (+14/+12/+10 per sector by type), faster bomb speeds (+24 per sector), and tighter spawn intervals. Between sectors, the convoy partially heals, creating a breather moment.
- **Hybrid input system**: Keyboard and on-screen touch buttons both feed into the same movement/aim/fire flags, enabling the game to work on both desktop and touch-capable platforms.
- **Steering-based drone AI**: Drones use a velocity blending approach (90% current + 10% desired) to smoothly curve toward the convoy rather than flying in straight lines, creating more organic and challenging attack patterns.
- **Delta-time clamped updates**: Frame time is capped at 0.05s to prevent physics issues during frame spikes.

## Improvement & Refinement Plan

1. **Extract a Game struct and internal packages**: All state is in local `mut` variables across a 1000+ line `main` function. Refactoring into a Game struct with `internal/types`, `internal/game`, and `internal/render` packages would dramatically improve maintainability and match the structure of other games in this collection.

2. **Add bullet-bomb interception**: Currently, bullets can only hit drones. Allowing bullets to destroy falling bombs mid-air would add a secondary defensive mechanic and reward precise aim, especially in later sectors when bomb density is high.

3. **Implement turret upgrade system**: Between sectors, the player could choose upgrades (faster fire rate, wider bullet spread, increased bullet speed) using score as currency. This would add progression depth and make score accumulation more meaningful.

4. **Add drone formation patterns**: Currently, drones spawn individually from random edges. Introducing formation patterns (V-formations, strafing runs, dive bombers) would create more varied and strategic combat encounters.

5. **Replace the first-found pool allocation with a better strategy**: The `spawn_bullet`, `spawn_bomb`, and `spawn_drone` functions use a `done` flag with `continue` to break out of the loop, which is an awkward pattern. Using an early `break` or a separate allocation function (as `alloc_raider` does in the Silkroad game) would be cleaner.

6. **Add visual convoy damage states**: The three convoy trucks always look the same regardless of HP. Adding visual damage indicators (smoke at <60% HP, fire at <30% HP) would give the player immediate visual feedback about convoy health beyond the HP bar.

7. **Implement a combo scoring system**: Shooting down multiple drones in rapid succession (within 1-2 seconds) could award combo multiplier bonuses. This would reward accurate rapid fire and make skilled play more rewarding.
