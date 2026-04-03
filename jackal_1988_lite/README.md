# Jackal 1988 Lite

Jackal 1988 Lite is a top-down tank combat game inspired by the classic NES-era Jackal. The player commands one or two tanks on a 26x26 tile-based battlefield, fighting through a 96-stage campaign against waves of enemy armor. Each stage loads a unique map pattern with destructible brick walls, indestructible steel barriers, water hazards, ice surfaces, and bush cover, all surrounding a command base that must be defended at all costs.

The core gameplay loop combines tank combat with a hostage rescue mechanic. Players navigate the battlefield, destroy enemy tanks that spawn from three lanes at the top of the map, and rescue hostages scattered across the level by walking over their camp tiles. Six types of powerups drop from destroyed enemies: shields, weapon stars, grenades that clear all enemies, clocks that freeze enemies, shovels that fortify the base with steel, and extra lives. A kill combo system multiplies score for rapid consecutive kills, while the rescue objective must be completed alongside the combat to clear each stage.

The game supports single-player and two-player co-op with separate control schemes, a fully autonomous demo mode with AI-controlled tanks, and a 96-stage campaign with procedurally generated stage profiles that vary enemy counts, spawn rates, powerup drop rates, sky colors, fog intensity, and UI accent colors. Camera shake, particle effects for explosions and sparks, and a scrolling starfield background provide visual feedback throughout.

## Build and Run

```bash
moon build --target native jackal_1988_lite/
./_build/native/debug/build/jackal_1988_lite/jackal_1988_lite.exe
```

## Controls

### Menu
- **W / Up Arrow**: Move cursor up
- **S / Down Arrow**: Move cursor down
- **Enter / Space**: Confirm selection (Start Campaign, Start Demo, toggle Co-Op, Quit)
- **C**: Toggle co-op mode
- **D**: Start demo (auto-play) immediately

### Player 1 (In-Game)
- **Arrow Keys (Up/Down/Left/Right)**: Move tank and set facing direction
- **Right Shift / Enter**: Fire bullet

### Player 2 (Co-Op)
- **W/A/S/D**: Move tank and set facing direction
- **Space**: Fire bullet

### General
- **P**: Pause / resume
- **Escape**: Exit demo mode or return to menu from pause

## How to Play

From the title screen, select "START CAMPAIGN" to begin the 96-stage campaign, or "START DEMO (AUTO)" to watch AI-controlled tanks play. Press C in the menu to enable two-player co-op before starting.

**Objective**: On each stage, destroy all enemy tanks and rescue all hostages to clear the stage. The command base (gold eagle tile near the bottom center) must survive -- if any bullet hits it, the game is over immediately.

**Tank combat**: Tanks move in four cardinal directions on a tile-based map. When firing, the bullet travels in the direction the tank faces. Player 1 starts with 1 active bullet limit and power level 1; picking up star powerups increases weapon level (max 3), which grants faster bullets (+38 speed per level), higher power (level 1-2 = power 2, level 3 = power 3), and at level 2+ allows 2 simultaneous bullets. Power 3 bullets can destroy steel walls.

**Enemy types**: Four enemy variants spawn with increasing probability as stages progress:
- **Basic** (yellow, 100 pts): Standard speed (78), 1 HP, standard reload
- **Fast** (orange, 200 pts): Quick speed (110), 1 HP, 15% faster reload
- **Sniper** (purple, 300 pts): Medium speed (84), 2 HP, 28% faster reload, faster bullets
- **Heavy** (red, 400 pts): Slow speed (66), 4 HP, 35% slower reload, power 2 bullets

Up to 8 enemies can be on the field simultaneously. They spawn from three lanes at the top of the map, targeting both the player and the base with probabilistic AI pathfinding.

**Hostage rescue**: Each stage spawns 5-12 hostages (scaling with stage number) on camp tiles. Walk over a hostage to rescue them (120 points each). Rescuing all hostages on a stage awards a 300-point bonus. Both combat and rescue objectives must be completed to clear a stage.

**Powerups**: Destroyed enemies have a 14-22% chance to drop a powerup (higher for heavy enemies, modified by stage profile). Powerups last 11 seconds and blink when expiring:
- **Shield (S)**: 8 seconds of invulnerability plus 2-second spawn protection
- **Star (*)**: Increase weapon level by 1 (max 3)
- **Grenade (G)**: Destroy all enemies on screen instantly
- **Clock (C)**: Freeze all enemies for 6 seconds
- **Shovel (H)**: Fortify the base ring with steel walls for 11 seconds
- **Tank (+)**: Extra life

**Kill combo**: Destroying enemies in rapid succession builds a combo (max x4 multiplier) that decays after 2.1 seconds of inactivity.

**Terrain**: Brick walls are destructible (1 HP). Steel walls are indestructible unless hit by power 3 bullets. Water blocks tank movement but not bullets. Bushes provide visual cover (drawn over tanks). Ice causes tanks to skid when stopping. The base tile is instantly destroyed by any bullet contact.

**Lives and respawning**: Each player starts with 3 lives. On death, the tank respawns at its designated spawn point after 1.2 seconds with 2 seconds of invulnerability. Weapon level decreases by 1 on death.

**Game over conditions**: All players have zero lives and no active tanks, OR the base is destroyed. Completing all 96 stages displays the campaign victory screen.

## Public API Reference

### Package `jackal_1988_lite/internal/types`

> Core data structures, constants, and utility functions shared across all packages.

#### Structs

| Struct | Fields | Description |
|--------|--------|-------------|
| `Tank` | `active`, `enemy_kind`, `x`, `y`, `dir`, `move_speed`, `hp`, `reload_timer`, `reload_delay`, `ai_move_timer`, `ai_fire_timer`, `ai_stuck_timer`, `shield_timer`, `invuln_timer`, `respawn_timer`, `lives`, `score`, `weapon_level`, `blink_timer`, `skid_timer` | Represents both player and enemy tanks with position, combat stats, AI timers, and status effects |
| `Bullet` | `active`, `owner_team`, `x`, `y`, `vx`, `vy`, `ttl`, `damage`, `power`, `radius` | A projectile with team ownership, velocity, time-to-live, and wall-breaking power |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `max_life`, `size`, `fade`, `color` | A visual effect particle with velocity, lifetime, and color |
| `Powerup` | `active`, `kind`, `x`, `y`, `ttl`, `blink`, `pulse` | A collectible pickup with type, position, and visual animation state |
| `Hostage` | `active`, `x`, `y`, `bob`, `blink` | A rescuable hostage with bobbing animation |
| `Star` | `x`, `y`, `speed`, `twinkle` | A background starfield particle |
| `Game` | `state`, `coop_enabled`, `demo_mode`, `demo_runs`, `demo_elapsed`, `menu_cursor`, `menu_blink`, `frame_counter`, `stage_index`, `stage_intro_timer`, `stage_clear_timer`, `game_over_timer`, `campaign_clear_timer`, `pause_blink`, `profile`, `freeze_all_timer`, `shovel_timer`, `camera_shake`, `camera_shake_phase`, `base_alive`, `base_flash`, `base_tiles_cached`, `score_total`, `high_score`, `hostages_goal`, `hostages_rescued`, `rescue_stage_bonus_awarded`, `enemies_to_spawn`, `enemies_spawned`, `enemies_alive`, `spawn_timer`, `kill_combo`, `combo_timer`, `rng_state`, `map_tiles`, `map_hp`, `players`, `enemies`, `bullets`, `particles`, `powerups`, `hostages`, `stars` | The central game state holding all entities, timers, scores, and map data |
| `StageProfile` | `title`, `subtitle`, `enemy_bonus`, `spawn_scale`, `drop_bonus`, `sky_top`, `sky_bottom`, `fog_alpha`, `ui_accent` | Per-stage visual and difficulty configuration |

#### Factory Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Tank::inactive` | `() -> Tank` | Creates an inactive tank placeholder for pool allocation |
| `Tank::new_player` | `(Int, Float, Float) -> Tank` | Creates a new player tank at the given spawn position with 3 lives, spawn invulnerability, and player speed |
| `Tank::new_enemy` | `(Int, Float, Float) -> Tank` | Creates a new enemy tank of the given kind (basic/fast/heavy/sniper) with appropriate speed, HP, and reload stats |
| `Bullet::inactive` | `() -> Bullet` | Creates an inactive bullet for pool allocation |
| `Particle::inactive` | `() -> Particle` | Creates an inactive particle for pool allocation |
| `Powerup::inactive` | `() -> Powerup` | Creates an inactive powerup for pool allocation |
| `Hostage::inactive` | `() -> Hostage` | Creates an inactive hostage for pool allocation |
| `Star::new` | `(Float, Float, Float, Float) -> Star` | Creates a new starfield particle with position, speed, and twinkle phase |
| `Game::new` | `() -> Game` | Creates a fresh Game with all entity pools allocated, star field initialized, and default state |
| `StageProfile::new` | `(String, String, Int, Float, Int, Color, Color, Float, Color) -> StageProfile` | Creates a stage profile with title, subtitle, difficulty modifiers, and visual theme |
| `default_stage_profile` | `() -> StageProfile` | Returns the default "Border Skirmish" profile |

#### Utility Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `absf` | `(Float) -> Float` | Absolute value for Float |
| `clampf` | `(Float, Float, Float) -> Float` | Clamp a Float to [low, high] |
| `clampi` | `(Int, Int, Int) -> Int` | Clamp an Int to [low, high] |
| `rand_next` | `(Game) -> Int` | Advance the xorshift RNG and return next positive Int |
| `rand_range` | `(Game, Int, Int) -> Int` | Random Int in [low, high] inclusive |
| `rand_rangef` | `(Game, Float, Float) -> Float` | Random Float in [low, high] |
| `tile_index` | `(Int, Int) -> Int` | Convert tile (x, y) to flat array index |
| `in_tile_bounds` | `(Int, Int) -> Bool` | Check if tile coordinates are within the 26x26 map |
| `get_tile` | `(Game, Int, Int) -> Int` | Get tile type at (tx, ty), returns steel for out-of-bounds |
| `set_tile` | `(Game, Int, Int, Int, Int) -> Unit` | Set tile type and HP at (tx, ty) |
| `world_x_to_tile` | `(Float) -> Int` | Convert world X coordinate to tile column |
| `world_y_to_tile` | `(Float) -> Int` | Convert world Y coordinate to tile row |
| `tile_center_x` | `(Int) -> Float` | Get world X center of a tile column |
| `tile_center_y` | `(Int) -> Float` | Get world Y center of a tile row |
| `world_to_screen_x` | `(Float, Float) -> Int` | Convert world X to screen X with camera shake offset |
| `world_to_screen_y` | `(Float, Float) -> Int` | Convert world Y to screen Y with camera shake offset |
| `tile_to_screen_x` | `(Int, Float) -> Int` | Convert tile column to screen X with shake |
| `tile_to_screen_y` | `(Int, Float) -> Int` | Convert tile row to screen Y with shake |
| `dir_vector_x` | `(Int) -> Float` | Get X component of a direction (left=-1, right=1, else 0) |
| `dir_vector_y` | `(Int) -> Float` | Get Y component of a direction (up=-1, down=1, else 0) |
| `tank_rect_at` | `(Float, Float) -> Rectangle` | Create a collision rectangle for a tank at given position |
| `tank_rect` | `(Tank) -> Rectangle` | Create a collision rectangle from a tank's current position |
| `rects_overlap` | `(Rectangle, Rectangle) -> Bool` | Check if two rectangles overlap |
| `distance_sq` | `(Float, Float, Float, Float) -> Float` | Squared distance between two points |
| `is_tile_solid_for_tank` | `(Int) -> Bool` | Whether a tile type blocks tank movement (brick, steel, water, base) |
| `is_tile_solid_for_bullet` | `(Int) -> Bool` | Whether a tile type blocks bullets (brick, steel, base) |
| `enemy_score` | `(Int) -> Int` | Score value for destroying an enemy of given kind |
| `enemy_color` | `(Int) -> Color` | Body color for an enemy tank of given kind |
| `team_of_player` | `(Int) -> Int` | Map player index to team constant |
| `draw_centered_text` | `(String, Int, Int, Int, Color) -> Unit` | Draw text horizontally centered at a screen position |
| `draw_shadow_text` | `(String, Int, Int, Int, Color) -> Unit` | Draw text with a black drop shadow |
| `shake_offsets` | `(Game) -> (Float, Float)` | Compute current camera shake X/Y offsets |
| `update_camera_shake` | `(Game, Float) -> Unit` | Decay camera shake over time |
| `push_camera_shake` | `(Game, Float) -> Unit` | Add to camera shake intensity, capped at max |
| `pulse_color` | `(Color, Float) -> Color` | Lerp a color toward white using a sine pulse |

#### Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `screen_width` / `screen_height` | 980 / 760 | Window dimensions |
| `map_tiles_w` / `map_tiles_h` | 26 / 26 | Map size in tiles |
| `tile_size` | 24 | Pixel size of each tile |
| `max_enemies` | 42 | Enemy pool capacity |
| `max_bullets` | 320 | Bullet pool capacity |
| `max_particles` | 960 | Particle pool capacity |
| `max_powerups` | 32 | Powerup pool capacity |
| `max_hostages` | 56 | Hostage pool capacity |
| `enemy_on_field_limit` | 8 | Max simultaneous active enemies |
| `level_count` | 96 | Total stages in campaign |
| `map_pattern_count` | 48 | Unique map layouts (cycled) |
| `tile_empty..tile_camp` | 0..7 | Tile type constants |
| `state_menu..state_campaign_clear` | 0..6 | Game state constants |
| `enemy_basic..enemy_sniper` | 0..3 | Enemy kind constants |
| `powerup_shield..powerup_tank` | 0..5 | Powerup kind constants |
| `dir_up..dir_left` | 0..3 | Direction constants |
| `team_none..team_enemy` | 0..3 | Team ownership constants |

### Package `jackal_1988_lite/internal/game`

> Game logic including state machine, player input, enemy AI, bullet physics, powerup effects, hostage rescue, and stage management.

#### Public Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main update dispatcher: advances starfield, increments frame counter, and delegates to the appropriate state handler (menu, stage intro, playing, paused, stage clear, game over, campaign clear) |
| `load_stage` | `(Game, Int) -> Unit` | Loads a stage by index: sets the profile, clears entities, loads the map pattern, seeds hostages, prepares players, configures enemy count, and enters stage intro state |
| `start_new_campaign` | `(Game) -> Unit` | Resets campaign state (scores, stage index, player tanks) and loads stage 0 |

### Package `jackal_1988_lite/internal/levels`

> Map pattern data and stage profile definitions for all 96 stages.

#### Public Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `level_pattern` | `(Int) -> Array[String]` | Returns a 26-row array of 26-character strings encoding the tile layout for a given stage index (modulo 48 unique patterns). Characters: `.` = empty, `#` = brick, `@` = steel, `~` = water, `^` = bush, `=` = ice, `B` = base, `H` = camp |
| `get_stage_profile` | `(Int) -> StageProfile` | Returns the StageProfile for a stage index (modulo 96), defining title, subtitle, enemy bonus, spawn scale, drop bonus, sky gradient colors, fog alpha, and UI accent color |

### Package `jackal_1988_lite/internal/particles`

> Particle system for explosions, sparks, and respawn bursts.

#### Public Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `spawn_particle` | `(Game, Float, Float, Float, Float, Float, Float, Color) -> Unit` | Allocate and initialize a single particle with position, velocity, lifetime, size, and color |
| `spawn_spark_burst` | `(Game, Float, Float, Int) -> Unit` | Emit a radial burst of gold spark particles |
| `spawn_explosion` | `(Game, Float, Float, Float) -> Unit` | Emit a large explosion with sparks and smoke puffs, scaled by strength; also triggers camera shake |
| `spawn_respawn_burst` | `(Game, Float, Float) -> Unit` | Emit a ring of 24 skyblue particles for tank spawn/respawn visual |
| `update_particles` | `(Game, Float) -> Unit` | Update all active particles: decay life, apply velocity with drag and gravity, deactivate expired ones |

### Package `jackal_1988_lite/internal/score`

> Score tracking, kill combo multiplier, and score granting.

#### Public Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `grant_score` | `(Game, Int, Int) -> Unit` | Add points to the total score and the specific player's score by team, update high score |
| `bump_combo` | `(Game) -> Unit` | Increment the kill combo counter (max 9) and reset the 2.1-second combo timer |
| `combo_multiplier` | `(Game) -> Int` | Return the current score multiplier based on combo count: 1 (0-1 kills), 2 (2-3), 3 (4-6), 4 (7-9) |
| `update_combo` | `(Game, Float) -> Unit` | Decay the combo timer; reset combo to 0 when timer expires |

### Package `jackal_1988_lite/internal/world`

> World-space collision detection for tanks and bullets against map geometry and other entities.

#### Public Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `point_in_world` | `(Float, Float) -> Bool` | Check if a point is within the map pixel bounds |
| `tank_hits_world` | `(Game, Float, Float) -> Bool` | Check if a tank-sized hitbox at (x, y) collides with map boundaries or solid tiles |
| `tank_hits_players` | `(Game, Float, Float, Int) -> Bool` | Check if a tank-sized hitbox overlaps any active player tank, optionally ignoring one player index |
| `tank_hits_enemies` | `(Game, Float, Float, Int) -> Bool` | Check if a tank-sized hitbox overlaps any active enemy tank, optionally ignoring one enemy index |

### Package `jackal_1988_lite/internal/render`

> All rendering: world terrain, entities, particles, UI panels, and state overlays.

#### Public Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_world` | `(Game) -> Unit` | Render the complete game world: starfield background, terrain tiles, powerups, hostages, player/enemy tanks, bullets, particles, bush overlay, and fog layer |
| `draw_ui` | `(Game) -> Unit` | Render the side panel (stage info, scores, rescue counter, enemy counter, player cards, controls, combo display) and the appropriate state overlay (menu, stage intro, pause, stage clear, game over, campaign clear) |

## Architecture

### Package Structure

```
jackal_1988_lite/
├── main.mbt                        -- Entry point: window init, game loop, draw calls
├── moon.pkg                        -- Root package config (is-main)
└── internal/
    ├── types/
    │   ├── types.mbt               -- All struct definitions (Tank, Bullet, Particle, Powerup, Hostage, Star, Game, StageProfile) and factory functions
    │   ├── constants.mbt           -- All numeric constants (screen size, tile types, states, speeds, pool sizes, spawn positions)
    │   ├── utils.mbt               -- Math helpers, RNG, tile/world coordinate conversions, collision primitives, drawing utilities, camera shake
    │   └── moon.pkg
    ├── game/
    │   ├── game_update.mbt         -- Top-level state machine: update_game dispatches to state-specific handlers (menu, playing, paused, stage intro/clear, game over, campaign clear)
    │   ├── player_system.mbt       -- Player input reading, movement with tile/entity collision, firing with weapon level scaling, death/respawn logic
    │   ├── enemy_system.mbt        -- Enemy spawning from 3 lanes, AI pathfinding toward players/base, shooting with line-of-sight checks, kill/destroy/score logic
    │   ├── bullet_system.mbt       -- Bullet allocation, sub-step movement with tile damage, player/enemy hit detection, bullet-vs-bullet cancellation
    │   ├── demo_ai.mbt             -- Autonomous AI for demo mode: target selection (enemies/powerups/guard base), movement planning, line-of-fire alignment
    │   ├── powerups.mbt            -- Powerup spawning, pickup detection, effect application (shield, star, grenade, clock, shovel, tank), global effect timers
    │   ├── rescue_system.mbt       -- Hostage spawning on camp tiles, pickup detection, rescue counter, stage bonus, rescue objective tracking
    │   ├── stage.mbt               -- Stage loading (map parsing, base fortification, player preparation), campaign reset, entity clearing, stage enemy composition
    │   └── moon.pkg
    ├── levels/
    │   ├── levels.mbt              -- 48 unique 26x26 tile map patterns as character-encoded string arrays
    │   ├── profiles.mbt            -- 96 unique StageProfile definitions with escalating difficulty and visual themes
    │   └── moon.pkg
    ├── particles/
    │   ├── particles.mbt           -- Particle pool management, spark/explosion/respawn burst emitters, physics update with drag and gravity
    │   └── moon.pkg
    ├── render/
    │   ├── render_world.mbt        -- World rendering: starfield, terrain tiles (brick, steel, water, ice, base, camp), bush overlay, fog layer, tank/bullet/powerup/hostage/particle drawing
    │   ├── render_ui.mbt           -- UI panel rendering: stage info, scores, enemy counter, player cards, control hints, combo display; state overlays (menu, pause, intro, clear, game over, campaign complete)
    │   └── moon.pkg
    ├── score/
    │   ├── score.mbt               -- Score granting by team, kill combo tracking with time-decay multiplier
    │   └── moon.pkg
    └── world/
        ├── world.mbt              -- World-space collision queries: point-in-bounds, tank-vs-tiles, tank-vs-tanks
        └── moon.pkg
```

### Data Flow

1. `main` initializes the window and creates a `Game` struct via `Game::new()`, which pre-allocates all entity arrays (42 enemies, 320 bullets, 960 particles, 32 powerups, 56 hostages, 120 stars) and sets the initial menu state.
2. Each frame, `update_game` advances the starfield, increments the frame counter, and dispatches to the current state handler. During `state_playing`, the update sequence is: camera shake decay, combo timer update, global effect timers (freeze/shovel), player reload/invuln/shield/skid timers, player input (or demo AI), enemy spawn timer, enemy AI (movement + firing), bullet physics (sub-stepped), powerup collection, hostage rescue, player respawns, particle physics, base flash decay, and win/lose condition checks.
3. The `game` package reads keyboard input via `@raylib.is_key_down`/`is_key_pressed` for player controls, or generates synthetic commands via `demo_ai.mbt` when in demo mode. Movement attempts are validated through `@world.tank_hits_world`, `@world.tank_hits_players`, and `@world.tank_hits_enemies`.
4. Bullets use 2-step sub-stepping per frame for accurate narrow-wall collision. On hit, `damage_tile_at_point` reduces brick HP or destroys steel (power 3), and `bullet_hit_enemy`/`bullet_hit_player` handles entity damage. Bullet-vs-bullet cancellation removes opposing bullets that overlap.
5. Rendering in `main` calls `draw_world` (terrain, entities in correct z-order with bushes on top) then `draw_ui` (side panel and state overlays). Camera shake offsets are computed once per frame and passed through all drawing functions.
6. Stage transitions flow: menu -> stage_intro (1.6s) -> playing -> stage_clear (2.4s) -> next stage intro (or campaign_clear). Game over returns to menu after a delay.

### Key Design Patterns

- **Object pool pattern**: All entity types (Tank, Bullet, Particle, Powerup, Hostage) are pre-allocated as fixed-capacity arrays with `active` boolean flags. Factory functions like `Tank::inactive()` produce sentinel values for pool initialization.
- **Integer-encoded enums**: Directions (0-3), tile types (0-7), game states (0-6), enemy kinds (0-3), powerup kinds (0-5), and team ownership (0-3) are all represented as `Int` constants rather than MoonBit enums.
- **Multi-package ECS-like architecture**: The game is split into 7 internal packages with clear responsibilities: `types` (data), `game` (logic), `levels` (content), `particles` (effects), `render` (drawing), `score` (scoring), and `world` (collision). All packages share the `Game` struct as a central state container.
- **Stage profile system**: Each of the 96 stages has a `StageProfile` that modulates enemy counts, spawn rates, powerup drop rates, sky gradient colors, fog opacity, and UI accent color, creating visual and mechanical variety without changing the core rules.
- **Character-encoded maps**: Map layouts are stored as arrays of 26-character strings where each character maps to a tile type (`#` = brick, `@` = steel, `~` = water, etc.), parsed at stage load time via `parse_level_char`.
- **Demo AI system**: An autonomous AI in `demo_ai.mbt` drives both players during demo mode. It selects targets (nearest enemy or powerup), plans movement using priority-direction pathfinding with collision look-ahead, aligns for line-of-fire shots, and occasionally fires randomly. This allows attract-mode gameplay without human input.
- **Sub-stepped bullet collision**: Bullets use 2 sub-steps per frame to prevent tunneling through single-tile walls, ensuring accurate hit detection even at high speeds (350 units/s for player bullets).
- **Base fortification ring**: A 14-tile ring around the command base is cached and can be temporarily upgraded to steel walls via the shovel powerup, then restored when the timer expires.

## Improvement & Refinement Plan

1. **Replace integer constants with proper enums**: The codebase uses `Int` constants for directions (`dir_up` = 0), tile types (`tile_brick` = 1), game states (`state_menu` = 0), enemy kinds, and powerup kinds. Converting these to MoonBit `enum` types would enable exhaustive pattern matching, eliminate magic number bugs, and improve readability in functions like `enemy_desired_dir`, `parse_level_char`, and `apply_powerup`.

2. **Decouple the Tank struct into player-specific and enemy-specific types**: The `Tank` struct contains fields that are only relevant to one role -- `ai_move_timer`, `ai_fire_timer`, and `ai_stuck_timer` are only used by enemies, while `lives`, `score`, and `weapon_level` are only used by players. Splitting into `PlayerTank` and `EnemyTank` would reduce struct size and make the code self-documenting.

3. **Extract the demo AI into a composable behavior tree**: The `demo_player_command` function in `demo_ai.mbt` implements a linear priority chain (seek powerup -> seek enemy -> guard base). A behavior tree or state machine pattern would make it easier to add new AI behaviors like retreating when low on lives, prioritizing hostage rescue, or cooperating between the two demo players.

4. **Add sound effects for combat feedback**: The game has extensive visual feedback (explosions, sparks, camera shake) but no audio. Critical moments like firing, bullet impacts, tank destruction, powerup pickup, hostage rescue, stage clear, and game over would benefit greatly from sound effects to enhance the retro arcade feel.

5. **Compress the level pattern data**: The `levels.mbt` file contains 48 unique map patterns as arrays of 26-character strings, totaling significant source code volume. Run-length encoding or a compact binary format decoded at startup would reduce file size substantially while keeping the same map variety.

6. **Add difficulty selection to the menu**: The campaign currently has a fixed difficulty curve controlled by stage profiles. Adding Easy/Normal/Hard options that modify `spawn_scale`, `enemy_bonus`, and `drop_bonus` globally would make the game accessible to a wider range of players while keeping the 96-stage campaign structure.

7. **Implement persistent high score storage**: The `high_score` field resets to zero each time the game launches. Saving and loading the high score via file I/O would provide long-term motivation and a sense of progression across play sessions.

8. **Add minimap or radar to the side panel**: The 26x26 tile map is large relative to the viewport, and enemy positions beyond the visible area are hard to track. A small minimap on the side panel showing enemy positions, hostage locations, and the base would improve strategic decision-making, especially in later stages with fog.
