# Portal Blackout Escape 2026

A stealth puzzle game on a dark grid-based map. Navigate through a blacked-out facility, collect energy cores to power a portal network, avoid patrolling drones, and reach the exit before time runs out.

## Build and Run

```bash
cd examples && moon build --target native portal_blackout_escape_2026/
cd examples && ./_build/native/debug/build/portal_blackout_escape_2026/portal_blackout_escape_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move on the grid (one tile at a time)
- **Space / E / J**: Action -- teleport when near a portal, or drop a flare EMP elsewhere
- **H**: Cycle through hint messages
- **R**: Restart
- **Escape**: Return to title
- **Mouse / Touch**: On-screen D-pad, action, hint, restart, and menu buttons

## How to Play

The facility is shrouded in darkness. Collect 6 of the 8 scattered energy cores to power the portal network and unlock the exit gate. Use two portal pads to teleport across the map. Drop flare EMPs to temporarily reveal the surrounding area and stun nearby drones. Drones patrol set routes and switch to hunting mode if they spot you. Getting caught costs a life (3 total). Manage your flare energy carefully and reach the exit within the 210-second time limit.

## Public API Reference

### Package `portal_blackout_escape_2026`

> Main entry point.

The `main` function initializes the window with MSAA, creates the `Game` state, and runs the frame loop: reading mouse/touch input, calling `@game.update_game`, then `@render.draw_frame`.

### Package `portal_blackout_escape_2026/internal/types`

> Core type definitions, constants, and utility functions shared across all packages.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Actor` | `x`, `y`, `fx`, `fy`, `t`, `moving` | Grid entity with integer tile coords and float interpolation fields for smooth visual movement. |
| `Drone` | `active`, `body`, `mode`, `move_cd`, `stun_t`, `patrol_min/max`, `seed` | Patrol drone with AI mode (`drone_patrol`, `drone_hunt`, `drone_stunned`), movement cooldown, and LCG random seed. |
| `Core` | `active`, `x`, `y`, `kind` | Collectible energy core at a fixed tile position with a visual kind id. |
| `Flare` | `active`, `x`, `y`, `t` | Deployed flare beacon with remaining lifetime `t`. |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | Visual particle entry for sparks and smoke effects. |
| `Game` | `map`, `player`, `drones`, `cores`, `flares`, `particles`, `state`, `lives`, `score`, … | Complete mutable run state including the tile map array, all entity pools, counters, timers, and input state. |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Actor::new` | `() -> Actor` | Creates a player actor at the configured start tile. |
| `Drone::new` | `() -> Drone` | Creates an inactive drone entry. |
| `Core::new` | `() -> Core` | Creates an inactive core entry. |
| `Flare::new` | `() -> Flare` | Creates an inactive flare entry. |
| `Particle::new` | `() -> Particle` | Creates an inactive particle entry. |
| `Game::new` | `() -> Game` | Creates a fully initialized game state with all pools allocated. |
| `mini` | `(Int, Int) -> Int` | Returns the smaller of two integers. |
| `maxi` | `(Int, Int) -> Int` | Returns the larger of two integers. |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer to `[lo, hi]`. |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to `[lo, hi]`. |
| `absi` | `(Int) -> Int` | Returns absolute value of an integer. |
| `lerpf` | `(Float, Float, Float) -> Float` | Linearly interpolates between `a` and `b` by factor `t`. |
| `sinf` | `(Float) -> Float` | Computes `sin(v)` as Float. |
| `randf` | `(Float, Float) -> Float` | Returns a pseudo-random float in `[lo, hi]`. |
| `manhattan` | `(Int, Int, Int, Int) -> Int` | Computes Manhattan distance between two grid tiles. |
| `board_px` | `(Int) -> Int` | Converts grid X to board pixel X (top-left corner). |
| `board_py` | `(Int) -> Int` | Converts grid Y to board pixel Y (top-left corner). |
| `cell_center_x` | `(Float) -> Int` | Converts float grid X to pixel X at cell center. |
| `cell_center_y` | `(Float) -> Int` | Converts float grid Y to pixel Y at cell center. |
| `start_button_rect` | `() -> (Int,Int,Int,Int)` | Returns the title START button rectangle. |
| `retry_button_rect` | `() -> (Int,Int,Int,Int)` | Returns the result RUN AGAIN button rectangle. |
| `btn_left/right/up/down` | `() -> (Int,Int,Int,Int)` | Return touch D-pad button rectangles. |
| `btn_action` | `() -> (Int,Int,Int,Int)` | Returns the action button rectangle. |
| `btn_hint/restart/menu` | `() -> (Int,Int,Int,Int)` | Return shortcut button rectangles. |
| `hint_text` | `(Int) -> String` | Returns one of four rotating hint messages by index. |
| `point_in_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Returns true if a float point is inside a rectangle. |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Returns true if mouse hold or any touch point is inside a rectangle. |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1780` | Window width in pixels. |
| `screen_h` | `Int` | `1000` | Window height in pixels. |
| `target_fps` | `Int` | `120` | Target simulation frame rate. |
| `board_x0` | `Int` | `28` | Left edge of the grid board. |
| `board_y0` | `Int` | `86` | Top edge of the grid board. |
| `cell` | `Int` | `60` | Grid cell size in pixels. |
| `grid_w` | `Int` | `23` | Grid width in tiles. |
| `grid_h` | `Int` | `13` | Grid height in tiles. |
| `state_title` | `Int` | `0` | Title screen state id. |
| `state_play` | `Int` | `1` | Active gameplay state id. |
| `state_result` | `Int` | `2` | Result screen state id. |
| `tile_wall` | `Int` | `0` | Impassable wall tile. |
| `tile_floor` | `Int` | `1` | Walkable floor tile. |
| `tile_exit` | `Int` | `2` | Exit gate tile (blocked until portal online). |
| `drone_patrol` | `Int` | `0` | Drone patrol mode id. |
| `drone_hunt` | `Int` | `1` | Drone hunt mode id. |
| `drone_stunned` | `Int` | `2` | Drone stunned mode id. |
| `max_drones` | `Int` | `5` | Drone pool size. |
| `max_cores` | `Int` | `8` | Core pool size. |
| `max_flares` | `Int` | `6` | Flare pool size. |
| `max_particles` | `Int` | `420` | Particle pool size. |
| `core_need` | `Int` | `6` | Cores required to activate the exit. |
| `max_lives` | `Int` | `3` | Starting life count. |
| `round_time_limit` | `Float` | `210.0` | Time limit per run in seconds. |
| `start_x/y` | `Int` | `2, 11` | Player start tile. |
| `exit_x/y` | `Int` | `21, 1` | Exit gate tile. |
| `portal_ax/ay` | `Int` | `4, 10` | Portal A tile. |
| `portal_bx/by` | `Int` | `18, 3` | Portal B tile. |
| `player_move_t` | `Float` | `0.105` | Player tile-move duration in seconds. |
| `drone_move_t` | `Float` | `0.150` | Drone tile-move duration in seconds. |
| `flare_ttl` | `Float` | `4.2` | Flare active lifetime in seconds. |
| `flare_cost` | `Float` | `34.0` | Energy cost per flare deployment. |
| `flare_stun_t` | `Float` | `2.3` | Stun duration applied by a flare. |
| `score_core` | `Int` | `180` | Points per collected core. |
| `score_teleport` | `Int` | `90` | Points per portal jump. |
| `score_stun` | `Int` | `60` | Points per stunned drone. |
| `score_win` | `Int` | `1100` | Bonus points on successful escape. |

### Package `portal_blackout_escape_2026/internal/game`

> Game logic, input handling, and update systems.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `title_hover` | `(Game) -> Bool` | Returns true if pointer is over the title start button. |
| `retry_hover` | `(Game) -> Bool` | Returns true if pointer is over the result retry button. |
| `update_title_input` | `(Game) -> Unit` | Handles start-screen keyboard/mouse/touch input. |
| `update_result_input` | `(Game) -> Unit` | Handles result-screen keyboard/mouse/touch input. |
| `update_play_input` | `(Game) -> Unit` | Reads movement, action, hint, restart, and menu input during play. |
| `idx` | `(Int, Int) -> Int` | Converts grid coords to flat map index. |
| `in_bounds` | `(Int, Int) -> Bool` | Bounds check for grid coordinates. |
| `tile_at` | `(Game, Int, Int) -> Int` | Returns tile type, `tile_wall` for out-of-bounds. |
| `set_tile` | `(Game, Int, Int, Int) -> Unit` | Writes tile type; ignores out-of-bounds. |
| `set_msg` | `(Game, String, Float) -> Unit` | Sets HUD message with display duration. |
| `actor_place` | `(Actor, Int, Int) -> Unit` | Instantly places actor at a tile. |
| `actor_start_move` | `(Actor, Int, Int) -> Unit` | Starts smooth tile movement. |
| `actor_tick` | `(Actor, Float, Float) -> Unit` | Advances interpolated float position each frame. |
| `clear_particles` | `(Game) -> Unit` | Resets all particles. |
| `emit_particle` | `(Game, Float, Float, Float, Float, Float, Float, Int) -> Unit` | Activates a free particle slot. |
| `burst` | `(Game, Float, Float, Int, Int) -> Unit` | Emits N particles around a pixel position. |
| `update_particles` | `(Game, Float) -> Unit` | Advances particle physics and expires old particles. |
| `flare_cover_at` | `(Game, Int, Int) -> Bool` | Checks if a flare hides a position from drone detection. |
| `core_index_at` | `(Game, Int, Int) -> Int` | Finds a core at a tile, or -1. |
| `drone_index_at` | `(Game, Int, Int, Int) -> Int` | Finds a drone at a tile excluding one index, or -1. |
| `build_map` | `(Game) -> Unit` | Generates the facility tile map. |
| `init_cores` | `(Game) -> Unit` | Places 8 energy cores at fixed positions. |
| `init_drones` | `(Game) -> Unit` | Places 5 patrol drones at fixed positions. |
| `clear_flares` | `(Game) -> Unit` | Deactivates all flares. |
| `start_run` | `(Game) -> Unit` | Full game state reset, map build, and transition to play. |
| `go_title` | `(Game) -> Unit` | Transitions to title screen. |
| `finish_run` | `(Game, Bool, String) -> Unit` | Ends run, records outcome, applies score bonus. |
| `cycle_hint` | `(Game) -> Unit` | Advances hint index and shows next message. |
| `blocked_by_map` | `(Game, Int, Int) -> Bool` | Returns true for walls and locked exit tiles. |
| `blocked_for_actor` | `(Game, Int, Int) -> Bool` | Player passability check (delegates to `blocked_by_map`). |
| `try_move_player` | `(Game, Int, Int) -> Bool` | Attempts one-tile player move. |
| `collect_core` | `(Game) -> Unit` | Collects core at player tile and activates portal when threshold reached. |
| `line_of_sight` | `(Game, Int, Int, Int, Int) -> Bool` | Axis-aligned ray-cast for drone vision. |
| `drone_seed_next` | `(Int) -> Int` | LCG step for deterministic drone randomness. |
| `blocked_for_drone` | `(Game, Int, Int, Int) -> Bool` | Drone passability check (walls, exit, occupied tiles). |
| `choose_drone_step` | `(Game, Int) -> (Int, Int)` | AI decision: hunt or patrol step for a drone. |
| `update_drones` | `(Game, Float) -> Unit` | Ticks all drone movement, stun, and AI each frame. |
| `update_flares` | `(Game, Float) -> Unit` | Ticks flare lifetimes and emits smoke particles. |
| `deploy_flare` | `(Game) -> Bool` | Deploys a flare, stunning nearby drones. |
| `try_portal` | `(Game) -> Bool` | Teleports player between portals A and B. |
| `handle_player_hit` | `(Game) -> Unit` | Handles drone collision with player. |
| `update_timers` | `(Game, Float) -> Unit` | Decrements all per-frame timer fields. |
| `update_title` | `(Game, Float) -> Unit` | Title screen frame update. |
| `update_result` | `(Game, Float) -> Unit` | Result screen frame update. |
| `update_play` | `(Game, Float) -> Unit` | Full gameplay frame update. |
| `update_game` | `(Game, Float) -> Unit` | **Public.** Routes input and update by current state; resets `action_pressed` at end of frame. |

### Package `portal_blackout_escape_2026/internal/render`

> Rendering and drawing routines.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `shake_dx` | `(Game) -> Int` | Random horizontal shake offset when shake timer active. |
| `shake_dy` | `(Game) -> Int` | Random vertical shake offset when shake timer active. |
| `pulse` | `(Game, Float) -> Float` | Oscillating `[0,1]` value at frequency `f` Hz. |
| `core_color` | `(Int) -> Color` | Color for a core by kind id. |
| `drone_color` | `(Int) -> Color` | Patrol-mode color for a drone by color id. |
| `draw_background` | `(Game) -> Unit` | Draws gradient background and ambient glows. |
| `draw_tiles` | `(Game, Int, Int) -> Unit` | Draws all grid tiles with shading and grid lines. |
| `draw_portals` | `(Game, Int, Int) -> Unit` | Draws portal pads with pulsing glow rings. |
| `draw_cores` | `(Game, Int, Int) -> Unit` | Draws active energy cores. |
| `draw_flares` | `(Game, Int, Int) -> Unit` | Draws active flare beacons. |
| `draw_drones` | `(Game, Int, Int) -> Unit` | Draws all active drones with mode-colored bodies. |
| `draw_player` | `(Game, Int, Int) -> Unit` | Draws the player sprite with damage blink. |
| `draw_particles` | `(Game, Int, Int) -> Unit` | Draws all active particles. |
| `light_alpha` | `(Game, Int, Int) -> Int` | Computes blackout overlay alpha for a tile. |
| `draw_blackout` | `(Game, Int, Int) -> Unit` | Overlays darkness on each interior tile. |
| `draw_board` | `(Game, Int, Int) -> Unit` | Draws all board layers in order. |
| `draw_touch_button` | `(Game, (Int,Int,Int,Int), String, Color, Color) -> Unit` | Draws a labeled touch button with active highlight. |
| `draw_touch_controls` | `(Game) -> Unit` | Draws D-pad, action, and shortcut buttons. |
| `draw_panel` | `(Game) -> Unit` | Draws the side HUD panel. |
| `draw_title_overlay` | `(Game) -> Unit` | Draws the title screen overlay. |
| `draw_result_overlay` | `(Game) -> Unit` | Draws the result screen overlay. |
| `draw_frame` | `(Game) -> Unit` | **Public.** Draws one complete frame. |

## Architecture

### Package Structure

```
portal_blackout_escape_2026/
├── main.mbt                  — Window init, game loop, input polling
└── internal/
    ├── types/
    │   ├── constants.mbt     — All numeric constants and layout values
    │   ├── types.mbt         — Struct definitions and constructor functions
    │   └── utils.mbt         — Math helpers, coordinate conversion, button rects, hint text, pointer hit test
    ├── game/
    │   ├── input.mbt         — State-specific input handlers (title, result, play)
    │   └── logic.mbt         — Map generation, actor movement, AI, flares, portals, scoring, state transitions
    └── render/
        └── render.mbt        — All drawing: background, tiles, portals, entities, particles, blackout, HUD, overlays
```

**Data flow:** Each frame `main` polls raw Raylib input into `Game` fields (`mouse_x`, `mouse_hold`, `touch_count`), then calls `@game.update_game` which routes to the appropriate input handler and update function. The update functions mutate `Game` in place. `@render.draw_frame` then reads the same `Game` snapshot to produce the frame. No data is passed between packages except the single mutable `Game` reference.

**Key design patterns:**
- **Grid-interpolated movement**: Actors hold both integer tile coords and float `fx`/`fy` for smooth sub-tile rendering. `actor_tick` advances `t` from 0 to 1 per tile step.
- **Pool-based allocation**: All entities (drones, cores, flares, particles) use fixed-size arrays with `active` flags, avoiding heap allocation during gameplay.
- **Blackout visibility**: A per-tile Manhattan distance check against the player and all active flares determines the darkness overlay alpha (20–172), creating the near-only-local-vision effect.
- **Drone AI**: Drones use line-of-sight and Manhattan distance to switch between patrol and hunt modes. Patrol follows a bounce pattern on one axis within `patrol_min`/`patrol_max` bounds; hunt uses greedy best-neighbor selection.

## Improvement & Refinement Plan

1. **Diagonal movement**: Allow WASD diagonal input so players can move diagonally on the grid, adding a layer of tactical maneuvering.
2. **Multiple difficulty levels**: Increase drone count, patrol speed, or hunt range on harder settings, and reduce the time limit.
3. **Flare energy regen indicator**: Add a visible recharge bar that pulses when a full flare is ready, making energy management less opaque.
4. **Drone alert visual**: Show a "!" icon above a drone when it switches from patrol to hunt mode, giving the player a clear threat cue.
5. **Partial darkness reveal with flares**: Currently flares use a fixed Manhattan-2 reveal radius. Replacing this with a line-of-sight check would make flare placement more strategic and realistic.
6. **Persistent best score display on title**: Show the all-time best score on the title screen so returning players have an immediate challenge target.
7. **Sound effects**: Add audio feedback for core collection, portal teleportation, flare deployment, drone stun, and player hit using `@raylib.play_sound`.
