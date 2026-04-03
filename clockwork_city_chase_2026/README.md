# Clockwork City Chase 2026

A vertically scrolling vehicular combat game set on a neon-lit clockwork highway. Pilot a car through a winding track, shoot enemies, collect pickups, and survive stage after stage.

## Build and Run

```bash
moon build --target native clockwork_city_chase_2026/
./_build/native/debug/build/clockwork_city_chase_2026/clockwork_city_chase_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Steer the car
- **Space / J / Left Click**: Fire weapons
- **Shift / K**: Dash (brief invulnerability and ram)
- **L / E**: EMP pulse (destroys nearby enemies, clears projectiles)
- **R / Enter**: Restart or continue
- **Touch**: On-screen buttons for movement, fire, dash, and EMP

## How to Play

- The track scrolls upward continuously and sways side to side. Stay on the road or take armor damage from the walls.
- Destroy scouts, spinners, tanks, and gear walls for score and combo multipliers.
- Collect coins, coolant (restores heat), and EMP cells (reduces EMP cooldown).
- Manage armor (health) and heat (energy) resources -- running out of either ends the run.
- Reach the distance target each stage to advance. Difficulty scales with each stage.

## Public API Reference

### Package `tonyfettes/raylib-examples/clockwork_city_chase_2026`
> Top-level entry point. Creates a `Game` value, calls `init_title`, then drives the raylib window loop by calling `update_game` and `draw_frame` every frame.

### Package `tonyfettes/raylib-examples/clockwork_city_chase_2026/internal/types`
> Shared data definitions: all structs, enums, constants, geometry helpers, color palette, UI hit-area functions, and math utilities used by every other package.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `StageClear`, `GameOver` | High-level flow state for the game loop. |
| `ObjKind` | `Scout`, `Spinner`, `Tank`, `GearWall`, `Coin`, `Coolant`, `EmpCell` | Classification for world objects; determines AI behavior, collision, and reward. |

#### Structs

| Struct | Key Fields | Description |
|--------|------------|-------------|
| `Game` | `objs`, `shots`, `sparks`, `rings`, `ghosts`, `hero`, `state`, `stage`, `distance`, `armor`, `heat`, `combo`, `scroll` | Complete session state; arrays are pre-allocated to fixed pool sizes. |
| `Player` | `x`, `y`, `vx`, `vy`, `w`, `h`, `heading`, `invuln`, `hurt_t`, `muzzle_t`, `engine_t` | Hero car position, velocity, and timer state. |
| `Obj` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `w`, `h`, `hp`, `shot_cd`, `spin`, `cloak`, `reward` | Generic world object slot used for enemies and pickups. |
| `Shot` | `active`, `from_player`, `x`, `y`, `vx`, `vy`, `life`, `dmg`, `kind` | Projectile slot for both player and enemy bullets. |
| `Spark` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | Short-lived visual particle. |
| `ShockRing` | `active`, `x`, `y`, `r`, `life`, `kind` | Expanding ring effect emitted on dash, EMP, and kills. |
| `Ghost` | `active`, `x`, `y`, `w`, `h`, `rot`, `life`, `kind` | After-image trail emitted during dash. |

#### Constructor Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Game::new` | `() -> Game` | Creates a fully initialized game with all pools allocated. |
| `Player::new` | `() -> Player` | Creates a player positioned at the default start location. |
| `Obj::new` | `() -> Obj` | Creates an inactive object slot. |
| `Shot::new` | `() -> Shot` | Creates an inactive shot slot. |
| `Spark::new` | `() -> Spark` | Creates an inactive spark slot. |
| `ShockRing::new` | `() -> ShockRing` | Creates an inactive shock ring slot. |
| `Ghost::new` | `() -> Ghost` | Creates an inactive ghost slot. |

#### Geometry and Track Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `track_center` | `(Float, Float) -> Float` | Returns the screen-x center of the track given depth and elapsed time; incorporates two sine-wave sway frequencies. |
| `track_half_width` | `(Int, Float, Float) -> Float` | Returns the half-width of the driveable track, narrowing by 10 px per stage. |
| `track_edges` | `(Int, Float, Float) -> (Float, Float)` | Returns `(left_x, right_x)` world-space track boundaries. |
| `lane_offset` | `(Int) -> Float` | Returns the signed x-offset of a lane index from the track center; lane gap is 90 px. |
| `lane_pos` | `(Int, Float) -> Float` | Converts a lane index and center x into an absolute x position. |
| `spawn_x` | `(Float, Float, Int, Float) -> Float` | Returns a random x position within the track bounds at a given depth. |

#### Math and Utility Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `lerpf` | `(Float, Float, Float) -> Float` | Linear interpolation between two floats. |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to `[lo, hi]`. |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an int to `[lo, hi]`. |
| `maxf` | `(Float, Float) -> Float` | Returns the larger of two floats. |
| `minf` | `(Float, Float) -> Float` | Returns the smaller of two floats. |
| `absf` | `(Float) -> Float` | Absolute value of a float. |
| `sqrtf` | `(Float) -> Float` | Square root of a float. |
| `sinf` | `(Float) -> Float` | Sine in radians, delegating to `@math.sin`. |
| `cosf` | `(Float) -> Float` | Cosine in radians, delegating to `@math.cos`. |
| `randf` | `(Float, Float) -> Float` | Uniform random float in `[lo, hi]` using raylib's RNG. |
| `randi` | `(Int, Int) -> Int` | Uniform random int in `[lo, hi]`. |
| `chance` | `(Int) -> Bool` | Returns true with probability `pct` percent. |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared Euclidean distance between two 2D points. |
| `ease_out_cubic` | `(Float) -> Float` | Cubic ease-out curve for normalized `[0, 1]` input. |
| `is_hostile` | `(ObjKind) -> Bool` | True for `Scout`, `Spinner`, `Tank`, `GearWall`. |
| `is_pickup` | `(ObjKind) -> Bool` | True for `Coin`, `Coolant`, `EmpCell`. |
| `obj_hit_r` | `(Obj) -> Float` | Collision radius for a world object (`max(w,h) * 0.38`). |
| `player_hit_r` | `(Player) -> Float` | Collision radius for the player car (`max(w,h) * 0.34`). |
| `alpha_color` | `(@raylib.Color, Int) -> @raylib.Color` | Returns a copy of a color with the given alpha clamped to `[0, 255]`. |
| `point_in_rect` | `(Float, Float, Float, Float, Float, Float) -> Bool` | AABB point-in-rectangle test. |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Float, Float, Float, Float) -> Bool` | Tests mouse hold or any active touch point against a rectangle. |

#### Color Palette Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `bg_top` | `@raylib.Color` | Dark navy sky top color `(10, 10, 24)`. |
| `bg_bottom` | `@raylib.Color` | Deep teal sky bottom color `(12, 26, 44)`. |
| `track_dark` | `@raylib.Color` | Dark asphalt fill color `(16, 20, 34)`. |
| `track_mid` | `@raylib.Color` | Mid-tone lane color `(22, 30, 50)`. |
| `amber` | `@raylib.Color` | Warm amber highlight `(255, 214, 124)`. |
| `armor_col` | `@raylib.Color` | Armor bar color `(255, 122, 154)`. |
| `heat_col` | `@raylib.Color` | Heat bar color `(116, 244, 196)`. |

#### UI Hit-Area Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `btn_left_rect` | `(Float, Float, Float, Float)` | Left movement button; 104x104 px near bottom-left. |
| `btn_right_rect` | `(Float, Float, Float, Float)` | Right movement button; 104x104 px next to left. |
| `btn_up_rect` | `(Float, Float, Float, Float)` | Up movement button; above the left/right row. |
| `btn_down_rect` | `(Float, Float, Float, Float)` | Down movement button; same column as up. |
| `btn_fire_rect` | `(Float, Float, Float, Float)` | Fire button; 104x104 px at bottom-right. |
| `btn_dash_rect` | `(Float, Float, Float, Float)` | Dash button; left of fire button. |
| `btn_emp_rect` | `(Float, Float, Float, Float)` | EMP button; above fire button. |
| `title_start_rect` | `(Float, Float, Float, Float)` | Centered 420x88 start button on the title screen. |
| `retry_rect` | `(Float, Float, Float, Float)` | Centered 220x64 retry button on the result screen. |

#### Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `screen_w` | 1280 | Window width in pixels. |
| `screen_h` | 720 | Window height in pixels. |
| `target_fps` | 120 | Target frame rate. |
| `hud_h` | 112 | Height of the top HUD bar in pixels. |
| `lane_count` | 5 | Number of driving lanes on the track. |
| `lane_gap` | 90.0 | Pixel spacing between lane centers. |
| `car_w` | 44.0 | Player car width. |
| `car_h` | 76.0 | Player car height. |
| `max_objs` | 420 | Pre-allocated enemy and pickup pool size. |
| `max_shots` | 480 | Pre-allocated projectile pool size. |
| `max_sparks` | 760 | Pre-allocated particle pool size. |
| `max_shock_rings` | 84 | Pre-allocated shock ring pool size. |
| `max_ghosts` | 240 | Pre-allocated dash ghost pool size. |
| `armor_max` | 100.0 | Starting and maximum armor. |
| `heat_max` | 100.0 | Starting and maximum heat. |
| `armor_drain_passive` | 0.45 | Armor lost per second passively. |
| `heat_drain_base` | 3.0 | Heat lost per second at rest. |
| `heat_drain_dash` | 6.0 | Additional heat lost per second while dashing. |
| `heat_pickup` | 23.0 | Heat restored by collecting a coolant canister. |
| `base_scroll` | 270.0 | Track scroll speed on stage 1 (px/s). |
| `stage_scroll_bonus` | 36.0 | Additional scroll speed per stage. |
| `stage_goal_base` | 2500.0 | Distance required to clear stage 1. |
| `stage_goal_bonus` | 780.0 | Additional distance required per subsequent stage. |
| `accel_x` | 1620.0 | Horizontal acceleration applied per input unit. |
| `accel_y` | 1180.0 | Vertical acceleration applied per input unit. |
| `max_speed_x` | 500.0 | Maximum horizontal speed. |
| `max_speed_y` | 340.0 | Maximum vertical speed. |
| `car_drag` | 3.0 | Velocity damping coefficient per second. |
| `dash_boost` | 540.0 | Impulse added on dash activation. |
| `dash_time` | 0.25 | Duration of active dash in seconds. |
| `dash_cd_time` | 1.62 | Cooldown between dashes in seconds. |
| `emp_radius` | 220.0 | EMP stun radius in pixels. |
| `emp_kill_radius` | 108.0 | Radius within which EMP instantly destroys enemies. |
| `emp_cd_time` | 2.46 | EMP cooldown in seconds. |
| `emp_time` | 0.82 | EMP active duration in seconds. |
| `shot_speed` | 760.0 | Player projectile speed in px/s. |
| `enemy_shot_speed` | 380.0 | Enemy projectile speed in px/s. |
| `shot_cd_base` | 0.148 | Minimum seconds between player shots. |
| `shot_life` | 1.24 | Projectile lifetime in seconds. |
| `invuln_time` | 0.64 | Post-hit invulnerability window in seconds. |
| `stage_clear_wait` | 1.9 | Auto-advance delay after stage clear in seconds. |
| `spawn_gap_min` | 64.0 | Minimum distance between spawn waves in pixels. |
| `spawn_gap_max` | 164.0 | Maximum distance between spawn waves in pixels. |

### Package `tonyfettes/raylib-examples/clockwork_city_chase_2026/internal/game`
> Simulation update: reads input from raylib, applies player physics, spawns and updates enemies and projectiles, handles collisions, and manages stage/game-over transitions.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `init_title` | `(@types.Game) -> Unit` | Resets all game arrays and mutable fields to the title-screen defaults; called on first launch and after game over. |
| `update_game` | `(@types.Game, Float) -> Unit` | Advances the full simulation by `dt` seconds: reads input, ticks timers, dispatches to the current state handler (`update_title`, `update_play`, `update_stage_clear`, `update_game_over`). |

### Package `tonyfettes/raylib-examples/clockwork_city_chase_2026/internal/render`
> Presentation: draws the background gradient, scrolling track, all world objects, projectiles, particles, HUD bars, and state overlays each frame.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(@types.Game) -> Unit` | Performs one complete render pass: sky, track geometry, enemies, pickups, player car, projectiles, sparks, rings, ghosts, HUD (armor/heat bars, combo, score), and state overlays (title, stage clear, game over). |

## Architecture

### Package Structure

```
clockwork_city_chase_2026/
├── README.mbt.md
├── main.mbt                        # Window init, game loop (update_game + draw_frame)
├── moon.pkg
├── pkg.generated.mbti
└── internal/
    ├── types/
    │   ├── constants.mbt           # All numeric and pool-size constants
    │   ├── types.mbt               # Struct/enum definitions and ::new constructors
    │   ├── utils.mbt               # Math helpers, color palette, UI rects, collision utils
    │   ├── moon.pkg
    │   └── pkg.generated.mbti
    ├── game/
    │   ├── input.mbt               # Keyboard and touch input reading into Game fields
    │   ├── logic.mbt               # Simulation: physics, spawning, collision, scoring
    │   ├── moon.pkg
    │   └── pkg.generated.mbti
    └── render/
        ├── render.mbt              # All raylib draw calls
        ├── moon.pkg
        └── pkg.generated.mbti
```

### Data Flow

The `main` package owns the single `Game` value and runs a standard raylib `begin_drawing` / `end_drawing` loop at 120 FPS. Each frame it calls `update_game` then `draw_frame`, passing the same `Game` reference to both.

Inside `update_game`, `input.mbt` queries raylib's keyboard and touch APIs and writes normalized input axes and button-press booleans directly onto `game.input_*` fields. `logic.mbt` then consumes those fields: it applies acceleration and drag to the hero's velocity, moves the hero, constrains it to the sinusoidal track boundaries, advances enemy and projectile positions, tests circular collisions, resolves damage and pickup collection, maintains the combo timer, and advances the scroll and distance counters. When distance reaches `stage_goal`, the state transitions to `StageClear`; when armor reaches zero, it transitions to `GameOver`.

`draw_frame` in `render.mbt` reads the same `Game` reference in read-only fashion to draw every layer: a gradient sky, the procedurally-computed track polygon, active enemies (with cloak shimmer), projectiles, sparks, expanding shock rings, dash ghost trails, the player car with muzzle flash, the HUD armor and heat bars with labels, the combo multiplier, score and kills, and finally the appropriate overlay for the current `GameState`.

### Key Design Patterns

- **Object pool arrays with active flags**: All dynamic entities (`Obj`, `Shot`, `Spark`, `ShockRing`, `Ghost`) live in fixed-size arrays allocated once by `Game::new`. Allocation scans for an inactive slot; when all slots are full the oldest-by-lifetime entry is evicted. This eliminates heap fragmentation at runtime.
- **Flat `Game` struct with embedded input**: Input state is stored directly on `Game` as boolean and float fields rather than in a separate input structure, so logic can read input without extra indirection.
- **Procedural track geometry**: The track center and half-width are computed every frame from two overlapping sine waves parameterized by cumulative distance and elapsed time. No stored waypoints are needed.
- **Stage-based difficulty scaling**: Scroll speed, stage goal distance, enemy HP, and spawned enemy count all scale linearly with the stage integer, so adding difficulty is a single constant change.
- **Circular hit detection**: All collisions use squared-distance comparisons against summed radii, avoiding square-root calls in the hot path.
- **Separated input, logic, render**: Each concern lives in a distinct file and the only shared surface is the `Game` struct, making each layer independently readable.

## Improvement & Refinement Plan

1. **Weighted spawn table with a data structure**: The current `spawn_wave` function uses a chain of `if roll < N` branches. Replacing it with an array of `(threshold, kind, params)` records would make balancing spawn probabilities a data change rather than a code change, and would make it easy to introduce stage-specific spawn tables.

2. **Deterministic RNG seeded per stage**: All randomness currently calls `@raylib.get_random_value`, which is a global mutable RNG. Storing a per-game seed and advancing it with a simple LCG would make runs reproducible for debugging and future replay recording.

3. **Track polygon caching**: `track_center` and `track_half_width` are called multiple times per frame from both logic and render with the same arguments. Computing them once per frame and storing results in the `Game` struct would eliminate redundant trigonometric evaluations.

4. **Combo decay visualization**: The combo timer (`combo_t` starts at 3.6 s) is invisible to the player other than the numeric counter. Adding a depleting arc or bar tied to `combo_t / 3.6` would make maintaining combos a more legible skill expression.

5. **Touch multi-point support for simultaneous fire and movement**: The current touch input reads from `get_touch_position` in a loop but uses the same `mouse_hold` coordinate for the held direction. Separating left-side and right-side touch zones properly would allow independent fire and movement on touchscreens.

6. **Stage clear transition animation**: The `StageClear` state immediately resumes the next stage after `stage_clear_wait` (1.9 s) or a keypress. Adding a brief camera pull-back or number-count animation during this window would better communicate stage progression.

7. **Persistent best-score storage**: `best_score` is tracked in the `Game` struct for the session but is never written to disk. A small file read/write in `init_title` and on game-over would give players a persistent high-score goal.
