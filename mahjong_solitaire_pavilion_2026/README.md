# Mahjong Solitaire Pavilion 2026

A tile-matching solitaire game inspired by traditional mahjong solitaire, set in a Chinese pavilion theme with ten progressively challenging stages. Players clear boards by matching pairs of identical free tiles -- tiles that have at least one horizontal side unblocked. The game features a 10-level campaign with named stages like "Courtyard Warmup," "Dragon Corridor," and "Master Solitaire."

The core gameplay loop involves scanning the board for matching pairs of free tiles, selecting them to remove both from the board, and repeating until the board is clear. Each level introduces larger boards (from 10x6 up to 18x12), more tile kinds (12 to 30), and tighter time limits. Players have limited hints, shuffles, and undo credits per level. Matching builds a combo counter that increases score and adds bonus time. Board patterns vary from simple rectangles to circles, diamonds, butterfly wings, and cross shapes.

The game features a sophisticated board generation system that creates shaped layouts using mathematical patterns (circles, diamonds, cross shapes) and ensures solvability by shuffling until valid moves exist. The undo system stores full state snapshots allowing precise reversal of matches.

## Build and Run

```bash
moon build --target native mahjong_solitaire_pavilion_2026/
./_build/native/debug/build/mahjong_solitaire_pavilion_2026/mahjong_solitaire_pavilion_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Move cursor across the board (hold for auto-repeat)
- **Enter/Space**: Select tile at cursor position / confirm match
- **Mouse click**: Tap tile directly on the board
- **H**: Use hint (highlights a valid matching pair, limited per level)
- **J**: Shuffle remaining tiles (limited per level)
- **U/Z**: Undo last match (limited per level)
- **C/Backspace**: Clear current selection
- **R**: Reset current level
- **N**: Next level (on clear screen)
- **F11**: Toggle borderless windowed mode
- **Touch controls**: On-screen D-pad for cursor movement, and side panel buttons for SELECT, HINT, SHUFFLE, UNDO, RESET, CLEAR

## How to Play

Begin by pressing Enter/Space or tapping "Start Pavilion" on the title screen. Each level presents a board filled with paired tiles in a unique shape pattern.

A tile is **free** when at least one of its left or right sides is open (no adjacent active tile on that side). Select two free tiles with the same kind to remove them both. Build combos by matching consecutively -- each combo increases score bonus (+25 per combo level) and adds time (2.1s + 0.18s per combo). Mismatched selections or selecting blocked tiles reset the combo.

Each level has a time limit (120s to 220s). Matching adds a small time bonus, but if the timer reaches zero, the level fails. If no valid moves remain, the game auto-shuffles (consuming a shuffle credit if available); if no shuffle produces valid moves, the level fails.

**Resources per level** (decreasing with difficulty):
- **Hints** (2-4): Reveal one valid pair
- **Shuffles** (2-4): Rearrange remaining tiles to create new pairs
- **Undos** (1-3): Reverse the last match, restoring tiles and score

Complete all 10 levels to finish the pavilion campaign. Your final score and total play time are displayed.

## Public API Reference

### Package `mahjong_solitaire_pavilion_2026`

> Main entry point.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Initializes window, creates Game instance, runs main loop calling `update_game` and `draw_frame` |

### Package `mahjong_solitaire_pavilion_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `LevelClear`, `CampaignClear`, `Fail` | Game state machine states |
| `Dir` | `DirNone`, `Left`, `Right`, `Up`, `Down` | Cursor movement directions |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `UndoPair` | `valid`, `x1`, `y1`, `kind1`, `x2`, `y2`, `kind2`, `prev_score`, `prev_combo`, `prev_timer`, `prev_remaining` | Snapshot of a matched pair for undo restoration |
| `Spark` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | Visual particle effect for tile matches and events |
| `Game` | `active`, `cells`, `undo`, `sparks`, `state`, `level_index`, `board_w`, `board_h`, `kind_count`, `score`, `combo`, `timer`, `time_limit`, `remaining`, `hints_left`, `shuffles_left`, `undos_left`, `cursor_x`, `cursor_y`, `select_active`, `select_x`, `select_y`, `hint_active`, etc. | Main game state container with board data, scoring, resources, and UI state |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1720` | Screen width in pixels |
| `screen_h` | `Int` | `980` | Screen height in pixels |
| `target_fps` | `Int` | `120` | Target frame rate |
| `max_cols` | `Int` | `18` | Maximum board columns |
| `max_rows` | `Int` | `12` | Maximum board rows |
| `max_cells` | `Int` | `216` | Maximum total cells (max_cols * max_rows) |
| `max_undos` | `Int` | `256` | Maximum undo history depth |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Game::new` | `() -> Game` | Creates a new Game with default state, allocates arrays for cells, undo, and sparks |
| `mini` | `(Int, Int) -> Int` | Returns the minimum of two integers |
| `maxi` | `(Int, Int) -> Int` | Returns the maximum of two integers |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between low and high bounds |
| `maxf` | `(Float, Float) -> Float` | Returns the maximum of two floats |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `randf` | `(Float, Float) -> Float` | Generates a random float in the given range |
| `idx` | `(Int, Int) -> Int` | Converts 1-based (x, y) board coordinates to a flat array index |
| `in_board` | `(Game, Int, Int) -> Bool` | Checks if coordinates are within the current board dimensions |
| `active_at` | `(Game, Int, Int) -> Bool` | Checks if a board position is active (part of the layout) |
| `cell_at` | `(Game, Int, Int) -> Int` | Returns the tile kind at a position (0 if empty or inactive) |
| `set_cell` | `(Game, Int, Int, Int) -> Unit` | Sets the tile kind at a board position |
| `clear_board` | `(Game) -> Unit` | Resets all cells and active flags |
| `clear_undo` | `(Game) -> Unit` | Resets the undo history |
| `clear_sparks` | `(Game) -> Unit` | Deactivates all spark particles |
| `clear_selection` | `(Game) -> Unit` | Clears the current tile selection |
| `clear_hint` | `(Game) -> Unit` | Clears the active hint highlight |
| `board_metrics` | `(Game) -> (Int, Int, Int)` | Computes board rendering position and tile size: (board_x, board_y, tile_size) |
| `world_center` | `(Game, Int, Int) -> (Float, Float, Float)` | Returns the pixel center and tile size for a board cell |
| `spawn_spark` | `(Game, Float, Float, Float, Float, Float, Float, Int) -> Unit` | Creates a visual spark particle at a position |
| `burst_tile` | `(Game, Int, Int, Int, Int) -> Unit` | Creates a burst of sparks centered on a board tile |
| `update_sparks` | `(Game, Float) -> Unit` | Updates all active spark positions, velocities, and lifetimes |
| `shuffle_ints` | `(Array[Int]) -> Unit` | Fisher-Yates shuffle of an integer array |
| `active_count` | `(Game) -> Int` | Counts how many board positions are currently active |
| `free_tile` | `(Game, Int, Int) -> Bool` | Checks if a tile is free (at least one horizontal side open) |
| `configure_level` | `(Int) -> (Int, Int, Int, Float, Int, Int, Int, Int, String)` | Returns level config: (width, height, kinds, time_limit, hints, shuffles, undos, pattern, name) |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside a rectangle |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Tests if mouse or any touch point is inside a rectangle |
| `panel_x` | `() -> Int` | Returns the X position of the side panel |
| `dpad_center_x` | `() -> Int` | Returns the center X of the touch D-pad |
| `dpad_center_y` | `() -> Int` | Returns the center Y of the touch D-pad |
| `dpad_size` | `() -> Int` | Returns the size of each D-pad button |
| `select_button_rect` | `() -> (Int, Int, Int, Int)` | Returns the rectangle for the Select button |
| `hint_button_rect` | `() -> (Int, Int, Int, Int)` | Returns the rectangle for the Hint button |
| `shuffle_button_rect` | `() -> (Int, Int, Int, Int)` | Returns the rectangle for the Shuffle button |
| `undo_button_rect` | `() -> (Int, Int, Int, Int)` | Returns the rectangle for the Undo button |
| `reset_button_rect` | `() -> (Int, Int, Int, Int)` | Returns the rectangle for the Reset button |
| `clear_button_rect` | `() -> (Int, Int, Int, Int)` | Returns the rectangle for the Clear button |
| `next_button_rect` | `() -> (Int, Int, Int, Int)` | Returns the rectangle for the Next/Retry button |
| `start_button_rect` | `() -> (Int, Int, Int, Int)` | Returns the rectangle for the Start button |

### Package `mahjong_solitaire_pavilion_2026/internal/game`

> Game logic, input detection, and update systems.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main update function: reads input, updates timers, handles state transitions and player actions |

### Package `mahjong_solitaire_pavilion_2026/internal/render`

> Rendering and drawing routines.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main rendering entry point: draws background, board, side panel, touch overlay, sparks, and state overlays |

## Architecture

### Package Structure

```
mahjong_solitaire_pavilion_2026/
├── main.mbt                      — Entry point: window init, game loop
├── moon.pkg                      — Root package config
└── internal/
    ├── types/
    │   ├── types.mbt             — GameState, Dir enums; UndoPair, Spark, Game structs; Game::new
    │   ├── constants.mbt         — Screen dimensions, board limits, pool sizes
    │   └── utils.mbt             — Math helpers, board queries, spark management, level config, UI rects
    ├── game/
    │   ├── logic.mbt             — Board generation, matching, undo, shuffle, level loading, state machine
    │   └── input.mbt             — Input detection for keyboard, mouse, and touch
    └── render/
        └── render.mbt            — Board drawing, side panel, touch overlay, state overlays
```

### Data Flow

1. **Initialization**: `main` creates a `Game` via `Game::new()`, allocating flat arrays for board cells, undo history, and spark particles.
2. **Input**: `update_game` reads mouse/touch state into the `Game` struct. Input detection functions (`detect_held_dir`, `detect_select_press`, etc.) check both keyboard and touch/mouse against UI button rectangles.
3. **Game logic**: `update_game` dispatches based on `GameState`. During `Play`, it processes cursor movement with auto-repeat, tile selection via `pick_tile`, hint/shuffle/undo actions, board tap detection, and timer countdown. `on_match` handles pair removal, scoring, combo tracking, undo recording, and level completion checks. `ensure_moves` auto-shuffles when no valid pairs remain.
4. **Level generation**: `load_level` calls `configure_level` for parameters, `set_pattern_active` to create the board shape using mathematical formulas, `fill_board_with_pairs` to populate tiles, and validates solvability with up to 24 shuffle attempts.
5. **Rendering**: `draw_frame` dispatches by state. The board draws tiles with kind-based colors and suit/rank labels. Free tiles have bright borders while blocked tiles are dimmed. Selected and hinted tiles have highlighted outlines. The side panel shows stats, resources, keyboard help, and action buttons.

### Key Design Patterns

- **ECS-like separation**: Types, game logic, and rendering are cleanly separated into distinct packages with unidirectional dependencies.
- **Pattern-based board generation**: `set_pattern_active` uses 10 mathematical patterns (rectangles, circles, diamonds, crosses, butterfly wings, sine waves, stairs, rings) to create varied board shapes.
- **Free tile validation**: `free_tile` checks horizontal adjacency -- a tile is free if either its left or right neighbor is empty/inactive, making it a 2D simplification of traditional 3D mahjong solitaire stacking.
- **Guaranteed solvability**: After filling the board with paired tiles, the game attempts to find valid moves and reshuffles (up to 24 times) until at least one exists.
- **Undo with full state snapshot**: Each `UndoPair` stores the matched tiles' positions and kinds plus the previous score, combo, timer, and remaining count for precise restoration.
- **Touch and keyboard parity**: Every action has both a keyboard shortcut and a touch button, detected through `pointer_on_rect` which checks both mouse and touch points.

## Improvement & Refinement Plan

1. **Add tile highlighting for matching kinds**: When a tile is selected, highlighting all other free tiles of the same kind across the board would help players spot matches faster, especially on larger boards where `kind_count` reaches 30.

2. **Implement difficulty-adaptive time bonuses**: The time bonus per match (2.1s + 0.18s per combo) is fixed across all levels. Scaling it inversely with level difficulty in `on_match` would better balance later levels that have 120+ tiles but only marginally more time.

3. **Add visual distinction for tile kinds**: Currently `color_for_kind` uses a formula `70 + kind * 37 % 168` that can produce visually similar colors for different kinds. Using a curated palette or adding pattern/icon variations would improve tile distinguishability.

4. **Support level select**: The campaign is strictly sequential via `next_level`. Adding a level select screen that tracks best scores per level would allow replaying favorite boards and improve replayability.

5. **Improve the shuffle validation loop**: `reshuffle` tries up to 32 shuffles to find one with valid moves. For boards with few remaining tiles and high `kind_count`, this could theoretically fail. Tracking which shuffles were tried and using a more systematic approach would be more robust.

6. **Add animation for tile removal**: Tiles disappear instantly when matched via `set_cell(game, x, y, 0)`. Adding a brief fade-out or slide animation in the render pass (checking a removal timer) would make matches feel more satisfying.

7. **Consolidate button rect functions**: The 8 separate `*_button_rect()` functions in utils.mbt each return `(Int, Int, Int, Int)`. A single function taking a button ID enum would reduce code duplication.
