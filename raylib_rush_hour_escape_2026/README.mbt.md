# Rush Hour Escape 2026

Rush Hour Escape 2026 is a sliding-block puzzle game inspired by the classic Rush Hour board game. Players manipulate cars and trucks on a 6x6 grid to clear a path for the red player car (marked "P") to reach the exit gate on the right side of row 3. Three progressively harder levels challenge the player to find efficient solutions.

The core gameplay is purely logic-based: click a car to select it, then use directional keys to slide it one cell at a time along its axis of movement (horizontal cars slide left/right, vertical cars slide up/down). Each car can only move if the target cell is empty and within the grid bounds. The puzzle is solved when the player car's rightmost cell reaches column 5 (the right edge) in the exit row. A par system tracks optimal move counts, awarding 1-3 stars based on how close the player gets to par.

The game features a warm, tactile visual style with a wooden-brown board border, cream-colored grid, colored car rectangles with directional indicator dots, and a pulsing red exit gate. Touch controls are provided via on-screen directional buttons.

## Build and Run

```bash
moon build --target native raylib_rush_hour_escape_2026/
./_build/native/debug/build/raylib_rush_hour_escape_2026/raylib_rush_hour_escape_2026.exe
```

## Controls

- **Mouse Click**: Select a car on the grid (click on any cell the car occupies)
- **A / Left Arrow**: Slide selected car left (horizontal cars only)
- **D / Right Arrow**: Slide selected car right (horizontal cars only)
- **W / Up Arrow**: Slide selected car up (vertical cars only)
- **S / Down Arrow**: Slide selected car down (vertical cars only)
- **R**: Restart from level 1
- **Touch/Mouse**: On-screen UP/LEFT/RIGHT/DOWN buttons (bottom-left corner)

## How to Play

Each level presents a grid of colored cars and trucks. Car 0 (red, marked "P") is the player car positioned horizontally in the exit row (row 3). The exit gate is on the right edge of this row.

Slide cars one cell at a time to create a clear path for the player car to reach the rightmost column. Horizontal cars only slide left/right; vertical cars only slide up/down. Cars cannot overlap or leave the 6x6 grid.

The game tracks your move count against a par target:
- **At or under par**: 3 stars, score bonus of 230 + (par - moves) * 12
- **1-3 moves over par**: 2 stars, score bonus of 170 - (moves - par) * 6 (minimum 90)
- **More than 3 over par**: 1 star, score bonus of 90 - (moves - par) * 3 (minimum 40)

Three levels with increasing difficulty:
- **Level 1**: 9 cars, par 12
- **Level 2**: 10 cars, par 16
- **Level 3**: 11 cars, par 19

Complete all three levels to earn the "Traffic Master" title.

## Public API Reference

### Package `raylib_rush_hour_escape_2026`

> Main entry point. Single-file puzzle game with grid logic, level data, rendering, and main loop.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width in pixels |
| `sh` | `Int` | `820` | Screen height in pixels |
| `gw` | `Int` | `6` | Grid width in cells |
| `gh` | `Int` | `6` | Grid height in cells |
| `cell` | `Int` | `90` | Cell size in pixels |
| `ox` | `Int` | `370` | Grid x-offset from screen left |
| `oy` | `Int` | `126` | Grid y-offset from screen top |
| `exit_row` | `Int` | `2` | The row where the exit gate is located (0-indexed) |
| `max_cars` | `Int` | `14` | Maximum number of cars in the pool |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Car` | `x`, `y`, `len`, `horizontal`, `player`, `color`, `active` | A car/truck on the grid with grid position, length (2 or 3), orientation, player flag, color index, and active state |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside an integer rectangle (for mouse/touch hit testing) |
| `clear_cars` | `(Array[Car]) -> Unit` | Resets all car slots to inactive defaults |
| `put_car` | `(Array[Car], Int, Int, Int, Int, Bool, Bool, Int) -> Unit` | Places a car at index with position, length, orientation, player flag, and color |
| `setup_level` | `(Int, Array[Car]) -> (Int, Int)` | Initializes a level by placing cars; returns (car_count, par) tuple |
| `color_for` | `(Int) -> Color` | Maps a color index to an RGBA color (0=red for player, 1-7 cycle through blue, green, yellow, purple, teal, orange, lavender) |
| `in_board` | `(Int, Int) -> Bool` | Returns true if grid coordinates are within the 6x6 board |
| `occupied_by` | `(Array[Car], Int, Int, Int, Int) -> Bool` | Returns true if any car (excluding skip index) occupies the given grid cell |
| `find_car_at` | `(Array[Car], Int, Int, Int) -> Int` | Returns the index of the car at the given grid cell, or -1 if empty |
| `can_move` | `(Array[Car], Int, Int, Int) -> Bool` | Returns true if the specified car can move one step in the given direction |
| `try_move` | `(Array[Car], Int, Int, Int) -> Bool` | Attempts to move a car one step; returns true if successful |
| `solved` | `(Array[Car]) -> Bool` | Returns true if the player car (index 0) has reached the exit position (rightmost column, exit row) |

## Architecture

### Package Structure

```
raylib_rush_hour_escape_2026/
├── main.mbt              -- Entry point: all types, puzzle logic, level data, rendering, and main loop
└── moon.pkg              -- Package config with raylib import
```

This is a single-file puzzle game (~699 lines). The code is organized into type definitions, utility functions, level setup with hardcoded car placements, grid logic functions (collision, movement, solving), and the main loop with input handling and rendering.

### Data Flow

1. **Level setup**: `setup_level` calls `clear_cars` and then `put_car` for each car in the level, returning the car count and par value.
2. **Input**: Mouse clicks call `find_car_at` to select a car. WASD/arrow keys or touch buttons set direction vectors.
3. **Movement**: `try_move` calls `can_move` to check if the target cell is in bounds and unoccupied, then updates the car's grid position.
4. **Win check**: After each move, `solved` checks if car 0's rightmost cell is at column gw-1 in the exit row.
5. **Level transition**: On solve, a 1.0-second `transition_t` timer runs, after which the next level loads or the game ends.
6. **Rendering**: The grid is drawn with wooden border and cream interior. Cars are colored rectangles with a dot indicator and yellow selection border. The exit gate is a red bar on the right edge.

### Key Design Patterns

- **Grid-based collision**: `occupied_by` iterates all cars to check cell occupancy, supporting both horizontal and vertical cars with variable length.
- **Hardcoded levels**: Three levels are defined inline in `setup_level` with explicit `put_car` calls, providing hand-crafted puzzle designs.
- **Par scoring**: A tiered scoring system rewards efficiency, with 3/2/1 stars based on proximity to the par move count.
- **Separation of can/try move**: `can_move` purely tests validity while `try_move` applies the mutation, enabling preview logic if needed.
- **Car pool**: A fixed array of 14 `Car` slots is pre-allocated, with `active` flags controlling which cars are in play.

## Improvement & Refinement Plan

1. **Add undo functionality**: There is no way to undo moves. Implementing a move history stack (storing car index and direction) would let players backtrack without restarting the entire level.

2. **Add more levels**: Only 3 levels are included. The `setup_level` function pattern makes it straightforward to add more puzzles, and a level editor or procedural generator would extend replayability significantly.

3. **Implement drag-to-slide**: Currently cars move one cell per keypress. Adding mouse drag support where dragging a car along its axis slides it multiple cells would provide a more intuitive interaction model.

4. **Add move animation**: Cars snap instantly to their new position. A brief linear interpolation (lerp) animation between positions would make the game feel more polished.

5. **Show par breakdown per level**: Stars are accumulated across levels but individual level scores are not displayed. Showing a per-level star rating on completion would give clearer feedback.

6. **Replace hardcoded levels with data arrays**: The three levels use repetitive `put_car` calls in `setup_level`. Defining levels as arrays of tuples `(x, y, len, horizontal, player, color)` would be more compact and easier to extend.

7. **Add move hint system**: For players stuck on a puzzle, a hint system that highlights one valid move toward the solution would improve accessibility without removing the challenge entirely.
