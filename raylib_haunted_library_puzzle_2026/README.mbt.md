# Haunted Library Puzzle 2026

A grid-based puzzle game set in a haunted library. Navigate through a maze of bookshelves, collect lost pages, activate arcane seals by pushing shelves onto glowing circles, and escape through the gate while avoiding patrolling ghosts.

## Build and Run

```bash
cd examples && moon build --target native raylib_haunted_library_puzzle_2026/
cd examples && ./_build/native/debug/build/raylib_haunted_library_puzzle_2026/raylib_haunted_library_puzzle_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Move the player on the grid
- **Space/E**: Stun pulse (uses lantern energy)
- **Touch buttons**: On-screen d-pad and action button
- **Mouse click**: UI buttons for start, retry, hints

## How to Play

Explore a 21x13 grid library. Collect all 5 lost pages scattered across the map and activate 3 arcane seals by pushing bookshelves onto glowing circles. Ghosts patrol the corridors and hunt you on sight -- use stun pulses to temporarily disable them, but manage your limited lantern energy. Break line-of-sight around book stacks to evade hunters. Once all seals are activated, the south gate opens for your escape. You have 3 lives.

## Public API Reference

### Package `raylib_haunted_library_puzzle_2026`

> Main entry point.

`main.mbt` initialises a 1760x980 window with MSAA, creates a `@types.Game` via `Game::new()`, and runs the frame loop: polls input into `@game.update_*_input`, advances simulation with `@game.update_game`, then renders with `@render.draw_frame`.

### Package `raylib_haunted_library_puzzle_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Actor` | `x`, `y`, `from_x`, `from_y`, `to_x`, `to_y`, `fx`, `fy`, `t`, `moving` | Grid entity with smooth interpolation between tiles. |
| `Ghost` | `active`, `body`, `mode`, `stun_t`, `move_cd`, `seed`, `alert_t` | Ghost entity with patrol/hunt/stunned AI modes and a deterministic-random seed for patrol direction. |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | Short-lived visual effect particle. |
| `Game` | `map`, `shelf_*`, `page_*`, `ghosts`, `particles`, `state`, `player`, `lives`, `pages`, `seals_on`, `gate_open`, `score`, `steps`, `time_s`, + input/timer fields | Complete runtime state for one puzzle session. |

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `Result` | High-level flow state. |
| `Tile` | `Floor`, `Wall`, `Exit` | Grid tile classification used for collision and pathfinding. |
| `GhostMode` | `Patrol`, `Hunt`, `Stunned` | Ghost behaviour mode. |
| `ParticleKind` | `Dust`, `Gold`, `Purple` | Particle visual category. |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Actor::new` | `() -> Actor` | Creates an Actor placed at the starting tile. |
| `Ghost::new` | `() -> Ghost` | Creates an inactive Ghost with default patrol state. |
| `Particle::new` | `() -> Particle` | Creates an inactive Particle with default values. |
| `Game::new` | `() -> Game` | Creates a fully initialised Game with preallocated arrays. |
| `mini` | `(Int, Int) -> Int` | Returns the smaller of two integers. |
| `maxi` | `(Int, Int) -> Int` | Returns the larger of two integers. |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer to `[lo, hi]`. |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to `[lo, hi]`. |
| `absi` | `(Int) -> Int` | Absolute value of an integer. |
| `lerpf` | `(Float, Float, Float) -> Float` | Linear interpolation between two floats. |
| `sinf` | `(Float) -> Float` | Sine via the core math backend. |
| `randf` | `(Float, Float) -> Float` | Uniform random float in `[lo, hi]`. |
| `manhattan` | `(Int, Int, Int, Int) -> Int` | Manhattan distance between two grid cells. |
| `board_px` / `board_py` | `(Int) -> Int` | Converts a grid index to board pixel coordinate. |
| `cell_center_x` / `cell_center_y` | `(Float) -> Int` | Converts an interpolated actor position to cell-centre pixel coordinate. |
| `seal_pos` | `(Int) -> (Int, Int)` | Returns the grid position of seal `i`. |
| `seal_hint` | `(Int) -> String` | Returns the hint string for hint index `i`. |
| `point_in_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Hit-tests a point against a rectangle. |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Hit-tests mouse or any touch point against a rectangle. |
| `title_hover` / `retry_hover` | `(Float, Float, Bool, Int) -> Bool` | Returns whether the respective UI button is under pointer. |
| `btn_left/right/up/down/action/hint/restart/menu` | `() -> (Int,Int,Int,Int)` | Returns the on-screen button rectangle for the given control. |
| `start_button_rect` / `retry_button_rect` | `() -> (Int,Int,Int,Int)` | Returns the overlay start / retry button rectangle. |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1760` | Window width in pixels. |
| `screen_h` | `Int` | `980` | Window height in pixels. |
| `target_fps` | `Int` | `120` | Target frame rate. |
| `cell` | `Int` | `60` | Grid cell size in pixels. |
| `grid_w` | `Int` | `21` | Number of board columns. |
| `grid_h` | `Int` | `13` | Number of board rows. |
| `max_shelves` | `Int` | `32` | Maximum movable shelves. |
| `max_pages` | `Int` | `5` | Collectible pages per run. |
| `max_ghosts` | `Int` | `5` | Maximum active ghosts. |
| `seal_need` | `Int` | `3` | Seals required to open the gate. |
| `max_particles` | `Int` | `360` | Particle pool size. |
| `player_move_time` | `Float` | `0.115` | Seconds per player tile move. |
| `ghost_move_time` | `Float` | `0.165` | Seconds per ghost tile move. |
| `page_score` | `Int` | `350` | Score per recovered page. |
| `seal_score` | `Int` | `220` | Score per activated seal. |
| `escape_score` | `Int` | `1000` | Bonus score for successful escape. |

### Package `raylib_haunted_library_puzzle_2026/internal/game`

> Game logic, input handling, and update systems.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_title_input` | `(@types.Game) -> Unit` | Handles title-screen keyboard, mouse, and touch input; starts a new run when confirmed. |
| `update_play_input` | `(@types.Game) -> Unit` | Handles in-play keyboard, D-pad touch, and action button input; writes movement deltas and action flags to the game state. |
| `update_result_input` | `(@types.Game) -> Unit` | Handles result-screen input; restarts the run when confirmed. |
| `update_game` | `(@types.Game, Float) -> Unit` | Advances one frame of simulation based on active flow state; clears `action_pressed` at end of frame. |
| `start_run` | `(@types.Game) -> Unit` | Resets the puzzle state, loads the map and entity layout, and transitions to the Play state. |
| `go_title` | `(@types.Game) -> Unit` | Returns the game to the Title state and clears transient effects. |
| `cycle_hint` | `(@types.Game) -> Unit` | Cycles the hint index and updates the message banner. |

### Package `raylib_haunted_library_puzzle_2026/internal/render`

> Rendering and drawing routines.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(@types.Game) -> Unit` | Draws the full frame: background, board with shake offset, side panel, touch controls, and any active overlay (title or result). |

## Architecture

### Package Structure

```
raylib_haunted_library_puzzle_2026/
├── main.mbt              — Entry point: window init, input poll, update dispatch, render call
├── moon.pkg
└── internal/
    ├── types/
    │   ├── constants.mbt — All numeric/string constants plus pure utility functions
    │   └── types.mbt     — GameState, Tile, GhostMode, ParticleKind enums; Actor, Ghost, Particle, Game structs with constructors
    ├── game/
    │   ├── input.mbt     — Input handlers for Title, Play, and Result states
    │   └── logic.mbt     — Map generation, entity placement, player movement, shelf pushing, ghost AI, stun pulse, win/loss detection, particle system
    └── render/
        └── render.mbt    — All draw functions: background, grid, seals, pages, shelves, gate, player, ghosts, particles, HUD panel, overlays, touch buttons
```

Data flows from `main.mbt` inward: raw Raylib input is written into `Game` fields, `@game.update_*_input` translates them to movement requests and action flags, `@game.update_game` advances simulation and mutates `Game`, and `@render.draw_frame` reads `Game` as a pure view. The `types` package is a leaf with no dependencies on `game` or `render`, preventing circular imports.

Key design patterns:
- Sokoban-style shelf pushing: `try_move_player` detects a shelf in the target cell and calls `push_shelf` before committing the move.
- Ghost AI uses Manhattan distance and axis-aligned line-of-sight checks; within detection range ghosts greedily minimise Manhattan distance to the player, otherwise they use a seeded LCG for pseudo-random patrol steps.
- Actor interpolation fields (`from_x/y`, `to_x/y`, `fx/fy`, `t`) decouple the logical grid position from the rendered float position, producing smooth movement at 120 fps.
- Screen-shake is applied as a pixel offset `(shake_dx, shake_dy)` passed to all board draw calls.
- A 240-second run timer forces the player to act efficiently; running out triggers a loss.

## Improvement & Refinement Plan

1. Add multiple puzzle layouts selectable at the title screen to increase replayability beyond the single hard-coded shelf and page arrangement.
2. Implement a proper BFS/A* ghost pathfinding mode for `Hunt` state instead of greedy Manhattan minimisation, which can be blocked by L-shaped obstacles.
3. Add an energy-regeneration animation or warning flash when lantern energy falls below 30 to give clearer feedback before the stun pulse becomes unavailable.
4. Introduce a ghost respawn mechanic or ghost count that scales per run to maintain tension in later phases when ghosts cluster near the exit.
5. Extract `load_layout` data into a declarative array-of-maps structure so new levels can be added without modifying logic code.
6. Persist the best score and fastest completion time across sessions using Raylib's `save_storage_value`/`load_storage_value`.
7. Add ambient sound effects (footsteps, ghost moan, seal activation chime, page rustle) using Raylib's audio API to reinforce the haunted-library atmosphere.
