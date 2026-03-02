# Glacier Rescue 2026

A helicopter rescue game set across a vast 4200x2800 glacier wilderness with scrolling camera. The player pilots a rescue helicopter through dynamic storm systems, locating stranded survivors scattered across ice fields, picking them up (up to 4 at a time), and ferrying them back to a base camp while managing fuel, hull integrity, and cold exposure.

The core loop involves scanning the terrain for survivor beacons, flying close to pick them up, then returning to base to offload passengers and refuel. Environmental hazards include drifting ice chunks, sweeping avalanches, and a persistent storm system with shifting wind, gusts, and periodic whiteout conditions. Players can deploy flares to reveal and warm nearby survivors, and use a speed boost that burns extra fuel. Each level requires rescuing an increasing number of survivors (12 + 4 per level) within a shrinking time limit, across up to 5 difficulty levels.

The game uses FixedArray pools for all entities, a dynamic storm system that adjusts wind direction and intensity on timers, and a cold/heat model where survivors gradually freeze to death and the helicopter takes hull damage when cold exposure exceeds 100%.

## Build and Run

```bash
moon build --target native raylib_glacier_rescue_2026/
./_build/native/debug/build/raylib_glacier_rescue_2026/raylib_glacier_rescue_2026.exe
```

## Controls

- **W / Up Arrow**: Fly up
- **A / Left Arrow**: Fly left
- **S / Down Arrow**: Fly down
- **D / Right Arrow**: Fly right
- **Left Shift / Space**: Boost (1.4s burst of speed, 3.4s cooldown, costs extra fuel)
- **E**: Drop flare (reveals and warms survivors in expanding radius, 5.2s cooldown)
- **R**: Restart current level
- **F11**: Toggle fullscreen
- **Enter / Space**: Start game, advance to next mission, retry
- **Touch D-pad**: On-screen directional controls (L/R/U/D)
- **Touch BOOST button**: Activate speed boost
- **Touch FLARE button**: Deploy flare

## How to Play

1. **Locate survivors**: Survivors are scattered across the map with pulsing beacon indicators. They slowly freeze over time (freeze rate: 2.4 + storm severity * 4.1 per second). When freeze reaches 100%, they are lost. Flares within range reduce freeze rate by 4.2.

2. **Pick up survivors**: Fly within 34 units of a non-carried survivor while carrying fewer than 4. Each pickup awards 90 points. Carried survivors follow the helicopter and their freeze timer reverses.

3. **Return to base**: The base is a marked circle in the bottom-left of the map. When near base at low speed with passengers onboard, all carried survivors are automatically delivered. Each delivery awards 220 points. Being near base also refuels (+26/s), repairs hull (+6.5/s), and reduces cold (-22/s).

4. **Manage resources**: Fuel drains based on speed, boosting, and storm severity. Hull takes damage from hazard collisions and from cold exposure exceeding 100%. When hull reaches 0 or time expires, the mission fails.

5. **Avoid hazards**: Ice chunks (kind 0, smaller) and debris (kind 1, larger/faster) bounce around the map influenced by wind. Collisions push the helicopter and deal hull damage. Avalanches sweep horizontally across the map, dealing continuous damage while inside.

6. **Win condition**: Rescue the mission target (12/16/20/24/28 for levels 1-5) to complete the mission. Bonus score is awarded for remaining time and survivors not lost.

## Public API Reference

### Package `raylib_glacier_rescue_2026`

> Main entry point and all game logic in a single file.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width |
| `sh` | `Int` | `800` | Screen height |
| `world_w` | `Float` | `4200.0` | World width in game units |
| `world_h` | `Float` | `2800.0` | World height in game units |
| `max_survivors` | `Int` | `44` | Maximum survivor pool size |
| `max_hazards` | `Int` | `52` | Maximum hazard pool size |
| `max_particles` | `Int` | `1100` | Maximum particle pool size |
| `max_flares` | `Int` | `8` | Maximum simultaneous flares |
| `max_avalanches` | `Int` | `10` | Maximum simultaneous avalanches |
| `base_x` | `Float` | `280.0` | Base camp X coordinate |
| `base_y` | `Float` | `world_h - 260.0` | Base camp Y coordinate |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Helicopter` | `x`, `y`, `vx`, `vy`, `rotor`, `fuel`, `hull`, `cold`, `boost_t`, `boost_cd`, `flare_cd`, `onboard`, `rescued`, `lost`, `score` | Player helicopter with physics, resources, cooldowns, and mission stats |
| `Survivor` | `active`, `carried`, `x`, `y`, `panic_t`, `freeze`, `beacon_t` | Stranded person with freeze timer and beacon animation |
| `Hazard` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `r`, `spin`, `life` | Drifting ice/debris obstacle with collision radius |
| `Avalanche` | `active`, `x`, `y`, `w`, `speed`, `life` | Horizontal sweep hazard that pushes the helicopter |
| `Flare` | `active`, `x`, `y`, `r`, `t`, `life` | Expanding light/heat circle that warms survivors and reduces cold |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `size`, `t`, `life`, `kind` | Visual effect particle (snow, warm glow, engine trail) |
| `Storm` | `wind_x`, `wind_y`, `shift_t`, `gust_t`, `whiteout_t`, `severity` | Dynamic weather system with shifting wind and whiteout events |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between low and high bounds |
| `lerpf` | `(Float, Float, Float) -> Float` | Linear interpolation between two floats |
| `randf` | `(Float, Float) -> Float` | Random float in range using raylib RNG |
| `sinf` | `(Float) -> Float` | Sine function wrapper |
| `cosf` | `(Float) -> Float` | Cosine function wrapper |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two 2D points |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Point-in-rectangle test for touch controls |
| `emit_particle` | `(FixedArray[Particle], Float, Float, Float, Float, Float, Float, Int) -> Unit` | Activates first inactive particle with given parameters |
| `burst_particles` | `(FixedArray[Particle], Float, Float, Int, Float, Int) -> Unit` | Spawns a radial burst of particles at a position |
| `spawn_survivors` | `(FixedArray[Survivor], Int) -> Unit` | Distributes survivors across the map scaled by level (20 + level * 4) |
| `spawn_hazards` | `(FixedArray[Hazard], Int) -> Unit` | Places hazards with randomized positions and velocities (18 + level * 5) |
| `spawn_avalanche` | `(FixedArray[Avalanche], Int) -> Unit` | Creates a horizontal sweep avalanche at a random Y position |
| `spawn_flare` | `(FixedArray[Flare], Float, Float) -> Unit` | Deploys a flare at the given position with initial radius 36 |
| `draw_bar` | `(Int, Int, Int, Int, Float, @raylib.Color, @raylib.Color) -> Unit` | Renders a fill-ratio progress bar with foreground and background colors |
| `draw_touch_controls` | `(Bool) -> Unit` | Draws on-screen D-pad, BOOST, and FLARE buttons |
| `main` | `() -> Unit` | Entry point: window init, entity allocation, game loop with state machine |

## Architecture

### Package Structure

```
raylib_glacier_rescue_2026/
├── main.mbt              — All game logic, physics, weather, rendering, and entry point
└── moon.pkg              — Package config with raylib and math imports
```

Single-file architecture with top-down organization: constants, struct definitions, utility functions, entity spawning, UI drawing helpers, and the main game loop. Uses FixedArray instead of Array for all entity pools, which is a notable difference from many other games in this repository.

### Data Flow

1. **Input**: Keyboard and touch input is read each frame. Touch positions are tested against on-screen button regions via `inside_rect`. All input flags are unified into boolean variables (`move_l`, `move_r`, `boost_down`, `flare_press`).

2. **Storm update**: The storm system adjusts wind direction periodically (`gust_t` timer) and randomly triggers whiteout events. Wind affects both helicopter and hazard movement.

3. **Helicopter physics**: Acceleration is computed from input direction, modified by boost multiplier and storm wind. Velocity undergoes drag and is clamped to max speed. The helicopter bounces off world boundaries. Fuel drains continuously based on speed, boost, and storm severity, but recharges near base.

4. **Entity updates**: Hazards drift with wind influence and bounce off world edges. Avalanches sweep horizontally. Survivors' freeze timers tick up (reduced by nearby flares). Flares expand in radius and expire. Collision checks run between helicopter and hazards/avalanches.

5. **Pickup/delivery**: Survivors within 34 units are picked up (max 4 onboard). Near base at low speed, all carried survivors are delivered. The `reset_round` closure handles level initialization.

6. **Camera**: A simple camera follows the helicopter, clamped to world bounds. Screen shake offsets are added during impacts.

### Key Design Patterns

- **FixedArray pools**: All entity pools use `FixedArray` rather than `Array`, providing compile-time-known sizes and avoiding heap allocation during gameplay.
- **Dynamic storm system**: The `Storm` struct creates emergent gameplay through shifting wind vectors, gust timers, and stochastic whiteout events, all parameterized by `severity` which scales with level.
- **Closure-based reset**: `reset_round` is defined as a closure capturing all game state variables, allowing clean level resets without passing dozens of parameters.
- **Multi-resource management**: Fuel, hull, and cold form an interconnected resource triangle. Cold above 100 damages hull; base proximity restores all three; flares reduce cold for both helicopter and survivors.
- **Scrolling camera with shake**: Camera position is computed from helicopter position and clamped to world bounds, with additive shake offset during impacts.

## Improvement & Refinement Plan

1. **Extract a GameState enum**: The integer `state` variable (0=menu, 1=play, 2=win, 3=lose) should be replaced with a named enum for clarity, especially since the state transitions interact with `transition_t` and `announce_t`.

2. **Split FixedArray initialization from gameplay**: The `reset_round` closure is defined inside `main` and captures many mutable locals. Extracting game state into a struct would make initialization and reset cleaner and enable splitting into packages.

3. **Add minimap**: The world is 4200x2800 but the screen is 1280x800, so the player can only see about 30% of the map. A corner minimap showing survivor positions and base location would reduce frustrating blind searching.

4. **Balance survivor freeze rates**: Survivors at the edges of the map freeze at the same rate as those near base. Adding distance-based cold zones or safe pockets would create more strategic rescue routing.

5. **Implement hazard respawning**: Hazards are spawned once via `spawn_hazards` and their `life` timer just randomizes their direction, not their existence. Adding actual despawn/respawn would keep the field dynamic across the full mission duration.

6. **Add fuel pickup mechanic**: Currently the only way to refuel is returning to base. Adding fuel drops or secondary stations would enable longer excursions and reduce back-and-forth tedium on higher levels.

7. **Decouple beacon particle spawning from rendering**: Survivor beacon particles are spawned during the render loop (`survivor.beacon_t` check happens inside the drawing section), mixing update logic with rendering.
