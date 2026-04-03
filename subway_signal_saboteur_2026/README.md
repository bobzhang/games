# Subway Signal Saboteur 2026

Subway Signal Saboteur 2026 is a puzzle-strategy game set in an underground subway control system. The player controls a saboteur navigating a 25x13 tile grid, toggling junction signals to route incoming trains to their color-matched target lanes while evading three patrolling inspectors.

The core gameplay loop involves moving the player character to signal panels positioned above and below the three train tracks, pressing action to cycle junction switches (UP/STRAIGHT/DOWN), and watching trains respond in real-time as they pass through junction columns. Trains are color-coded (Red, Blue, Green) to indicate their target lane. Successfully routing a train to the correct lane awards 120 points; misrouting costs 70 points and a life. Train collisions (same lane, same position) cost 120 points and a life. The player must route 20 trains correctly within a 210-second time limit.

Three AI inspectors patrol the walkways. They switch between Patrol mode (walking back and forth along defined paths) and Hunt mode (chasing the player when within range or line of sight). The player has an EMP ability (costing 35 energy from a regenerating 100-point pool) that stuns inspectors within Manhattan distance 2 for 2.2 seconds, slows trains for 1.7 seconds, and provides critical escape windows.

## Build and Run

```bash
moon build --target native subway_signal_saboteur_2026/
./_build/native/debug/build/subway_signal_saboteur_2026/subway_signal_saboteur_2026.exe
```

## Controls

- **W / Up Arrow**: Move up
- **A / Left Arrow**: Move left
- **S / Down Arrow**: Move down
- **D / Right Arrow**: Move right
- **Space / E / J**: Action (toggle signal when on signal panel; deploy EMP otherwise)
- **H**: Cycle through hint messages
- **R**: Restart run
- **Escape**: Return to title screen
- **Enter / Space**: Start game (title/result screens)
- **Touch controls**: Directional pad (bottom-left), Action button (bottom-right), Hint/Retry/Menu buttons

## How to Play

From the title screen, press Enter or click START SHIFT. The saboteur spawns at position (2, 10) on the bottom walkway. The grid has three horizontal train tracks at rows 4, 6, and 8, with walkways above (row 2) and below (row 10) for the player. Four junction columns at x=6, 10, 14, 18 each have a signal panel on the top and bottom walkways.

Trains spawn from the left edge at increasing frequency (every 1.55-2.35 seconds initially, accelerating as more trains are routed). Each train has a color indicating its target lane (Red=lane 0, Blue=lane 1, Green=lane 2). As a train crosses a junction column, it shifts lanes according to the junction's signal: UP (-1 lane), STRAIGHT (no change), or DOWN (+1 lane), clamped to valid lanes 0-2.

To toggle a junction signal, move the player to a signal panel (within 1 tile of a junction X) on the top or bottom walkway and press Action. The signal cycles: -1 (UP) -> 0 (STRAIGHT) -> 1 (DOWN) -> -1 (UP). Each toggle awards 20 points.

When not on a signal panel, pressing Action deploys an EMP pulse (requires 35 energy). This stuns all inspectors within Manhattan distance 2 for 2.2 seconds, slows all trains to 52% speed for 1.7 seconds, and awards 50 points per stunned inspector. EMP energy regenerates at 16/sec.

The three inspectors patrol set paths. When the player is within Manhattan distance 4 or within line of sight (cardinal axes, blocked by walls/tracks) at distance 8, they enter Hunt mode and chase the player. Being on the same tile as an inspector costs a life and resets the player to the starting position (with a 1-second invulnerability flash). Being caught by an inspector costs a life; losing all 3 lives ends the run.

Win by routing 20 trains correctly before the 210-second timer expires. Win bonus is 1000 points plus 150 per remaining life.

## Public API Reference

### Package `subway_signal_saboteur_2026`

> Main entry point.

The main function initializes the window with MSAA 4x hint and audio device, creates a `Game` instance, and runs the game loop.

### Package `subway_signal_saboteur_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `Result` | Game state machine states |
| `Tile` | `Void`, `Floor`, `Track`, `Wall` | Map tile types |
| `InspectorMode` | `Patrol`, `Hunt`, `Stunned` | Inspector AI behavior modes |
| `ParticleKind` | `Spark`, `Gold`, `Smoke` | Visual particle color categories |
| `TrainColor` | `Red`, `Blue`, `Green` | Train target lane color identifiers |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Actor` | `x`, `y`, `from_x`, `from_y`, `to_x`, `to_y`, `fx`, `fy`, `t`, `moving` | Animated grid entity with integer position, lerped float position, and movement interpolation state |
| `Train` | `active`, `x`, `prev_x`, `lane`, `target_lane`, `speed`, `passed_junction`, `color_id` | Train entity moving rightward on tracks with lane, target, speed, and junction tracking |
| `Inspector` | `active`, `body`, `mode`, `move_cd`, `dir_x`, `path_y`, `path_min_x`, `path_max_x`, `stun_t`, `seed`, `alert_t` | Inspector AI with Actor body, patrol parameters, stun timer, and deterministic RNG seed |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | Visual particle with physics and lifetime |
| `Game` | `map`, `switch_state`, `trains`, `inspectors`, `particles`, `state`, `player`, `lives`, `score`, `routed_ok`, `time_left`, `emp_energy` | Main game state with map, entity pools, scoring, and UI state |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w`, `screen_h` | `Int` | `1840`, `1010` | Screen dimensions |
| `cell` | `Int` | `56` | Grid cell size in pixels |
| `grid_w`, `grid_h` | `Int` | `25`, `13` | Grid dimensions in cells |
| `train_lane_n` | `Int` | `3` | Number of train lanes |
| `junction_n` | `Int` | `4` | Number of junction switches |
| `max_trains` | `Int` | `24` | Maximum train pool size |
| `max_inspectors` | `Int` | `3` | Maximum inspector count |
| `max_lives` | `Int` | `3` | Starting lives |
| `goal_routed` | `Int` | `20` | Trains to route correctly for victory |
| `round_time_limit` | `Float` | `210.0` | Time limit in seconds |
| `emp_cost` | `Float` | `35.0` | EMP energy cost per use |
| `score_route_ok` | `Int` | `120` | Points for correct route |
| `score_route_bad` | `Int` | `-70` | Points for wrong route |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Actor::new` | `() -> Actor` | Creates an actor at the starting position |
| `Train::new` | `() -> Train` | Creates an inactive train |
| `Inspector::new` | `() -> Inspector` | Creates an inactive inspector with default patrol |
| `Particle::new` | `() -> Particle` | Creates an inactive particle |
| `Game::new` | `() -> Game` | Creates a new game with all pools and default state |
| `mini`, `maxi` | `(Int, Int) -> Int` | Integer min/max functions |
| `clampi`, `clampf` | `(T, T, T) -> T` | Clamp integer/float to range |
| `absi`, `absf` | `(T) -> T` | Absolute value for int/float |
| `lerpf` | `(Float, Float, Float) -> Float` | Linear interpolation between two floats |
| `sinf` | `(Float) -> Float` | Sine via Double conversion |
| `randf` | `(Float, Float) -> Float` | Random float in [lo, hi] |
| `manhattan` | `(Int, Int, Int, Int) -> Int` | Manhattan distance between two grid points |
| `board_px`, `board_py` | `(Int) -> Int` | Convert grid coordinates to pixel positions |
| `cell_center_x`, `cell_center_y` | `(Float) -> Int` | Center pixel of a cell given float grid position |
| `lane_to_y` | `(Int) -> Int` | Convert lane index (0-2) to grid Y coordinate |
| `junction_x` | `(Int) -> Int` | Get grid X for junction index |
| `signal_panel_top_y`, `signal_panel_bottom_y` | `() -> Int` | Y coordinates of signal panels |
| `start_button_rect`, `retry_button_rect` | `() -> (Int, Int, Int, Int)` | UI button rectangles |
| `btn_left`, `btn_right`, `btn_up`, `btn_down` | `() -> (Int, Int, Int, Int)` | Directional touch button rectangles |
| `btn_action`, `btn_hint`, `btn_restart`, `btn_menu` | `() -> (Int, Int, Int, Int)` | Action touch button rectangles |
| `hint_text` | `(Int) -> String` | Returns hint text for a given index (0-3) |
| `point_in_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Point-in-rectangle test |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Mouse or touch point on rectangle test |
| `idx` | `(Int, Int) -> Int` | Convert 2D grid to 1D array index |
| `in_bounds` | `(Int, Int) -> Bool` | Check if grid position is within bounds |
| `tile_at` | `(Game, Int, Int) -> Tile` | Get tile at grid position (Void if out of bounds) |
| `set_tile` | `(Game, Int, Int, Tile) -> Unit` | Set tile at grid position |
| `set_msg` | `(Game, String, Float) -> Unit` | Set message text with display duration |
| `actor_place` | `(Actor, Int, Int) -> Unit` | Teleport actor to grid position |
| `actor_start_move` | `(Actor, Int, Int) -> Unit` | Begin interpolated movement to target |
| `actor_tick` | `(Actor, Float, Float) -> Unit` | Update actor interpolation each frame |

### Package `subway_signal_saboteur_2026/internal/game`

> Game logic, AI, train simulation, and input handling.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main update entry point: dispatches input and state updates per game state |
| `update_title_input` | `(Game) -> Unit` | Handles title screen start input |
| `update_play_input` | `(Game) -> Unit` | Handles play movement, action, hint, restart, and menu input |
| `update_result_input` | `(Game) -> Unit` | Handles result screen retry input |
| `start_run` | `(Game) -> Unit` | Initializes a new game run: builds map, spawns inspectors, resets state |
| `go_title` | `(Game) -> Unit` | Returns to title screen |
| `finish_run` | `(Game, Bool, String) -> Unit` | Ends the run with win/loss state and reason |
| `build_map` | `(Game) -> Unit` | Constructs the grid map with walls, floors, and tracks |
| `init_inspectors` | `(Game) -> Unit` | Places inspectors at predefined patrol paths |
| `clear_trains` | `(Game) -> Unit` | Deactivates all trains |
| `spawn_train` | `(Game) -> Bool` | Spawns a new train with random lane, target, and speed (max 8 active) |
| `try_toggle_switch` | `(Game) -> Bool` | Cycles the nearest junction signal if player is on a signal panel |
| `deploy_emp` | `(Game) -> Bool` | Fires EMP: stuns nearby inspectors, slows trains, costs energy |
| `try_move_player` | `(Game, Int, Int) -> Bool` | Attempts to move the player one cell in given direction |
| `update_trains` | `(Game, Float) -> Unit` | Advances trains, applies junction switches, handles exit scoring |
| `resolve_train_collisions` | `(Game) -> Unit` | Detects and handles same-lane train overlaps |
| `update_inspectors` | `(Game, Float) -> Unit` | Updates inspector AI: patrol, hunt, stun recovery, movement |
| `choose_inspector_step` | `(Game, Int) -> (Int, Int)` | Decides next inspector movement based on mode and player proximity |
| `line_of_sight` | `(Game, Int, Int, Int, Int) -> Bool` | Cardinal-axis line of sight check blocked by walls and tracks |
| `handle_player_spotted` | `(Game) -> Unit` | Checks if any inspector occupies the player's tile and applies penalty |
| `update_play` | `(Game, Float) -> Unit` | Orchestrates the play state update each frame |
| `cycle_hint` | `(Game) -> Unit` | Cycles to next hint message |

### Package `subway_signal_saboteur_2026/internal/render`

> Rendering and drawing routines.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main rendering entry point |
| `draw_background` | `(Game) -> Unit` | Draws gradient background with ambient glow circles |
| `draw_tiles` | `(Game, Int, Int) -> Unit` | Draws grid tiles (walls, tracks, floors) with offset for shake |
| `draw_junctions` | `(Game, Int, Int) -> Unit` | Draws junction indicators with switch direction arrows and signal panels |
| `draw_trains` | `(Game, Int, Int) -> Unit` | Draws trains as colored rectangles with body and headlight |
| `draw_inspectors` | `(Game, Int, Int) -> Unit` | Draws inspectors with mode-dependent coloring and hunt alert rings |
| `draw_player` | `(Game, Int, Int) -> Unit` | Draws the player character with hit-flash blinking |
| `draw_particles` | `(Game, Int, Int) -> Unit` | Draws active particles with kind-based coloring |
| `draw_board` | `(Game, Int, Int) -> Unit` | Composites all board elements in order |
| `draw_panel` | `(Game) -> Unit` | Draws the side information panel with stats, signals, EMP bar, and controls |
| `draw_touch_button` | `(Game, (Int,Int,Int,Int), String, Color, Color) -> Unit` | Draws a styled touch button with hover detection |
| `draw_touch_controls` | `(Game) -> Unit` | Draws all mobile touch buttons during play |
| `draw_title_overlay` | `(Game) -> Unit` | Draws title screen overlay with instructions and start button |
| `draw_result_overlay` | `(Game) -> Unit` | Draws win/loss result overlay with score summary and retry button |

## Architecture

### Package Structure

```
subway_signal_saboteur_2026/
├── main.mbt                    -- Entry point: window/audio init, game loop
├── moon.pkg                    -- Root package config
└── internal/
    ├── types/
    │   ├── types.mbt           -- Enums, structs (Game, Actor, Train, Inspector, Particle)
    │   ├── constants.mbt       -- All game constants and tuning values
    │   └── utils.mbt           -- Math, grid helpers, button rects, tile access, actor movement
    ├── game/
    │   ├── logic.mbt           -- Map building, train sim, inspector AI, signal toggling, EMP, win/lose
    │   └── input.mbt           -- Input handling for all three game states
    └── render/
        └── render.mbt          -- All drawing: background, tiles, trains, inspectors, player, HUD, overlays
```

### Data Flow

1. **Input** (`input.mbt`): `update_play_input` reads keyboard and touch state, sets `req_dx`/`req_dy` for movement and `action_pressed` for signal/EMP. Diagonal input is resolved to single-axis. Touch buttons use `pointer_on_rect` for hit-testing.

2. **Update** (`logic.mbt`): `update_play` runs each frame:
   - Timers decrement (time limit, cooldowns, flash, shake)
   - EMP energy regenerates at 16/sec
   - Player actor interpolates movement via `actor_tick`
   - If not moving and no cooldown, `try_move_player` checks walkability
   - Action: `try_toggle_switch` first (if on signal panel), else `deploy_emp`
   - Train spawning at decreasing intervals
   - `update_trains`: advance by speed * dt (slowed if EMP active), apply junction switches when crossing junction X, handle exit scoring
   - `resolve_train_collisions`: detect same-lane overlaps
   - `update_inspectors`: tick actors, manage stun recovery, `choose_inspector_step` selects patrol or hunt movement
   - `handle_player_spotted`: inspector-player collision check
   - Win/lose resolution

3. **Render** (`render.mbt`): `draw_frame` draws background, board with shake offset (tiles, junctions, trains, inspectors, player, particles), side panel with stats/signals/EMP bar/controls, touch buttons, and state overlays.

### Key Design Patterns

- **Actor interpolation system**: `Actor` struct handles smooth grid movement via `from_x`/`from_y` to `to_x`/`to_y` lerping with a normalized `t` parameter, used by both player and inspectors.
- **Junction signal cycling**: Tri-state signals (-1, 0, 1) cycle through UP/STRAIGHT/DOWN, affecting train lane changes only at the exact junction crossing point.
- **Inspector AI with dual modes**: Patrol follows a fixed horizontal path; Hunt uses Manhattan distance greedy pathfinding. Transitions based on proximity and line-of-sight thresholds.
- **Deterministic inspector randomness**: `inspector_seed_next` uses a linear congruential generator for consistent fallback movement decisions.
- **EMP dual-use mechanic**: EMP both stuns inspectors (defensive) and slows trains (giving time to adjust signals), creating tactical depth from a single ability.

## Improvement & Refinement Plan

1. **Add visual lane color indicators**: The tracks do not show which color they correspond to. Drawing colored stripes or labels on each lane at the exit would help players quickly assess routing needs without memorizing lane-to-color mapping.

2. **Implement train preview queue**: Players cannot see upcoming trains until they appear. A queue display showing the next 2-3 trains and their target colors would allow proactive signal planning instead of reactive scrambling.

3. **Add signal lock mechanic**: Currently signals can be toggled freely. A brief lock period after toggling (preventing re-toggle for 1-2 seconds) would increase challenge and reward more deliberate signal planning.

4. **Improve inspector pathfinding**: `choose_inspector_step` uses single-step greedy Manhattan distance, which gets stuck on walls. Implementing BFS or A* for Hunt mode would make inspectors more threatening and less exploitable.

5. **Add score combo system**: Routing multiple trains correctly in succession could multiply score gains. This would reward sustained focus and create risk/reward tension with inspector avoidance.

6. **Extract train scoring into a separate function**: The exit logic in `update_trains` mixes train deactivation, scoring, life loss, and particle emission. A `resolve_train_exit(game, train)` function would improve clarity.

7. **Add difficulty progression**: The spawn rate increases slightly but other parameters are static. Adding inspector speed increases, more junctions, or tighter time limits at higher scores would provide long-term challenge scaling.
