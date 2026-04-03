# Platformer 3D

Platformer 3D is a third-person 3D platformer built with MoonBit and raylib, featuring a full campaign of 20 levels spread across four themed worlds: Green Hills, Crystal Caves, Lava Peaks, and Sky Fortress. The player controls a cube-shaped character navigating floating platforms in 3D space, collecting gems, coins, stars, and keys while avoiding enemies and environmental hazards.

The core gameplay loop involves jumping between platforms of varying types -- static, moving (along X/Y/Z axes), bouncy, falling, crumbling, ice, phasing, rotating, conveyor, and size-pulsing -- to reach a golden goal crystal at the end of each level. The player can wall-jump, double-jump (via power-up), dash with Left Shift, and stomp enemies from above. A combo system rewards rapid successive collectible pickups with score multipliers up to 5x. Power-ups including Double Jump, Speed Boost, Shield, Magnet, and Slow Fall add tactical variety. Checkpoints placed on static platforms allow respawning mid-level upon death.

Technically, the game uses a full object-pool architecture with pre-allocated arrays for all entities (128 platforms, 64 collectibles, 32 enemies, 512 particles, etc.), avoiding runtime allocation during gameplay. The camera orbits the player with smooth interpolation, supports rotation (Q/E) and zoom (+/-), and features shake effects on impacts. A 3-star rating system based on completion time, gem collection, and zero-death runs provides replayability across all 20 levels.

## Build and Run

```bash
moon build --target native platformer_3d/
./_build/native/debug/build/platformer_3d/platformer_3d.exe
```

## Controls

- **W/Up Arrow**: Move forward (relative to camera)
- **S/Down Arrow**: Move backward (relative to camera)
- **A/Left Arrow**: Move left (relative to camera)
- **D/Right Arrow**: Move right (relative to camera)
- **Space**: Jump (supports jump buffering and coyote time; wall-jump when sliding; double-jump with power-up)
- **Left Shift**: Dash in movement direction (0.15s burst, 0.6s cooldown)
- **Q**: Rotate camera left
- **E**: Rotate camera right
- **+ (Equal)**: Zoom camera in
- **- (Minus)**: Zoom camera out
- **P / Escape**: Pause game
- **Enter/Space**: Confirm menu selection, advance to next level
- **M**: Return to menu (from level complete or game over)
- **Up/Down Arrows**: Navigate menu items
- **Left/Right Arrows**: Navigate world select / level select grid

## How to Play

From the main menu, choose New Game to start the campaign at World 1, Level 1, or use World Select / Level Select to jump to any level. Each level consists of a series of floating platforms leading to a golden goal crystal. Reach the goal to complete the level.

Collect green gems (10 pts), yellow stars (50 pts), bronze/silver/gold coins (5/20/100 pts), and golden keys (200 pts) for score. A combo multiplier builds when collecting items in rapid succession and decays after 2 seconds of inactivity, capping at 5x. Collecting all gems and finishing with zero deaths earns bonus score.

Platform types introduce escalating challenge: ice platforms reduce friction, falling platforms drop after a short delay when touched, crumbling platforms disintegrate on a timer, moving platforms travel along axes, bouncy platforms launch the player upward, conveyor platforms push the player sideways, and phasing platforms blink in and out of existence.

Enemies include patrolling ground enemies, bouncing enemies, circling flyers, chasing enemies that pursue the player within range, and turrets that fire projectiles. Stomp enemies from above to defeat them (bounce upward on kill). Getting hit costs a life; a shield power-up absorbs one hit. Losing all 5 lives triggers Game Over with option to retry.

Each level awards 1-3 stars: 1 star for completion, +1 for zero deaths, +1 for collecting all gems under 60 seconds. World progression is linear in campaign mode, with a world intro screen between worlds.

## Public API Reference

### Package `platformer_3d`

> Main entry point.

No public types or functions. The `main` function initializes the window at 1024x768 with MSAA 4x, creates a `Game` instance, and runs a 60 FPS game loop that updates game state, clears the background based on the current world theme, draws the 3D world and 2D UI overlay, and handles window close.

### Package `platformer_3d/internal/types`

> Core type definitions, constants, and utility functions.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Platform` | `active`, `kind`, `x/y/z`, `w/h/d`, `move_speed`, `move_range`, `fall_timer`, `crumbling`, `phase_visible`, `rot_angle`, `r/g/b` | Represents a platform with type-specific behavior (moving, falling, crumbling, phasing, etc.) |
| `Enemy` | `active`, `kind`, `x/y/z`, `vx/vy/vz`, `patrol_range`, `patrol_dir`, `health`, `stunned`, `size`, `r/g/b` | Enemy entity with patrol, bounce, fly, chase, or turret behavior |
| `Collectible` | `active`, `kind`, `x/y/z`, `bob_timer`, `spin_timer`, `collected`, `magnet_target` | Collectible item (gem, star, life, coin, key) with bobbing/spinning animation |
| `PowerUp` | `active`, `kind`, `x/y/z`, `bob_timer`, `spin_timer`, `collected` | Power-up pickup (double jump, speed, shield, magnet, slow fall) |
| `Hazard` | `active`, `kind`, `x/y/z`, `w/h/d`, `timer`, `phase`, `on`, `base_x/y`, `move_range`, `move_speed` | Environmental hazard (spike, lava, saw, laser, fire jet, pendulum, crusher) |
| `Checkpoint` | `active`, `x/y/z`, `activated`, `anim_timer` | Mid-level checkpoint flag |
| `Particle` | `active`, `x/y/z`, `vx/vy/vz`, `life`, `max_life`, `r/g/b`, `size`, `kind` | Visual particle for effects (jump, collect, death, stomp, etc.) |
| `Decoration` | `active`, `kind`, `x/y/z`, `scale`, `rot_y`, `r/g/b` | World decoration (tree, rock, crystal, mushroom, pillar, cloud, etc.) |
| `Projectile` | `active`, `kind`, `x/y/z`, `vx/vy/vz`, `life`, `r/g/b` | Projectile fired by turret enemies |
| `ScoreFly` | `active`, `x/y`, `value`, `timer`, `max_time` | Floating score text that rises and fades |
| `Game` | `state`, `px/py/pz`, `vx/vy/vz`, `grounded`, `lives`, `score`, `gems_collected`, `current_world`, `current_level`, entity pools, UI state, camera, animation timers, `rng_state` | Main game state container holding all gameplay data |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Platform::inactive` | `() -> Platform` | Creates an inactive platform with default values |
| `Enemy::inactive` | `() -> Enemy` | Creates an inactive enemy with default values |
| `Collectible::inactive` | `() -> Collectible` | Creates an inactive collectible with default values |
| `PowerUp::inactive` | `() -> PowerUp` | Creates an inactive power-up with default values |
| `Hazard::inactive` | `() -> Hazard` | Creates an inactive hazard with default values |
| `Checkpoint::inactive` | `() -> Checkpoint` | Creates an inactive checkpoint with default values |
| `Particle::inactive` | `() -> Particle` | Creates an inactive particle with default values |
| `Decoration::inactive` | `() -> Decoration` | Creates an inactive decoration with default values |
| `Projectile::inactive` | `() -> Projectile` | Creates an inactive projectile with default values |
| `ScoreFly::inactive` | `() -> ScoreFly` | Creates an inactive score fly with default values |
| `Game::new` | `() -> Game` | Creates a new game with all entity pools pre-allocated and default state |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to [low, high] range |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer to [low, high] range |
| `minf` | `(Float, Float) -> Float` | Returns the minimum of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns the maximum of two floats |
| `mini` | `(Int, Int) -> Int` | Returns the minimum of two integers |
| `maxi` | `(Int, Int) -> Int` | Returns the maximum of two integers |
| `lerpf` | `(Float, Float, Float) -> Float` | Linear interpolation between two floats |
| `signf` | `(Float) -> Float` | Returns the sign of a float (-1, 0, or 1) |
| `dist2d` | `(Float, Float, Float, Float) -> Float` | Euclidean distance between two 2D points (XZ plane) |
| `dist3d` | `(Float, Float, Float, Float, Float, Float) -> Float` | Euclidean distance between two 3D points |
| `smoothstep` | `(Float, Float, Float) -> Float` | Cubic smooth interpolation between edges |
| `ease_in_quad` | `(Float) -> Float` | Ease-in quadratic easing function |
| `ease_out_quad` | `(Float) -> Float` | Ease-out quadratic easing function |
| `ease_in_out_quad` | `(Float) -> Float` | Ease-in-out quadratic easing function |
| `ease_out_bounce` | `(Float) -> Float` | Ease-out bounce easing function |
| `ease_out_elastic` | `(Float) -> Float` | Ease-out elastic easing function (Taylor series approximation) |
| `move_toward` | `(Float, Float, Float) -> Float` | Moves a value toward a target by a maximum delta |
| `wrap_angle` | `(Float) -> Float` | Wraps an angle to the 0..360 range |
| `normalize2d` | `(Float, Float) -> (Float, Float, Float)` | Normalizes a 2D vector, returning (nx, nz, length) |
| `dot2d` | `(Float, Float, Float, Float) -> Float` | 2D dot product |
| `dot3d` | `(Float, Float, Float, Float, Float, Float) -> Float` | 3D dot product |
| `reflect2d` | `(Float, Float, Float, Float) -> (Float, Float)` | Reflects a 2D vector off a normal |
| `aabb_overlap` | `(Float x12) -> Bool` | Tests overlap between two axis-aligned bounding boxes |
| `sphere_aabb` | `(Float x10) -> Bool` | Tests overlap between a sphere and an AABB |
| `point_above_platform` | `(Float x6) -> Bool` | Tests if a point is directly above a platform in XZ |
| `find_shadow_y` | `(Game, Float, Float, Float) -> Float` | Finds the highest platform surface below a point for shadow casting |
| `shadow_alpha` | `(Float, Float) -> Int` | Calculates shadow opacity based on height above surface |
| `shadow_scale` | `(Float, Float) -> Float` | Calculates shadow size based on height above surface |
| `alloc_particle` | `(Game) -> Int` | Finds an inactive particle slot, returns -1 if full |
| `spawn_particles` | `(Game, Float, Float, Float, Int, Int, Int, Int) -> Unit` | Spawns a burst of particles at a world position with random velocity |
| `spawn_particles_dir` | `(Game, Float, Float, Float, Int, Float, Float, Float, Float, Int, Int, Int) -> Unit` | Spawns particles with a directional bias and spread |
| `spawn_particle_ring` | `(Game, Float, Float, Float, Int, Float, Float, Int, Int, Int) -> Unit` | Spawns particles in a ring pattern (for power-ups, checkpoints) |
| `alloc_enemy` | `(Game) -> Int` | Finds an inactive enemy slot |
| `alloc_projectile` | `(Game) -> Int` | Finds an inactive projectile slot |
| `alloc_score_fly` | `(Game) -> Int` | Finds an inactive score fly slot |
| `spawn_score_fly` | `(Game, Float, Float, Int) -> Unit` | Spawns a floating score text at screen coordinates |
| `add_score` | `(Game, Int) -> Unit` | Adds score with combo multiplier and refreshes combo timer |
| `trigger_cam_shake` | `(Game, Float, Float) -> Unit` | Triggers camera shake with intensity and duration |
| `rand_next` | `(Game) -> Int` | Advances the xorshift RNG and returns the next value |
| `rand_range` | `(Game, Int, Int) -> Int` | Returns a random integer in [low, high] |
| `rand_rangef` | `(Game, Float, Float) -> Float` | Returns a random float in [low, high) |
| `map_range` | `(Float, Float, Float, Float, Float) -> Float` | Maps a value from one range to another |
| `approach` | `(Float, Float, Float, Float) -> Float` | Moves a value toward a target at a given speed over dt |
| `lerp_color` | `(Int, Int, Float) -> Int` | Linearly interpolates between two color component values |
| `pulse` | `(Float, Float) -> Float` | Returns 0..1 sine pulse for animations |
| `flash_on` | `(Float, Float) -> Bool` | Returns true during the first half of each period for flashing effects |
| `calc_stars` | `(Float, Int, Int, Int) -> Int` | Calculates 1-3 star rating based on time, gems, and deaths |

#### Constants (selected)

| Constant | Value | Description |
|----------|-------|-------------|
| `screen_width` / `screen_height` | 1024 / 768 | Window dimensions |
| `gravity` | 25.0 | Gravity acceleration |
| `jump_force` | 10.0 | Normal jump velocity |
| `move_speed` | 6.0 | Player movement speed |
| `dash_speed` / `dash_duration` / `dash_cooldown` | 14.0 / 0.15 / 0.6 | Dash parameters |
| `player_max_lives` | 5 | Starting lives |
| `num_worlds` / `levels_per_world` / `total_levels` | 4 / 5 / 20 | Campaign structure |
| `max_platforms` / `max_particles` / `max_enemies` | 128 / 512 / 32 | Pool sizes |
| `state_menu` through `state_world_intro` | 0-9 | Game state constants |
| `plat_static` through `plat_size_pulse` | 0-12 | Platform type constants |
| `enemy_patrol` through `enemy_ghost` | 0-5 | Enemy type constants |
| `powerup_double_jump` through `powerup_slow_fall` | 0-4 | Power-up type constants |

### Package `platformer_3d/internal/levels`

> Level data generation and world theme definitions.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `get_world_name` | `(Int) -> String` | Returns the display name for a world index (e.g., "Green Hills") |
| `get_level_name` | `(Int, Int) -> String` | Returns the display name for a specific world+level (e.g., "Meadow Path") |
| `world_platform_color` | `(Int) -> (Int, Int, Int)` | Returns the RGB platform color for a world theme |
| `world_bg_color` | `(Int) -> (Int, Int, Int)` | Returns the RGB background color for a world |
| `world_deco_color_1` | `(Int) -> (Int, Int, Int)` | Returns the primary decoration color for a world |
| `world_deco_color_2` | `(Int) -> (Int, Int, Int)` | Returns the secondary decoration color for a world |
| `get_platform_data` | `(Int, Int) -> Array[(Int, Float, Float, Float, Float, Float, Float, Float)]` | Returns platform layout data (kind, x, y, z, w, d, move_range, move_speed) for a level |
| `get_collectible_data` | `(Int, Int) -> Array[(Int, Float, Float, Float)]` | Returns collectible placement data (kind, x, y, z) for a level |
| `get_enemy_data` | `(Int, Int) -> Array[(Int, Float, Float, Float, Float)]` | Returns enemy placement data (kind, x, y, z, patrol_range) for a level |
| `get_hazard_data` | `(Int, Int) -> Array[(Int, Float, Float, Float, Float, Float, Float)]` | Returns hazard placement data (kind, x, y, z, w, h, d) for a level |
| `get_powerup_data` | `(Int, Int) -> Array[(Int, Float, Float, Float)]` | Returns power-up placement data (kind, x, y, z) for a level |
| `get_decoration_data` | `(Int, Int) -> Array[(Int, Float, Float, Float, Float)]` | Returns decoration placement data (kind, x, y, z, scale) for a level |
| `get_goal_position` | `(Int, Int) -> (Float, Float, Float)` | Returns the goal position (x, y, z) for a level (last platform + 1.0 Y) |
| `get_level_difficulty` | `(Int, Int) -> Int` | Returns a 1-5 difficulty rating based on world and level |
| `level_has_key` | `(Int, Int) -> Bool` | Returns whether a level requires a key (level 4 in worlds 1+) |
| `world_unlock_stars` | `(Int) -> Int` | Returns the recommended star count to unlock a world |

### Package `platformer_3d/internal/game`

> Game logic, state machine updates, and entity systems.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main update dispatcher: advances particles, score flies, and delegates to state-specific update |
| `load_level` | `(Game, Int, Int) -> Unit` | Loads a level by world and level index: clears pools, populates entities, sets player spawn and camera |

### Package `platformer_3d/internal/render`

> Rendering and drawing routines for 3D world and 2D UI.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_world` | `(Game) -> Unit` | Sets up the 3D camera and draws all world elements: floor, decorations, platforms, collectibles, power-ups, hazards, enemies, projectiles, checkpoints, goal, player, shadow, and particles |
| `draw_ui` | `(Game) -> Unit` | Draws the 2D UI overlay: dispatches to the appropriate screen (menu, HUD, pause, level complete, game over, world select, level select, world intro, campaign complete) and score flies |

## Architecture

### Package Structure

```
platformer_3d/
├── main.mbt              — Entry point: window init, 60 FPS game loop
├── moon.pkg              — Package config, imports all internal packages
└── internal/
    ├── types/
    │   ├── types.mbt     — 11 structs (Platform, Enemy, Game, etc.) with ::inactive() constructors
    │   ├── constants.mbt — ~200 tuning constants (physics, pools, states, colors, scoring)
    │   └── utils.mbt     — Math utilities, collision detection, particle spawning, RNG, easing
    ├── levels/
    │   └── levels.mbt    — Procedural level data for 4 worlds x 5 levels, theme colors
    ├── game/
    │   ├── game_update.mbt  — State machine (10 states), entity update systems, collision checks
    │   ├── player_system.mbt — Player movement, physics, platform collision resolution, wall-slide
    │   └── stage.mbt        — Level loading, pool clearing, entity spawning from level data
    └── render/
        ├── render_world.mbt — 3D rendering: platforms, player, enemies, hazards, decorations, particles
        └── render_ui.mbt    — 2D UI: menus, HUD, minimap, pause, level complete, world/level select
```

The `types` package is the foundation, defining all data structures and constants with zero dependencies on raylib (except `@math` for easing functions). The `levels` package generates level data procedurally from world/level indices. The `game` package handles all state transitions and entity behavior. The `render` package reads game state and draws everything, never modifying state (except checkpoint animation timers and particle spawning for lava pools/fire jets).

### Data Flow

1. **Input**: `update_player` in `player_system.mbt` reads WASD/Arrow keys and Space, transforms input relative to camera angle, applies acceleration with friction, and triggers jumps/dashes.
2. **Physics**: `resolve_platform_collisions` iterates all active platforms, performing AABB overlap tests against the player capsule and resolving penetration along the smallest axis. Special platforms trigger behaviors (bouncy, falling, crumbling, conveyor force).
3. **Enemies**: `update_enemies` dispatches to per-type AI (patrol, bounce, fly-circle, chase, turret). `check_enemy_collision` determines if the player stomps from above (kill) or gets hit (damage/death).
4. **Camera**: `update_camera` smoothly interpolates the orbital camera toward the player position with configurable rotation and zoom, applying shake offsets.
5. **Rendering**: `draw_world` sets up `Camera3D`, draws the world floor, then iterates all entity pools to draw 3D primitives. `draw_ui` overlays 2D HUD, menus, and minimap.

### Key Design Patterns

- **Object pool pattern**: All entities use pre-allocated `Array` pools with `active` flags. `alloc_particle`, `alloc_enemy`, `alloc_projectile`, `alloc_score_fly` scan for inactive slots, avoiding heap allocation during gameplay.
- **Integer-based state machine**: Game states are integer constants (0-9) driving a central dispatcher in `update_game` and `draw_ui`. Platform types (0-12), enemy types (0-5), collectible types (0-7), and hazard types (0-6) all use the same pattern.
- **Camera-relative input**: Movement input is rotated by the camera angle using sin/cos, allowing the player to move intuitively regardless of camera orientation.
- **Coyote time and jump buffering**: `coyote_timer` (0.1s after leaving ground) and `jump_buffer_timer` (0.1s before landing) provide forgiving jump timing, a standard platformer polish technique.
- **Combo scoring system**: `combo_count`, `combo_timer`, and `combo_mult` implement a decaying multiplier that rewards rapid collectible pickups.
- **Procedural level generation**: Levels are defined as hardcoded platform arrays in `levels.mbt` but collectibles, enemies, hazards, power-ups, and decorations are placed algorithmically relative to platform positions.

## Improvement & Refinement Plan

1. **Replace integer type tags with enums**: The `kind` fields on `Platform`, `Enemy`, `Collectible`, `Hazard`, `PowerUp`, and `Decoration` use bare `Int` constants (e.g., `plat_static = 0`). Converting these to MoonBit enums would eliminate magic numbers, enable exhaustive match checking, and improve readability throughout `game_update.mbt` and `render_world.mbt`.

2. **Extract entity update functions into per-type modules**: `game_update.mbt` contains 898 lines mixing state machine logic, enemy AI, power-up management, hazard updates, and collision checks. Splitting into `enemy_system.mbt`, `hazard_system.mbt`, `powerup_system.mbt`, and `collision_system.mbt` would improve maintainability.

3. **Add audio feedback**: The game has rich visual feedback (particles, camera shake, combo indicators) but no sound. Adding jump, collect, stomp, death, and level-complete sound effects via raylib's audio API would greatly enhance the player experience.

4. **Implement ghost enemies**: The `enemy_ghost` type (constant 5) and its associated color constants (`enemy_ghost_r/g/b`, `enemy_ghost_speed`, `enemy_ghost_fade_dist`) are defined in `constants.mbt` but no update or draw logic exists for ghost enemies in `game_update.mbt` or `render_world.mbt`.

5. **Fix checkpoint animation timer mutation in render**: In `draw_checkpoints` within `render_world.mbt`, the line `cp.anim_timer += 0.016` mutates game state during rendering. This should be moved to the game update loop to maintain the separation between update and render phases.

6. **Add conveyor visual animation**: Conveyor platforms (`plat_conveyor_l`/`plat_conveyor_r`) draw static arrow indicators in `draw_platform_special`. Animating the arrows based on `game.frame_counter` would make it clearer which direction the conveyor pushes.

7. **Implement laser hazard type**: `hazard_laser` (constant 3) is defined in `constants.mbt` with color values (`laser_r/g/b`) but has no update or rendering logic in `update_hazards` or `draw_hazards`, unlike the other six hazard types that are fully implemented.

8. **Reduce constant verbosity with struct-based color definitions**: The `constants.mbt` file defines individual `pub let` values for every RGB component of every color (e.g., `forest_plat_r`, `forest_plat_g`, `forest_plat_b`). Grouping these into color tuple constants or a small Color struct would reduce the file from ~1095 lines to roughly 300.
