# neon_2048_storm_2026

A neon-themed twist on 2048 played on a 5x5 grid with storm mechanics that periodically spawn blocker tiles, a zap ability to clear cells, and an undo system.

## Build and Run

```bash
cd examples && moon build --target native neon_2048_storm_2026/
cd examples && ./_build/native/debug/build/neon_2048_storm_2026/neon_2048_storm_2026.exe
```

## Controls

- **Mouse / Touch**: Swipe or click directional buttons to slide tiles
- **Keyboard**: Arrow keys or WASD to slide tiles

## How to Play

- Slide numbered tiles in four directions to merge matching values
- Every few turns a "storm" spawns blocker tiles that cannot be merged
- Charge and use the zap ability to destroy individual cells
- Undo your last move if you make a mistake
- Reach the target tile value to win, or fill the board to lose
- Neon spark effects and screen shake add visual flair to merges

## Public API Reference

### Package `neon_2048_storm_2026`
> Main entry point.

`main.mbt` initialises the Raylib window and audio device, creates the `Game`
struct, then drives the game loop: each frame it calls `@game.update_game` for
simulation and `@render.draw_frame` for drawing, using `@types.clampf` to cap
the delta-time.

### Package `neon_2048_storm_2026/internal/types`
> Core type definitions, constants, and utility functions.

#### Structs
| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Game` | `board`, `score`, `zap_charge`, `turns_to_storm`, `shake_t`, `mouse_x/y` | Complete mutable runtime state for one game session |
| `Spark` | `active`, `x/y`, `vx/vy`, `life`, `size`, `kind` | Single pooled particle used for board visual effects |

#### Enums
| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `Result` | High-level phase of a Neon 2048 run |
| `Direction` | `DirLeft`, `DirRight`, `DirUp`, `DirDown` | Input direction for slide operations |
| `SparkKind` | `SparkDefault`, `SparkMerge`, `SparkExplosion` | Visual spark effect category |

#### Functions
| Function | Signature | Description |
|----------|-----------|-------------|
| `Spark::new` | `() -> Spark` | Creates an inactive spark for the particle pool |
| `Game::new` | `() -> Game` | Creates a new game in title state with initialised buffers |
| `mini` | `(Int, Int) -> Int` | Returns the smaller of two integers |
| `maxi` | `(Int, Int) -> Int` | Returns the larger of two integers |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer into `[lo, hi]` |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float into `[lo, hi]` |
| `maxf` | `(Float, Float) -> Float` | Returns the larger of two floats |
| `randf` | `(Float, Float) -> Float` | Returns a pseudo-random float in `[lo, hi]` |
| `idx` | `(Int, Int) -> Int` | Converts board coordinates to a flat row-major index |
| `in_board` | `(Int, Int) -> Bool` | Returns true when coordinates lie inside the grid |
| `board_metrics` | `(Game) -> (Int, Int, Int)` | Computes board origin and tile size with screen-shake offset |
| `cell_world_center` | `(Game, Int, Int) -> (Float, Float)` | Returns world-space centre of a board cell |
| `set_msg` | `(Game, String, Float) -> Unit` | Sets the transient HUD message and its lifetime |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Checks whether an active pointer is inside a rectangle |
| `pointer_cell` | `(Game, Float, Float) -> (Bool, Int, Int)` | Converts pointer position to a board cell coordinate |
| `charge_for_merge` | `(Int) -> Int` | Returns zap charge gained from merging a tile of value `v` |
| `bonus_for_chain` | `(Int) -> Int` | Returns bonus score for merge chains longer than one |
| `tile_rank` | `(Int) -> Int` | Maps a tile value to an integer progression rank |
| `rank_name` | `(Int) -> String` | Returns the display rank title for a computed rank |
| `final_grade` | `(Game) -> String` | Returns the final letter grade from max tile and score |

#### Constants (`constants.mbt`)
| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1720` | Width of the game window in pixels |
| `screen_h` | `Int` | `980` | Height of the game window in pixels |
| `target_fps` | `Int` | `120` | Target frame rate used by the main loop |
| `board_n` | `Int` | `5` | Number of rows and columns in the square board |
| `max_cells` | `Int` | `25` | Total number of cells in the board |
| `target_tile` | `Int` | `2048` | Winning tile value for a completed run |
| `blocker_value` | `Int` | `-1` | Sentinel value for a cell that contains storm debris |
| `panel_x0` | `Int` | `1060` | Left edge of the right-side control panel |
| `panel_w` | `Int` | `636` | Width of the right-side control panel |

Button layout helpers (`board_area_x/y/w/h`, `title_start_button`, `retry_button`, `btn_left/right/up/down/zap/undo/restart`) return `Int` or `(Int,Int,Int,Int)` rectangles for hit-testing.

### Package `neon_2048_storm_2026/internal/game`
> Game logic, input handling, and update systems.

#### Functions (`logic.mbt`)
| Function | Signature | Description |
|----------|-----------|-------------|
| `clear_effects` | `(Game) -> Unit` | Deactivates every spark in the particle pool |
| `spawn_spark` | `(Game, Float, Float, Float, Float, Float, Float, SparkKind) -> Unit` | Activates the first free spark slot |
| `burst` | `(Game, Float, Float, Int, SparkKind) -> Unit` | Emits `n` randomly scattered sparks at a position |
| `update_sparks` | `(Game, Float) -> Unit` | Advances all active sparks one frame |
| `clear_board` | `(Game) -> Unit` | Zeroes every board cell |
| `copy_board` | `(Array[Int], Array[Int]) -> Unit` | Copies one board buffer into another |
| `save_undo` | `(Game) -> Unit` | Snapshots the board and counters for a single undo |
| `restore_undo` | `(Game) -> Bool` | Restores the last saved undo snapshot |
| `line_index` | `(Int, Int, Direction) -> Int` | Maps a slide direction and position to a board index |
| `spawn_tile` | `(Game, SparkKind) -> Bool` | Places a new tile in a random empty cell |
| `spawn_blocker` | `(Game) -> Bool` | Places a storm debris blocker in a random empty cell |
| `start_match` | `(Game) -> Unit` | Resets all state and begins a new game |
| `board_has_move` | `(Game) -> Bool` | Returns true when at least one valid move or empty cell exists |
| `finish_win` | `(Game) -> Unit` | Transitions to the result screen as a win |
| `finish_lose` | `(Game) -> Unit` | Transitions to the result screen as a loss |
| `apply_post_turn` | `(Game) -> Unit` | Checks win/loss conditions after a move |
| `process_line` | `(Game, Int, Direction) -> (Bool, Int, Int, Int, Int)` | Slides and merges one row or column in a direction |
| `try_move` | `(Game, Direction) -> Bool` | Attempts a full board slide in a direction |
| `use_zap` | `(Game, Int, Int) -> Bool` | Consumes zap charge to destroy the cell at `(x,y)` |
| `update_play` | `(Game, Float) -> Unit` | Advances timers and sparks each frame |
| `update_game` | `(Game, Float) -> Unit` | **Public.** Advances one full frame of game simulation |

#### Functions (`input.mbt`)
| Function | Signature | Description |
|----------|-----------|-------------|
| `title_hover` | `(Game) -> Bool` | Returns true when the pointer is over the start button |
| `result_hover` | `(Game) -> Bool` | Returns true when the pointer is over the retry button |
| `update_title_input` | `(Game) -> Unit` | Handles start transitions on the title screen |
| `update_result_input` | `(Game) -> Unit` | Handles retry transitions on the result screen |
| `btn_pressed` | `(Game, (Int,Int,Int,Int)) -> Bool` | Checks whether a touch button is currently pressed |
| `handle_buttons` | `(Game) -> Bool` | Dispatches all on-screen button presses |
| `update_play_input` | `(Game, Float) -> Unit` | Processes keyboard, mouse, and touch input during play |

### Package `neon_2048_storm_2026/internal/render`
> Rendering and drawing routines.

#### Functions (`render.mbt`)
| Function | Signature | Description |
|----------|-----------|-------------|
| `bg_wave` | `(Game, Float) -> Float` | Returns a sine wave value driven by `ui_t` |
| `draw_bg` | `(Game) -> Unit` | Draws the dark neon background with animated circles and scan stripes |
| `tile_body_color` | `(Int) -> Color` | Maps a tile value to its fill colour |
| `tile_text_color` | `(Int) -> Color` | Maps a tile value to its label text colour |
| `draw_board_panel` | `(Game, Int, Int, Int) -> Unit` | Draws the board background panel with shake highlight |
| `draw_cell` | `(Game, Int, Int, Int, Int, Int) -> Unit` | Draws one cell including its blocker or tile appearance |
| `draw_grid` | `(Game, Int, Int, Int) -> Unit` | Draws all cells and grid lines |
| `draw_cursor` | `(Game, Int, Int, Int) -> Unit` | Draws the selection cursor highlight |
| `draw_sparks` | `(Game) -> Unit` | Draws all active spark particles |
| `draw_touch_button` | `(String, (Int,Int,Int,Int), Bool, Color) -> Unit` | Draws a labelled on-screen button |
| `draw_controls` | `(Game) -> Unit` | Draws the full set of on-screen touch buttons |
| `draw_panel` | `(Game) -> Unit` | Draws the right-side HUD panel with stats and controls legend |
| `draw_title` | `(Game) -> Unit` | Draws the title screen overlay |
| `draw_result_overlay` | `(Game) -> Unit` | Draws the win/loss result overlay |
| `draw_frame` | `(Game) -> Unit` | **Public.** Renders the complete frame for the current game state |

## Architecture

### Package Structure
```
neon_2048_storm_2026/
├── main.mbt          — Window init, audio init, game loop
└── internal/
    ├── types/
    │   ├── types.mbt      — GameState, Direction, SparkKind enums; Spark and Game structs with constructors
    │   ├── constants.mbt  — Window dimensions, board size, tile values, button rectangles
    │   └── utils.mbt      — Math helpers, board coordinate utilities, scoring helpers, grade/rank functions
    ├── game/
    │   ├── logic.mbt      — Board simulation: slide/merge, undo, storm spawner, zap, win/loss, particle logic
    │   └── input.mbt      — Keyboard, mouse, and touch input routing for all game states
    └── render/
        └── render.mbt     — All draw functions: background, board, cells, sparks, HUD panel, overlays
```

Data flows from top to bottom each frame:
1. `main` gathers frame time and passes it to `@game.update_game`.
2. `update_game` reads input (via `input.mbt`), then dispatches to
   state-specific update functions in `logic.mbt`.
3. `logic.mbt` mutates the shared `Game` struct in place.
4. `main` then calls `@render.draw_frame`, which reads the same `Game` struct
   to produce all draw calls.

Design patterns used:
- **Flat struct mutation**: all game state lives in one `Game` struct passed by
  reference; no message queues or event systems.
- **Pool allocation**: sparks are fixed-size arrays; `spawn_spark` finds the
  first inactive slot.
- **Segment-based merging**: `process_line` handles blocker cells by splitting
  each row/column into contiguous segments before compacting and merging.

## Improvement & Refinement Plan

1. **Animated tile movement**: interpolate tiles from their source cells to
   their destination cells over a few frames instead of snapping, giving the
   merge a polished feel.
2. **Per-tile merge flash**: briefly brighten or scale a tile when it is newly
   merged so the player can track which cells changed.
3. **Sound effects**: add short audio cues (merge chime, zap blast, storm
   rumble) using the already-initialised audio device.
4. **Persistent best score**: write `best_score` to a local file between
   sessions so it survives restarts.
5. **Variable storm timing**: scale `turns_to_storm` based on the current
   maximum tile or wave number so late-game pressure increases progressively.
6. **Touch swipe detection**: replace the directional button press with swipe
   gesture recognition for a more natural mobile experience.
7. **Accessibility colour mode**: add an alternative tile colour palette that
   does not rely on hue alone, making the board readable for colour-blind
   players.
