# raylib_pac_dash_2026

A Pac-Man-inspired maze game with classic mechanics: eat all pellets, avoid four colored ghosts, grab power pellets to turn the tables, and clear the maze to win.

## Build and Run

```bash
cd examples && moon build --target native raylib_pac_dash_2026/
cd examples && ./_build/native/debug/build/raylib_pac_dash_2026/raylib_pac_dash_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move player through the maze

## How to Play

- Navigate a 21x23 tile maze eating pellets for points (10 points each)
- Collect power pellets to enter frightened mode where you can eat ghosts
- Four ghosts with distinct colors chase you using alternating chase and scatter phases
- Eat all pellets to win the level
- You have 3 lives -- losing them all ends the game
- Ghosts eaten during frightened mode award bonus points

## Public API Reference

### Package `raylib_pac_dash_2026`

> Main entry point. Initializes the window, creates the game state, and runs the main loop.

No additional public types or functions beyond the `main` entry point.

### Package `raylib_pac_dash_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Ghost` | `x`, `y`, `dir_x`, `dir_y`, `start_x`, `start_y`, `scatter_x`, `scatter_y`, `color` | Ghost actor state including movement direction and scatter home position |
| `Game` | `walls`, `pellets`, `player_x`, `player_y`, `dir_x`, `dir_y`, `want_x`, `want_y`, `ghosts`, `score`, `lives`, `pellets_left`, `frightened_timer`, `chase_mode`, `game_over`, `win` | Complete runtime state for one Pac Dash session |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Ghost::new` | `(Int, Int, Int, Int, @raylib.Color) -> Ghost` | Creates a ghost at its spawn position with a given scatter target and color |
| `Game::new` | `() -> Game` | Allocates a fresh game state with empty maze layers and default counters |
| `map_index` | `(Int, Int) -> Int` | Converts maze coordinates to a linear array index |
| `in_map` | `(Int, Int) -> Bool` | Returns whether a tile coordinate lies inside maze bounds |
| `tunnel_wrap_x` | `(Int) -> Int` | Wraps a horizontal tunnel coordinate to the opposite edge |
| `is_walkable` | `(Game, Int, Int) -> Bool` | Returns whether a tile is walkable for the player and ghosts |
| `manhattan_distance` | `(Int, Int, Int, Int) -> Int` | Manhattan distance between two grid coordinates |
| `tile_center_x` | `(Int) -> Int` | Converts tile X to on-screen center pixel X |
| `tile_center_y` | `(Int) -> Int` | Converts tile Y to on-screen center pixel Y |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `maze_cols` | `Int` | 21 | Number of columns in the maze grid |
| `maze_rows` | `Int` | 23 | Number of rows in the maze grid |
| `tile_size` | `Int` | 24 | Pixel size of one maze tile |
| `maze_x` | `Int` | 24 | Left screen offset for maze rendering |
| `maze_y` | `Int` | 24 | Top screen offset for maze rendering |
| `hud_x` | `Int` | computed | Left X coordinate for HUD text block |
| `screen_width` | `Int` | 760 | Window width in pixels |
| `screen_height` | `Int` | 610 | Window height in pixels |

### Package `raylib_pac_dash_2026/internal/game`

> Game logic, maze setup, AI, and state transitions.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `init_game` | `(@types.Game) -> Unit` | Builds the maze walls, resets pellets, and places the player and all four ghosts at their starting positions |
| `update_game` | `(@types.Game, Float) -> Unit` | Per-frame update: reads input, advances player and ghost movement timers, resolves collisions, and updates game state |

### Package `raylib_pac_dash_2026/internal/render`

> Rendering for the maze, entities, and HUD.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(@types.Game) -> Unit` | Main rendering entry point: draws the maze, player, ghosts, HUD, and game-over or win overlays |

## Architecture

### Package Structure

```
raylib_pac_dash_2026/
├── main.mbt              — Entry point: window init, game creation, main loop
├── moon.pkg              — Package config with imports
└── internal/
    ├── types/
    │   ├── types.mbt     — Ghost and Game structs with constructors
    │   ├── constants.mbt — Screen dimensions and maze layout constants
    │   └── utils.mbt     — Grid math: map_index, is_walkable, tile_center_x/y
    ├── game/
    │   ├── logic.mbt     — Maze building, pellet reset, player/ghost stepping, collision, AI
    │   └── input.mbt     — Per-frame keyboard sampling into game.want_x/want_y
    └── render/
        └── render.mbt    — All drawing: maze tiles, player, ghosts, HUD, overlays
```

The `types` package provides all shared data structures and maze utility functions. The `game` package owns all state mutation including maze construction, movement stepping, ghost AI, and collision resolution. The `render` package is a read-only consumer of game state. The main entry point creates one `Game` instance, calls `init_game`, and runs the loop.

### Data Flow

1. **Input**: `try_set_player_wanted_dir` in `input.mbt` reads WASD/arrow keys and writes `game.want_x`/`game.want_y`, which the movement logic applies when the current tile boundary is reached.
2. **Update**: `update_game` in `logic.mbt` advances `step_timer_player` and `step_timer_ghost`. When timers expire, `step_player` moves the player (applying the wanted direction if walkable), `maybe_consume_pellet` awards points and checks for win, and `step_ghost` moves each ghost using `choose_ghost_target` (Manhattan distance chase toward player or scatter home). `resolve_collisions` then checks player-ghost proximity for life loss or ghost eating.
3. **Render**: `draw_frame` in `render.mbt` draws maze walls as filled rectangles, normal pellets as small dots, power pellets as larger circles, the player as a colored circle, each ghost with frightened coloring when active, and the HUD showing score and lives.

### Key Design Patterns

- **Tile-based step timers**: Player and ghost movement is governed by `step_timer_player` and `step_timer_ghost` counters, decrementing each frame and triggering a grid step when they expire. This decouples movement rate from frame rate.
- **Buffered input direction**: The player's desired direction (`want_x`, `want_y`) is buffered and applied on the next step when the target tile is walkable, producing smooth corner-turning similar to the original arcade game.
- **Chase/scatter phase cycling**: `phase_timer` tracks time in the current AI mode. `update_phase` alternates between scatter (ghosts return to their home corners) and chase (ghosts target the player) modes, resetting to scatter on player respawn.
- **Pool-free ghost array**: Ghosts are stored in a plain `Array[Ghost]` initialized at game start with fixed positions and colors. There are always exactly four ghosts; no activation flags are needed.
- **Tunnel wrapping**: `tunnel_wrap_x` in `utils.mbt` wraps x coordinates at maze boundaries, enabling the left-right tunnel effect without special-casing the movement logic.

## Improvement & Refinement Plan

1. **Add a `Ghost` state enum for home/chase/scatter/frightened/eaten**: Ghost behavior is currently controlled by a global `chase_mode` boolean and a shared `frightened_timer`. Using a per-ghost state enum would allow individual ghosts to be in different states (e.g., one is eaten and returning home while others are chasing).

2. **Implement distinct per-ghost AI personalities**: All four ghosts currently use the same `choose_ghost_target` function which returns either the player position or the scatter home. Classic Pac-Man characters use different targeting strategies (ambush, flanking, random). Adding per-ghost target computation would increase strategic depth.

3. **Add a level progression system**: Currently `init_game` always builds the same maze. A level counter with increasing ghost speed and reduced frightened duration on each level would add progression depth.

4. **Introduce a `GameState` enum instead of boolean flags**: `game_over` and `win` are separate booleans. A `GameState` enum (Playing, Win, GameOver, Respawning) would consolidate state transitions and make the update dispatch cleaner.

5. **Add a ghost-eaten bonus score sequence**: When a ghost is eaten during frightened mode, the classic game displays the point value (200, 400, 800, 1600) and briefly pauses movement. Implementing this visual feedback would improve game feel.

6. **Extract maze layout into a data file**: The maze is built procedurally inside `build_walls` in `logic.mbt`. Representing the layout as a static integer array or string pattern would make it easier to design new mazes without modifying logic code.
