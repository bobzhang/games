# Volcano Rescue Ops 2026

A turn-based route-planning puzzle game set on a volcanic grid. The player plans routes for a rescue truck to navigate between civilian sites and a shelter, collecting stranded survivors and delivering them before lava spreads across the map. The game combines pathfinding strategy with resource management across three progressively harder levels.

The core gameplay loop is deliberate and strategic: click a map tile to auto-plan a path using BFS, or manually append directional steps to the route queue, then press EXECUTE to watch the truck follow the planned path. Each move costs 6 fuel and generates 4.8 heat. Lava spreads from seed cells at regular intervals, destroying civilian sites and blocking routes. Depot tiles provide fuel, coolant, and cooling when the truck parks on them. The player must deliver enough civilians to the shelter to meet each level's rescue quota.

The game features a full BFS pathfinder (`plan_route_to`) that finds shortest paths around rocks and lava. Lava spreads probabilistically to adjacent cells with biased chances (higher near the truck, lower near the shelter). Three hand-crafted levels ("North Ridge Lift", "Molten Corridor", "Caldera Spiral") each have unique rock layouts, depot placements, and lava seeds.

## Build and Run

```bash
moon build --target native raylib_volcano_rescue_ops_2026/
./_build/native/debug/build/raylib_volcano_rescue_ops_2026/raylib_volcano_rescue_ops_2026.exe
```

## Controls

- **Click map tile**: Auto-plan route to that tile using BFS pathfinder
- **W / Up Arrow**: Append "up" step to route queue
- **A / Left Arrow**: Append "left" step to route queue
- **S / Down Arrow**: Append "down" step to route queue
- **D / Right Arrow**: Append "right" step to route queue
- **Enter / Space / E**: Execute planned route
- **Backspace / Delete / X**: Clear planned route
- **C**: Use coolant (reduces heat by 28, costs 18 coolant)
- **R**: Restart current level
- **N / Enter**: Advance to next level (on win screen)
- **F11**: Toggle borderless windowed mode
- **Touch D-pad**: On-screen directional route building (bottom-left panel)
- **Touch EXECUTE button**: Start route execution
- **Touch CLEAR button**: Clear route queue
- **Touch COOLANT button**: Use coolant
- **Touch RESTART button**: Restart level

## How to Play

Each level presents a 15x10 grid with rock walls, lava seeds, civilian sites, depot tiles, a shelter, and a starting position.

**Route planning**: Click any walkable tile on the map to auto-generate a shortest path from the truck to that tile. Alternatively, use arrow keys or D-pad to manually queue individual directional steps. The planned route appears as a blue preview line on the map.

**Execution**: Press EXECUTE to run the planned route. The truck moves one step every 0.22 seconds, consuming 6 fuel and gaining 4.8 heat per step. Upon reaching a civilian site, survivors are automatically picked up (vehicle capacity: 6). Upon reaching the shelter, all carried civilians are delivered.

**Resources**: Heat rises passively (faster near lava, while carrying passengers, and during route execution) and is partially offset by natural cooling (0.95/sec). Parking on a depot tile provides 5.6 extra cooling/sec and restores fuel (23/sec) and coolant (16/sec). Coolant can be used manually to reduce heat by 28 at the cost of 18 coolant.

**Lava**: Lava spreads from existing lava cells to adjacent ground tiles at intervals (1.58s/1.42s/1.31s by level). Spread probability is 28+level*8% base, increased near depots and the truck, decreased near the shelter. Lava kills civilians at covered sites.

**Level 1** ("North Ridge Lift"): 15 civilians, rescue quota 11, 205s time limit. **Level 2** ("Molten Corridor"): 17 civilians, quota 13, 225s. **Level 3** ("Caldera Spiral"): 20 civilians, quota 15, 245s.

**Win condition**: Deliver enough civilians to meet the rescue quota. **Lose conditions**: Vehicle overheats (heat >= 100), timer expires, truck consumed by lava, shelter overrun by lava, rescue quota becomes impossible, or fuel exhausted away from a depot.

## Public API Reference

### Package `raylib_volcano_rescue_ops_2026`

> Main entry point.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Entry point: creates window, instantiates Game, runs update/render loop |

### Package `raylib_volcano_rescue_ops_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1680` | Screen width |
| `screen_h` | `Int` | `960` | Screen height |
| `target_fps` | `Int` | `120` | Target frame rate |
| `grid_w` | `Int` | `15` | Grid width in tiles |
| `grid_h` | `Int` | `10` | Grid height in tiles |
| `max_cells` | `Int` | `150` | Total grid cells (grid_w * grid_h) |
| `max_sites` | `Int` | `12` | Maximum civilian site pool |
| `max_route_steps` | `Int` | `96` | Maximum route queue length |
| `level_count` | `Int` | `3` | Total number of levels |
| `state_title` | `Int` | `0` | Title screen state |
| `state_play` | `Int` | `1` | Gameplay state |
| `state_result` | `Int` | `2` | Win/lose result state |
| `result_none` | `Int` | `0` | No result |
| `result_win` | `Int` | `1` | Win result |
| `result_lose` | `Int` | `2` | Lose result |
| `tile_ground` | `Int` | `0` | Ground tile type |
| `tile_rock` | `Int` | `1` | Rock (impassable) tile type |
| `tile_depot` | `Int` | `2` | Depot (supply) tile type |
| `tile_shelter` | `Int` | `3` | Shelter (delivery) tile type |
| `dir_none/up/down/left/right` | `Int` | `0-4` | Direction constants for route steps |
| `map_x`, `map_y` | `Int` | `44`, `124` | Map rendering offset |
| `tile_size` | `Int` | `56` | Tile pixel size |
| `panel_x`, `panel_w` | `Int` | computed | Side panel position and width |
| `vehicle_capacity` | `Int` | `6` | Max civilians the truck can carry |
| `max_heat` | `Float` | `100.0` | Maximum heat before overheating |
| `max_fuel` | `Float` | `100.0` | Maximum fuel capacity |
| `max_coolant` | `Float` | `100.0` | Maximum coolant capacity |
| `move_fuel_cost` | `Float` | `6.0` | Fuel consumed per movement step |
| `move_heat_gain` | `Float` | `4.8` | Heat gained per movement step |
| `step_interval` | `Float` | `0.22` | Seconds between route execution steps |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `CivilianSite` | `active`, `x`, `y`, `waiting` | Civilian rescue site with grid position and number of waiting survivors |
| `Game` | `terrain`, `lava`, `route`, `sites`, `truck_x/y`, `shelter_x/y`, `carrying`, `rescued`, `lost`, `heat`, `fuel`, `coolant`, `mission_time`, `state`, `result`, ... | Main game state container with grid data, entity state, resources, and UI state |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `CivilianSite::new` | `() -> CivilianSite` | Creates an inactive civilian site |
| `Game::new` | `() -> Game` | Creates a new game with default state and allocated arrays |
| `mini` | `(Int, Int) -> Int` | Returns minimum of two integers |
| `maxi` | `(Int, Int) -> Int` | Returns maximum of two integers |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps integer between bounds |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps float between bounds |
| `cell_index` | `(Int, Int) -> Int` | Converts grid (x, y) to flat array index |
| `in_bounds` | `(Int, Int) -> Bool` | Tests if coordinates are within the grid |
| `tile_at` | `(Game, Int, Int) -> Int` | Returns the tile type at a grid position |
| `lava_at` | `(Game, Int, Int) -> Bool` | Tests if a cell is covered by lava |
| `route_dx` | `(Int) -> Int` | Returns x offset for a direction constant |
| `route_dy` | `(Int) -> Int` | Returns y offset for a direction constant |
| `total_waiting` | `(Game) -> Int` | Counts total civilians still waiting across all sites |
| `level_title` | `(Int) -> String` | Returns the human-readable name for a level index |
| `mission_result_label` | `(Game) -> String` | Returns "Mission Successful" or "Mission Failed" |
| `current_goal_progress` | `(Game) -> String` | Returns "rescued/goal" progress string |
| `has_next_level` | `(Game) -> Bool` | Tests if there is another level after the current one |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Point-in-rectangle test |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Tests mouse or any touch point against a rectangle |
| `sample_pointer` | `(Float, Float, Bool, Int) -> (Bool, Float, Float)` | Returns the active pointer position (mouse or touch) |
| `map_rect` | `() -> (Int, Int, Int, Int)` | Returns the map rendering rectangle |
| `execute_button_rect` | `() -> (Int, Int, Int, Int)` | Returns the EXECUTE button rectangle |
| `clear_route_button_rect` | `() -> (Int, Int, Int, Int)` | Returns the CLEAR button rectangle |
| `coolant_button_rect` | `() -> (Int, Int, Int, Int)` | Returns the COOLANT button rectangle |
| `restart_button_rect` | `() -> (Int, Int, Int, Int)` | Returns the RESTART button rectangle |
| `title_start_button_rect` | `() -> (Int, Int, Int, Int)` | Returns the title screen start button rectangle |
| `result_restart_button_rect` | `() -> (Int, Int, Int, Int)` | Returns the result screen restart button rectangle |
| `result_next_button_rect` | `() -> (Int, Int, Int, Int)` | Returns the result screen next-level button rectangle |
| `dpad_center_x` | `() -> Int` | D-pad center x position |
| `dpad_center_y` | `() -> Int` | D-pad center y position |
| `dpad_size` | `() -> Int` | D-pad button size |
| `dpad_left/right/up/down_rect` | `() -> (Int, Int, Int, Int)` | D-pad directional button rectangles |

### Package `raylib_volcano_rescue_ops_2026/internal/game`

> Game logic, input detection, pathfinding, and level setup.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main update entry: reads input, handles state transitions, updates play logic |

### Package `raylib_volcano_rescue_ops_2026/internal/render`

> Rendering and drawing routines.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main rendering entry: draws background, map, entities, HUD, and UI overlays |

## Architecture

### Package Structure

```
raylib_volcano_rescue_ops_2026/
├── main.mbt                    — Entry point: window init, game loop
├── moon.pkg                    — Root package config
└── internal/
    ├── types/
    │   ├── types.mbt           — CivilianSite and Game structs
    │   ├── constants.mbt       — All game constants (grid, tiles, resources, UI layout)
    │   └── utils.mbt           — Grid math, tile queries, UI rect helpers
    ├── game/
    │   ├── logic.mbt           — Level setup, pathfinding (BFS), route execution, lava spread, win/loss
    │   └── input.mbt           — Input detection functions for buttons, D-pad, map clicks
    └── render/
        └── render.mbt          — Map rendering, truck, sites, route preview, HUD, panels
```

The game follows a clean three-package separation: types defines all data structures and constants, game handles all logic and input, and render handles all drawing. The main entry point simply creates a Game, then loops calling `update_game` and `draw_frame`.

### Data Flow

1. **Input** (`input.mbt`): Each `detect_*` function checks keyboard keys and touch/mouse regions for a specific action, returning a boolean. `detect_map_target` converts pointer coordinates to grid coordinates for pathfinding.
2. **Logic** (`logic.mbt`): `update_game` reads input, dispatches to appropriate handlers (route planning, execution, coolant use, restart, etc.), then calls `update_play` which advances the mission timer, processes route steps, updates passive heat/fuel, spreads lava, processes civilian pickup/dropoff, and checks win/loss conditions.
3. **Pathfinding**: `plan_route_to` performs BFS from the truck to the target cell, reconstructs the path in reverse, and fills the route queue with directional steps.
4. **Lava spread**: `spread_lava_once` copies lava to a buffer, then for each lava cell attempts probabilistic spread to adjacent cells. Spread probability is biased by tile type and proximity to truck/shelter. After spreading, `burn_sites_from_lava` destroys any civilians on newly-lava tiles.
5. **Render** (`render.mbt`): `draw_frame` dispatches to title, play, or result screen drawing. Play screen renders the grid map, sites, route preview, truck, HUD panel with resource bars, action buttons, and D-pad.

### Key Design Patterns

- **ECS-like Separation**: Types/game/render split keeps data, logic, and presentation independent.
- **BFS Pathfinding**: Uses flat arrays for queue, parent, and visited sets, avoiding dynamic allocation. Explores up/down/left/right neighbors and reconstructs the path via parent chain.
- **Probabilistic Lava Spread**: `try_spread_to` uses a base probability modified by tile type and entity proximity, creating organic-looking lava flow that biases toward the player.
- **Route Queue**: A fixed-size array acts as a FIFO queue for route steps, with `push_route_step` and `pop_route_step` operations. Route can be built manually (D-pad) or automatically (BFS).
- **Depot as Resource Node**: Depot tiles provide multi-resource regeneration (fuel, coolant, cooling), making them strategic rest stops on the map.

## Improvement & Refinement Plan

1. **Replace integer constants with enums**: Tile types (0-3), directions (0-4), states (0-2), and results (0-2) are all plain integers. Converting to proper MoonBit enums would provide type safety and eliminate magic number bugs.
2. **Add undo for route building**: There is no way to remove the last step from a manually-built route without clearing the entire queue. Adding an undo (pop last step) would improve the route planning UX.
3. **Add route cost preview**: When hovering over a target tile, show the fuel and heat cost of the planned route before committing. Currently the player must mentally estimate route length times per-step costs.
4. **Improve lava visualization**: Lava cells are drawn as solid orange rectangles. Adding animated flow patterns, edge blending between lava and ground tiles, and ember particles would significantly improve visual quality.
5. **Add score/rating system**: The game currently only tracks rescued count for win/loss. Adding a scoring system based on time, fuel efficiency, and civilians saved (similar to the star system in the volcano_airlift game) would increase replayability.
6. **Implement A* instead of BFS**: The BFS pathfinder finds shortest paths but does not consider route quality. An A* implementation with cost weights for heat-dangerous cells (near lava) would plan safer routes.
7. **Add route persistence across turns**: When the route is blocked by newly-spread lava, the entire route is cancelled. Auto-replanning the remaining route around the obstacle would be more user-friendly than requiring manual intervention.
