# Silkroad Caravan Guard 2026

Silkroad Caravan Guard 2026 is a top-down escort defense game set on the ancient Silk Road. The player controls a lone guard who patrols an elliptical perimeter around a three-wagon caravan, fighting off waves of raiders that approach across five undulating desert lanes. The game uses a warm desert palette with parallax dune layers, animated lane markings, and a sun that drifts across a gradient twilight sky.

The core gameplay loop revolves around protecting the caravan while it automatically advances through four checkpoints. The player shoots raiders (J key with auto-aim to nearest target), repairs damaged wagons with limited kits (K key within range), and uses a dodge roll (Space) that grants brief invulnerability and can kill raiders on contact. Raiders come in three types: skirmishers (balanced), brutes (slow but tough, high damage), and riders (fast but fragile). Each raider targets the nearest alive wagon and attacks on a cooldown when in range, dealing damage that also drains caravan morale.

The game manages three primary resources: morale (a 0-100 meter that drains at 1.6/s plus 0.012 per active raider, restored by kills and repairs, game over at zero), ammo (max 42, regenerates on a timer, 22% chance to drop from kills), and repair kits (max 8, 9% chance to drop from raider kills). Checkpoints award score bonuses, restore morale/ammo/kits, and heal all wagons. Reaching all four checkpoints triggers victory; morale reaching zero or all wagons being destroyed ends the run.

## Build and Run

```bash
moon build --target native raylib_silkroad_caravan_guard_2026/
./_build/native/debug/build/raylib_silkroad_caravan_guard_2026/raylib_silkroad_caravan_guard_2026.exe
```

## Controls

- **Left Arrow / A**: Move left
- **Right Arrow / D**: Move right
- **Up Arrow / W**: Move up
- **Down Arrow / S**: Move down
- **J**: Shoot (hold for continuous fire, auto-aims at nearest raider within 950px); also confirms actions on title/end screens
- **K**: Repair nearest damaged wagon (consumes 1 repair kit, requires proximity within 92px)
- **Space**: Dodge roll in movement direction (0.22s duration, 1.02s cooldown, grants invulnerability, kills raiders on contact)
- **P**: Pause / resume
- **R**: Restart the run
- **Enter**: Start game from title screen (alternative to J)
- **F11**: Toggle borderless windowed mode

## How to Play

From the title screen, press J or Enter to begin the escort. Your guard patrols an elliptical ring around the three-wagon caravan. Use WASD/arrows to move along the perimeter (you are constrained between an inner and outer ellipse around the caravan formation).

Raiders spawn from the right side of the screen across five desert lanes and home in on the nearest alive wagon. Press and hold J to shoot -- bullets auto-aim toward the closest raider within range. Each shot costs one ammo, which regenerates slowly over time. Killing raiders earns score, restores morale, and has a chance to drop extra ammo (22%) or a repair kit (9%).

Key mechanics:
- **Morale**: Your primary survival meter (starts at 76/100, max 100). Drains at 1.6/s baseline plus 0.012 per active raider. Increases by 0.9 per kill, 7.5 per repair, and 18 per checkpoint. Decreases when wagons take damage (0.24 per damage point) and when raiders breach your guard (6.4 per hit). When morale reaches zero, the escort fails.
- **Wagons**: Three wagons with 120 HP each. Raiders attack when adjacent, dealing 8-19 damage depending on type. Destroyed wagons cause score loss (-40) and morale penalty (-10). Press K near a damaged wagon to repair it (+34 HP, 0.7s cooldown per wagon).
- **Ammo**: Starts at 26, max 42. Regenerates 1 unit every 0.58s (decreasing slightly with checkpoint). Shoot cooldown is 0.14s. Running out shows "Out of ammo" message.
- **Dodge Roll**: Press Space to roll at 760 speed for 0.22s with 1.02s cooldown. Grants invulnerability during roll plus 0.18s after. Kills any raider you contact while rolling (+18 score).
- **Raider types**: Skirmishers (speed 102-128, HP 46-62, 8-12 damage), Brutes (speed 76-96, HP 84-108, 14-19 damage, larger radius), Riders (speed 132-162, HP 52-72, 9-13 damage). Mix shifts toward tougher types at higher checkpoints.
- **Checkpoints**: Four checkpoints at increasing distances. Reaching each awards score (160 + checkpoint*28), restores 18 morale, adds 10 ammo and 1 repair kit, and heals all wagons by 20 HP. Reaching all four triggers victory.

## Public API Reference

### Package `raylib_silkroad_caravan_guard_2026`

> Main entry point. Initializes window, creates game state, and runs the main loop.

No public types or functions beyond the `main` entry point.

### Package `raylib_silkroad_caravan_guard_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Wagon` | `x`, `y`, `hp`, `max_hp`, `repair_cd` | A caravan wagon with position, health, and repair cooldown |
| `Raider` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `speed`, `hp`, `target_wagon`, `lane`, `attack_cd`, `flash_t`, `radius` | An enemy raider with type, movement, health, attack state, and collision radius |
| `Bullet` | `active`, `x`, `y`, `vx`, `vy`, `life`, `dmg` | A projectile with position, velocity, lifetime, and damage |
| `Dust` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | A particle effect with position, velocity, lifetime, size, and visual type |
| `Player` | `x`, `y`, `vx`, `vy`, `facing_x`, `facing_y`, `roll_t`, `roll_cd`, `roll_dx`, `roll_dy`, `shoot_cd`, `invuln_t`, `repair_t` | The player guard with position, velocity, facing direction, roll state, and cooldown timers |
| `Game` | `wagons`, `raiders`, `bullets`, `dusts`, `hero`, `state`, `score`, `best_score`, `kills`, `checkpoint`, `distance`, `checkpoint_start`, `next_checkpoint`, `morale`, `ammo`, `ammo_regen_t`, `repair_kits`, `spawn_t`, `time_s`, `flash_t`, `shake_t`, `message`, `message_t`, `input_*` | Main game state container with all entity pools, resources, timers, and input state |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1360` | Screen width |
| `screen_h` | `Int` | `820` | Screen height |
| `target_fps` | `Int` | `120` | Target frame rate |
| `state_title` | `Int` | `0` | Title screen state |
| `state_play` | `Int` | `1` | Active gameplay state |
| `state_pause` | `Int` | `2` | Paused state |
| `state_game_over` | `Int` | `3` | Game over (defeat) state |
| `state_victory` | `Int` | `4` | Victory state |
| `wagon_count` | `Int` | `3` | Number of wagons in the caravan |
| `lane_count` | `Int` | `5` | Number of desert lanes raiders approach on |
| `max_raiders` | `Int` | `180` | Object pool size for raiders |
| `max_bullets` | `Int` | `260` | Object pool size for bullets |
| `max_dust` | `Int` | `960` | Object pool size for dust particles |
| `checkpoint_total` | `Int` | `4` | Total checkpoints to reach for victory |
| `checkpoint_base_span` | `Float` | `1400.0` | Distance of first checkpoint |
| `checkpoint_span_step` | `Float` | `220.0` | Additional distance per subsequent checkpoint |
| `caravan_speed_base` | `Float` | `132.0` | Base caravan travel speed |
| `caravan_speed_step` | `Float` | `20.0` | Speed increase per checkpoint |
| `wagon_gap` | `Float` | `148.0` | Horizontal spacing between wagons |
| `wagon_hp_max` | `Float` | `120.0` | Maximum hit points per wagon |
| `player_radius` | `Float` | `16.0` | Player collision radius |
| `player_speed` | `Float` | `320.0` | Player movement speed |
| `player_drag` | `Float` | `8.0` | Player velocity smoothing factor |
| `player_roll_speed` | `Float` | `760.0` | Speed during dodge roll |
| `player_roll_time` | `Float` | `0.22` | Duration of dodge roll |
| `player_roll_cd` | `Float` | `1.02` | Cooldown between dodge rolls |
| `player_invuln_time` | `Float` | `0.72` | Invulnerability duration after being hit |
| `shoot_cd` | `Float` | `0.14` | Cooldown between shots |
| `bullet_speed` | `Float` | `860.0` | Bullet travel speed |
| `bullet_life` | `Float` | `0.82` | Bullet lifetime in seconds |
| `bullet_dmg` | `Float` | `28.0` | Damage per bullet |
| `ammo_max` | `Int` | `42` | Maximum ammo capacity |
| `ammo_regen_base` | `Float` | `0.58` | Base ammo regeneration interval |
| `repair_range` | `Float` | `92.0` | Maximum distance to repair a wagon |
| `repair_heal` | `Float` | `34.0` | HP restored per repair kit |
| `repair_cd` | `Float` | `0.7` | Per-wagon repair cooldown |
| `kit_max` | `Int` | `8` | Maximum repair kits |
| `morale_max` | `Float` | `100.0` | Maximum morale value |
| `morale_decay` | `Float` | `1.6` | Base morale drain per second |
| `morale_kill_gain` | `Float` | `0.9` | Morale gained per raider kill |
| `perimeter_outer_rx` | `Float` | `280.0` | Outer patrol ellipse horizontal radius |
| `perimeter_outer_ry` | `Float` | `195.0` | Outer patrol ellipse vertical radius |
| `perimeter_inner_rx` | `Float` | `154.0` | Inner patrol ellipse horizontal radius |
| `perimeter_inner_ry` | `Float` | `102.0` | Inner patrol ellipse vertical radius |
| `spawn_interval_base` | `Float` | `1.35` | Base time between raider waves |
| `spawn_interval_min` | `Float` | `0.34` | Minimum time between raider waves |
| `raider_skirmisher` | `Int` | `0` | Raider type: balanced stats |
| `raider_brute` | `Int` | `1` | Raider type: slow, tanky, high damage |
| `raider_rider` | `Int` | `2` | Raider type: fast, fragile |
| `desert_lane_top` | `Float` | `228.0` | Y position of topmost lane |
| `desert_lane_gap` | `Float` | `94.0` | Vertical spacing between lanes |
| `tau` | `Float` | `6.283185307179586` | Full circle in radians (2*pi) |
| `caravan_center_x` | `Float` | `screen_w * 0.48` | Horizontal center of caravan formation |
| `caravan_center_y` | `Float` | `screen_h * 0.57` | Vertical center of caravan formation |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Wagon::new` | `(Int) -> Wagon` | Creates a wagon at its slot position with full HP |
| `Raider::new` | `() -> Raider` | Creates an inactive raider with default values |
| `Bullet::new` | `() -> Bullet` | Creates an inactive bullet with default values |
| `Dust::new` | `() -> Dust` | Creates an inactive dust particle with default values |
| `Player::new` | `() -> Player` | Creates a player at the left edge of the outer perimeter |
| `Game::new` | `() -> Game` | Creates a new game instance with pre-allocated object pools and title state |
| `mini` | `(Int, Int) -> Int` | Returns the minimum of two integers |
| `maxi` | `(Int, Int) -> Int` | Returns the maximum of two integers |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between bounds |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between bounds |
| `clamp01` | `(Float) -> Float` | Clamps a float to the 0.0-1.0 range |
| `minf` | `(Float, Float) -> Float` | Returns the minimum of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns the maximum of two floats |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `lerpf` | `(Float, Float, Float) -> Float` | Linearly interpolates between two floats by factor t |
| `sinf` | `(Float) -> Float` | Returns the sine of a radian angle |
| `cosf` | `(Float) -> Float` | Returns the cosine of a radian angle |
| `sqrtf` | `(Float) -> Float` | Returns the square root of a float (returns 0 for non-positive) |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Returns the squared distance between two 2D points |
| `randf` | `(Float, Float) -> Float` | Returns a random float in [lo, hi] |
| `randi` | `(Int, Int) -> Int` | Returns a random integer in [lo, hi] |
| `chance` | `(Int) -> Bool` | Returns true with the given percentage probability (0-100) |
| `checkpoint_span` | `(Int) -> Float` | Calculates the distance span for a given checkpoint index |
| `caravan_speed` | `(Int) -> Float` | Calculates caravan travel speed for a given checkpoint count |
| `wagon_slot_x` | `(Int) -> Float` | Returns the x position for a wagon at the given index |
| `wagon_slot_y` | `(Int) -> Float` | Returns the y position for a wagon at the given index (alternating vertical offset) |
| `lane_base_y` | `(Int) -> Float` | Returns the base y position for a desert lane at the given index |
| `ellipse_norm` | `(Float, Float, Float, Float) -> Float` | Returns the normalized distance from center on an ellipse (1.0 = on edge) |

### Package `raylib_silkroad_caravan_guard_2026/internal/game`

> Game logic, input sampling, and state update systems.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main update function: samples input, handles restart, dispatches to state-specific update (title, play, pause, end) |

### Package `raylib_silkroad_caravan_guard_2026/internal/render`

> Rendering and drawing routines.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main rendering entry point: draws sky, dunes, lanes, perimeter, wagons, raiders, bullets, dust, player, HUD, overlays, and screen flash |

## Architecture

### Package Structure

```
raylib_silkroad_caravan_guard_2026/
├── main.mbt                          -- Entry point: window init, game loop
├── moon.pkg                          -- Root package config
└── internal/
    ├── types/
    │   ├── types.mbt                 -- Wagon/Raider/Bullet/Dust/Player/Game structs and constructors
    │   ├── constants.mbt             -- All tuning constants (screen, states, pools, player, raider, resources, perimeter)
    │   └── utils.mbt                 -- Math utilities, random helpers, checkpoint/caravan calculations, geometry
    ├── game/
    │   ├── input.mbt                 -- Keyboard input sampling and normalization
    │   └── logic.mbt                 -- Spawning, combat, resource management, state transitions, checkpoint progression
    └── render/
        └── render.mbt               -- All drawing: sky, dunes, lanes, perimeter, wagons, raiders, bullets, dust, player, HUD, overlays
```

The game follows a clean types/game/render separation. The `types` package defines all data structures, constants, and math utilities with no game logic. The `game` package handles input sampling and all gameplay systems. The `render` package handles all drawing and visual effects.

### Data Flow

1. **Input**: `update_input` clears all input flags, reads WASD/arrow keys into normalized `input_x`/`input_y`, and samples action key presses (J shoot, K repair, Space roll, P pause, R restart, Enter confirm).
2. **State dispatch**: `update_game` checks for restart, then dispatches to `update_title`, `update_play`, `update_pause`, or `update_end` based on integer state.
3. **Play update**: `update_play` advances time, updates wagon positions (sinusoidal sway), processes hero movement (velocity smoothing or roll override), constrains hero to elliptical ring (`clamp_hero_ring`), attempts shooting (`try_shoot` with auto-aim) and repair (`try_repair` with range check), spawns raider waves, updates raider AI (target wagon, attack, hero collision), processes bullet-raider collisions, updates dust particles, manages resource regeneration/drain, and checks end conditions.
4. **Combat**: `try_shoot` auto-aims at nearest raider, spawns a bullet with normalized direction. `update_bullets` moves bullets and checks collision against all active raiders. `update_raiders` steers raiders toward target wagons, handles attack damage, hero collision (roll kills vs invulnerability knockback), and off-screen cleanup.
5. **Resource management**: `update_resources` regenerates ammo on a timer, calculates morale drain based on active raider pressure (plus heavy drain if all wagons broken), and triggers game over at zero morale.
6. **Checkpoint progression**: `update_progress` advances distance by `caravan_speed * dt` and awards checkpoints when distance thresholds are crossed, granting bonuses and potentially triggering victory.
7. **Rendering**: `draw_frame` layers sky gradient with stars, parallax dune strips, animated lane markings, elliptical perimeter dots with checkpoint progress ring, wagon bodies with HP bars, raider circles with directional triangles, bullet dots, dust particles, player circle with facing line, full HUD panel (morale/ammo/kits bars, score, checkpoint progress bar, controls strip, messages), and state-specific overlays (title, pause, end).

### Key Design Patterns

- **Object pool pattern**: Raiders (180), bullets (260), and dust particles (960) use pre-allocated arrays with `active` flags and allocation functions that recycle the oldest entity when full.
- **Elliptical perimeter constraint**: The hero is confined to an annular ring between inner and outer ellipses around the caravan, creating a natural patrol path using `ellipse_norm` for distance calculation.
- **Integer state machine**: Game states use integer constants (0-4) rather than enums, with conditional dispatch in `update_game` and `draw_frame`.
- **Auto-aim shooting**: `try_shoot` finds the nearest active raider within 950px and normalizes the direction vector, removing the need for manual aiming.
- **Sinusoidal lane animation**: Lane y-positions oscillate with sine/cosine functions incorporating time, lane index, and travel distance, creating a dynamic "shifting dunes" effect.
- **Checkpoint-scaled difficulty**: Raider type probability distributions, raider stats (speed bonuses), spawn interval pressure, and caravan speed all scale with checkpoint count.
- **Camera shake**: `cam_shake` generates random offset during `shake_t > 0`, applied uniformly to all world-space drawing for impact feedback.
- **Dual resource pressure**: Morale (drains continuously, affected by combat) and ammo (consumed by shooting, regenerates slowly) create tension between offensive and defensive play.

## Improvement & Refinement Plan

1. **Replace integer state constants with an enum**: The game uses `state_title = 0`, `state_play = 1`, etc. as integer constants. Converting to a proper `GameState` enum would improve type safety and enable exhaustive match checking.

2. **Add raider variety in visuals**: All three raider types are drawn as circles with different colors and radii. Adding distinct shapes (e.g., triangles for riders, squares for brutes) or body details would make them easier to distinguish at a glance.

3. **Implement wagon destruction effects**: When a wagon reaches 0 HP, only an X is drawn over it. Adding a destruction animation (explosion particles, darkening over time, smoke) would make the loss more impactful.

4. **Add sound effects and music**: The game has no audio. Desert ambience, shooting sounds, raider death effects, checkpoint fanfares, and morale-low warning tones would greatly enhance the experience.

5. **Implement a minimap or radar**: With 180 possible raiders across 5 lanes, threats from off-screen are invisible. A small radar showing raider positions relative to the caravan would improve situational awareness.

6. **Add progressive wave structure**: Currently raiders spawn continuously on a timer. Implementing distinct waves with brief rest periods between them would create natural tension-release cycles and give the player time to repair.

7. **Persist best scores across sessions**: `best_score` resets when the game restarts. Saving it to a file would provide persistent high scores.

8. **Add touch/mouse controls**: The game only supports keyboard input. Adding click-to-move, click-to-shoot, and on-screen buttons for repair/roll would enable mouse and mobile play.
