# Minesweeper Neon Ops 2026

A cyberpunk-themed minesweeper game set in a neon-lit urban grid, featuring a 24x14 board with 58 mines. Unlike classic minesweeper, this version introduces a lives system (3 lives), combo-based scoring, limited hint charges, and performance grading from S-rank "Neon Oracle" down to D-rank "Rookie". The dark neon art style features glowing cells, particle spark effects, and animated background waves.

The core gameplay loop combines traditional minesweeper deduction with action-game mechanics. Players reveal cells to build combos that decay over time, earning bonus points for sustained chains. Hitting a mine costs a life rather than ending the game immediately, allowing recovery from mistakes. Three hint charges let players safely reveal a random unrevealed cell at a score penalty of 60 points. The game supports both keyboard navigation (WASD/Arrows with cursor) and mouse/touch input, with a full on-screen button panel for mobile play.

The architecture cleanly separates concerns across four packages: types for data definitions and utilities, game for logic and input handling, render for all drawing routines, and main for the game loop. A spark particle system provides visual feedback for reveals, flags, and mine explosions with three distinct particle colors.

## Build and Run

```bash
moon build --target native raylib_minesweeper_neon_ops_2026/
./_build/native/debug/build/raylib_minesweeper_neon_ops_2026/raylib_minesweeper_neon_ops_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Move cursor on the board
- **Enter or Space**: Reveal cell (in Reveal mode) or toggle flag (in Flag mode)
- **F**: Toggle flag on cell at cursor position
- **M**: Switch between Reveal and Flag mode
- **H**: Use hint (reveals a random safe cell, costs 60 score)
- **R**: Restart the current match
- **Escape**: Return to title screen
- **Left Click**: Click board cells directly or interact with touch buttons
- **Right Click**: Toggle flag on clicked cell
- **Touch buttons (on-screen)**: MODE, HINT, RESTART, REVEAL/FLAG CELL

## How to Play

Start from the title screen by pressing Enter, Space, or clicking the "Start Operation" button. Navigate the 24x14 grid and reveal safe cells. The first reveal is always safe -- mines are placed after your initial click with a 3x3 exclusion zone.

Revealed cells show colored numbers (1-8) indicating adjacent mine count, or expand via flood-fill if no adjacent mines exist. Build combos by revealing cells in quick succession; combos decay over time (1 per 0.55 seconds) and multiply score bonuses. Scoring: base points per reveal are 18 for empty cells or 12 + (adjacent_count * 8) for numbered cells, plus combo * 5 bonus.

You have 3 lives. Hitting a mine costs one life and triggers a screen shake and explosion particles but does not end the game. Losing all lives ends the operation. You also have 3 hints that safely reveal a random unrevealed non-mine cell at a 60-point score penalty.

Upon completion (win or loss), your performance is graded S through D based on score, time, mistakes, and remaining lives. Time bonuses: under 130s = +380, under 200s = +250, under 280s = +120. Each remaining life adds 170 points; each mistake subtracts 220. Grade thresholds: S (7000+), A (5200+), B (3600+), C (2200+), D (below).

## Public API Reference

### Package `raylib_minesweeper_neon_ops_2026`

> Main entry point: initializes window with MSAA, audio, and runs the game loop.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Entry point: creates window (1720x980), initializes audio, runs update/draw loop at 120 FPS |

### Package `raylib_minesweeper_neon_ops_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `Result` | Game state machine states |
| `PlayMode` | `Reveal`, `Flag` | Current interaction mode for cell actions |
| `Grade` | `GradeS`, `GradeA`, `GradeB`, `GradeC`, `GradeD` | Performance grade levels |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Cell` | `mine`, `revealed`, `flagged`, `exploded`, `around` | Single board cell with mine/reveal/flag/explosion state and adjacency count |
| `Spark` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | Particle effect with position, velocity, lifetime, and type (0=reveal, 1=flag, 2=mine) |
| `Game` | `cells`, `sparks`, `state`, `mode`, `lives`, `hints`, `score`, `combo`, `grade`, `win` | Main game state container holding board, particles, scoring, and UI state |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1720` | Window width in pixels |
| `screen_h` | `Int` | `980` | Window height in pixels |
| `target_fps` | `Int` | `120` | Target frame rate |
| `board_w` | `Int` | `24` | Board width in cells |
| `board_h` | `Int` | `14` | Board height in cells |
| `max_cells` | `Int` | `board_w * board_h` | Total number of cells on the board |
| `mine_count_default` | `Int` | `58` | Default number of mines |
| `lives_default` | `Int` | `3` | Starting lives |
| `hints_default` | `Int` | `3` | Starting hint charges |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Cell::new` | `() -> Cell` | Creates a default cell (no mine, unrevealed, unflagged) |
| `Spark::new` | `() -> Spark` | Creates an inactive spark particle |
| `Game::new` | `() -> Game` | Creates a new game with default state, pre-allocated cells and 1400 spark pool |
| `panel_x` | `() -> Int` | Returns the X pixel position of the side info panel (1168) |
| `board_area_x` | `() -> Int` | Returns board drawing area left offset (44) |
| `board_area_y` | `() -> Int` | Returns board drawing area top offset (32) |
| `board_area_w` | `() -> Int` | Returns board drawing area width |
| `board_area_h` | `() -> Int` | Returns board drawing area height |
| `title_start_button` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) rectangle for the title screen start button |
| `result_retry_button` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) rectangle for the result screen retry button |
| `touch_mode_button` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) rectangle for the touch mode toggle button |
| `touch_hint_button` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) rectangle for the touch hint button |
| `touch_reset_button` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) rectangle for the touch reset button |
| `touch_reveal_button` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) rectangle for the touch reveal/flag action button |
| `mini` | `(Int, Int) -> Int` | Returns the minimum of two integers |
| `maxi` | `(Int, Int) -> Int` | Returns the maximum of two integers |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer to [lo, hi] range |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to [lo, hi] range |
| `maxf` | `(Float, Float) -> Float` | Returns the maximum of two floats |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `randf` | `(Float, Float) -> Float` | Returns a random float in [lo, hi] range |
| `in_board` | `(Int, Int) -> Bool` | Checks whether (x, y) is within board boundaries |
| `idx` | `(Int, Int) -> Int` | Converts (x, y) board coordinates to flat array index |
| `board_metrics` | `(Game) -> (Int, Int, Int)` | Computes (x0, y0, tile_size) for board rendering, including screen shake offset |
| `set_msg` | `(Game, String, Float) -> Unit` | Sets the UI message text with a display duration in seconds |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Tests if pointer (mouse/touch) position is inside a rectangle |
| `safe_cells_total` | `(Game) -> Int` | Returns total number of non-mine cells |
| `flags_left` | `(Game) -> Int` | Returns remaining flag count (mines minus flags placed) |
| `unrevealed_safe_cells` | `(Game) -> Int` | Returns count of safe cells not yet revealed |
| `clear_ratio_pct` | `(Game) -> Int` | Returns percentage (0-100) of safe cells revealed |
| `compute_grade` | `(Int, Int, Int, Int) -> Grade` | Computes performance grade from score, time, mistakes, and lives |
| `grade_name` | `(Grade) -> String` | Returns single-letter grade name ("S", "A", "B", "C", "D") |
| `grade_title` | `(Grade) -> String` | Returns grade title ("Neon Oracle", "City Detective", "Field Agent", "Cadet", "Rookie") |

### Package `raylib_minesweeper_neon_ops_2026/internal/game`

> Game logic, input handling, and state management.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(@types.Game, Float) -> Unit` | Main update dispatcher: reads mouse/touch state and delegates to state-specific handlers |

### Package `raylib_minesweeper_neon_ops_2026/internal/render`

> All rendering routines including background, board, particles, UI panels, and overlays.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(@types.Game) -> Unit` | Main rendering entry point: draws background, board, sparks, panel, touch UI, and result overlay |

## Architecture

### Package Structure

```
raylib_minesweeper_neon_ops_2026/
├── main.mbt              — Entry point: window init, audio init, game loop
├── moon.pkg              — Package config, imports all internal packages
└── internal/
    ├── types/
    │   ├── types.mbt     — Core structs (Cell, Spark, Game) and enums (GameState, PlayMode, Grade)
    │   ├── constants.mbt — Board dimensions, UI layout constants, button rectangles
    │   └── utils.mbt     — Math utilities, board helpers, grading logic
    ├── game/
    │   ├── logic.mbt     — Mine placement, flood fill, reveal/flag logic, combo/score, spark effects
    │   └── input.mbt     — Keyboard, mouse, and touch input handling per state
    └── render/
        └── render.mbt    — Background waves, board/cell drawing, particle rendering, info panel, overlays
```

### Data Flow

1. **Input Gathering**: `update_game` reads mouse position, touch count, and hold state into `Game` fields every frame. It then dispatches to `update_title_input`, `update_play_input`, or `update_result_input` based on `game.state`.
2. **Play Input**: `handle_keyboard` processes WASD/arrow movement, M (mode toggle), F (flag), H (hint), Enter/Space (action). Mouse clicks are mapped to board cells via `click_to_cell` using `board_metrics`. Touch buttons are checked via `handle_touch_buttons` using `pointer_on_rect`.
3. **Game Logic**: `reveal_cell` handles first-move mine placement via `place_mines`, then either calls `flood_reveal` (BFS queue for zero-adjacent cells) or `reveal_single`. Each safe reveal calls `award_combo` and computes score via `score_for_reveal`. Mine hits decrement lives and call `reset_combo`. `check_clear` tests for win condition.
4. **Particle System**: `spawn_spark` finds an inactive slot in the pre-allocated 1400-spark pool. `burst` emits N sparks with randomized velocity/lifetime. `update_sparks` applies velocity, drag, gravity, and lifetime decay each frame.
5. **Rendering**: `draw_frame` calls `draw_bg` (animated wave circles), `draw_board_back`, `draw_cells` (per-cell hidden/revealed drawing), `draw_cursor`, `draw_sparks`, `draw_panel` (score/lives/combo/controls info), `draw_touch_ui` (on-screen buttons), and `draw_result_overlay` on game end.

### Key Design Patterns

- **Object pool for particles**: The `sparks` array is pre-allocated with 1400 `Spark` objects, reused via `active` flag scanning in `spawn_spark`, avoiding runtime allocation.
- **BFS flood fill**: Unlike the classic recursive approach, `flood_reveal` uses pre-allocated `queue_x`/`queue_y` arrays as a BFS queue, preventing stack overflow on large empty regions.
- **State machine**: `GameState` enum (`Title`, `Play`, `Result`) drives both update and render branching.
- **Dual input mode**: `PlayMode` enum (`Reveal`, `Flag`) changes the behavior of the primary action key/button, supporting both keyboard and touch workflows.
- **Performance grading**: `compute_grade` combines score, time bonuses, remaining lives, and mistake penalties into a single metric mapped to S-D grades with thematic titles.
- **Screen shake**: `shake_t` timer adds random pixel offsets to `board_metrics` output when a mine is hit, providing visceral feedback.
- **Touch-friendly UI**: Dedicated on-screen button rectangles defined in constants with `pointer_on_rect` hit testing, separate from keyboard controls.

## Improvement & Refinement Plan

1. **Add difficulty levels**: The board is hardcoded at 24x14 with 58 mines. Adding selectable difficulty presets (easy/medium/hard) by parameterizing `board_w`, `board_h`, and `mine_count_default` in `constants.mbt` would increase replayability.
2. **Combo timer visualization**: The `combo_t` decay is tracked but not visually displayed. Adding a countdown bar near the combo display in `draw_panel` would help players understand and maintain their chains.
3. **Persist best scores**: `best_score` resets each session since it lives on `Game`. Writing it to a file and loading on startup would give the scoring system more meaning.
4. **Separate spark kinds into typed enum**: The `Spark.kind` field uses raw integers (0, 1, 2) for reveal/flag/explosion colors. A `SparkKind` enum would improve clarity in both `spawn_spark` and `draw_sparks`.
5. **Extract button layout into a reusable system**: `draw_touch_button` and the button rectangle functions in `constants.mbt` are repetitive. A `Button` struct with position, label, and callback would reduce code duplication in `handle_touch_buttons` and `draw_touch_ui`.
6. **Add chord reveal**: Clicking a revealed numbered cell with the correct number of adjacent flags should auto-reveal remaining neighbors. This standard minesweeper feature is missing from `do_action_on_cell`.
7. **Reduce parameter threading**: Many internal functions pass `@types.Game` as the sole argument but also accept coordinates separately. Grouping cursor/action state into method calls on `Game` could simplify signatures like `reveal_single`, `toggle_flag`, and `cell_world_center`.
