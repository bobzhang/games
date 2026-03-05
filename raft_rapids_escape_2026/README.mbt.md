# Raft Rapids Escape 2026

A top-down river survival game where you steer a small raft through 180 seconds of increasingly dangerous rapids. The river is alive with sinusoidal water currents that push both the raft and obstacles laterally, forcing constant course corrections. Rocks, drifting logs, and floating mines scroll down the play area while coins, fuel canisters, shields, and repair kits provide the resources needed to survive.

The core loop is pure evasion and resource management: fuel drains continuously and faster when boosting, collisions cost lives and fuel, and running out of either ends the run. Coins build a combo multiplier (up to 15x) that decays after 2.2 seconds, rewarding aggressive collection. A hint system analyzes the obstacle field and highlights the safest lane or the nearest valuable pickup, at a small score penalty. Difficulty scales through 10 levels determined by elapsed time, with obstacles spawning more frequently and moving faster at higher levels.

The game features a split-screen layout with the river play area on the left and a stats/control panel on the right, plus on-screen touch buttons for mobile play including a directional pad, boost, hint, and restart.

## Build and Run

```bash
moon build --target native raft_rapids_escape_2026/
./_build/native/debug/build/raft_rapids_escape_2026/raft_rapids_escape_2026.exe
```

## Controls

- **W / Up Arrow**: Steer raft up (against current)
- **S / Down Arrow**: Steer raft down (with current)
- **A / Left Arrow**: Steer raft left
- **D / Right Arrow**: Steer raft right
- **Left Shift / Right Shift / J**: Activate boost (1.7x speed, burns fuel faster)
- **H**: Use a navigation hint (3 per run, costs 6 score)
- **R**: Restart run
- **Escape**: Return to title screen
- **Enter / Space**: Start expedition or retry from title/result screen
- **Touch Buttons**: On-screen D-pad (L/R/U/D), BOOST, HINT, and RST buttons on the right panel

## How to Play

Press Enter, Space, click, or tap the START EXPEDITION button to begin. You start with 3 lives, 100 fuel, and 180 seconds on the clock.

**Obstacles** scroll down the river at speeds that increase with level (level = 1 + game_time/24, capped at 10). Rocks deal 1 life and 8 fuel damage; logs deal 1 life and 11 fuel; mines deal 2 lives and 18 fuel. A shield pickup absorbs hits for 7 seconds (mines drain 1.6s of shield, others drain 0.9s). Hitting a river bank wall costs 1.8 fuel and triggers a bounce.

**Pickups** spawn every 1.55 seconds. Coins (58% chance) award 16 + combo*4 score and build the combo counter. Fuel canisters (22%) restore 30 fuel. Shield pickups (12%) grant 7 seconds of shield. Repair kits (8%) restore 1 life (or convert to 50 score + 10 fuel if at max 5 lives).

**Fuel** drains at 3.2 + level*0.19 per second normally, or 11.5 + level*0.42 per second while boosting. Running out of fuel ends the run. Boosting multiplies raft speed by 1.65x and spawns water splash particles.

**Water currents** are computed from sinusoidal functions that vary with position and time, affecting both the raft and all objects. The `water_current_x` and `water_current_y` functions create unpredictable lateral and forward forces that strengthen with level.

**Hints** (3 per run) analyze the obstacle field across 5 virtual lanes and highlight the safest position, or point toward the nearest fuel/shield pickup if one is ahead of the raft.

Survive all 180 seconds to see "MISSION COMPLETE". Lose all lives or run out of fuel for "MISSION FAILED". Distance-based scoring adds 1 point per 120-meter band crossed. The best score is tracked across runs within the session.

## Public API Reference

### Package `raft_rapids_escape_2026`

> Main entry point.

The main package contains only the `main` function (not pub), which initializes a 1720x980 window with 4x MSAA at 120 FPS, creates a `Game` instance, and runs the update-draw loop with delta time capped at 0.04s.

### Package `raft_rapids_escape_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Obstacle` | `active`, `x`, `y`, `w`, `h`, `vx`, `vy`, `kind`, `phase` | A river hazard (rock, log, or mine) in the object pool |
| `Pickup` | `active`, `x`, `y`, `kind`, `phase` | A collectible item (coin, fuel, shield, repair) in the object pool |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | A visual particle for splash/impact effects |
| `Game` | `obstacles`, `pickups`, `particles`, `raft_x`, `raft_y`, `lives`, `fuel`, `shield_t`, `score`, `level`, `combo`, `game_t`, `state`, `win`, ... | Main game state container with all pools, raft state, resources, and input |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1720` | Window width |
| `screen_h` | `Int` | `980` | Window height |
| `target_fps` | `Int` | `120` | Target frame rate |
| `state_title` | `Int` | `0` | Title screen state |
| `state_play` | `Int` | `1` | Active gameplay state |
| `state_result` | `Int` | `2` | Result/game-over state |
| `obstacle_rock` | `Int` | `0` | Rock obstacle type |
| `obstacle_log` | `Int` | `1` | Log obstacle type |
| `obstacle_mine` | `Int` | `2` | Mine obstacle type |
| `pickup_coin` | `Int` | `0` | Coin pickup type |
| `pickup_fuel` | `Int` | `1` | Fuel canister pickup type |
| `pickup_shield` | `Int` | `2` | Shield bubble pickup type |
| `pickup_repair` | `Int` | `3` | Repair kit pickup type |
| `max_obstacles` | `Int` | `120` | Obstacle pool capacity |
| `max_pickups` | `Int` | `80` | Pickup pool capacity |
| `max_particles` | `Int` | `1400` | Particle pool capacity |
| `world_x0` | `Int` | `24` | Play area left edge |
| `world_y0` | `Int` | `20` | Play area top edge |
| `world_w` | `Int` | `1120` | Play area width |
| `world_h` | `Int` | `940` | Play area height |
| `panel_x0` | `Int` | `world_x0 + world_w + 24` | Right panel left edge |
| `panel_w` | `Int` | `screen_w - panel_x0 - 24` | Right panel width |
| `raft_r` | `Float` | `26.0` | Raft collision radius |
| `run_time_goal` | `Float` | `180.0` | Seconds to survive for victory |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Obstacle::new` | `() -> Obstacle` | Creates a default inactive obstacle |
| `Pickup::new` | `() -> Pickup` | Creates a default inactive pickup |
| `Particle::new` | `() -> Particle` | Creates a default inactive particle |
| `Game::new` | `() -> Game` | Creates a new game with pre-allocated pools and default state |
| `mini` | `(Int, Int) -> Int` | Returns the smaller of two integers |
| `maxi` | `(Int, Int) -> Int` | Returns the larger of two integers |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between lo and hi |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between lo and hi |
| `minf` | `(Float, Float) -> Float` | Returns the smaller of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns the larger of two floats |
| `absf` | `(Float) -> Float` | Absolute value of a float |
| `sinf` | `(Float) -> Float` | Sine function wrapping `@math.sin` |
| `cosf` | `(Float) -> Float` | Cosine function wrapping `@math.cos` |
| `randf` | `(Float, Float) -> Float` | Random float in [lo, hi] via raylib RNG |
| `world_left` | `() -> Float` | Play area left boundary as float |
| `world_right` | `() -> Float` | Play area right boundary as float |
| `world_top` | `() -> Float` | Play area top boundary as float |
| `world_bottom` | `() -> Float` | Play area bottom boundary as float |
| `point_dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two 2D points |
| `water_current_x` | `(Game, Float) -> Float` | Computes lateral water current force at a given Y position |
| `water_current_y` | `(Game, Float) -> Float` | Computes vertical water current force at a given X position |
| `set_msg` | `(Game, String, Float) -> Unit` | Sets a timed status message for display |
| `point_in_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside an integer rectangle |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Tests if mouse or any touch point is inside a rectangle |
| `start_button_rect` | `() -> (Int, Int, Int, Int)` | Title screen start button bounds |
| `retry_button_rect` | `() -> (Int, Int, Int, Int)` | Result screen retry button bounds |
| `btn_left` | `() -> (Int, Int, Int, Int)` | Touch D-pad left button bounds |
| `btn_right` | `() -> (Int, Int, Int, Int)` | Touch D-pad right button bounds |
| `btn_up` | `() -> (Int, Int, Int, Int)` | Touch D-pad up button bounds |
| `btn_down` | `() -> (Int, Int, Int, Int)` | Touch D-pad down button bounds |
| `btn_boost` | `() -> (Int, Int, Int, Int)` | Touch boost button bounds |
| `btn_restart` | `() -> (Int, Int, Int, Int)` | Touch restart button bounds |
| `btn_hint` | `() -> (Int, Int, Int, Int)` | Touch hint button bounds |

### Package `raft_rapids_escape_2026/internal/game`

> Game logic, input handling, spawning, collision, and state transitions.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main update entry point: reads input, dispatches state-specific input and logic |

All other functions in this package are private:

| Function | Description |
|----------|-------------|
| `clear_particles` | Deactivates all particles in the pool |
| `clear_world` | Deactivates all obstacles and pickups |
| `emit_particle` | Finds an inactive particle slot and activates it with given parameters |
| `splash` | Spawns multiple particles in a radial burst at a position |
| `update_particles` | Advances particle positions, applies drag and gravity, removes expired |
| `reset_raft` | Resets raft to center-bottom of play area with slight upward velocity |
| `start_run` | Clears world, resets all state, begins a new run from level 1 |
| `finish_run` | Transitions to result state, records best score, spawns celebration/failure particles |
| `circle_rect_hit` | Circle-vs-rectangle collision test for raft-obstacle detection |
| `obstacle_hit_cost` | Returns life cost for an obstacle kind (mine=2, others=1) |
| `obstacle_hit_fuel` | Returns fuel cost for an obstacle kind (mine=18, log=11, rock=8) |
| `hurt_player` | Applies damage from obstacle, checks shield absorption, triggers game over if lives depleted |
| `pickup_radius` | Returns collision radius for a pickup kind |
| `collect_pickup` | Processes pickup collection: awards score/fuel/shield/lives based on kind |
| `spawn_obstacle` | Creates a new obstacle at a random position above the play area with kind-dependent size and speed |
| `spawn_pickup` | Creates a new pickup at a random position above the play area with weighted random kind |
| `update_raft` | Applies movement input, water current forces, drag, boost, wall bouncing, and boundary clamping |
| `update_obstacles` | Moves obstacles with sway and current influence, checks raft collisions, awards dodge score |
| `update_pickups` | Moves pickups with current, checks raft collection radius |
| `use_hint` | Analyzes obstacle field across 5 lanes, finds safest position or nearest valuable pickup, costs 6 score |
| `update_play` | Orchestrates all play-state systems: timers, spawning, physics, collision, fuel drain, win/lose checks |
| `title_hover` | Checks if pointer is over the start button |
| `result_hover` | Checks if pointer is over the retry button |
| `update_title_input` | Reads start inputs on the title screen |
| `update_result_input` | Reads retry inputs on the result screen |
| `update_play_input` | Reads movement, boost, hint, restart, and escape inputs during gameplay |

### Package `raft_rapids_escape_2026/internal/render`

> Rendering, visual effects, and UI drawing.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main render entry point: draws background, world, objects, panel, overlays |

All other functions in this package are private:

| Function | Description |
|----------|-------------|
| `ui_wave` | Computes a sinusoidal animation value for UI effects |
| `shake_offset_x` | Random horizontal screen shake when shake timer is active |
| `shake_offset_y` | Random vertical screen shake when shake timer is active |
| `draw_background` | Renders ambient circles and horizontal stripe atmosphere |
| `draw_world_back` | Draws the river play area with animated wave lines and bank edges |
| `draw_currents` | Visualizes water current vectors as small arrows across the play area |
| `obstacle_color` | Returns display color for each obstacle kind |
| `draw_obstacle` | Renders a single obstacle (rock=rectangle+circle, log=rectangle+rings, mine=circle+spikes) |
| `pickup_color` | Returns display color for each pickup kind |
| `pickup_radius` | Returns visual radius for each pickup kind |
| `draw_pickup` | Renders a pulsing pickup with kind-specific inner detail |
| `draw_particles` | Renders all active particles with life-based alpha |
| `draw_raft` | Draws the raft with hull, prow triangle, tilt based on velocity, boost flame, and shield ring |
| `draw_hint` | Draws the hint beacon circle and line from raft to target |
| `draw_progress_bar` | Reusable progress bar with fill color, background, and border |
| `draw_panel` | Draws the right-side stats panel: title, score, lives, level, distance, fuel/shield/time bars, combo, hints, controls text |
| `draw_touch_button` | Draws a single touch button with hover highlight |
| `draw_touch_controls` | Draws all touch buttons (D-pad, boost, hint, restart) during play |
| `draw_title_overlay` | Renders the title screen with instructions and start button |
| `draw_result_overlay` | Renders the result screen with score summary and retry button |
| `draw_msg` | Draws the timed status message banner at the top of the play area |

## Architecture

### Package Structure

```
raft_rapids_escape_2026/
├── main.mbt              — Entry point: window init, game loop
├── moon.pkg              — Package config, imports types/game/render
└── internal/
    ├── types/
    │   ├── types.mbt     — Core structs: Obstacle, Pickup, Particle, Game
    │   ├── constants.mbt — Screen dimensions, pool sizes, state/kind constants, button rects
    │   ├── utils.mbt     — Math utilities, water current functions, hit testing
    │   └── moon.pkg
    ├── game/
    │   ├── logic.mbt     — Spawning, physics, collision, scoring, state transitions
    │   ├── input.mbt     — Keyboard/mouse/touch input per state
    │   └── moon.pkg
    └── render/
        ├── render.mbt    — All drawing: world, objects, raft, panel, overlays, touch UI
        └── moon.pkg
```

The types package defines all data structures and stateless utilities including the water current simulation. The game package handles all state mutation: input processing, raft physics, obstacle/pickup spawning and movement, collision detection, resource management, and state transitions. The render package is read-only, drawing the game state each frame. The main package wires them together.

### Data Flow

1. **Input Collection**: `update_game` reads raw mouse/touch state, then dispatches to state-specific input handlers. During play, `update_play_input` converts keyboard and touch button state into `move_x`/`move_y` direction values and `boost_on` flag on the `Game` struct.

2. **Physics and Simulation**: `update_play` advances all timers, then calls `update_raft` (applies movement with water currents and drag), `update_obstacles` (moves obstacles with sway and current, checks collisions), and `update_pickups` (moves pickups, checks collection). Fuel drains continuously. Level increases every 24 seconds.

3. **Rendering**: `draw_frame` computes shake offset, then layers: background atmosphere, river play area with current visualization, obstacles, pickups, hint beacon, particles, raft, side panel with stats/bars, touch controls, status message, and state overlays.

### Key Design Patterns

- **Object Pool Pattern**: Obstacles (120), pickups (80), and particles (1400) use pre-allocated arrays with `active` flags. `emit_particle` scans for the first inactive slot. `spawn_obstacle` and `spawn_pickup` do the same.

- **Water Current Simulation**: The `water_current_x` and `water_current_y` functions use layered sinusoidal functions with time and position inputs to create complex, ever-changing current patterns. These forces affect both the raft and all floating objects, creating a shared physics environment.

- **Hint AI System**: The `use_hint` function divides the play area into 5 virtual lanes and scores each based on nearby obstacle density, with mines weighted higher. It also scans for fuel/shield pickups ahead of the raft. This provides strategic guidance without playing for the player.

- **Circle-Rectangle Collision**: The `circle_rect_hit` function uses nearest-point-on-rect distance testing for accurate raft (circle) vs obstacle (rectangle) collisions.

- **Split-Screen Layout**: The game dedicates the left 1120px to the river play area and the right panel to stats, progress bars, and touch controls, keeping gameplay and information cleanly separated.

- **Delta-Time with Cap**: Frame time is capped at 0.04s to prevent physics instabilities, while targeting 120 FPS.

## Improvement & Refinement Plan

1. **Replace Integer State/Kind Constants with Enums**: Game state (`state_title`, `state_play`, `state_result`), obstacle kinds, and pickup kinds are all plain integers in `constants.mbt`. Proper enums would enable exhaustive matching and prevent invalid values.

2. **Deduplicate `pickup_radius`**: The `pickup_radius` function appears in both `logic.mbt` (game package) and `render.mbt` (render package) with identical logic. Moving it to `utils.mbt` in the types package would eliminate this duplication.

3. **Add Sound Effects**: The audio device is initialized (`init_audio_device`) in `main.mbt` but no sounds are played. Adding splash, collision, pickup, and boost audio would greatly enhance immersion.

4. **Improve Obstacle Eviction**: When the obstacle pool is full, `spawn_obstacle` silently fails (returns false). Adding eviction of the farthest-past-screen obstacle would maintain obstacle density even under heavy spawning at higher levels.

5. **Add Visual Current Strength Indicator**: While `draw_currents` shows current direction arrows, the strength is hard to gauge. Color-coding or scaling the arrows based on magnitude would help players anticipate drift.

6. **Persist Best Score**: The `best_score` field resets on application restart. File-based persistence would let players track progress across sessions.

7. **Balance Fuel Economy at High Levels**: Fuel drain increases linearly with level (`3.2 + level*0.19` base, `11.5 + level*0.42` boosting), but fuel pickup frequency stays constant at 1.55s intervals. At level 10, sustained boosting may be nearly impossible even with perfect fuel collection. A slight increase in fuel pickup value or frequency at higher levels would maintain the viability of boosting.

8. **Add Obstacle Variety**: Currently only 3 obstacle types exist. Adding whirlpools (area-of-effect pull), rapids sections (speed zones), or breakable debris would increase strategic depth at higher levels.
