# Jade Temple Bellkeeper 2026

An action-defense game where you play as the bellkeeper of a jade temple, defending a central shrine from waves of spirit foes by ringing sacred bells that emit shockwaves.

## Build and Run

```bash
cd examples && moon build --target native raylib_jade_temple_bellkeeper_2026/
cd examples && ./_build/native/debug/build/raylib_jade_temple_bellkeeper_2026/raylib_jade_temple_bellkeeper_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Move the hero
- **J or Space**: Ring the nearest bell (costs spirit energy)
- **K**: Dash (costs spirit, brief invulnerability)
- **R**: Restart
- **Touch buttons**: On-screen d-pad, ring, and dash buttons

## How to Play

Four sacred bells orbit the central shrine. Move near a bell and ring it to emit a damaging shockwave that destroys nearby foes (wisps, brutes, shamans, and relics). Foes advance toward the shrine and drain its HP on contact. Manage your spirit energy -- it regenerates over time but is consumed by ringing bells and dashing. Build combos by defeating foes in quick succession. Reach the stage score goal within the time limit to advance to harder stages.

## Public API Reference

### Package `raylib_jade_temple_bellkeeper_2026`

> Main entry point.

The `main` function initializes the window (1280x720, MSAA 4x), initializes the audio device, sets 120 FPS, creates the `Game` struct via `@types.Game::new()`, and runs the frame loop. Each frame it clamps delta time to 33 ms, calls `@game.update_game`, then draws with `@render.draw_frame` inside `begin_drawing`/`end_drawing`.

### Package `raylib_jade_temple_bellkeeper_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Bell` | `x`, `y`, `cooldown`, `glow`, `charge` | Bell node orbiting the shrine; stores ring cooldown and charge fraction. |
| `Foe` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `w`, `h`, `hp`, `life`, `phase`, `shot_cd`, `reward`, `marked` | Runtime record for hostile spirits (wisp, brute, shaman) and relic pickups. |
| `Bolt` | `active`, `x`, `y`, `vx`, `vy`, `life`, `dmg`, `kind` | Shaman-fired projectile that damages the hero on contact. |
| `Spark` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | Short-lived particle effect emitted by explosions and bell rings. |
| `Ring` | `active`, `x`, `y`, `r`, `life`, `kind` | Expanding circle effect spawned by bell shockwaves and death bursts. |
| `Echo` | `active`, `x`, `y`, `w`, `h`, `life`, `rot` | Fading ghost rectangle left behind the hero during a dash. |
| `Hero` | `x`, `y`, `vx`, `vy`, `w`, `h`, `angle`, `dash_cd`, `dash_t`, `invuln`, `hurt_t`, `aura_t`, `anim_t` | Mutable hero state for movement, dashing, and damage feedback. |
| `Game` | `bells`, `foes`, `bolts`, `sparks`, `rings`, `echoes`, `hero`, `state`, `stage`, `score`, `shrine_hp`, `spirit`, `time_left`, ... | Top-level game state holding all entity pools, counters, and input state. |

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `StageClear`, `GameOver` | High-level scene state machine. |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Foe::new` | `() -> Foe` | Creates an inactive foe with default values. |
| `Bolt::new` | `() -> Bolt` | Creates an inactive bolt. |
| `Spark::new` | `() -> Spark` | Creates an inactive spark particle. |
| `Ring::new` | `() -> Ring` | Creates an inactive ring effect. |
| `Echo::new` | `() -> Echo` | Creates an inactive echo effect. |
| `Hero::new` | `() -> Hero` | Creates a hero positioned near the shrine with default stats. |
| `Game::new` | `() -> Game` | Creates a fresh game state with all object pools allocated. |
| `shrine_x` | `() -> Float` | Returns the shrine center x-coordinate (screen_w * 0.5). |
| `shrine_y` | `() -> Float` | Returns the shrine center y-coordinate (screen_h * 0.55). |
| `bell_orbit_r` | `() -> Float` | Returns the bell orbit radius (220.0). |
| `bell_pos` | `(Int) -> (Float, Float)` | Returns world coordinates for bell index `i` (cardinal positions). |
| `bg_top` | `() -> Color` | Returns the top background gradient color. |
| `bg_bottom` | `() -> Color` | Returns the bottom background gradient color. |
| `cyan` / `pink` / `amber` / `jade` | `() -> Color` | Returns named accent colors. |
| `shrine_col` / `spirit_col` | `() -> Color` | Returns HUD bar colors. |
| `btn_size` | `() -> Float` | Returns the touch button side length (102.0). |
| `btn_left_rect` / `btn_right_rect` / `btn_up_rect` / `btn_down_rect` | `() -> (Float, Float, Float, Float)` | Returns touch d-pad button rectangles. |
| `btn_ring_rect` / `btn_dash_rect` | `() -> (Float, Float, Float, Float)` | Returns touch action button rectangles. |
| `title_start_rect` / `retry_rect` | `() -> (Float, Float, Float, Float)` | Returns overlay button rectangles. |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer to `[lo, hi]`. |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to `[lo, hi]`. |
| `minf` / `maxf` | `(Float, Float) -> Float` | Returns the min/max of two floats. |
| `absf` | `(Float) -> Float` | Returns the absolute value. |
| `lerpf` | `(Float, Float, Float) -> Float` | Linear interpolation. |
| `sinf` / `cosf` | `(Float) -> Float` | Trigonometric helpers. |
| `sqrtf` | `(Float) -> Float` | Square root helper. |
| `ease_out_cubic` | `(Float) -> Float` | Applies an ease-out cubic curve to a normalized value. |
| `randf` | `(Float, Float) -> Float` | Returns a random float in `[lo, hi]`. |
| `randi` | `(Int, Int) -> Int` | Returns a random integer in `[lo, hi]`. |
| `chance` | `(Int) -> Bool` | Returns true with probability `pct / 100`. |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Returns squared distance between two points. |
| `point_in_rect` | `(Float, Float, Float, Float, Float, Float) -> Bool` | Tests point-in-rectangle. |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Float, Float, Float, Float) -> Bool` | Tests mouse or any touch point against a rectangle. |
| `is_hostile` | `(Int) -> Bool` | Returns true if the entity kind is a hostile foe. |
| `is_relic` | `(Int) -> Bool` | Returns true if the entity kind is a relic pickup. |
| `foe_hit_r` | `(Foe) -> Float` | Returns the collision radius for a foe. |
| `hero_hit_r` | `(Hero) -> Float` | Returns the collision radius for the hero. |
| `a_col` | `(Color, Int) -> Color` | Returns a color with clamped alpha. |
| `foe_col` | `(Int) -> Color` | Returns the display color for a foe kind. |
| `spark_col` | `(Int) -> Color` | Returns the display color for a spark kind. |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1280` | Window width in pixels. |
| `screen_h` | `Int` | `720` | Window height in pixels. |
| `target_fps` | `Int` | `120` | Target frame rate. |
| `hud_h` | `Int` | `112` | HUD strip height. |
| `play_left` / `play_right` / `play_top` / `play_bottom` | `Float` | computed | Play area boundaries. |
| `foe_wisp` / `foe_brute` / `foe_shaman` / `foe_relic` | `Int` | `0`–`3` | Foe kind IDs. |
| `max_foes` | `Int` | `380` | Foe pool size. |
| `max_bolts` | `Int` | `420` | Bolt pool size. |
| `max_sparks` | `Int` | `900` | Spark pool size. |
| `max_rings` | `Int` | `96` | Ring pool size. |
| `max_echoes` | `Int` | `320` | Echo pool size. |
| `hero_w` / `hero_h` | `Float` | `46.0` / `52.0` | Hero collision dimensions. |
| `hero_accel` | `Float` | `1400.0` | Hero movement acceleration. |
| `hero_drag` | `Float` | `3.6` | Hero velocity damping. |
| `hero_max_speed` | `Float` | `390.0` | Hero top speed. |
| `hero_invuln_time` | `Float` | `0.62` | Invulnerability window after damage. |
| `dash_cd_time` | `Float` | `1.2` | Dash cooldown duration. |
| `dash_time` | `Float` | `0.2` | Dash active duration. |
| `dash_speed` | `Float` | `700.0` | Dash movement speed. |
| `bell_count` | `Int` | `4` | Number of bells. |
| `bell_ring_reach` | `Float` | `138.0` | Activation distance for bell ringing. |
| `bell_cd_time` | `Float` | `1.38` | Bell cooldown duration. |
| `bell_cost` | `Float` | `18.0` | Spirit cost per bell ring. |
| `bell_shock_radius` | `Float` | `180.0` | Shockwave effect radius. |
| `bell_shock_damage` | `Float` | `26.0` | Shockwave damage per hit. |
| `shrine_radius` | `Float` | `64.0` | Shrine collision radius. |
| `shrine_max_hp` | `Float` | `100.0` | Maximum shrine health. |
| `spirit_max` | `Float` | `100.0` | Maximum spirit meter value. |
| `spirit_regen` | `Float` | `16.0` | Spirit regeneration per second. |
| `spirit_dash_cost` | `Float` | `12.0` | Spirit cost per dash. |
| `stage_goal_base` | `Int` | `1200` | Stage 1 score goal. |
| `stage_goal_bonus` | `Int` | `760` | Score goal increment per stage. |
| `stage_time_base` | `Float` | `60.0` | Stage 1 timer in seconds. |
| `stage_time_bonus` | `Float` | `10.0` | Extra time added per stage. |

### Package `raylib_jade_temple_bellkeeper_2026/internal/game`

> Game logic, input handling, and update systems.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | **Public.** Advances one full simulation frame: reads input, ticks timers, dispatches to state-specific update. |
| `clear_input` | `(Game) -> Unit` | Resets all input fields to neutral. |
| `update_title_input` | `(Game) -> Unit` | Reads start input for the title screen. |
| `update_play_input` | `(Game) -> Unit` | Reads movement, ring, dash, and restart input during gameplay. |
| `update_result_input` | `(Game) -> Unit` | Reads retry input for result screens. |
| `clear_foes` / `clear_bolts` / `clear_sparks` / `clear_rings` / `clear_echoes` | `(Game) -> Unit` | Reset corresponding entity pools. |
| `reset_bells` | `(Game) -> Unit` | Restores all bells to orbiting positions with full charge. |
| `reset_hero` | `(Game) -> Unit` | Resets hero to spawn position with default stats. |
| `alloc_foe` / `alloc_bolt` / `alloc_spark` / `alloc_ring` / `alloc_echo` | `(Game) -> Int` | Returns a free pool index, evicting the shortest-lived entry if full. |
| `emit_spark` | `(Game, Float, Float, Float, Float, Float, Float, Int) -> Unit` | Allocates and initializes a spark particle. |
| `burst_sparks` | `(Game, Float, Float, Int, Int) -> Unit` | Emits `n` sparks radiating from a point. |
| `spawn_ring` | `(Game, Float, Float, Float, Float, Int) -> Unit` | Allocates and initializes a ring effect. |
| `spawn_echo` | `(Game, Float, Float, Float, Float, Float, Float) -> Unit` | Allocates and initializes an echo trail. |
| `spawn_bolt` | `(Game, Float, Float, Float, Float, Float, Float, Int) -> Unit` | Allocates and initializes a bolt projectile. |
| `spawn_foe` | `(Game, Int, Float, Float, Float, Float, Float, Float, Float, Float, Float, Int) -> Unit` | Allocates and fully initializes a foe. |
| `score_gain` | `(Game, Int) -> Int` | Computes combo-scaled score gain. |
| `add_score` | `(Game, Int) -> Unit` | Adds score and updates best score. |
| `push_combo` | `(Game) -> Unit` | Increments combo counter and resets decay timer. |
| `clear_combo` | `(Game) -> Unit` | Resets combo to zero. |
| `hurt_hero` | `(Game, Float) -> Unit` | Applies damage if not invulnerable, triggering effects. |
| `ring_bell` | `(Game, Int) -> Unit` | Triggers a bell shockwave, damaging foes and destroying bolts in range. |
| `find_nearest_bell` | `(Game) -> Int` | Returns the nearest in-range bell index, or -1. |
| `edge_spawn` | `() -> (Float, Float)` | Returns a random spawn point on a play area edge. |
| `spawn_wisp` / `spawn_brute` / `spawn_shaman` / `spawn_relic` | `(Game) -> Unit` | Spawn individual foe types at an edge position. |
| `spawn_wave` | `(Game) -> Unit` | Spawns a mixed group of foes scaled by stage. |
| `spawn_step` | `(Game, Float) -> Unit` | Ticks spawn cooldown and triggers a wave when it expires. |
| `apply_dash` | `(Game) -> Unit` | Executes the dash action in the input direction. |
| `update_hero` | `(Game, Float) -> Unit` | Updates hero movement, dash, bell-ring, and boundary clamping. |
| `fire_shaman_bolt` | `(Game, Foe) -> Unit` | Fires a bolt from a shaman aimed at the hero. |
| `kill_foe` | `(Game, Int, Int, Int) -> Unit` | Deactivates a foe and awards score with effects. |
| `update_foes` | `(Game, Float) -> Unit` | Advances all active foes with AI, collision, and out-of-bounds removal. |
| `update_bolts` | `(Game, Float) -> Unit` | Advances all active bolts and applies hero collision damage. |
| `update_effects` | `(Game, Float) -> Unit` | Advances spark, ring, and echo effects. |
| `update_bells` | `(Game, Float) -> Unit` | Decrements bell cooldowns and recomputes charge. |
| `emit_ambient` | `(Game, Float) -> Unit` | Emits atmospheric upward spark particles. |
| `update_timers` | `(Game, Float) -> Unit` | Advances global and hero timers including combo decay. |
| `init_title_scene` | `(Game) -> Unit` | Resets everything and sets Title state. |
| `start_stage` | `(Game, Int) -> Unit` | Prepares a stage with scaled goal, time, and resources. |
| `start_run` | `(Game) -> Unit` | Resets run stats and starts stage 1. |
| `update_play` | `(Game, Float) -> Unit` | Runs a full play-state tick. |
| `update_title` | `(Game, Float) -> Unit` | Updates title screen logic. |
| `update_stage_clear` | `(Game, Float) -> Unit` | Runs stage-clear celebration and advances to next stage. |
| `update_game_over` | `(Game, Float) -> Unit` | Updates game-over state and returns to title on input. |

### Package `raylib_jade_temple_bellkeeper_2026/internal/render`

> Rendering and drawing routines.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | **Public.** Renders the complete frame: clears background, draws world, HUD, state overlays, touch controls, and flash. |
| `draw_center_text` | `(String, Int, Int, Color) -> Unit` | Draws text centered horizontally at a given y. |
| `draw_right_text` | `(String, Int, Int, Int, Color) -> Unit` | Draws text right-aligned at a given x. |
| `cam_shake` | `(Game) -> (Float, Float)` | Returns a random camera offset based on shake timer. |
| `draw_sky` | `(Game, Float, Float) -> Unit` | Draws background gradient, moon, stars, and wave clouds. |
| `draw_floor_grid` | `(Game, Float, Float) -> Unit` | Draws the play area floor with animated scrolling grid. |
| `draw_shrine` | `(Game, Float, Float) -> Unit` | Draws shrine with aura, HP gem, and bell connector lines. |
| `draw_bell` | `(Bell, Int, Float, Float) -> Unit` | Draws a bell with glow, body, clapper, and charge bar. |
| `draw_wisp` / `draw_brute` / `draw_shaman` / `draw_relic` | `(Foe, Float, Float, Float) -> Unit` | Draw individual foe kinds. |
| `draw_foe` | `(Foe, Float, Float) -> Unit` | Dispatches to kind-specific draw and adds HP bar. |
| `draw_hero` | `(Game, Float, Float) -> Unit` | Draws hero with aura, body, tail, and hurt flash. |
| `draw_bolts` | `(Game, Float, Float) -> Unit` | Draws all active bolt projectiles. |
| `draw_fx` | `(Game, Float, Float) -> Unit` | Draws sparks, rings, and echo effects. |
| `draw_bar` | `(Int, Int, Int, Int, Float, Float, String, Color) -> Unit` | Draws a labeled progress bar. |
| `draw_hud` | `(Game) -> Unit` | Draws shrine HP, spirit, score/goal, timer, bell charges, combo, and hints. |
| `draw_button_visual` | `(String, (Float,Float,Float,Float), Bool, Float, Float, Bool, Int) -> Unit` | Draws a touch button with press/hover state. |
| `draw_touch_controls` | `(Game) -> Unit` | Renders all state-appropriate touch buttons. |
| `draw_title_overlay` | `(Game) -> Unit` | Draws title screen with how-to-play panel. |
| `draw_stage_clear_overlay` | `(Game) -> Unit` | Draws stage-clear animation and bonus. |
| `draw_game_over_overlay` | `(Game) -> Unit` | Draws game-over stats and retry button. |
| `draw_flash` | `(Game) -> Unit` | Draws screen-wide damage flash effect. |
| `draw_world` | `(Game, Float, Float) -> Unit` | Draws all world layers in depth order. |

## Architecture

### Package Structure

```
raylib_jade_temple_bellkeeper_2026/
├── main.mbt           — Entry point: window/audio init, game loop
├── moon.pkg           — Package config with raylib and math imports
└── internal/
    ├── types/
    │   ├── types.mbt      — All struct definitions and ::new constructors
    │   ├── constants.mbt  — Layout constants, foe kind IDs, color helpers, button rects
    │   └── utils.mbt      — Math helpers, RNG, geometry, color utilities
    ├── game/
    │   ├── input.mbt      — Per-state input reading (keyboard, mouse, touch)
    │   └── logic.mbt      — Simulation: pool allocation, spawning, physics, collision, state machine
    └── render/
        └── render.mbt     — All drawing: world, entities, HUD, overlays, effects
```

**Data flow**: `main` calls `update_game` (logic package) then `draw_frame` (render package) each frame. Both receive the shared `Game` struct. The types package is imported by all three other packages and contains no game logic. The game package handles all mutable state changes; the render package is read-only with respect to game state.

**Key design patterns**:
- **Object pool pattern**: All entity arrays (`foes`, `bolts`, `sparks`, `rings`, `echoes`) are pre-allocated in `Game::new`. Pool allocators (`alloc_foe`, etc.) scan for inactive slots and evict the shortest-lived entry when full.
- **State machine**: `GameState` enum (`Title`, `Play`, `StageClear`, `GameOver`) drives both update and render dispatch via `match`.
- **Input abstraction**: Each state has its own input function that writes into normalized `input_x`, `input_y`, and press flags on the `Game` struct, decoupling logic from input source.
- **Delta-time physics**: All movement uses `dt`-scaled acceleration and drag for frame-rate independence.

## Improvement & Refinement Plan

1. **Add bell upgrade system**: Between stages, allow the player to spend bonus score to increase one bell's shock radius, damage, or reduce its cost. This would give strategic depth and reward high-combo play.

2. **Add foe difficulty tiers**: Currently, stage scaling only increases foe HP linearly. Introducing elite variants (e.g., armored brutes immune to one shockwave, fast shamans that dodge, phase wisps) would create more tactical variety.

3. **Introduce a persistent best-score leaderboard**: The `best_score` field survives a run restart but is lost on exit. Saving it to a file using a native IO call would give players long-term progression tracking.

4. **Add audio feedback**: The code initializes the audio device but uses no sounds or music. Adding bell ring tones (different pitch per bell), hit sounds, and an ambient temple track would significantly improve game feel.

5. **Decouple rendering from window coordinates**: All positions are in screen space. Adding a camera struct with world-to-screen transforms would enable scrolling arenas or zooming, increasing replayability.

6. **Extract constants to a dedicated configuration**: Currently `start_stage`, `spawn_wave`, and `hurt_hero` contain embedded numeric literals (damage values, score bonuses, regen amounts). Moving these to named constants in the types package would make balance tuning easier.

7. **Add a relic streak bonus**: Rescuing multiple relics in quick succession could grant larger spirit or shrine HP bonuses, encouraging players to prioritize relic routes and adding a risk/reward dimension.
