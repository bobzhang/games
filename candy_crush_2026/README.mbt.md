# Candy Crush 2026

A match-3 puzzle game with special candies, jelly clearing objectives, and progressive difficulty across levels.

## Build and Run

```bash
moon build --target native candy_crush_2026/
./_build/native/debug/build/candy_crush_2026/candy_crush_2026.exe
```

## Controls

- **Arrow Keys / Mouse**: Select and swap candies
- **Mouse Click**: Select a candy, then click an adjacent candy to swap
- **F11**: Toggle borderless windowed
- Touch input supported

## How to Play

Swap adjacent candies on an 8x8 board to form matches of 3 or more in a row or column. Matching 4 or 5 creates special candies with powerful effects. Each level has a limited number of moves and a jelly-clearing objective -- clear all jelly tiles to advance. Chain reactions from cascading matches build combos for bonus points. Hints appear automatically if no move is made.

## Public API Reference

### Package `candy_crush_2026/internal/types`
> Defines all shared types, board constants, layout geometry, scoring, and stateless utility functions. Both `game` and `render` packages depend solely on this package.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `LevelClear`, `GameOver` | High-level phase of a candy crush session. |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Game` | `kinds`, `specials`, `jelly`, `flash`, `marks`, `spawn_special`, `state`, `level`, `score`, `best_score`, `chain_best`, `moves_left`, `jelly_left`, `selected`, `sel_x/y`, `cursor_x/y`, `hint_active`, `hint_x0/y0/x1/y1`, `hint_t`, `message`, `message_t`, `touch_mode`, `touch_cd`, `swap_flash_t`, `swap_x0/y0/x1/y1`, `mouse_x/y`, `mouse_press`, `touch_count` | Full mutable game state including flat board arrays, UI animation timers, input fields, and match hint tracking. |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Game::new` | `() -> Game` | Constructs a new game in `Title` state with zeroed board arrays and default counters. |
| `idx` | `(Int, Int) -> Int` | Converts board column and row to a flat row-major array index. |
| `in_board` | `(Int, Int) -> Bool` | Returns true when `(x, y)` is within `[0, board_cols) x [0, board_rows)`. |
| `is_adjacent` | `(Int, Int, Int, Int) -> Bool` | Returns true when two cells share exactly one edge (`|dx|+|dy|==1`). |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer to `[lo, hi]`. |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to `[lo, hi]`. |
| `absi` | `(Int) -> Int` | Returns the absolute value of an integer. |
| `maxf` | `(Float, Float) -> Float` | Returns the larger of two floats. |
| `swapi` | `(Array[Int], Int, Int) -> Unit` | Swaps two elements of an integer array in place. |
| `score_for_removed` | `(Int, Int) -> Int` | Computes score for `cleared` cells at combo depth `chain`: `cleared * (42 + chain * 18)`. |
| `candy_color` | `(Int) -> @raylib.Color` | Maps a candy kind index (0-5) to its display colour (red, orange, yellow, green, blue, purple). |
| `tint` | `(@raylib.Color, Int) -> @raylib.Color` | Shifts all RGB channels of a colour by a delta while preserving alpha. Used for highlight and shadow variants. |
| `board_pixel_w/h` | `() -> Int` | Board pixel dimensions: `board_cols * cell_px` and `board_rows * cell_px`. |
| `board_x/y` | `() -> Int` | Pixel origin of the board, centred in the area left of the side panel. |
| `panel_x/y` | `() -> Int` | Pixel origin of the right-side UI panel. |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests whether a float point lies inside an axis-aligned integer rectangle. |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Returns true if a mouse press or any active touch point hits the rectangle. |
| `pointer_to_cell` | `(Float, Float, Bool, Int) -> (Bool, Int, Int)` | Converts a mouse press or touch point to a board cell coordinate. Returns `(false, 0, 0)` if no hit. |
| `start_button_rect` | `() -> (Int, Int, Int, Int)` | Rectangle for the Start button on the title overlay. |
| `hint_button_rect` | `() -> (Int, Int, Int, Int)` | Rectangle for the Hint button in the side panel. |
| `shuffle_button_rect` | `() -> (Int, Int, Int, Int)` | Rectangle for the Shuffle button in the side panel. |
| `restart_button_rect` | `() -> (Int, Int, Int, Int)` | Rectangle for the Restart button in the side panel. |
| `result_button_rect` | `() -> (Int, Int, Int, Int)` | Rectangle for the action button on level-clear and game-over overlays. |

#### Constants

| Constant | Type | Description |
|----------|------|-------------|
| `screen_w` | `Int` | Window width: 1420 px. |
| `screen_h` | `Int` | Window height: 900 px. |
| `target_fps` | `Int` | Target frame rate: 120 fps. |
| `board_cols` | `Int` | Board columns: 8. |
| `board_rows` | `Int` | Board rows: 8. |
| `board_cells` | `Int` | Total cells: 64 (`board_cols * board_rows`). |
| `candy_kinds` | `Int` | Number of regular candy colours: 6. |
| `cell_px` | `Int` | Pixel size of one cell: 84 px. |
| `board_pad` | `Int` | Padding around board visual frame: 18 px. |
| `ui_panel_w` | `Int` | Right side panel width: 360 px. |
| `moves_base` | `Int` | Move budget for level 1: 28. |
| `moves_level_bonus` | `Int` | Extra moves per level: 2. |
| `base_jelly` | `Int` | Jelly target for level 1: 16 cells. |
| `jelly_level_bonus` | `Int` | Extra jelly cells per level: 3. |
| `special_none` | `Int` | No special effect: 0. |
| `special_row` | `Int` | Row-clearing special: 1. |
| `special_col` | `Int` | Column-clearing special: 2. |
| `special_bomb` | `Int` | 3x3 bomb special: 3. |
| `hint_ttl_max` | `Float` | Hint highlight duration: 2.2 s. |
| `message_ttl_max` | `Float` | HUD message display duration: 2.4 s. |
| `touch_action_cooldown` | `Float` | Minimum delay between touch actions: 0.1 s. |

### Package `candy_crush_2026/internal/game`
> All board logic: level setup, match scanning, special candy expansion, cascading removal and refill, swap validation, shuffle, hint search, and per-state input dispatch. Exports `update_game`.

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(@types.Game, Float) -> Unit` | Main per-frame entry point. Ticks all timers (flash, hint, message, touch cooldown, swap flash), then dispatches to state-specific input handlers. |

### Package `candy_crush_2026/internal/render`
> Stateless rendering layer. Reads only from `@types.Game` and issues raylib draw calls. Exports `draw_frame`.

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(@types.Game) -> Unit` | Renders a full frame: gradient background with decorative circles, board frame, board cells with candy circles and jelly/flash overlays, selection/hint/swap highlights, side panel with stats and buttons, HUD message, and state-specific overlays. |

## Architecture

### Package Structure

```
candy_crush_2026/
├── main.mbt          — window init, F11 borderless toggle, input polling into Game fields, game loop
└── internal/
    ├── types/        — Game/GameState, all constants, board geometry, color helpers, pointer utilities
    ├── game/         — match scanning, cascade logic, board fill/shuffle, swap/select, input dispatch
    └── render/       — stateless raylib draw calls reading from Game
```

### Data Flow

`main.mbt` owns the single `Game` value. Each frame it reads raw raylib input (mouse position, mouse pressed, touch count) directly into `game.mouse_x/y`, `game.mouse_press`, and `game.touch_count`, then calls `@game.update_game(game, dt)`. The `game` package contains three state-specific input handlers (`update_title_input`, `update_play_input`, `update_result_input`) that are dispatched from `update_game` via a `match` on `game.state`. These handlers read the normalised input fields, then call the appropriate high-level actions such as `restart_run`, `select_or_swap`, `use_hint`, or `try_manual_shuffle`.

Board state is stored as six flat `Array[Int]` or `Array[Float]` parallel arrays indexed by `idx(x, y)`. A swap attempt copies `kinds`, performs the swap, tests for any match with `has_any_match`, and reverts if none exists. A valid swap decrements `moves_left`, triggers `run_cascade`, which iterates: scan and mark all horizontal and vertical runs of 3+, expand marks through any special candy chain reactions, remove marked cells (decrementing `jelly_left` where applicable and placing spawned specials in-place), then collapse and refill each column bottom-up with newly random candies. This repeats until no new matches are found, accumulating combo chain depth for scoring.

After every swap the logic checks `jelly_left <= 0` (level clear), `moves_left <= 0` (game over), and whether any valid swap remains. If the board has no possible swap, `shuffle_board` is called up to 160 times to find a permutation with no immediate matches but at least one possible swap. The render package reads the resulting `Game` fields directly -- including `flash` values for white flash overlays, `hint_active` / `hint_x0/y0/x1/y1` for the pulsing hint arrows, and `swap_flash_t` for the swap confirmation highlight.

### Key Design Patterns

- **Parallel flat arrays**: The board is represented as six separate fixed-length arrays (`kinds`, `specials`, `jelly`, `flash`, `marks`, `spawn_special`) rather than a single array of cell objects. This avoids allocation, keeps each concern separate, and makes bulk operations (zero-filling, copying) explicit.
- **Speculative swap testing**: `would_swap_match` temporarily swaps two elements, tests for a match, and swaps back. Both the player swap validation and the `has_possible_swap` scan reuse this pattern, so there is one canonical match-check path.
- **Iterative special expansion**: `expand_special_marks` runs a fixpoint loop that re-scans all marked cells with special types and marks their affected neighbours, repeating until no new cells are added. This naturally handles chain reactions (e.g., a row-clear triggering a column-clear).
- **Separation of input and logic**: Input handlers only mutate high-level action fields or call named logic functions. Game logic never queries raylib directly; all platform input has already been normalised into `game.mouse_*` and `game.touch_count` by `main.mbt`.
- **Stateless render package**: `draw_frame` and all its helpers are pure functions from `Game` to raylib side-effects. Animation state (flash, hint pulse) is driven by timer fields stored in `Game`, so no render state is maintained between frames.

## Improvement & Refinement Plan

1. **Animated candy drop and swap**: Candies currently appear instantly after collapse and refill. Adding interpolated pixel offsets stored in separate animation arrays (one per cell) would make the match resolution visually readable and more satisfying.
2. **Persistent best score across sessions**: `best_score` lives in `Game` and resets when the process exits. Writing it to a platform file or save slot would give players a meaningful session-spanning target.
3. **Difficulty scaling beyond move count and jelly target**: As levels increase, moves grow by only 2 per level and jelly by 3. Introducing additional axes -- such as a minimum chain requirement for bonus moves, or locked cells that must be hit twice -- would keep higher levels engaging without solely increasing target size.
4. **Special candy visual distinction**: The three specials (row, column, bomb) are drawn with small geometric overlays (horizontal bar, vertical bar, circle). Adding colour-coded glow rings or particle effects that activate when a special is triggered would make it immediately clear which chain effect is firing.
5. **Undo last swap**: Storing the previous board state in a snapshot array and exposing an undo action (e.g., key Z) would lower the frustration of accidental swaps and is a standard quality-of-life feature in the genre.
6. **Sound effects**: There are no audio calls. Match sounds scaled by chain depth, a distinct tone for special candy creation, and a jelly-clear chime would make the cascade feedback loop substantially more rewarding.
7. **Board obstacle cells**: Introducing immovable obstacle cells (rocks, caged candies) that block matches or require multiple hits to remove would create level-design variety and give the jelly target more structural meaning.
