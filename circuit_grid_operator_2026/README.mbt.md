# Circuit Grid Operator 2026

A real-time infrastructure puzzle game where the player manages a 10x7 power grid, routing electrical charge from source nodes on the left edge to sink nodes on the right edge by rotating circuit tiles. The grid is under constant pressure from cascading fault events that disable nodes, requiring the player to balance routing optimization with fault repair and budget management.

The gameplay centers on clicking tiles to rotate their wire connections (straight, corner, tee, cross) to form continuous paths from 3 source nodes to 3 sink nodes. A BFS-based network simulation runs every 0.44 seconds (accelerating with tier), propagating charge through connected nodes with a 10% decay per hop. Sinks accumulate delivered charge, and the player must deliver 560 total units before the 240-second timer expires. Three special actions -- Patch All (repairs faults, $32), Reroute Row (randomizes a row, $24), and Overclock (boosts source output by 55% for 8s, $42) -- consume from a budget that regenerates through successful deliveries.

The game features a tier system (1-8, advancing every 90 deliveries) that increases fault frequency, fault duration, sink demands, and network tick speed. Stability drops from unpowered sinks and active faults, and reaching 0% triggers a cascade blackout (game over). Empty tiles can be filled by spending $14, and faulted tiles can be individually patched for $6.

## Build and Run

```bash
moon build --target native circuit_grid_operator_2026/
./_build/native/debug/build/circuit_grid_operator_2026/circuit_grid_operator_2026.exe
```

## Controls

- **Mouse Click on tile**: Rotate tile clockwise (normal tile), build new wire ($14, empty tile), or manually patch ($6, faulted tile)
- **F**: Patch All faults ($32) -- reduces fault timers and restores health on all faulted nodes
- **R**: Reroute Row ($24) -- randomizes wire types and rotations in a random interior row
- **O**: Overclock ($42) -- boosts source output by 55% for 8 seconds
- **Escape**: Deselect current tile
- **Enter**: Start game / continue after win/loss
- **F11**: Toggle fullscreen
- **Touch**: Tap tiles and action buttons directly

## How to Play

Click "START OPERATION" or press Enter. The 10x7 grid contains:
- **Sources** (blue, left edge at rows 1, 3, 5): Emit charge each network tick
- **Sinks** (green, right edge at rows 1, 3, 5): Receive charge and track demand/stored values
- **Wire tiles** (straight, corner, tee, cross): Route charge between ports based on rotation
- **Void tiles** (dark): Block charge flow; can be filled for $14
- **Hub tiles** (cross, fixed positions): Provide 4-way connections

**Routing**: Click wire tiles to rotate them 90 degrees clockwise. Align ports so charge can flow from sources through connected tiles to sinks. Charge propagates via BFS with 10% decay per hop. Sinks receiving charge above 25% threshold accumulate deliveries.

**Faults**: Every 5-9 seconds (decreasing with tier), fault events strike 1+ random nodes. Faulted nodes flash red, block charge, and degrade in health. They auto-decay over time but can be repaired via:
- Click faulted tile ($6): Manual patch, reduces fault timer by 2.5s
- Press F / Patch All button ($32): Patches all faults, reducing timers by 4.0s and restoring health

**Budget**: Starts at $124. Earns half of each tick's delivery count. Spent on patches, reroutes, overclock, and construction.

**Win condition**: Deliver 560+ total charge units. **Lose conditions**: Timer reaches 0 or stability reaches 0%.

**Stability**: Drops when sinks are unpowered (-2.2 per tick with 0 powered sinks), when demand goes unmet (-0.065 per missed unit), and from active fault count (-0.03 per fault per tick). Cannot be directly repaired.

**Tier progression**: Tier = 1 + delivered/90 (max 8). Higher tiers increase fault severity, sink demand, network speed, and fault frequency.

## Public API Reference

### Package `circuit_grid_operator_2026`

> Main entry point and complete game implementation (single-file architecture).

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1366` | Screen width |
| `sh` | `Int` | `768` | Screen height |
| `cols` | `Int` | `10` | Grid columns |
| `rows` | `Int` | `7` | Grid rows |
| `board_x` | `Int` | `26` | Board left edge pixel position |
| `board_y` | `Int` | `90` | Board top edge pixel position |
| `cell_sz` | `Int` | `84` | Cell size in pixels |
| `board_w` | `Int` | `840` | Board width (cols * cell_sz) |
| `board_h` | `Int` | `588` | Board height (rows * cell_sz) |
| `panel_x` | `Int` | `900` | Info panel left edge |
| `panel_w` | `Int` | `440` | Info panel width |
| `max_pulses` | `Int` | `340` | Particle pulse pool size |
| `max_cells` | `Int` | `70` | Total cell count (cols * rows) |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Cell` | `kind`, `rot`, `health`, `fault_t`, `charge`, `demand`, `stored`, `pulse`, `label` | A grid cell with wire type (0-6), rotation, health, fault timer, charge level, and sink demand/storage |
| `Pulse` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | A visual particle effect for feedback |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampi` | `(Int, Int, Int) -> Int` | Clamps integer between bounds |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps float between bounds |
| `randf` | `(Float, Float) -> Float` | Random float in range |
| `idx` | `(Int, Int) -> Int` | Converts (x, y) grid coordinates to linear index |
| `in_bounds` | `(Int, Int) -> Bool` | Tests if grid coordinates are within bounds |
| `opposite` | `(Int) -> Int` | Returns the opposite direction (0=up, 1=right, 2=down, 3=left) |
| `dir_dx` | `(Int) -> Int` | X offset for a direction |
| `dir_dy` | `(Int) -> Int` | Y offset for a direction |
| `cell_px` | `(Int) -> Int` | Pixel X position for grid column |
| `cell_py` | `(Int) -> Int` | Pixel Y position for grid row |
| `cell_cx` | `(Int) -> Float` | Center X pixel coordinate for grid column |
| `cell_cy` | `(Int) -> Float` | Center Y pixel coordinate for grid row |
| `board_contains` | `(Float, Float) -> Bool` | Tests if pixel position is within the board area |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside a rectangle |
| `pick_cell` | `(Float, Float) -> Int` | Returns the cell index at a pixel position, or -1 |
| `wire_name` | `(Int) -> String` | Returns display name for a wire kind |
| `rand_wire_kind` | `() -> Int` | Randomly selects a wire kind (34% straight, 28% corner, 22% tee, 16% cross) |
| `has_port` | `(Int, Int, Int) -> Bool` | Tests if a cell kind/rotation combination has a port in the given direction |
| `clear_pulses` | `(Array[Pulse]) -> Unit` | Deactivates all pulses |
| `add_pulse` | `(Array[Pulse], Float, Float, Int) -> Unit` | Spawns a pulse particle at position |
| `burst_pulses` | `(Array[Pulse], Float, Float, Int, Int) -> Unit` | Spawns multiple pulses at position |
| `update_pulses` | `(Array[Pulse], Float) -> Unit` | Updates pulse positions and lifetimes |
| `draw_pulses` | `(Array[Pulse]) -> Unit` | Renders all active pulses |
| `clear_grid` | `(Array[Cell]) -> Unit` | Resets all cells to empty |
| `setup_grid` | `(Array[Cell]) -> Unit` | Initializes grid with random wires, fixed sources, sinks, hubs, and voids |
| `reroll_row` | `(Array[Cell], Int) -> Unit` | Randomizes wire kinds and rotations for interior cells of a row |
| `count_faults` | `(Array[Cell]) -> Int` | Counts cells with active faults |
| `patch_faults` | `(Array[Cell], Float) -> Int` | Reduces fault timers and restores health on all faulted cells |
| `induce_faults` | `(Array[Cell], Int, Int) -> Int` | Creates new faults on random non-source, non-faulted cells |
| `degrade_faults` | `(Array[Cell], Float) -> Unit` | Ticks fault timers, degrades health, decays charge, and slowly regenerates unfaulted health |
| `run_network_step` | `(Array[Cell], Array[Int], Array[Int], Int, Int, Float) -> (Int, Int, Int)` | BFS charge propagation from sources to sinks; returns (delivered, missed, powered_sinks) |
| `draw_port_glyph` | `(Int, Float, Float, Float, Color) -> Unit` | Draws source/sink special icons |
| `draw_cell_wires` | `(Int, Int, Int, Int, Bool) -> Unit` | Draws wire connections for a cell based on kind and rotation |
| `draw_board` | `(Array[Cell], Int, Int, Float) -> Unit` | Renders the entire grid with cells, wires, health bars, fault indicators, and selection highlight |
| `draw_button` | `(Int, Int, Int, Int, String, Bool, Bool) -> Unit` | Draws a clickable button with enabled/hover states |
| `draw_panel` | `(Float, Float, Int, Int, Int, Int, Int, Float, Int, Array[Cell], Int, Float) -> Unit` | Renders the right-side info panel with stats, bars, and selection details |
| `main` | `() -> Unit` | Entry point: initializes window, cell/pulse pools, and runs the game loop with state machine |

## Architecture

### Package Structure

```
circuit_grid_operator_2026/
├── main.mbt              — Complete game: grid logic, BFS network, rendering, UI, state machine
└── moon.pkg              — Package config with raylib and math imports
```

Single-file architecture with all logic in `main.mbt`. The `Cell` array represents the grid state, while `Pulse` particles provide visual feedback. The BFS network simulation uses pre-allocated `queue` and `seen` arrays.

### Data Flow

1. **Input**: Mouse clicks on the board identify cells via `pick_cell`. Clicking rotates normal tiles, builds on empty tiles, or patches faulted tiles. Button clicks and keyboard shortcuts trigger global actions (Patch All, Reroute, Overclock).
2. **Simulation**: Every `step_cd` seconds (0.44s base, decreasing with tier), `run_network_step` performs a BFS from all non-faulted sources. Charge propagates through connected ports with 10% decay per hop. Sinks accumulate delivered units and auto-increase demand when a threshold is met.
3. **Faults**: `degrade_faults` runs every frame, ticking down fault timers and degrading health on faulted cells. Every `fault_cd` seconds (5-9s, decreasing with tier), `induce_faults` strikes random cells with new faults.
4. **Stability**: Calculated each network tick based on powered sinks, missed demand, and fault count. Reaching 0% triggers blackout.
5. **Render**: Draws grid background, cell tiles with wire connections (colored by charge level), fault indicators (flashing X), health bars, source/sink labels, selection highlight, right-side info panel with stats and action buttons, and particle effects.

### Key Design Patterns

- **BFS network simulation**: Charge propagation uses breadth-first search from source nodes with a `seen` marker system (incrementing integer avoids clearing the array each tick).
- **Port connectivity model**: `has_port(kind, rot, dir)` defines which directions each tile type connects in each rotation, enabling the BFS to determine valid charge paths.
- **Economy system**: Budget ($) earned from deliveries gates all player actions, creating a resource management layer atop the puzzle mechanics.
- **Tier scaling**: All difficulty parameters (fault frequency, demand, network speed) scale with tier, which advances automatically with cumulative deliveries.
- **Stability as indirect health**: Rather than direct HP, stability degrades from systemic failures (unpowered sinks, active faults), creating emergent pressure.

## Improvement & Refinement Plan

1. **Add undo for tile rotations**: Rotating a tile is irreversible without spending budget on reroute. Adding a single-step undo (storing previous rotation) would reduce frustration from accidental clicks.

2. **Show charge flow visualization**: Charge is only shown as cell background brightness. Drawing animated particles flowing along wire connections during network ticks would make the charge routing more visually intuitive.

3. **Add sink priority or ordering**: All three sinks are treated equally. Allowing the player to prioritize sinks (e.g., directing more flow to high-demand sinks) would add strategic depth.

4. **Improve fault prediction**: The fault ETA timer shows when the next fault event occurs, but not which cells are at risk. Adding visual indicators (e.g., low-health cells highlighted) would help players proactively repair before faults strike.

5. **Extract grid and simulation into separate modules**: The 1916-line single file would benefit from splitting into `internal/types` (Cell, Pulse structs), `internal/game` (BFS simulation, fault logic), and `internal/render` (board drawing, panel UI).

6. **Add multiple grid layouts**: The grid always uses the same source/sink/hub/void placement. Generating varied layouts or allowing level selection would increase replayability.

7. **Balance overclock cost/benefit**: Overclock costs $42 for 8 seconds of 55% boost. The return on investment depends heavily on current grid connectivity. Adding a preview of expected throughput boost would help players decide when to use it.
