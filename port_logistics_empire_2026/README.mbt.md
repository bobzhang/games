# Port Logistics Empire 2026

A logistics management simulation where you build and manage a port network. Place nodes (docks, warehouses, factories), connect them with routes, and dispatch trucks to transport raw materials and goods to meet demand across the network.

## Build and Run

```bash
cd examples && moon build --target native port_logistics_empire_2026/
cd examples && ./_build/native/debug/build/port_logistics_empire_2026/port_logistics_empire_2026.exe
```

## Controls

- **Mouse**: Click to place nodes, draw routes between nodes, and interact with UI
- **Touch**: Tap for placement and route creation
- **Keyboard**: Various hotkeys for node types and route management (shown in-game HUD)

## Key Concepts

The game features a node-and-route network where docks produce raw materials, factories convert them into goods, and warehouses store and distribute them. Routes between nodes have health and levels that affect truck throughput. Trucks automatically travel routes carrying cargo. Balance production, routing capacity, and demand fulfillment to grow your logistics score. Nodes can experience outages, and routes degrade over time, requiring maintenance.

## Public API Reference

### Package `port_logistics_empire_2026`

> Main entry point.

The `main` function initializes the window, allocates fixed-size arrays for `Node`, `Route`, `Truck`, and `Spark` objects, calls `reset_run()` to build the starting map, and runs the frame loop. Each frame the loop updates timers, processes mouse/keyboard input for node selection and route actions, runs `update_nodes`/`update_routes`/`update_trucks`, checks win/lose conditions, then draws the world, UI panel, and action buttons.

#### Types

| Type | Description |
|------|-------------|
| `Node` | Port, factory, market, or hub node with `raw`, `goods`, `demand`, and `outage_t` inventory state |
| `Route` | Directed route connecting two node indices with `level`, `hp`, and `spawn_cd` for truck generation |
| `Truck` | A vehicle travelling a route with `t` progress, `dir`, `cargo_kind`, and `cargo` payload |
| `Spark` | Short-lived visual particle with position, velocity, `life`, and `size` |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer to `[lo, hi]` |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to `[lo, hi]` |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Returns squared Euclidean distance between two points |
| `randf` | `(Float, Float) -> Float` | Returns a random float in `[lo, hi]` using raylib RNG |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests whether a point is inside an integer rectangle |
| `minf` | `(Float, Float) -> Float` | Returns the smaller of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns the larger of two floats |
| `node_kind_name` | `(Int) -> String` | Returns the display name for a node kind id |
| `node_color` | `(Int) -> Color` | Returns the display color for a node kind id |
| `cargo_color` | `(Int) -> Color` | Returns the display color for a cargo kind id |
| `clear_nodes` | `(Array[Node]) -> Unit` | Resets all node records to inactive defaults |
| `clear_routes` | `(Array[Route]) -> Unit` | Resets all route records to inactive defaults |
| `clear_trucks` | `(Array[Truck]) -> Unit` | Resets all truck records to inactive defaults |
| `clear_sparks` | `(Array[Spark]) -> Unit` | Resets all spark records to inactive defaults |
| `add_node` | `(Array[Node], Int, Float, Float, Float, String) -> Int` | Activates the first free node slot and returns its index |
| `find_route` | `(Array[Route], Int, Int) -> Int` | Returns the index of an existing route between two nodes, or -1 |
| `add_route` | `(Array[Route], Int, Int) -> Int` | Activates the first free route slot connecting two nodes |
| `count_active_routes` | `(Array[Route]) -> Int` | Returns the number of active routes |
| `count_active_trucks` | `(Array[Truck]) -> Int` | Returns the number of active trucks |
| `add_truck` | `(Array[Truck], Int, Int, Int) -> Int` | Activates the first free truck slot on a route |
| `add_spark` | `(Array[Spark], Float, Float, Int) -> Unit` | Activates the first free spark slot at a position |
| `burst_sparks` | `(Array[Spark], Float, Float, Int, Int) -> Unit` | Emits `n` sparks of a given kind at a position |
| `update_sparks` | `(Array[Spark], Float) -> Unit` | Advances spark physics and expires dead sparks |
| `draw_sparks` | `(Array[Spark]) -> Unit` | Draws all active sparks as fading circles |
| `point_seg_dist2` | `(Float, Float, Float, Float, Float, Float) -> Float` | Returns squared distance from a point to a line segment |
| `pick_node` | `(Array[Node], Float, Float) -> Int` | Returns the index of the node under the cursor, or -1 |
| `pick_route` | `(Array[Route], Array[Node], Float, Float) -> Int` | Returns the index of the route nearest the cursor, or -1 |
| `setup_map` | `(Array[Node], Array[Route], Array[Truck]) -> Unit` | Builds the initial port network layout and seed inventory |
| `load_from_node_to_target` | `(Array[Node], Truck, Int, Int, Int) -> Unit` | Loads a truck with cargo appropriate for its destination node type |
| `update_nodes` | `(Array[Node], Float, Int) -> (Int, Int)` | Ticks production and consumption on all active nodes; returns delivery and bonus cash gains |
| `update_routes` | `(Array[Route], Float, Float) -> Int` | Ticks route degradation during storms; returns count of broken routes |
| `update_trucks` | `(Array[Truck], Array[Route], Array[Node], Float, Float, Array[Spark]) -> Unit` | Advances truck travel and handles cargo delivery at endpoints |
| `damage_random_route` | `(Array[Route], Float) -> Int` | Applies damage to a randomly chosen active route and returns its index |
| `truck_pos` | `(Truck, Route, Array[Node]) -> (Float, Float)` | Returns the current world position of a truck along its route |
| `draw_button` | `(Int, Int, Int, Int, String, Bool, Bool) -> Unit` | Draws a labelled action button with enabled and hover states |
| `draw_world_bg` | `(Float) -> Unit` | Draws the animated world background gradient and floating dots |
| `draw_routes` | `(Array[Route], Array[Node], Int, Float) -> Unit` | Draws all active routes with health-based color and selection highlight |
| `draw_nodes` | `(Array[Node], Int) -> Unit` | Draws all active nodes with icons, labels, and inventory counts |
| `draw_trucks` | `(Array[Truck], Array[Route], Array[Node]) -> Unit` | Draws all active trucks along their routes with cargo indicators |
| `draw_ui_panel` | `(Float, Int, Int, Int, Int, Int, Int, Float, Float, Int, Array[Route]) -> Unit` | Draws the right-side HUD panel with stats, storm bar, and route info |
| `route_build_cost` | `(Int) -> Int` | Returns the budget cost to build the next route |
| `route_upgrade_cost` | `(Int) -> Int` | Returns the budget cost to upgrade a route at a given level |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1366` | Window width in pixels |
| `sh` | `Int` | `768` | Window height in pixels |
| `world_l` | `Float` | `24.0` | Left edge of the world viewport |
| `world_t` | `Float` | `24.0` | Top edge of the world viewport |
| `world_r` | `Float` | `950.0` | Right edge of the world viewport |
| `world_b` | `Float` | `744.0` | Bottom edge of the world viewport |
| `max_nodes` | `Int` | `12` | Maximum nodes in the pool |
| `max_routes` | `Int` | `40` | Maximum routes in the pool |
| `max_trucks` | `Int` | `140` | Maximum trucks in the pool |
| `max_sparks` | `Int` | `280` | Maximum sparks in the pool |

## Architecture

All game logic is in `main.mbt`. Key patterns:

- **Node-route-truck graph**: Nodes hold integer inventory (`raw`, `goods`, `demand`). Routes connect pairs of nodes and spawn trucks on a cooldown. Trucks traverse from one endpoint to the other, loading cargo at the source and unloading at the destination via `load_from_node_to_target` and the arrival branch in `update_trucks`.
- **State machine**: `state` cycles through `0` (menu), `1` (play), `2` (win), and `3` (lose). Transitions occur when the delivery goal is met, the timer expires, or the budget goes deeply negative.
- **Delta-time updates for frame-rate independence**: `update_nodes`, `update_routes`, `update_trucks`, and `update_sparks` all accept `dt` and scale production rates and physics by it.
- **Pool allocation**: All entity arrays are fixed-size and pre-allocated; `add_node`, `add_route`, `add_truck`, and `add_spark` scan for the first inactive slot, keeping allocation O(n) without dynamic memory.
- **Storm system**: A periodic cooldown triggers a storm that damages random routes, causes node outages, and slows truck progress. Players must spend budget on `REPAIR ALL` or `LOGISTICS SURGE` to recover.

## Improvement & Refinement Plan

1. Introduce a free-list index per pool so `add_node`, `add_route`, and `add_truck` are O(1) instead of O(n) linear scans.
2. Allow players to demolish routes to reclaim a fraction of the build cost and redistribute trucks when a network branch is no longer needed.
3. Add visual truck pathing arrows on routes so players can immediately see which direction cargo is flowing without inspecting each truck individually.
4. Persist the player's high-score and best completion time between sessions using a simple local file.
5. Introduce a second map layout unlocked after the first contract is completed, with longer routes and additional factory nodes.
6. Show a per-node throughput sparkline (deliveries per second) in the UI panel so players can identify bottlenecks at a glance.
7. Add a keyboard shortcut to cycle the selected route (Tab key) so players can quickly navigate the network without precise mouse clicks.
