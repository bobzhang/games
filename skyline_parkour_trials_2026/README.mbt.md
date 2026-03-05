# Skyline Parkour Trials

A precision platformer where the player runs, jumps, and wall-climbs across rooftop obstacle courses against the clock. Three handcrafted stages feature increasing complexity with solid platforms, hazard zones, and time-bonus checkpoints. The game emphasizes momentum management with advanced movement mechanics including coyote time, jump buffering, wall sliding, wall jumping, and limited wall climbing.

The core loop is pure speedrun: navigate from start to goal as fast as possible, hitting checkpoints to extend the shared timer. Each stage has a unique time budget (42s, 36s, 32s) that carries over between stages. The timer is capped at 99.9 seconds. Fall off the skyline, hit a hazard, or run out of time and the run ends. Complete all three stages to achieve victory.

Technically, the game features a comprehensive touch-input abstraction that unifies keyboard, mouse, and multi-touch controls with edge detection for button presses. The three-layer parallax city background with animated glow creates atmospheric depth, and the camera tracks the player with a 34% forward look-ahead for anticipatory platforming.

## Build and Run

```bash
moon build --target native skyline_parkour_trials_2026/
./_build/native/debug/build/skyline_parkour_trials_2026/skyline_parkour_trials_2026.exe
```

## Controls

- **A / Left Arrow**: Move left
- **D / Right Arrow**: Move right
- **Space / W / Up Arrow**: Jump (also wall jump when near a wall)
- **Left Shift / Right Shift / E**: Wall climb (hold while touching a wall)
- **R**: Restart entire run
- **Enter / Space**: Start game (title screen), advance (stage clear/game over)
- **Touch controls**: Left/Right movement buttons, JUMP button, CLIMB button, RESTART button

## How to Play

Sprint across rooftop platforms in a neon-lit cityscape. Three stages of increasing difficulty must be completed in sequence with a shared countdown timer.

**Movement**: Run left/right with A/D. The player accelerates differently on ground (2700) vs air (1650) and has separate drag values for each (2300 ground, 820 air). Maximum run speed is 420 units/s. The `approachf` function applies drag when no input is pressed, smoothly decelerating toward zero.

**Jumping**: Press Space to jump with an initial velocity of 780 units/s upward. Releasing the jump button early applies extra gravity (2400 vs normal 2140), enabling variable-height jumps. A jump buffer window of 0.13s catches early presses, and coyote time gives a 0.11s grace period after walking off an edge.

**Wall mechanics**: Touching a wall sets a 0.17s wall-jump window. During this window the player slides down at a reduced speed of 210 instead of the normal max fall speed of 980. Pressing jump during the window executes a wall jump (820 upward, 470 horizontal push away from wall). Holding Shift/E while touching a wall activates wall climbing, which provides upward acceleration (1650 units/s^2, capped at 220 units/s upward) for up to 0.62s per ground-touch cycle. Climbing stamina resets when landing on the ground.

**Checkpoints**: Blue pulsing markers scattered across each stage. Touching one adds bonus time (6-9 seconds depending on stage and position) and increments the checkpoint counter. A popup briefly shows the time gained.

**Hazards**: Red pulsing rectangles placed on certain platforms. Contact instantly fails the run with a "Hit a hazard" message.

**Goal**: A green pulsing zone at the end of each stage. Reaching it clears the stage, awards a time bonus (9s for stage 1, 8s for stage 2, none for stage 3), and transitions to the next stage or victory.

**Stage layout**: Stage 1 (width 2800) has 9 platforms, 2 hazards, 2 checkpoints. Stage 2 (width 3200) has 14 platforms, 3 hazards, 3 checkpoints with more wall-jump corridors. Stage 3 (width 3600) has 18 platforms, 4 hazards, 3 checkpoints with extensive vertical climbing sections using narrow wall columns.

**Lose conditions**: Timer reaches zero (out of time), player falls below the stage boundary (210 pixels below screen bottom), or player touches a hazard tile.

## Public API Reference

### Package `skyline_parkour_trials_2026`

> Main entry point. Initializes the window at 1366x768 at 120 FPS, creates the Game instance, and runs the update/draw loop with clamped delta time.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Entry point: sets up window with MSAA, creates Game, polls input, runs update_game and draw_frame each frame |

### Package `skyline_parkour_trials_2026/internal/types`

> Core type definitions, constants, color functions, and utility helpers.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1366` | Screen width in pixels |
| `screen_h` | `Int` | `768` | Screen height in pixels |
| `target_fps` | `Int` | `120` | Target frame rate |
| `stage_count` | `Int` | `3` | Total number of stages |
| `max_tiles` | `Int` | `128` | Maximum tile pool size |
| `max_checkpoints` | `Int` | `12` | Maximum checkpoint pool size |
| `player_w` | `Float` | `34.0` | Player hitbox width |
| `player_h` | `Float` | `54.0` | Player hitbox height |
| `gravity` | `Float` | `2140.0` | Normal downward acceleration |
| `max_fall_speed` | `Float` | `980.0` | Terminal velocity when falling |
| `run_accel_ground` | `Float` | `2700.0` | Horizontal acceleration on ground |
| `run_accel_air` | `Float` | `1650.0` | Horizontal acceleration in air |
| `run_max_speed` | `Float` | `420.0` | Maximum horizontal run speed |
| `run_drag_ground` | `Float` | `2300.0` | Horizontal deceleration on ground when not pressing input |
| `run_drag_air` | `Float` | `820.0` | Horizontal deceleration in air when not pressing input |
| `jump_speed` | `Float` | `780.0` | Initial upward velocity on jump |
| `jump_cut_gravity` | `Float` | `2400.0` | Extra gravity applied when jump button released early |
| `jump_buffer_time` | `Float` | `0.13` | Jump buffer window in seconds |
| `coyote_time` | `Float` | `0.11` | Coyote time window in seconds |
| `wall_jump_window` | `Float` | `0.17` | Wall jump grace period in seconds |
| `wall_jump_push` | `Float` | `470.0` | Horizontal push speed on wall jump |
| `wall_jump_speed` | `Float` | `820.0` | Upward speed on wall jump |
| `wall_slide_speed` | `Float` | `210.0` | Max fall speed while wall sliding |
| `wall_climb_time_max` | `Float` | `0.62` | Maximum wall climb duration per ground touch |
| `wall_climb_up_accel` | `Float` | `1650.0` | Upward acceleration while wall climbing |
| `wall_climb_up_speed` | `Float` | `220.0` | Maximum upward speed while wall climbing |
| `timer_cap` | `Float` | `99.9` | Maximum timer value |
| `stage_fail_y_pad` | `Float` | `210.0` | Distance below screen bottom before fall triggers game over |

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `StageClear`, `GameOver`, `Victory` | Game state machine states |
| `TileKind` | `Solid`, `Hazard` | Tile collision behavior type |
| `LoseReason` | `None`, `Time`, `Fall`, `HitHazard` | Reason for run failure |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Tile` | `kind`, `x`, `y`, `w`, `h` | A rectangular world tile with a collision type |
| `Checkpoint` | `x`, `y`, `w`, `h`, `bonus_s`, `taken` | A collectible time bonus marker with position and value |
| `Player` | `x`, `y`, `vx`, `vy`, `on_ground`, `wall_side`, `wall_window_t`, `wall_climb_t`, `coyote_t`, `jump_buffer_t`, `facing` | Player character with full physics and movement state |
| `Game` | `tiles`, `checkpoints`, `hero`, `state`, `stage`, `timer_s`, `run_time_s`, `goal_x/y/w/h`, `input_*`, `touch_*`, `mouse_*` | Main game state container with world data, player, timers, and input fields |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Tile::new` | `() -> Tile` | Creates a default inactive tile |
| `Checkpoint::new` | `() -> Checkpoint` | Creates a default untaken checkpoint |
| `Player::new` | `() -> Player` | Creates a player at origin with default physics state |
| `Game::new` | `() -> Game` | Creates a new game instance with allocated tile and checkpoint arrays |
| `stage_initial_time` | `(Int) -> Float` | Returns the starting timer for a given stage (42, 36, or 32 seconds) |
| `stage_clear_bonus` | `(Int) -> Int` | Returns time bonus seconds for clearing a stage (9, 8, or 0) |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between low and high bounds |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between low and high bounds |
| `maxf` | `(Float, Float) -> Float` | Returns the maximum of two floats |
| `minf` | `(Float, Float) -> Float` | Returns the minimum of two floats |
| `absf` | `(Float) -> Float` | Returns absolute value of a float |
| `approachf` | `(Float, Float, Float) -> Float` | Moves a value toward a target by a fixed step per frame |
| `sinf` | `(Float) -> Float` | Sine function via core math |
| `cosf` | `(Float) -> Float` | Cosine function via core math |
| `point_in_rect` | `(Float, Float, Float, Float, Float, Float) -> Bool` | Point-in-rectangle hit test |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Float, Float, Float, Float) -> Bool` | Tests mouse and all touch points against a rectangle |
| `overlap_rect` | `(Float, Float, Float, Float, Float, Float, Float, Float) -> Bool` | Axis-aligned rectangle overlap test |
| `mouse_click_on_rect` | `(Float, Float, Float, Float, Float, Float) -> Bool` | Tests if mouse was clicked inside a rectangle |
| `timer_string` | `(Float) -> String` | Formats a float timer as "S.D" (seconds with one decimal) |
| `run_string` | `(Float) -> String` | Formats a run time as "S.D" with higher range |
| `touch_left_rect` | `() -> (Float, Float, Float, Float)` | Returns bounds for the left movement touch button |
| `touch_right_rect` | `() -> (Float, Float, Float, Float)` | Returns bounds for the right movement touch button |
| `touch_jump_rect` | `() -> (Float, Float, Float, Float)` | Returns bounds for the jump touch button |
| `touch_climb_rect` | `() -> (Float, Float, Float, Float)` | Returns bounds for the climb touch button |
| `touch_play_restart_rect` | `() -> (Float, Float, Float, Float)` | Returns bounds for the in-play restart touch button |
| `title_start_rect` | `() -> (Float, Float, Float, Float)` | Returns bounds for the title screen start button |
| `panel_next_rect` | `() -> (Float, Float, Float, Float)` | Returns bounds for the panel next/retry button |
| `panel_restart_rect` | `() -> (Float, Float, Float, Float)` | Returns bounds for the panel restart button |
| `col_bg_top` | `() -> Color` | Dark blue-gray background gradient top color |
| `col_bg_bottom` | `() -> Color` | Near-black background gradient bottom color |
| `col_sky_glow` | `() -> Color` | Translucent blue sky glow circle color |
| `col_roof` | `() -> Color` | Solid tile fill color |
| `col_roof_edge` | `() -> Color` | Solid tile top edge highlight color |
| `col_checkpoint` | `() -> Color` | Checkpoint outline color (cyan) |
| `col_goal` | `() -> Color` | Goal zone outline color (green) |
| `col_text_main` | `() -> Color` | Primary HUD text color (near-white) |
| `col_text_dim` | `() -> Color` | Secondary HUD text color (light blue) |
| `col_player_run` | `() -> Color` | Player body color during normal movement (yellow) |
| `col_player_wall` | `() -> Color` | Player body color during wall interaction (orange) |

### Package `skyline_parkour_trials_2026/internal/game`

> Game logic, input handling, stage layout definitions, and state transitions.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `init_title_scene` | `(Game) -> Unit` | Loads stage 1 data and sets the game to Title state with initial timer |
| `update_game` | `(Game, Float) -> Unit` | Top-level update: dispatches to state-specific input handlers and updaters based on current GameState |

### Package `skyline_parkour_trials_2026/internal/render`

> All rendering and visual effects.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main render entry: draws parallax background, tiles, checkpoints, goal, player, HUD, state overlays, and touch controls |

## Architecture

### Package Structure

```
skyline_parkour_trials_2026/
├── main.mbt                          -- Entry point: window init, input polling, game loop
├── moon.pkg                          -- Root package config
└── internal/
    ├── types/
    │   ├── types.mbt                 -- Enums (GameState, TileKind, LoseReason), structs (Tile, Checkpoint, Player, Game), constructors
    │   ├── constants.mbt             -- Physics constants, stage timing, touch button rects, color functions
    │   ├── utils.mbt                 -- Math helpers, collision tests, pointer hit testing, timer formatting
    │   └── moon.pkg                  -- Types package config
    ├── game/
    │   ├── input.mbt                 -- Input polling for all 5 game states with keyboard, mouse, and touch support
    │   ├── logic.mbt                 -- Stage layouts (3 hardcoded stages), physics, collision, state transitions
    │   └── moon.pkg                  -- Game package config
    └── render/
        ├── render.mbt                -- All drawing: parallax background, tiles, player, HUD, overlays, touch controls
        └── moon.pkg                  -- Render package config
```

The code follows a clean three-layer architecture. `types` defines all data structures, enums, constants, and pure utility functions. `game` handles all mutable state manipulation including physics simulation, stage loading, collision resolution, and state transitions. `render` is a read-only consumer of game state for drawing.

### Data Flow

1. **Input**: The main loop polls mouse position and touch count into `Game` fields each frame. `update_game` then delegates to state-specific input handlers (`update_title_input`, `update_play_input`, `update_stage_clear_input`, `update_game_over_input`, `update_victory_input`) that map keyboard keys, mouse clicks, and touch regions to abstract input flags (`input_x`, `input_jump_press`, `input_jump_hold`, `input_climb_hold`, `input_next_press`, `input_restart_press`). Touch mode auto-enables when any touch is detected.

2. **Physics**: `update_hero_movement` applies horizontal acceleration/drag based on `input_x`, processes wall sliding (capped at 210 units/s fall speed when near a wall), wall climbing (limited by `wall_climb_t` stamina), and gravity. Jump logic checks the jump buffer against coyote time for ground jumps or the wall window for wall jumps. Variable-height jumps are achieved by applying extra gravity when the jump button is released early. Horizontal and vertical movement are resolved separately via `move_hero_x` and `move_hero_y`, each sweeping against all solid tiles.

3. **Collision**: `overlap_rect` performs AABB tests between the player and tiles. Horizontal collisions snap the player to the tile edge and set `wall_side` for wall jump detection. Vertical collisions snap the player to the surface and set `on_ground` or cancel upward velocity. Hazard tiles are checked separately via `hero_hits_hazard` which does not resolve but triggers a game over.

4. **Stage Progression**: Three stages are defined by `setup_stage_1/2/3` which push tiles, hazards, checkpoints, and a goal into the game arrays. `finish_stage` transitions to StageClear (or Victory for the final stage) and awards a time bonus. `load_stage` clears existing data, loads the target stage, and resets the hero position.

5. **Rendering**: `draw_frame` draws layers in order: three-layer parallax city background with animated glow, solid and hazard tiles with edge highlights, pulsing checkpoints, pulsing goal zone, player character with directional eye and speed trail, HUD panel with timer/stage/checkpoint info, and state-specific overlays (title, stage clear, game over, victory). Touch controls render only in Play state when touch mode is active.

### Key Design Patterns

- **Enum-based state machine**: Uses proper MoonBit enums (`GameState`, `TileKind`, `LoseReason`) with pattern matching instead of integer constants, providing type safety and exhaustiveness checking.
- **Separated input/logic/render**: Input polling and logic update are cleanly separated within `update_game` -- input is gathered first via a state-specific handler, then the state update runs against the abstracted input flags.
- **Advanced platformer physics**: Implements coyote time, jump buffering, variable-height jumps via gravity modulation, wall sliding with reduced fall speed, wall jumping with directional push, and stamina-limited wall climbing -- a comprehensive set of precision platformer mechanics.
- **Shared timer across stages**: Unlike per-stage timers, the countdown carries between stages with bonuses from checkpoints and stage clears, creating a cumulative speedrun feel.
- **Camera tracking**: A simple `camera_x` function positions the view at 34% of screen width behind the player, clamped to stage bounds, giving forward look-ahead for platforming.
- **Touch-first input abstraction**: `pointer_on_rect` unifies mouse clicks and multi-touch input, while edge detection via `touch_*_prev` flags prevents repeat triggers on hold.
- **Separate X/Y collision resolution**: `move_hero_x` and `move_hero_y` resolve collisions independently, preventing diagonal collision bugs and enabling reliable wall detection.

## Improvement & Refinement Plan

1. **Add a replay ghost system**: Record the player's position each frame during a run and replay it as a translucent ghost on subsequent attempts. This would let players race against their best time and identify where they lose speed.

2. **Implement momentum-based scoring**: Currently the only metric is time. Adding a speed bonus that accumulates when the player maintains high velocity would reward skillful movement chains and discourage overly cautious play.

3. **Add mid-stage respawn at checkpoints**: When the player dies after hitting a checkpoint, offer the option to respawn at the last checkpoint with a time penalty instead of restarting the entire run. This would reduce frustration on later stages.

4. **Create procedural stage generation**: The three hardcoded stages in `setup_stage_1/2/3` provide limited replayability. A procedural generator that creates valid platforming layouts from building blocks (wall-jump corridors, hazard gaps, checkpoint platforms) would extend longevity.

5. **Add visual particle effects**: The game currently has no particle system for landings, wall slides, or speed. Adding dust particles on landing (`move_hero_y` when `on_ground` transitions to true), sparks on wall contact (when `wall_side` is set), and wind streaks at high speed would significantly improve game feel.

6. **Implement stage select after victory**: After completing all three stages, allow the player to replay individual stages from a stage select screen. This would support focused practice on specific stages without replaying earlier ones.

7. **Add audio feedback for movement states**: Wall slides, landings, jumps, checkpoint pickups, and hazard deaths should each have distinct sounds. The wall climb mechanic in particular needs audio feedback since its time-limited nature (0.62s `wall_climb_t`) is not visually obvious.

8. **Separate stage data from logic**: The three `setup_stage_*` functions in `logic.mbt` contain hardcoded coordinate data mixed with logic. Extracting stage layouts into a `stages.mbt` data file or even a declarative format would make level editing cleaner and open the door to a level editor.
