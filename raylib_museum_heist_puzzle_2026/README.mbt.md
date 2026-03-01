# Museum Heist Puzzle 2026

A stealth puzzle game set in a museum, where you navigate a thief through a 20x14 tile grid to collect all artifacts while avoiding guards with directional vision cones. The game features 3 hand-crafted levels forming a campaign, guards on looping patrol paths with Bresenham line-of-sight checking, and an exit that unlocks only after all artifacts on a floor are collected.

The core gameplay loop involves tile-by-tile movement through rooms divided by walls, timing your path to slip past guards whose forward-facing vision cones are rendered as red-tinted overlays on the board. Guards patrol predefined waypoint paths at a fixed interval (0.33s per step), and their vision extends in a 90-degree forward cone up to their view range, blocked by walls via Bresenham's line algorithm. Stepping into a guard's vision cone or onto a guard's tile triggers an alarm and ends the level in failure. Collecting all artifacts unlocks the exit door, which changes from a locked brown appearance to a pulsing green indicator.

The game supports both keyboard and mouse/touch input with an on-screen D-pad for movement and clickable action buttons for menu navigation. A side panel displays the current floor, level name, artifact progress, stealth status, and control hints.

## Build and Run

```bash
moon build --target native raylib_museum_heist_puzzle_2026/
./_build/native/debug/build/raylib_museum_heist_puzzle_2026/raylib_museum_heist_puzzle_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Move player one tile in a cardinal direction
- **Enter or Space**: Start campaign / confirm action on overlay screens
- **N**: Cycle to next floor preview on title screen
- **R or Backspace**: Retry current floor
- **Touch/Mouse D-pad**: Hold directional buttons to move during play
- **Touch/Mouse action buttons**: Tap START HEIST, RETRY FLOOR, NEXT FLOOR, RESTART, BACK TO TITLE

## How to Play

Press Enter or tap START HEIST on the title screen to begin the campaign at Floor 1. You can also press N or tap CYCLE FLOOR to preview each level's layout before starting.

**Movement**: Use WASD or arrow keys (or the on-screen D-pad) to move one tile at a time. Movement has a step cooldown of 0.14 seconds preventing overly rapid input. The player cannot walk through walls or outside the board border.

**Artifacts**: Gold circles with crosshair indicators are scattered across each floor. Walk onto an artifact's tile to collect it. The side panel tracks your progress (e.g., "Artifacts 2/3"). All artifacts must be collected before the exit unlocks.

**Exit**: A small door tile marked "E" on the board. When locked, it appears brown. When all artifacts are collected, it pulses green. Walk onto the exit tile to clear the floor.

**Guards**: Red circles with directional indicators patrol fixed waypoint paths. Each guard has a forward-facing vision cone (90 degrees) extending up to their view range (5-6 tiles). The vision area is shown as a red overlay on the board. Guards check line-of-sight using Bresenham's algorithm, so walls block their vision. If you step into a guard's vision cone or land on the same tile as a guard, the alarm triggers and you lose.

**Campaign**: The game has 3 floors:
- Floor 1 "East Wing Silent Sweep" -- 3 artifacts, 2 guards (view range 6)
- Floor 2 "Laser Hall Maze" -- 4 artifacts, 3 guards (view range 5-6)
- Floor 3 "Grand Vault Orbit" -- 5 artifacts, 4 guards (view range 5-6)

Clearing a floor shows a "Floor Cleared" overlay with options to continue to the next floor or retry. Clearing all 3 floors shows the "Grand Collection Secured" campaign victory screen.

**Loss**: When spotted, a red alarm flash covers the screen (0.45s duration) and the "Alarm Triggered" overlay appears. Press R or tap RETRY FLOOR to restart the current level. During play, the RESTART button on the side panel also restarts the floor immediately.

## Public API Reference

### Package `raylib_museum_heist_puzzle_2026`

> Main entry point.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Entry point: initializes window (1280x800) at 60 FPS, creates Game, runs main loop reading mouse/touch state each frame, calls update_game and draw_frame |

### Package `raylib_museum_heist_puzzle_2026/internal/types`

> Core type definitions, constants, board utilities, guard vision logic, and UI layout helpers.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `Win`, `Lose`, `CampaignClear` | Game state machine states |
| `Direction` | `DirNone`, `Left`, `Right`, `Up`, `Down` | Cardinal movement directions plus no-movement |
| `TileKind` | `Floor`, `Wall` | Board tile types |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Artifact` | `x`, `y`, `taken` | Collectible relic at a board position with taken flag |
| `Guard` | `x`, `y`, `dir_x`, `dir_y`, `view_range`, `path`, `path_index`, `step_timer` | Patrolling guard with position, facing direction, vision range, waypoint path, and movement timer |
| `FrameInput` | `move_dir`, `start_pressed`, `next_pressed`, `retry_pressed`, `restart_pressed` | Aggregated input state for one frame from keyboard + touch/mouse |
| `Game` | `tiles`, `artifacts`, `guards`, `state`, `level_index`, `level_count`, `level_name`, `player_x`, `player_y`, `exit_x`, `exit_y`, `artifacts_total`, `artifacts_collected`, `player_step_t`, `state_t`, `pulse_t`, `alarm_t`, `mouse_x`, `mouse_y`, `mouse_hold`, `mouse_press`, `touch_count` | Main game state containing the tile board, entity arrays, player/exit positions, progress counters, timers, and input state |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` / `screen_h` | `Int` | `1280` / `800` | Window dimensions |
| `target_fps` | `Int` | `60` | Target frame rate |
| `board_cols` / `board_rows` | `Int` | `20` / `14` | Board grid dimensions |
| `board_cells` | `Int` | `280` | Total tile count (board_cols * board_rows) |
| `tile_size` | `Int` | `44` | Pixel size of each tile |
| `board_origin_x` / `board_origin_y` | `Int` | `36` / `96` | Board top-left pixel position |
| `panel_x` / `panel_y` | `Int` | `938` / `22` | Side panel top-left pixel position |
| `panel_w` / `panel_h` | `Int` | `320` / `756` | Side panel dimensions |
| `player_step_interval` | `Float` | `0.14` | Seconds between player tile moves |
| `guard_step_interval` | `Float` | `0.33` | Seconds between guard patrol steps |
| `menu_action_delay` | `Float` | `0.16` | Minimum seconds before overlay actions are accepted |
| `alarm_flash_time` | `Float` | `0.45` | Duration of the red alarm screen flash |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Game::new` | `() -> Game` | Creates a new Game with a board of 280 Floor tiles, empty entity arrays, and default state |
| `absi` | `(Int) -> Int` | Returns absolute value of an integer |
| `maxi` | `(Int, Int) -> Int` | Returns the maximum of two integers |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer to [lo, hi] range |
| `cell_index` | `(Int, Int) -> Int` | Converts (x, y) grid coordinates to a flat array index |
| `cell_x` | `(Int) -> Int` | Extracts x coordinate from a flat array index |
| `cell_y` | `(Int) -> Int` | Extracts y coordinate from a flat array index |
| `in_bounds` | `(Int, Int) -> Bool` | Tests if (x, y) is within the board grid |
| `tile_at` | `(Game, Int, Int) -> TileKind` | Returns the tile kind at (x, y), or Wall if out of bounds |
| `set_tile` | `(Game, Int, Int, TileKind) -> Unit` | Sets the tile kind at (x, y) if in bounds |
| `walkable` | `(Game, Int, Int) -> Bool` | Tests if the tile at (x, y) is Floor |
| `fill_board_floor` | `(Game) -> Unit` | Sets all tiles to Floor |
| `add_wall_rect` | `(Game, Int, Int, Int, Int) -> Unit` | Fills a rectangle of tiles with Wall |
| `carve_floor_rect` | `(Game, Int, Int, Int, Int) -> Unit` | Fills a rectangle of tiles with Floor |
| `add_border_walls` | `(Game) -> Unit` | Places Wall tiles along all four board edges |
| `clear_entities` | `(Game) -> Unit` | Empties artifact and guard arrays and resets counters |
| `spawn_artifact` | `(Game, Int, Int) -> Unit` | Adds an artifact at (x, y) if the tile is Floor |
| `spawn_guard` | `(Game, Array[Int], Int, Float) -> Unit` | Creates a guard with a waypoint path (flat indices), view range, and initial timer phase |
| `pc` | `(Int, Int) -> Int` | Shorthand for cell_index, used to build guard path arrays |
| `dir_delta` | `(Direction) -> (Int, Int)` | Returns the (dx, dy) offset for a Direction enum value |
| `has_line_of_sight` | `(Game, Int, Int, Int, Int) -> Bool` | Tests wall-free line of sight between two cells using Bresenham's algorithm |
| `in_guard_front` | `(Guard, Int, Int) -> Bool` | Tests if a relative offset (dx, dy) falls within the guard's 90-degree forward cone |
| `guard_sees_cell` | `(Game, Guard, Int, Int) -> Bool` | Tests if a guard can see a specific cell (in bounds, in range, in cone, line of sight clear) |
| `any_guard_on_cell` | `(Game, Int, Int) -> Bool` | Tests if any guard occupies a specific cell |
| `exit_unlocked` | `(Game) -> Bool` | Returns true if all artifacts have been collected |
| `player_spotted` | `(Game) -> Bool` | Returns true if the player is on a guard's tile or in any guard's vision cone |
| `cell_px` | `(Int) -> Int` | Converts grid x to pixel x (board_origin_x + x * tile_size) |
| `cell_py` | `(Int) -> Int` | Converts grid y to pixel y (board_origin_y + y * tile_size) |
| `board_right` | `() -> Int` | Returns the right pixel edge of the board |
| `board_bottom` | `() -> Int` | Returns the bottom pixel edge of the board |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a float point (px, py) is inside an integer rectangle |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Tests if mouse or any touch point is pressing inside a rectangle |
| `dpad_center_x` / `dpad_center_y` | `() -> Int` | Returns the pixel center of the on-screen D-pad |
| `dpad_button_size` | `() -> Int` | Returns the size (68px) of each D-pad button |
| `dpad_left_rect` / `dpad_right_rect` / `dpad_up_rect` / `dpad_down_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for each D-pad directional button |
| `start_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the START HEIST button on title screen |
| `next_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the NEXT FLOOR / CYCLE FLOOR button |
| `retry_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the RETRY FLOOR button on overlays |
| `restart_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) for the in-play RESTART button on the side panel |

### Package `raylib_museum_heist_puzzle_2026/internal/game`

> Game logic: level setup, guard patrol, player movement, artifact collection, detection, and state transitions.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `reset_to_title` | `(@types.Game) -> Unit` | Loads level 0 and sets state to Title |
| `update_game` | `(@types.Game, Float) -> Unit` | Main update: gathers input, caps delta time to 0.05s, advances timers, dispatches to state-specific update (title/play/win/lose/campaign_clear) |

### Package `raylib_museum_heist_puzzle_2026/internal/render`

> All rendering routines.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(@types.Game) -> Unit` | Main render: draws background, board tiles, guard FOV overlay, exit door, artifacts, guards, player, side panel, play controls (D-pad + restart button), alarm flash, and state overlays (title/win/lose/campaign_clear) |

## Architecture

### Package Structure

```
raylib_museum_heist_puzzle_2026/
├── main.mbt              -- Entry point: window init, mouse/touch reading, game loop
├── moon.pkg              -- Package config, imports
└── internal/
    ├── types/
    │   ├── types.mbt     -- Enums (GameState, Direction, TileKind), structs (Artifact, Guard, FrameInput, Game), Game::new
    │   ├── constants.mbt -- Screen/board dimensions, tile size, timing intervals
    │   └── utils.mbt     -- Board helpers, guard vision (Bresenham LOS, cone check), D-pad/button rect functions
    ├── game/
    │   ├── logic.mbt     -- 3 hand-crafted level layouts, level loading, guard patrol, player movement, artifact collection, detection, state transitions
    │   └── input.mbt     -- Keyboard + touch/mouse D-pad input gathering into FrameInput struct
    └── render/
        └── render.mbt    -- Background, board tiles, guard FOV overlay, exit, artifacts, guards, player, side panel, D-pad buttons, alarm flash, overlay cards
```

### Data Flow

1. **Input**: `main` reads mouse position, mouse button state, and touch count each frame into `Game` fields. `gather_input` then reads keyboard keys and tests D-pad/button hit regions via `pointer_on_rect` to produce a `FrameInput` struct.
2. **State Dispatch**: `update_game` dispatches to `update_title`, `update_play`, `update_win`, `update_lose`, or `update_campaign_clear` based on `game.state`. Each state handler checks `actions_ready` (requires 0.16s delay) before accepting button presses.
3. **Level Loading**: `load_level` clears all entities, fills the board with Floor, adds border walls, then calls the appropriate `setup_level_N` function which places interior walls, artifacts, guards with patrol paths, and sets player/exit positions.
4. **Play Update**: `update_play` decrements the player step timer, advances all guards along their patrol paths, moves the player if the step cooldown has elapsed, collects artifacts on the player's tile, checks for exit completion, and checks for guard detection.
5. **Guard Patrol**: Each guard has a looping waypoint path. `advance_guard_once` moves the guard one tile toward the current target waypoint, updating facing direction. When a waypoint is reached, the path index advances. Guards step at 0.33s intervals.
6. **Detection**: `player_spotted` first checks if any guard occupies the player's tile, then checks each guard's vision cone. `guard_sees_cell` validates: in bounds, not a wall, within view range (Chebyshev distance), within the 90-degree forward cone (`in_guard_front`), and has clear line of sight (`has_line_of_sight` using Bresenham's algorithm).
7. **Rendering**: `draw_frame` renders layers in order: background -> board tiles -> guard FOV overlay (red tint) -> exit door -> artifacts (gold circles) -> guards (red circles with direction indicator) -> player (blue circle) -> side panel -> D-pad controls -> alarm flash -> state overlay card.

### Key Design Patterns

- **Bresenham line-of-sight**: `has_line_of_sight` uses Bresenham's line algorithm to trace from guard to target cell, returning false if any intermediate tile is a Wall. This provides efficient grid-based visibility checking.
- **90-degree forward cone**: `in_guard_front` tests if a relative cell offset falls within the guard's facing direction using axis-aligned comparisons (e.g., for a right-facing guard: `dx >= 0 && abs(dy) <= dx`).
- **Hand-crafted levels with builder functions**: Each level is defined as a procedural function that calls `add_wall_rect`, `carve_floor_rect`, `spawn_artifact`, and `spawn_guard` to build the layout. This keeps level data as code rather than external files.
- **Input buffer pattern**: Mouse/touch state is captured once per frame into `Game` fields, and `gather_input` produces a `FrameInput` struct that decouples input reading from game logic.
- **Action delay for overlays**: `menu_action_delay` (0.16s) prevents accidental double-presses when transitioning between states by requiring a minimum time before overlay buttons respond.
- **Waypoint patrol paths**: Guard paths are defined as arrays of flat cell indices. Guards move one tile per step interval toward the current waypoint, advancing to the next waypoint upon arrival, with the path looping.

## Improvement & Refinement Plan

1. **Add undo/move history**: There is no way to undo a move. Adding a move stack would let players backtrack when they realize they are about to be spotted, improving the puzzle feel without eliminating challenge.
2. **Show guard patrol path preview**: Guard paths are invisible to the player. Displaying faint waypoint indicators or a dotted path line would help players plan routes, especially on harder levels.
3. **Add a move counter and par score**: There is no scoring system. Tracking the number of moves per level and comparing against a par value would add replayability and optimization incentive.
4. **Implement procedural level generation**: All 3 levels are hand-crafted. Adding a procedural generator using random room placement with guaranteed solvability checks would provide infinite content.
5. **Add sound effects**: The game has no audio feedback. Adding sounds for movement, artifact collection, exit unlock, alarm trigger, and guard patrol would significantly enhance the atmosphere.
6. **Improve guard AI variety**: All guards follow fixed waypoint paths. Adding stationary guards that rotate in place, or guards that briefly pause at waypoints before continuing, would create more diverse puzzle challenges.
7. **Add a turn-based mode option**: The game currently runs in real-time with step cooldowns. A pure turn-based mode where guards only move when the player moves would appeal to players who prefer deliberate puzzle solving over timing-based gameplay.
