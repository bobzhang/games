# Abyss Signal Runner 2026

A deep-sea survival runner where you pilot a submersible scout through procedurally generated cave systems. The game blends vertical-scrolling dodge mechanics with resource management, set in a bioluminescent abyss filled with rocks, mines, data nodes, oxygen pickups, ocean currents, and salvageable scrap.

The core gameplay loop has the player navigating a narrowing, sinusoidal cave corridor that scrolls upward at increasing speed. Obstacles spawn in randomized waves, some cloaked and invisible until revealed by the sonar pulse ability. The player must balance aggressive scoring (collecting data and scrap for combo multipliers) against survival (avoiding hull damage from rocks and mines, maintaining oxygen that constantly drains). A dash ability grants brief invulnerability and can destroy obstacles on contact. Each stage has a depth goal; reaching it grants a hull/oxygen bonus and advances to a harder stage with faster scrolling and narrower cave walls.

Technically, the game features a procedural cave system driven by layered sine functions (`cave_center` and `cave_half_width`), an object pool architecture for all entities and particles, a combo scoring system with time decay, and full touch-screen control support with on-screen directional and action buttons alongside keyboard input.

## Build and Run

```bash
moon build --target native abyss_signal_runner_2026/
./_build/native/debug/build/abyss_signal_runner_2026/abyss_signal_runner_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move the submersible in four directions (hold for continuous acceleration)
- **Shift / K**: Dash in the current movement direction (1.3s cooldown, grants brief invulnerability, destroys obstacles on contact)
- **Space / J / L**: Sonar pulse (2.1s cooldown, reveals cloaked objects within 220px radius, destroys mines within 70px)
- **R / Enter**: Restart the game
- **Touch controls**: On-screen directional pad (left cluster: left/right/up/down) and action buttons (right side: DASH and SONAR)
- **Mouse click / Tap**: Start game from title screen, retry from game over screen

## How to Play

From the title screen, press Space, Enter, or click/tap "START DIVE" to begin. Your submersible automatically descends through the abyss (the cave scrolls upward). Steer with WASD or arrow keys to avoid obstacles and collect pickups.

**Obstacles and hazards:**
- **Rocks**: Gray circles that deal 16 hull damage on contact. Dash through them to destroy them for 60 points.
- **Mines**: Pink pulsating circles with spike lines that deal 26 hull damage and self-destruct. Dash or active sonar destroys them for 110-120 points. In stage 2+, some mines are cloaked.
- **Currents**: Purple ring zones that push your submersible in their velocity direction. Cannot be destroyed.

**Collectibles:**
- **Data nodes**: Green diamond shapes worth 100 points. Also restore 2 oxygen. In stage 4+, some are cloaked.
- **Oxygen pickups**: Blue circles labeled "O2" that restore 24 oxygen and give 40 points. Spawn more frequently when oxygen is below 36%.
- **Scrap**: Gold rectangles worth 80 points that build your combo.

**Resource management:** Oxygen drains at a base rate of 3/s plus a speed-dependent bonus. Dashing also burns extra oxygen. Running out of oxygen ends the game. Hull starts at 100; hitting cave walls deals 12 damage, and direct obstacle hits deal 16-26. Hull reaching zero also ends the game.

**Combo system:** Collecting data, scrap, or destroying mines with dash/sonar builds your combo counter (max 18x). The combo decays after 3.4 seconds of no combo activity. Higher combo gives a score bonus calculated as `base + base * combo / 4`.

**Stage progression:** Each stage has a depth goal (starting at 1900, increasing by 620 per stage). Reaching the goal clears the stage, grants a 300 + stage*120 point bonus, partially restores hull (+12) and oxygen (+36 at stage transition), and advances to the next stage where scroll speed increases by 24/s and cave walls narrow by 8px per side.

## Public API Reference

### Package `abyss_signal_runner_2026`

> Main entry point. Initializes a 1280x720 window with MSAA 4x and audio device, creates the game state, and runs the frame loop at 120 FPS.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Entry point: window/audio init, input polling (mouse position, touch count, hold state), game update, and draw loop |

### Package `abyss_signal_runner_2026/internal/types`

> Core type definitions, layout/gameplay constants, color palette, utility math, cave generation, and UI rectangle helpers.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `StageClear`, `GameOver` | State machine controlling input dispatch and rendering |
| `ObjKind` | `Rock`, `Mine`, `Data`, `Oxygen`, `Current`, `Scrap` | Object type classification for collision and rendering behavior |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Obj` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `r`, `cloak`, `spin`, `life` | A pooled game object (obstacle or pickup) with position, velocity, radius, cloaking flag, and lifetime |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | A visual particle for burst effects and ambience |
| `Ripple` | `active`, `x`, `y`, `r`, `life`, `kind` | An expanding ring visual effect for sonar pulses and pickups |
| `Trail` | `active`, `x`, `y`, `w`, `h`, `life`, `kind` | A rectangular trail segment left by the player or dash effect |
| `Player` | `x`, `y`, `vx`, `vy`, `r`, `invuln`, `hurt_t`, `anim_t` | Player submersible state including position, velocity, collision radius, and timers |
| `Game` | `objs`, `particles`, `ripples`, `trails`, `hero`, `state`, `stage`, `distance`, `score`, `hull`, `oxygen`, `combo`, ... | Main game state container holding all entity pools, player, resources, timers, and input state |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Obj::new` | `() -> Obj` | Creates an inactive object with zeroed fields |
| `Particle::new` | `() -> Particle` | Creates an inactive particle with zeroed fields |
| `Ripple::new` | `() -> Ripple` | Creates an inactive ripple with zeroed fields |
| `Trail::new` | `() -> Trail` | Creates an inactive trail with zeroed fields |
| `Player::new` | `() -> Player` | Creates a player at screen center-bottom with default radius and zero velocity |
| `Game::new` | `() -> Game` | Creates a new game in Title state with pre-allocated object pools (420 objs, 560 particles, 64 ripples, 180 trails) |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between low and high bounds |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between low and high bounds |
| `maxf` | `(Float, Float) -> Float` | Returns the larger of two floats |
| `minf` | `(Float, Float) -> Float` | Returns the smaller of two floats |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `sinf` | `(Float) -> Float` | Computes sine of a float via `@math.sin` |
| `cosf` | `(Float) -> Float` | Computes cosine of a float via `@math.cos` |
| `sqrtf` | `(Float) -> Float` | Computes square root of a float |
| `randf` | `(Float, Float) -> Float` | Returns a random float in [lo, hi] using raylib's RNG |
| `randi` | `(Int, Int) -> Int` | Returns a random integer in [lo, hi] |
| `chance` | `(Int) -> Bool` | Returns true with p% probability (0-99 scale) |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Returns squared distance between two 2D points |
| `ease_out_quad` | `(Float) -> Float` | Quadratic ease-out curve for animation |
| `cave_center` | `(Float, Float) -> Float` | Computes the horizontal center of the cave at a given depth and time using layered sines |
| `cave_half_width` | `(Float, Float, Int) -> Float` | Computes the half-width of the cave corridor, narrowing with stage progression |
| `bg_top` | `() -> @raylib.Color` | Returns the dark navy background gradient top color |
| `bg_bottom` | `() -> @raylib.Color` | Returns the dark teal background gradient bottom color |
| `cave_glow` | `() -> @raylib.Color` | Returns the cyan cave edge glow color |
| `hazard_col` | `() -> @raylib.Color` | Returns the pink hazard (mine/damage) color |
| `data_col` | `() -> @raylib.Color` | Returns the green data node color |
| `oxygen_col` | `() -> @raylib.Color` | Returns the light blue oxygen pickup color |
| `phase_col` | `() -> @raylib.Color` | Returns the purple current/phase color |
| `hp_col` | `() -> @raylib.Color` | Returns the pink hull HP bar color |
| `btn_size` | `() -> Float` | Returns the size of touch control buttons (102px) |
| `btn_left_rect` | `() -> (Float, Float, Float, Float)` | Returns the bounding rectangle for the touch left-move button |
| `btn_right_rect` | `() -> (Float, Float, Float, Float)` | Returns the bounding rectangle for the touch right-move button |
| `btn_up_rect` | `() -> (Float, Float, Float, Float)` | Returns the bounding rectangle for the touch up-move button |
| `btn_down_rect` | `() -> (Float, Float, Float, Float)` | Returns the bounding rectangle for the touch down-move button |
| `btn_dash_rect` | `() -> (Float, Float, Float, Float)` | Returns the bounding rectangle for the touch dash button |
| `btn_sonar_rect` | `() -> (Float, Float, Float, Float)` | Returns the bounding rectangle for the touch sonar button |
| `point_in_rect` | `(Float, Float, Float, Float, Float, Float) -> Bool` | Tests if a point (x,y) is inside a rectangle (rx,ry,rw,rh) |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Float, Float, Float, Float) -> Bool` | Tests if mouse or any touch point is inside a rectangle |
| `title_start_rect` | `() -> (Float, Float, Float, Float)` | Returns the bounding rectangle for the title screen start button |
| `restart_rect` | `() -> (Float, Float, Float, Float)` | Returns the bounding rectangle for the game over retry button |
| `depth_at_screen` | `(Game, Float) -> Float` | Converts a screen Y coordinate to an absolute depth value |
| `cave_edges` | `(Game, Float) -> (Float, Float)` | Returns the left and right cave wall X positions at a given screen Y |
| `alloc_trail` | `(Game) -> Int` | Finds an inactive trail slot or evicts the lowest-lifetime trail |
| `emit_trail` | `(Game, Float, Float, Float, Float, Float, Int) -> Unit` | Emits a trail segment at the given position with specified size, lifetime, and kind |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1280` | Window width |
| `screen_h` | `Int` | `720` | Window height |
| `target_fps` | `Int` | `120` | Target frame rate |
| `max_objs` | `Int` | `420` | Object pool capacity |
| `max_particles` | `Int` | `560` | Particle pool capacity |
| `max_ripples` | `Int` | `64` | Ripple pool capacity |
| `max_trails` | `Int` | `180` | Trail pool capacity |
| `player_r` | `Float` | `22.0` | Player collision radius |
| `base_scroll` | `Float` | `210.0` | Base vertical scroll speed (px/s) |
| `stage_scroll_gain` | `Float` | `24.0` | Additional scroll speed per stage |
| `player_accel` | `Float` | `920.0` | Player acceleration from input (px/s^2) |
| `player_drag` | `Float` | `2.0` | Velocity drag coefficient |
| `player_max_speed` | `Float` | `360.0` | Maximum player speed |
| `oxygen_drain` | `Float` | `3.0` | Base oxygen drain per second |
| `oxygen_data_bonus` | `Float` | `2.0` | Oxygen restored per data node collected |
| `oxygen_pickup` | `Float` | `24.0` | Oxygen restored per O2 pickup |
| `sonar_cd_time` | `Float` | `2.1` | Sonar cooldown duration |
| `sonar_time` | `Float` | `0.76` | Sonar active duration |
| `sonar_reveal_r` | `Float` | `220.0` | Sonar reveal radius |
| `sonar_destroy_r` | `Float` | `70.0` | Sonar mine destruction radius |
| `dash_cd_time` | `Float` | `1.3` | Dash cooldown duration |
| `dash_time` | `Float` | `0.19` | Dash active duration |
| `dash_speed` | `Float` | `560.0` | Dash velocity magnitude |
| `invuln_time` | `Float` | `0.62` | Invulnerability duration after taking damage |
| `stage_base_goal` | `Float` | `1900.0` | Depth goal for stage 1 |
| `stage_goal_gain` | `Float` | `620.0` | Additional depth goal per stage |
| `stage_clear_delay` | `Float` | `1.8` | Auto-advance delay after stage clear |
| `spawn_start_y` | `Float` | `-120.0` | Initial spawn Y offset (above screen) |
| `spawn_spacing_min` | `Float` | `70.0` | Minimum vertical spacing between spawn waves |
| `spawn_spacing_max` | `Float` | `170.0` | Maximum vertical spacing between spawn waves |
| `cave_min_half` | `Float` | `150.0` | Minimum cave half-width |
| `cave_max_half` | `Float` | `290.0` | Maximum cave half-width |
| `cave_x_margin` | `Float` | `84.0` | Margin from cave walls for object spawning |

### Package `abyss_signal_runner_2026/internal/game`

> Game logic: input handling, player physics, object spawning/updating, collision detection, stage management, and particle/timer updates.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(@types.Game, Float) -> Unit` | Public per-frame update: advances time, handles input dispatch by state, updates timers, then dispatches to state-specific logic (title/play/stage-clear/game-over) |
| `init_game` | `(@types.Game) -> Unit` | Public initialization: sets up the title scene with cleared pools and default state |

### Package `abyss_signal_runner_2026/internal/render`

> All rendering: backdrop, procedural cave walls, objects, particles, trails, ripples, player, HUD, touch controls, and state overlays.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(@types.Game) -> Unit` | Public per-frame render: clears background, computes camera shake offset, draws backdrop/cave/world/signal-pulse/flash/HUD, then dispatches to state-specific overlays (title/play-hint/touch-controls/stage-clear/game-over) |

## Architecture

### Package Structure

```
abyss_signal_runner_2026/
├── main.mbt              — Entry point: window/audio init, input polling, game loop
├── moon.pkg              — Package config, imports
└── internal/
    ├── types/
    │   ├── types.mbt     — GameState/ObjKind enums, Obj/Particle/Ripple/Trail/Player/Game structs, constructors
    │   ├── constants.mbt — Screen size, pool limits, physics tuning, ability timers, cave parameters
    │   └── utils.mbt     — Math (clamp/abs/sin/cos/sqrt/rand), cave generation, color palette, UI rects, pool helpers
    ├── game/
    │   ├── logic.mbt     — State updates, player physics, object spawning/collision, abilities, stage management
    │   └── input.mbt     — Per-state input handlers for keyboard, mouse, and touch
    └── render/
        └── render.mbt    — Drawing: backdrop, cave walls, objects by kind, particles/trails/ripples, player, HUD, overlays
```

The `types` package owns all data structures and is imported by both `game` and `render`. The `game` package handles all mutations to game state. The `render` package is purely read-only, drawing based on the current state. The root package wires everything together with a minimal main loop that polls raw input (mouse position, touch count, hold state) and passes it to the game update.

### Data Flow

1. **Input collection**: `main.mbt` reads raw mouse position and touch state into `game.mx`, `game.my`, `game.hold`, `game.touch_count` each frame. Then `update_game` dispatches to `update_title_input`, `update_play_input`, or `update_result_input` which translate raw input into normalized fields (`input_x`, `input_y`, `input_dash_press`, `input_sonar_press`, `input_restart_press`).

2. **State update**: `update_game` calls `update_timers` to decay all cooldowns and effect timers, then dispatches to the current state's update function. During `Play`, `update_play` advances distance, calls `apply_player_input` for physics, `resolve_cave_hit` for wall collisions, `spawn_step` for obstacle generation, `update_objects` for movement/collision, and `update_particles` for visual effects.

3. **Collision resolution**: `update_objects` iterates the object pool, moves objects, checks lifetime, then tests circle-circle collision against the player. Each `ObjKind` has distinct collision behavior (damage, score, resource pickup, velocity push for currents). The dash flag (`dash_t > 0`) changes rock/mine collisions from harmful to destructive.

4. **Rendering**: `draw_frame` computes a camera shake offset, draws the layered background (gradient + ambient circles + star dots), renders the procedural cave walls via `draw_cave` (iterating screen rows and drawing dark rectangles outside cave edges with glowing edge lines), then layers world entities, HUD bars, and state-specific overlays.

### Key Design Patterns

- **Object pool architecture**: All entities (`Obj`, `Particle`, `Ripple`, `Trail`) use pre-allocated fixed-size arrays with `active` flags. Allocation functions (`alloc_obj`, `alloc_particle`, `alloc_ripple`, `alloc_trail`) scan for inactive slots or evict the lowest-lifetime entry, preventing runtime allocation.
- **State machine**: `GameState` enum drives a two-level dispatch: first for input handling, then for update logic, and finally for rendering. Each state has its own dedicated functions.
- **Procedural cave generation**: Cave walls are computed analytically from two layered sine waves in `cave_center` and a wobble function in `cave_half_width`, parameterized by depth and time, creating an infinitely scrolling environment without stored level data.
- **Unified touch/keyboard input**: The input system writes to normalized `input_x`/`input_y`/`input_*_press` fields that abstract over keyboard keys, mouse clicks, and multi-touch points, enabling seamless mobile and desktop play.
- **Ability cooldown system**: Dash and sonar each have a `_cd` (cooldown remaining) and `_t` (active duration) timer that gate activation and influence collision rules (dash grants invulnerability, active sonar changes mine collision to destruction).
- **Delta time with clamping**: The main loop clamps dt to 0.033s (30 FPS minimum) to prevent physics explosions during frame hitches, while targeting 120 FPS for smooth animation.

## Improvement & Refinement Plan

1. **Difficulty curve smoothing**: The `scroll_speed` in `update_play` has a linear distance-based bonus (`distance * 0.008` capped at 52) plus a per-stage increase. Adding an easing function to the within-stage speed ramp would prevent sudden difficulty spikes at stage transitions.

2. **Object pool overflow handling**: `alloc_obj` evicts the object with the highest Y value when the pool is full, which can remove objects the player hasn't yet encountered. Tracking pool utilization and throttling `spawn_wave` when capacity exceeds 80% would prevent premature eviction.

3. **Separated cave generation from rendering**: `cave_center` and `cave_half_width` in `utils.mbt` are called by both `game/logic.mbt` (for collision in `resolve_cave_hit` and `object_spawn_x`) and `render/render.mbt` (for drawing). Caching cave edges per frame in a lookup table would avoid redundant sine computations.

4. **Audio feedback integration**: The main loop initializes an audio device (`init_audio_device`) but no sound effects are loaded or played. Adding sonar ping, dash whoosh, collision impact, and data pickup sounds would significantly enhance the game feel.

5. **Combo decay visualization**: The combo counter decays after 3.4 seconds (`combo_t` in `push_combo`), but the HUD only shows "COMBO x{n}" with an alpha fade. Adding a visible countdown bar or ring around the combo display would help players time their pickups.

6. **Current visualization improvement**: `draw_obj_current` draws concentric rings and a directional arrow, but the push direction is not intuitive. Adding animated flow lines or particle streams along the current's velocity vector in `draw_objects` would better communicate the push direction to the player.

7. **Oxygen drain balancing**: Oxygen drain is constant at 3/s baseline plus speed-dependent and dash-dependent components. At high stages where scroll speed is fast and dashing is essential for survival, oxygen depletion becomes the primary death cause. Scaling `oxygen_data_bonus` with stage number or increasing O2 pickup spawn rates at higher stages would maintain balanced difficulty.
