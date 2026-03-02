# raylib_orbital_salvage_ops_2026

A top-down space salvage game where you pilot a ship through an orbital debris field, collecting scrap with a tractor beam, fighting hostile drones, and depositing cargo at a beacon.

## Build and Run

```bash
cd examples && moon build --target native raylib_orbital_salvage_ops_2026/
cd examples && ./_build/native/debug/build/raylib_orbital_salvage_ops_2026/raylib_orbital_salvage_ops_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move ship
- **J / Space**: Fire weapons (hold)
- **K**: Tractor beam (hold to pull in nearby scrap)
- **L**: EMP pulse (area stun)
- **Right Shift**: Boost
- **Enter**: Start game
- **F11**: Toggle borderless windowed

## How to Play

- Fly through a large orbital debris field collecting scrap metal
- Use the tractor beam to pull scrap toward your ship
- Fight off hostile drones, mines, and wrecks that attack your ship
- Deposit collected cargo at the salvage beacon to bank your haul
- Reach the salvage target (120 scrap deposited) to complete the operation
- Manage HP, energy, and weapon heat while building kill combos

## Public API Reference

### Package `raylib_orbital_salvage_ops_2026`

> Main entry point.

The `main` function initializes the window, creates all game entity arrays (`Player`, `Drone`, `Bullet`, `Scrap`, `Mine`, `Particle`, `Wreck`, `Boss`), and runs the frame loop calling update and draw logic each frame until the window closes.

#### Types

| Type | Description |
|------|-------------|
| `Player` | Player ship state: position, velocity, facing direction, HP, energy, weapon heat, cooldowns, cargo, score, and combo. |
| `Drone` | Enemy drone: position, velocity, HP, fire cooldown, and kind (0=scout, 1=fighter, 2=heavy). |
| `Bullet` | Projectile for both player and drone teams: position, velocity, damage, radius, and remaining lifetime. |
| `Scrap` | Collectible salvage piece: position, velocity, value, animation timer, and tractor-beam magnet flag. |
| `Mine` | Proximity explosive: position, velocity, blast radius, arming timer, and lifetime. |
| `Wreck` | Static debris obstacle: position and collision radius. |
| `Particle` | Visual effect particle: position, velocity, size, lifetime, and kind for color selection. |
| `Boss` | Boss ship: position, velocity, HP, max HP, fire cooldown, drone-spawn cooldown, and animation timer. |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value to the inclusive range `[lo, hi]`. |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float. |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Returns the squared Euclidean distance between two points. |
| `randf` | `(Float, Float) -> Float` | Returns a uniform random float in `[lo, hi]` using raylib RNG. |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Returns true if point `(px, py)` lies within the given rectangle. |
| `drone_radius` | `(Int) -> Float` | Returns the collision radius for a drone of the given kind. |
| `drone_hp` | `(Int, Int) -> Float` | Returns the starting HP for a drone of given kind at the given level. |
| `clear_drones` | `(Array[Drone]) -> Unit` | Deactivates and zeroes all drones in the array. |
| `clear_bullets` | `(Array[Bullet]) -> Unit` | Deactivates and zeroes all bullets in the array. |
| `clear_scrap` | `(Array[Scrap]) -> Unit` | Deactivates and zeroes all scrap pieces in the array. |
| `clear_mines` | `(Array[Mine]) -> Unit` | Deactivates and zeroes all mines in the array. |
| `clear_particles` | `(Array[Particle]) -> Unit` | Deactivates and zeroes all particles in the array. |
| `clear_wrecks` | `(Array[Wreck]) -> Unit` | Deactivates and zeroes all wrecks in the array. |
| `add_drone` | `(Array[Drone], Int, Float, Float, Int) -> Bool` | Activates the first free drone slot at position `(x, y)` with stats for the given kind and level. |
| `add_bullet` | `(Array[Bullet], Int, Int, Float, Float, Float, Float, Float, Float, Float) -> Bool` | Activates the first free bullet slot with full physics and damage parameters. |
| `add_scrap` | `(Array[Scrap], Int, Float, Float, Float, Float, Int) -> Bool` | Activates the first free scrap slot at position `(x, y)` with velocity and value. |
| `add_mine` | `(Array[Mine], Float, Float, Float, Float, Float) -> Bool` | Activates the first free mine slot at position `(x, y)` with velocity and blast radius. |
| `add_particle` | `(Array[Particle], Int, Float, Float, Float, Float, Float, Float) -> Bool` | Activates the first free particle slot with full visual parameters. |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Spawns `count` particles in random directions from `(x, y)` at a given speed scale and kind. |
| `push_from_center` | `(Float, Float, Float, Float, Float) -> (Float, Float)` | Returns a push impulse vector directed away from center `(cx, cy)` with given force. |
| `spawn_map_wrecks` | `(Array[Wreck]) -> Unit` | Clears and randomly places all wreck obstacles across the world, avoiding the spawn zone and beacon area. |
| `draw_touch_ui` | `(Int) -> Unit` | Draws the on-screen touch control overlay (movement pad and action buttons) during play state. |
| `main` | `() -> Unit` | Entry point: initialises window, allocates all entity arrays, runs the game loop. |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1366` | Window width in pixels. |
| `sh` | `Int` | `768` | Window height in pixels. |
| `world_w` | `Float` | `3600.0` | Scrollable world width in pixels. |
| `world_h` | `Float` | `2600.0` | Scrollable world height in pixels. |
| `max_drones` | `Int` | `240` | Maximum simultaneous active drones. |
| `max_bullets` | `Int` | `980` | Maximum simultaneous active bullets. |
| `max_scrap` | `Int` | `360` | Maximum simultaneous active scrap pieces. |
| `max_mines` | `Int` | `220` | Maximum simultaneous active mines. |
| `max_particles` | `Int` | `1700` | Maximum simultaneous active particles. |
| `max_wrecks` | `Int` | `120` | Number of static wreck obstacles on the map. |
| `player_radius` | `Float` | `18.0` | Collision radius of the player ship. |
| `target_salvage` | `Int` | `120` | Scrap units that must be deposited to win. |
| `beacon_x` | `Float` | `world_w - 260.0` | X position of the salvage deposit beacon. |
| `beacon_y` | `Float` | `250.0` | Y position of the salvage deposit beacon. |

## Architecture

All game logic is in `main.mbt`. Key design patterns:
- **State machine**: An integer `state` variable drives title (0), play (1), win (2), and game-over (3) screens; transitions happen when `deposited >= target_salvage`, `hp <= 0`, or `timer <= 0`.
- **Top-down scrolling world**: A 3600×2600 world is panned via `cam_x`/`cam_y` camera offsets that follow the player ship.
- **Object pools**: All entities (drones, bullets, scrap, mines, particles) are pre-allocated arrays with an `active` flag; helper functions scan for the first free slot.
- **Tractor beam mechanic**: Holding the tractor key sets `player.tractor_on`; scrap pieces with the magnet flag are pulled toward the ship each frame.
- **Boss encounter**: When `deposited` crosses a threshold and enough drones have been killed, the boss activates, fires spread-shot patterns, and spawns additional drones.
- **Delta-time updates**: All physics, cooldowns, and timers are multiplied by `dt` (capped at 0.033 s) for frame-rate independence.

## Improvement & Refinement Plan

1. **Extract update and render functions**: The `main` function contains all logic in one monolithic loop (~1000 lines). Splitting into `update_game(dt)` and `draw_frame()` functions would improve readability and testability.
2. **Add minimap**: With a 3600×2600 world the player easily loses track of scrap fields and the beacon. A small corner minimap showing scrap density, drone positions, and the beacon would help navigation.
3. **Drone pathfinding**: Drones currently home in directly, making them easy to kite. Introducing simple obstacle avoidance around wreck radii would make encounters more varied.
4. **Configurable difficulty tiers**: `drone_cd`, `mine_cd`, and `scrap_cd` are hardcoded. Exposing easy/normal/hard presets would broaden audience appeal without changing core mechanics.
5. **Sound stubs**: No audio is used. Adding raylib sound effect calls at bullet fire, scrap pickup, mine explosion, and boss death events would significantly improve game feel.
6. **Scrap variety rewards**: All three scrap kinds award 1–3 value uniformly at random. Giving each visual kind a distinct reward range and appearance colour would make the tractor-beam decision more strategic.
7. **Persistent high score**: The best combo (`best_combo`) resets on restart. Saving it to a file between sessions and displaying it on the title screen would provide a long-term goal.
