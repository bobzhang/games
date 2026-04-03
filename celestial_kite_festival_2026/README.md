# Celestial Kite Festival 2026

A wind-physics action game set during a celestial night festival where the player pilots a diamond-shaped kite tethered to a moving ground anchor. The sky is filled with drifting lanterns to rescue, hostile birds and storm clouds to avoid or destroy, and rare koi fish and energy orbs to catch -- all while coping with dynamic wind gusts that push the kite across a bounded play area.

The core gameplay loop revolves around steering the kite using directional input, collecting lanterns and bonus objects to accumulate score toward a stage goal, and surviving threats that drain the kite's "calm" meter. The player has two special abilities: a burst shockwave (costing energy, with a cooldown) that damages nearby hostile objects, and a rope reel (costing energy per second) that shortens the tether to resist gusts and pull the kite toward the anchor. Wind direction and intensity shift periodically, demanding constant positional adjustment. Each stage increases the score goal, wind power, and enemy toughness, while granting additional time.

The game features a rich particle system with spark effects, expanding halos, and fading trails behind the kite. A combo multiplier rewards rapid successive collections. The rope physics use spring-and-damping forces to constrain the kite within its tether radius, and a parallax camera shake system provides visceral feedback on damage. Touch controls with on-screen directional pads and action buttons provide full mobile support.

## Build and Run

```bash
moon build --target native celestial_kite_festival_2026/
./_build/native/debug/build/celestial_kite_festival_2026/celestial_kite_festival_2026.exe
```

## Controls

- **W / Up Arrow**: Steer kite upward
- **S / Down Arrow**: Steer kite downward
- **A / Left Arrow**: Steer kite left
- **D / Right Arrow**: Steer kite right
- **Space / K**: Burst shockwave (damages nearby enemies, costs 24 energy, 1.8s cooldown)
- **J / Left Shift / Right Shift / Right Mouse Button**: Reel rope (shortens tether, costs 22 energy/s)
- **R / Enter**: Restart (during play) / Retry (after game over)
- **Space / Enter**: Start game (on title screen)
- **Touch**: On-screen directional pad (left, right, up, down) and BURST/REEL action buttons

## How to Play

On the title screen, press Space/Enter or tap START to begin. You control a kite tethered to a ground anchor that sways gently side to side at the bottom of the screen. The play area is bounded by visible borders.

**Objective**: Accumulate enough score to reach the stage goal before time runs out or your calm meter empties. The stage goal starts at 1300 and increases by 720 per stage.

**Collectibles**:
- **Lanterns** (amber, most common): Grant score (120 + 12 per stage), add 1.8 seconds to the timer, and count as a rescue. Build your combo.
- **Orbs** (green): Grant 100 score, restore 28 energy and 10 calm.
- **Koi** (orange, rare and fast): Grant 340 score, restore 18 energy and 18 calm, add 3 seconds, count as 2 rescues, and build combo.

**Threats**:
- **Birds** (pink): Home in on the kite. Contact deals 12 calm damage. Can be destroyed by burst or collision (deals 18 damage to them).
- **Storms** (blue clouds): Drift with wind, pulse in size, emit sparks. Contact deals 18 calm damage. Tougher than birds.

**Abilities**:
- **Burst**: Press Space/K to emit a shockwave in a 150-unit radius that damages birds and storms. Costs 24 energy with a 1.8-second cooldown.
- **Reel**: Hold J/Shift to shorten the rope (from max 360 to min 150), pulling the kite inward and resisting wind. Costs 22 energy per second.

**Resources**:
- **Calm** (max 100): Decays at 3.2/s. Depleted by enemy hits. Game over at 0. Restored by orbs (+10) and koi (+18).
- **Energy** (max 100): Regenerates at 16/s. Used for burst and reel abilities. Restored by orbs (+28) and koi (+18).

**Combo**: Successive collections without getting hit build a combo multiplier (up to x30), adding bonus score. The combo resets on hit and times out after 4 seconds of inactivity.

**Stage progression**: Reaching the score goal triggers Stage Clear with a bonus (220 + stage * 90 points). Wind power increases by 22 per stage. Spawn rate increases. The game continues until calm or time reaches zero.

## Public API Reference

### Package `celestial_kite_festival_2026`

> Main entry point.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Initializes window (1280x720), audio device, creates Game instance, and runs the main loop: reads input, calls `update_game`, then `draw_frame` |

### Package `celestial_kite_festival_2026/internal/types`

> Core type definitions, constants, utility functions, and color helpers.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `ObjKind` | `Lantern`, `Bird`, `Storm`, `Orb`, `Koi` | Type of sky object -- collectible or hostile |
| `GameState` | `Title`, `Play`, `StageClear`, `GameOver` | Game state machine states |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `SkyObj` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `w`, `h`, `hp`, `life`, `phase`, `value`, `flagged` | A sky object (lantern, bird, storm, orb, or koi) with physics and lifetime |
| `Spark` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | A particle spark effect with velocity and decay |
| `Halo` | `active`, `x`, `y`, `r`, `life`, `kind` | An expanding ring effect used for burst and collection feedback |
| `Trail` | `active`, `x`, `y`, `life`, `w`, `h`, `rot` | A fading rectangular trail left by the kite |
| `Kite` | `x`, `y`, `vx`, `vy`, `w`, `h`, `angle`, `invuln`, `hurt_t`, `burst_glow`, `reel_glow`, `anim_t` | The player-controlled kite with physics, visual timers, and invulnerability |
| `Game` | `objs`, `sparks`, `halos`, `trails`, `kite`, `state`, `stage`, `score`, `calm`, `energy`, `wind_x`, `wind_y`, `rope_len`, `combo`, ... | Main game state container with all object pools, resources, and input state |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1280` | Screen width |
| `screen_h` | `Int` | `720` | Screen height |
| `target_fps` | `Int` | `120` | Target frame rate |
| `hud_h` | `Int` | `110` | HUD panel height |
| `play_top` | `Float` | `124.0` | Top boundary of play area |
| `play_bottom` | `Float` | `694.0` | Bottom boundary of play area |
| `play_left` | `Float` | `42.0` | Left boundary of play area |
| `play_right` | `Float` | `1238.0` | Right boundary of play area |
| `max_objs` | `Int` | `360` | Maximum sky objects in pool |
| `max_sparks` | `Int` | `900` | Maximum spark particles in pool |
| `max_halos` | `Int` | `90` | Maximum halo effects in pool |
| `max_trails` | `Int` | `320` | Maximum trail elements in pool |
| `kite_w` | `Float` | `54.0` | Kite width |
| `kite_h` | `Float` | `64.0` | Kite height |
| `kite_accel` | `Float` | `1040.0` | Kite acceleration from input |
| `kite_drag` | `Float` | `2.8` | Kite velocity drag coefficient |
| `kite_max_speed` | `Float` | `540.0` | Maximum kite speed |
| `kite_rope_len_min` | `Float` | `150.0` | Minimum rope length when reeling |
| `kite_rope_len_max` | `Float` | `360.0` | Maximum rope length (default) |
| `kite_rope_spring` | `Float` | `9.0` | Spring force when rope is taut |
| `kite_rope_damp` | `Float` | `0.94` | Damping applied when rope constrains |
| `burst_cd_time` | `Float` | `1.8` | Burst ability cooldown in seconds |
| `burst_radius` | `Float` | `150.0` | Burst shockwave radius |
| `burst_cost` | `Float` | `24.0` | Energy cost of burst |
| `reel_energy_cost` | `Float` | `22.0` | Energy cost per second of reeling |
| `reel_rate` | `Float` | `120.0` | Rope shortening rate per second |
| `rope_recover_rate` | `Float` | `52.0` | Rope lengthening rate when not reeling |
| `stage_time_base` | `Float` | `62.0` | Base time per stage in seconds |
| `stage_time_bonus` | `Float` | `12.0` | Additional time per stage level |
| `stage_goal_base` | `Int` | `1300` | Base score goal for stage 1 |
| `stage_goal_bonus` | `Int` | `720` | Additional goal per stage level |
| `calm_max` | `Float` | `100.0` | Maximum calm value |
| `energy_max` | `Float` | `100.0` | Maximum energy value |
| `calm_decay` | `Float` | `3.2` | Calm decay rate per second |
| `energy_regen` | `Float` | `16.0` | Energy regeneration rate per second |
| `wind_base` | `Float` | `48.0` | Base wind power |
| `wind_stage_bonus` | `Float` | `22.0` | Additional wind power per stage |
| `stage_clear_wait` | `Float` | `2.0` | Duration of stage clear screen |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `SkyObj::new` | `() -> SkyObj` | Creates a default inactive sky object |
| `Spark::new` | `() -> Spark` | Creates a default inactive spark particle |
| `Halo::new` | `() -> Halo` | Creates a default inactive halo effect |
| `Trail::new` | `() -> Trail` | Creates a default inactive trail element |
| `Kite::new` | `() -> Kite` | Creates a kite centered on screen with default physics |
| `Game::new` | `() -> Game` | Creates a new game with pre-allocated object pools and default state |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between low and high bounds |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between low and high bounds |
| `minf` | `(Float, Float) -> Float` | Returns the minimum of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns the maximum of two floats |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `sinf` | `(Float) -> Float` | Sine function for floats (radians) |
| `cosf` | `(Float) -> Float` | Cosine function for floats (radians) |
| `sqrtf` | `(Float) -> Float` | Square root for floats |
| `lerpf` | `(Float, Float, Float) -> Float` | Linear interpolation between two floats |
| `ease_out_cubic` | `(Float) -> Float` | Cubic ease-out easing function |
| `randf` | `(Float, Float) -> Float` | Random float in [lo, hi] range |
| `randi` | `(Int, Int) -> Int` | Random integer in [lo, hi] range |
| `chance` | `(Int) -> Bool` | Returns true with given percentage probability |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two points |
| `point_in_rect` | `(Float, Float, Float, Float, Float, Float) -> Bool` | Tests if point is inside rectangle |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Float, Float, Float, Float) -> Bool` | Tests if mouse or any touch point is on a rectangle |
| `sky_top` | `() -> Color` | Returns dark blue sky gradient top color |
| `sky_bottom` | `() -> Color` | Returns medium blue sky gradient bottom color |
| `cyan` | `() -> Color` | Returns cyan accent color |
| `pink` | `() -> Color` | Returns pink accent color |
| `amber` | `() -> Color` | Returns amber/gold accent color |
| `calm_col` | `() -> Color` | Returns calm meter color (pink-red) |
| `energy_col` | `() -> Color` | Returns energy meter color (teal-green) |
| `wind_col` | `() -> Color` | Returns wind indicator color (light blue) |
| `touch_btn_size` | `() -> Float` | Returns touch button size (98.0) |
| `btn_left_rect` | `() -> (Float, Float, Float, Float)` | Returns bounds of the left directional button |
| `btn_right_rect` | `() -> (Float, Float, Float, Float)` | Returns bounds of the right directional button |
| `btn_up_rect` | `() -> (Float, Float, Float, Float)` | Returns bounds of the up directional button |
| `btn_down_rect` | `() -> (Float, Float, Float, Float)` | Returns bounds of the down directional button |
| `btn_burst_rect` | `() -> (Float, Float, Float, Float)` | Returns bounds of the burst action button |
| `btn_reel_rect` | `() -> (Float, Float, Float, Float)` | Returns bounds of the reel action button |
| `title_start_rect` | `() -> (Float, Float, Float, Float)` | Returns bounds of the title screen start button |
| `retry_rect` | `() -> (Float, Float, Float, Float)` | Returns bounds of the game over retry button |
| `is_hostile` | `(ObjKind) -> Bool` | Returns true for Bird and Storm kinds |
| `is_collectible` | `(ObjKind) -> Bool` | Returns true for Lantern, Orb, and Koi kinds |
| `obj_hit_r` | `(SkyObj) -> Float` | Computes collision radius for a sky object |
| `kite_hit_r` | `(Kite) -> Float` | Computes collision radius for the kite |
| `kite_anchor_x` | `(Game) -> Float` | Computes the anchor X position (sways with time) |
| `kite_anchor_y` | `() -> Float` | Returns the anchor Y position (near screen bottom) |
| `a_col` | `(Color, Int) -> Color` | Creates a color copy with modified alpha value |

### Package `celestial_kite_festival_2026/internal/game`

> Game logic: input handling, physics, spawning, AI, and state transitions.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main update entry point: dispatches input and logic by game state, updates timers |
| `init_title_scene_pub` | `(Game) -> Unit` | Public wrapper to initialize the title scene (clears all objects, resets state) |

### Package `celestial_kite_festival_2026/internal/render`

> Rendering and visual effects.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main rendering entry point: draws world with camera shake, HUD, state overlays, touch controls, and damage flash |

## Architecture

### Package Structure

```
celestial_kite_festival_2026/
├── main.mbt              — Entry point: window/audio init, game loop
├── moon.pkg              — Package config, imports
└── internal/
    ├── types/
    │   ├── types.mbt     — Core structs (Game, Kite, SkyObj, Spark, Halo, Trail) and enums (ObjKind, GameState)
    │   ├── constants.mbt — Game tuning constants (physics, timers, pool sizes, stage scaling)
    │   └── utils.mbt     — Math utilities, random helpers, collision tests, color functions, UI rect definitions
    ├── game/
    │   ├── input.mbt     — Input handling for each game state (title, play, result)
    │   └── logic.mbt     — Game logic: spawning, physics, wind, kite movement, collisions, scoring, state transitions
    └── render/
        └── render.mbt    — All drawing: sky/clouds/stars parallax, objects, kite, particles, HUD, overlays, touch UI
```

### Data Flow

1. **Input**: `main.mbt` reads mouse position, touch count, and mouse button state into `Game` fields each frame. `input.mbt` translates keyboard, mouse, and touch into abstract `input_x`, `input_y`, `input_burst_press`, `input_reel_hold`, and `input_restart_press` based on the current `GameState`.

2. **Update**: `update_game` dispatches to state-specific updaters. During `Play`, `update_play` ticks the timer, updates wind direction, moves the kite via `update_kite` (applying acceleration, drag, rope spring constraint), spawns waves of objects via `spawn_step`, updates all objects via `update_objs` (movement, collision with kite), and checks win/loss conditions.

3. **Collision**: `update_objs` checks squared distance between each active object and the kite. Collectibles trigger `collect_obj` (score, resource restoration, combo). Hostiles trigger `hurt_kite` (calm damage, invulnerability frames, screen flash/shake).

4. **Render**: `draw_frame` computes camera shake offset, then layers: gradient sky with parallax stars and clouds, wind lane streaks, play area bounds, anchor and rope line, trails, collectible objects, hostile objects, kite with tail, spark/halo particles, HUD bars, state overlays, and touch button visuals.

### Key Design Patterns

- **Object pool pattern**: Pre-allocated arrays with `active` flags for `SkyObj` (360), `Spark` (900), `Halo` (90), and `Trail` (320). Allocation functions (`alloc_obj`, `alloc_spark`, etc.) find inactive slots or recycle the oldest entry.
- **State machine**: `GameState` enum drives distinct input, update, and render behavior for Title, Play, StageClear, and GameOver states.
- **Spring-damper rope physics**: The kite is constrained to `rope_len` distance from a swaying anchor using spring forces and velocity damping, creating natural tether behavior.
- **Combo multiplier**: `push_combo` and `clear_combo` manage a combo counter (up to 30x) with a 4-second timeout, multiplicatively boosting score gains.
- **Parallax rendering**: Stars, clouds, and wind lanes are offset by camera shake multiplied by different factors (0.1 to 0.2) for depth layering.
- **Touch/keyboard abstraction**: Input is read into abstract fields (`input_x`, `input_y`, `input_burst_press`, `input_reel_hold`) that unify keyboard, mouse, and touch inputs.

## Improvement & Refinement Plan

1. **Add difficulty scaling for bird homing**: Birds currently home toward the kite with a fixed 90.0 acceleration multiplier. Scaling this with `game.stage` would make later stages more challenging, as currently birds use the same tracking intensity throughout.

2. **Implement object type-specific spawn intervals**: The `spawn_wave` function uses uniform random rolls to select object types. Dedicated spawn timers per type would allow finer control over pacing and prevent lucky/unlucky streaks of only hostile or only collectible spawns.

3. **Add rope tension visual feedback**: The rope is drawn with thickness based on stretch ratio in `draw_anchor_and_rope`, but there is no color change. Shifting rope color from white to red as stretch approaches maximum would provide clearer feedback about impending constraint.

4. **Persist best score across sessions**: `best_score` is tracked in the `Game` struct but resets when the game is restarted via `init_title_scene`. Saving to a file would give players a reason to replay.

5. **Add audio feedback**: The game initializes the audio device (`init_audio_device`) but never loads or plays any sounds. Adding wind, collection, burst, and damage sounds would significantly enhance the experience.

6. **Improve storm HP bar accuracy**: The HP bar ratio calculation in `draw_obj` uses hardcoded values (`30.0 + 6 * 1` for storms) instead of referencing the actual stage-scaled HP formula (`28.0 + (stage-1) * 6.0`), causing inaccurate health display on later stages.

7. **Add visual wind direction indicator**: Wind magnitude is shown as text in the HUD, but there is no directional arrow. Adding a wind vector arrow (similar to the wind lanes but in the HUD) would help players anticipate drift direction.
