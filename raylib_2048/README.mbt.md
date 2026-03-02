# 2048

A faithful recreation of the classic 2048 sliding-number puzzle game, built with MoonBit and raylib. The game presents a 4x4 grid where numbered tiles slide and merge, wrapped in a warm earth-tone color palette that closely mirrors the original web version's aesthetic.

The core gameplay loop consists of sliding all tiles in one of four cardinal directions. When two tiles carrying the same value collide during a slide, they merge into a single tile whose value is their sum. After every successful move a new tile (90% chance of a 2, 10% chance of a 4) spawns in a random empty cell. The player's score accumulates the values of all merged tiles. Reaching a tile with value 2048 triggers a win state, though the player may choose to continue playing for a higher score.

The implementation features smooth lerp-based slide and pop animations, a one-level undo system that saves and restores the entire board state, and a best-score tracker that persists across restarts within a session. The game uses a flat array of 16 tiles with index arithmetic (`row * 4 + col`) rather than a 2D array, keeping the data layout cache-friendly.

## Build and Run

```bash
moon build --target native raylib_2048/
./_build/native/debug/build/raylib_2048/raylib_2048.exe
```

## Controls

- **Arrow Keys / WASD**: Slide all tiles in the chosen direction (left, right, up, down)
- **Z / U**: Undo the last move (one level of undo; also works on Game Over screen)
- **R**: Restart the game with a fresh board
- **Enter / Space**: Start a new game from the title screen; continue playing after winning
- **Mouse Click**: Click "New Game" or "Undo" buttons in the header; click "New Game" on the title screen; click "Keep Going" on the win overlay

## How to Play

From the title screen, press Enter, Space, or click the "New Game" button to begin. The board starts with two randomly placed tiles. Use arrow keys or WASD to slide all tiles simultaneously in one direction. Tiles slide as far as they can and merge with an adjacent tile of the same value, doubling the result. Each merge adds the new tile's value to your score. A new tile spawns after every valid move.

The goal is to create a tile with the value 2048. When you do, a golden "You Win!" overlay appears with a "Keep Going" option that lets you continue beyond 2048 for a higher score. If no empty cells remain and no adjacent tiles share the same value, the game ends with a "Game Over" overlay. Press R or Enter to restart, or press Z/U to undo your last move and try a different approach.

Your best score within the current session is tracked and displayed alongside your current score in the header.

## Public API Reference

### Package `raylib_2048`

> Main entry point. Initializes the window, creates the game state, and runs the frame loop.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Entry point: creates a 560x740 window with MSAA 4x, runs the game loop at 60 FPS with clamped delta time |

### Package `raylib_2048/internal/types`

> Core type definitions, layout constants, color palette, and utility functions.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `Won`, `Over` | Drives the state machine that controls input handling and rendering branches |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Tile` | `value`, `anim_x`, `anim_y`, `target_x`, `target_y`, `scale`, `is_new`, `is_merged` | A single cell on the board; holds its numeric value and animation state for slide/pop effects |
| `Game` | `tiles`, `prev_values`, `state`, `score`, `best_score`, `prev_score`, `can_undo`, `animating`, `msg`, `msg_t`, `keep_playing` | Main game state container holding the 16-tile board, undo buffer, scores, and UI state |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Tile::empty` | `() -> Tile` | Creates an empty tile with value 0, no animation, and default scale |
| `Game::new` | `() -> Game` | Creates a new game instance in the Title state with a zeroed board and no score |
| `tile_color` | `(Int) -> @raylib.Color` | Returns the background color for a tile based on its value (2 through 2048+) |
| `tile_text_color` | `(Int) -> @raylib.Color` | Returns dark text for values <=4, light text for higher values |
| `tile_font_size` | `(Int) -> Int` | Returns an appropriate font size that shrinks as the number of digits grows |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value between a low and high bound |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `lerpf` | `(Float, Float, Float) -> Float` | Linearly interpolates between two floats by factor t |
| `cell_screen_x` | `(Int) -> Float` | Converts a column index to a screen X coordinate accounting for board padding and gaps |
| `cell_screen_y` | `(Int) -> Float` | Converts a row index to a screen Y coordinate accounting for board top offset, padding, and gaps |
| `rect` | `(Int, Int, Int, Int) -> @raylib.Rectangle` | Constructs a Rectangle from integer x, y, width, height values |
| `rectf` | `(Float, Float, Float, Float) -> @raylib.Rectangle` | Constructs a Rectangle from float x, y, width, height values |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `560` | Window width in pixels |
| `screen_h` | `Int` | `740` | Window height in pixels |
| `target_fps` | `Int` | `60` | Target frame rate |
| `grid_size` | `Int` | `4` | Number of rows and columns on the board |
| `cell_count` | `Int` | `16` | Total number of cells (grid_size squared) |
| `board_padding` | `Int` | `16` | Padding inside the board rectangle |
| `cell_gap` | `Int` | `12` | Gap between adjacent cells |
| `board_top` | `Int` | `200` | Y offset where the board begins |
| `board_left` | `Int` | `16` | X offset where the board begins |
| `board_size` | `Int` | `528` | Computed board width/height in pixels |
| `cell_size` | `Int` | `116` | Computed individual cell size in pixels |
| `anim_slide_speed` | `Float` | `12.0` | Lerp speed for tile sliding animations |
| `anim_pop_speed` | `Float` | `6.0` | Lerp speed for tile pop (spawn/merge) animations |
| `anim_pop_scale` | `Float` | `1.15` | Initial overshoot scale for merged tile pop effect |
| `bg_color` | `@raylib.Color` | `(250,248,239)` | Window background color (warm off-white) |
| `board_bg_color` | `@raylib.Color` | `(187,173,160)` | Board background color (brown-gray) |
| `cell_empty_color` | `@raylib.Color` | `(205,193,180)` | Empty cell placeholder color |
| `header_text_color` | `@raylib.Color` | `(119,110,101)` | Color for header and subtitle text |
| `score_bg_color` | `@raylib.Color` | `(187,173,160)` | Score box background color |
| `score_label_color` | `@raylib.Color` | `(238,228,218)` | Score label text color |
| `score_value_color` | `@raylib.Color` | `(255,255,255)` | Score value text color (white) |
| `btn_color` | `@raylib.Color` | `(143,122,102)` | Button background color |
| `btn_text_color` | `@raylib.Color` | `(249,246,242)` | Button text color (near-white) |

### Package `raylib_2048/internal/game`

> Game logic: input handling, tile movement/merging, spawning, undo, and animation updates.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(@types.Game, Float) -> Unit` | Public entry point called each frame; dispatches to `handle_input` then `update_animations` |

### Package `raylib_2048/internal/render`

> All drawing routines for the title screen, gameplay HUD, board, tiles, and state overlays.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(@types.Game) -> Unit` | Public entry point called each frame; clears the background and dispatches to the appropriate draw functions based on `GameState` |

## Architecture

### Package Structure

```
raylib_2048/
├── main.mbt              — Entry point: window init, game loop, delta time clamping
├── moon.pkg              — Package config with raylib and internal package imports
└── internal/
    ├── types/
    │   ├── types.mbt     — GameState enum, Tile struct, Game struct, constructors
    │   ├── constants.mbt — Screen dimensions, layout math, animation speeds, color palette
    │   └── utils.mbt     — Math helpers (clampf, absf, lerpf), coordinate converters, rectangle builders
    ├── game/
    │   ├── logic.mbt     — Core 2048 algorithm (try_move, spawn_tile, has_moves), undo, animation update
    │   └── input.mbt     — Per-state input handlers for keyboard and mouse
    └── render/
        └── render.mbt    — Drawing: title screen, header/score boxes, board/tiles, win/game-over overlays
```

The project follows a clean three-package internal architecture. The `types` package owns all data definitions and is imported by both `game` and `render`, ensuring a strict dependency direction. The `game` package never imports `render` and vice versa, enforcing separation of logic and presentation. The root package ties everything together in a minimal game loop.

### Data Flow

1. **Input phase**: `handle_input` (in `input.mbt`) checks the current `GameState` and dispatches to a state-specific handler (`handle_title_input`, `handle_play_input`, `handle_won_input`, `handle_over_input`). During play, directional key presses call `try_move(game, dr, dc)` which mutates the `Game` struct in place.

2. **Logic phase**: `try_move` saves the current board to `prev_values` for undo support, then performs the slide-and-merge algorithm column-by-column or row-by-row depending on the direction. It sets `anim_x`/`anim_y` to the tile's origin and `target_x`/`target_y` to the destination so the animation system can interpolate. After merging, it calls `spawn_tile` and checks for win/loss conditions.

3. **Animation phase**: `update_animations` iterates all 16 tiles, lerping `anim_x`/`anim_y` toward `target_x`/`target_y` at `anim_slide_speed`, and lerping `scale` back to 1.0 at `anim_pop_speed` for new and merged tiles. The `animating` flag blocks input until all animations complete.

4. **Render phase**: `draw_frame` clears the screen and branches on `GameState`. During play it calls `draw_header` (title text, score boxes, buttons) and `draw_board` (empty cell backgrounds, then each tile with its animated position, scale, color, and centered text). Win and Game Over states add semi-transparent overlays on top.

### Key Design Patterns

- **State machine**: The `GameState` enum (`Title`, `Play`, `Won`, `Over`) drives both input dispatch in `handle_input` and rendering dispatch in `draw_frame`, keeping state transitions explicit.
- **Flat array with index arithmetic**: The 4x4 board is stored as a 16-element `Array[Tile]` indexed by `row * grid_size + col`, avoiding nested array allocation.
- **Lerp-based animation**: Tiles store both current (`anim_x`, `anim_y`) and target positions. Each frame the current values are lerped toward the target at a speed proportional to delta time, producing smooth motion without a separate tweening library.
- **One-level undo**: `save_state` copies all 16 tile values and the current score into `prev_values` and `prev_score` before each move. `undo` restores them and snaps tile positions.
- **Delta time clamping**: The main loop clamps `dt` to a maximum of 0.05 seconds to prevent large jumps in animation after frame hitches.
- **ECS-like separation**: Types, game logic, and rendering are isolated in separate packages, enabling independent modification of any layer.

## Improvement & Refinement Plan

1. **Persistent high score storage**: The `best_score` field in `Game` resets when the application closes. Adding file-based persistence (e.g., writing to a JSON or text file) would let players retain their best scores across sessions.

2. **Multi-level undo**: Currently `save_state`/`undo` only store one previous board state in `prev_values`. Replacing this with a stack of snapshots would allow players to undo multiple moves, which is a common feature in modern 2048 implementations.

3. **Touch/swipe gesture support**: The input system in `handle_play_input` only handles discrete key presses and button clicks. Adding mouse drag detection with a distance threshold would enable swipe-style input, improving usability on touchscreen devices.

4. **Tile value-to-color lookup table**: `tile_color` in `utils.mbt` uses a match expression with hardcoded values up to 2048 and a catch-all. For tiles beyond 2048 (when `keep_playing` is true), a computed color gradient or extended lookup table would provide distinct visual feedback.

5. **Score popup animation**: When tiles merge, the merge score is silently added to `game.score`. A brief floating "+N" text near the merged tile would give satisfying visual feedback, leveraging the existing `msg`/`msg_t` pattern already used for the "Undo" message.

6. **Animation queueing for rapid input**: The `animating` flag in `handle_play_input` blocks all input until animations finish. Allowing input buffering (queuing the next move while the current animation plays) would make the game feel more responsive during fast play.

7. **Board size configuration**: Constants like `grid_size`, `board_size`, and `cell_size` in `constants.mbt` are all computed from fixed values. Parameterizing the grid size (e.g., 3x3, 5x5, 6x6 modes) would add replay variety with minimal logic changes since `try_move` already uses `grid_size` throughout.
