# Contra 1987 Lite

Contra 1987 Lite is a top-down tank battle game inspired by classic NES tank combat titles. Set across 96 procedurally themed stages with names like "Rust Outpost," "Neon Bastion," and "Storm Arsenal," players command tanks on a 26x26 tile grid battlefield featuring destructible brick walls, indestructible steel barriers, water hazards, slippery ice tiles, and concealing bush terrain.

The core gameplay loop tasks players with eliminating all enemy tanks spawning from the top of the map while simultaneously destroying scattered "bio cores" -- pulsating destructible objectives placed throughout each stage. Players must also protect their command base at the bottom of the map from enemy fire. The game supports single-player and local two-player co-op, with six collectible power-ups (Shield, Star weapon upgrade, Grenade screen-clear, Clock freeze, Shovel base-fortify, and ExtraLife) dropped by defeated enemies. A kill combo system rewards rapid eliminations with score multipliers up to 4x.

Technically notable is the built-in demo AI system that autonomously plays co-op campaigns, pathfinding toward enemies and power-ups while defending the base. The game uses a deterministic xorshift PRNG for reproducible randomness, pre-allocated object pools for all entities (up to 42 enemies, 320 bullets, 960 particles), and a layered rendering pipeline with camera shake, fog overlays, and per-stage color themes.

## Build and Run

```bash
moon build --target native raylib_contra_1987_lite/
./_build/native/debug/build/raylib_contra_1987_lite/raylib_contra_1987_lite.exe
```

## Controls

### Menu
- **Up Arrow / W**: Move menu cursor up
- **Down Arrow / S**: Move menu cursor down
- **Enter / Space**: Select menu option
- **C**: Toggle co-op mode
- **D**: Start demo (auto-play) campaign

### Player 1 (In-Game)
- **Arrow Keys**: Move tank (Up/Down/Left/Right)
- **Right Shift / Enter**: Fire

### Player 2 (In-Game, Co-Op)
- **W/A/S/D**: Move tank
- **Space**: Fire

### General
- **P**: Pause / Resume
- **Escape**: Return to menu (from pause or during demo)

## How to Play

From the main menu, select "START CAMPAIGN" to begin a solo run or enable co-op first with "C" and start together. Each stage begins with a brief intro showing the stage number, title, enemy count, and bio core goal.

During gameplay, enemy tanks spawn from three lanes at the top of the map. Four enemy types appear with increasing frequency in later stages: Basic (yellow, 1 HP), Fast (orange, quick movement), Sniper (purple, faster bullets, 2 HP), and Heavy (red, 4 HP, slower). Up to 8 enemies are on the field simultaneously.

To clear a stage, you must destroy all spawned enemies AND destroy all bio cores (red pulsating circles scattered across the map). Bio cores have HP bars that scale with stage progression. Shooting them with higher-power weapons deals more damage.

The game ends if your base (golden eagle tile at the bottom center) is destroyed, or all players lose all lives. Players start with 3 lives and respawn after a 1.2-second delay with brief invulnerability. Power-ups drop from defeated enemies based on a probability roll (14-22% base chance, higher for Heavy enemies). Collecting them grants immediate effects: Shield (8s protection), Star (weapon upgrade, up to level 3), Grenade (destroys all on-screen enemies), Clock (freezes enemies for 6s), Shovel (steel-reinforces base for 11s), and ExtraLife (+1 life).

The 96-stage campaign cycles through 48 unique map patterns with escalating difficulty: more enemies per stage, faster spawn rates, and harder enemy type distributions. Completing all 96 stages triggers the campaign victory screen.

## Public API Reference

### Package `raylib_contra_1987_lite`

> Main entry point.

The `main` function initializes a 980x760 window at 60 FPS, creates a `Game` instance, and runs the game loop calling `@game.update_game` and `@render.draw_world`/`@render.draw_ui` each frame with delta time clamped to 50ms.

### Package `raylib_contra_1987_lite/internal/types`

> Core type definitions, constants, and utility functions.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Menu`, `StageIntro`, `Playing`, `Paused`, `StageClear`, `GameOver`, `CampaignClear` | State machine controlling game flow |
| `Dir` | `Up`, `Right`, `Down`, `Left` | Cardinal directions for tank movement and firing |
| `Tile` | `Empty`, `Brick`, `Steel`, `Water`, `Bush`, `Ice`, `Base` | Map tile types with different collision and visual properties |
| `Team` | `TeamNone`, `Player1`, `Player2`, `Enemy` | Ownership tag for bullets and scoring |
| `EnemyKind` | `Basic`, `Fast`, `Heavy`, `Sniper` | Enemy tank archetypes with distinct stats |
| `PowerupKind` | `Shield`, `Star`, `Grenade`, `Clock`, `Shovel`, `ExtraLife` | Collectible power-up types |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Tank` | `active`, `x`, `y`, `dir`, `hp`, `lives`, `score`, `weapon_level`, `shield_timer`, `enemy_kind` | Represents both player and enemy tanks with movement, combat, and AI state |
| `Bullet` | `active`, `owner_team`, `x`, `y`, `vx`, `vy`, `ttl`, `damage`, `power`, `radius` | Projectile with team ownership, velocity, time-to-live, and armor-piercing power |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `max_life`, `size`, `fade`, `color` | Visual effect particle with physics and fading |
| `Powerup` | `active`, `kind`, `x`, `y`, `ttl`, `blink`, `pulse` | Collectible item with lifetime and visual pulsing |
| `BioCore` | `active`, `x`, `y`, `hp`, `max_hp`, `pulse`, `flash` | Destructible objective entity with health bar |
| `Star` | `x`, `y`, `speed`, `twinkle` | Background starfield element |
| `StageProfile` | `title`, `subtitle`, `enemy_bonus`, `spawn_scale`, `drop_bonus`, `sky_top`, `sky_bottom`, `fog_alpha`, `ui_accent` | Per-stage visual theme and difficulty parameters |
| `Game` | `state`, `stage_index`, `players`, `enemies`, `bullets`, `particles`, `powerups`, `cores`, `map_tiles`, `rng_state`, ... | Central game state container holding all entities and progression data |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Game::new` | `() -> Game` | Creates a new game instance with pre-allocated entity pools and starfield |
| `Tank::inactive` | `() -> Tank` | Returns a default inactive tank for pool initialization |
| `Tank::new_player` | `(Int, Float, Float) -> Tank` | Creates an active player tank at the given spawn position |
| `Tank::new_enemy` | `(EnemyKind, Float, Float) -> Tank` | Creates an active enemy tank with kind-specific stats |
| `Bullet::inactive` | `() -> Bullet` | Returns a default inactive bullet for pool initialization |
| `Particle::inactive` | `() -> Particle` | Returns a default inactive particle for pool initialization |
| `Powerup::inactive` | `() -> Powerup` | Returns a default inactive power-up for pool initialization |
| `BioCore::inactive` | `() -> BioCore` | Returns a default inactive bio core for pool initialization |
| `Star::new` | `(Float, Float, Float, Float) -> Star` | Creates a background star with position, speed, and twinkle phase |
| `StageProfile::new` | `(String, String, Int, Float, Int, Color, Color, Float, Color) -> StageProfile` | Constructs a stage profile with all visual and difficulty parameters |
| `default_stage_profile` | `() -> StageProfile` | Returns a fallback stage profile ("Border Skirmish") |
| `team_of_player` | `(Int) -> Team` | Maps player index (0 or 1) to `Player1` or `Player2` team |
| `rand_dir` | `(Game) -> Dir` | Returns a random cardinal direction using the game's PRNG |
| `absf` | `(Float) -> Float` | Absolute value of a float |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to a range |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer to a range |
| `rand_next` | `(Game) -> Int` | Advances the xorshift PRNG and returns the next value |
| `rand_range` | `(Game, Int, Int) -> Int` | Returns a random integer in an inclusive range |
| `rand_rangef` | `(Game, Float, Float) -> Float` | Returns a random float in a range |
| `tile_index` | `(Int, Int) -> Int` | Converts tile coordinates to a flat array index |
| `in_tile_bounds` | `(Int, Int) -> Bool` | Checks if tile coordinates are within the map |
| `get_tile` | `(Game, Int, Int) -> Tile` | Reads a tile from the map (Steel if out of bounds) |
| `set_tile` | `(Game, Int, Int, Tile, Int) -> Unit` | Writes a tile and its HP to the map |
| `world_x_to_tile` | `(Float) -> Int` | Converts world X coordinate to tile X |
| `world_y_to_tile` | `(Float) -> Int` | Converts world Y coordinate to tile Y |
| `tile_center_x` | `(Int) -> Float` | Returns the world X center of a tile |
| `tile_center_y` | `(Int) -> Float` | Returns the world Y center of a tile |
| `world_to_screen_x` | `(Float, Float) -> Int` | Converts world X to screen X with camera shake offset |
| `world_to_screen_y` | `(Float, Float) -> Int` | Converts world Y to screen Y with camera shake offset |
| `tile_to_screen_x` | `(Int, Float) -> Int` | Converts tile X to screen X with shake offset |
| `tile_to_screen_y` | `(Int, Float) -> Int` | Converts tile Y to screen Y with shake offset |
| `dir_vector_x` | `(Dir) -> Float` | Returns the X component of a direction vector |
| `dir_vector_y` | `(Dir) -> Float` | Returns the Y component of a direction vector |
| `tank_rect_at` | `(Float, Float) -> Rectangle` | Creates a collision rectangle centered at a position |
| `tank_rect` | `(Tank) -> Rectangle` | Creates a collision rectangle for a tank |
| `rects_overlap` | `(Rectangle, Rectangle) -> Bool` | Checks if two rectangles overlap |
| `distance_sq` | `(Float, Float, Float, Float) -> Float` | Returns squared distance between two points |
| `is_tile_solid_for_tank` | `(Tile) -> Bool` | Returns true if a tile blocks tank movement |
| `is_tile_solid_for_bullet` | `(Tile) -> Bool` | Returns true if a tile blocks bullet travel |
| `enemy_score` | `(EnemyKind) -> Int` | Returns score value for an enemy type (100-400) |
| `enemy_color` | `(EnemyKind) -> Color` | Returns the display color for an enemy type |
| `draw_centered_text` | `(String, Int, Int, Int, Color) -> Unit` | Draws horizontally centered text |
| `draw_shadow_text` | `(String, Int, Int, Int, Color) -> Unit` | Draws text with a black drop shadow |
| `shake_offsets` | `(Game) -> (Float, Float)` | Computes current camera shake X/Y offsets |
| `update_camera_shake` | `(Game, Float) -> Unit` | Decays camera shake intensity over time |
| `push_camera_shake` | `(Game, Float) -> Unit` | Adds to camera shake intensity (capped at max) |
| `pulse_color` | `(Color, Float) -> Color` | Generates a pulsing color by lerping toward white |

#### Constants (selected)

| Constant | Value | Description |
|----------|-------|-------------|
| `screen_width` | 980 | Window width in pixels |
| `screen_height` | 760 | Window height in pixels |
| `map_tiles_w` / `map_tiles_h` | 26 | Map dimensions in tiles |
| `tile_size` | 24 | Tile size in pixels |
| `max_enemies` | 42 | Maximum enemy pool size |
| `max_bullets` | 320 | Maximum bullet pool size |
| `max_particles` | 960 | Maximum particle pool size |
| `level_count` | 96 | Total number of campaign stages |
| `map_pattern_count` | 48 | Number of unique map layouts |
| `speed_player` | 128.0 | Player tank movement speed |
| `bullet_speed_player` | 350.0 | Player bullet speed |
| `freeze_duration` | 6.0 | Clock power-up freeze time in seconds |
| `shovel_duration` | 11.0 | Shovel power-up fortification time in seconds |

### Package `raylib_contra_1987_lite/internal/game`

> Game logic: update loop, player input, enemy AI, bullet physics, power-ups, stage management.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Master update dispatching to state-specific handlers (menu, playing, paused, etc.) |
| `load_stage` | `(Game, Int) -> Unit` | Loads a stage by index: sets profile, clears entities, generates map, seeds bio cores, prepares players |
| `start_new_campaign` | `(Game) -> Unit` | Resets campaign state and loads stage 0 |

### Package `raylib_contra_1987_lite/internal/levels`

> Level data: 48 unique map patterns and 96 stage profiles.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `level_pattern` | `(Int) -> Array[String]` | Returns 26 row strings defining the tile layout for a stage (mod 48) |
| `get_stage_profile` | `(Int) -> StageProfile` | Returns the visual theme and difficulty profile for a stage (mod 96) |

### Package `raylib_contra_1987_lite/internal/particles`

> Particle system for visual effects.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `spawn_particle` | `(Game, Float, Float, Float, Float, Float, Float, Color) -> Unit` | Spawns a single particle with position, velocity, lifetime, size, and color |
| `spawn_spark_burst` | `(Game, Float, Float, Int) -> Unit` | Emits a burst of gold spark particles at a position |
| `spawn_explosion` | `(Game, Float, Float, Float) -> Unit` | Creates a multi-color explosion with sparks and smoke puffs, plus camera shake |
| `spawn_respawn_burst` | `(Game, Float, Float) -> Unit` | Emits a ring of sky-blue particles for respawn effects |
| `update_particles` | `(Game, Float) -> Unit` | Updates all active particles: movement, drag, gravity, fade, and deactivation |

### Package `raylib_contra_1987_lite/internal/render`

> Rendering and drawing routines.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_world` | `(Game) -> Unit` | Renders the complete game world: starfield, terrain, cores, power-ups, tanks, bullets, particles, bushes, and fog overlay |
| `draw_ui` | `(Game) -> Unit` | Renders the side panel (scores, enemy counter, player cards) and state-specific overlays (menu, pause, stage intro/clear, game over, campaign clear) |

### Package `raylib_contra_1987_lite/internal/score`

> Scoring and combo system.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `grant_score` | `(Game, Team, Int) -> Unit` | Awards points to a team's player and the total score, updating high score |
| `bump_combo` | `(Game) -> Unit` | Increments the kill combo counter (max 9) and resets the combo timer to 2.1s |
| `combo_multiplier` | `(Game) -> Int` | Returns the current score multiplier (1x-4x) based on combo count |
| `update_combo` | `(Game, Float) -> Unit` | Decays the combo timer and resets combo on expiry |

### Package `raylib_contra_1987_lite/internal/world`

> World collision detection.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `point_in_world` | `(Float, Float) -> Bool` | Checks if a point is within the map pixel boundaries |
| `tank_hits_world` | `(Game, Float, Float) -> Bool` | Checks if a tank at a position collides with map boundaries or solid tiles |
| `tank_hits_players` | `(Game, Float, Float, Int) -> Bool` | Checks if a tank overlaps any active player (optionally ignoring one) |
| `tank_hits_enemies` | `(Game, Float, Float, Int) -> Bool` | Checks if a tank overlaps any active enemy (optionally ignoring one) |

## Architecture

### Package Structure

```
raylib_contra_1987_lite/
├── main.mbt              — Entry point: window init, 60 FPS game loop
├── moon.pkg              — Root package config, imports game/render/types
└── internal/
    ├── types/
    │   ├── types.mbt     — All enums, structs (Game, Tank, Bullet, etc.)
    │   ├── constants.mbt — Tuning values: speeds, pool sizes, timings
    │   └── utils.mbt     — Math, RNG, coordinate conversions, collision helpers
    ├── game/
    │   ├── game_update.mbt   — Master update loop, state machine transitions
    │   ├── player_system.mbt — Player input, movement, firing, respawns
    │   ├── enemy_system.mbt  — Enemy spawning, AI movement/firing, destruction
    │   ├── bullet_system.mbt — Bullet movement, tile/entity collision, bullet-vs-bullet
    │   ├── core_system.mbt   — Bio core spawning, damage, objective tracking
    │   ├── powerups.mbt      — Power-up spawning, collection, effect application
    │   ├── demo_ai.mbt       — Autonomous AI for demo mode players
    │   └── stage.mbt         — Stage loading, map parsing, campaign management
    ├── levels/
    │   ├── levels.mbt    — 48 tile-map patterns as string arrays
    │   └── profiles.mbt  — 96 stage profiles (colors, difficulty scaling)
    ├── particles/
    │   └── particles.mbt — Particle pool management and effect generators
    ├── render/
    │   ├── render_world.mbt — World rendering: terrain, tanks, bullets, effects
    │   └── render_ui.mbt    — UI panel, menu, and overlay rendering
    ├── score/
    │   └── score.mbt     — Scoring, combo multiplier, high score tracking
    └── world/
        └── world.mbt     — Spatial queries: point/tank collision against map and entities
```

The architecture follows a strict ECS-like separation: `types` holds all data definitions with no logic dependencies, `game` contains all mutation and update logic, `render` reads game state for drawing, and `world`/`score`/`particles` provide focused subsystems. The `levels` package is purely data-driven with no runtime dependencies beyond types.

### Data Flow

1. **Input**: `update_player_input` in `player_system.mbt` reads keyboard state via `read_player_move_dir` and `is_player_shoot_pressed` (or `demo_player_command` in demo mode).
2. **Update**: `update_game` dispatches to state-specific handlers. During `Playing`, it calls subsystems in sequence: camera shake decay, combo decay, global effects (freeze/shovel timers), player reload timers, player input, enemy spawning, enemy AI, bullet physics, core updates, power-up collection, player respawns, and particle physics.
3. **Collision**: Bullet updates in `update_bullets` use sub-stepping (2 steps per frame) for robust narrow-wall collision. Each step checks world boundaries, tile damage, and entity hits. `tank_hits_world`/`tank_hits_players`/`tank_hits_enemies` in `world.mbt` handle spatial queries.
4. **Rendering**: `draw_world` renders layers in order (starfield, backdrop, terrain, cores, power-ups, players, enemies, bullets, particles, bush overlay, fog). `draw_ui` renders the side panel and state-specific overlays.

### Key Design Patterns

- **Object Pool Pattern**: All entities (enemies, bullets, particles, power-ups, cores) use pre-allocated fixed-size arrays with `active` flags. Allocation scans for inactive slots; no dynamic memory allocation during gameplay.
- **State Machine**: The `GameState` enum drives distinct update and render paths through the seven game states.
- **Deterministic PRNG**: A custom xorshift random number generator (`rand_next`) seeded at game creation ensures reproducible behavior, critical for the demo AI system.
- **Layered Rendering**: World elements are drawn in strict z-order with bush tiles rendered last (over tanks) to provide visual concealment, matching classic tank battle game behavior.
- **Delta Time with Cap**: Frame time is clamped to 50ms to prevent physics tunneling during frame spikes.
- **Demo AI System**: Full autonomous gameplay via `demo_ai.mbt` that evaluates nearest enemies/power-ups, computes pathfinding priorities, checks line-of-sight for shooting, and guards the base when idle.

## Improvement & Refinement Plan

1. **Extract collision response from bullet_system.mbt**: The `update_bullets` function handles movement, tile damage, and entity collision in a single 200-line function. Splitting tile collision, entity collision, and bullet-vs-bullet into separate passes would improve readability.

2. **Replace linear entity scans with spatial partitioning**: Functions like `bullet_hit_enemy` and `tank_hits_enemies` iterate over the full pool array (42 enemies, 320 bullets). A grid-based spatial hash matching the existing tile grid would reduce collision checks significantly in later stages with many active entities.

3. **Consolidate duplicate powerup_radius functions**: Both `render_world.mbt` and `powerups.mbt` in the game package define their own `powerup_radius` function with identical logic. Moving this to `types` as a public function would eliminate duplication.

4. **Add difficulty curve documentation to StageProfile**: The 96-entry `get_stage_profile` function in `profiles.mbt` uses a repetitive pattern with manually tuned values. Generating profiles algorithmically from a formula based on stage index would reduce the 1150-line file to under 50 lines while making the difficulty curve more transparent.

5. **Unify timer decay pattern**: Functions like `update_player_reload_timers`, `update_global_effects`, and enemy timer updates all repeat the same `if timer > 0.0 { timer -= dt; if timer < 0.0 { timer = 0.0 } }` pattern. A shared `decay_timer` utility would reduce boilerplate across `player_system.mbt`, `enemy_system.mbt`, and `powerups.mbt`.

6. **Parameterize demo AI behavior**: The demo AI in `demo_ai.mbt` uses hardcoded probability thresholds (e.g., `rand_range(game, 0, 99) < 4` for random shots). Extracting these into a `DemoAIConfig` struct would allow tuning aggressiveness for different demo difficulty levels.

7. **Add sound effect hooks**: The game currently has no audio. Key events like `spawn_explosion`, `apply_powerup`, `on_player_destroyed`, and `destroy_enemy` are natural points to add sound effect calls without restructuring game logic.
