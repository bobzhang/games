# Minesweeper

A classic Minesweeper implementation built with MoonBit and raylib, featuring a 16x16 grid with 40 hidden mines. The game faithfully recreates the retro Windows Minesweeper experience, complete with 3D-raised cell visuals, numbered adjacency hints in traditional colors, and a timer display.

The core gameplay loop is straightforward: left-click to reveal cells, right-click to toggle flags on suspected mines, and work through logical deduction to uncover every safe cell. The first click is always guaranteed safe, as mines are generated after the initial click with a 3x3 exclusion zone around the chosen cell. Revealing a cell with no adjacent mines triggers a recursive flood-fill that automatically expands the cleared region. The game tracks elapsed time (up to 999 seconds) and remaining mine count based on placed flags.

The entire game is implemented in a single `main.mbt` file using flat integer arrays for mine placement, revealed state, flag state, and adjacency counts. This makes the data layout cache-friendly and the logic easy to follow, while the classic 3D beveled cell rendering is achieved with carefully placed light and dark edge lines.

## Build and Run

```bash
moon build --target native raylib_minesweeper/
./_build/native/debug/build/raylib_minesweeper/raylib_minesweeper.exe
```

## Controls

- **Left Click**: Reveal a cell (first click generates the minefield)
- **Right Click**: Toggle flag on an unrevealed cell
- **R**: Restart game (resets board, timer, and flags)

## How to Play

Click any cell to begin. The first click is always safe — mines are placed after your initial click, with a 3x3 safe zone around the clicked cell. Revealed cells display a colored number (1–8) indicating how many of the 8 neighboring cells contain mines. If a revealed cell has zero adjacent mines, the game automatically flood-fills outward, revealing all connected safe cells until numbered boundary cells are reached.

Right-click unrevealed cells to place or remove flags marking suspected mines. The header displays remaining mines (total mines minus flags placed) and a running timer. Reveal every non-mine cell to win. Click a mine and the game ends, revealing all mine positions as black circles. Press R at any time to restart with a fresh board.

Number colors follow the classic Minesweeper convention: 1 = blue, 2 = green, 3 = red, 4 = dark blue, 5 = maroon, 6 = teal, 7 = black, 8 = gray.

## Public API Reference

### Package `raylib_minesweeper`

> Main entry point and complete game implementation in a single file.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `Rows` | `Int` | `16` | Number of rows in the grid |
| `Cols` | `Int` | `16` | Number of columns in the grid |
| `MineCount` | `Int` | `40` | Total number of mines placed on the board |
| `CellSize` | `Int` | `30` | Pixel size of each cell |
| `GridOffsetX` | `Int` | `10` | Horizontal pixel offset for the grid |
| `GridOffsetY` | `Int` | `60` | Vertical pixel offset for the grid (leaves room for header) |
| `StateWaiting` | `Int` | `0` | Game state: waiting for first click |
| `StatePlaying` | `Int` | `1` | Game state: actively playing |
| `StateWon` | `Int` | `2` | Game state: player won |
| `StateLost` | `Int` | `3` | Game state: player lost |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `cell_index` | `(Int, Int) -> Int` | Converts (row, col) coordinates to a flat array index |
| `in_bounds` | `(Int, Int) -> Bool` | Checks whether (row, col) is within the grid boundaries |
| `count_adjacent` | `(Array[Int], Int, Int) -> Int` | Counts mines in the 8 cells surrounding the given (row, col) |
| `number_color` | `(Int) -> @raylib.Color` | Returns the classic Minesweeper color for a given adjacency number (1–8) |
| `generate_mines` | `(Array[Int], Array[Int], Int, Int) -> Unit` | Places mines randomly, avoiding a 3x3 safe zone around (safe_row, safe_col), then computes adjacency counts |
| `flood_fill` | `(Array[Int], Array[Int], Array[Int], Array[Int], Int, Int) -> Unit` | Recursively reveals cells starting from (row, col), expanding through cells with zero adjacent mines |
| `check_win` | `(Array[Int], Array[Int]) -> Bool` | Returns true if all non-mine cells have been revealed |
| `reset_game` | `(Array[Int], Array[Int], Array[Int], Array[Int]) -> Unit` | Clears all game arrays (mines, revealed, flagged, adjacent) to zeros |
| `main` | `() -> Unit` | Entry point: initializes window, runs game loop with input handling, update logic, and rendering |

## Architecture

### Package Structure

```
raylib_minesweeper/
├── main.mbt              — Complete game: constants, logic, rendering, entry point
└── moon.pkg              — Package config with raylib import
```

This is a single-file game implementation. All constants, helper functions, game logic, and rendering code reside in `main.mbt`. The game state is managed through four flat `Array[Int]` arrays (`mines`, `revealed`, `flagged`, `adjacent`) and an integer state variable.

### Data Flow

1. **Input**: `main` checks for key R (restart) and mouse clicks. Mouse position is converted to grid coordinates via `(mx - GridOffsetX) / CellSize`.
2. **First Click**: On the first left-click, `generate_mines` populates the mines array (excluding the 3x3 safe zone) and precomputes all adjacency counts.
3. **Reveal**: Left-clicking an unflagged, unrevealed cell either triggers `flood_fill` (safe cell) or sets `StateLost` (mine cell). After each reveal, `check_win` tests whether all safe cells are uncovered.
4. **Flagging**: Right-clicking toggles the `flagged` array and updates `flags_placed`.
5. **Rendering**: The grid is drawn cell-by-cell. Unrevealed cells get 3D beveled edges (light top-left, dark bottom-right). Revealed cells show adjacency numbers via `number_color` or mine circles. The header shows mine count, status text, and timer.

### Key Design Patterns

- **Flat array grid representation**: Four parallel `Array[Int]` arrays (`mines`, `revealed`, `flagged`, `adjacent`) indexed by `row * Cols + col`, providing cache-friendly access and simple state management.
- **Deferred mine generation**: Mines are placed only after the first click via `generate_mines`, guaranteeing a safe start with a 3x3 exclusion zone.
- **Recursive flood fill**: `flood_fill` uses direct recursion over the 8-neighbor pattern to auto-reveal connected empty regions.
- **Integer state machine**: Game states are represented as integer constants (`StateWaiting`, `StatePlaying`, `StateWon`, `StateLost`) rather than an enum, keeping the implementation minimal.
- **Classic 3D cell rendering**: Unrevealed cells use light/dark edge lines to simulate the raised button appearance of classic Minesweeper.

## Improvement & Refinement Plan

1. **Use an enum for game state**: Replace `StateWaiting`/`StatePlaying`/`StateWon`/`StateLost` integer constants with a proper MoonBit enum type for exhaustive pattern matching and type safety.
2. **Encapsulate game state in a struct**: The four parallel arrays (`mines`, `revealed`, `flagged`, `adjacent`) and scalar variables (`game_state`, `flags_placed`, etc.) could be grouped into a `Game` struct, reducing function parameter counts significantly (e.g., `flood_fill` currently takes 6 parameters).
3. **Use iterative flood fill**: The current recursive `flood_fill` could overflow the stack on very large grids. An iterative approach using an explicit stack or queue would be more robust.
4. **Add chord clicking**: Classic Minesweeper supports clicking a revealed numbered cell (when the correct number of adjacent flags are placed) to auto-reveal remaining neighbors. This is missing from the current input handling.
5. **Extract rendering into helper functions**: The rendering section in `main` is over 80 lines of inline drawing code. Extracting `draw_header`, `draw_cell`, and `draw_grid` functions would improve readability.
6. **Make grid size configurable**: The constants `Rows`, `Cols`, and `MineCount` are hardcoded. Adding difficulty presets (Beginner 9x9/10, Intermediate 16x16/40, Expert 30x16/99) would enhance replayability.
7. **Add flag count validation**: The current code allows placing more flags than there are mines. Adding a cap at `MineCount` flags or a visual warning would improve the player experience.
