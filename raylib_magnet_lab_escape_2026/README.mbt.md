# Magnet Lab Escape 2026

A side-scrolling action platformer set in a malfunctioning magnet laboratory spanning 5600 units of hazardous terrain. The player must collect magnetized energy cores and deliver them to a reactor at the far end of the lab while fighting off waves of hostile drones. The game combines platforming, twin-stick shooting, and a unique magnetic polarity mechanic into a tense escape scenario.

The core gameplay loop revolves around using a togglable magnetic field to attract or repel nearby objects -- energy cores, metal boxes, and even enemy projectiles. Cores must be collected and guided to the reactor delivery zone. Five locked gates divide the world into sectors, each requiring a minimum number of delivered cores to open. Drones of three types spawn continuously with escalating difficulty, and the player must balance HP, energy (for magnets and dashing), and weapon heat while racing against a 420-second countdown timer.

The game features a sophisticated physics system where cores and boxes respond to gravity, bounce off platforms and gates, and can be magnetically launched into drones to deal damage. Destroyed boxes drop bonus cores, and defeated drones have a chance to drop cores and boxes. A combo system rewards consecutive drone kills without taking damage.

## Build and Run

```bash
moon build --target native raylib_magnet_lab_escape_2026/
./_build/native/debug/build/raylib_magnet_lab_escape_2026/raylib_magnet_lab_escape_2026.exe
```

## Controls

- **A/D or Left/Right**: Move horizontally
- **W/Up/Space**: Jump (with coyote time and jump buffering)
- **L**: Fire weapon (generates heat, fires in facing direction)
- **J (hold)**: Activate magnet field (drains energy, affects cores/boxes/enemy bolts within range)
- **K**: Toggle magnet polarity between attract (+) and repel (-)
- **Right Shift**: Dash (costs 18 energy, grants brief speed burst and damage reduction, 1s cooldown)
- **R/Enter**: Restart (from win/lose screens)
- **F11**: Toggle fullscreen
- **Touch controls**: On-screen D-pad (L/R/Jump) and action buttons (FIRE/MAG/DASH/POL)

## How to Play

You begin at the left side of a 5600-unit wide laboratory. Your objective is to deliver 120 energy cores to the reactor located near the right edge of the map, within 420 seconds.

The world is divided by five gates at positions 1180, 2120, 3080, 4040, and 4920, requiring 6, 18, 34, 56, and 82 delivered cores respectively to unlock. You cannot pass a closed gate. Cores are scattered throughout the lab and also spawn periodically. Hold J to activate your magnet field (310-unit radius for cores, 290 for boxes, 230 for enemy bolts). Press K to switch between attract and repel polarity -- attract pulls objects toward you, repel pushes them away. Cores delivered to the reactor (within 80 units, moving slowly enough) add to your delivery count and score.

Three drone types appear with increasing frequency: small chasers (kind 0, single shots), medium orbiters (kind 1, dual spread shots), and large heavies (kind 2, powerful single projectiles). Difficulty scales with both deliveries and elapsed time. Destroying drones awards score and builds your combo counter; taking damage resets it. Drones can drop cores (72% chance) and boxes (36% chance) on destruction.

Boxes are metallic objects that can be magnetically thrown into drones to deal 26 damage. Destroyed boxes release bonus cores worth 2-4 points. Cores moving fast enough also damage drones on impact (18 damage).

At level 6+, your weapon fires an additional angled bolt for extra firepower. Manage your energy carefully -- it regenerates at 10/s, but magnets drain 17/s and dashes cost 18 energy. Weapon heat dissipates at 34/s but blocks firing above 94.

## Public API Reference

### Package `raylib_magnet_lab_escape_2026`

> Main entry point and single-file game implementation.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width in pixels |
| `sh` | `Int` | `760` | Screen height in pixels |
| `world_w` | `Float` | `5600.0` | Total world width in game units |
| `floor_y` | `Float` | `680.0` | Y position of the floor |
| `gravity` | `Float` | `920.0` | Gravity acceleration |
| `max_platforms` | `Int` | `280` | Maximum number of platforms in the object pool |
| `max_gates` | `Int` | `8` | Maximum number of gates |
| `max_cores` | `Int` | `340` | Maximum number of energy cores |
| `max_boxes` | `Int` | `220` | Maximum number of boxes |
| `max_drones` | `Int` | `180` | Maximum number of drones |
| `max_bolts` | `Int` | `1100` | Maximum number of projectiles |
| `max_particles` | `Int` | `1700` | Maximum number of particles |
| `reactor_x` | `Float` | `5380.0` | Reactor X position (world_w - 220) |
| `reactor_y` | `Float` | `580.0` | Reactor Y position (floor_y - 100) |
| `target_cores` | `Int` | `120` | Cores needed to win |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Player` | `x`, `y`, `vx`, `vy`, `face`, `hp`, `energy`, `heat`, `inv_t`, `fire_cd`, `dash_cd`, `dash_t`, `jump_buf_t`, `coyote_t`, `grounded`, `magnet_on`, `polarity`, `score`, `cargo`, `delivered`, `combo`, `best_combo` | Player state including position, physics, resources, and scoring |
| `Platform` | `active`, `x`, `y`, `w`, `h`, `moving`, `amp`, `speed`, `phase` | Static or oscillating platform with active flag for object pooling |
| `Gate` | `active`, `x`, `req`, `open` | Barrier requiring a minimum core delivery count to open |
| `Core` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `r`, `value`, `magnetized`, `t` | Collectible energy core with physics, magnetic state, and point value |
| `Box` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `r`, `hp`, `magnetized`, `t` | Destructible metal box that drops cores when destroyed |
| `Drone` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `hp`, `fire_cd`, `t` | Enemy drone with AI behavior varying by kind (0=chaser, 1=orbiter, 2=heavy) |
| `Bolt` | `active`, `team`, `kind`, `x`, `y`, `vx`, `vy`, `dmg`, `r`, `life` | Projectile with team affiliation (1=player, 2=enemy) |
| `Particle` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `size`, `life`, `t` | Visual particle for explosions and effects |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value between low and high bounds |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Computes squared distance between two 2D points |
| `randf` | `(Float, Float) -> Float` | Generates a random float in the given range using raylib RNG |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside a rectangle (for touch input) |
| `drone_radius` | `(Int) -> Float` | Returns collision radius for a drone kind (16, 21, or 27) |
| `drone_hp` | `(Int, Int) -> Float` | Computes drone HP based on kind and difficulty level |
| `clear_platforms` | `(Array[Platform]) -> Unit` | Resets all platforms in the pool to inactive |
| `clear_gates` | `(Array[Gate]) -> Unit` | Resets all gates in the pool to inactive |
| `clear_cores` | `(Array[Core]) -> Unit` | Resets all cores in the pool to inactive |
| `clear_boxes` | `(Array[Box]) -> Unit` | Resets all boxes in the pool to inactive |
| `clear_drones` | `(Array[Drone]) -> Unit` | Resets all drones in the pool to inactive |
| `clear_bolts` | `(Array[Bolt]) -> Unit` | Resets all bolts in the pool to inactive |
| `clear_particles` | `(Array[Particle]) -> Unit` | Resets all particles in the pool to inactive |
| `add_platform` | `(Array[Platform], Float, Float, Float, Float, Bool, Float, Float) -> Bool` | Activates an inactive platform with position, size, and optional oscillation |
| `add_gate` | `(Array[Gate], Float, Int) -> Bool` | Activates a gate at position x with a required core delivery count |
| `add_core` | `(Array[Core], Int, Float, Float, Float, Float, Int) -> Bool` | Spawns an energy core with kind, position, velocity, and value |
| `add_box` | `(Array[Box], Int, Float, Float, Float, Float) -> Bool` | Spawns a box with kind, position, and velocity |
| `add_drone` | `(Array[Drone], Int, Float, Float, Int) -> Bool` | Spawns a drone with kind, position, and level-scaled HP |
| `add_bolt` | `(Array[Bolt], Int, Int, Float, Float, Float, Float, Float, Float, Float) -> Bool` | Spawns a projectile with team, kind, position, velocity, damage, radius, and lifetime |
| `add_particle` | `(Array[Particle], Int, Float, Float, Float, Float, Float, Float) -> Bool` | Spawns a particle with kind, position, velocity, size, and lifetime |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Creates a burst of particles radiating outward from a point |
| `gate_block_circle` | `(Array[Gate], Float, Float, Float, Float) -> (Float, Float)` | Prevents a circular object from passing through closed gates, returning adjusted position and velocity |
| `setup_world` | `(Array[Platform], Array[Gate], Array[Core], Array[Box]) -> Unit` | Generates the level layout with 18 sectors of platforms, 5 gates, 95 cores, and 68 boxes |
| `draw_touch_ui` | `(Int) -> Unit` | Renders on-screen touch controls (D-pad and action buttons) during gameplay |
| `main` | `() -> Unit` | Entry point: initializes window, allocates object pools, runs game loop |

## Architecture

### Package Structure

```
raylib_magnet_lab_escape_2026/
├── main.mbt              — Complete game: entry point, structs, logic, rendering
└── moon.pkg              — Package config with raylib and math imports
```

This is a single-file game implementation. All structs, game logic, physics, input handling, rendering, and the main loop reside in `main.mbt`. The architecture uses pre-allocated object pools for all entity types.

### Data Flow

1. **Initialization**: `main` allocates fixed-size arrays for all entity types using `Array::makei`, creates the `Player` struct, and calls `setup_world` to populate platforms, gates, cores, and boxes.
2. **Input**: Each frame, keyboard state is read via `@raylib.is_key_pressed`/`is_key_down`. Touch input is detected via mouse position checks against on-screen button rectangles using `inside_rect`.
3. **Update** (state == 1): The game updates in sequence -- player timers, movement with gate/platform collision (`gate_block_circle`), shooting (`add_bolt`), magnet field physics, drone spawning and AI, core/box physics with platform/gate collisions, bolt-entity collisions, particle updates, and win/lose checks.
4. **Rendering**: Camera offset (`cam_x`) follows the player. Drawing proceeds in layers: parallax stars, floor, reactor zone, platforms, gates, cores, boxes, drones, bolts, player, particles, HUD (gauges, navigation strip), touch UI, and state overlays (title/win/lose).

### Key Design Patterns

- **Object pool pattern**: All entities (platforms, gates, cores, boxes, drones, bolts, particles) use pre-allocated arrays with `active` flags. The `add_*` functions scan for inactive slots, and the `clear_*` functions reset entire pools.
- **State machine**: Integer `state` variable drives logic branches (0=title, 1=playing, 2=win, 3=lose).
- **Magnetic field simulation**: When the magnet is active, force is applied to nearby objects proportional to distance, with polarity determining attraction vs repulsion direction.
- **Gate progression**: Gates act as physical barriers checked via `gate_block_circle`, gating world exploration behind delivery milestones.
- **Difficulty scaling**: `level` increases based on deliveries and elapsed time, affecting drone HP, spawn rate, acceleration, and unlocking dual-bolt firing at level 6+.
- **Coyote time and jump buffering**: `coyote_t` (0.11s) allows jumping shortly after leaving a platform; `jump_buf_t` (0.14s) buffers jump input before landing.

## Improvement & Refinement Plan

1. **Extract entity modules**: The 2700+ line `main.mbt` would benefit from splitting into separate files for types, physics, input handling, entity updates, and rendering to improve maintainability.

2. **Replace integer state machine with enum**: The `state` variable uses magic integers (0, 1, 2, 3). A `GameState` enum with `Title`, `Playing`, `Win`, `Lose` variants would improve readability and eliminate invalid state bugs.

3. **Unify entity update logic**: The physics patterns for cores, boxes, and drones share similar gravity/friction/collision code. A shared physics update function taking position, velocity, and friction parameters would reduce the ~200 lines of duplicated collision logic.

4. **Add energy core types with distinct behaviors**: The `kind` field on `Core` only affects radius (11, 13, 15) and color. Different kinds could have distinct magnetic properties, delivery bonuses, or visual effects to add gameplay depth.

5. **Improve drone AI variety**: Kind-1 drones (orbiters) attempt to maintain distance but share similar code structure with kind-0 (chasers). Adding patrol patterns, formation flying, or shield behaviors would create more tactical variety.

6. **Reduce magic numbers in input handling**: Touch button coordinates are computed from hardcoded offsets (`pad_x + 12`, `btn_x + 160`, etc.). Extracting these as named constants or computing them from screen dimensions would improve touch UI maintainability.

7. **Add gradual difficulty ramp-down on repeated failure**: The `level` calculation in the game loop escalates monotonically. Adding a difficulty adjustment based on player deaths or low HP would help accessibility without changing the core challenge.
