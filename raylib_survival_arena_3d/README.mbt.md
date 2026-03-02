# Survival Arena 3D

Survival Arena 3D is a first-person wave-based survival shooter built with MoonBit and raylib. Set in a 60x60 enclosed arena with pillars, low walls, ramps, and ammo crates, the player must survive 30 increasingly difficult waves of diverse enemies ranging from shambling zombies and fast runners to shield-bearing warriors, exploding kamikazes, corpse-reviving necromancers, and multi-phase bosses.

The core gameplay loop alternates between intense combat waves and a between-wave shop phase. During combat, the player moves with WASD, aims with the mouse in first-person perspective, and fights using six weapons: pistol (infinite ammo), shotgun (8-pellet spread), assault rifle (automatic fire), sniper rifle (penetrating shots with 2.5x headshot damage), rocket launcher (splash damage), and minigun (spin-up mechanic with increasing spread). Each weapon has its own magazine, reload time, and upgrade path. Enemies drop pickups including health, ammo, speed/damage boosts, shields, and rare nukes. A combo system rewards consecutive kills with score multipliers up to 4x, and multi-kills (double, triple, multi) grant bonus points.

The game features a deep progression system with a 14-item shop for purchasing health, armor, ammo, permanent stat upgrades (damage +15%, speed +10%), new weapons (sniper, rocket, minigun), and deployable defenses (barricades and spike traps). The 3D arena includes static cover (pillars and low walls), ramps for elevation, and respawning ammo crates. Eight distinct enemy types each have unique AI behaviors: spitters maintain distance and fire acid projectiles, brutes charge when close, exploders rush in and self-destruct, shielded enemies block frontal damage, and necromancers revive fallen enemies. Boss enemies appear on waves 10, 15, 20, 25, and 29 with phase-based abilities that escalate as their health drops.

## Build and Run

```bash
moon build --target native raylib_survival_arena_3d/
./_build/native/debug/build/raylib_survival_arena_3d/raylib_survival_arena_3d.exe
```

## Controls

- **W/A/S/D**: Move forward/left/backward/right
- **Mouse**: Look around (first-person camera)
- **Left Mouse Button**: Fire weapon (hold for automatic weapons)
- **R**: Manual reload
- **Left Shift**: Sprint (1.6x speed, cannot sprint while crouching)
- **Left Control / C**: Toggle crouch (0.5x speed, lower camera)
- **1-6**: Select weapon (1=Pistol, 2=Shotgun, 3=Rifle, 4=Sniper, 5=Rocket, 6=Minigun)
- **Mouse Wheel**: Cycle through owned weapons
- **Up/Down Arrow**: Navigate shop menu (between waves)
- **Enter / E**: Buy selected shop item
- **Space**: Skip shop timer and start next wave
- **Escape**: Pause game
- **P**: Unpause
- **Q**: Quit to menu (while paused)

## How to Play

Press Enter or Space on the title screen to start. The game begins with a 15-second shop phase before Wave 1. During shop phases, navigate the 14-item shop with Up/Down arrows and buy items with Enter or E. Press Space to skip the timer and start the wave immediately.

During waves, enemies spawn from the arena edges at intervals of 0.6 seconds. Kill enemies to earn gold (10-150 per enemy depending on type) and score points (multiplied by your combo). Collect dropped pickups by walking over them. Ammo crates scattered around the arena respawn every 20 seconds and provide weapon-specific ammo.

The combo system tracks consecutive kills within a 3-second window. Each kill increases the combo multiplier by 0.25 (up to 4.0x). Rapid kills also trigger multi-kill bonuses: double kill (+50), triple kill (+100), and multi kill (+200). Headshots deal 2.5x damage and grant +25 bonus score. The headshot zone is the top 20% of the enemy's hitbox.

Weapons must be reloaded when the magazine empties. The pistol has infinite reserve ammo. Other weapons consume ammo from reserves. The minigun requires a 0.6-second spin-up before firing and has increasing spread during sustained fire.

Between waves, spend gold on healing, armor, ammo refills, permanent stat upgrades, new weapons, barricades (placed in front of the player), and spike traps. Barricades have 150 HP and block enemy movement; enemies attack barricades when stuck against them. Each wave completed awards a gold bonus of 50 + (wave * 20).

Enemy difficulty scales with each wave: HP multiplied by 1 + wave*0.08, speed multiplied by 1 + wave*0.025 (capped at 2x), and overall difficulty by 1 + wave*0.05. Surviving all 30 waves triggers victory. Losing all HP results in game over.

## Public API Reference

### Package `raylib_survival_arena_3d`

> Main entry point: initializes the window, runs the game loop.

There are no public functions or types in this package.

### Package `raylib_survival_arena_3d/internal/types`

> Core type definitions, constants, utility functions, and object pool management.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Menu`, `Playing`, `WaveComplete`, `Paused`, `GameOver` | Game state machine controlling flow between menus, combat, shop, and end screens |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Player` | `x`, `y`, `z`, `yaw`, `pitch`, `hp`, `armor`, `current_weapon`, `ammo`, `magazine`, `score`, `money`, `kills`, `combo_count`, `combo_mult`, `owns_weapon`, `minigun_spin`, `recoil_offset`, `weapon_damage_level`, `weapon_rate_level`, `weapon_mag_level` | Player state including 3D position, FPS camera angles, health/armor, weapon inventory with per-weapon upgrades, combo system, boost timers, and stats |
| `Enemy` | `active`, `kind`, `x/y/z`, `vx/vy/vz`, `hp`, `max_hp`, `speed`, `damage`, `attack_timer`, `size`, `gold_value`, `score_value`, `spit_timer`, `stun_timer`, `explode_triggered`, `revive_timer`, `facing_angle`, `boss_phase`, `state`, `can_revive`, `drops_pickup` | Enemy entity with AI state machine, type-specific behaviors, and death/revive tracking |
| `Projectile` | `active`, `kind`, `x/y/z`, `dx/dy/dz`, `speed`, `damage`, `life`, `is_enemy`, `splash_radius`, `penetration`, `is_headshot_capable` | Projectile for both player bullets and enemy spit attacks |
| `Particle` | `active`, `x/y/z`, `vx/vy/vz`, `life`, `max_life`, `r/g/b`, `size`, `kind` | Visual particle with type-based physics (blood, muzzle, explosion, shell, spark, heal) |
| `Pillar` | `x`, `z`, `radius`, `height` | Static cylindrical obstacle in the arena |
| `Crate` | `active`, `x`, `z`, `respawn_timer`, `kind` | Respawning ammo pickup crate tied to a weapon type |
| `LowWall` | `x`, `z`, `width`, `height`, `depth`, `angle` | Half-height cover wall |
| `Ramp` | `x`, `z`, `width`, `length`, `height`, `angle` | Elevated ramp structure |
| `Pickup` | `active`, `kind`, `x/y/z`, `float_timer`, `life` | Dropped pickup with bobbing animation and lifetime |
| `ArenaTrap` | `active`, `kind`, `x`, `z`, `cooldown_timer`, `active_timer`, `damage` | Placeable trap (spike, flame, electric) |
| `Barricade` | `active`, `x`, `z`, `hp`, `max_hp` | Destructible defensive barrier |
| `KillFeedEntry` | `active`, `text`, `timer`, `color_r/g/b` | Kill feed notification with colored text and fade timer |
| `WeaponState` | `reload_timer`, `reloading`, `reload_time` | Per-weapon cooldown and reload tracking |
| `ShopItem` | `name`, `cost`, `kind` | Shop item definition |
| `DamageIndicator` | `active`, `angle`, `timer` | Directional damage indicator on the HUD |
| `Game` | `state`, `player`, `weapons`, `current_wave`, `wave_timer`, `spawn_timer`, `enemies_to_spawn`, `pillars`, `crates`, `low_walls`, `ramps`, `enemies`, `projectiles`, `particles`, `pickups`, `traps`, `barricades`, `kill_feed`, `damage_indicators`, `cam_pos/target`, `shop_cursor`, `difficulty`, stats fields | Main game state container with all entity pools, arena geometry, wave system, camera, UI state, and statistics |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Player::new` | `() -> Player` | Creates a new player with 100 HP, 3 starting weapons, and default stats |
| `Enemy::inactive` | `() -> Enemy` | Creates an inactive enemy for pool pre-allocation |
| `Projectile::inactive` | `() -> Projectile` | Creates an inactive projectile for pool pre-allocation |
| `Particle::inactive` | `() -> Particle` | Creates an inactive particle for pool pre-allocation |
| `Crate::new` | `(Float, Float, Int) -> Crate` | Creates an active ammo crate at position for a weapon type |
| `Pickup::inactive` | `() -> Pickup` | Creates an inactive pickup for pool pre-allocation |
| `ArenaTrap::inactive` | `() -> ArenaTrap` | Creates an inactive trap for pool pre-allocation |
| `Barricade::inactive` | `() -> Barricade` | Creates an inactive barricade for pool pre-allocation |
| `KillFeedEntry::inactive` | `() -> KillFeedEntry` | Creates an inactive kill feed entry |
| `WeaponState::new` | `() -> WeaponState` | Creates a new weapon state with no active reload |
| `DamageIndicator::inactive` | `() -> DamageIndicator` | Creates an inactive damage indicator |
| `Game::new` | `() -> Game` | Creates a new game with arena geometry (8 pillars, 6 crates, 6 walls, 4 ramps) and all entity pools |
| `absf` | `(Float) -> Float` | Absolute value of a float |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to [low, high] |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer to [low, high] |
| `minf` | `(Float, Float) -> Float` | Returns the smaller of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns the larger of two floats |
| `lerpf` | `(Float, Float, Float) -> Float` | Linear interpolation between two floats |
| `sign` | `(Float) -> Float` | Returns -1.0, 0.0, or 1.0 based on sign |
| `distance2d` | `(Float, Float, Float, Float) -> Float` | Euclidean distance between two 2D points (xz plane) |
| `distance3d` | `(Float, Float, Float, Float, Float, Float) -> Float` | Euclidean distance between two 3D points |
| `normalize3d` | `(Float, Float, Float) -> (Float, Float, Float)` | Normalizes a 3D vector, returns zero vector if length < 0.0001 |
| `dot3d` | `(Float, Float, Float, Float, Float, Float) -> Float` | Dot product of two 3D vectors |
| `angle_between` | `(Float, Float, Float, Float) -> Float` | Angle in radians between two 2D points using atan2 |
| `angle_within` | `(Float, Float, Float) -> Bool` | Tests if two angles are within a threshold (wrapping-aware) |
| `rand_next` | `(Game) -> Int` | XOR-shift RNG returning next positive integer |
| `rand_range` | `(Game, Int, Int) -> Int` | Random integer in [low, high] |
| `rand_rangef` | `(Game, Float, Float) -> Float` | Random float in [low, high] |
| `rand_bool` | `(Game, Float) -> Bool` | Returns true with given probability |
| `alloc_enemy` | `(Game) -> Int` | Finds first inactive enemy slot, returns -1 if full |
| `alloc_projectile` | `(Game) -> Int` | Finds first inactive projectile slot |
| `alloc_particle` | `(Game) -> Int` | Finds first inactive particle slot |
| `alloc_pickup` | `(Game) -> Int` | Finds first inactive pickup slot |
| `alloc_barricade` | `(Game) -> Int` | Finds first inactive barricade slot |
| `alloc_trap` | `(Game) -> Int` | Finds first inactive trap slot |
| `spawn_particles` | `(Game, Float, Float, Float, Int, Int, Int, Int) -> Unit` | Spawns colored particles at a 3D position |
| `spawn_particles_typed` | `(Game, Float, Float, Float, Int, Int, Int, Int, Int) -> Unit` | Spawns typed particles (blood, muzzle, explosion, shell, spark, heal) |
| `spawn_particles_dir` | `(Game, Float, Float, Float, Float, Float, Float, Int, Int, Int, Int) -> Unit` | Spawns directional particles for muzzle flash effects |
| `spawn_shell_casing` | `(Game, Float, Float, Float, Float, Float) -> Unit` | Spawns a shell casing particle ejected to the right |
| `in_arena` | `(Float, Float) -> Bool` | Checks if a point is inside the arena bounds |
| `clamp_to_arena` | `(Float, Float) -> (Float, Float)` | Clamps a position to arena bounds with margin |
| `push_from_pillar` | `(Float, Float, Float, Float, Float, Float) -> (Float, Float, Bool)` | Circle-vs-circle collision push against a pillar |
| `push_from_box` | `(Float, Float, Float, Float, Float, Float, Float) -> (Float, Float, Bool)` | Circle-vs-box collision push against a wall/barricade |
| `weapon_name` | `(Int) -> String` | Returns the display name for a weapon type |
| `weapon_short_name` | `(Int) -> String` | Returns the short name for weapon slot UI |
| `weapon_fire_rate` | `(Int) -> Float` | Returns base fire rate for a weapon |
| `weapon_damage` | `(Int) -> Float` | Returns base damage for a weapon |
| `weapon_proj_speed` | `(Int) -> Float` | Returns projectile speed for a weapon |
| `weapon_reload_time` | `(Int) -> Float` | Returns reload time for a weapon |
| `weapon_mag_size` | `(Int) -> Int` | Returns base magazine size for a weapon |
| `effective_fire_rate` | `(Player, Int) -> Float` | Returns fire rate with upgrade level applied (-12% per level) |
| `effective_damage` | `(Player, Int) -> Float` | Returns damage with upgrades (+20% per level), boosts, and multiplier |
| `effective_mag_size` | `(Player, Int) -> Int` | Returns magazine size with upgrade level (+30% per level) |
| `enemy_name` | `(Int) -> String` | Returns the display name for an enemy type |
| `pickup_name` | `(Int) -> String` | Returns the display name for a pickup type |
| `count_active_enemies` | `(Game) -> Int` | Counts currently active enemies in the pool |
| `show_message` | `(Game, String, Float) -> Unit` | Displays a temporary HUD message |
| `add_kill_feed` | `(Game, String, Int, Int, Int) -> Unit` | Adds a colored entry to the kill feed, shifting older entries down |
| `update_kill_feed` | `(Game, Float) -> Unit` | Updates kill feed timers, deactivating expired entries |
| `update_damage_indicators` | `(Game, Float) -> Unit` | Updates damage indicator timers |
| `add_damage_indicator` | `(Game, Float, Float) -> Unit` | Adds a directional damage indicator from a source position |
| `is_headshot_hit` | `(Float, Float, Float) -> Bool` | Tests if projectile Y is in the top 20% of enemy hitbox |
| `combo_text` | `(Int) -> String` | Returns combo tier text (COMBO, KILLING SPREE, RAMPAGE, UNSTOPPABLE) |
| `push_from_barricades` | `(Game, Float, Float, Float) -> (Float, Float)` | Pushes entity away from all active barricades |
| `push_from_low_walls` | `(Game, Float, Float, Float) -> (Float, Float)` | Pushes entity away from all low walls |

### Package `raylib_survival_arena_3d/internal/levels`

> Wave definitions, enemy stat tables, shop configuration, and boss parameters.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `get_wave_enemy_kind` | `(Int, Int) -> Int` | Returns the enemy type to spawn for a given wave and spawn index |
| `get_wave_total_enemies` | `(Int) -> Int` | Returns total enemy count for a wave |
| `get_wave_kinds` | `(Int) -> Array[Int]` | Returns the array of enemy types for a wave |
| `get_wave_counts` | `(Int) -> Array[Int]` | Returns the array of enemy counts per type for a wave |
| `get_wave_hp_mult` | `(Int) -> Float` | Returns HP multiplier for a wave (1.0 + wave * 0.08) |
| `get_wave_speed_mult` | `(Int) -> Float` | Returns speed multiplier for a wave (capped at 2.0) |
| `enemy_base_hp` | `(Int) -> Float` | Base HP for each enemy type (20-500) |
| `enemy_base_speed` | `(Int) -> Float` | Base speed for each enemy type (2.0-6.5) |
| `enemy_base_damage` | `(Int) -> Float` | Base damage per attack for each enemy type |
| `enemy_attack_range` | `(Int) -> Float` | Attack range for each enemy type (1.5-20.0) |
| `enemy_size` | `(Int) -> Float` | Hitbox size for each enemy type (0.5-1.5) |
| `enemy_gold_value` | `(Int) -> Int` | Gold dropped by each enemy type (10-150) |
| `enemy_score_value` | `(Int) -> Int` | Score value for each enemy type (10-300) |
| `enemy_spit_cooldown` | `(Int) -> Float` | Ranged attack cooldown for spitters and necromancers |
| `wave_bonus` | `(Int) -> Int` | Gold bonus for completing a wave (50 + wave * 20) |
| `enemy_drop_chance` | `(Int) -> Float` | Pickup drop probability by enemy type (6%-80%) |
| `random_pickup_kind` | `(Int) -> Int` | Weighted random pickup type (35% health, 25% ammo, etc.) |
| `shop_item_count` | `() -> Int` | Returns 14 (total shop items) |
| `shop_item_name` | `(Int) -> String` | Returns the display name for a shop item |
| `shop_item_cost` | `(Int) -> Int` | Returns the gold cost for a shop item |
| `boss_phase_hp_threshold` | `(Int) -> Float` | HP percentage threshold for boss phase transitions |
| `boss_ability_cooldown` | `(Int) -> Float` | Ability cooldown per boss phase (5.0 down to 2.0) |
| `boss_charge_speed_mult` | `(Int) -> Float` | Boss charge speed multiplier per phase (2.0-3.5) |

### Package `raylib_survival_arena_3d/internal/game`

> Game logic: player movement, enemy AI, weapon systems, projectile physics, shop, and wave management.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main update dispatcher: updates particles, kill feed, damage indicators, then delegates to state-specific update |

### Package `raylib_survival_arena_3d/internal/render`

> 3D world rendering and 2D UI overlay.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_world` | `(Game) -> Unit` | Renders the 3D scene: arena floor/walls, pillars, walls, ramps, crates, barricades, traps, pickups, enemies, projectiles, and particles |
| `draw_ui` | `(Game) -> Unit` | Draws state-dependent 2D overlays: HUD (HP/armor bars, ammo, weapon slots, wave info), crosshair with hit markers, weapon viewmodel, shop panel, pause screen, and game over screen |

## Architecture

### Package Structure

```
raylib_survival_arena_3d/
├── main.mbt                          -- Entry point: window init, game loop
├── moon.pkg                          -- Package config (is-main), imports types/game/render
└── internal/
    ├── types/
    │   ├── types.mbt                 -- All structs: Player, Enemy, Projectile, Particle, Game, etc.
    │   ├── constants.mbt             -- 150+ tuning constants (weapons, enemies, arena, physics, scoring)
    │   ├── utils.mbt                 -- Math, collision, RNG, pool allocators, particle spawners, UI helpers
    │   └── moon.pkg                  -- Imports math
    ├── game/
    │   ├── game_update.mbt           -- State dispatch, menu/pause/game-over, wave management, shop, pickups, crates, traps
    │   ├── player_system.mbt         -- Player movement, FPS camera, damage handling, boost timers, crouch/sprint
    │   ├── enemy_system.mbt          -- Enemy spawning, 8 AI behaviors, combat, death/loot, trap interaction
    │   ├── weapon_system.mbt         -- Weapon firing, reloading, projectile creation, projectile updates, explosions
    │   └── moon.pkg                  -- Imports types, levels, math, raylib
    ├── levels/
    │   ├── levels.mbt                -- 30 wave definitions, enemy stat tables, shop items, boss configs
    │   └── moon.pkg                  -- No imports (pure data)
    └── render/
        ├── render_world.mbt          -- 3D rendering: arena, pillars, walls, ramps, crates, barricades, traps, enemies (8 distinct models), projectiles, particles
        ├── render_ui.mbt             -- 2D UI: menu, HUD, crosshair, weapon display, shop, pause, game over
        └── moon.pkg                  -- Imports types, math, raylib
```

The `levels` package is a pure data package with no dependencies, making wave definitions and enemy stat tables easy to tune independently. The `types` package contains both data structures and utility functions including collision detection, RNG, and pool allocation, serving as the shared foundation. The `game` package is split by system (player, enemy, weapon) for maintainability. The `render` package is split between 3D world rendering and 2D UI overlays.

### Data Flow

1. **Input**: `update_player` reads mouse delta for FPS camera rotation and WASD keys for movement. `handle_shooting` reads mouse button state. `update_playing` reads number keys and scroll wheel for weapon selection. Shop navigation uses arrow keys and Enter/E.
2. **Update**: `update_game` dispatches to state-specific handlers. During `Playing`, systems execute in order: player movement, camera update, weapon cooldowns, shooting, enemy AI, projectile physics, crate respawning, pickup collection, trap updates, message timers, weapon selection, and wave status checks.
3. **Enemy AI**: Each of the 8 enemy types has a dedicated AI function. The `update_enemies_ai` function spawns enemies from wave definitions, then iterates all active enemies applying: stun checks, distance/direction to player, type-specific movement and attack AI, velocity application, arena/pillar/barricade collision, enemy-enemy push-apart, and trap damage.
4. **Projectiles**: `fire_weapon` creates projectiles with weapon-specific properties (shotgun pellets, sniper penetration, rocket splash, minigun spread). `update_projectiles` moves projectiles, checks lifetime, tests collision against floor/walls/pillars/barricades, and resolves hits with headshot detection and shield-block checks.
5. **Render**: `draw_world` builds a `Camera3D` from player position and look direction, then draws all 3D elements in the arena. `draw_ui` overlays 2D HUD elements based on game state.

### Key Design Patterns

- **Object Pool Pattern**: Eight entity pools (enemies 128, projectiles 256, particles 512, pickups 32, traps 12, barricades 16, kill feed 5, damage indicators 4) use `Array` with `active` flags and linear-scan allocation.
- **State Machine**: `GameState` enum drives top-level flow (Menu/Playing/WaveComplete/Paused/GameOver). Enemies have an integer `state` field (0=spawn, 1=chase, 2=attack/charge, 3=stagger). Boss enemies have a separate `boss_phase` (0-3) based on HP thresholds.
- **Type-Dispatched AI**: Enemy behavior is dispatched by `kind` integer to specialized functions (`update_melee_ai`, `update_runner_ai`, `update_brute_ai`, `update_spitter_ai`, `update_exploder_ai`, `update_necromancer_ai`, `update_shielded_ai`, `update_boss_ai`), each implementing unique movement and attack patterns.
- **Weapon Upgrade System**: Three upgrade axes per weapon (damage, fire rate, magazine size) stored in per-weapon arrays on the `Player` struct, with `effective_*` functions computing final values.
- **Circle-vs-Geometry Collision**: `push_from_pillar` (circle-vs-circle) and `push_from_box` (circle-vs-AABB with interior push-out) handle player and enemy collision against all static and dynamic obstacles.
- **Data-Driven Waves**: The `levels` package defines all 30 waves as pure functions returning enemy type and count arrays, completely decoupled from game logic.
- **XOR-Shift RNG**: Deterministic RNG via `rand_next` using XOR-shift operations, avoiding external dependencies for random number generation.

## Improvement & Refinement Plan

1. **Replace integer constants with enums for weapon and enemy types**: `weapon_pistol`, `enemy_zombie`, `pickup_health`, etc. are all `Int` constants in `constants.mbt`. Converting these to proper MoonBit enums would enable exhaustive pattern matching in the many dispatch functions (`weapon_name`, `weapon_fire_rate`, `enemy_base_hp`, `update_enemies_ai`, `enemy_color`), preventing missed cases and improving type safety.

2. **Extract shop system into its own package**: `buy_shop_item` in `game_update.mbt` is a 140-line function with hardcoded item indices. Moving shop logic to a dedicated `internal/shop` package with a data-driven item registry would improve modularity and make it easier to add new items.

3. **Add spatial partitioning for enemy collision**: The enemy-enemy push-apart in `update_enemies_ai` uses O(n^2) pairwise distance checks across all 128 enemy slots. With large late-game waves, a grid-based spatial hash would significantly reduce collision checks.

4. **Implement weapon upgrade persistence in the shop UI**: While `weapon_damage_level`, `weapon_rate_level`, and `weapon_mag_level` arrays exist on the `Player` struct and `effective_damage`/`effective_fire_rate`/`effective_mag_size` use them, the shop in `buy_shop_item` only modifies the global `damage_mult` and `speed_mult`. Adding per-weapon upgrade shop items would utilize the existing infrastructure.

5. **Add arena variation between waves**: Currently `Game::new` creates a fixed arena layout with 8 pillars, 6 crates, 6 walls, and 4 ramps. Adding arena layout rotation or progressive arena expansion as waves progress would increase variety and strategic depth.

6. **Implement proper 3D collision for projectiles against low walls and barricades**: In `update_projectiles`, projectile-vs-barricade collision only checks 2D distance and a height threshold. Using proper 3D AABB intersection with `push_from_box` would prevent projectiles from passing through cover at certain angles.

7. **Add a minimap to the HUD**: The constants `minimap_size`, `minimap_x`, and `minimap_y` are defined in `constants.mbt` but no minimap rendering exists in `render_ui.mbt`. Implementing a top-down minimap showing enemy positions, pickups, and arena layout would improve spatial awareness, especially during hectic late-game waves.

8. **Consolidate enemy rendering with a table-driven approach**: The `draw_enemies` function in `render_world.mbt` dispatches to 8 separate drawing functions (`draw_zombie`, `draw_runner`, `draw_brute`, etc.), each 40-80 lines of cube/sphere draw calls. A data-driven body part system defining limb positions, sizes, and colors per enemy type would reduce code duplication significantly.
