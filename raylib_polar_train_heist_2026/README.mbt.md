# Polar Train Heist 2026

A side-scrolling action game set on a moving train in a polar landscape. Fight through stages of guards, drones, and turrets while collecting loot, managing armor and heat, and using dash and grappling hook abilities.

## Build and Run

```bash
cd examples && moon build --target native raylib_polar_train_heist_2026/
cd examples && ./_build/native/debug/build/raylib_polar_train_heist_2026/raylib_polar_train_heist_2026.exe
```

## Controls

- **A/D or Left/Right Arrow Keys**: Move left/right
- **W / Up / Space**: Jump (with coyote time and jump buffering)
- **J / Z / Left Mouse**: Fire weapon (hold to auto-fire)
- **Shift / K**: Dash (cooldown-based)
- **L / E**: Grappling hook (pulls nearby enemies, cooldown-based)
- **R / Enter**: Restart
- **Mouse / Touch**: On-screen buttons for movement, jump, fire, dash, and hook

## How to Play

Progress through multi-stage train cars by defeating enemies and traveling the required distance. Guards, drones, and turrets spawn ahead and shoot back. Collect crates for loot, medkits for armor repair, and batteries for heat recovery. Chain kills to build combos for bonus score. The scroll speed increases with each stage. Armor acts as health -- when it runs out, the heist is over.

## Public API Reference

### Package `raylib_polar_train_heist_2026`

> Main entry point.

`main.mbt` initializes the window with MSAA and audio, creates a `Game` struct via `Game::new()`, calls `init_game` to set up the title scene, then runs the frame loop: reading mouse/touch input into the game struct, calling `update_game`, and dispatching `draw_frame` inside `begin_drawing`/`end_drawing`.

### Package `raylib_polar_train_heist_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Ent` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `w`, `h`, `hp`, `lane`, `shot_cd`, `cloak`, `reward` | Runtime entity record for enemies and pickups |
| `Shot` | `active`, `from_player`, `x`, `y`, `vx`, `vy`, `life`, `dmg`, `kind` | Runtime projectile record for player and enemy shots |
| `Fx` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | Runtime particle effect record |
| `Ring` | `active`, `x`, `y`, `r`, `life`, `kind` | Expanding ring effect record |
| `Shadow` | `active`, `x`, `y`, `w`, `h`, `rot`, `life`, `kind` | Soft shadow afterimage effect record |
| `Player` | `x`, `y`, `vx`, `vy`, `lane`, `grounded`, `coyote_t`, `jump_buf_t`, `heading`, `invuln`, `hurt_t`, `muzzle_t` | Mutable player state for movement, combat, and invulnerability |
| `Game` | `ents`, `shots`, `fxs`, `rings`, `shadows`, `hero`, `state`, `stage`, `distance`, `score`, `armor`, `heat`, `dash_cd`, `hook_cd`, `scroll`, `input_*` | Global mutable game state for the polar train heist |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Ent::new` | `() -> Ent` | Creates an inactive entity record with default fields |
| `Shot::new` | `() -> Shot` | Creates an inactive shot record |
| `Fx::new` | `() -> Fx` | Creates an inactive particle effect record |
| `Ring::new` | `() -> Ring` | Creates an inactive ring effect record |
| `Shadow::new` | `() -> Shadow` | Creates an inactive shadow effect record |
| `Player::new` | `() -> Player` | Creates a player initialized on the middle lane |
| `Game::new` | `() -> Game` | Creates a fresh game state with pooled objects and title defaults |
| `btn_size` | `() -> Float` | Returns the square size used by touch controls |
| `btn_left_rect` | `() -> (Float, Float, Float, Float)` | Returns the rectangle for the touch left button |
| `btn_right_rect` | `() -> (Float, Float, Float, Float)` | Returns the rectangle for the touch right button |
| `btn_jump_rect` | `() -> (Float, Float, Float, Float)` | Returns the rectangle for the touch jump button |
| `btn_fire_rect` | `() -> (Float, Float, Float, Float)` | Returns the rectangle for the touch fire button |
| `btn_dash_rect` | `() -> (Float, Float, Float, Float)` | Returns the rectangle for the touch dash button |
| `btn_hook_rect` | `() -> (Float, Float, Float, Float)` | Returns the rectangle for the touch hook button |
| `title_start_rect` | `() -> (Float, Float, Float, Float)` | Returns the rectangle for the title-screen start button |
| `retry_rect` | `() -> (Float, Float, Float, Float)` | Returns the rectangle for the result-screen retry button |
| `bg_top` | `() -> Color` | Returns the top color of the polar background gradient |
| `bg_bottom` | `() -> Color` | Returns the bottom color of the polar background gradient |
| `snow_col` | `() -> Color` | Returns the base snow highlight color |
| `cyan` | `() -> Color` | Returns the cyan accent color |
| `pink` | `() -> Color` | Returns the pink accent color |
| `amber` | `() -> Color` | Returns the amber accent color |
| `armor_col` | `() -> Color` | Returns the armor bar color |
| `heat_col` | `() -> Color` | Returns the heat bar color |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer to the inclusive `[lo, hi]` range |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to the inclusive `[lo, hi]` range |
| `maxf` | `(Float, Float) -> Float` | Returns the larger of two floats |
| `minf` | `(Float, Float) -> Float` | Returns the smaller of two floats |
| `absf` | `(Float) -> Float` | Returns the absolute value |
| `lerpf` | `(Float, Float, Float) -> Float` | Linearly interpolates from `a` to `b` by `t` |
| `sinf` | `(Float) -> Float` | Computes the sine of a value in radians |
| `cosf` | `(Float) -> Float` | Computes the cosine of a value in radians |
| `sqrtf` | `(Float) -> Float` | Computes the square root |
| `randf` | `(Float, Float) -> Float` | Returns a random float in `[lo, hi]` |
| `randi` | `(Int, Int) -> Int` | Returns a random integer in `[lo, hi]` |
| `chance` | `(Int) -> Bool` | Returns true with probability `pct / 100` |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Returns squared distance between two points |
| `ease_out_cubic` | `(Float) -> Float` | Applies an ease-out cubic curve to a normalized value |
| `lane_y` | `(Int) -> Float` | Returns the world y-coordinate of a lane center |
| `is_hostile` | `(Int) -> Bool` | Returns whether an entity kind is hostile |
| `is_pickup` | `(Int) -> Bool` | Returns whether an entity kind is a pickup |
| `ent_hit_r` | `(Ent) -> Float` | Returns collision radius used for an entity |
| `player_hit_r` | `(Player) -> Float` | Returns collision radius used for the player |
| `point_in_rect` | `(Float, Float, Float, Float, Float, Float) -> Bool` | Returns whether a point lies inside a rectangle |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Float, Float, Float, Float) -> Bool` | Returns whether active mouse or touch input is inside a rectangle |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1280` | Window width in pixels |
| `screen_h` | `Int` | `720` | Window height in pixels |
| `target_fps` | `Int` | `120` | Target frame rate for gameplay |
| `state_title` | `Int` | `0` | Title screen state id |
| `state_play` | `Int` | `1` | Active heist gameplay state id |
| `state_stage_clear` | `Int` | `2` | Stage-clear transition state id |
| `state_game_over` | `Int` | `3` | Game-over state id |
| `ent_guard` | `Int` | `0` | Entity kind id for patrol guards |
| `ent_drone` | `Int` | `1` | Entity kind id for flying drones |
| `ent_turret` | `Int` | `2` | Entity kind id for stationary turrets |
| `ent_crate` | `Int` | `3` | Entity kind id for explosive crates |
| `ent_medkit` | `Int` | `4` | Entity kind id for armor pickups |
| `ent_battery` | `Int` | `5` | Entity kind id for heat pickups |
| `ent_signal` | `Int` | `6` | Entity kind id for signal loot pickups |
| `max_ents` | `Int` | `380` | Maximum entities tracked in the pool |
| `max_shots` | `Int` | `460` | Maximum projectiles tracked in the pool |
| `max_fx` | `Int` | `800` | Maximum spark effects tracked in the pool |
| `max_rings` | `Int` | `76` | Maximum ring effects tracked in the pool |
| `max_shadows` | `Int` | `220` | Maximum shadow effects tracked in the pool |
| `player_w` | `Float` | `42.0` | Player collision width |
| `player_h` | `Float` | `76.0` | Player collision height |
| `gravity` | `Float` | `1550.0` | Downward acceleration |
| `jump_speed` | `Float` | `680.0` | Initial vertical velocity for jumps |
| `dash_cd_time` | `Float` | `1.4` | Dash cooldown duration |
| `dash_speed` | `Float` | `600.0` | Dash horizontal speed |
| `hook_cd_time` | `Float` | `2.3` | Hook ability cooldown duration |
| `hook_radius` | `Float` | `240.0` | Hook effect radius |
| `base_scroll` | `Float` | `250.0` | Base world scroll speed |
| `stage_goal_base` | `Float` | `2200.0` | Base distance goal for stage completion |
| `armor_max` | `Float` | `100.0` | Maximum armor meter value |
| `heat_max` | `Float` | `100.0` | Maximum heat meter value |
| `lane_count` | `Int` | `3` | Number of vertical lanes on the train route |
| `hud_h` | `Int` | `112` | Height of the HUD area in pixels |

### Package `raylib_polar_train_heist_2026/internal/game`

> Game logic, input handling, and update systems.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `init_game` | `(Game) -> Unit` | Initializes runtime state to the title scene defaults |
| `update_game` | `(Game, Float) -> Unit` | Advances one frame of simulation, input, and state transitions |

### Package `raylib_polar_train_heist_2026/internal/render`

> Rendering and drawing routines.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Renders the full frame for the current polar train heist state |

## Architecture

### Package Structure

```
raylib_polar_train_heist_2026/
├── main.mbt               — Window init, audio init, game loop
└── internal/
    ├── types/             — Structs, constants, and pure utility functions
    │   ├── types.mbt      — Game, Player, Ent, Shot, Fx, Ring, Shadow structs and constructors
    │   ├── constants.mbt  — All numeric constants and UI layout helpers
    │   └── utils.mbt      — Math helpers, RNG, lane geometry, hit-test functions
    ├── game/              — Simulation and input
    │   ├── input.mbt      — Keyboard/mouse/touch input mapped into normalized game inputs
    │   └── logic.mbt      — Entity spawning, physics, combat, score, state transitions
    └── render/            — Drawing
        └── render.mbt     — Sky, mountains, train body, entities, HUD, overlays, effects
```

Data flows top-down each frame: `main.mbt` gathers raw pointer data into `Game`, then `update_game` processes input, advances physics and AI, and transitions state. `draw_frame` reads the same `Game` struct to produce the frame — no mutable state is shared between logic and rendering beyond `Game` itself. Object pools (`Array[Ent]`, `Array[Shot]`, etc.) are pre-allocated in `Game::new()` and recycled each frame using linear scans, avoiding allocation in the hot path. The three-lane layout is a virtual coordinate system: `lane_y(i)` maps integer lane indices to screen-space Y values, and all entity placement uses this indirection.

## Improvement & Refinement Plan

1. Replace linear pool scans in `alloc_ent`, `alloc_shot`, etc. with a free-list index to eliminate O(n) allocation cost as pool sizes grow.
2. Add persistent best-score storage via a simple file write so the best score survives between sessions.
3. Introduce a stamina or shield pickup variant to give players more meaningful resource trade-offs alongside armor and heat.
4. Add a brief invulnerability grace period when advancing to a new stage so the transition does not immediately punish the player.
5. Emit distinct audio cues (via raylib audio) for dash, hook, kill, and damage events to reinforce gameplay feedback.
6. Expose scroll speed and stage goal as configurable difficulty presets (easy/normal/hard) rather than purely linear progression.
7. Draw the background aurora bands and stars into a render texture once per stage change instead of every frame to reduce per-frame overdraw.
