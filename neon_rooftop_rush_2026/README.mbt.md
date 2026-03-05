# Neon Rooftop Rush 2026

A neon-themed side-scrolling endless runner set atop a cyberpunk cityscape at night. The player sprints automatically across procedurally generated rooftops, leaping over vents and signs, sliding under drones, and using a grapple hook to swing across gaps between buildings. Glowing data chips are scattered along arcing paths above the rooftops, rewarding skillful traversal with score multipliers.

The core gameplay loop centers on stage-based progression: each stage has a distance goal that increases by 620 units per stage. Clearing a stage awards a bonus based on combo count and remaining health, then raises the base scroll speed by 32 units. The scroll speed also ramps continuously at 2.6 units per second within each stage. Four obstacle types -- vents (jump over), signs (slide under), drones (can be destroyed via grapple), and pulsing lasers (dodge during off-phase) -- create a rhythm of jump, slide, and hook actions. Health does not regenerate except for a small 14-point top-up on stage clear, making damage avoidance critical.

The game features a well-separated architecture with dedicated packages for types/constants, game logic/input, and rendering. A combo system multiplies score gain at 6% per combo level, encouraging continuous chip collection and drone takedowns without taking damage.

## Build and Run

```bash
moon build --target native neon_rooftop_rush_2026/
./_build/native/debug/build/neon_rooftop_rush_2026/neon_rooftop_rush_2026.exe
```

## Controls

- **Space / W / Up**: Jump (press again mid-air for double jump)
- **S / Down / Left Shift**: Slide (hold while grounded)
- **J / K / L**: Grapple hook (targets nearest forward anchor point, costs 26 stamina)
- **R**: Restart run
- **Escape**: Return to title screen
- **Enter / Space**: Start game from title / Continue from stage clear
- **Touch**: On-screen buttons for Jump (bottom-right), Slide (bottom-left), and Hook (bottom-right, left of Jump)

## How to Play

1. **Start**: Press Space, Enter, or tap on the title screen to begin a run.
2. **Auto-run**: The player automatically moves right at increasing speed. Focus on timing jumps, slides, and hooks.
3. **Jump**: Press to perform a ground jump. Press again mid-air for a double jump (1 air jump available, resets on landing). Coyote time (0.10s) and jump buffering (0.12s) provide forgiving timing windows.
4. **Slide**: Hold the slide key while grounded to reduce your hitbox height from 88 to 54 pixels for 0.40s. Use this to pass under signs and avoid drone-height obstacles.
5. **Grapple hook**: Press J/K/L to hook onto the nearest anchor point ahead (within 30-320 pixel horizontal range and above the player). This costs 26 stamina and pulls the player upward over 0.34s. Hitting a drone while grappling destroys it for 260 bonus points and combo gain.
6. **Collect chips**: Data chips float in arc patterns above rooftops. Picking them up grants 100+ base points scaled by the combo multiplier (1.0 + combo * 0.06).
7. **Avoid obstacles**: Vents deal 13 damage, signs deal 13 damage (avoid by sliding), drones deal 13 damage (avoid or grapple through them), and lasers deal 18 damage (they pulse on/off -- pass when dim). Each hit grants 0.70s of invulnerability.
8. **Stage progression**: A progress bar shows distance toward the stage goal. Clearing a stage awards a bonus (380 + combo * 14 + health * 4) and heals 14 HP. Subsequent stages are faster and have longer distance goals.
9. **Game over**: When health reaches 0, the run ends. Press R/Enter/Tap to retry. Best score persists during the session.

## Public API Reference

### Package `neon_rooftop_rush_2026`

> Main entry point.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Entry point: creates window, initializes game, runs the update/render loop |

### Package `neon_rooftop_rush_2026/internal/types`

> Core type definitions, constants, utility functions, and color helpers.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1280` | Screen width |
| `screen_h` | `Int` | `720` | Screen height |
| `target_fps` | `Int` | `120` | Target frames per second |
| `state_title` | `Int` | `0` | Title screen state |
| `state_play` | `Int` | `1` | Active gameplay state |
| `state_stage_clear` | `Int` | `2` | Stage clear state |
| `state_game_over` | `Int` | `3` | Game over state |
| `obstacle_vent` | `Int` | `0` | Vent obstacle type |
| `obstacle_sign` | `Int` | `1` | Neon sign obstacle type |
| `obstacle_drone` | `Int` | `2` | Drone obstacle type |
| `obstacle_laser` | `Int` | `3` | Laser obstacle type |
| `max_segments` | `Int` | `96` | Max rooftop segment pool size |
| `max_obstacles` | `Int` | `160` | Max obstacle pool size |
| `max_chips` | `Int` | `220` | Max data chip pool size |
| `max_anchors` | `Int` | `80` | Max grapple anchor pool size |
| `max_particles` | `Int` | `320` | Max particle pool size |
| `world_gravity` | `Float` | `2120.0` | Gravity acceleration |
| `jump_speed` | `Float` | `-780.0` | Initial ground jump velocity |
| `double_jump_speed` | `Float` | `-720.0` | Double jump velocity |
| `slide_duration` | `Float` | `0.40` | Slide action duration in seconds |
| `grapple_duration` | `Float` | `0.34` | Grapple pull duration in seconds |
| `coyote_time` | `Float` | `0.10` | Coyote time grace period |
| `jump_buffer_time` | `Float` | `0.12` | Jump buffer input window |
| `invuln_time` | `Float` | `0.70` | Invulnerability frames after hit |
| `hurt_flash_time` | `Float` | `0.24` | Hurt visual flash duration |
| `stage_intro_time` | `Float` | `1.30` | Stage intro overlay duration |
| `base_scroll_speed` | `Float` | `390.0` | Base horizontal scroll speed |
| `speed_per_stage` | `Float` | `32.0` | Speed increase per stage |
| `speed_ramp_per_second` | `Float` | `2.6` | Continuous speed ramp |
| `stage_base_goal` | `Float` | `1650.0` | Stage 1 distance goal |
| `stage_goal_growth` | `Float` | `620.0` | Distance goal increase per stage |
| `player_spawn_x` | `Float` | `210.0` | Player spawn X position |
| `player_spawn_y` | `Float` | `390.0` | Player spawn Y position |
| `ui_button_size` | `Float` | `104.0` | Touch UI button size |
| `ui_button_gap` | `Float` | `14.0` | Touch UI button gap |
| `particle_spark` | `Int` | `0` | Spark particle kind |
| `particle_glow` | `Int` | `1` | Glow particle kind |
| `particle_hurt` | `Int` | `2` | Hurt particle kind |
| `skyline_layers` | `Int` | `3` | Number of parallax skyline layers |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Segment` | `active`, `x`, `y`, `w`, `h`, `skin`, `neon`, `window_seed` | Rooftop building segment with visual skin and neon color |
| `Obstacle` | `active`, `kind`, `x`, `y`, `w`, `h`, `vx`, `phase`, `hit_lock` | Rooftop obstacle with 4 kinds (vent/sign/drone/laser) |
| `Chip` | `active`, `x`, `y`, `bob_t`, `spin_t` | Collectible data chip with bobbing and spinning animation |
| `Anchor` | `active`, `x`, `y`, `glow_t` | Grapple anchor point with pulsing glow |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | Visual particle with 3 kinds (spark/glow/hurt) |
| `Ghost` | `active`, `x`, `y`, `w`, `h`, `life`, `hue` | Player afterimage trail effect |
| `Player` | `x`, `y`, `w`, `h`, `vy`, `grounded`, `coyote_t`, `jump_buf_t`, `air_jumps`, `slide_t`, `grapple_t`, `grapple_target_y`, `invuln_t`, `hurt_t`, `anim_t`, `floor_y` | Player character with full platformer physics state |
| `Game` | `segments`, `obstacles`, `chips`, `anchors`, `particles`, `ghosts`, `hero`, `state`, `speed`, `distance`, `score`, `best_score`, `combo`, `stage`, `health`, `stamina`, ... | Main game state container with all entity pools and gameplay variables |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Segment::new` | `() -> Segment` | Creates a new inactive segment |
| `Obstacle::new` | `() -> Obstacle` | Creates a new inactive obstacle |
| `Chip::new` | `() -> Chip` | Creates a new inactive chip |
| `Anchor::new` | `() -> Anchor` | Creates a new inactive anchor |
| `Particle::new` | `() -> Particle` | Creates a new inactive particle |
| `Ghost::new` | `() -> Ghost` | Creates a new inactive ghost trail |
| `Player::new` | `() -> Player` | Creates a player at spawn position with default state |
| `Game::new` | `() -> Game` | Creates full game state with all entity pools allocated |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between lo and hi |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between lo and hi |
| `absf` | `(Float) -> Float` | Returns absolute value of a float |
| `maxf` | `(Float, Float) -> Float` | Returns the maximum of two floats |
| `minf` | `(Float, Float) -> Float` | Returns the minimum of two floats |
| `lerpf` | `(Float, Float, Float) -> Float` | Linear interpolation between two floats |
| `approachf` | `(Float, Float, Float) -> Float` | Moves a value toward a target by a fixed step |
| `sinf` | `(Float) -> Float` | Sine function wrapping math.sin |
| `cosf` | `(Float) -> Float` | Cosine function wrapping math.cos |
| `ease_out_quad` | `(Float) -> Float` | Quadratic ease-out curve |
| `ease_in_out` | `(Float) -> Float` | Quadratic ease-in-out curve |
| `randf` | `(Float, Float) -> Float` | Random float in range [lo, hi] |
| `randi` | `(Int, Int) -> Int` | Random integer in range [lo, hi] |
| `chance` | `(Int) -> Bool` | Returns true with given percentage probability |
| `rect_contains` | `(Float, Float, Float, Float, Float, Float) -> Bool` | Point-in-rectangle test |
| `rect_overlap` | `(Float, Float, Float, Float, Float, Float, Float, Float) -> Bool` | AABB overlap test |
| `dist_sq` | `(Float, Float, Float, Float) -> Float` | Squared distance between two points |
| `color_mix` | `(@raylib.Color, @raylib.Color, Float) -> @raylib.Color` | Linearly interpolates between two colors |
| `neon_blue` | `() -> @raylib.Color` | Returns neon blue color (58, 214, 255) |
| `neon_pink` | `() -> @raylib.Color` | Returns neon pink color (255, 88, 182) |
| `neon_lime` | `() -> @raylib.Color` | Returns neon lime color (145, 255, 82) |
| `neon_orange` | `() -> @raylib.Color` | Returns neon orange color (255, 184, 74) |
| `bg_night` | `() -> @raylib.Color` | Returns dark night background color |
| `bg_haze` | `() -> @raylib.Color` | Returns hazy background color |
| `ui_dark` | `() -> @raylib.Color` | Returns dark UI panel color |
| `ui_light` | `() -> @raylib.Color` | Returns light UI text color |
| `button_jump_rect` | `() -> (Float, Float, Float, Float)` | Returns jump button touch rectangle |
| `button_slide_rect` | `() -> (Float, Float, Float, Float)` | Returns slide button touch rectangle |
| `button_grapple_rect` | `() -> (Float, Float, Float, Float)` | Returns grapple button touch rectangle |

### Package `neon_rooftop_rush_2026/internal/game`

> Game logic, input handling, world generation, and entity updates.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(@types.Game, Float) -> Unit` | Main update dispatcher: reads input, dispatches state-specific update |
| `init_title` | `(@types.Game) -> Unit` | Initializes the title screen scene |

### Package `neon_rooftop_rush_2026/internal/render`

> Rendering and drawing routines for all game visuals.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(@types.Game) -> Unit` | Main rendering entry point: draws world, HUD, overlays, and effects |

## Architecture

### Package Structure

```
neon_rooftop_rush_2026/
├── main.mbt                  — Entry point: window init, audio init, game loop
├── moon.pkg                  — Root package config with imports
└── internal/
    ├── types/
    │   ├── types.mbt         — Core structs (Game, Player, Segment, Obstacle, Chip, etc.)
    │   ├── constants.mbt     — Game tuning constants and state/obstacle kind identifiers
    │   └── utils.mbt         — Math utilities, random helpers, easing, collision, colors
    ├── game/
    │   ├── logic.mbt         — World generation, entity spawning, physics, damage, stage management
    │   └── input.mbt         — Input reading for each game state (title, play, stage clear, game over)
    └── render/
        └── render.mbt        — All drawing: skyline parallax, segments, obstacles, hero, HUD, overlays
```

The code follows a clean ECS-like separation: `types` holds all data structures and pure utilities, `game` handles all state mutation and game logic, and `render` is a pure read-only drawing layer. The main package simply wires them together in a standard init-loop-cleanup pattern.

### Data Flow

1. **Input**: `update_game` reads raw mouse/touch state, then dispatches to the appropriate state-specific input handler (`update_title_input`, `update_play_input`, etc.) which maps keyboard/touch to logical flags (`input_jump_press`, `input_slide_hold`, etc.). Touch buttons are detected via `pointer_on_rect` checks against fixed screen-space rectangles.

2. **Update**: After input, the state-specific update function runs. In `update_play`, the sequence is: advance timers, calculate scroll speed with ramp, `shift_world` (moves all entities left by dx), `ensure_world` (spawns new segments/obstacles/chips/anchors ahead), `update_player` (gravity, jump/slide/grapple physics, floor detection via `find_floor`), `update_obstacles` (collision with player hitbox via `hero_hitbox` and `rect_overlap`), `update_chips` (collection via distance check), `update_particles` (fade and physics), and `update_combo_and_score` (distance scoring, combo decay).

3. **Rendering**: `draw_frame` draws in order: parallax skyline (3 layers), anchors, rooftop segments with neon trim and windows, obstacles, chips, particles/ghosts, hero, then HUD and state overlays. Camera shake is applied via `shake_offset`. A screen flash effect fades out after damage or stage clear.

### Key Design Patterns

- **Object pool with eviction**: All entity pools use `alloc_*_slot` functions that first scan for inactive slots, and if full, evict the oldest (leftmost x or lowest life) entry. This prevents allocation failures.
- **State machine with input/update separation**: Game states (title/play/stage_clear/game_over) each have dedicated input and update functions, preventing stale flags when transitioning states.
- **Coyote time and jump buffering**: Player physics includes forgiving platformer mechanics with `coyote_t` (0.10s grace period after leaving edge) and `jump_buf_t` (0.12s pre-landing buffer).
- **Parallax scrolling**: Three skyline background layers scroll at different speeds (0.12 to 0.44 of game distance) creating depth perception.
- **Combo multiplier system**: Score is multiplied by `1.0 + combo * 0.06`, with combo increasing from chip collection and drone grapple kills, and resetting on damage or timer expiry (4s decay).
- **Procedural world generation**: `spawn_stage_chunk` generates rooftop segments with random width/height/gap, populates obstacles probabilistically, and places chip arcs and grapple anchors based on gap size.

## Improvement & Refinement Plan

1. **Replace integer obstacle kinds with an enum**: `obstacle_vent`, `obstacle_sign`, `obstacle_drone`, and `obstacle_laser` are integer constants used throughout `spawn_obstacle`, `update_obstacles`, and `draw_obstacle`. A proper enum would improve pattern matching and prevent invalid values.

2. **Add wall-jump or wall-slide mechanic**: The player currently has no way to recover from narrow gaps without an anchor. Adding wall interaction on segment edges would provide another movement option and reduce reliance on anchor placement RNG.

3. **Implement health pickups**: Health only recovers by 14 on stage clear. Adding rare health chip spawns within chip arcs (perhaps with a distinct color) would reward exploration and extend run length.

4. **Add screen transition effects**: State changes between title/play/stage_clear/game_over are instant. Fade or wipe transitions using the existing `flash_t` system would feel more polished.

5. **Separate touch input into its own module**: Touch input logic (button rectangles, `pointer_on_rect`) is duplicated between `input.mbt` and `render.mbt`. Extracting shared touch button geometry and hit-testing into `types` or a shared utility would remove duplication.

6. **Add obstacle preview indicators**: Signs and lasers can appear suddenly in fast stages. Drawing a warning indicator at the right screen edge for upcoming obstacles would give players more reaction time at high speeds.

7. **Persist best score across sessions**: `best_score` resets when the application restarts. Saving it to a file would provide long-term progression motivation.

8. **Add audio feedback**: The game initializes the audio device (`init_audio_device`) but plays no sounds. Adding jump, grapple, chip collect, damage, and stage clear sound effects would significantly enhance the game feel.
