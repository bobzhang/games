# City Crossing 2026

A Frogger-style grid-based crossing game where the player navigates an 11x11 grid, dodging traffic on road rows and hopping onto floating logs across river rows, to reach 5 home slots at the top. The player moves one cell at a time using discrete input, creating a classic arcade feel with turn-by-turn risk assessment.

The grid is divided into distinct zone types: a home row (row 0) with 5 docking slots at odd columns, three river rows (rows 1-3) where the player must ride floating logs or drown, safe grass median rows (rows 4, 8, 10), and four road rows (rows 5, 6, 7, 9) with cars of varying speeds and directions. Traffic and logs wrap around the screen edges, and their speed increases by 18% per level. Filling all 5 home slots completes a level, granting a score bonus and resetting the board with faster traffic. The player starts with 4 lives, a 55-second timer per attempt, and loses a life from car collisions, falling in the river, drifting off-screen on a log, missing a dock slot, or running out of time.

## Build and Run

```bash
moon build --target native raylib_city_crossing_2026/
./_build/native/debug/build/raylib_city_crossing_2026/raylib_city_crossing_2026.exe
```

## Controls

- **W / Up Arrow**: Move one cell up
- **S / Down Arrow**: Move one cell down
- **A / Left Arrow**: Move one cell left
- **D / Right Arrow**: Move one cell right
- **R**: Restart the game (resets lives, score, level, and traffic)
- **Touch**: On-screen directional pad (bottom-left corner) with UP, DOWN, LEFT, RIGHT buttons

## How to Play

Start at the bottom center of the 11x11 grid with 4 lives, score 0, and a 55-second timer. Your goal is to reach the home slots at the top row.

**Movement**: Press a direction key (or tap the on-screen D-pad) to move exactly one cell (56 pixels). Moving up awards 10 points. Moving down deducts 2 points (minimum 0). Left and right movement does not affect score.

**Road rows** (rows 5, 6, 7, 9): Cars travel horizontally at varying speeds and directions. If your position overlaps a car (within 5 pixels of its edges), you lose a life and respawn at the bottom. Row 5 has 3 cars moving right at speed 160. Row 6 has 4 cars moving left at speed 210. Row 7 has 2 trucks (3 cells wide) moving right at speed 124. Row 9 has 3 cars moving left at speed 246.

**River rows** (rows 1, 2, 3): You must land on a floating log or you drown (lose a life). While on a log, you drift with it. If the drift carries you past the grid boundary, you lose a life. Row 1 has 3 logs moving right at speed 88. Row 2 has 3 logs moving left at speed 106. Row 3 has 3 logs moving right at speed 124.

**Home row** (row 0): Contains 5 home slots at columns 1, 3, 5, 7, and 9. You must land within 38% of a cell width from the slot center. Landing on an already-filled slot or missing a slot entirely costs a life. Successfully docking awards 220 + timer*2 points and resets the timer to 55 seconds.

**Level completion**: Filling all 5 home slots completes the level. You receive a bonus of 600 + lives*60 points. The level increments, all homes reset, traffic resets, and the speed multiplier increases (1.0 + (level-1)*0.18).

**Game over**: Occurs when lives reach 0 (from any cause: car hit, drowning, drifting off, missed dock, or timer expiry). Press R to restart.

## Public API Reference

### Package `raylib_city_crossing_2026`

> Main entry point and complete game implementation (single-file architecture).

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1200` | Screen width in pixels |
| `sh` | `Int` | `820` | Screen height in pixels |
| `cols` | `Int` | `11` | Grid width in cells |
| `rows` | `Int` | `11` | Grid height in cells |
| `cell` | `Int` | `56` | Cell size in pixels |
| `ox` | `Int` | `292` | Grid X offset from screen left edge |
| `oy` | `Int` | `120` | Grid Y offset from screen top |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Car` | `x` (mut Float), `row` (Int), `w` (Int), `speed` (Float), `color` (Int) | A road vehicle with horizontal position, row assignment, width in cells, movement speed, and color index (0=red, 1=blue, 2=yellow) |
| `Log` | `x` (mut Float), `row` (Int), `w` (Int), `speed` (Float) | A floating log on a river row with horizontal position, row assignment, width in cells, and drift speed |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between low and high bounds |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point (px, py) is inside a rectangle defined by (rx, ry, rw, rh) |
| `set_car` | `(Array[Car], Int, Float, Int, Int, Float, Int) -> Unit` | Initializes a car at the given index with position, row, width, speed, and color |
| `set_log` | `(Array[Log], Int, Float, Int, Int, Float) -> Unit` | Initializes a log at the given index with position, row, width, and speed |
| `reset_traffic` | `(Array[Car], Array[Log]) -> Unit` | Sets all 12 cars and 9 logs to their initial positions, rows, sizes, and speeds |
| `reset_homes` | `(Array[Bool]) -> Unit` | Clears all 5 home slots to unfilled |
| `homes_done` | `(Array[Bool]) -> Bool` | Returns true if all 5 home slots are filled |
| `slot_col` | `(Int) -> Int` | Returns the grid column for home slot index (0->1, 1->3, 2->5, 3->7, 4->9) |
| `slot_center_x` | `(Int) -> Float` | Returns the pixel X center coordinate for a home slot index |
| `row_from_y` | `(Float) -> Int` | Converts a pixel Y position to a grid row index |
| `is_river_row` | `(Int) -> Bool` | Returns true if the row is a river row (rows 1, 2, or 3) |
| `is_road_row` | `(Int) -> Bool` | Returns true if the row is a road row (rows 5, 6, 7, or 9) |
| `spawn_pos` | `() -> (Float, Float)` | Returns the pixel coordinates for the player's starting position (center of bottom row) |
| `main` | `() -> Unit` | Entry point: initializes window, creates car/log/home arrays, and runs the game loop with input, physics, collision, scoring, and rendering |

## Architecture

### Package Structure

```
raylib_city_crossing_2026/
├── main.mbt              — Complete game: grid layout, traffic physics, collision, scoring, rendering
└── moon.pkg              — Package config with raylib import
```

Single-file architecture with all logic in `main.mbt` (695 lines). Two struct types (`Car`, `Log`) define moving obstacles. Game state (player position, lives, score, level, timer) is managed as mutable local variables in `main`. Traffic is stored in fixed-size arrays (12 cars, 9 logs) initialized by `reset_traffic`.

### Data Flow

1. **Input**: Arrow keys or WASD (discrete, one press = one cell move) and touch D-pad buttons set `dx`/`dy` movement deltas. The `moved` flag ensures only one move per frame.
2. **Physics**: Cars and logs update positions each frame using `speed * speed_mul * dt`. Both wrap around the grid edges (with a 30-34 pixel buffer beyond the visible area) to create seamless looping traffic.
3. **Collision**: After the player moves, the current row determines the collision check. Road rows test overlap with car hitboxes. River rows search for a log underneath the player; if found, the player drifts with the log; if not, the player drowns. The home row checks proximity to slot centers.
4. **Scoring**: Moving up awards 10 points. Docking in a home slot awards 220 + timer*2. Completing a level awards 600 + lives*60. Moving down deducts 2 points.
5. **Render**: Layers from back to front: row-colored background strips (green/blue/gray), home slot rectangles (yellow if filled, green if empty), grid lines, logs (brown rectangles with wood grain detail), cars (colored rectangles with windshield and wheel details), player (green circle with eye dots), touch D-pad overlay, status message bar, and game-over overlay.

### Key Design Patterns

- **Discrete grid movement**: The player moves exactly one cell per input, unlike continuous movement in most action games. This creates a deliberate, planning-oriented gameplay feel characteristic of the Frogger genre.
- **Row-type zoning**: Each row has a fixed type (home, river, road, safe) that determines both its visual appearance and its collision/interaction rules, keeping logic clean and predictable.
- **Wrap-around traffic**: Cars and logs that exit one side of the grid re-enter from the other, with a pixel buffer to ensure smooth visual transitions. This creates infinite-feeling traffic patterns from finite obstacle pools.
- **Speed multiplier scaling**: All traffic speeds are multiplied by `1.0 + (level-1) * 0.18`, providing a simple but effective difficulty curve that affects all obstacles uniformly.
- **Fixed obstacle layout**: Traffic patterns are hand-tuned in `reset_traffic` rather than procedurally generated, giving each row a distinct character (fast narrow cars vs. slow wide trucks, alternating directions).

## Improvement & Refinement Plan

1. **Add animated player movement**: The player currently teleports between cells. Adding a smooth interpolation between cells (over 100-150ms) would make movement feel more polished while maintaining the discrete grid logic.

2. **Implement bonus items on logs**: Logs are purely transport platforms. Placing collectible items (bonus points, extra time, extra life) on specific logs would add risk-reward decisions to river crossing.

3. **Add visual feedback for deaths**: Death is instant with no animation. Adding a brief splash effect for drowning, a collision flash for car hits, or a puff animation for missed docks would improve game feel.

4. **Vary traffic patterns per level**: Traffic always resets to the same initial layout. Randomizing car counts, speeds, or adding new obstacle types (e.g., faster motorcycles, alligators in the river) per level would increase replay variety.

5. **Add a high score display**: Score is shown during gameplay but not persisted. Tracking and displaying the best score achieved would give players a persistent goal across sessions.

6. **Improve river log visibility**: Logs all look identical regardless of width. Adding visual variation (different wood tones, moss, or turtle-back logs that periodically submerge) would make the river section more visually interesting and add gameplay variety.
