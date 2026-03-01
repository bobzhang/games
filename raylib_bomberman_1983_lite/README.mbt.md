# Bomberman 1983 Lite

Bomberman 1983 Lite is a fully-featured Bomberman-style tank combat game with a 96-stage campaign, 2-player co-op support, a demo/AI mode, 6 powerup types, 4 enemy variants, a combo scoring system, and rich particle effects. The game is set on a 26x26 tile grid with a destructible environment, featuring 48 unique map patterns and 96 stage profiles with distinct visual themes.

The core gameplay is a bomb-placement defense game: players place bombs on a tile grid that detonate after a 1.8-second fuse, sending blast waves in four cardinal directions. The objective of each stage is to eliminate all spawning enemies while protecting a base tile at the bottom of the map. Enemies spawn from three lanes at the top and navigate toward the base or players using a weighted random AI. Bombs can chain-detonate, creating devastating explosion sequences. Six powerup types drop from destroyed enemies: Shield (invulnerability), Star (weapon upgrade), Grenade (instant kill all enemies), Clock (freeze all enemies), Shovel (temporarily fortify base with steel), and ExtraLife.

The game features an impressive technical architecture with 8 internal packages handling types, game logic, rendering, particles, scoring, world collision, levels, and level profiles. The custom xorshift RNG ensures deterministic behavior, and a sub-stepping bullet collision system prevents tunneling through narrow walls.

## Build and Run

```bash
moon build --target native raylib_bomberman_1983_lite/
./_build/native/debug/build/raylib_bomberman_1983_lite/raylib_bomberman_1983_lite.exe
```

## Controls

### Player 1 (Arrow Keys)
- **Arrow Keys**: Move (Up/Down/Left/Right)
- **Right Shift / Enter**: Place bomb

### Player 2 (WASD, co-op mode)
- **W/A/S/D**: Move
- **Space**: Place bomb

### Menu / General
- **Up/Down or W/S**: Navigate menu
- **Enter / Space**: Select menu option
- **C**: Toggle co-op mode
- **D**: Start demo mode (AI plays)
- **P**: Pause (during gameplay)
- **Escape**: Return to menu (from pause or demo)

## How to Play

From the main menu, select "Start" to begin a solo campaign or toggle co-op with C first. Each stage loads a unique tile map with Brick (destructible), Steel (indestructible except by power 3+ weapons), Water (impassable), Bush (visual cover), Ice (causes sliding), and a Base tile that must be protected.

**Bomb Mechanics**: Place bombs with your fire key. Bombs detonate after 1.8 seconds, creating a blast that extends in 4 directions for a range of 2-5 tiles (depending on weapon level). Blasts destroy Brick tiles, damage enemies, and trigger chain detonations on adjacent bombs. Only 1-4 bombs can be active per player (based on weapon level). Reload time is 0.18 seconds between placements.

**Enemies**: Four types spawn from three lanes at the top:
- **Basic** (yellow): 1 HP, 78 speed, 100 points
- **Fast** (orange): 1 HP, 110 speed, 200 points
- **Sniper** (purple): 2 HP, 84 speed, 300 points
- **Heavy** (red): 4 HP, 66 speed, 400 points

Each stage spawns 18-60 enemies total (scaling with stage number), with at most 8 on the field at once. Enemy mix shifts toward harder types in later stages.

**Powerups** (11-second lifetime, dropped by enemies):
- **Shield**: 8s invulnerability shield + 2s invuln
- **Star**: +1 weapon level (max 3), improves reload speed and bomb capacity/range
- **Grenade**: Instantly kills all active enemies on screen
- **Clock**: Freezes all enemies for 6 seconds
- **Shovel**: Fortifies base perimeter with Steel for 11 seconds
- **ExtraLife**: +1 life

**Scoring**: Kill score is multiplied by a combo system (1x for 1 kill, 2x for 2-3, 3x for 4-6, 4x for 7+). Combo resets after 2.1 seconds without a kill. Powerup collection awards 120 points.

**Win**: Eliminate all enemies in a stage to advance.
**Lose**: All players run out of lives, or the base is destroyed.

The campaign spans 96 stages. Completing all stages displays "Campaign Clear".

## Public API Reference

### Package `raylib_bomberman_1983_lite`

> Main entry point. Initializes window with MSAA 4x, runs the game loop.

No public types or functions are exported.

### Package `raylib_bomberman_1983_lite/internal/types`

> Core type definitions, constants, and utility functions.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Menu`, `StageIntro`, `Playing`, `Paused`, `StageClear`, `GameOver`, `CampaignClear` | Game state machine |
| `Team` | `None`, `Player1`, `Player2`, `Enemy` | Entity team affiliation |
| `TileKind` | `Empty`, `Brick`, `Steel`, `Water`, `Bush`, `Ice`, `Base` | Tile types for the map grid |
| `EnemyKind` | `Basic`, `Fast`, `Heavy`, `Sniper` | Enemy variant types with distinct stats |
| `PowerupKind` | `Shield`, `Star`, `Grenade`, `Clock`, `Shovel`, `ExtraLife` | Collectible powerup types |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Game` | `state`, `stage_index`, `profile`, `map_tiles`, `map_hp`, `players`, `enemies`, `bullets`, `bombs`, `particles`, `powerups`, `stars`, `base_alive`, `score_total`, `high_score`, `enemies_to_spawn`, `enemies_alive`, `kill_combo`, `freeze_all_timer`, `shovel_timer` | Main game state container |
| `Tank` | `active`, `enemy_kind`, `x`, `y`, `dir`, `move_speed`, `hp`, `reload_timer`, `reload_delay`, `ai_move_timer`, `ai_fire_timer`, `shield_timer`, `invuln_timer`, `lives`, `score`, `weapon_level` | Player or enemy tank entity |
| `Bullet` | `active`, `owner_team`, `x`, `y`, `vx`, `vy`, `ttl`, `damage`, `power`, `radius` | Projectile with team ownership |
| `Bomb` | `active`, `owner_team`, `x`, `y`, `tile_x`, `tile_y`, `fuse`, `blast_timer`, `exploding`, `blast_range` | Placed bomb with fuse and blast state |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `max_life`, `size`, `fade`, `color` | Visual particle for explosions/sparks |
| `Powerup` | `active`, `kind`, `x`, `y`, `ttl`, `blink`, `pulse` | Collectible item with type and lifetime |
| `Star` | `x`, `y`, `speed`, `twinkle` | Background starfield element |
| `StageProfile` | `title`, `subtitle`, `enemy_bonus`, `spawn_scale`, `drop_bonus`, `sky_top`, `sky_bottom`, `fog_alpha`, `ui_accent` | Per-stage visual theme and difficulty parameters |

#### Key Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `screen_width` / `screen_height` | `980` / `760` | Window dimensions |
| `map_tiles_w` / `map_tiles_h` | `26` / `26` | Map grid size |
| `tile_size` | `24` | Tile size in pixels |
| `max_enemies` | `42` | Enemy pool size |
| `max_bullets` | `320` | Bullet pool size |
| `max_bombs` | `96` | Bomb pool size |
| `max_particles` | `960` | Particle pool size |
| `level_count` | `96` | Total campaign stages |
| `map_pattern_count` | `48` | Unique map layouts |
| `bomb_fuse_time` | `1.8` | Seconds before detonation |
| `bomb_blast_time` | `0.36` | Blast duration |
| `bomb_range_base` | `2` | Base blast range in tiles |
| `speed_player` | `128.0` | Player movement speed |

#### Key Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Game::new` | `() -> Game` | Creates a full game state with all pre-allocated pools and starfield |
| `Tank::new_player` | `(Int, Float, Float) -> Tank` | Creates a player tank at spawn position with 3 lives |
| `Tank::new_enemy` | `(EnemyKind, Float, Float) -> Tank` | Creates an enemy tank with kind-specific stats |
| `Tank::inactive` / `Bullet::inactive` / `Bomb::inactive` / `Particle::inactive` / `Powerup::inactive` | `() -> T` | Factory functions for inactive pool slots |
| `team_of_player` | `(Int) -> Team` | Maps player index to Team enum |
| `rand_next` / `rand_range` / `rand_rangef` | various | Custom xorshift RNG functions |
| `tile_index` / `in_tile_bounds` / `get_tile` / `set_tile` | various | Tile map access helpers |
| `world_x_to_tile` / `world_y_to_tile` / `tile_center_x` / `tile_center_y` | various | Coordinate conversion utilities |
| `is_tile_solid_for_tank` / `is_tile_solid_for_bullet` | `(TileKind) -> Bool` | Tile collision predicates |
| `enemy_score` / `enemy_color` | `(EnemyKind) -> Int/Color` | Enemy kind attribute lookups |
| `push_camera_shake` / `update_camera_shake` / `shake_offsets` | various | Camera shake system |
| `count_team_bombs` | `(Game, Team) -> Int` | Counts active bombs for a team |
| `StageProfile::new` | `(String, String, Int, Float, Int, Color, Color, Float, Color) -> StageProfile` | Creates a stage profile with all parameters |
| `default_stage_profile` | `() -> StageProfile` | Returns the default stage profile |

### Package `raylib_bomberman_1983_lite/internal/game`

> Game logic: player input, bomb system, bullet system, enemy AI, powerups, stage management, demo AI.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main update entry point dispatching to state-specific handlers |

### Package `raylib_bomberman_1983_lite/internal/render`

> Rendering: world tiles, tanks, bombs, bullets, particles, HUD, and overlays.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_world` | `(Game) -> Unit` | Renders the game world: starfield, tiles, bombs, tanks, bullets, particles |
| `draw_ui` | `(Game) -> Unit` | Renders HUD: enemy counter, player cards, stage info, and state overlays |

### Package `raylib_bomberman_1983_lite/internal/levels`

> Level data: 48 map patterns and 96 stage profiles.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `level_pattern` | `(Int) -> Array[String]` | Returns 26 row strings for a map pattern index |
| `get_stage_profile` | `(Int) -> StageProfile` | Returns the visual theme and difficulty profile for a stage |

### Package `raylib_bomberman_1983_lite/internal/particles`

> Particle system for visual effects.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `spawn_particle` | `(Game, Float, Float, Float, Float, Float, Float, Color) -> Unit` | Creates a single particle with position, velocity, lifetime, and color |
| `spawn_spark_burst` | `(Game, Float, Float, Int) -> Unit` | Spawns N gold sparks in random directions |
| `spawn_explosion` | `(Game, Float, Float, Float) -> Unit` | Creates a full explosion with sparks, smoke puffs, and camera shake |
| `spawn_respawn_burst` | `(Game, Float, Float) -> Unit` | Creates a circular burst of skyblue particles for respawn effects |
| `update_particles` | `(Game, Float) -> Unit` | Updates all active particles: applies velocity, gravity, damping, and lifetime |

### Package `raylib_bomberman_1983_lite/internal/score`

> Scoring and combo system.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `grant_score` | `(Game, Team, Int) -> Unit` | Awards points to a team and updates total/high score |
| `bump_combo` | `(Game) -> Unit` | Increments kill combo (max 9) and resets combo timer to 2.1s |
| `combo_multiplier` | `(Game) -> Int` | Returns score multiplier based on combo (1x/2x/3x/4x) |
| `update_combo` | `(Game, Float) -> Unit` | Ticks combo timer and resets combo to 0 when expired |

### Package `raylib_bomberman_1983_lite/internal/world`

> World collision detection.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `point_in_world` | `(Float, Float) -> Bool` | Tests if a point is within world pixel bounds |
| `tank_hits_world` | `(Game, Float, Float) -> Bool` | Tests if a tank at position collides with world boundaries or solid tiles |
| `tank_hits_players` | `(Game, Float, Float, Int) -> Bool` | Tests tank-vs-player rectangle collision (excluding one player) |
| `tank_hits_enemies` | `(Game, Float, Float, Int) -> Bool` | Tests tank-vs-enemy rectangle collision (excluding one enemy) |

## Architecture

### Package Structure

```
raylib_bomberman_1983_lite/
├── main.mbt                    -- Entry point: window init, game loop
├── moon.pkg                    -- Root package config
└── internal/
    ├── types/
    │   ├── types.mbt           -- All enums, structs, constructors
    │   ├── constants.mbt       -- ~80 game constants
    │   ├── utils.mbt           -- RNG, tile helpers, coordinate conversion, collision
    │   └── stage_profile.mbt   -- StageProfile struct and default
    ├── game/
    │   ├── game_update.mbt     -- State machine dispatcher, menu/intro/clear/gameover logic
    │   ├── player_system.mbt   -- Player input, movement, destruction, respawn
    │   ├── bomb_system.mbt     -- Bomb placement, detonation, chain triggers, blast propagation
    │   ├── bullet_system.mbt   -- Bullet movement, sub-stepped collision, bullet-vs-bullet
    │   ├── enemy_system.mbt    -- Enemy spawning, AI movement, destruction, stage clear check
    │   ├── powerups.mbt        -- Powerup spawning, collection, effect application
    │   ├── stage.mbt           -- Stage loading, map parsing, campaign management
    │   ├── world_helpers.mbt   -- Tile damage, line-of-sight checks
    │   └── demo_ai.mbt        -- AI player controller for demo mode
    ├── levels/
    │   ├── levels.mbt          -- 48 map pattern definitions as string arrays
    │   └── profiles.mbt        -- 96 stage profile definitions
    ├── particles/
    │   └── particles.mbt       -- Particle allocation, spawning, and update
    ├── render/
    │   ├── render_world.mbt    -- World rendering: starfield, tiles, entities, particles
    │   └── render_ui.mbt       -- HUD rendering: enemy counter, player cards, overlays
    ├── score/
    │   └── score.mbt           -- Score granting, combo tracking, multiplier calculation
    └── world/
        └── world.mbt           -- World boundary and entity collision detection
```

This is the most architecturally complex game in the collection, with 8 internal packages following a clear separation of concerns. The `types` package owns all data definitions and pure utilities; `game` handles all mutable state logic split across 9 files by subsystem; `levels` provides static data; `particles`, `score`, and `world` are focused utility packages; and `render` draws everything.

### Data Flow

1. **Initialization**: `Game::new()` allocates pools for 42 enemies, 320 bullets, 96 bombs, 960 particles, 32 powerups, and 120 stars.
2. **Menu**: `update_menu` navigates cursor, toggles co-op, starts campaigns or demo mode.
3. **Stage loading**: `load_stage` calls `load_stage_map` (parses level pattern characters into tiles), `prepare_players_for_stage` (respawns or continues), and sets enemy count.
4. **Playing**: `update_playing` orchestrates: camera shake, combo timer, global effects (freeze/shovel), player reload timers, player input, enemy spawning, enemy AI, bomb updates, bullet updates, powerup collection, player respawns, and particle updates.
5. **Bomb detonation**: `trigger_bomb` propagates blast in 4 directions up to `blast_range` tiles, calling `detonate_tile` which destroys Bricks, triggers chain bombs via `mark_chain_bombs`, and damages entities via `hit_entities_on_tile`.
6. **Demo AI**: `demo_player_command` drives AI players by finding nearest enemy/powerup, choosing movement direction with fallback, and firing when line-of-sight is clear.
7. **Rendering**: `draw_world` renders the gradient starfield, world backdrop, tile map, bombs (with pulsing fuse animation), tanks (with direction indicators), bullets, and particles. `draw_ui` renders the side panel with enemy counter icons, player cards, stage info, and state-specific overlays.

### Key Design Patterns

- **8-package architecture**: Clear separation into types, game (9 files), levels (data), particles, score, world, and render packages.
- **Pre-allocated object pools**: All entities use fixed-size arrays with `active` flags and `alloc_*`/`inactive()` factory patterns.
- **Custom xorshift RNG**: `rand_next` uses a deterministic xorshift PRNG (state `0x13572468`), enabling reproducible gameplay.
- **Bomb chain detonation**: `mark_chain_bombs` sets the fuse of adjacent bombs to `bomb_chain_trigger_window` (0.06s), creating cascade explosions.
- **Sub-stepped bullet collision**: `update_bullets` divides each frame into 2 sub-steps to prevent tunneling through narrow tile walls.
- **Demo AI with line-of-sight**: `demo_player_command` uses `sight_blocked` to ray-march between tiles before deciding to shoot, and `demo_priority_dir` for intelligent pathfinding.
- **Kill combo multiplier**: Score scales from 1x to 4x based on consecutive kills within a 2.1s window, encouraging aggressive play.
- **Stage profile theming**: Each of 96 stages has unique `sky_top`/`sky_bottom` colors, `fog_alpha`, `ui_accent`, enemy bonuses, and spawn scaling.

## Improvement & Refinement Plan

1. **Enable enemy shooting**: The `enemy_shoot_if_ready` function in `enemy_system.mbt` is a no-op stub -- enemies never fire bullets. Implementing enemy projectiles would dramatically increase difficulty and strategic depth.

2. **Add bullet spawning for players**: Players currently can only place bombs (`place_player_bomb`), not fire bullets. The `Bullet` infrastructure exists with `update_bullets`, `bullet_hit_enemy`, and `bullet_hit_player` fully implemented. Connecting player fire input to bullet spawning would enable dual combat modes.

3. **Add sound effects**: The game has extensive visual feedback (explosions via `spawn_explosion`, sparks via `spawn_spark_burst`, camera shake via `push_camera_shake`) but no audio. Adding sounds for bomb placement, detonation, enemy death, and powerup collection would enhance immersion.

4. **Add persistent high score**: The `high_score` field in `Game` resets each session. Writing to a file on game over and reading on startup would add long-term motivation.

5. **Improve enemy pathfinding near obstacles**: `enemy_desired_dir` in `enemy_system.mbt` uses weighted random direction choice, often causing enemies to get stuck against walls. The `ai_stuck_timer` (0.14s threshold) provides a fallback, but a simple wall-following or waypoint system would produce smoother movement.

6. **Balance powerup drop rates**: In `spawn_random_powerup`, the Grenade powerup (instant kill all enemies) has an 18% drop rate, same as Shield. Given its game-changing power, reducing its probability or restricting it to later stages would improve balance.

7. **Add visual indicator for bomb chain radius**: When placing a bomb, there is no preview of the blast range. Showing a subtle overlay of the expected detonation area (based on `blast_range`) would help players make strategic placement decisions.
