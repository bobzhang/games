# Match-3 Garden 2026

A classic match-3 puzzle game on an 8x8 board with 6 flower tile types. Select adjacent tiles to swap them, and if the swap creates a horizontal or vertical line of 3 or more matching tiles, those tiles are cleared and new ones fall in from above. Cascade chain reactions score progressively higher combos. The player has 30 moves to achieve the highest score possible.

The game uses a match-then-gravity loop: after each valid swap, all matches of 3+ tiles in any row or column are removed simultaneously, tiles above fall down to fill gaps, empty spaces at the top are refilled with random tiles, and the process repeats until no more matches exist. Each cascade step increases the combo multiplier, awarding `removed * 10 * combo` points per step. Invalid swaps (those that do not create any match) are automatically reversed.

## Build and Run

```bash
moon build --target native raylib_match3_garden_2026/
./_build/native/debug/build/raylib_match3_garden_2026/raylib_match3_garden_2026.exe
```

## Controls

- **Arrow Keys / W/A/S/D**: Move cursor across the 8x8 board
- **Enter / Space**: Select tile under cursor, then select an adjacent tile to swap
- **R**: Restart with a fresh board and 30 moves

## How to Play

You start with a randomly generated 8x8 board containing 6 types of flower tiles (colored circles: red, orange, yellow, lime, skyblue, brown). The board is generated to contain no pre-existing matches of 3 or more.

Move the cursor with arrow keys or WASD and press Enter/Space to select a tile. Then move to an adjacent tile (up, down, left, or right -- not diagonal) and press Enter/Space again to swap. If the swap creates one or more lines of 3+ matching tiles, those tiles are cleared and scored. Tiles above the cleared cells fall down, and new random tiles fill in from the top. If cascading matches occur, each successive cascade increases the combo multiplier.

If a swap would not create any match, it is automatically reversed and no move is consumed. If the second selection is not adjacent to the first, the selection is moved to the new tile instead.

You have 30 moves. When moves run out, the game displays "GARDEN SHIFT ENDED" and you can press R to start a new run.

## Public API Reference

### Package `raylib_match3_garden_2026`

> Main entry point and complete game implementation (single-file game).

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1080` | Screen width in pixels |
| `sh` | `Int` | `720` | Screen height in pixels |
| `board_w` | `Int` | `8` | Board width in tiles |
| `board_h` | `Int` | `8` | Board height in tiles |
| `tile_count` | `Int` | `6` | Number of distinct tile types |
| `cell` | `Int` | `64` | Cell size in pixels |
| `board_px` | `Int` | `220` | Board X offset in pixels |
| `board_py` | `Int` | `96` | Board Y offset in pixels |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `idx` | `(Int, Int) -> Int` | Converts (x, y) board coordinates to a flat array index |
| `tile_color` | `(Int) -> @raylib.Color` | Maps tile type (0-5) to its display color |
| `random_tile` | `() -> Int` | Returns a random tile type in range [0, tile_count-1] |
| `fill_board_no_matches` | `(Array[Int]) -> Unit` | Fills the board with random tiles while preventing initial matches of 3+ |
| `mark_matches` | `(Array[Int], Array[Bool]) -> Int` | Scans board for horizontal and vertical runs of 3+ matching tiles, marks them in the boolean array, and returns the count of marked tiles |
| `apply_matches_and_refill` | `(Array[Int], Array[Bool]) -> Int` | Removes marked tiles, applies gravity (tiles fall down), fills empty top cells with random tiles, returns count of removed tiles |
| `swap_tiles` | `(Array[Int], Int, Int, Int, Int) -> Unit` | Swaps two tiles on the board given their (x1, y1) and (x2, y2) coordinates |
| `main` | `() -> Unit` | Entry point: initializes window at 1080x720 at 60 FPS, runs main game loop with input handling, match logic, and rendering |

## Architecture

### Package Structure

```
raylib_match3_garden_2026/
├── main.mbt         — Complete game: constants, board logic, match detection, input, rendering
└── moon.pkg         — Package config with raylib import
```

### Data Flow

1. **Initialization**: `main` creates a flat `Array[Int]` of size 64 (8x8) as the board, calls `fill_board_no_matches` to populate it without pre-existing matches, and initializes cursor, selection, score, and move counters.
2. **Input**: Each frame checks for R (restart), arrow/WASD keys (cursor movement), and Enter/Space (select/swap). Input is only processed when moves remain.
3. **Selection & Swap**: First Enter/Space press selects the tile under the cursor. Second press on an adjacent tile triggers `swap_tiles`. If `mark_matches` finds matches, the swap is committed and a cascade loop begins. If no matches, `swap_tiles` is called again to reverse the swap.
4. **Cascade Loop**: After a valid swap, the game enters a while loop: `mark_matches` detects all matching runs, `apply_matches_and_refill` removes matches and applies gravity, score is accumulated with increasing combo multiplier, and the loop repeats until no more matches exist.
5. **Rendering**: Each frame draws the title, score, moves, best combo, the board background, tile circles with outlines, cursor highlight (yellow), selection highlight (red), a message bar, and the game-over overlay when moves reach zero.

### Key Design Patterns

- **Match-3 cascade loop**: The core mechanic uses a `while matched > 0` loop that repeatedly marks, clears, drops, refills, and re-checks, allowing unlimited cascade depth with escalating combo scoring.
- **No-match board generation**: `fill_board_no_matches` uses a retry approach (up to 30 retries per cell) to ensure no horizontal or vertical run of 3+ identical tiles exists at game start.
- **Gravity-then-refill**: `apply_matches_and_refill` processes each column bottom-up, compacting non-empty tiles downward, then fills remaining top positions with random tiles.
- **Invalid swap reversal**: Swaps that produce no match are immediately reversed by calling `swap_tiles` a second time, ensuring the board state is never corrupted.
- **Flat array board representation**: The board uses a single `Array[Int]` indexed by `y * board_w + x`, with -1 representing temporarily empty cells during match processing.
- **Single-file architecture**: The entire game (constants, logic, rendering) is contained in one file, appropriate for a compact puzzle game with no state machine complexity.

## Improvement & Refinement Plan

1. **Add tile removal animation**: Currently tiles disappear instantly. Adding a brief shrink or fade animation before gravity takes effect would make cascades more visually satisfying.

2. **Implement gravity animation**: Tiles snap instantly to their new positions after a match. Animating the downward slide would make the cascade mechanic more readable and appealing.

3. **Add mouse/touch input**: The game only supports keyboard input. Adding click-to-select on the board grid would make it accessible for mouse and touch users.

4. **Prevent deadlocked boards**: After cascades, the board may have no valid swaps remaining. Adding a deadlock detection step (checking all adjacent swap pairs for potential matches) with automatic shuffle would prevent unwinnable states.

5. **Add scoring tiers and feedback**: The game shows a final score but provides no context for how good it is. Adding score tiers (e.g., bronze/silver/gold) or a high score tracker would give players goals to aim for.

6. **Implement special tiles**: Matching 4 or 5 tiles could create special tiles (line clearers, board bombs) that trigger enhanced effects when matched, adding strategic depth beyond simple swapping.

7. **Add sound effects**: The game has no audio feedback. Adding match sounds, cascade chimes with increasing pitch, and a game-over jingle would significantly improve the experience.
