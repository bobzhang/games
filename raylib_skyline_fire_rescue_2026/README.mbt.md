# Skyline Fire Rescue

An arcade-style city firefighting simulation where the player pilots a water-bombing helicopter across a burning urban skyline. Fifteen named buildings are ablaze across three rows of the city grid, each with structural integrity that degrades under fire and trapped civilians who face escalating danger. The player must juggle three critical tasks: dousing fires, rescuing people, and delivering them to the hospital.

The core loop involves shuttling between fires, the water reservoir (bottom-left), and the city hospital (bottom-right). Water drops fired from the helicopter cool burning buildings on contact, and the player must return to the reservoir to refill. Civilians are rescued by flying near buildings with low-enough fire levels (below 68) and pressing the rescue key, then transported to the hospital for score bonuses. Fire grows continuously, spreads to nearby buildings when intensity exceeds 52, and causes casualties when it surpasses 54. Buildings that lose all integrity collapse, killing everyone inside.

The game features a tier-based difficulty scaling (1-8) driven by total rescues, periodic random fire spike events, and three end conditions: win by rescuing 42 civilians, lose if the 300-second timer expires, or lose if total casualties reach 34.

## Build and Run

```bash
moon build --target native raylib_skyline_fire_rescue_2026/
./_build/native/debug/build/raylib_skyline_fire_rescue_2026/raylib_skyline_fire_rescue_2026.exe
```

## Controls

- **W / Up Arrow**: Move helicopter up
- **A / Left Arrow**: Move helicopter left
- **S / Down Arrow**: Move helicopter down
- **D / Right Arrow**: Move helicopter right
- **Space / J**: Drop water on fires (consumes 2 water per burst, 0.12s cooldown)
- **K / H**: Rescue civilians from nearby buildings (0.42s cooldown)
- **R**: Return to menu (on game over screen)
- **Enter**: Start game / return to menu
- **F11**: Toggle fullscreen
- **Touch controls**: D-pad (UP/LT/DN/RT), DROP circle, RES circle

## How to Play

Pilot the helicopter through a city of 15 named buildings arranged in a 5x3 grid. Buildings start with varying fire levels and civilian counts. Fire grows at a base rate that increases with tier level, and when a building's fire reaches 52+, it periodically spreads flames to the nearest neighbor within 280 units.

Fly over the **Water Reservoir** (bottom-left, blue zone) to automatically refill water at 36 units/second. Drop water with Space/J to release 6-9 water projectiles that arc downward with gravity and extinguish fire on contact. Each hit reduces a building's fire level by the drop's power value (2.5-4.2).

To rescue civilians, fly within 72 units of a building's center when its fire is below 68, and press K/H. The helicopter can carry up to 6 passengers. Deliver them to the **City Hospital** (bottom-right, green zone) by flying into it -- passengers are automatically unloaded for 55 points each.

Buildings have structural integrity (starts 78-100) that degrades proportional to fire intensity. When integrity reaches 0, the building collapses, killing all remaining occupants. When fire exceeds 54, there is a probabilistic chance of civilian casualties each frame. New people periodically appear in buildings via emergency events.

Win by rescuing 42 total civilians. Lose if the 300-second timer expires or if total casualties reach 34. Difficulty tier increases every 12 rescues (max tier 8), accelerating fire growth and emergency frequency. A score bonus ticks up when fires are low and rescues are high.

## Public API Reference

### Package `raylib_skyline_fire_rescue_2026`

> Main entry point and sole package. Contains all types, game logic, rendering, and input handling.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1366` | Screen width |
| `sh` | `Int` | `768` | Screen height |
| `world_l` | `Float` | `24.0` | World left boundary |
| `world_t` | `Float` | `24.0` | World top boundary |
| `world_r` | `Float` | `970.0` | World right boundary |
| `world_b` | `Float` | `744.0` | World bottom boundary |
| `reservoir_x/y/w/h` | `Int` | `42, 596, 250, 128` | Water reservoir zone bounds |
| `hospital_x/y/w/h` | `Int` | `700, 596, 244, 128` | City hospital zone bounds |
| `max_buildings` | `Int` | `28` | Maximum building pool size |
| `max_drops` | `Int` | `220` | Maximum water drop pool size |
| `max_particles` | `Int` | `360` | Maximum particle pool size |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Helicopter` | `x`, `y`, `vx`, `vy`, `water`, `water_max`, `passengers`, `capacity`, `fire_cd`, `rescue_cd`, `wobble` | Player helicopter with position, velocity, water tank, passenger capacity, and action cooldowns |
| `Building` | `active`, `x`, `y`, `w`, `h`, `fire`, `integrity`, `people`, `casualties`, `spread_cd`, `emergency_cd`, `collapsed`, `pulse`, `name` | City building with fire level, structural integrity, trapped civilians, fire spread timer, and named identity |
| `WaterDrop` | `active`, `x`, `y`, `vx`, `vy`, `power`, `life`, `kind` | Water projectile with physics, extinguishing power, and lifetime |
| `Particle` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `size`, `life`, `pulse` | Visual effect particle (kind 0=fire, 1=water, 2=rescue, 3=casualty) |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between bounds |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between bounds |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two points |
| `randf` | `(Float, Float) -> Float` | Random float in range |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Point-in-rectangle test |
| `circle_rect_hit` | `(Float, Float, Float, Float, Float, Float, Float) -> Bool` | Circle-rectangle collision test |
| `building_center_x` | `(Building) -> Float` | Returns horizontal center of a building |
| `building_center_y` | `(Building) -> Float` | Returns vertical center of a building |
| `clear_buildings` | `(Array[Building]) -> Unit` | Resets all buildings to inactive state |
| `clear_drops` | `(Array[WaterDrop]) -> Unit` | Resets all water drops to inactive |
| `clear_particles` | `(Array[Particle]) -> Unit` | Resets all particles to inactive |
| `add_building` | `(Array[Building], Float, Float, Float, Float, Int, Float, String) -> Bool` | Adds a building with position, size, people count, initial fire, and name |
| `setup_city` | `(Array[Building]) -> Unit` | Places 15 named buildings in a 5x3 grid with initial fire levels |
| `add_drop` | `(Array[WaterDrop], Float, Float, Float, Float, Float, Float, Int) -> Bool` | Creates a water drop projectile in the pool |
| `add_particle` | `(Array[Particle], Float, Float, Int) -> Unit` | Creates a visual particle with random velocity |
| `burst_particles` | `(Array[Particle], Float, Float, Int, Int) -> Unit` | Emits multiple particles at a position |
| `update_particles` | `(Array[Particle], Float) -> Unit` | Updates particle physics with gravity and damping |
| `update_drops` | `(Array[WaterDrop], Array[Building], Float, Array[Particle]) -> Float` | Updates water drops, checks building collisions, returns total hit power |
| `nearest_viable_building` | `(Array[Building], Float, Float) -> Int` | Finds index of nearest non-collapsed building |
| `update_fire_system` | `(Array[Building], Float, Int, Array[Particle]) -> (Int, Int, Int)` | Core fire simulation: growth, spread, casualties, collapse. Returns (active fires, new casualties, new collapses) |
| `try_rescue` | `(Helicopter, Array[Building], Array[Particle]) -> Int` | Attempts to load civilians from nearby safe buildings into helicopter |
| `draw_city_bg` | `(Float) -> Unit` | Draws city background with roads, grid lines, and ambient lights |
| `draw_special_zones` | `() -> Unit` | Draws reservoir and hospital zones with labels |
| `draw_buildings` | `(Array[Building], Float) -> Unit` | Draws buildings with fire effects, smoke, windows, integrity bars, and collapse state |
| `draw_drops` | `(Array[WaterDrop]) -> Unit` | Draws active water drop projectiles |
| `draw_helicopter` | `(Helicopter, Float) -> Unit` | Draws helicopter with rotor animation, body, and passenger count |
| `draw_touch_ui` | `() -> Unit` | Draws on-screen D-pad and action buttons |
| `draw_particles` | `(Array[Particle]) -> Unit` | Draws all active particles with kind-based coloring |
| `main` | `() -> Unit` | Entry point: window init, game loop with state machine (0=menu, 1=play, 2=win, 3=lose) |

## Architecture

### Package Structure

```
raylib_skyline_fire_rescue_2026/
├── main.mbt              — All game code in a single file
└── moon.pkg              — Package config with raylib and math imports
```

This is a single-file game where all types, constants, utility functions, simulation logic, input handling, and rendering coexist in `main.mbt`. The main function uses a closure-based `reset_run` for initialization and a monolithic game loop with an integer state machine.

### Data Flow

1. **Input**: Keyboard keys (WASD, Space/J, K/H) and touch control regions are polled each frame. Touch D-pad and circular action buttons are detected via `inside_rect` and `dist2` hit tests.
2. **Simulation**: `update_fire_system` is the heart of the game -- it grows fire on each building, checks fire spread to neighbors via `nearest_viable_building`, probabilistically generates casualties, and collapses buildings when integrity reaches 0. Water drops are updated with gravity in `update_drops` and tested against building bounds with `circle_rect_hit`. The helicopter refills water when inside the reservoir rect and auto-delivers passengers when inside the hospital rect.
3. **Events**: A periodic random event timer (`event_cd`, 8-14s) fires up a random building and adds people, creating urgency spikes.
4. **Rendering**: Layers are drawn bottom-up: city background with roads and lights, special zones, buildings with fire/smoke/integrity bars, water drops, helicopter, particles, HUD panel (right side), touch controls, message bar, then state overlays.

### Key Design Patterns

- **Named building system**: Each of the 15 buildings has a unique string name (e.g., "Atlas Mall", "Civic Center") displayed in fire spike messages, adding narrative flavor.
- **Fire spread mechanic**: When fire exceeds 52, buildings spread fire to the nearest neighbor within 280 units on a cooldown timer, creating chain reactions.
- **Dual-resource management**: Water (for firefighting) and passenger capacity (for rescues) create a constant strategic tension between the two objectives.
- **Circle-rectangle collision**: `circle_rect_hit` is used for precise water-drop-to-building collision rather than simple point-in-rect, giving better feel for water bombing.
- **Probabilistic casualties**: Civilian loss is not deterministic -- it uses a probability that scales with fire intensity, creating tension without guaranteed outcomes.

## Improvement & Refinement Plan

1. **Extract game state into a struct**: Variables like `state`, `timer`, `rescued_total`, `casualties_total`, `collapsed_total`, `score`, `tier`, `msg`, `msg_t`, `scene_t`, and `event_cd` are all loose locals in `main`. A `Game` struct would improve organization and enable the `reset_run` closure to become a method.

2. **Replace integer state with enum**: `state` uses integers 0-3 for menu/play/win/lose. A `GameState` enum would be more readable and prevent invalid states.

3. **Add building priority indicators**: Buildings with high fire and many people are highest priority, but there is no visual indicator helping the player triage. Adding a pulsing warning icon or color-coded outline based on urgency would improve gameplay.

4. **Implement wind mechanic**: Water drops currently fall straight down with slight random horizontal spread. Adding a wind system that shifts drops would create an additional challenge at higher tiers and make positioning more strategic.

5. **Balance rescue difficulty curve**: The fire threshold for rescue (68) is static. Making it decrease at higher tiers would force the player to fight fires before rescuing, increasing difficulty more organically.

6. **Add building fire bar visualization**: Buildings show an integrity bar at the bottom, but there is no fire intensity bar. Adding one would help players prioritize which buildings need water most urgently.

7. **Expand the event system**: Currently only one event type exists (random fire spike). Adding events like "gas leak" (instant high fire), "structural reinforcement" (integrity boost), or "civilian influx" (many people appear) would add variety.
