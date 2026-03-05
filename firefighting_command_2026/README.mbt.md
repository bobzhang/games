# firefighting_command_2026

A grid-based firefighting strategy game. Command a fire truck across a 5x3 grid of zones, spraying water to extinguish fires before they spread and destroy houses.

## Build and Run

```bash
moon build --target native firefighting_command_2026/
./_build/native/debug/build/firefighting_command_2026/firefighting_command_2026.exe
```

## Controls

- **WASD / Arrow keys**: Move fire truck between grid cells
- **Space**: Spray water on the current cell
- **R**: Restart

## How to Play

- Move the fire truck to burning zones and spray water to reduce fire intensity
- Fires spread to adjacent cells over time and new fires ignite randomly
- Each zone contains a house; if fire reaches 100%, the house is destroyed and you lose a life
- Water is limited and regenerates slowly
- Save as many houses as possible; game ends when all lives are lost

## Public API Reference

### Package `tonyfettes/raylib-examples/firefighting_command_2026`

Single-file game. All logic, data, and rendering live in `main.mbt`. No internal sub-packages.

#### Structs

| Struct | Fields | Description |
|---|---|---|
| `Zone` | `mut fire : Float`, `mut has_house : Bool` | One grid cell; `fire` is a percentage 0–100 representing intensity, `has_house` tracks whether the building is still standing |

#### Functions

| Function | Signature | Description |
|---|---|---|
| `cell_x` | `fn cell_x(c : Int) -> Float` | Screen X centre of column `c`: `150.0 + c * 180.0` |
| `cell_y` | `fn cell_y(r : Int) -> Float` | Screen Y centre of row `r`: `200.0 + r * 170.0` |
| `idx` | `fn idx(c : Int, r : Int) -> Int` | Flat array index for column `c`, row `r`: `r * cols + c` |
| `reset_zones` | `fn reset_zones(zones : Array[Zone]) -> Unit` | Resets all zones to full houses with no fire, then seeds 2 random ignition points between 28–46% |
| `active_fire_count` | `fn active_fire_count(zones : Array[Zone]) -> Int` | Counts zones with `fire > 0.0` |
| `main` | `fn main` | Initialises the window, runs the game loop, handles all input, simulation, and rendering |

#### Constants (file-level `let` bindings)

| Constant | Value | Description |
|---|---|---|
| `sw` | `1120` | Window width in pixels |
| `sh` | `740` | Window height in pixels |
| `cols` | `5` | Grid columns |
| `rows` | `3` | Grid rows (15 zones total) |

Key simulation rates (inlined in `main`):

| Parameter | Value | Description |
|---|---|---|
| Fire spray rate | `48.0` %/s | Rate at which holding Space reduces `zone.fire` |
| Water consumption | `24.0` /s | Water depleted per second while spraying |
| Water recharge | `14.0` /s | Water gained per second when on a fire-free zone |
| Fire growth | `7.0` % per tick | Intensity added to each active fire every spread tick |
| Spread tick | `1.0` s | Interval between fire growth and spread attempts |
| New fire spawn | `4.6` s | Interval between random new ignitions |
| Initial ignition | `28–46` % | Random starting intensity for seeded fires at reset |
| Spawn ignition | `24–42` % | Random starting intensity for fires spawned during play |
| Spread seed | `18.0` % | Intensity added to an adjacent zone on fire spread |
| Starting lives | `4` | Lives lost when a fire reaches 100% in a zone |
| Budget reward | `30` pts | Points awarded per extinguished fire |

## Architecture

### Package Structure

```
firefighting_command_2026/
└── main.mbt    # All game state, simulation, input, and rendering in one file
```

### Data Flow

The game is a single-function loop inside `main`. All mutable state is declared as local `let mut` variables: the `zones` array (15 `Zone` records), truck grid position (`truck_c`, `truck_r`), pixel position (`truck_x`, `truck_y`), `water`, two accumulator timers (`spread_tick`, `spawn_tick`), score counters (`budget`, `saved`, `lost`), `lives`, game-over flag (`over`), and the status message string.

Each frame, input is processed first: arrow or WASD keys update `truck_c` / `truck_r` and the pixel position is immediately snapped via `cell_x` / `cell_y`. Holding Space or J while `water > 0` and the current zone has fire reduces `zone.fire` by `48 * dt` and `water` by `24 * dt`; if the fire reaches zero the zone is counted as saved and `budget` increases. When the truck is on a fire-free zone, `water` recharges at `14 * dt`. The spread timer accumulates `dt` each frame; when it reaches 1.0 s every active fire grows by 7%, and if it reaches 100% the house is destroyed and a life is lost, otherwise a random adjacent zone with a standing house may receive a 18% ignition seed. The spawn timer fires every 4.6 s to ignite a random zone that still has a house. Rendering draws zone rectangles, fire circles scaled to intensity, truck geometry, the HUD bar, and the game-over overlay when `lives <= 0`.

### Key Design Patterns

- **Flat local state**: All mutable game state is held as `let mut` variables in `main`'s scope. There are no heap-allocated structs other than the `zones` array, keeping the data model minimal for a 369-line single-file game.
- **Discrete grid with continuous fire values**: The 5x3 tile grid uses integer column/row coordinates for truck movement and adjacency queries, while `zone.fire` is a continuous float percentage, giving smooth visual scaling of fire circles without a separate animation system.
- **Delta-time accumulator pattern**: Both the spread tick and the spawn tick use `tick += dt; if tick >= interval { tick -= interval; ... }` to drive periodic events at fixed real-time rates independent of frame rate.
- **Inline adjacency search with retry**: Fire spread picks a random direction and retries up to 6 times to find a valid adjacent zone with a standing house, providing probabilistic spread that respects grid boundaries without a pre-built neighbour list.
- **Immediate-mode rendering**: Every draw call is issued directly in the main loop body with no retained scene graph; zone positions are computed on the fly from `cell_x` / `cell_y` each frame.

## Improvement & Refinement Plan

1. **Extract simulation constants**: Spray rate (48 %/s), water consumption (24 /s), recharge rate (14 /s), spread growth (7 %), spread interval (1.0 s), and spawn interval (4.6 s) are inlined as numeric literals; grouping them as named constants at the top of the file would make balancing changes a single-place edit.
2. **Separate game state into a struct**: Lift `water`, `lives`, `budget`, `saved`, `lost`, `over`, `spread_tick`, `spawn_tick`, and `msg` into a named `GameState` struct so `reset_zones` can also reset the full state without duplicating the reset block that currently appears twice in `main`.
3. **Animated fire intensity**: Fire circles currently scale in radius with intensity but use constant colours; interpolating the fill colour from orange to deep red as intensity approaches 100% would give a stronger visual urgency signal without additional data.
4. **Water bar depletion warning**: The water gauge has no visual warning when reserves are critically low; changing the bar colour to red below a threshold (e.g. 20%) would prompt the player to reposition without reading the numeric value.
5. **Weighted spread probability**: The current retry-based spread gives roughly equal probability to all four directions; weighting the probability by wind direction (a simple slowly-rotating bias vector) would add a strategic layer and vary each session's spread pattern.
6. **Sound integration**: All game events (fire extinguished, building destroyed, new fire reported) currently update only the `msg` string; adding a short raylib audio cue for each event would significantly improve feedback without structural changes to the game loop.
