# Metro Repair Dispatch 2026

A real-time logistics game where you pilot a maintenance drone across a metro network, repairing degrading track segments and managing station congestion to keep trains running on schedule.

## Build and Run

```bash
cd examples && moon build --target native metro_repair_dispatch_2026/
cd examples && ./_build/native/debug/build/metro_repair_dispatch_2026/metro_repair_dispatch_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Fly the maintenance drone
- **J or Space**: Repair targeted track segment
- **K**: Scan for faults (sonar-style pulse, cooldown)
- **R**: Restart mission
- **Touch controls**: On-screen buttons available

## How to Play

A metro network of stations and track segments operates autonomously with trains picking up passengers. Track segments degrade over time from wear and faults, slowing or stopping trains. Fly your drone to damaged segments and repair them before they fail completely. Stations accumulate crowd pressure when trains are delayed. Use the scan ability to detect hidden faults early. Manage drone energy and hull integrity while keeping the entire network functional.

## Public API Reference

### Package `metro_repair_dispatch_2026`

> Main entry point.

The `main` function initialises the window, allocates all entity pools (stations, segments, trains, particles), calls `setup_network` to build the two-line metro topology, then runs the frame loop which updates drone physics, station/segment/train simulation, and renders the world.

#### Types

| Type | Description |
|------|-------------|
| `Drone` | The player-controlled maintenance drone with position, velocity, energy, hull, repair cooldown, scan state, and wobble phase. |
| `Station` | A metro station holding position, line membership bitmask, crowd count, wait time, strain, and passenger spawn timer. |
| `Segment` | A track segment between two station indices with health, fault timer, wear accumulation, traffic load, and spark effect cooldown. |
| `Train` | A train travelling a route with passenger count, capacity, delay accumulation, blink timer, and color identifier. |
| `Particle` | A short-lived visual particle with kind, position, velocity, size, life, and pulse phase. |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to an inclusive range. |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer to an inclusive range. |
| `maxf` | `(Float, Float) -> Float` | Returns the larger of two floats. |
| `minf` | `(Float, Float) -> Float` | Returns the smaller of two floats. |
| `randf` | `(Float, Float) -> Float` | Returns a pseudo-random float in a range. |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Returns squared Euclidean distance between two points. |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests whether a point lies inside an axis-aligned rectangle. |
| `setup_network` | `(Array[Station], Array[Segment], Array[Train]) -> (Array[Int], Array[Int])` | Initialises the full two-line metro network and returns route arrays. |
| `update_stations` | `(Array[Station], Float, Int) -> Float` | Ticks station crowd growth and returns total network strain. |
| `update_segments` | `(Array[Segment], Array[Station], Float, Int, Array[Particle]) -> (Int, Float)` | Degrades segment health, spawns faults, returns fault count and health sum. |
| `update_trains` | `(Array[Train], Array[Segment], Array[Station], Array[Int], Array[Int], Float, Array[Particle]) -> (Int, Float, Int)` | Moves trains, handles boarding, returns delivered/delay/boarded totals. |
| `apply_repair` | `(Drone, Array[Segment], Array[Station], Array[Particle]) -> Int` | Repairs nearby faulted or damaged segments; costs energy. |
| `nearest_faulty_segment` | `(Array[Segment], Array[Station], Float, Float) -> (Int, Float, Float, Float)` | Finds the closest faulted segment to a point. |
| `main` | `() -> Unit` | Entry point: window init, game loop, render. |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1366` | Screen width in pixels. |
| `sh` | `Int` | `768` | Screen height in pixels. |
| `world_x` | `Int` | `24` | Left edge of the world drawing area. |
| `world_y` | `Int` | `24` | Top edge of the world drawing area. |
| `world_w` | `Int` | `930` | Width of the world drawing area. |
| `world_h` | `Int` | `720` | Height of the world drawing area. |
| `panel_x` | `Int` | `world_x + world_w + 16` | Left edge of the information panel. |
| `panel_w` | `Int` | `sw - panel_x - 20` | Width of the information panel. |
| `max_stations` | `Int` | `16` | Station pool capacity. |
| `max_segments` | `Int` | `36` | Segment pool capacity. |
| `max_trains` | `Int` | `14` | Train pool capacity. |
| `max_particles` | `Int` | `420` | Particle pool capacity. |

## Architecture

All game logic resides in `main.mbt`. Key design patterns:

- **Integer state machine**: `state` is an `Int` (0 = menu, 1 = play, 2 = win, 3 = lose). Transitions occur when the delivery target is met, the countdown timer expires, crowd count exceeds 760, average segment health falls below 18 %, or drone hull reaches zero.
- **Fixed-size pool arrays**: Every entity type (`Station`, `Segment`, `Train`, `Particle`) is allocated once at startup into a fixed-capacity array. Slots are activated/deactivated via an `active` flag, avoiding heap allocation in the game loop.
- **Two-route metro topology**: `setup_network` builds Line A (Harbor → Hilltop, 6 stations) and Line B (Dock South → Bay End, 6 stations) sharing the Central X interchange, plus three cross-connector segments. Trains use integer route indices and a ping-pong direction to navigate.
- **Tier-driven difficulty**: `tier` increments with every 180 delivered passengers (capped at 8), scaling crowd spawn rates, segment wear speed, fault probability, and the random shock event frequency.
- **Rendering approach**: The world is drawn at 60 fps inside `begin_drawing`/`end_drawing`. Layers are painted back-to-front: background gradient → grid → segments → stations → trains → drone → scan beam → particles → panel → overlay states.
- **Delta-time updates for frame-rate independence**: All physics, timers, and simulation steps are multiplied by `dt`, which is capped at 0.033 s to prevent large jumps after frame stalls.

## Improvement & Refinement Plan

1. **Separate state into a struct**: Extract all mutable game variables (`timer`, `score`, `tier`, `drone`, etc.) into a `Game` struct so the frame loop and helper functions share state through a single mutable reference instead of a large closure.
2. **Add a fault severity tier**: Introduce mild/severe fault levels with different visual indicators and repair costs, giving the player better information about which segments to prioritise.
3. **Drone energy recharge sound / visual feedback**: Currently returning to the depot is silent. Add a charging particle effect and audio cue to make the depot mechanic more legible to new players.
4. **Persist best score across sessions**: Write the best score to a file so high-score comparison is meaningful across restarts.
5. **Configurable network layouts**: Move the station coordinates and route definitions to a data table so new maps can be added without touching the simulation code.
6. **Progressive fault escalation**: If a fault is left unrepaired beyond its `fault_t` window, permanently reduce the segment's max health, creating long-term consequences for neglect.
7. **Minimap in the panel**: Draw a small-scale version of the network in the right panel showing all faults, trains, and the drone position at a glance to reduce the need to scroll the viewport visually.
