# Chrono Rail Shooter 2026

A vertically scrolling rail shooter where the player pilots a ship along a constrained track, defending a chrono train against timeline rogue squads. The ship moves within rail boundaries while the track scrolls forward automatically, creating a constant forward momentum with enemies, hazard panels, and pickups flowing toward the player.

The gameplay combines fast-paced bullet-hell shooting with resource management across four ability systems: rapid-fire main gun (with heat buildup), homing rockets (energy cost with cooldown), invulnerability dash (energy cost with cooldown), and EMP pulse (high energy cost, long cooldown, area damage and bullet clearing). A shield system provides passive damage reduction while draining energy. The distance-based progression system introduces three enemy types of escalating difficulty and spawns a boss encounter ("Chrono Warden" with 1400 HP) at 68% of the 9000-unit distance goal.

The game features a rich visual rail environment with scrolling floor panels (some hazardous, some boosting), parallax background, and extensive particle effects. Combo scoring rewards sustained aggression, and pickups (repair kits, energy cells, chrono shards) drop from destroyed enemies. Touch controls with a virtual D-pad and skill buttons provide mobile accessibility.

## Build and Run

```bash
moon build --target native raylib_chrono_rail_shooter_2026/
./_build/native/debug/build/raylib_chrono_rail_shooter_2026/raylib_chrono_rail_shooter_2026.exe
```

## Controls

- **W / Up Arrow**: Move ship up
- **S / Down Arrow**: Move ship down
- **A / Left Arrow**: Move ship left
- **D / Right Arrow**: Move ship right
- **J / Space**: Fire main gun (hold for continuous fire; overheats above 92%)
- **K**: Dash (brief invulnerability burst, 22 energy, 1.0s cooldown)
- **E**: Launch rocket (36 damage, 26 energy, 1.35s cooldown)
- **L**: EMP pulse (area damage to enemies, clears nearby bullets, 50 energy, 5.6s cooldown)
- **Right Shift**: Hold shield (reduces damage by 56%, drains 19 energy/s)
- **F11**: Toggle fullscreen
- **Enter**: Start game / Restart after game over
- **R**: Restart after game over or victory
- **Touch**: Left panel D-pad for movement, right panel buttons for FIRE, DASH, ROCKET, EMP

## How to Play

Press Enter or tap to start. Your ship spawns centered in the rail zone (X: 220-1060) and scrolls forward automatically. The distance counter tracks progress toward the 9000-unit goal.

**Combat**: Hold J/Space to fire. Your main gun has a heat gauge that rises 8 units per shot and cools at 42/s. Firing is blocked above 92% heat. At level 4+, you gain two additional side cannons. Destroy enemies for score (52 + kind_bonus + combo * 3 points). Each consecutive kill increases the combo counter.

**Abilities**:
- **Dash (K)**: Costs 22 energy, 1.0s cooldown. Grants 0.22s invulnerability and a speed boost in the movement direction (520 velocity impulse).
- **Rocket (E)**: Costs 26 energy, 1.35s cooldown. Fires a high-damage projectile (36 damage, 8-unit radius).
- **EMP (L)**: Costs 50 energy, 5.6s cooldown. Deals 42 damage to enemies within 290 units, clears enemy bullets within 280 units, and deals 54 damage to the boss within 340 units.
- **Shield (Right Shift)**: Held active, reduces incoming damage by 56%, drains 19 energy per second.

**Enemy Types**:
- **Type 0** (red circles): Small, sine-wave movement, single shots. Available from level 1.
- **Type 1** (orange rectangles): Medium, faster sine-wave, faster shooting. Available from level 3.
- **Type 2** (purple rectangles): Large, slow sine-wave, fires spread shots (3 bullets). Available from level 6.

**Environment**: Floor panels scroll toward you. Red hazard panels deal 12 damage on contact. Blue boost panels give a speed boost and 16 energy.

**Pickups** (drop from enemies, also spawn periodically):
- **Repair Kit** (green): Restores 16 HP
- **Energy Cell** (blue): Restores 26 energy
- **Chrono Shard** (gold): Grants 160 + combo * 4 score

**Boss**: "Chrono Warden" appears at 68% distance (6120 units). It has 1400 HP, fires 5-bullet spreads, and periodically spawns enemy reinforcements. Defeating it awards 1200 points.

**Win**: Reach 9000 distance with the boss defeated. **Lose**: HP reaches 0.

**Leveling**: Level = distance / 900 + 1. Higher levels increase enemy HP, bullet speed, spawn rate, and unlock stronger enemy types.

## Public API Reference

### Package `raylib_chrono_rail_shooter_2026`

> Main entry point and complete game implementation (single-file architecture).

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width |
| `sh` | `Int` | `720` | Screen height |
| `rail_l` | `Float` | `220.0` | Left rail boundary |
| `rail_r` | `Float` | `1060.0` | Right rail boundary |
| `max_enemies` | `Int` | `240` | Enemy pool size |
| `max_bullets` | `Int` | `960` | Bullet pool size |
| `max_pickups` | `Int` | `160` | Pickup pool size |
| `max_particles` | `Int` | `1300` | Particle pool size |
| `max_panels` | `Int` | `240` | Floor panel pool size |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Player` | `x`, `y`, `vx`, `vy`, `hp`, `energy`, `heat`, `fire_cd`, `rocket_cd`, `dash_cd`, `dash_t`, `emp_cd`, `inv_t`, `shield_on`, `score`, `combo`, `best_combo`, `distance` | Player ship state with position, resources, cooldowns, and scoring |
| `Enemy` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `hp`, `fire_cd`, `phase`, `t` | An enemy ship with type, physics, health, and firing timer |
| `Bullet` | `active`, `team`, `kind`, `x`, `y`, `vx`, `vy`, `dmg`, `radius`, `life` | A projectile with team affiliation (1=player, 2=enemy), damage, and lifetime |
| `Pickup` | `active`, `kind`, `x`, `y`, `vy`, `t` | A collectible item (0=health, 1=energy, 2=score) |
| `Particle` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `size`, `life`, `t` | A visual particle effect with velocity and decay |
| `Panel` | `active`, `x`, `y`, `w`, `h`, `hazard`, `boost`, `t` | A scrolling floor panel that may be hazardous or provide a boost |
| `Boss` | `active`, `x`, `y`, `hp`, `max_hp`, `fire_cd`, `spawn_cd`, `phase`, `t` | Boss enemy with high HP, spread fire, and minion spawning |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between low and high bounds |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two 2D points |
| `randf` | `(Float, Float) -> Float` | Random float in [lo, hi] range |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside a rectangle |
| `enemy_radius` | `(Int) -> Float` | Returns collision radius for an enemy kind (16, 20, or 26) |
| `enemy_hp` | `(Int, Int) -> Float` | Computes enemy HP based on kind and level |
| `clear_enemies` | `(Array[Enemy]) -> Unit` | Deactivates all enemies in the pool |
| `clear_bullets` | `(Array[Bullet]) -> Unit` | Deactivates all bullets in the pool |
| `clear_pickups` | `(Array[Pickup]) -> Unit` | Deactivates all pickups in the pool |
| `clear_particles` | `(Array[Particle]) -> Unit` | Deactivates all particles in the pool |
| `clear_panels` | `(Array[Panel]) -> Unit` | Deactivates all floor panels in the pool |
| `add_enemy` | `(Array[Enemy], Int, Float, Float, Int) -> Bool` | Spawns an enemy of given kind at position with level-scaled HP |
| `add_bullet` | `(Array[Bullet], Int, Int, Float, Float, Float, Float, Float, Float, Float) -> Bool` | Creates a bullet with team, kind, position, velocity, damage, radius, and lifetime |
| `add_pickup` | `(Array[Pickup], Int, Float, Float, Float) -> Bool` | Spawns a pickup of given kind at position with vertical speed |
| `add_particle` | `(Array[Particle], Int, Float, Float, Float, Float, Float, Float) -> Bool` | Creates a visual particle with kind, position, velocity, size, and lifetime |
| `add_panel` | `(Array[Panel], Float, Float, Float, Float, Bool, Bool) -> Bool` | Spawns a floor panel with position, size, and hazard/boost flags |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Emits multiple particles in a radial burst at a position |
| `draw_touch_ui` | `(Int) -> Unit` | Renders touch control overlays (D-pad and skill buttons) when in play state |
| `main` | `() -> Unit` | Entry point: initializes window, object pools, and runs the game loop with state machine (0=title, 1=play, 2=victory, 3=defeat) |

## Architecture

### Package Structure

```
raylib_chrono_rail_shooter_2026/
├── main.mbt              — Complete game: structs, math utils, object pools, input, physics, AI, rendering, state machine
└── moon.pkg              — Package config with raylib and math imports
```

This is a single-file game with all logic in `main.mbt`. Seven struct types define the entity model. State is managed via integer `state` (0=title, 1=play, 2=victory, 3=defeat) and closures (`reset_run`, `on_player_hit`) capture the mutable game state.

### Data Flow

1. **Input**: Keyboard state and touch positions are read each frame. Touch input maps to virtual D-pad zones and skill button zones using `inside_rect`. All inputs set boolean flags (`move_l`, `fire_hold`, `dash_press`, etc.).
2. **Update**: During play state, the system updates in order: player cooldowns/timers, movement with acceleration and drag, panel spawning and scrolling, enemy spawning and AI (sine-wave movement, aimed firing), boss AI (spread fire, minion spawning), bullet physics and collision, pickup collection, particle physics, and win/loss checks.
3. **Collision**: Player bullets check against all enemies (and boss) using squared distance. Enemy bullets check against player. Enemy bodies check against player. Panels check AABB overlap with player.
4. **Render**: Layers from back to front: scrolling background strips, rail boundaries, floor panels (with hazard stripes), pickups, enemies (varied shapes by kind), boss with HP bar, bullets (color-coded by team), particles (alpha-fading), player ship (with shield ring), HUD overlay (score, combo, distance, HP/EN/HEAT bars, cooldown timers), status messages, touch UI, and state overlays (title/victory/defeat).

### Key Design Patterns

- **Object pool pattern**: Pre-allocated arrays with `active` flags for all entity types (240 enemies, 960 bullets, 160 pickups, 1300 particles, 240 panels). `add_*` functions find the first inactive slot.
- **Level scaling**: `level = distance / 900 + 1` dynamically adjusts enemy HP, fire rate, spawn rate, and unlocks new enemy types, creating smooth difficulty progression.
- **Closure-based state management**: `reset_run` and `on_player_hit` are closures that capture all mutable state, providing clean reset and damage handling without passing many parameters.
- **Heat/energy resource tension**: Fire rate is gated by heat buildup (8 per shot, cools at 42/s), while abilities cost energy (regenerates at 11/s). This creates a resource management layer atop the action gameplay.
- **Team-based bullet system**: `team` field (1=player, 2=enemy) determines collision targets, allowing a single bullet pool for all projectiles.

## Improvement & Refinement Plan

1. **Extract structs and logic into internal packages**: The 2132-line single file could be split into `internal/types` (Player, Enemy, Bullet, etc.), `internal/game` (physics, AI, spawning), and `internal/render` (all drawing code) for better maintainability.

2. **Add more boss attack patterns**: The boss currently only uses a 5-bullet spread and minion spawning. Adding phases based on HP thresholds (e.g., circular bullet patterns at 50% HP, laser beams at 25%) would create a more memorable encounter.

3. **Improve pickup attraction**: Pickups currently require exact collision (26-unit radius). Adding a magnetic attraction when the player is within a larger radius would reduce frustration, especially during intense combat.

4. **Add weapon variety**: The main gun fires identical bullets regardless of level (except for spread at level 4+). Adding weapon pickups or upgrades (spread shot, piercing, homing) would add progression depth beyond raw stats.

5. **Implement proper combo decay**: The combo counter only resets on hit but never decays with time. Adding a combo timer (e.g., 3 seconds between kills) would make high combos more meaningful and rewarding.

6. **Add screen border warning for incoming enemies**: Enemies spawn at Y=-90 with no warning. Adding indicators at the top edge showing incoming enemy positions would give players time to prepare, especially for type 2 enemies with their spread shots.
