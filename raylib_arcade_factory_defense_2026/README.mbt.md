# Arcade Factory Defense 2026

A twin-stick arena defense game where the player protects a central factory core from 10 waves of increasingly dangerous enemies. The core loop combines direct combat -- shooting enemies with an aim-directed weapon -- with a turret-building economy fueled by scrap dropped from defeated foes. The player must balance between aggressive combat to maintain kill combos and strategic turret placement to create overlapping fields of fire.

Enemies spawn from the arena edges in waves of increasing size and variety. Kind-0 "drones" are small and fast, kind-1 "gunners" orbit at range and fire projectiles, and kind-2 "heavies" (appearing from wave 6) are large, slow tanks that fire spreads of three bullets. All enemies target the factory core by default but switch to chasing the player when within 260px. The player has a rapid-fire weapon (with a heat gauge that disables firing at 94%), a dash ability that costs 20 energy with a 1.16s cooldown, and an EMP bomb that deals 44 damage in a 240px radius while clearing nearby enemy projectiles.

Between waves, the player earns bonus scrap and can enter build mode to place Auto Turrets (12 scrap, 220px range, rapid fire) or Cannon Turrets (26 scrap, 300px range, heavy shots). Turrets auto-target the nearest enemy and can be destroyed by enemy fire and ramming. Surviving all 10 waves wins the game; the run ends if either the player's HP or the core's HP reaches zero.

## Build and Run

```bash
moon build --target native raylib_arcade_factory_defense_2026/
./_build/native/debug/build/raylib_arcade_factory_defense_2026/raylib_arcade_factory_defense_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move player
- **Mouse**: Aim direction (when not in build mode, aim follows cursor within arena)
- **J / Space**: Hold to fire weapon (disabled in build mode)
- **K / Right Shift**: Dash in aim direction (1.16s cooldown, costs 20 energy)
- **L**: Deploy EMP bomb (5.2s cooldown, costs 36 energy, 240px area damage)
- **B**: Toggle build mode on/off
- **T**: Cycle turret type (Auto / Cannon); also L while in build mode
- **R / Enter**: Restart from win/lose screens
- **F11**: Toggle fullscreen
- **Touch D-pad**: On-screen movement buttons (bottom-left)
- **Touch buttons**: FIRE, DASH, BUILD, BOMB (bottom-right)

## How to Play

Press Enter or tap to start from the title screen. Your character spawns near the factory core in a 1280x760 arena. Enemies arrive in waves (8 + wave * 3 per wave) from random edges. Shoot them to earn score and scrap drops, then collect scrap by walking over it.

**Combat mechanics:**
- Your weapon fires at ~8.6 shots/s (scaling slightly with wave), adding 7 heat per shot. Heat decays at 38/s. If heat reaches 94, firing is blocked until it cools down.
- From wave 4 onward, your weapon fires a 3-bullet spread instead of a single shot.
- Dash grants 0.2 seconds of boosted speed (460 vs 300 normal) and reduces incoming damage by 42%.
- The EMP bomb deals 44 damage to all enemies within 240px and destroys enemy projectiles within 280px.
- Kill combos increase per consecutive kill without taking damage. Each kill awards 44 + kind * 24 + combo * 2 score.

**Building:**
- Press B to enter build mode. Click or tap to place turrets. Press B again to exit build mode.
- Auto Turrets cost 12 scrap, have 100 HP, 220px range, and fire at ~4/s.
- Cannon Turrets cost 26 scrap, have 160 HP, 300px range, and fire heavy shots at ~1.2/s.
- Turrets cannot be placed within 56px of each other, within 64px of the core, or too close to arena edges.
- Turrets auto-target and fire at the nearest enemy within range.
- Enemies can damage turrets by ramming (proximity contact).

**Wave progression:**
- Between waves, you receive a 3.8-second preparation period and a scrap bonus (8 + wave).
- Enemy spawn rate increases each wave (0.62 - wave * 0.028 seconds between spawns).
- Enemies gain more HP per wave (+2.8/4.0/8.4 per wave for each kind).
- Turret fire rates also improve slightly per wave.
- Survive all 10 waves to see the "Factory Secured" victory screen.

**Lose conditions:** Player HP reaches 0 ("Pilot down") or core HP reaches 0 ("Core destroyed").

## Public API Reference

### Package `raylib_arcade_factory_defense_2026`

> Single-file game with all logic, rendering, and the main loop in `main.mbt`.

Since this is a single-file game, all structs and functions are package-private. The only public entry point is the `main` function.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width |
| `sh` | `Int` | `760` | Screen height |
| `arena_l` | `Float` | `36.0` | Arena left boundary |
| `arena_r` | `Float` | `1244.0` | Arena right boundary (sw - 36) |
| `arena_t` | `Float` | `92.0` | Arena top boundary |
| `arena_b` | `Float` | `720.0` | Arena bottom boundary (sh - 40) |
| `core_x` | `Float` | `640.0` | Core X position (center) |
| `core_y` | `Float` | `400.0` | Core Y position (center + 20) |
| `core_r` | `Float` | `44.0` | Core collision radius |
| `max_enemies` | `Int` | `260` | Enemy pool size |
| `max_bullets` | `Int` | `1200` | Bullet pool size |
| `max_turrets` | `Int` | `120` | Turret pool size |
| `max_scraps` | `Int` | `320` | Scrap pool size |
| `max_particles` | `Int` | `1800` | Particle pool size |
| `max_waves` | `Int` | `10` | Total wave count to survive for victory |

#### Structs (package-private)

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Player` | `x`, `y`, `vx`, `vy`, `aim_x`, `aim_y`, `hp`, `energy`, `heat`, `inv_t`, `fire_cd`, `dash_cd`, `dash_t`, `bomb_cd`, `scrap`, `score`, `combo`, `best_combo` | Player state: position, velocity, aim direction, health/energy/heat resources, ability cooldowns, economy, and scoring |
| `Enemy` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `hp`, `fire_cd`, `t` | An enemy with kind (0=drone, 1=gunner, 2=heavy), movement, health, and fire cooldown |
| `Bullet` | `active`, `team`, `kind`, `x`, `y`, `vx`, `vy`, `dmg`, `r`, `life` | A projectile with team (1=friendly, 2=enemy), damage, radius, and lifetime |
| `Turret` | `active`, `kind`, `x`, `y`, `hp`, `fire_cd`, `t` | A placed turret (kind 0=auto, 1=cannon) with health and fire cooldown |
| `Scrap` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `value`, `life`, `t` | A collectible resource drop with value, physics, and lifetime |
| `Particle` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `size`, `life`, `t` | A visual particle (4 color kinds: cyan, yellow, red, purple) |

#### Functions (package-private)

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to [lo, hi] |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two points |
| `randf` | `(Float, Float) -> Float` | Random float in [lo, hi] |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Point-in-rectangle test for UI hit detection |
| `enemy_radius` | `(Int) -> Float` | Returns collision radius by enemy kind (15, 20, 28) |
| `enemy_hp` | `(Int, Int) -> Float` | Returns base HP for an enemy kind scaled by wave |
| `turret_cost` | `(Int) -> Int` | Returns scrap cost for turret kind (12 or 26) |
| `turret_range` | `(Int) -> Float` | Returns targeting range for turret kind (220 or 300) |
| `clear_enemies` | `(Array[Enemy]) -> Unit` | Deactivates all enemies in the pool |
| `clear_bullets` | `(Array[Bullet]) -> Unit` | Deactivates all bullets in the pool |
| `clear_turrets` | `(Array[Turret]) -> Unit` | Deactivates all turrets in the pool |
| `clear_scraps` | `(Array[Scrap]) -> Unit` | Deactivates all scraps in the pool |
| `clear_particles` | `(Array[Particle]) -> Unit` | Deactivates all particles in the pool |
| `add_enemy` | `(Array[Enemy], Int, Float, Float, Int) -> Bool` | Spawns an enemy of given kind at position with wave-scaled HP |
| `add_bullet` | `(Array[Bullet], Int, Int, Float, Float, Float, Float, Float, Float, Float) -> Bool` | Spawns a bullet with team, kind, position, velocity, damage, radius, and lifetime |
| `add_turret` | `(Array[Turret], Int, Float, Float) -> Bool` | Places a turret of given kind at position with HP and initial fire cooldown |
| `add_scrap` | `(Array[Scrap], Int, Float, Float, Float, Float, Int, Float) -> Bool` | Spawns a scrap pickup with kind, position, velocity, value, and lifetime |
| `add_particle` | `(Array[Particle], Int, Float, Float, Float, Float, Float, Float) -> Bool` | Spawns a visual particle with kind, position, velocity, size, and lifetime |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Creates a radial burst of particles at a position |
| `count_active_enemies` | `(Array[Enemy]) -> Int` | Returns the number of active enemies |
| `can_place_turret` | `(Array[Turret], Float, Float) -> Bool` | Validates turret placement (arena bounds, core clearance, turret spacing) |
| `draw_touch_ui` | `(Int) -> Unit` | Draws mobile touch controls (D-pad and action buttons) when in play state |
| `main` | `() -> Unit` | Entry point: 1280x760 window at 60 FPS, allocates pools, runs game loop with state machine (0=menu, 1=play, 2=win, 3=lose) |

## Architecture

### Package Structure

```
raylib_arcade_factory_defense_2026/
├── main.mbt    — All structs, logic, rendering, and game loop (~2308 lines)
└── moon.pkg    — Package config with raylib and math imports
```

This is a single-file game. Constants and struct definitions are at the top, followed by utility functions, entity management functions (clear/add/spawn), rendering helpers, and the `main` function containing all game state as local variables, closures for reset and damage handling, the game loop, all update logic, and all rendering code.

### Data Flow

1. **Initialization**: `main` allocates fixed-size arrays for all entity pools (260 enemies, 1200 bullets, 120 turrets, 320 scraps, 1800 particles). The `reset_run` closure initializes player stats, clears all pools, and places two starter Auto Turrets flanking the core.

2. **Wave system**: Between waves, a `wave_pre_t` timer counts down (3.8s). When it reaches zero, the wave activates with `to_spawn = 8 + wave * 3` enemies. During a wave, enemies spawn from random arena edges at decreasing intervals. When all enemies for the wave are spawned and all active enemies are defeated, the wave ends, `wave` increments, and the player receives bonus scrap.

3. **Input**: Movement inputs (WASD/arrows/touch D-pad) produce a normalized direction vector. Mouse position within the arena overrides the aim direction when not in build mode. Fire, dash, build, and bomb actions are triggered by keyboard keys or touch buttons. Build mode intercepts the fire button for turret placement.

4. **Physics**: Player velocity uses acceleration/drag model with speed capping. Dash temporarily increases acceleration (1600 vs 980), reduces drag (2.0 vs 5.2), and raises max speed (460 vs 300). Enemies use steering behaviors: drones accelerate toward the target, gunners orbit at 220px distance, heavies lumber toward the target. All entities are clamped to arena bounds.

5. **Combat resolution**: Friendly bullets (team 1) check against all enemies for circle-circle collision. Enemy bullets (team 2) check against player, core, and turrets. Enemy-player contact deals direct damage. Enemy-core contact deals continuous damage. Enemy-turret ramming damages both.

6. **Economy**: Killed enemies drop 1-3 scrap items. Scrap drifts with friction and has a 12-22 second lifetime. Player collects scrap by proximity (28px). Scrap funds turret construction. Energy regenerates at 10/s and fuels dash (20 cost) and bomb (36 cost).

7. **Rendering**: Background grid with animated star field, arena bounds, core with glow, turrets, scrap drops, enemies by kind, bullets by team, player with aim line, dash ring, build preview with range circle, particles, HUD bars (core HP, player HP, energy, heat), and state overlays.

### Key Design Patterns

- **Single-file monolith**: All game code in one file with local variables as game state and closures (`reset_run`, `on_player_hit`) for reusable operations.
- **Object pool pattern**: Fixed-size arrays with `active` flags for all entity types. `add_*` functions scan linearly for the first inactive slot. `clear_*` functions deactivate all entries.
- **Integer state machine**: `state` is an `Int` (0=menu, 1=play, 2=win, 3=lose) controlling the main loop branch.
- **Squared distance checks**: All proximity tests use `dist2` to avoid square root calculations in hot paths.
- **Economy loop**: Kill enemies -> collect scrap -> build turrets -> turrets help kill enemies, creating a positive feedback loop balanced by turret vulnerability to enemy fire and ramming.
- **Scaling difficulty**: Enemy HP, spawn rate, turret fire rate, and player fire rate all scale with wave number, creating organic difficulty progression.
- **Combo scoring**: Consecutive kills without taking damage multiply the score reward per kill, encouraging aggressive play and dodge mastery.

## Improvement & Refinement Plan

1. **Replace integer state machine and entity kinds with enums**: `state` uses magic integers (0-3), and `enemy.kind`, `bullet.team`, `turret.kind` are all integers. Converting to proper MoonBit enums would improve type safety and code readability.

2. **Extract entity logic into separate functions**: The main game loop body spans over 800 lines of inline update and render code. Breaking enemy update, bullet resolution, wave management, and rendering into dedicated functions would improve maintainability.

3. **Add turret upgrade system**: Currently turrets are static once placed. Adding an upgrade mechanic (e.g., spend scrap to increase turret range, fire rate, or HP) would deepen the economic decision-making.

4. **Implement turret sell/recycle**: There is no way to remove or relocate placed turrets. Adding a sell-back mechanic (returning partial scrap) would let players adapt their defenses as the game progresses.

5. **Add enemy pathfinding around turrets**: Enemies move in straight lines toward targets and only interact with turrets via collision. Adding simple obstacle avoidance or flanking behavior would make turret placement more strategically meaningful.

6. **Visual turret range indicator**: The range circle only appears during build mode preview. Showing range circles for existing turrets on hover or toggle would help players understand their defensive coverage.

7. **Add sound effects**: The game is completely silent. Adding firing sounds, explosion effects, scrap collection chimes, wave start/clear fanfares, and ambient factory hum would significantly improve the experience.

8. **Implement persistent upgrade progression**: Each run starts fresh with identical parameters. Adding meta-progression (e.g., unlocking turret types, starting bonuses from previous high scores) would incentivize repeated play.
