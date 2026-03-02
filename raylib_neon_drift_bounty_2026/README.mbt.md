# raylib_neon_drift_bounty_2026

A neon top-down vehicular combat game where you pilot a bounty hunter's vehicle through scrolling stages, shooting enemy bikes, drones, and trucks while dodging return fire.

## Build and Run

```bash
cd examples && moon build --target native raylib_neon_drift_bounty_2026/
cd examples && ./_build/native/debug/build/raylib_neon_drift_bounty_2026/raylib_neon_drift_bounty_2026.exe
```

## Controls

- **Mouse / Touch**: Aim and move (touch mode)
- **WASD / Arrow Keys**: Move vehicle
- **J / Space**: Fire weapons (hold)
- **K**: Hack ability (disable enemy shields)
- **Shift**: Boost
- **Enter**: Start game

## How to Play

- Scroll through neon highway stages, destroying enemy vehicles for bounty credits
- Chain kills to build combos for score multipliers
- Manage shield and energy -- boost for speed, hack to disable tough enemies
- Clear the distance goal for each stage to advance
- Collect credits from destroyed enemies to increase your score

## Public API Reference

### Package `raylib_neon_drift_bounty_2026` (root)

| Symbol | Kind | Description |
|--------|------|-------------|
| `main` | `fn` | Initializes the window and audio device, creates the game state, and runs the main frame loop until the window is closed. |

### Package `internal/types`

#### Enumerations

| Symbol | Description |
|--------|-------------|
| `GameState` | High-level game flow states: `Title`, `Play`, `StageClear`, `GameOver`. |
| `EntityKind` | Entity variants: `FoeBike`, `FoeDrone`, `FoeTruck`, `FoeLaser`, `ItemCredit`, `ItemBattery`, `ItemHackcell`. |

#### Structs

| Symbol | Description |
|--------|-------------|
| `Entity` | Active enemy or pickup with position, velocity, dimensions, HP, shoot cooldown, spin, cloak flag, and credit reward. |
| `Bullet` | Projectile from the player or an enemy with position, velocity, lifetime, damage, and kind. |
| `Spark` | Visual spark particle with position, velocity, lifetime, size, and kind for color selection. |
| `GlowRing` | Expanding ring effect with position, radius, lifetime, and kind. |
| `Afterimage` | Speed-trail ghost copy of the player vehicle with position, dimensions, rotation, lifetime, and kind. |
| `Player` | Hero vehicle with position, velocity, dimensions, heading, invulnerability timer, hurt flash, muzzle flash, and engine pulse timers. |
| `Game` | Aggregates all mutable session state: entity/bullet/spark/ring/afterimage pools, player, game flow state, stage, distance, score, credits, combo, shield, energy, ability cooldowns, timers, input flags, and touch state. |

#### Constructors

| Symbol | Description |
|--------|-------------|
| `Entity::new` | Creates a default inactive Entity. |
| `Bullet::new` | Creates a default inactive Bullet. |
| `Spark::new` | Creates a default inactive Spark. |
| `GlowRing::new` | Creates a default inactive GlowRing. |
| `Afterimage::new` | Creates a default inactive Afterimage. |
| `Player::new` | Creates a Player centered on screen at 76% height. |
| `Game::new` | Creates a fully initialized Game with all object pools allocated. |

#### Constants (`internal/types/constants.mbt`)

| Symbol | Value | Description |
|--------|-------|-------------|
| `screen_w` | `1280` | Window width in pixels. |
| `screen_h` | `720` | Window height in pixels. |
| `target_fps` | `120` | Target frame rate. |
| `max_entities` | `380` | Entity pool capacity. |
| `max_bullets` | `440` | Bullet pool capacity. |
| `max_sparks` | `760` | Spark pool capacity. |
| `max_glow_rings` | `80` | Glow ring pool capacity. |
| `max_afterimages` | `220` | Afterimage pool capacity. |
| `lanes_count` | `5` | Number of road lanes. |
| `lane_gap` | `92.0` | Pixel spacing between lanes. |
| `player_w / player_h` | `42 / 74` | Player vehicle hitbox dimensions. |
| `base_scroll_speed` | `280.0` | Initial road scroll speed in px/s. |
| `stage_scroll_gain` | `34.0` | Extra scroll speed added per stage. |
| `stage_distance_base` | `2600.0` | Stage completion distance for stage 1. |
| `stage_distance_gain` | `760.0` | Extra distance goal added per stage. |
| `bullet_speed` | `780.0` | Player bullet velocity. |
| `enemy_bullet_speed` | `390.0` | Enemy bullet velocity. |
| `hack_radius` | `220.0` | Radius of the hack pulse area of effect. |
| `boost_time` | `0.26` | Seconds of active boost per activation. |
| `invuln_after_hit` | `0.62` | Invulnerability window after taking damage. |

#### Utility Functions (`internal/types/utils.mbt`)

| Symbol | Description |
|--------|-------------|
| `clampi(v, lo, hi)` | Clamps an integer to `[lo, hi]`. |
| `clampf(v, lo, hi)` | Clamps a float to `[lo, hi]`. |
| `maxf(a, b)` | Returns the larger of two floats. |
| `minf(a, b)` | Returns the smaller of two floats. |
| `absf(v)` | Returns the absolute value of a float. |
| `lerpf(a, b, t)` | Linearly interpolates between two floats. |
| `sinf(v)` | Sine of an angle in radians. |
| `cosf(v)` | Cosine of an angle in radians. |
| `sqrtf(v)` | Square root of a non-negative float. |
| `randf(lo, hi)` | Pseudo-random float in `[lo, hi]`. |
| `randi(lo, hi)` | Pseudo-random integer in `[lo, hi]`. |
| `chance(pct)` | Returns true with `pct`% probability. |
| `dist2(x0, y0, x1, y1)` | Squared distance between two 2D points. |
| `ease_out_cubic(t)` | Cubic ease-out curve for normalized `t`. |
| `road_center_at(depth, time_s)` | Horizontally swaying road center X at a given scroll depth. |
| `road_half_width(stage, depth, time_s)` | Pulsing road half-width that narrows at higher stages. |
| `lane_to_offset(lane)` | Pixel offset from road center for a lane index. |
| `lane_x(lane, center)` | World X coordinate for a lane at a given road center. |
| `road_edges(stage, depth, time_s)` | Returns `(left, right)` road edge X coordinates. |
| `road_spawn_x(game_depth, game_time, stage, y)` | Random X within the road boundaries at the given Y. |
| `entity_is_hostile(kind)` | True for enemy kinds; false for pickups. |
| `is_pickup(kind)` | True for item kinds; false for enemies. |
| `entity_hit_radius(e)` | Circular collision radius for an entity. |
| `player_hit_radius(hero)` | Circular collision radius for the player. |
| `point_in_rect(x, y, rx, ry, rw, rh)` | True when a point lies inside a rectangle. |
| `pointer_on_rect(mx, my, hold, touch_count, rx, ry, rw, rh)` | True when mouse or any touch point overlaps a rectangle. |
| `bg_top / bg_bottom` | Sky background gradient colors. |
| `road_dark / road_mid` | Road surface fill colors. |
| `neon_yellow / shield_col / energy_col` | Palette colors for UI and effects. |
| `btn_*_rect` | Hit area tuples for all touch buttons (left, right, up, down, fire, boost, hack). |
| `title_start_rect / result_retry_rect` | Hit areas for title start and result retry buttons. |

### Package `internal/game`

#### `input.mbt`

| Symbol | Description |
|--------|-------------|
| `clear_frame_input(game)` | Resets all per-frame input flags to false. |
| `update_title_input(game)` | Reads title screen input and starts a run on any start action. |
| `update_play_input(game)` | Reads keyboard and touch input for movement, fire, boost, hack, and restart during gameplay. |
| `update_result_input(game)` | Reads game-over screen input and sets the restart flag. |

#### `logic.mbt`

| Symbol | Description |
|--------|-------------|
| `clear_entities / clear_bullets / clear_sparks / clear_rings / clear_images(game)` | Deactivates all entries in the respective pool. |
| `reset_player(game)` | Restores the player to the default centered spawn position and zeroes motion. |
| `alloc_entity/bullet/spark/ring/image_slot(game)` | Returns the index of the first free slot in each pool. |
| `emit_spark(game, ...)` | Spawns a single spark particle at a given position with specified velocity and kind. |
| `burst(game, x, y, count, kind)` | Emits `count` sparks with random velocities around `(x, y)`. |
| `spawn_ring(game, x, y, kind)` | Spawns a glow ring at the given position. |
| `emit_image(game, x, y, rot, kind)` | Emits a new afterimage at the given position and rotation. |
| `spawn_bullet(game, x, y, vx, vy, dmg, kind, from_player)` | Fires a bullet with specified parameters. |
| `spawn_entity(game, kind, x, y, hp, w, h, vx, vy, reward)` | Activates a new entity with all parameters. |
| `score_gain(combo)` | Returns the score value of a kill at the current combo. |
| `add_score(game, amount)` | Adds to the score and updates best_score if exceeded. |
| `push_combo(game) / reset_combo(game)` | Increments or resets the combo counter and expiry timer. |
| `damage_player(game, amount)` | Applies damage to shield, triggers hurt effects, and transitions to GameOver at zero. |
| `start_stage(game, stage)` | Sets speed, goal distance, and score for the given stage number. |
| `init_title_scene(game)` | Resets world and player, then configures the title screen state. |
| `start_run(game)` | Resets all pools and stats, then begins stage 1. |
| `spawn_enemy_pack(game)` | Spawns a random wave of enemies at the top of the screen. |
| `spawn_step(game)` | Advances next_spawn_y and calls spawn_enemy_pack if the threshold is reached. |
| `apply_hack_pulse(game)` | Emits the hack ring and damages all cloaked enemies within hack_radius. |
| `shoot_player_bullet(game)` | Fires a player bullet from the muzzle position with fire cooldown management. |
| `apply_player_input(game, dt)` | Applies acceleration, drag, boost, hack, and firing from input flags each frame. |
| `constrain_player_to_road(game)` | Clamps the player's x position to the current road boundaries. |
| `entity_fire(game, e)` | Fires an enemy bullet toward the player from the given entity. |
| `kill_entity(game, e)` | Deactivates an enemy, adds score, pushes combo, and spawns credit drop and effects. |
| `collect_pickup(game, e)` | Applies the effect of collecting a credit, battery, or hackcell pickup. |
| `update_entities(game, dt)` | Ticks entity logic: movement, shooting, player collision, and bullet hit detection. |
| `update_bullets(game, dt)` | Moves bullets, deactivates expired ones, and tests for player-hit collisions. |
| `update_effects(game, dt)` | Advances spark, glow ring, and afterimage lifetimes and despawns expired entries. |
| `emit_ambient_traffic_glow(game)` | Occasionally spawns ambient glow rings near the road edges for atmosphere. |
| `update_timers(game, dt)` | Ticks ability cooldowns, flash, shake, combo, and hint timers. |
| `update_play(game, dt)` | Main gameplay frame: scroll, player, entities, bullets, effects, timers, stage clear detection. |
| `update_title(game, dt)` | Title demo frame: scrolls ambient effects and waits for start input. |
| `update_stage_clear(game, dt)` | Stage-clear frame: runs the delay then advances to the next stage. |
| `update_game_over(game, dt)` | Game-over frame: ticks timers and restarts on retry input. |

#### Public entry points

| Symbol | Description |
|--------|-------------|
| `pub fn update_game(game, dt)` | Dispatches input and simulation for the current game state each frame. |
| `pub fn init_title(game)` | Initializes the game into the title scene. |

### Package `internal/render`

| Symbol | Description |
|--------|-------------|
| `draw_center_text(text, y, size, col)` | Draws horizontally centered text at a given Y. |
| `draw_right_text(text, y, size, col)` | Draws right-aligned text at a given Y. |
| `draw_bar(x, y, w, h, fill, bg, fg, border)` | Draws a filled progress bar with background and border. |
| `alpha_color(col, a)` | Returns a color with a replaced alpha channel. |
| `shake_offset(game)` | Returns a random camera shake displacement. |
| `draw_sky_backdrop(game)` | Draws the vertical gradient sky background. |
| `draw_city_horizon(game)` | Draws parallax silhouette city building layers. |
| `draw_road_surface(game)` | Draws the procedurally swaying neon road. |
| `entity_body_col(kind)` | Returns the primary fill color for an entity kind. |
| `draw_entity_bike/drone/truck/laser/pickup(e, game)` | Draws a specific entity type with kind-appropriate visuals. |
| `draw_entities(game)` | Draws all active entities. |
| `draw_bullets(game)` | Draws all active bullets as colored streaks or orbs. |
| `draw_sparks(game)` | Draws all active spark particles. |
| `draw_rings(game)` | Draws all active glow rings as expanding circles. |
| `draw_afterimages(game)` | Draws all active afterimage ghost trails. |
| `draw_player(game)` | Draws the player vehicle with muzzle flash, engine glow, and boost afterimages. |
| `draw_hack_pulse(game)` | Draws the hack pulse ring visual while hack is active. |
| `cooldown_text(cd, total)` | Returns a cooldown label string for ability buttons. |
| `draw_hud(game)` | Draws the HUD: shield/energy bars, stage progress, score, and ability readout. |
| `draw_button(rect, label, active, col)` | Draws a single touch control button with label. |
| `draw_touch_controls(game)` | Draws all on-screen touch buttons for mobile. |
| `draw_play_hint(game)` | Draws the tutorial hint overlay during early gameplay. |
| `draw_title_overlay(game)` | Draws the title screen with game name, controls, and start prompt. |
| `draw_stage_clear_overlay(game)` | Draws the stage-clear banner and next-stage transition. |
| `draw_game_over_overlay(game)` | Draws the game-over screen with final score and retry prompt. |
| `pub fn draw_world(game)` | Top-level render function: composes sky, city, road, entities, HUD, and overlays. |

## Architecture

```
raylib_neon_drift_bounty_2026/
├── main.mbt                  # Entry point: window init, game loop
└── internal/
    ├── types/
    │   ├── constants.mbt     # All numeric tuning constants
    │   ├── utils.mbt         # Math helpers, road geometry, color/button utilities
    │   └── types.mbt         # Data types: enums, structs, constructors
    ├── game/
    │   ├── input.mbt         # Per-frame input reading (keyboard, mouse, touch)
    │   └── logic.mbt         # Game simulation: physics, AI, combat, progression
    └── render/
        └── render.mbt        # Rendering: sky, road, entities, HUD, overlays
```

### Data flow

```
main.mbt
  └─ update_game(game, dt)          [internal/game/logic.mbt]
       ├─ update_*_input(game)      [internal/game/input.mbt]
       │    └─ reads raylib input → sets game.input_* flags
       └─ update_play / update_title / ... (game, dt)
            ├─ apply_player_input   → player physics, boost, hack, fire
            ├─ constrain_player_to_road
            ├─ update_entities      → enemy AI, collision, rewards
            ├─ update_bullets       → projectile movement, hit detection
            ├─ update_effects       → sparks, rings, afterimages
            └─ update_timers        → cooldowns, combos, stage clear

  └─ draw_world(game)               [internal/render/render.mbt]
       ├─ draw_sky_backdrop
       ├─ draw_city_horizon         (parallax layers)
       ├─ draw_road_surface         (procedural swaying road)
       ├─ draw_entities / draw_bullets / draw_sparks / draw_rings / draw_afterimages
       ├─ draw_player
       ├─ draw_hud
       └─ draw_*_overlay            (title / stage clear / game over)
```

### Key design decisions

- **Object pools**: All entities, bullets, sparks, rings, and afterimages use fixed-size arrays allocated once at startup. Slots are recycled via `alloc_*_slot` functions that scan for the first inactive entry.
- **Procedural road**: The road center and width sway sinusoidally as a function of scroll distance and time, giving an organic curve feel without authored level data.
- **Combo and score scaling**: Every kill calls `score_gain(combo)` which multiplies a base credit value by the current combo. The combo resets on a timer, rewarding sustained aggressive play.
- **Ability system**: Boost grants a short speed surge on a cooldown. Hack emits a pulse that instantly kills cloaked enemies within radius, enabling otherwise difficult encounters. Both are driven by energy.
- **Stage progression**: Stages increase scroll speed by `stage_scroll_gain` and extend the distance goal by `stage_distance_gain`, providing a smooth difficulty ramp without hand-authored levels.
- **Touch and keyboard parity**: Input is abstracted into boolean/float flags on the Game struct, so all downstream logic is input-agnostic.

## Improvement & Refinement Plan

- **Variety in enemy patterns**: Add formation spawning (V-shape, column rush, flanking pairs) and a boss entity with multiple health phases to break up the flat wave cadence.
- **Weapon upgrades**: Introduce a power-up tier system (spread shot, rapid fire, homing missiles) collectable from defeated elite enemies, giving the player a sense of build progression within a run.
- **Dynamic road hazards**: Add oil slicks, barriers, and roadside explosions that the player must dodge even without combat, making the road itself a source of tension.
- **Persistent best-stage tracking**: Track the highest stage reached per session and surface it on the title screen alongside the best score.
- **Audio feedback**: Add engine hum, weapon fire SFX, boost whoosh, explosion bursts, and a combo-streak jingle to reinforce game feel.
- **Difficulty tiers**: Expose an easy/normal/hard mode on the title screen that scales damage taken, enemy fire rate, and spawn density.
- **Afterimage color variety**: Tint afterimages based on the active ability (blue for normal, orange for boost, cyan for hack) to visually communicate player state.
- **Edge-scroll camera lean**: Shift the visible area slightly ahead of the player's horizontal drift to give more reaction time against upcoming threats.
- **Unit tests**: Add `internal/game/logic_test.mbt` to cover score calculation, damage application, combo mechanics, and stage transition boundaries.
- **Reduce render duplication**: Extract a shared `draw_entity_shape(x, y, w, h, col)` helper used by all entity draw functions to reduce repeated rectangle/outline draw calls.
