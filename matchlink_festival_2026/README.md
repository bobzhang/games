# MatchLink Festival 2026

A Lianliankan (connect-matching-tiles) puzzle game with a 10-level campaign. Players match pairs of identical tiles by finding connecting paths that use at most two right-angle turns through empty cells. The game features escalating board sizes from 8x6 to 16x12, a countdown timer with time bonuses on matches, combo scoring, hint and shuffle power-ups, and full keyboard, mouse, and touch input support.

The core mechanic is path finding: two tiles of the same kind can be linked only if a path exists between them consisting of horizontal and vertical line segments with at most two bends, passing only through empty cells (or the tiles themselves). The path-finding algorithm checks direct lines, single-turn L-shapes, and two-turn Z/S-shapes by iterating over all possible intermediate anchor points along the source tile's row and column. Successfully matched pairs are removed, the combo counter increments, time is added, and sparks burst from the cleared cells. If no valid moves remain, the board auto-shuffles. Each level has a time limit, limited hints, and limited shuffles.

## Build and Run

```bash
moon build --target native matchlink_festival_2026/
./_build/native/debug/build/matchlink_festival_2026/matchlink_festival_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Move cursor (hold to auto-repeat)
- **Enter / Space**: Select tile at cursor / confirm swap
- **H**: Use hint (highlights a valid pair)
- **J**: Shuffle remaining tiles
- **C / Backspace**: Clear current selection
- **R**: Reset current level
- **N**: Next level (on level clear)
- **Mouse click**: Tap tile directly on the board
- **Touch D-pad**: On-screen directional buttons (lower-left)
- **Touch buttons**: On-screen SELECT, HINT, SHUFFLE, CLEAR, RESET buttons (side panel)
- **F11**: Toggle borderless windowed mode

## How to Play

The game starts on a title screen. Press Enter/Space or tap "Start Festival" to begin the 10-level campaign.

**Matching tiles**: Select a tile by moving the cursor to it and pressing Enter/Space (or clicking/tapping it). Then select a second tile of the same kind. If a valid path exists between them (straight line, one-turn L-shape, or two-turn Z/S-shape through empty cells), both tiles are removed, you earn score, and the combo counter increases. If no valid path exists, the selection switches to the second tile and the combo resets.

**Scoring**: Each match awards `90 + combo * 20 + kind * 4` points. Consecutive successful matches build the combo counter. Each match also adds `2.2 + combo * 0.18` seconds to the timer (capped at the level's time limit).

**Power-ups**: Each level provides a limited number of hints and shuffles. Hints highlight a valid pair on the board. Shuffles rearrange all remaining tiles while ensuring at least one valid move exists.

**Auto-shuffle**: If no valid moves exist after a match, the game automatically shuffles (consuming a shuffle ticket if available, or forcing a free shuffle). If shuffling cannot produce a valid board, the level fails.

**Level progression**: Clear all tiles before the timer runs out to advance. The 10 levels progress from "Harbor Warmup" (8x6, 8 tile kinds, 118s) to "Master Lantern Grid" (16x12, 26 tile kinds, 210s). Completing all 10 levels shows a campaign summary with total score and play time.

## Public API Reference

### Package `matchlink_festival_2026`

> Main entry point.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Initializes window at 1720x980 at 120 FPS, creates Game, runs main loop with dt-capped updates and F11 toggle |

### Package `matchlink_festival_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `LevelClear`, `CampaignClear`, `Fail` | Game state machine states |
| `Direction` | `DirNone`, `Left`, `Right`, `Up`, `Down` | Cardinal direction for cursor movement and D-pad |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `LinkPath` | `found`, `points`, `x0`-`y0` through `x3`-`y3` | A connecting path between two tiles with up to 4 waypoints (2 turns max) |
| `Spark` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | A particle spark for match burst effects |
| `Game` | `cells`, `sparks`, `state`, `level_index`, `level_count`, `board_w`, `board_h`, `kind_count`, `score`, `combo`, `timer`, `time_limit`, `remaining`, `hints_left`, `shuffles_left`, `cursor_x`, `cursor_y`, `select_active`, `select_x`, `select_y`, `path_active`, `path_ttl`, `path_points`, `path_x0`-`path_y3`, `hint_active`, `hint_ttl`, `hint_x0`-`hint_y1`, `hold_dir`, `repeat_t`, `touch_action_cd`, `message`, `message_t`, `shake_t`, `ui_t`, `mouse_x`, `mouse_y`, `mouse_hold`, `mouse_press`, `touch_count` | Main game state containing board, particles, level info, economy, selection, path flash, hint flash, input state, and UI timers |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1720` | Screen width |
| `screen_h` | `Int` | `980` | Screen height |
| `target_fps` | `Int` | `120` | Target frame rate |
| `max_cols` | `Int` | `16` | Maximum board columns |
| `max_rows` | `Int` | `12` | Maximum board rows |
| `max_cells` | `Int` | `192` | Maximum cell count (max_cols * max_rows) |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `empty_path` | `() -> LinkPath` | Creates an empty (not found) link path |
| `Game::new` | `() -> Game` | Creates a new Game with 1200 pre-allocated sparks, 10-level campaign, and Title state |
| `mini` | `(Int, Int) -> Int` | Returns the minimum of two integers |
| `maxi` | `(Int, Int) -> Int` | Returns the maximum of two integers |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between lo and hi bounds |
| `maxf` | `(Float, Float) -> Float` | Returns the maximum of two floats |
| `randf` | `(Float, Float) -> Float` | Returns a random float in [lo, hi] range using raylib's random |
| `cell_index` | `(Int, Int) -> Int` | Converts 1-based (x, y) board coordinates to flat array index |
| `in_board` | `(Game, Int, Int) -> Bool` | Checks whether (x, y) is within the current board bounds (1-based) |
| `cell_at` | `(Game, Int, Int) -> Int` | Returns the tile kind at (x, y), or 0 if out of bounds |
| `set_cell` | `(Game, Int, Int, Int) -> Unit` | Sets the tile kind at (x, y) if within bounds |
| `clear_board` | `(Game) -> Unit` | Sets all cells to 0 |
| `clear_sparks` | `(Game) -> Unit` | Deactivates all spark particles |
| `clear_path_flash` | `(Game) -> Unit` | Clears the path flash animation state |
| `clear_hint_flash` | `(Game) -> Unit` | Clears the hint highlight animation state |
| `board_metrics` | `(Game) -> (Int, Int, Int)` | Computes board drawing origin (x, y) and tile size, clamped between 36-84 pixels, with screen shake offset |
| `world_center` | `(Game, Int, Int) -> (Float, Float, Float)` | Returns pixel center (cx, cy) and tile size for a board cell |
| `world_center_ext` | `(Game, Int, Int) -> (Float, Float)` | Returns pixel center (cx, cy) for a board cell (without tile size) |
| `spawn_spark` | `(Game, Float, Float, Float, Float, Float, Float, Int) -> Unit` | Activates the first inactive spark with position, velocity, life, size, and kind |
| `burst_cell` | `(Game, Int, Int, Int, Int) -> Unit` | Spawns multiple sparks around a board cell for match/fail effects |
| `update_sparks` | `(Game, Float) -> Unit` | Updates all active sparks: applies velocity, drag (1.9x), gravity (36.0), and decrements life |
| `shuffle_ints` | `(Array[Int]) -> Unit` | Fisher-Yates shuffles an integer array in place using raylib random |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Point-in-rectangle test for UI hit detection |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Checks if mouse or any touch point is inside a rectangle |
| `panel_x` | `() -> Int` | Returns the X position of the side panel (screen_w - 420) |
| `dpad_center_x` | `() -> Int` | Returns the X center of the on-screen D-pad (162) |
| `dpad_center_y` | `() -> Int` | Returns the Y center of the on-screen D-pad (screen_h - 184) |
| `dpad_size` | `() -> Int` | Returns the size of each D-pad button (78) |
| `select_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the SELECT touch button |
| `hint_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the HINT touch button |
| `shuffle_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the SHUFFLE touch button |
| `clear_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the CLEAR touch button |
| `reset_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the RESET touch button |
| `next_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the NEXT STAGE touch button |
| `start_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the title START touch button |
| `path_point` | `(LinkPath, Int) -> (Int, Int)` | Returns the (x, y) of a waypoint in a LinkPath by index (0-3) |
| `path_point_flash` | `(Game, Int) -> (Int, Int)` | Returns the (x, y) of a waypoint in the game's active path flash by index (0-3) |
| `clear_selection` | `(Game) -> Unit` | Deactivates the tile selection state |

### Package `matchlink_festival_2026/internal/game`

> Game logic: input detection, path finding, board management, level progression, and state updates.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main update: reads mouse/touch input, updates timers, dispatches to state-specific handlers (Title, Play, LevelClear, CampaignClear, Fail) |

### Package `matchlink_festival_2026/internal/render`

> Rendering and drawing routines.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main rendering entry point: draws background, board with tiles and overlays, side panel with stats and buttons, touch D-pad, sparks, and state-specific overlays (title, level clear, campaign clear, fail) |

## Architecture

### Package Structure

```
matchlink_festival_2026/
├── main.mbt                      — Entry point: window init, game loop
├── moon.pkg                      — Root package config
└── internal/
    ├── types/
    │   ├── types.mbt             — GameState/Direction enums, LinkPath/Spark/Game structs, constructors
    │   ├── constants.mbt         — Screen dimensions, grid maximums
    │   └── utils.mbt             — Math helpers, board accessors, spark management, UI rect functions, path point accessors
    ├── game/
    │   ├── input.mbt             — Input detection: D-pad direction, button presses, board tap mapping
    │   ├── logic.mbt             — Path finding, board building, shuffle, match handling, level loading, state machine
    │   └── levels.mbt            — 10-level configuration (board size, kind count, time limit, hints, shuffles, name)
    └── render/
        └── render.mbt            — Board drawing, side panel, touch overlay, title, level clear, fail, campaign overlays
```

### Data Flow

1. **Initialization**: `main` creates a `Game` via `Game::new()` with a pre-allocated cells array (192 elements for max 16x12) and 1200 pre-allocated spark particles. The game starts in `Title` state.
2. **Input**: `update_game` reads mouse position, mouse button state, and touch point count into the Game struct each frame. State-specific input detection functions check keyboard keys, mouse clicks on UI buttons, and touch taps on the board and D-pad.
3. **Level Loading**: `load_level` calls `configure_level` to get board dimensions, tile kinds, time limit, hints, and shuffles for the level. `build_level_board` generates paired tiles (each kind appears an even number of times) and shuffles them. The board is verified to have at least one valid move, reshuffling up to 28 times if needed.
4. **Path Finding**: `find_link_path` checks if two tiles of the same kind can be connected. It first tries direct lines and single-turn paths via `direct_or_one_turn_from_anchor`. If those fail, it iterates over all horizontal and vertical anchor points from the source tile, checking if a two-segment path from the anchor to the destination exists. Paths are represented as `LinkPath` with up to 4 waypoints.
5. **Match Processing**: When a valid pair is found, `on_pair_matched` removes both tiles, increments combo, awards score, adds time, triggers spark bursts at both cells, and checks if the board is cleared (level complete) or needs auto-shuffling.
6. **Rendering**: `draw_frame` draws a layered scene: animated background stripes, the board with colored numbered tiles and grid lines, cursor and selection highlights, path flash lines, hint highlights, the side panel with stats/buttons/help text, touch D-pad overlay, sparks, and state-specific overlays.

### Key Design Patterns

- **Lianliankan path algorithm**: The path-finding uses a systematic approach: try direct line, try single-turn (two possible L-shapes), then iterate all anchor points for two-turn paths. This covers all possible connections with at most 2 bends.
- **1-based board coordinates**: Board cells use 1-based (x, y) coordinates, with 0 reserved for out-of-bounds. The `cell_index` function maps to a 0-based flat array. This simplifies boundary checks for path finding since paths can extend one cell beyond the board edges.
- **Object pool for particles**: 1200 `Spark` structs are pre-allocated. `spawn_spark` finds the first inactive spark and reuses it, avoiding allocation during gameplay.
- **Auto-shuffle safety net**: `ensure_move_exists` is called after every match. If no valid moves remain, it attempts a ticket-based shuffle, then a free forced shuffle, and only fails the level if no valid arrangement is possible.
- **Touch-first UI design**: All gameplay actions have both keyboard shortcuts and on-screen touch buttons. The D-pad, SELECT, HINT, SHUFFLE, CLEAR, and RESET buttons are always rendered and support mouse and multi-touch input via `pointer_on_rect`.
- **Combo time bonus**: Each match extends the timer by `2.2 + combo * 0.18` seconds, rewarding fast consecutive matches and creating a risk/reward dynamic between speed and accuracy.
- **Level configuration table**: `configure_level` returns a 7-tuple for each level, cleanly separating level design data from game logic. Board sizes scale from 48 tiles (8x6) to 192 tiles (16x12).
- **Screen shake**: The `shake_t` timer adds random offsets to the board drawing origin via `board_metrics`, providing tactile feedback on shuffles and failures.

## Improvement & Refinement Plan

1. **Add tile removal animation**: Currently matched tiles disappear instantly. Adding a brief shrink, fade, or slide animation would make the matching feel more satisfying and help players track what happened.

2. **Implement path drawing animation**: The path flash appears and disappears in 0.23 seconds as static lines. Animating the path as a traveling spark or sequential segment reveal would make the connection more visually interesting.

3. **Add difficulty curve within levels**: All tiles on a level board are placed randomly. Introducing structured patterns (like border-first placement or clusters) could create more interesting strategic situations.

4. **Implement score persistence**: The game does not save high scores or campaign progress. Adding local storage for best scores per level and fastest campaign completion would provide replay motivation.

5. **Add visual tile variety**: Tiles are currently rendered as colored rectangles with number labels. Using distinct symbols, patterns, or icon designs per tile kind would improve readability at a glance, especially on larger boards with 20+ tile kinds.

6. **Implement undo functionality**: There is no way to undo a match. While matches cannot be reversed, adding an undo for the last selection (before the second tile is picked) would reduce frustration from accidental taps.

7. **Add audio feedback**: The game has no sound. Adding match sounds (with combo pitch scaling), shuffle effects, timer warning tones, and level completion fanfares would significantly enhance the experience.
