# Clockwork Train Heist 2026

A tile-based stealth puzzle game set on a moving train. Navigate through train cars, avoid patrolling guards, collect loot, and escape before time runs out.

## Build and Run

```bash
moon build --target native raylib_clockwork_train_heist_2026/
./_build/native/debug/build/raylib_clockwork_train_heist_2026/raylib_clockwork_train_heist_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move one tile at a time
- **Space / E**: Smoke pulse -- stuns nearby guards and blocks vision
- **Touch**: On-screen D-pad and action button
- **H**: Cycle through hint tips

## How to Play

- Collect 6 loot pieces (blueprints, keycards, gold) scattered across the train cars to unlock the escape cable.
- Guards patrol corridors and will chase you if they spot you. Use walls and smoke to break line of sight.
- Smoke pulses stun guards and cost smoke energy, which regenerates over time.
- Reach the exit tile after collecting enough loot to win.
- You have 3 lives and a 210-second time limit per run.

## Public API Reference

### Package `tonyfettes/raylib-examples/raylib_clockwork_train_heist_2026`
> Top-level entry point. Creates a `Game` value, then drives the raylib window loop by calling `update_game` and `draw_frame` every frame.

### Package `tonyfettes/raylib-examples/raylib_clockwork_train_heist_2026/internal/types`
> Shared data definitions: all structs, enums, constants, board geometry helpers, button hit areas, and utility functions used by every other package.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `Result` | High-level flow state for the game loop. |
| `TileKind` | `Wall`, `Floor`, `Door`, `Exit` | Classification for each cell in the 27x13 board map. |
| `GuardMode` | `Patrol`, `Hunt`, `Stunned` | AI behavior state for each guard. |
| `LootKind` | `Blueprint`, `Keycard`, `Gold` | Category of a collectible loot item. |
| `ParticleKind` | `Spark`, `Glitter`, `Smoke` | Visual effect category for particle rendering. |

#### Structs

| Struct | Key Fields | Description |
|--------|------------|-------------|
| `Game` | `map`, `guards`, `loots`, `smokes`, `particles`, `state`, `player`, `lives`, `score`, `loot_taken`, `vault_open`, `time_left`, `smoke_energy`, `msg`, `flash_t`, `shake_t` | Complete session state; all entity arrays are pre-allocated pools. |
| `Actor` | `x`, `y`, `from_x`, `from_y`, `to_x`, `to_y`, `fx`, `fy`, `t`, `moving` | Grid actor with sub-cell interpolation for smooth movement animation. |
| `Guard` | `active`, `body(Actor)`, `mode`, `move_cd`, `stun_t`, `dir_x`, `dir_y`, `patrol_min`, `patrol_max`, `seed`, `alert_t`, `color_id` | Guard entity including patrol range, AI mode, stun timer, and visual color. |
| `Loot` | `active`, `x`, `y`, `kind`, `value` | Collectible item placed at a fixed grid cell. |
| `Smoke` | `active`, `x`, `y`, `t` | Deployed smoke cloud with a lifetime countdown. |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind(ParticleKind)` | Short-lived visual particle with velocity and typed appearance. |

#### Constructor Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Game::new` | `() -> Game` | Creates a fully initialized game with all pools pre-allocated and initial values set. |
| `Actor::new` | `() -> Actor` | Creates an actor placed at `(start_x, start_y)` with movement complete. |
| `Guard::new` | `() -> Guard` | Creates an inactive guard slot with default patrol parameters. |
| `Loot::new` | `() -> Loot` | Creates an inactive loot slot defaulting to `Gold`. |
| `Smoke::new` | `() -> Smoke` | Creates an inactive smoke slot. |
| `Particle::new` | `() -> Particle` | Creates an inactive particle slot. |

#### Board Geometry Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `board_px` | `(Int) -> Int` | Converts a board column index to the left edge screen x-coordinate. |
| `board_py` | `(Int) -> Int` | Converts a board row index to the top edge screen y-coordinate. |
| `cell_center_x` | `(Float) -> Int` | Converts an interpolated fractional column position to the pixel center x. |
| `cell_center_y` | `(Float) -> Int` | Converts an interpolated fractional row position to the pixel center y. |

#### Button and UI Hit-Area Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `start_button_rect` | `() -> (Int, Int, Int, Int)` | Title-screen start button rectangle in the right panel. |
| `retry_button_rect` | `() -> (Int, Int, Int, Int)` | Result-screen retry button rectangle in the right panel. |
| `btn_left` | `() -> (Int, Int, Int, Int)` | On-screen left D-pad button (76x76 px). |
| `btn_right` | `() -> (Int, Int, Int, Int)` | On-screen right D-pad button (76x76 px). |
| `btn_up` | `() -> (Int, Int, Int, Int)` | On-screen up D-pad button (76x76 px). |
| `btn_down` | `() -> (Int, Int, Int, Int)` | On-screen down D-pad button (76x76 px). |
| `btn_action` | `() -> (Int, Int, Int, Int)` | On-screen smoke action button (126x126 px, bottom-right). |
| `btn_hint` | `() -> (Int, Int, Int, Int)` | On-screen hint cycle button (116x70 px). |
| `btn_restart` | `() -> (Int, Int, Int, Int)` | On-screen in-play restart button (116x70 px). |
| `btn_menu` | `() -> (Int, Int, Int, Int)` | On-screen return-to-menu button (116x70 px). |
| `hint_text` | `(Int) -> String` | Returns one of 4 contextual hint strings by index. |
| `point_in_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | AABB point-in-rectangle test using float point and int rect. |
| `pointer_on_rect` | `(Game, Int, Int, Int, Int) -> Bool` | Tests mouse hold or any active touch point against an integer rectangle. |
| `title_hover` | `(Game) -> Bool` | Returns whether the title start button is currently under the pointer. |
| `retry_hover` | `(Game) -> Bool` | Returns whether the retry button is currently under the pointer. |

#### Math and Utility Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `lerpf` | `(Float, Float, Float) -> Float` | Linear interpolation between two floats. |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to `[lo, hi]`. |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an int to `[lo, hi]`. |
| `mini` | `(Int, Int) -> Int` | Returns the smaller of two integers. |
| `maxi` | `(Int, Int) -> Int` | Returns the larger of two integers. |
| `absi` | `(Int) -> Int` | Absolute value of an integer. |
| `sinf` | `(Float) -> Float` | Sine in radians via `@math.sin`. |
| `randf` | `(Float, Float) -> Float` | Uniform random float in `[lo, hi]` using raylib's RNG. |
| `manhattan` | `(Int, Int, Int, Int) -> Int` | Manhattan distance between two grid cells. |

#### Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `screen_w` | 1820 | Window width in pixels. |
| `screen_h` | 1000 | Window height in pixels. |
| `target_fps` | 120 | Target frame rate. |
| `grid_w` | 27 | Number of board columns. |
| `grid_h` | 13 | Number of board rows. |
| `cell` | 58 | Pixel size of one grid cell. |
| `board_x0` | 28 | Board left edge in screen pixels. |
| `board_y0` | 86 | Board top edge in screen pixels. |
| `board_w` | 1566 | Total board width in pixels (`grid_w * cell`). |
| `board_h` | 754 | Total board height in pixels (`grid_h * cell`). |
| `panel_x0` | 1614 | Right information panel left edge. |
| `panel_w` | 186 | Right information panel width. |
| `max_guards` | 6 | Pre-allocated guard pool size. |
| `max_loot` | 8 | Pre-allocated loot pool size. |
| `max_smokes` | 5 | Pre-allocated smoke pool size. |
| `max_particles` | 420 | Pre-allocated particle pool size. |
| `loot_need` | 6 | Loot pieces required to unlock the exit. |
| `start_x` | 2 | Player starting column. |
| `start_y` | 6 | Player starting row. |
| `exit_x` | 25 | Exit tile column (`grid_w - 2`). |
| `exit_y` | 6 | Exit tile row. |
| `player_move_t` | 0.11 | Seconds per player tile move (sets animation speed). |
| `guard_move_t` | 0.15 | Seconds per guard tile move. |
| `smoke_ttl` | 4.8 | Smoke cloud lifetime in seconds. |
| `smoke_cost` | 34.0 | Smoke energy consumed per deployment. |
| `run_time_limit` | 210.0 | Maximum run duration before automatic failure (seconds). |
| `score_blueprint` | 280 | Score for collecting a blueprint. |
| `score_keycard` | 360 | Score for collecting a keycard. |
| `score_gold` | 180 | Score for collecting gold. |
| `score_escape` | 1200 | Bonus score awarded on successful escape. |

### Package `tonyfettes/raylib-examples/raylib_clockwork_train_heist_2026/internal/game`
> Simulation update: reads keyboard and touch input, advances actor interpolation, moves guards, applies smoke interactions, updates timers, checks win/loss conditions, and transitions game state.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(@types.Game, Float) -> Unit` | Advances the full simulation by `dt` seconds: reads input, updates the player and guard actors, tests for loot collection and exit conditions, ticks smoke and particle lifetimes, and manages state transitions between `Title`, `Play`, and `Result`. |

### Package `tonyfettes/raylib-examples/raylib_clockwork_train_heist_2026/internal/render`
> Presentation: draws the board background, tile grid, guards, loot items, smoke clouds, particles, the player, and the side panel with score, lives, timer, and contextual messages.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(@types.Game) -> Unit` | Performs one complete render pass: background, all board tiles, smoke clouds, loot items, particles, guards with alert indicators, player actor, on-screen D-pad and action buttons, right-panel HUD (score, best score, lives, time, loot count, smoke energy, hints), and the title or result overlay. |

## Architecture

### Package Structure

```
raylib_clockwork_train_heist_2026/
├── README.mbt.md
├── main.mbt                        # Window init, game loop (update_game + draw_frame)
├── moon.pkg
├── pkg.generated.mbti
└── internal/
    ├── types/
    │   ├── constants.mbt           # All numeric and pool-size constants
    │   ├── types.mbt               # Struct/enum definitions and ::new constructors
    │   ├── utils.mbt               # Math, board geometry, UI rects, input hit-testing
    │   ├── moon.pkg
    │   └── pkg.generated.mbti
    ├── game/
    │   ├── input.mbt               # Keyboard and touch input; dispatches to logic helpers
    │   ├── logic.mbt               # Simulation: actor movement, guard AI, smoke, collisions
    │   ├── moon.pkg
    │   └── pkg.generated.mbti
    └── render/
        ├── render.mbt              # All raylib draw calls
        ├── moon.pkg
        └── pkg.generated.mbti
```

### Data Flow

The `main` package owns the single `Game` value and runs a 120 FPS raylib loop, calling `update_game` then `draw_frame` each frame.

Inside `update_game`, `input.mbt` reads raylib keyboard events and touch positions and writes a requested movement direction (`req_dx`, `req_dy`) and action flags onto `Game`. `logic.mbt` then consumes those: it calls `actor_tick` to advance the player's sub-cell interpolation parameters (`fx`, `fy`, `t`) toward the target tile; once a move completes it checks the destination tile for loot collection, the exit condition, and wall/door blocking. Guards are advanced by the same `actor_tick` and their AI decides each move via patrol bounds or Manhattan-distance hunt toward the player when alert. Smoke clouds deplete by `dt / smoke_ttl` each frame and stun any guard whose grid cell overlaps the cloud center. The timer counts down from 210 s and triggers a loss when it reaches zero.

`draw_frame` in `render.mbt` reads the `Game` reference to draw every visual layer: the dark background gradient, each `TileKind` cell as a colored rectangle, active smoke cloud circles with fading alpha, loot icons at their grid positions, particle effects, each active guard body with an alert halo scaled to `alert_t`, the player actor, on-screen D-pad buttons, and finally the right-side panel showing score, best score, lives, loot count, countdown timer, smoke energy bar, and hint text.

### Key Design Patterns

- **Actor interpolation struct**: The `Actor` struct stores both the integer grid cell (`x`, `y`) and the float interpolated position (`fx`, `fy`) with a normalized progress value `t`. This cleanly separates logical tile position from visual position and makes smooth movement a simple lerp.
- **Object pool arrays with active flags**: All entities (`Guard`, `Loot`, `Smoke`, `Particle`) live in fixed-size arrays. Allocation is a linear scan for an inactive slot, keeping heap allocation out of the frame loop.
- **Flat `Game` struct with embedded input**: Movement requests (`req_dx`, `req_dy`) and input flags are stored directly on `Game`, eliminating a separate input-state object.
- **Manhattan distance guard AI**: Guards in `Hunt` mode chase the player by comparing Manhattan distance, stepping one tile toward the smaller axis delta each move tick. This is cheap and produces believable corridor chasing without pathfinding.
- **Smoke as both stun and vision blocker**: A single `Smoke` entity serves double duty: its grid position is checked both for guard stun in logic and for vision occlusion in the line-of-sight test, keeping the state representation minimal.
- **Panel layout from constants**: The right information panel position and width (`panel_x0`, `panel_w`) are computed once from `board_x0 + board_w + 20` and `screen_w - panel_x0 - 20`, so resizing the board automatically repositions the panel.

## Improvement & Refinement Plan

1. **Procedural map generation**: The current map is a hardcoded layout defined in `logic.mbt`. Replacing it with a cellular-automata or room-corridor generator seeded per run would give each heist a distinct layout, greatly increasing replay value.

2. **Line-of-sight occlusion for guards**: Guards currently detect the player within a radius or by proximity. Adding a tile-by-tile ray cast that stops at `Wall` and `Door` tiles would make positioning behind walls a meaningful stealth mechanic and motivate the use of smoke to break sight lines.

3. **Guard alert propagation**: A single alerted guard could broadcast to adjacent guards, creating a realistic alarm cascade. This would require only a small addition to the guard update loop and would raise the tension of being spotted.

4. **Animated door tiles**: `Door` tiles are currently static colored rectangles. Animating them with a slide or iris effect when the player passes through (using `game.time_s` or a per-door timer) would reinforce the train-car boundary crossings visually.

5. **Smoke energy regeneration rate tuning with HUD feedback**: Smoke energy regenerates at a fixed rate but the constant is embedded in the logic. Exposing it as a named constant in `constants.mbt` and adding a visible regeneration rate label in the panel would let designers tune it directly and let players understand the resource economy.

6. **Particle burst on loot collection**: Loot collection currently triggers a score update with a text message. Spawning a `Glitter` particle burst at the loot's grid pixel position would give immediate visual confirmation and make the collection feel more rewarding.

7. **Persistent high score and run statistics**: `best_score` is tracked in memory but never saved. Writing and reading a small data file (score, fastest completion time, total loot collected) would give players a concrete progression target across sessions.
