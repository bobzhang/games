# Urban Flood Evacuation 2026

A real-time rescue boat simulation set in a flooded urban grid. The player pilots a rescue vessel through rising floodwaters, navigating between debris barriers and expanding flood cells to locate stranded civilian groups, ferry them aboard, and deliver survivors to a central safe hub and scattered shelter stations before time runs out.

The core gameplay loop revolves around route optimization under pressure: civilian groups spawn at world edges and drift inward while their panic meters climb. The player must rescue groups before panic reaches 100 (causing the group to be lost), manage fuel and hull integrity, and balance pickups with deliveries to the safe hub. Shelter stations scattered across the map accumulate their own queue pressure and can overflow, adding to the civilian loss count. A tier system escalates difficulty as the player rescues more people, spawning floods faster and groups more frequently.

Technically, the game employs a pure object-pool architecture with pre-allocated arrays for all entity types (shelters, groups, flood cells, barriers, particles), avoiding dynamic allocation during gameplay. A sonar ping mechanic lets the player locate the nearest high-panic group, and the flood system uses pulsing radius fields that apply drag and extra fuel consumption to the boat when overlapping.

## Build and Run

```bash
moon build --target native raylib_urban_flood_evacuation_2026/
./_build/native/debug/build/raylib_urban_flood_evacuation_2026/raylib_urban_flood_evacuation_2026.exe
```

## Controls

- **W / Up Arrow**: Move boat up
- **S / Down Arrow**: Move boat down
- **A / Left Arrow**: Move boat left
- **D / Right Arrow**: Move boat right
- **J / Space**: Boost (increased acceleration and speed, drains fuel faster)
- **L / U**: Rescue nearby civilian groups (picks up survivors within range)
- **K / H**: Sonar ping (locates nearest group with panic >= 30)
- **Enter / Space / Click**: Start game from menu / Restart from end screen
- **R**: Return to menu from win/lose screen
- **F11**: Toggle fullscreen
- **Touch D-pad**: On-screen directional controls (bottom-left)
- **Touch BOOST button**: On-screen boost (bottom-right area)
- **Touch RESCUE button**: On-screen rescue action
- **Touch PING button**: On-screen sonar ping

## How to Play

The mission begins with a 420-second countdown timer and a target of 620 rescued civilians. Your rescue boat starts at the central safe hub on the left side of the flooded city grid.

**Rescue cycle**: Civilian groups spawn from the edges of the map and drift inward. Each group has a panic meter that rises over time (faster when near flood cells or far from the safe hub). Approach a group and press the rescue key to load survivors aboard (up to 8 per pickup, max capacity 38). Return to the safe hub zone to automatically unload passengers -- 3 at a time -- earning 10 points per person delivered.

**Threats**: Flood cells are large pulsing circular hazards that cross the map. Inside a flood cell, the boat suffers increased drag and fuel consumption, and nearby civilian groups panic faster. Debris barriers are solid obstacles scattered across the map that deal hull damage on collision at speed. Shelter stations have rising queue levels that overflow if not managed (losing 3 people per overflow).

**Resource management**: Fuel depletes while moving and drains faster when boosting or inside flood zones. Hull takes damage from barrier collisions. Both refill automatically when parked inside the safe hub zone. The safe hub itself has a queue counter that rises over time -- if it reaches maximum (260), the mission fails.

**Win condition**: Rescue 620 or more civilians before the timer expires. **Lose conditions**: Timer reaches zero, lost civilians exceed 150, hull reaches zero, or the safe hub queue overflows.

**Difficulty scaling**: The tier increases every 110 rescued civilians (up to tier 9). Higher tiers spawn groups faster, produce more flood cells, increase shelter queue pressure, and make floods more powerful.

## Public API Reference

### Package `raylib_urban_flood_evacuation_2026`

> Main entry point and complete game implementation in a single file.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Player` | `x`, `y`, `vx`, `vy`, `heading`, `hull`, `fuel`, `onboard`, `capacity`, `rescue_cd`, `ping_cd`, `ping_t` | Rescue boat state including position, velocity, heading, hull/fuel resources, passenger count, and cooldown timers |
| `Shelter` | `active`, `x`, `y`, `queue`, `risk`, `alarm_t`, `id` | Shelter station with queue pressure and flood risk tracking |
| `Group` | `active`, `x`, `y`, `count`, `panic`, `drift_x`, `drift_y`, `flare_t`, `id` | Stranded civilian group with drift movement and panic meter |
| `FloodCell` | `active`, `x`, `y`, `vx`, `vy`, `radius`, `pressure`, `life`, `phase` | Moving flood hazard with pulsing radius and pressure intensity |
| `Barrier` | `active`, `x`, `y`, `vx`, `vy`, `size`, `hard`, `spin` | Drifting debris obstacle with hardness affecting collision damage |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | Visual particle for splash, debris, and rescue effects |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value between low and high bounds |
| `minf` | `(Float, Float) -> Float` | Returns the minimum of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns the maximum of two floats |
| `mini` | `(Int, Int) -> Int` | Returns the minimum of two integers |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `randf` | `(Float, Float) -> Float` | Generates a random float in the given range using raylib RNG |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Computes squared distance between two 2D points |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside an axis-aligned rectangle |
| `clear_shelters` | `(Array[Shelter]) -> Unit` | Resets all shelters to inactive default state |
| `clear_groups` | `(Array[Group]) -> Unit` | Resets all groups to inactive default state |
| `clear_floods` | `(Array[FloodCell]) -> Unit` | Resets all flood cells to inactive default state |
| `clear_barriers` | `(Array[Barrier]) -> Unit` | Resets all barriers to inactive default state |
| `clear_parts` | `(Array[Particle]) -> Unit` | Resets all particles to inactive default state |
| `add_particle` | `(Array[Particle], Float, Float, Int) -> Unit` | Activates the first available particle at position with given kind |
| `burst` | `(Array[Particle], Float, Float, Int, Int) -> Unit` | Emits n particles of a given kind at a position |
| `update_parts` | `(Array[Particle], Float) -> Unit` | Updates particle positions, applies drag/gravity per kind, expires dead particles |
| `init_shelters` | `(Array[Shelter], Int, Int, Int, Int) -> Unit` | Places up to 7 shelters at predefined positions within the world bounds |
| `init_barriers` | `(Array[Barrier], Array[Shelter], Float, Float, Float, Float, Float, Float) -> Unit` | Scatters debris barriers across the map avoiding shelters and safe zone |
| `spawn_group` | `(Array[Group], Float, Float, Float, Float, Int, Int) -> Bool` | Spawns a civilian group at a random world edge with tier-scaled count |
| `spawn_flood` | `(Array[FloodCell], Float, Float, Float, Float, Int) -> Bool` | Spawns a flood cell entering from a random edge with tier-scaled pressure |
| `active_groups` | `(Array[Group]) -> Int` | Counts currently active civilian groups |
| `active_floods` | `(Array[FloodCell]) -> Int` | Counts currently active flood cells |
| `active_critical` | `(Array[Group]) -> Int` | Counts active groups with panic >= 70 |
| `peak_group_panic` | `(Array[Group]) -> Float` | Returns the highest panic value among active groups |
| `update_floods` | `(Array[FloodCell], Float, Float, Float, Float, Float) -> Unit` | Moves flood cells with pulsing speed, bounces off world boundaries, expires by life timer |
| `update_barriers` | `(Array[Barrier], Float, Float, Float, Float, Float) -> Unit` | Drifts barriers with wobble, bounces off world edges, slowly decays hardness |
| `update_groups` | `(Array[Group], Array[FloodCell], Float, Float, Float, Float, Float, Float, Float) -> (Int, Float)` | Updates group drift, raises panic based on floods and distance, returns (lost people, panic sum) |
| `rescue_groups` | `(Player, Array[Group], Array[Particle]) -> (Int, Int)` | Picks up civilians from nearby groups into the boat, returns (people rescued, groups hit) |
| `nearest_urgent_group` | `(Array[Group], Float, Float) -> (Bool, Float, Float, Float)` | Finds the closest group with panic >= 30, returns (found, x, y, panic) |
| `draw_city` | `(Int, Int, Int, Int, Float) -> Unit` | Renders the flooded city background with animated water gradient and submerged road grid |
| `draw_safe_zone` | `(Int, Int, Int, Int) -> Unit` | Draws the safe hub zone with hatched pattern and label |
| `draw_shelters` | `(Array[Shelter], Float) -> Unit` | Renders shelter buildings with queue/risk labels and pulsing beacons |
| `draw_groups` | `(Array[Group], Float) -> Unit` | Renders civilian groups with panic-colored circles and flare indicators |
| `draw_floods` | `(Array[FloodCell], Float) -> Unit` | Renders flood cells as pulsing translucent circles |
| `draw_barriers` | `(Array[Barrier], Float) -> Unit` | Renders debris barriers as hardness-colored wobbling circles |
| `draw_player` | `(Player, Float) -> Unit` | Draws the rescue boat with heading indicator, wake effect, onboard passengers, and ping circle |
| `draw_parts` | `(Array[Particle]) -> Unit` | Renders active particles colored by kind |
| `draw_touch_controls` | `(Int, Int, Float, Float, Bool) -> Unit` | Draws on-screen D-pad and action buttons for touch input |
| `draw_bar` | `(Int, Int, String, Float, Float, @raylib.Color) -> Unit` | Renders a labeled progress bar on the HUD panel |
| `draw_button` | `(Int, Int, Int, Int, String, Bool) -> Unit` | Draws a clickable UI button with hover highlight |
| `main` | `() -> Unit` | Entry point: initializes window, allocates entity pools, runs game loop with state machine |

## Architecture

### Package Structure

```
raylib_urban_flood_evacuation_2026/
├── main.mbt              — Complete game: structs, logic, rendering, input, main loop
└── moon.pkg              — Package config with raylib and math imports
```

The entire game is contained in a single `main.mbt` file. Structs are defined at the top, followed by utility functions, then entity management (clear/init/spawn), update logic, rendering functions, and finally the main game loop.

### Data Flow

1. **Input**: The main loop reads keyboard state (`is_key_down`, `is_key_pressed`) and mouse/touch positions. Touch input maps on-screen D-pad and button regions to the same boolean flags as keyboard controls.
2. **Update**: The game state integer (0=menu, 1=play, 2=win, 3=lose) gates which logic runs. During play, entity arrays are updated in sequence: particles, player movement with flood drag, rescue/ping actions, floods, barriers, group panic, shelter queues, spawning, and win/lose checks.
3. **Render**: Drawing proceeds in layer order: city background, safe zone, barriers, shelters, groups, floods, player, ping indicators, particles, then the HUD panel on the right side.

### Key Design Patterns

- **Object Pool Pattern**: All entities (shelters[7], groups[26], floods[24], barriers[210], particles[900]) use pre-allocated arrays with `active` flags. The `clear_*` functions reset pools, and spawn functions find the first inactive slot.
- **State Machine**: A simple integer (`state`) with values 0-3 drives menu, gameplay, win, and lose screens.
- **Tier-based Difficulty Scaling**: The `tier` variable (1-9) increases every 110 rescues and affects spawn rates, flood pressure, group sizes, and shelter queue growth.
- **Delta-time Integration**: All movement, cooldowns, and timers use `dt` with a 0.033s cap to prevent physics instabilities at low frame rates.
- **Sonar Ping System**: The ping mechanic searches for the nearest group with panic >= 30 and draws a visual indicator line from the player to the target for 2 seconds.

## Improvement & Refinement Plan

1. **Extract entity modules**: The single 2200+ line `main.mbt` would benefit from splitting into `types.mbt`, `game.mbt`, `render.mbt`, and `input.mbt` using the internal package pattern, improving maintainability and enabling parallel development.
2. **Add shelter delivery mechanic**: Currently shelters only accumulate queue pressure but the player cannot deliver people to them. Adding delivery to shelters (reducing their queue) would create more strategic routing decisions beyond just returning to the safe hub.
3. **Replace magic numbers with named constants**: Values like `84.0` (rescue range), `38` (capacity), `420.0` (timer), `620` (target), and `150` (loss limit) are scattered throughout the code. Extracting these into named constants would improve tuning and readability.
4. **Implement fuel station pickups**: Fuel only regenerates at the safe hub. Adding fuel pickup drops or fuel caches at shelters would reduce the tedious back-and-forth and create more interesting route planning.
5. **Add visual minimap**: With a 1240x900 world area and up to 26 active groups, a minimap on the HUD panel would help players locate distant groups without relying solely on the ping mechanic.
6. **Improve barrier collision response**: The current collision in the main loop applies a simple radial push but does not reflect the boat's velocity. Adding proper velocity reflection off `Barrier` surfaces would make collisions feel more physical.
7. **Add group rescue priority feedback**: The `nearest_urgent_group` function finds the closest panicking group, but the HUD does not show a persistent directional indicator. Adding a compass arrow pointing toward the most urgent group would improve situational awareness.
