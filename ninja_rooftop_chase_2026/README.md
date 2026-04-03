# Ninja Rooftop Chase 2026

A side-scrolling action runner where a ninja sprints across neon-lit rooftops, switching between three lanes to dodge obstacles, slashing enemies with a katana, throwing shurikens at distant threats, and dashing through danger zones. The goal is to cover 5,600 meters of distance before a 228-second timer expires, while managing HP (220) and energy (100) resources.

The game features four obstacle types: crates (jump over, 14 damage), signs (slide under, 12 damage), guards (melee enemies with HP that shoot projectiles, 18 damage on contact), and drones (flying enemies that hover at varying heights, 16 damage). Guards and drones can be destroyed by slashing (J key, melee range) or throwing shurikens (K key, ranged projectile), earning score with combo multipliers. Every 500 meters of distance covered awards a 160-point milestone bonus.

The player has three combat abilities -- slash (0.14s active, 0.30s cooldown, 6 energy), throw (0.28s cooldown, 10 energy, fires a shuriken at 720 speed), and dash (0.30s invulnerability, 1.4s cooldown, 20 energy) -- plus movement abilities of jumping (520 upward velocity, 8 energy) and sliding (hold to crouch). Performing slashes while airborne builds a trick timer that converts to bonus points on landing. Energy regenerates at 14/s, and difficulty scales through a level system based on distance traveled, increasing run speed, enemy HP, and projectile damage.

## Build and Run

```bash
moon build --target native ninja_rooftop_chase_2026/
./_build/native/debug/build/ninja_rooftop_chase_2026/ninja_rooftop_chase_2026.exe
```

## Controls

- **A/D or Left/Right**: Switch lanes (up/down in the 3-lane layout)
- **W / Up / Space**: Jump (costs 8 energy)
- **S / Down**: Slide (hold to crouch under overhead obstacles)
- **J**: Slash attack (melee, 0.14s active, 0.30s cooldown, 6 energy)
- **K**: Throw shuriken (ranged projectile, 0.28s cooldown, 10 energy)
- **L**: Dash (0.30s burst + invulnerability-like speed, 1.4s cooldown, 20 energy)
- **R**: Restart run
- **Enter**: Start from title / Return to title from results
- **F11**: Toggle fullscreen
- **Touch**: Left D-pad for UP/DN/JMP/SLD, right buttons for SLASH/THROW/DASH

## How to Play

1. **Start**: Press Enter or tap on the title screen to begin the chase.
2. **Lane switching**: Use A/D or Left/Right to move between three horizontal lanes (top at y=248, middle at y=392, bottom at y=534). All movement and combat occurs within these lanes.
3. **Jump over crates**: Kind 0 obstacles are ground-level crates (36x40 pixels). Jump over them -- they hit if you are below 36 pixels altitude and within 30 pixels horizontally. Contact deals 14 HP damage.
4. **Slide under signs**: Kind 1 obstacles are overhead signs. Hold S/Down to slide (0.15s duration, reduces hitbox). Standing upright within 30 pixels at low altitude deals 12 HP damage.
5. **Fight guards**: Kind 2 obstacles are enemies with HP (44 + level*4) that shoot projectiles when within range. Slash them in melee range (74 pixels) to deal 36 + level*2 damage per hit, or throw shurikens for ranged kills. Touching them deals 18 damage. Kills award 92 + combo*6 + 10 bonus points.
6. **Destroy drones**: Kind 3 obstacles are flying enemies with HP (34 + level*3) that oscillate in height. Slash them when at matching altitude or throw shurikens. Kills award 92 + combo*6 + 18 bonus points. Contact deals 16 damage.
7. **Air tricks**: While airborne, pressing J (slash) builds the trick timer by 0.32 (max 1.8). Landing with trick_t > 0.2 converts to bonus points: trick_t * 520 + combo * 4 points, plus increments the combo.
8. **Collect pickups**: Three pickup types appear on the lanes -- coins (gold, +34 + combo*2 score), medpacks (pink, +24 HP), and energy cells (blue, +24 energy).
9. **Build combos**: Kills, trick landings, and coin pickups all increment the combo counter. Taking damage resets it to zero.
10. **Manage energy**: Energy (100 max, regenerates at 14/s) fuels all abilities. Balance offense and defense to avoid running dry.
11. **Reach the goal**: Cover 5,600 meters before the 228-second timer expires. Distance accumulates at run_speed * 0.11 per second. Run speed starts at 248 and increases by 11 per level (distance / 720). Dashing adds 180 to run speed temporarily.
12. **Win/Lose**: Reaching 5,600m wins with "CHASE ESCAPED". Running out of HP or time loses with "CHASE FAILED".

## Public API Reference

### Package `ninja_rooftop_chase_2026`

> Main entry point and complete game implementation in a single file.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width |
| `sh` | `Int` | `760` | Screen height |
| `world_w` | `Float` | `1280.0` | World width in pixels |
| `player_x` | `Float` | `220.0` | Fixed horizontal position of the player |
| `lane_count` | `Int` | `3` | Number of horizontal lanes |
| `max_obstacles` | `Int` | `260` | Maximum obstacle pool size |
| `max_shots` | `Int` | `420` | Maximum projectile pool size |
| `max_pickups` | `Int` | `140` | Maximum pickup pool size |
| `max_particles` | `Int` | `920` | Maximum particle pool size |
| `target_distance` | `Float` | `5600.0` | Distance in meters required to win |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Player` | `lane`, `z`, `vz`, `slide_t`, `dash_t`, `dash_cd`, `hp`, `energy`, `slash_t`, `slash_cd`, `throw_cd`, `flash_t`, `trick_t`, `score`, `combo`, `coins`, `distance` | Player ninja with lane position, vertical position/velocity, ability timers, resources, and scoring |
| `Obstacle` | `active`, `kind`, `x`, `lane`, `hp`, `atk_cd`, `pulse_t` | Obstacle/enemy with 4 kinds (crate/sign/guard/drone), health, attack cooldown, and animation timer |
| `Shot` | `active`, `from_player`, `x`, `lane`, `z`, `vx`, `dmg`, `life` | Projectile (shuriken or enemy shot) with origin, position, velocity, damage, and lifetime |
| `Pickup` | `active`, `kind`, `x`, `lane`, `t` | Collectible item with 3 kinds (coin/medpack/energy), position, and animation timer |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `size`, `t`, `life`, `kind` | Visual particle with 4 color kinds (cyan/green/orange/red) |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `absf` | `(Float) -> Float` | Returns absolute value of a float |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Point-in-rectangle test for touch UI |
| `randf` | `(Float, Float) -> Float` | Random float in range [lo, hi] |
| `lane_y` | `(Int) -> Float` | Returns the Y coordinate for a lane (0=248, 1=392, 2=534) |
| `obstacle_z` | `(Obstacle) -> Float` | Returns the vertical offset of an obstacle (drones oscillate 44-54, others 0) |
| `clear_obstacles` | `(Array[Obstacle]) -> Unit` | Resets all obstacles to inactive |
| `clear_shots` | `(Array[Shot]) -> Unit` | Resets all shots to inactive |
| `clear_pickups` | `(Array[Pickup]) -> Unit` | Resets all pickups to inactive |
| `clear_particles` | `(Array[Particle]) -> Unit` | Resets all particles to inactive |
| `spawn_particle` | `(Array[Particle], Float, Float, Float, Int) -> Unit` | Spawns a single particle with random velocity |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Spawns multiple particles in a burst pattern |
| `spawn_shot` | `(Array[Shot], Bool, Float, Int, Float, Float, Float, Float) -> Bool` | Spawns a projectile with origin, lane, altitude, velocity, damage, and lifetime |
| `spawn_obstacle` | `(Array[Obstacle], Int) -> Bool` | Spawns a random obstacle at the right edge with level-scaled HP |
| `spawn_pickup` | `(Array[Pickup]) -> Bool` | Spawns a random pickup at the right edge |
| `nearest_obstacle_dy` | `(Array[Obstacle], Float) -> Int` | Returns the horizontal pixel distance to the nearest obstacle ahead of the player |
| `main` | `() -> Unit` | Entry point: initializes window, allocates pools, runs game loop with input/update/render |

## Architecture

### Package Structure

```
ninja_rooftop_chase_2026/
├── main.mbt    — Complete game: types, constants, utilities, spawning, game loop, rendering
└── moon.pkg    — Package config with raylib and math imports
```

Single-file game with all logic in `main.mbt` (1581 lines). Organized top-to-bottom: constants, struct definitions, utility functions, pool clear functions, spawning functions, main function with nested closures (`reset_run`, `on_hit`, `on_kill`), game loop with input/update/render.

### Data Flow

1. **Input**: Each frame reads keyboard state for lane switching (A/D), jump (W/Space), slide (S held), slash (J), throw (K), dash (L), and fullscreen (F11). Touch inputs map on-screen D-pad buttons (UP/DN/JMP/SLD on the left) and action buttons (SLASH/THROW/DASH on the right) via `inside_rect` checks. Touch uses `is_mouse_button_down` for slide (continuous) and `is_mouse_button_pressed` for discrete actions.

2. **Update**: In state 1 (playing): timer counts down, cooldowns tick, lane switching applies, jump physics (gravity at 1400, landing detection with trick bonus), slide activation, dash activation (adds 180 to run speed), slash activation (melee hitbox, air trick accumulation), shuriken spawning, energy regeneration (14/s, capped at 100), level calculation (distance / 720), run speed computation (248 + level*11, +180 during dash, -24 at low HP, min 150), distance accumulation, milestone checks (every 500m), obstacle spawning on cooldown (accelerates with level), pickup spawning (2-4.4s interval), obstacle movement and collision (kind-specific hit logic), shot movement and collision (player shurikens vs enemies, enemy shots vs player), pickup collection (coins/medpacks/energy), particle physics (gravity, drag, lifetime), win/lose checks.

3. **Rendering**: Background city buildings with parallax scrolling, three lane tracks with scrolling tile markers, pickups (blinking colored circles), obstacles by kind (crates as brown rectangles, signs as pink bars, guards as dark red rectangles, drones as blue circles with eyes), shots (colored circles), particles with fade, player ninja (colored rectangle body with slash and dash ring effects), HUD bar (title, score, combo, distance, time, HP bar, energy bar, kills, coins, missed, level, nearest threat), touch controls, message bar, state overlays (title/win/lose panels).

### Key Design Patterns

- **Object pool pattern**: Pre-allocated arrays with `active` flags for obstacles (260), shots (420), pickups (140), and particles (920). Linear scan for first free slot on spawn.
- **Closure-based event handlers**: `on_hit` and `on_kill` closures capture the player, particles, and local variables, providing clean callback-style event handling without method dispatch.
- **Level-scaled difficulty**: Level increases by 1 for every 720 meters of distance, scaling run speed (+11/level), enemy HP (+3-4/level), slash damage (+1.6-2/level), and enemy projectile speed (+16/level) and damage (+1.6/level).
- **Air trick system**: Performing slashes while airborne accumulates a trick timer (0.32 per slash, max 1.8) that converts to bonus score on landing, rewarding aggressive aerial play.
- **Fixed player X position**: The player stays at x=220 while the world scrolls left, simplifying collision detection to 1D horizontal distance checks.
- **Energy economy**: All abilities consume energy (6-20 per use) that regenerates at 14/s, creating a resource management layer that prevents ability spam.

## Improvement & Refinement Plan

1. **Replace obstacle kind integers with an enum**: Obstacle kinds 0-3 are used as magic numbers throughout spawning, collision, and rendering. An `ObstacleKind` enum with `Crate`, `Sign`, `Guard`, `Drone` variants would clarify the code significantly.

2. **Replace game state integers with an enum**: States 0 (title), 1 (playing), 2 (win), 3 (lose) should use a `GameState` enum for readability and pattern matching.

3. **Extract the game loop into separate functions**: The `main` function spans over 1200 lines with input, update, and render interleaved. Extracting `update_game` and `draw_frame` functions would improve maintainability.

4. **Add invulnerability frames after taking damage**: The player has a visual flash on hit (0.18s) but no invulnerability period, allowing rapid consecutive hits. Adding brief invulnerability after damage would prevent unfair multi-hit scenarios.

5. **Add sound effects**: The game has no audio. Slash swooshes, shuriken throws, impact sounds, coin pickups, milestone chimes, and background music would significantly enhance the experience.

6. **Add combo timeout**: The combo counter never decays on its own -- it only resets on taking damage. Adding a time-based decay (e.g., 3 seconds without incrementing) would make combos more skill-based.

7. **Add obstacle variety**: All obstacles spawn from the right edge at similar speeds. Adding obstacles that move between lanes, telegraph attacks with warnings, or require specific counter-strategies would increase gameplay depth.

8. **Implement a high score system**: Scores are lost on restart. Persisting the best score, best distance, and best kill count would give players progression between runs.
