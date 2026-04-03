# Lighthouse Supply Run 2026

A maritime logistics game where you pilot a supply vessel through stormy seas, delivering fuel to lighthouses scattered across the map while avoiding reefs, storms, and pirates.

## Build and Run

```bash
cd examples && moon build --target native lighthouse_supply_run_2026/
cd examples && ./_build/native/debug/build/lighthouse_supply_run_2026/lighthouse_supply_run_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Steer the supply vessel
- **J or Space**: Load/unload cargo at dock / sonar ping
- **K**: Repair hull
- **R**: Restart mission
- **Touch buttons**: On-screen controls available

## How to Play

Navigate open waters to resupply lighthouses before their fuel demand runs critical. Each lighthouse has a priority level and increasing urgency. Load cargo at the home dock and deliver to lighthouses in need. Dodge coral reefs that damage your hull, weather storms that push your ship off course, and outrun pirates that pursue and attack. Manage hull integrity and energy reserves across escalating missions.

## Public API Reference

### Package `lighthouse_supply_run_2026`

> Main entry point and single-file game implementation.

The `main` function initializes the window, creates all entity arrays, calls `init_lights` and `init_reefs` to set up the world, and runs the frame loop. Each frame reads input, updates all entities, delivers cargo, and renders all layers.

#### Types

| Type | Description |
|------|-------------|
| `Player` | Supply vessel state: position, velocity, heading, hull integrity, energy, cargo count, ping cooldown/timer/position, and wake animation timer. |
| `Lighthouse` | Lighthouse with pooling flag, position, demand level, warning timer, priority, delivery count, and identifier. |
| `Reef` | Coral reef hazard with pooling flag, position, collision radius, hardness, and animated pulse timer. |
| `Storm` | Moving storm with pooling flag, position, velocity, influence radius, intensity, remaining lifetime, and phase. |
| `Pirate` | Hostile vessel with pooling flag, position, velocity, speed, attack cooldown, blink timer, target index, and identifier. |
| `Particle` | Visual particle with pooling flag, position, velocity, lifetime, size, and kind. |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to `[lo, hi]`. |
| `minf` / `maxf` | `(Float, Float) -> Float` | Returns the min/max of two floats. |
| `absf` | `(Float) -> Float` | Returns the absolute value. |
| `mini` | `(Int, Int) -> Int` | Returns the smaller of two integers. |
| `randf` | `(Float, Float) -> Float` | Returns a random float in `[lo, hi]`. |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Returns squared distance between two points. |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests point-in-rectangle for touch input. |
| `clear_lights` / `clear_reefs` / `clear_storms` / `clear_pirates` / `clear_parts` | pool `-> Unit` | Reset all records in each entity pool. |
| `add_particle` | `(Array[Particle], Float, Float, Float, Float, Float, Float, Int) -> Unit` | Activates an inactive particle. |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Emits `n` particles outward from a point. |
| `update_parts` | `(Array[Particle], Float) -> Unit` | Advances all active particles by `dt`. |
| `init_lights` | `(Array[Lighthouse], ...) -> Unit` | Places lighthouses at fixed positions with initial demands. |
| `init_reefs` | `(Array[Reef], ...) -> Unit` | Places reef hazards with randomized positions and radii. |
| `active_storms` | `(Array[Storm]) -> Int` | Returns the count of active storms. |
| `active_pirates` | `(Array[Pirate]) -> Int` | Returns the count of active pirates. |
| `peak_demand` | `(Array[Lighthouse]) -> Float` | Returns the highest demand across all active lighthouses. |
| `total_demand` | `(Array[Lighthouse]) -> Float` | Returns the sum of all active lighthouse demands. |
| `spawn_storm` | `(Array[Storm], ...) -> Unit` | Activates a storm at a map edge with randomized parameters. |
| `spawn_pirate` | `(Array[Pirate], ...) -> Unit` | Activates a pirate at a map edge with a target lighthouse. |
| `update_storms` | `(Array[Storm], Player, Float) -> Unit` | Advances storms, applies wind to player within range. |
| `highest_demand_light` | `(Array[Lighthouse]) -> Int` | Returns the index of the highest-demand active lighthouse. |
| `update_pirates` | `(Array[Pirate], Player, Float) -> Unit` | Advances pirates, steers toward target, attacks player on contact. |
| `update_light_demands` | `(Array[Lighthouse], Float) -> Unit` | Increases lighthouse demands over time and triggers warning effects. |
| `deliver_to_lights` | `(Player, Array[Lighthouse], ...) -> Unit` | Delivers cargo to nearby lighthouses, reducing demand and awarding score. |
| `nearest_urgent_light` | `(Player, Array[Lighthouse]) -> Int` | Returns the nearest lighthouse with high demand for navigation. |
| `draw_ocean` | `(Float, ...) -> Unit` | Draws animated ocean background with waves. |
| `draw_harbor` | `(...) -> Unit` | Draws the home harbor dock area. |
| `draw_lights` | `(Array[Lighthouse], Float) -> Unit` | Draws lighthouses with animated beams and demand bars. |
| `draw_reefs` | `(Array[Reef], Float) -> Unit` | Draws reef hazards with pulsing animation. |
| `draw_storms` | `(Array[Storm], Float) -> Unit` | Draws storms as swirling translucent circles. |
| `draw_pirates` | `(Array[Pirate], Float) -> Unit` | Draws pirate vessels with blink indicators. |
| `draw_player` | `(Player, Float) -> Unit` | Draws the supply vessel with wake and sonar ping. |
| `draw_parts` | `(Array[Particle]) -> Unit` | Draws all active particles with alpha fading. |
| `draw_touch_controls` | `(...) -> Unit` | Renders on-screen touch buttons. |
| `draw_bar` | `(...) -> Unit` | Draws a labeled horizontal progress bar. |
| `draw_button` | `(...) -> Unit` | Draws a labeled button with press state highlight. |
| `main` | `() -> Unit` | Entry point: initializes window, world, and game loop. |

#### Constants

There are no top-level `let` constants in this file. Configuration values (world size, harbor position, lighthouse positions, reef counts, etc.) are defined as inline literals within the initialization functions.

## Architecture

All game logic is in `main.mbt`. Key patterns:
- **State machine**: An integer `state` variable (0=title, 1=playing, 2=win, 3=lose) drives logic branches and overlay rendering. A `mission` counter tracks completed supply cycles.
- **Main data structures**: The `Player` struct holds all vessel state. Six `Array` pools (lighthouses, reefs, storms, pirates, particles) with `active` flags manage all entities.
- **Delta-time updates**: All physics (ship steering with drag, storm wind forces, pirate pursuit) are scaled by `dt` for frame-rate independence.
- **Demand escalation**: `update_light_demands` increases all lighthouse demands each frame; delivering cargo reduces individual demand and awards score scaled by priority.
- **Spawn management**: Storm and pirate spawning is gated by cooldowns and active-count caps to prevent overwhelming the player.

## Improvement & Refinement Plan

1. **Replace integer state with an enum**: The `state` variable uses magic integers. A `GameState` enum (`Title`, `Playing`, `Win`, `Lose`) would eliminate invalid states and improve readability.

2. **Add a fog-of-war mechanic**: The current map is fully visible. Limiting visibility radius around the player and revealing lighthouses only via sonar ping would add exploration tension and make the sonar ability more tactically valuable.

3. **Introduce cargo capacity upgrades**: The player starts with a fixed cargo capacity. Adding optional upgrade buoys between deliveries would create a progression layer and strategic routing decisions.

4. **Improve pirate AI variety**: All pirates share the same pursuit behavior. Adding a pirate that blocks lighthouse approaches (guardian) or one that steals delivered cargo (raider) would create more tactical gameplay.

5. **Add hull repair docks**: Currently hull integrity can only be recovered at the home harbor. Placing repair buoys at mid-map positions would reduce the cost of long-range delivery routes.

6. **Extract constants for world layout**: Lighthouse positions, reef counts, and storm intensity parameters are embedded as inline literals. Naming these as top-level `let` constants would make difficulty tuning and world layout modification easier.

7. **Add mission success streak bonus**: Delivering to all lighthouses before any reaches maximum demand could trigger a score multiplier, rewarding efficient routing and creating a risk/reward loop around lighthouse priority selection.
