# Magnet Maze 2026

A turn-based grid puzzle game where the player navigates a 14x10 walled maze and uses magnetic pulses to guide four metallic orbs onto matching goal positions. The game combines Sokoban-style spatial reasoning with a twist: instead of pushing objects directly, the player emits attract or repel pulses that simultaneously move all orbs in the maze relative to the player's position.

Each pulse moves every orb one cell toward (attract) or away from (repel) the player along the dominant axis, unless blocked by walls, other orbs, or the player. The challenge lies in positioning yourself strategically so that a single pulse moves the right orbs in the right directions. Three handcrafted levels with increasing wall complexity and tighter turn limits test the player's ability to plan multi-step magnetic sequences. A star rating system rewards efficient solutions with bonus score.

## Build and Run

```bash
moon build --target native raylib_magnet_maze_2026/
./_build/native/debug/build/raylib_magnet_maze_2026/raylib_magnet_maze_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Move the player one cell in the corresponding direction
- **Space/Enter/J**: Emit a magnetic pulse (attract or repel based on current mode)
- **Tab/T**: Toggle between attract and repel mode
- **R**: Restart from level 1
- **Touch controls**: On-screen D-pad (UP/DOWN/LEFT/RIGHT), PULSE button, and ATTRACT/REPEL toggle button

## How to Play

You control a magnetic character on a 14x10 grid. Four silver orbs are scattered across the maze, and four gold goal positions mark where they need to end up. Both moving and pulsing consume one turn from the level's turn limit.

**Moving**: Use arrow keys or WASD to move one cell at a time. You cannot move into walls or cells occupied by orbs.

**Pulsing**: Press Space to emit a magnetic pulse. In attract mode, all orbs move one cell toward you along the axis with the greatest distance. In repel mode, orbs move one cell away from you. Orbs are blocked by walls, other orbs, and the player's position.

**Levels**: Three levels with turn limits of 30, 34, and 38 respectively. Each level has unique wall layouts creating corridors that constrain orb movement. When all four orbs rest on goal positions, the level is solved and you earn a score bonus based on remaining turns. Stars are awarded: 3 stars for 10+ turns remaining, 2 stars for 5+, and 1 star otherwise.

**Win/Lose**: Complete all three levels to earn the "Magnet Master" title. Running out of turns results in failure. Press R to restart at any time.

## Public API Reference

### Package `raylib_magnet_maze_2026`

> Main entry point and single-file game implementation.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1220` | Screen width in pixels |
| `sh` | `Int` | `820` | Screen height in pixels |
| `gw` | `Int` | `14` | Grid width in cells |
| `gh` | `Int` | `10` | Grid height in cells |
| `cell` | `Int` | `64` | Cell size in pixels |
| `ox` | `Int` | `162` | Grid X offset for rendering |
| `oy` | `Int` | `104` | Grid Y offset for rendering |
| `max_orbs` | `Int` | `4` | Number of orbs and goals per level |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Orb` | `x`, `y`, `active` | A magnetic orb with grid coordinates and active state |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `idx` | `(Int, Int) -> Int` | Converts 2D grid coordinates to a 1D array index |
| `absi` | `(Int) -> Int` | Returns the absolute value of an integer |
| `signi` | `(Int) -> Int` | Returns the sign of an integer (-1, 0, or 1) |
| `in_bounds` | `(Int, Int) -> Bool` | Checks if grid coordinates are within the 14x10 grid |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside a rectangle (for touch input) |
| `clear_walls` | `(Array[Bool]) -> Unit` | Resets all wall cells to false |
| `clear_orbs` | `(Array[Orb]) -> Unit` | Resets all orbs to inactive state |
| `set_orb` | `(Array[Orb], Int, Int, Int) -> Unit` | Places an orb at grid position (x, y) and marks it active |
| `set_goal` | `(Array[Int], Array[Int], Int, Int, Int) -> Unit` | Sets a goal position at index i to coordinates (x, y) |
| `is_wall` | `(Array[Bool], Int, Int) -> Bool` | Checks if a cell is a wall (out-of-bounds counts as wall) |
| `orb_at` | `(Array[Orb], Int, Int, Int) -> Bool` | Checks if any active orb (except index skip) occupies position (x, y) |
| `goal_at` | `(Array[Int], Array[Int], Int, Int) -> Bool` | Checks if a goal exists at position (x, y) |
| `goals_completed` | `(Array[Orb], Array[Int], Array[Int]) -> Int` | Counts how many orbs are currently on goal positions |
| `all_orbs_on_goals` | `(Array[Orb], Array[Int], Array[Int]) -> Bool` | Returns true when all orbs are on goals |
| `setup_level` | `(Int, Array[Bool], Array[Orb], Array[Int], Array[Int]) -> (Int, Int, Int)` | Configures walls, orbs, and goals for a level; returns (player_x, player_y, turn_limit) |
| `try_move_player` | `(Array[Bool], Array[Orb], Int, Int, Int, Int) -> (Int, Int, Bool)` | Attempts to move the player by (dx, dy); returns new position and success flag |
| `apply_pulse` | `(Array[Orb], Array[Bool], Int, Int, Bool) -> Int` | Applies a magnetic pulse from player position, moving orbs toward/away; returns count of orbs moved |
| `main` | `() -> Unit` | Entry point: initializes window, runs game loop with input, logic, and rendering |

## Architecture

### Package Structure

```
raylib_magnet_maze_2026/
├── main.mbt              — Complete game: entry point, types, logic, rendering
└── moon.pkg              — Package config with raylib import
```

This is a single-file game with all logic contained in `main.mbt`. The grid state is represented as a flat boolean array for walls, an array of `Orb` structs for orbs, and parallel integer arrays for goal coordinates.

### Data Flow

1. **Initialization**: `main` allocates the walls array (`gw * gh` booleans), orbs array, and goal coordinate arrays. `setup_level` populates them for the current level and returns the player start position and turn limit.
2. **Input**: Each frame checks for keyboard presses (movement keys, pulse, mode toggle) and touch input via `inside_rect` checks against on-screen button positions.
3. **Logic**: Movement calls `try_move_player` which validates against walls and orbs. Pulses call `apply_pulse` which iterates all orbs, computes the dominant axis toward/away from the player, and moves orbs one cell if the destination is valid. Each action decrements `turns_left`. After each turn, `all_orbs_on_goals` checks for level completion.
4. **Rendering**: The grid is drawn cell by cell with walls shown as darker rectangles. Goals appear as yellow circles, orbs as white circles with highlights, and the player as a colored circle (green for attract, red for repel). Touch UI buttons are drawn at fixed screen positions.

### Key Design Patterns

- **Turn-based state machine**: Every move or pulse consumes one turn, creating discrete puzzle states. The `consumed_turn` flag ensures only valid actions decrement the counter.
- **Grid-based collision**: All movement is validated against the walls array and orb positions using `is_wall`, `orb_at`, and `in_bounds` functions.
- **Dominant-axis magnetic movement**: `apply_pulse` determines direction by comparing absolute distances on X and Y axes, moving orbs along whichever axis has the greater displacement.
- **Level progression with transition**: A `transition_t` timer creates a brief "SECTOR CLEAR" overlay before advancing to the next level.
- **Star rating**: Performance is measured by remaining turns after solving, incentivizing efficient solutions.

## Improvement & Refinement Plan

1. **Add undo functionality**: The turn-based nature makes undo straightforward. Storing a history stack of `(player_pos, orb_positions, turns_left)` tuples would let players experiment without full restarts via `setup_level`.

2. **Expand level count**: Only three levels exist in `setup_level`. Adding a procedural level generator that places walls and validates solvability would dramatically extend replayability.

3. **Add diagonal or multi-cell pulse movement**: Currently `apply_pulse` moves orbs exactly one cell along the dominant axis. An advanced mode where orbs slide until hitting a wall (like ice physics) would create richer puzzle possibilities.

4. **Use enum for game state**: The `over` and `won` booleans could be replaced with a `GameState` enum (`Playing`, `LevelTransition`, `Won`, `Lost`) for clearer state management.

5. **Improve orb-goal matching visualization**: Currently any orb on any goal counts as completed. Adding color-coded orb-goal pairs and visual feedback (glow, animation) when an orb reaches its goal would improve the puzzle clarity.

6. **Extract level data to a configuration format**: Level layouts are hardcoded as sequences of `walls[idx(x,y)] = true` calls. Defining levels as grid strings or arrays would make adding and modifying levels much easier.
