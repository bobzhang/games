# Tetris Meteor Fall 2026

A faithful implementation of the classic Tetris block-stacking puzzle game, themed around meteors falling from space. All seven standard tetrominoes (I, O, T, S, Z, J, L) are present, each with full rotation support across four orientations. The game runs on a 10-column by 20-row board with a dark space-themed aesthetic.

The core gameplay follows standard Tetris rules: tetrominoes fall from the top of the board, the player positions and rotates them, and completed horizontal lines are cleared for points. The game features a 7-bag randomizer for fair piece distribution, a hold system that lets the player swap the current piece once per drop, and a ghost piece that previews the landing position. Scoring follows the classic multiplier system -- single (100), double (300), triple (500), and Tetris/quad (800) -- multiplied by the current level. Soft drop awards 1 point per cell, and hard drop awards 2 points per cell traveled.

The difficulty curve is driven by the level system: every 10 lines cleared advances the level, which decreases the drop interval from 0.70 seconds by 0.05 per level down to a minimum of 0.09 seconds. Wall kicks allow rotation near edges with up to 5 horizontal offset attempts.

## Build and Run

```bash
moon build --target native raylib_tetris_meteor_fall_2026/
./_build/native/debug/build/raylib_tetris_meteor_fall_2026/raylib_tetris_meteor_fall_2026.exe
```

## Controls

- **Left Arrow**: Move piece left
- **Right Arrow**: Move piece right
- **Down Arrow**: Soft drop (hold for fast fall at 0.08x interval)
- **Up Arrow / X**: Rotate clockwise
- **Z**: Rotate counter-clockwise
- **Space**: Hard drop (instantly drops piece to landing position)
- **C**: Hold piece (swap current piece with hold slot, once per drop)
- **R**: Restart game (when game over)

## How to Play

Tetrominoes fall from the top of the 10x20 board. Use left/right to position them, Up/X or Z to rotate, and Space to hard drop. Complete full horizontal lines to clear them and earn points. The scoring system rewards clearing multiple lines at once:

- **Single** (1 line): 100 * level
- **Double** (2 lines): 300 * level
- **Triple** (3 lines): 500 * level
- **Tetris** (4 lines): 800 * level

Every 10 lines cleared advances the level, increasing the drop speed. Use the **Hold** system (C key) to stash a piece for later -- you can only hold once per piece drop. The **Next** preview on the right side shows the upcoming piece. A transparent ghost piece on the board shows exactly where the current piece will land.

The game ends when a new piece spawns and immediately collides with existing blocks on the board. Press R to restart.

## Public API Reference

### Package `raylib_tetris_meteor_fall_2026`

> Main entry point. Initializes a 560x700 window at 60 FPS, creates the Game, and runs the update/draw loop.

No additional public types or functions beyond `main`.

### Package `raylib_tetris_meteor_fall_2026/internal/types`

> Core type definitions, piece data, board utilities, and constants.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Cell` | `x`, `y` | A 2D integer coordinate used for piece block offsets |
| `Game` | `board`, `piece_kind`, `piece_rot`, `piece_x`, `piece_y`, `next_kind`, `hold_kind`, `hold_used`, `score`, `lines`, `level`, `drop_timer`, `drop_interval`, `over`, `bag`, `bag_pos` | Main game state container with the board grid, active piece, preview/hold, scoring, and 7-bag randomizer |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Game::new` | `() -> Game` | Creates a new game with an empty 10x20 board, initial drop interval of 0.65s, and an empty bag |
| `normalize_rot` | `(Int) -> Int` | Normalizes a rotation value to [0, 3] range |
| `make_cell` | `(Int, Int) -> Cell` | Creates a Cell with given x, y coordinates |
| `piece_cell` | `(Int, Int, Int) -> Cell` | Returns the block offset for a given piece kind (0-6), rotation (0-3), and block index (0-3) |
| `piece_color` | `(Int) -> @raylib.Color` | Maps a color ID (1-7) to the corresponding tetromino color (skyblue, yellow, purple, lime, red, blue, orange) |
| `board_index` | `(Int, Int) -> Int` | Converts board (x, y) coordinates to a flat array index |
| `collides` | `(Game, Int, Int, Int, Int) -> Bool` | Checks if a piece (kind, rotation) at position (px, py) would collide with board edges or existing blocks |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `board_cols` | `Int` | 10 | Board width in cells |
| `board_rows` | `Int` | 20 | Board height in cells |
| `board_cell` | `Int` | 30 | Cell size in pixels |
| `board_x` | `Int` | 42 | Board left offset in pixels |
| `board_y` | `Int` | 24 | Board top offset in pixels |
| `side_panel_x` | `Int` | 366 | X position of the side panel (next/hold/score) |
| `screen_width` | `Int` | 560 | Window width |
| `screen_height` | `Int` | 700 | Window height |
| `bag_size` | `Int` | 7 | Size of the 7-bag randomizer |
| `score_single` | `Int` | 100 | Points for clearing 1 line |
| `score_double` | `Int` | 300 | Points for clearing 2 lines |
| `score_triple` | `Int` | 500 | Points for clearing 3 lines |
| `score_tetris` | `Int` | 800 | Points for clearing 4 lines |

### Package `raylib_tetris_meteor_fall_2026/internal/game`

> Game logic: piece movement, rotation, locking, line clearing, scoring, and bag randomization.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `reset_game` | `(@types.Game) -> Unit` | Clears the board, resets score/lines/level, refills the bag, and spawns the first piece |
| `update_game` | `(@types.Game, Float) -> Unit` | Main update: reads input, handles movement/rotation/hold/drop, advances gravity timer, locks pieces, clears lines, checks game over |

### Package `raylib_tetris_meteor_fall_2026/internal/render`

> Rendering: board grid, pieces, ghost piece, HUD panels, and game over overlay.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(@types.Game) -> Unit` | Main render entry point: draws the board grid, locked blocks, ghost piece, active piece, next/hold previews, score/lines/level display, controls reference, and game over overlay |

## Architecture

### Package Structure

```
raylib_tetris_meteor_fall_2026/
├── main.mbt              — Entry point: window init (560x700), game loop
├── moon.pkg              — Package config with raylib and internal imports
└── internal/
    ├── types/
    │   ├── types.mbt     — Cell and Game structs with constructors
    │   ├── constants.mbt — Board dimensions, scoring values, screen layout
    │   ├── pieces.mbt    — All 7 tetromino definitions with rotation data and colors
    │   └── utils.mbt     — Board index helper and collision detection
    ├── game/
    │   └── logic.mbt     — Bag randomizer, piece spawning, movement, rotation with wall kicks, locking, line clearing, scoring, hold system
    └── render/
        └── render.mbt    — Board rendering, piece drawing, ghost piece, HUD with next/hold previews and score display
```

The types package defines the game data model and piece geometry. The game package contains all logic with no rendering code. The render package reads game state for drawing with no side effects on game state.

### Data Flow

1. `main` creates a `Game` via `Game::new()` and calls `reset_game()` to initialize the bag and spawn the first piece.
2. Each frame, `update_game()` is called with clamped delta time. It processes input (movement, rotation, hard drop, hold), advances the gravity drop timer, and handles piece locking when a downward move fails.
3. When a piece locks, `lock_piece()` writes the piece's blocks to the board array, `clear_lines()` scans for and removes full rows (shifting down), and `apply_line_score()` updates score, lines, level, and drop interval.
4. `spawn_piece()` pulls the next piece from the bag (refilling via Fisher-Yates shuffle when exhausted) and checks for immediate collision (game over).
5. `draw_frame()` renders the board, ghost piece, active piece, HUD panels, and game-over overlay.

### Key Design Patterns

- **7-Bag Randomizer**: The `bag` array holds pieces 0-6, shuffled via Fisher-Yates. When all pieces are consumed (`bag_pos >= bag_size`), `refill_bag()` reshuffles. This ensures each piece type appears exactly once per 7-piece cycle.
- **Piece Geometry via Function**: Rather than lookup tables, `piece_cell()` uses nested match expressions to return block offsets for any (kind, rotation, block) combination, encoding all 7 pieces x 4 rotations x 4 blocks.
- **Wall Kick System**: `try_rotate()` attempts the new rotation with horizontal offsets [0, -1, +1, -2, +2], accepting the first non-colliding position.
- **Ghost Piece**: The `ghost_y()` function in the render package drops a copy of the current piece downward until collision, showing the projected landing position.
- **Flat Board Array**: The 10x20 board is stored as a flat `Array[Int]` with `board_index(x, y)` for access. Cell values are 0 (empty) or 1-7 (piece color ID).
- **Hold System**: `use_hold()` swaps the current piece with the hold slot. The `hold_used` flag prevents multiple holds per piece.

## Improvement & Refinement Plan

1. **Add T-spin detection and scoring**: The current scoring only considers line count (single/double/triple/tetris). Implementing T-spin detection (checking if the T piece was rotated into place and the corners are filled) would add a significant strategic dimension and reward advanced play.

2. **Implement proper SRS wall kick tables**: The `try_rotate()` function uses a simple linear offset array `[0, -1, 1, -2, 2]`. The standard Super Rotation System defines different kick tables for each piece type and rotation direction, which would make rotation behavior feel more natural and competitive.

3. **Add lock delay**: Currently, a piece locks immediately when it cannot move down. Adding a brief lock delay (e.g., 0.5 seconds) that resets on successful movement would give players time to slide pieces under overhangs, which is a standard feature in modern Tetris implementations.

4. **Implement DAS (Delayed Auto Shift)**: The input system only handles key-pressed events for left/right movement. Adding DAS (initial delay then repeat) for held direction keys would make piece positioning faster and more fluid at high levels.

5. **Add line clear visual effect**: The `clear_lines()` function immediately removes full rows with no animation. Adding a brief flash, row highlight, or particle burst when lines are cleared would provide satisfying visual feedback.

6. **Add a title/pause screen**: The game currently starts immediately on launch with no title screen or pause functionality. Adding state management for title, play, and paused states would improve the user experience.

7. **Persist high score**: The score resets on game restart with no record of previous achievements. Saving the best score to disk would motivate repeated play.

8. **Add soft drop scoring at correct rate**: The current soft drop gives 1 point per key press rather than per cell traveled, which diverges from the standard rule of 1 point per cell. The hard drop correctly awards 2 points per cell.
