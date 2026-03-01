# Picross Harbor 2026

Picross Harbor 2026 is a nonogram puzzle game set in a maritime harbor theme. Players work through a 12-level campaign of handcrafted grid puzzles -- from the 8x8 "Lighthouse Watch" to the 12x12 "Storm Port" -- using numeric row and column clues to deduce which cells should be filled and which should be marked empty, gradually revealing hidden pixel-art images of harbor objects.

The core gameplay loop is pure logic deduction: read the clue numbers along each row and column (which describe consecutive groups of filled cells), fill cells you are certain about, cross out cells that must be empty, and work through intersections to solve the board. The game tracks mistakes against a per-level limit, awards 1-3 stars based on time, mistakes, and hint usage, and accumulates campaign statistics across all levels.

The game supports both keyboard and touch/mouse input with an on-screen D-pad and action buttons, a full undo stack (up to 8192 steps), a hint system that auto-fills or auto-crosses the first solvable cell, and particle spark effects on cell actions. Board dimensions and tile sizes adapt dynamically based on puzzle size through the `board_metrics` layout calculator.

## Build and Run

```bash
moon build --target native raylib_picross_harbor_2026/
./_build/native/debug/build/raylib_picross_harbor_2026/raylib_picross_harbor_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move cursor on the grid (hold for auto-repeat)
- **Space / F**: Fill the cell at the cursor (toggle: fill or unfill)
- **X / C**: Cross out the cell at the cursor (toggle: cross or uncross)
- **Tab / T**: Toggle between Fill and Mark tool modes
- **Z / Backspace**: Undo last action
- **H**: Use a hint (reveals one correct cell; limited per level)
- **R**: Reset the current level
- **N / Enter / Space**: Advance to next level (on clear/fail screens)
- **Mouse click**: Click directly on grid cells, on-screen D-pad, or action buttons (Fill, Mark, Undo, Hint, Reset)
- **Touch**: Tap grid cells or on-screen controls
- **F11**: Toggle borderless windowed mode

## How to Play

Press Enter or Space on the title screen to start the campaign at Level 1 ("Lighthouse Watch", an 8x8 grid). Each puzzle presents a grid with numeric clues along the left side (row clues) and top (column clues). Each number represents a consecutive group of filled cells in that row or column. Multiple numbers mean multiple groups separated by at least one empty cell.

Use arrow keys or WASD to move the cursor, then press Space/F to fill a cell or X/C to mark it as empty (crossed). Filling a cell that should be empty or crossing a cell that should be filled counts as a mistake. Each level has a mistake limit (7-14 depending on difficulty); exceeding it fails the level. You can undo any action with Z or Backspace, which fully restores the previous state including mistake count.

Each level provides 2-3 hints that auto-solve one cell. Hints prioritize filling an unfilled solution cell, then crossing a wrongly-filled cell, then crossing an unknown non-solution cell.

Stars are awarded per level: 3 stars for completing under par time with no mistakes and no hints, losing one star for each of: exceeding par time, having any mistakes, or using any hints (minimum 1 star). The campaign tracks total stars, completion count, total time, and total mistakes across all 12 levels.

The 12 levels progress in size and difficulty: Lighthouse Watch (8x8), Tugboat Shift (9x9), Anchor Draft (10x10), Crane Hook (10x10), Cargo Crate (10x10), Wave Beacon (11x11), Harbor Bridge (12x10), Seagull Pass (12x10), Submarine Echo (12x12), Shipyard Gear (12x12), Fleet Signal (12x12), and Storm Port (12x12).

## Public API Reference

### Package `raylib_picross_harbor_2026`

> Main entry point. Initializes the window, creates the game state, and runs the main loop.

No additional public types or functions beyond the `main` entry point.

### Package `raylib_picross_harbor_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `UndoStep` | `valid`, `x`, `y`, `prev_state`, `prev_mistakes`, `prev_filled_correct`, `prev_filled_wrong`, `prev_hints_left`, `prev_hints_used` | Snapshot of a single cell change for undo restoration |
| `Spark` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | Particle effect with position, velocity, lifetime, and visual type |
| `Game` | `solution`, `cells`, `row_clues`, `col_clues`, `state`, `level_index`, `cursor_x`, `cursor_y`, `tool_mode`, `mistakes`, `hints_left`, `total_stars` | Main game state containing puzzle data, player progress, and UI state |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Game::new` | `() -> Game` | Creates a new game instance with pre-allocated arrays for solution, cells, undo stack (8192), and sparks (900) |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | 1720 | Window width in pixels |
| `screen_h` | `Int` | 980 | Window height in pixels |
| `target_fps` | `Int` | 120 | Target frame rate |
| `max_board` | `Int` | 12 | Maximum grid dimension (rows or columns) |
| `max_cells` | `Int` | 144 | Maximum total cells (max_board * max_board) |
| `cell_unknown` | `Int` | 0 | Cell state: not yet determined |
| `cell_fill` | `Int` | 1 | Cell state: filled by player |
| `cell_cross` | `Int` | 2 | Cell state: marked as empty |
| `state_title` | `Int` | 0 | Title screen state |
| `state_play` | `Int` | 1 | Active puzzle-solving state |
| `state_level_clear` | `Int` | 2 | Level completed successfully |
| `state_campaign_clear` | `Int` | 3 | All 12 levels completed |
| `state_level_fail` | `Int` | 4 | Mistake limit exceeded |
| `tool_fill` | `Int` | 1 | Fill tool mode |
| `tool_cross` | `Int` | 2 | Cross/mark tool mode |
| `dir_none` | `Int` | 0 | No direction held |
| `dir_left` | `Int` | 1 | Left direction |
| `dir_right` | `Int` | 2 | Right direction |
| `dir_up` | `Int` | 3 | Up direction |
| `dir_down` | `Int` | 4 | Down direction |

#### Utility Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `mini` | `(Int, Int) -> Int` | Returns the minimum of two integers |
| `maxi` | `(Int, Int) -> Int` | Returns the maximum of two integers |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer to a [lo, hi] range |
| `maxf` | `(Float, Float) -> Float` | Returns the maximum of two floats |
| `randf` | `(Float, Float) -> Float` | Returns a random float in [lo, hi] using raylib RNG |
| `board_index` | `(Int, Int) -> Int` | Converts (x, y) coordinates to a flat array index |
| `in_grid` | `(Game, Int, Int) -> Bool` | Checks if (x, y) is within the current puzzle grid bounds |
| `solution_at` | `(Game, Int, Int) -> Bool` | Returns whether the solution cell at (x, y) should be filled |
| `cell_at` | `(Game, Int, Int) -> Int` | Returns the current player cell state at (x, y) |
| `set_solution` | `(Game, Int, Int, Bool) -> Unit` | Sets the solution value at (x, y) |
| `set_cell` | `(Game, Int, Int, Int) -> Unit` | Sets the player cell state at (x, y) |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Point-in-rectangle test for UI hit detection |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Checks if mouse or any touch point is inside a rectangle |
| `dpad_center_x` | `() -> Int` | Returns the X center of the on-screen D-pad (164) |
| `dpad_center_y` | `() -> Int` | Returns the Y center of the on-screen D-pad |
| `dpad_size` | `() -> Int` | Returns the D-pad button size (78) |
| `right_panel_x` | `() -> Int` | Returns the X position of the right side panel |
| `action_w` | `() -> Int` | Returns the width of action buttons (170) |
| `action_h` | `() -> Int` | Returns the height of action buttons (72) |
| `fill_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the Fill button |
| `cross_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the Mark/Cross button |
| `undo_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the Undo button |
| `hint_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the Hint button |
| `reset_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the Reset button |
| `next_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the Next/Retry button |
| `start_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the Start Campaign button |
| `row_solved` | `(Game, Int) -> Bool` | Checks if all cells in a row match the solution |
| `col_solved` | `(Game, Int) -> Bool` | Checks if all cells in a column match the solution |
| `puzzle_solved` | `(Game) -> Bool` | Checks if the entire puzzle is solved (all correct fills, no wrong fills) |
| `max_row_clues` | `(Game) -> Int` | Returns the maximum number of clue segments across all rows |
| `max_col_clues` | `(Game) -> Int` | Returns the maximum number of clue segments across all columns |
| `board_metrics` | `(Game) -> (Int, Int, Int, Int, Int, Int, Int)` | Computes layout metrics: board_x, board_y, tile size, clue margins, origin. Includes shake offset |
| `world_for_cell` | `(Game, Int, Int) -> (Float, Float, Float)` | Returns the pixel center (x, y) and tile size for a grid cell |

### Package `raylib_picross_harbor_2026/internal/game`

> Game logic, level management, input handling, and state transitions.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(@types.Game, Float) -> Unit` | Main per-frame update: samples mouse/touch, updates timers, dispatches input to the active game state |

### Package `raylib_picross_harbor_2026/internal/render`

> Rendering for board, side panel, overlays, and touch controls.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(@types.Game) -> Unit` | Main rendering entry point: draws background, board with clues, side panel, touch controls, and state overlays |

## Architecture

### Package Structure

```
raylib_picross_harbor_2026/
├── main.mbt              — Entry point: window init, game loop
├── moon.pkg              — Package config with imports
└── internal/
    ├── types/
    │   ├── types.mbt     — UndoStep, Spark, Game structs and constructor
    │   ├── constants.mbt — State IDs, cell types, directions, screen dimensions
    │   └── utils.mbt     — Math helpers, grid utilities, UI rect definitions, solve-checking
    ├── game/
    │   ├── logic.mbt     — Level loading (12 puzzles), cell actions, undo, hints, clue computation, sparks
    │   └── input.mbt     — Keyboard/mouse/touch input detection for all actions and D-pad
    └── render/
        └── render.mbt    — Board drawing, clue rendering, side panel, touch D-pad, state overlays
```

The `types` package is unusually rich, containing not just data structures but also grid query functions (`solution_at`, `cell_at`, `row_solved`) and UI layout helpers (`board_metrics`, button rects). The `game` package handles all state mutation including the 12 hardcoded puzzle definitions, undo stack management, and spark particle updates. The `render` package reads game state to draw the board, clue numbers, cursor, particles, side panel with stats, and context-dependent overlays.

### Data Flow

1. **Input**: `detect_*` functions in `input.mbt` check keyboard presses, mouse clicks, and touch positions against UI rects. Results are used directly in `update_game` rather than buffered into an input struct.
2. **Update**: `update_game` in `logic.mbt` first updates frame timers and spark physics via `update_frame_timers`, then dispatches based on state. In play state, it processes cursor hold for auto-repeat via `update_cursor_hold`, then checks for tool toggle, undo, hint, board tap, fill, and cross actions with cooldown gating via `touch_action_cd`.
3. **Cell mutation**: `apply_cell_state` is the central function that modifies a cell, pushes an undo step, tracks correct/wrong fill counts, detects mistakes, spawns spark particles, and checks for puzzle completion or failure.
4. **Render**: `draw_frame` draws background, board (cells, clues, cursor, sparks), side panel (stats, buttons, keyboard legend), and state-specific overlays (level clear with stars, level fail, campaign clear).

### Key Design Patterns

- **Object pool pattern**: Sparks (900 pre-allocated) and undo steps (8192 pre-allocated) use arrays with active flags and length counters, avoiding runtime allocation.
- **State machine**: Five integer states (title, play, level_clear, campaign_clear, level_fail) drive update and render logic through if-else chains.
- **Full undo with state snapshots**: Each `UndoStep` captures the previous cell state plus all counters (mistakes, fills, hints), enabling perfect rollback including from failure state.
- **Adaptive board layout**: `board_metrics` dynamically computes tile size and origin based on grid dimensions and clue counts, clamping tile size between 24 and 68 pixels, centering the board in the available area.
- **Multi-input support**: Every interactive element checks keyboard, mouse position with click flag, and all touch points, making the game playable on touch devices without code duplication.
- **Cooldown-gated actions**: `touch_action_cd` prevents rapid double-firing of touch/click inputs on buttons.
- **Hardcoded level data**: All 12 puzzles are defined as literal 2D arrays in `load_level`, with clues auto-computed by `compute_all_clues`.

## Improvement & Refinement Plan

1. **Use enums for game state and cell state**: The game state (`state_title`, `state_play`, etc.) and cell state (`cell_unknown`, `cell_fill`, `cell_cross`) are integer constants. Converting them to proper enums would enable exhaustive match checking and prevent invalid state values.

2. **Extract level data into a separate data module**: All 12 puzzle definitions are hardcoded inside `load_level` in `logic.mbt`, making the function over 200 lines long. Moving puzzle data to a dedicated `internal/levels/` package with a structured level registry would improve readability and make adding puzzles easier.

3. **Reduce the size of the UndoStep struct**: Each `UndoStep` stores the full game counters (mistakes, filled_correct, filled_wrong, hints_left, hints_used). Since these can be recomputed from the cell array, a more compact undo that only stores cell position and previous state would reduce memory usage for the 8192-element pool.

4. **Add auto-cross for completed rows/columns**: When `row_solved` or `col_solved` returns true, the game could automatically cross remaining unknown cells in that line, reducing tedious end-game clicks. The `row_solved` and `col_solved` functions in `utils.mbt` already exist and could trigger this.

5. **Consolidate UI rect definitions**: The six `*_button_rect` functions in `utils.mbt` each compute positions independently. Centralizing button layout into a single function or struct that computes all positions relative to the panel origin would make layout changes easier.

6. **Add keyboard shortcut for tool-specific actions**: Currently, Space/F always uses the fill tool and X/C always uses the cross tool (in `detect_fill_press` and `detect_cross_press`), but the tool_mode toggle via Tab exists independently. The two input modes are somewhat redundant and could be unified or the tool toggle could be removed since direct fill/cross keys already exist.

7. **Add a puzzle preview on level select**: The title screen jumps directly into level 1 with no level selection. Adding a level select screen showing solved/unsolved status and star counts for each of the 12 puzzles would improve the campaign experience, using the already-tracked `total_completed` and `total_stars` fields.
