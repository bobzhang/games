# Gomoku Street Duel 2026

A classic Gomoku (Five-in-a-Row) board game played on a standard 15x15 grid against a heuristic AI opponent. The player places black stones and the AI plays white, with the first to form an unbroken line of five stones in any direction winning the round. The game features a wood-textured board with traditional star points, cursor-based navigation, and direct board clicking/tapping.

The AI uses a scoring heuristic that evaluates each empty cell by analyzing chain lengths and open ends in all four directions (horizontal, vertical, and both diagonals). It prioritizes winning moves, then blocking opponent wins, then maximizing offensive/defensive value with a slight defensive bias (110% weight on defense). A hint system lets the player request the AI's best suggestion for their own position, limited to 4 hints per round. Full move history with undo support allows rolling back the last human-AI move pair.

The game tracks wins, losses, and draws across rounds with alternating first-player advantage. The code is cleanly separated into types, game logic (with dedicated AI, input, and logic modules), and rendering packages.

## Build and Run

```bash
moon build --target native raylib_gomoku_street_duel_2026/
./_build/native/debug/build/raylib_gomoku_street_duel_2026/raylib_gomoku_street_duel_2026.exe
```

## Controls

- **W / Up Arrow**: Move cursor up
- **A / Left Arrow**: Move cursor left
- **S / Down Arrow**: Move cursor down
- **D / Right Arrow**: Move cursor right
- **Enter / Space**: Place stone at cursor position
- **H**: Request AI hint (limited to 4 per round)
- **U / Z**: Undo last move pair (human + AI)
- **C / Backspace**: Clear active hint
- **R**: Reset current round
- **N**: Next round (on result screen)
- **F11**: Toggle borderless windowed mode
- **Mouse click on board**: Place stone directly at clicked cell
- **Touch D-pad**: On-screen directional cursor control
- **Touch PLACE/HINT/UNDO/CLEAR/RESET buttons**: On-screen action buttons

## How to Play

1. **Place stones**: Move the cursor with WASD/arrows and press Enter/Space to place a black stone. Alternatively, click or tap directly on the board cell.

2. **Win condition**: Form a line of 5 or more consecutive stones horizontally, vertically, or diagonally before the AI does.

3. **AI turn**: After your move, the AI thinks for 0.26 seconds then places a white stone. The AI evaluates all cells near existing stones and picks the highest-scoring move.

4. **Use hints**: Press H to get the AI's recommendation for your best move (shown as a highlighted ring for 3 seconds). You get 4 hints per round.

5. **Undo moves**: Press U/Z to undo. If it's your turn, it undoes both the AI's last move and your preceding move. If waiting for AI, it undoes your last move.

6. **Round progression**: After a win, loss, or draw, press Enter/N to start a new round. First-move advantage alternates between human and AI each round.

### AI Scoring System

| Pattern | Score |
|---------|-------|
| 4+ in a line (any open ends) | 220,000 |
| 3 in a line, both ends open | 36,000 |
| 3 in a line, one end open | 7,600 |
| 2 in a line, both ends open | 2,100 |
| 2 in a line, one end open | 460 |
| 1 in a line, both ends open | 130 |
| 1 in a line, one end open | 48 |
| Baseline | 10 |

Center proximity bonus: up to +50 points, decreasing by 3 per Manhattan distance from center.

## Public API Reference

### Package `raylib_gomoku_street_duel_2026`

> Main entry point.

The `main` function initializes the window, creates a `Game` instance, reads input each frame, and delegates to `update_game` and `draw_frame`.

### Package `raylib_gomoku_street_duel_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1720` | Window width |
| `screen_h` | `Int` | `980` | Window height |
| `target_fps` | `Int` | `120` | Target frame rate |
| `board_n` | `Int` | `15` | Board dimension (15x15) |
| `max_cells` | `Int` | `225` | Total cells (board_n * board_n) |

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `Result` | Game state machine states |
| `Player` | `Empty`, `Human`, `AI` | Cell occupant or turn indicator |
| `Dir` | `DirNone`, `Left`, `Right`, `Up`, `Down` | Cursor movement direction |
| `SparkKind` | `SparkAI`, `SparkHuman`, `SparkUndo`, `SparkHint` | Particle effect type for color coding |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Spark` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | Visual particle effect with typed coloring |
| `Game` | `board`, `hist_x/y/p`, `hist_len`, `sparks`, `state`, `turn`, `winner`, `move_count`, `human_wins`, `ai_wins`, `draws`, `cursor_x/y`, `hints_left`, `hint_active/x/y/ttl`, `ai_delay`, `game_time`, `message` | Central game state containing board, history, stats, cursor, and UI state |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Game::new` | `() -> Game` | Creates a new game with empty board, spark pool (900), and default state |
| `mini` | `(Int, Int) -> Int` | Returns the smaller of two integers |
| `maxi` | `(Int, Int) -> Int` | Returns the larger of two integers |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between low and high bounds |
| `maxf` | `(Float, Float) -> Float` | Returns the larger of two floats |
| `absf` | `(Float) -> Float` | Returns absolute value of a float |
| `randf` | `(Float, Float) -> Float` | Random float in range using raylib RNG |
| `board_index` | `(Int, Int) -> Int` | Converts (x, y) to flat array index |
| `in_board` | `(Int, Int) -> Bool` | Checks if coordinates are within board bounds |
| `cell_at` | `(Game, Int, Int) -> Player` | Returns the cell occupant at given coordinates |
| `set_cell` | `(Game, Int, Int, Player) -> Unit` | Sets the cell occupant at given coordinates |
| `set_message` | `(Game, String, Float) -> Unit` | Sets the status message with a time-to-live |
| `clear_hint` | `(Game) -> Unit` | Deactivates the current hint display |
| `spawn_spark` | `(Game, Float, Float, Float, Float, Float, Float, SparkKind) -> Unit` | Activates the first inactive spark with given parameters |
| `board_metrics` | `(Game) -> (Int, Int, Int)` | Computes board draw origin (x, y) and tile size, with shake offset |
| `world_center` | `(Game, Int, Int) -> (Float, Float, Float)` | Returns pixel center of a board cell and tile size |
| `burst_move` | `(Game, Int, Int, Int, SparkKind) -> Unit` | Spawns a particle burst at a board cell position |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Point-in-rectangle hit test |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Checks if mouse or any touch point hits a rectangle |
| `panel_x` | `() -> Int` | Returns the X position of the side panel |
| `dpad_center_x` | `() -> Int` | Returns the center X of the on-screen D-pad |
| `dpad_center_y` | `() -> Int` | Returns the center Y of the on-screen D-pad |
| `dpad_size` | `() -> Int` | Returns the size of each D-pad button |
| `place_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the PLACE button |
| `hint_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the HINT button |
| `undo_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the UNDO button |
| `clear_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the CLEAR button |
| `reset_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the RESET button |
| `next_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the NEXT ROUND button |
| `start_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the START button |

### Package `raylib_gomoku_street_duel_2026/internal/game`

> Game logic, AI, and input handling.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main update entry: ticks timers, dispatches input, handles state transitions, runs AI |

Internal (non-pub) functions:

| Function | Description |
|----------|-------------|
| `has_neighbor` | Checks if any stone exists within radius `r` of a cell |
| `count_chain_and_open` | Counts consecutive same-player stones in one direction plus open-end flag |
| `line_pattern_score` | Maps (chain length, open ends) to a heuristic score value |
| `score_dir` | Evaluates one direction axis for a given player at a cell |
| `score_cell_for` | Total heuristic score for placing a stone at a cell (all 4 directions + center bonus) |
| `would_win_if_place` | Tests if placing at a cell would create five-in-a-row |
| `best_move_for` | Finds the highest-scoring legal move for a player, with randomized tie-breaking |
| `ai_step` | Executes the AI's turn if conditions are met (correct state, turn, and delay elapsed) |
| `use_hint` | Computes and displays the best move suggestion for the human player |
| `clear_board` | Resets all cells to Empty |
| `clear_history` | Resets move history |
| `clear_sparks` | Deactivates all spark particles |
| `push_history` | Records a move in the history stack |
| `pop_history` | Removes and returns the last move from history |
| `count_one_side` | Counts consecutive stones in one direction from a cell |
| `check_five_from` | Checks if a stone at (x,y) completes a five-in-a-row |
| `board_full` | Returns true if all cells are occupied |
| `place_stone` | Places a stone, checks for win/draw, switches turns |
| `undo_round_step` | Undoes a single move from history |
| `undo_last_turn` | Undoes the last human-AI move pair |
| `move_cursor_once` | Moves cursor one step in a direction |
| `update_cursor_hold` | Handles cursor auto-repeat when a direction key is held |
| `update_sparks` | Updates spark particle positions and lifetimes |
| `update_timers` | Ticks all game timers (ai_delay, message, shake, hint, etc.) |
| `reset_round` | Resets board and state for a new round |
| `detect_held_dir` | Reads current directional input from keyboard and touch D-pad |
| `detect_place_press` | Checks for stone placement input (Enter/Space or PLACE button) |
| `detect_hint_press` | Checks for hint input (H key or HINT button) |
| `detect_undo_press` | Checks for undo input (U/Z key or UNDO button) |
| `detect_clear_press` | Checks for clear hint input (C/Backspace or CLEAR button) |
| `detect_reset_press` | Checks for reset input (R key or RESET button) |
| `detect_start_press` | Checks for start input (Enter/Space or START button) |
| `detect_next_press` | Checks for next round input (Enter/Space/N or NEXT button) |
| `detect_board_tap` | Detects direct click/tap on a board cell, returns (hit, x, y) |

### Package `raylib_gomoku_street_duel_2026/internal/render`

> Rendering and visual effects.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main render entry: draws background, board, panel, overlays based on state |

Internal (non-pub) functions:

| Function | Description |
|----------|-------------|
| `draw_bg` | Renders animated dark background with pulsing circles and stripe bands |
| `draw_board_grid` | Draws the wooden board with grid lines and 9 star points |
| `draw_stone` | Renders a single stone (black for Human, white for AI) with highlight |
| `draw_hint` | Draws the hint indicator ring at the suggested cell |
| `draw_last_markers` | Draws small rings on the last human and AI moves |
| `draw_board` | Composites grid, stones, hint, markers, and cursor |
| `draw_button` | Generic button renderer with label, hover color, and outline |
| `draw_side_panel` | Renders the right panel with stats, controls legend, and action buttons |
| `draw_touch_overlay` | Draws the on-screen D-pad with active state highlighting |
| `draw_sparks` | Renders all active spark particles with kind-based coloring |
| `draw_title` | Draws the title screen with game name and start button |
| `draw_result_overlay` | Draws the end-of-round overlay with winner, move count, and next button |

## Architecture

### Package Structure

```
raylib_gomoku_street_duel_2026/
├── main.mbt                    — Entry point: window init, input polling, game loop
├── moon.pkg                    — Package config, imports
└── internal/
    ├── types/
    │   ├── types.mbt           — Game, Player, GameState, Spark enums and structs
    │   ├── constants.mbt       — Screen dimensions, board size, max cells
    │   └── utils.mbt           — Math utilities, board indexing, UI layout helpers
    ├── game/
    │   ├── ai.mbt              — Heuristic AI: scoring, best move, hint generation
    │   ├── game_update.mbt     — Main update dispatcher and timer management
    │   ├── input.mbt           — Input detection for keyboard and touch
    │   └── logic.mbt           — Board operations, move placement, undo, win check
    └── render/
        └── render.mbt          — All drawing: board, stones, panel, overlays, particles
```

### Data Flow

1. **Input**: `main.mbt` polls mouse/touch state each frame and stores it in `Game` fields. The `game` package reads this state through `detect_*` functions that unify keyboard and touch input.

2. **Update**: `update_game` ticks timers first, then dispatches based on `GameState`. During `Play`, it processes cursor movement, detects action presses (place, hint, undo, clear, reset), and runs `ai_step` if it's the AI's turn.

3. **AI**: `ai_step` calls `best_move_for` which iterates all empty cells near existing stones, scoring each for both offense and defense across 4 directions. Immediate wins score 1,000,000; blocking opponent wins score 760,000.

4. **Render**: `draw_frame` draws background, board grid with stones, side panel with stats and buttons, touch overlay, spark particles, and state-dependent overlays (title or result).

### Key Design Patterns

- **ECS-like separation**: Types, game logic, and rendering are in separate packages with clean interfaces. Only `update_game` and `draw_frame` are public.
- **Heuristic AI with pattern scoring**: The AI uses a lookup table mapping (chain_length, open_ends) to scores, making it easy to tune difficulty by adjusting the table values.
- **Move history stack**: `hist_x/y/p` arrays with `hist_len` implement a manual stack for full undo support without heap allocation.
- **Unified input detection**: Each action has a `detect_*` function that checks both keyboard and touch/mouse input, enabling seamless cross-platform play.
- **Auto-repeat cursor**: `update_cursor_hold` implements key repeat with an initial 0.2s delay and 0.095s repeat interval, matching standard keyboard behavior.

## Improvement & Refinement Plan

1. **Add difficulty levels**: The AI scoring table in `line_pattern_score` uses fixed values. Adding an easy/medium/hard setting that scales these values or limits search depth would let players of different skill levels enjoy the game.

2. **Implement winning line highlight**: When `check_five_from` detects a win, the five stones that form the line are not visually distinguished. Storing the winning line coordinates and highlighting them in the render pass would provide clearer feedback.

3. **Add opening book**: The first move is always center (`board_n / 2`). Adding a small opening book with common Gomoku openings (e.g., direct/indirect openings) would make the AI feel more varied.

4. **Optimize AI search range**: `best_move_for` checks `has_neighbor(game, x, y, 2)` for every empty cell, iterating the full board each time. Pre-computing a set of candidate cells incrementally after each move would reduce the O(n^4) worst case.

5. **Support human vs human mode**: The game only supports human vs AI. Adding a PvP mode would be straightforward since the core `place_stone` function already takes a `Player` parameter.

6. **Add animation to stone placement**: Stones appear instantly when placed. Adding a brief scale-up animation or a drop effect would make the game feel more polished and give the AI's moves a more noticeable visual cue.

7. **Persist win/loss stats**: `human_wins`, `ai_wins`, and `draws` reset when the program exits. Saving them to a file would provide long-term tracking.
