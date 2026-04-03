# Temple Relic Run 2026

A grid-based dungeon crawler set inside a procedurally generated ancient temple. You play as an explorer navigating tile-based floors filled with stone walls, mummy-like enemies, spike traps, pressure plates, and precious relics. The game combines puzzle-solving (pushing crates onto pressure plates) with action combat across five increasingly difficult stages, all under a global time limit.

The core gameplay loop for each stage involves three objectives: collect all relics scattered across the floor, push crates onto every pressure plate to unlock the exit gate, and survive enemy attacks and spike traps. Combat offers three abilities -- a directional slash that hits enemies in a T-shaped pattern, a dash that moves two tiles and damages enemies in the path, and a bomb (relic charge) that deals massive area damage in a 5x5 area and destroys interior stone walls. Each ability has its own cooldown and stamina cost.

The procedural level generation places stone blocks, enemies, relics, plates, crates, and spikes with increasing density per stage. Enemy count scales from 4 to 28, spike traps from 3 to 18, and relics from 4 to 14. A global 420-second timer and per-stage countdown create mounting pressure, with periodic damage when stage time expires.

## Build and Run

```bash
moon build --target native temple_relic_run_2026/
./_build/native/debug/build/temple_relic_run_2026/temple_relic_run_2026.exe
```

## Controls

- **W / Up Arrow**: Move up one tile
- **A / Left Arrow**: Move left one tile
- **S / Down Arrow**: Move down one tile
- **D / Right Arrow**: Move right one tile
- **J**: Slash attack (hits 2 tiles forward + 1 tile on each side, 0.32s cooldown)
- **K**: Dash (moves 2 tiles in facing direction, damages enemies, costs 24 stamina, 1.35s cooldown)
- **L**: Relic Charge / Bomb (5x5 area damage, destroys inner walls, costs 40 stamina, 5.4s cooldown)
- **R**: Restart run
- **Enter**: Start game / return to menu
- **F11**: Toggle fullscreen
- **Touch/Mouse**: On-screen D-pad (left side) and SLASH / DASH / CHARGE buttons (right side)

## How to Play

Press Enter or tap to start from the title screen. Each stage generates a 20x12 tile map with border walls, random interior stone blocks, and various entities:

**Objectives per stage:**
1. **Collect all relics** -- Walk over diamond-shaped relic pickups. Each awards 90 + stage * 12 points and increments your combo.
2. **Activate all pressure plates** -- Push crates onto circular plate markers. A plate is activated when a crate or the player stands on it. The required plate count is 2 + stage (capped at 6).
3. **Reach the exit gate** -- Located at the top-right corner (map_w-2, 1). The gate turns green and opens only when all relics are collected AND all plates are pressed.

**Combat:**
- **Slash (J)**: Melee attack dealing 15 + stage damage to enemies 1-2 tiles ahead, and 12 damage to enemies on adjacent flanking tiles. Enemies are stunned for 0.4s. Missing resets your combo.
- **Dash (K)**: Dash 2 tiles in your facing direction. Enemies in the path take 18 damage and are stunned for 0.6s. Costs 24 stamina.
- **Bomb (L)**: Area attack hitting all enemies within Manhattan distance 2 for 42 damage with 0.8s stun. Also destroys interior stone walls in a 3x3 area. Costs 40 stamina.

**Enemies** come in three kinds (0, 1, 2) with increasing HP (18 + kind * 12 + stage * 2) and faster attack intervals. They chase the player using simple pathfinding (move toward player on the dominant axis, with orthogonal fallback). Adjacent enemies attack for 10 + kind * 3 damage. Enemies standing on active spike traps take damage too.

**Spike traps** cycle on a timer -- they alternate between extended (dangerous) and retracted states. Walking onto an active spike deals 7 damage.

**Resources:** Stamina regenerates at 18/second (max 100). HP does not regenerate except for +18 on stage clear. Player takes 8 damage periodically when stage time runs out. The game ends when HP reaches 0 or the global 420-second timer expires.

Clearing all 5 stages shows "TEMPLE MASTERED" with your final score.

## Public API Reference

### Package `temple_relic_run_2026`

> Single-file game with all types, logic, and rendering in main.mbt.

This game uses package-private types and local closures for game logic. All structs and functions are package-private (no `pub` keyword), so there is no exported public API. The key internal types and functions are documented below for reference.

#### Structs (package-private)

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Player` | `gx`, `gy`, `hp`, `stamina`, `slash_cd`, `dash_cd`, `bomb_cd`, `hurt_t`, `face_x`, `face_y`, `score`, `combo` | Player state with grid position, health, stamina, ability cooldowns, and scoring |
| `Crate` | `active`, `gx`, `gy` | Pushable crate on the grid |
| `Plate` | `active`, `gx`, `gy`, `pressed` | Pressure plate that activates when stood on or covered by a crate |
| `Relic` | `active`, `gx`, `gy`, `taken` | Collectible relic pickup |
| `Enemy` | `active`, `kind`, `gx`, `gy`, `hp`, `move_cd`, `atk_cd`, `stun_t`, `hurt_cd` | Grid-based enemy with movement AI and attack cooldowns |
| `Spike` | `active`, `gx`, `gy`, `t` | Timed spike trap that cycles between up and down states |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `size`, `t`, `life`, `kind` | Visual particle for combat and pickup effects |

#### Key Functions (package-private)

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between bounds |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between bounds |
| `absi` | `(Int) -> Int` | Absolute value of an integer |
| `randf` | `(Float, Float) -> Float` | Random float in range |
| `idx` | `(Int, Int) -> Int` | Converts grid (x,y) to flat array index |
| `in_bounds` | `(Int, Int) -> Bool` | Checks if grid coordinates are within map bounds |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Point-in-rectangle test for touch input |
| `cell_center_x` | `(Int) -> Float` | Pixel x-center of a grid cell |
| `cell_center_y` | `(Int) -> Float` | Pixel y-center of a grid cell |
| `crate_at` | `(Array[Crate], Int, Int) -> Int` | Finds crate index at grid position, -1 if none |
| `enemy_at` | `(Array[Enemy], Int, Int) -> Int` | Finds enemy index at grid position, -1 if none |
| `relic_at` | `(Array[Relic], Int, Int) -> Int` | Finds uncollected relic at grid position, -1 if none |
| `spike_at` | `(Array[Spike], Int, Int) -> Int` | Finds spike trap at grid position, -1 if none |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Emits a burst of particles at a position |
| `clear_crates` | `(Array[Crate]) -> Unit` | Deactivates all crates |
| `clear_plates` | `(Array[Plate]) -> Unit` | Deactivates all plates |
| `clear_relics` | `(Array[Relic]) -> Unit` | Deactivates all relics |
| `clear_enemies` | `(Array[Enemy]) -> Unit` | Deactivates all enemies |
| `clear_spikes` | `(Array[Spike]) -> Unit` | Deactivates all spikes |
| `clear_particles` | `(Array[Particle]) -> Unit` | Deactivates all particles |

#### Key Closures (inside main)

| Closure | Description |
|---------|-------------|
| `can_walk` | Checks if a tile is walkable (in bounds and not a wall) |
| `cell_free_for_spawn` | Checks if a cell is available for entity placement during generation |
| `setup_stage` | Procedurally generates a stage: walls, crates, plates, relics, enemies, spikes |
| `reset_run` | Resets player stats and starts stage 1 |
| `spike_is_up` | Determines if a spike trap is currently in its dangerous extended state |
| `update_plate_state` | Recalculates which plates are pressed and whether the exit gate should open |
| `damage_player` | Applies damage to the player with hurt invincibility and combo reset |
| `kill_enemy` | Removes an enemy, awards score with combo bonus, emits particles |
| `attempt_move` | Handles player grid movement including crate pushing |

#### Constants (package-private)

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | 1280 | Screen width |
| `sh` | `Int` | 760 | Screen height |
| `map_w` | `Int` | 20 | Map width in tiles |
| `map_h` | `Int` | 12 | Map height in tiles |
| `tile` | `Int` | 52 | Tile size in pixels |
| `map_x` | `Int` | 120 | Map x offset in pixels |
| `map_y` | `Int` | 72 | Map y offset in pixels |
| `max_crates` | `Int` | 20 | Crate pool size |
| `max_plates` | `Int` | 10 | Plate pool size |
| `max_relics` | `Int` | 18 | Relic pool size |
| `max_enemies` | `Int` | 42 | Enemy pool size |
| `max_spikes` | `Int` | 30 | Spike pool size |
| `max_particles` | `Int` | 900 | Particle pool size |

## Architecture

### Package Structure

```
temple_relic_run_2026/
├── main.mbt    — Single-file game: all types, procedural generation, game logic, input, and rendering
└── moon.pkg    — Package config with raylib and math imports
```

This is a single-file game where all code lives in `main.mbt`. The `main` function contains the entire game lifecycle, using local closures for reusable logic like `setup_stage`, `attempt_move`, `damage_player`, and `kill_enemy`. Entity pools are allocated as local arrays.

### Data Flow

1. `main` allocates all entity pools (tiles, crates, plates, relics, enemies, spikes, particles) and the player struct.
2. `reset_run()` initializes the run state and calls `setup_stage(1)` which procedurally generates the first floor.
3. Each frame reads keyboard and touch input, applies movement via `attempt_move()` (with move-repeat timing for held keys), and processes ability presses (slash, dash, bomb).
4. Enemy AI runs per-frame: enemies chase the player on a movement cooldown, attack when adjacent, and take spike damage.
5. `update_plate_state()` checks all plates and determines if the exit gate should open.
6. Win/loss checks: reaching the open exit advances to the next stage (or wins on stage 5), while HP <= 0 or total_time <= 0 triggers game over.
7. Rendering draws the tile grid, entities, particles, HUD bars, status text, touch controls, and any overlay (title/win/lose).

### Key Design Patterns

- **Single-File Architecture with Closures**: All game logic resides in `main.mbt`, using closures (`setup_stage`, `attempt_move`, `damage_player`, etc.) that capture local variables for state management, avoiding the need for a global Game struct.
- **Grid-Based Movement**: All entities move on a discrete tile grid (20x12). Movement is axis-aligned with move-repeat timing for held keys (0.11s keyboard, 0.14s touch).
- **Object Pool Pattern**: Fixed-size arrays with `active` flags for crates, plates, relics, enemies, spikes, and particles. Entity lookup functions (`crate_at`, `enemy_at`, etc.) scan pools linearly.
- **Procedural Generation**: Each stage generates interior walls, then places entities with proximity constraints (`cell_free_for_spawn` ensures minimum distance from player and non-overlapping placement).
- **Sokoban-Style Crate Pushing**: Crates are pushed when the player moves into them, provided the cell behind the crate is walkable and unoccupied.
- **Cycling Spike Traps**: Spikes use a simple phase calculation `(t * 2.0).to_int() % 4 <= 1` to alternate between dangerous and safe states.
- **Combo System**: Consecutive kills and relic pickups increment a combo counter that adds bonus score (combo * 4 per kill). Missing a slash resets the combo.

## Improvement & Refinement Plan

1. **Extract structs and logic into internal packages**: The 1867-line `main.mbt` file handles everything from type definitions to procedural generation to rendering. Splitting into `internal/types`, `internal/game`, and `internal/render` would improve maintainability and enable the `pub` API pattern used by other games in this collection.

2. **Replace integer state constants with an enum**: The game state is tracked as an integer (0=title, 1=play, 2=win, 3=lose). A proper `GameState` enum would make the if-else dispatch in the main loop more readable and compiler-checked.

3. **Improve enemy pathfinding**: The current enemy AI moves toward the player on the dominant axis with a single orthogonal fallback. This causes enemies to get stuck on walls frequently. A simple BFS or A* to the player's position (feasible on a 20x12 grid) would produce more challenging enemy movement.

4. **Add level connectivity validation**: The procedural generation places stone blocks randomly without ensuring the player can reach the exit, all relics, and all plates. Adding a flood-fill reachability check after generation would prevent unwinnable layouts.

5. **Implement visual feedback for ability cooldowns**: The HUD shows cooldown values as integers in a text line ("Slash 0 Dash 0 Bomb 0"), which is hard to read during fast gameplay. Cooldown bars or radial indicators near the touch buttons would provide clearer feedback.

6. **Add damage numbers or hit flash to enemies**: When enemies take damage, only a particle burst indicates the hit. Adding floating damage numbers or a brief color flash on the enemy sprite would make combat feel more responsive.

7. **Decouple tile map from flat array**: The `tiles` array uses `idx(gx, gy)` to index into a flat `Array[Int]`. Wrapping this in a `TileMap` struct with bounds-checked access methods would reduce the risk of out-of-bounds errors and centralize map queries.

8. **Balance stage time pressure**: The stage timer penalizes players with 8 damage on expiry but then only resets to 8 seconds, creating a rapid damage loop. A more gradual penalty (increasing damage or spawning additional enemies) would feel fairer while maintaining urgency.
