# Void Anchor Raid 2026

A twin-stick arena shooter with territory control objectives set in a void-themed sci-fi arena. The player fights waves of enemies while capturing and defending void anchors -- static control points scattered across a walled arena. The game blends bullet-hell combat with point-capture strategy, requiring the player to balance offensive shooting with territorial positioning.

The core gameplay loop centers on capturing all five void anchors by standing near them (progress builds over time) and then holding them for 10 consecutive seconds. Enemies spawn in escalating waves from arena edges with three distinct types: fast chasers (kind 0), orbiting shooters (kind 1), and heavy triple-shot elites (kind 2). Captured anchors become turrets that auto-fire at nearby enemies, while enemy-captured anchors shoot back at the player. The player manages HP, energy (for dash and pulse abilities), and weapon heat to survive.

The arena features a fixed wall layout with perimeter boundaries and interior cover blocks, creating choke points and tactical cover. The collision system uses circle-rect intersection tests with axis-separated movement resolution. A combo system rewards consecutive kills with scaling score bonuses, and defeated enemies drop score and energy orbs.

## Build and Run

```bash
moon build --target native void_anchor_raid_2026/
./_build/native/debug/build/void_anchor_raid_2026/void_anchor_raid_2026.exe
```

## Controls

- **W / Up Arrow**: Move up
- **A / Left Arrow**: Move left
- **S / Down Arrow**: Move down
- **D / Right Arrow**: Move right
- **Mouse**: Aim direction (when cursor is inside arena)
- **J / Space**: Fire weapon (hold for continuous fire)
- **H**: Accelerated anchor capture (hold near anchor, drains energy)
- **K / Right Shift**: Dash (costs 18 energy, 1.14s cooldown)
- **L**: Void pulse -- area-of-effect attack dealing 24 damage and stunning enemies within range (costs 36 energy, 5.8s cooldown)
- **R / Enter / Click**: Restart from end screen
- **F11**: Toggle fullscreen
- **Touch D-pad**: On-screen directional movement (bottom-left)
- **Touch FIRE button**: Shoot
- **Touch CAP button**: Accelerated capture
- **Touch DASH button**: Dash ability
- **Touch PULSE button**: Void pulse ability

## How to Play

The match starts with a 420-second timer and 5 void anchors placed at the center and four corners of the arena. Two enemies spawn immediately, and wave 1 begins after a short prep delay.

**Anchor capture**: Stand inside an anchor's radius to build capture progress (21 units/sec baseline, 34 units/sec when holding the capture key at the cost of energy). Enemies near an anchor decrease its progress. When progress reaches +55, the anchor becomes player-owned; at -55, it becomes enemy-owned. Player-owned anchors auto-target and fire at nearby enemies. Enemy-owned anchors shoot at the player.

**Combat**: Fire your weapon by holding the fire key. Weapon heat accumulates at 7 per shot and dissipates at 36/sec; you cannot fire above 94 heat. Starting from wave 5, your weapon fires a 3-round spread instead of single shots. Enemies drop score orbs (kind 0) and energy orbs (kind 1) on death.

**Abilities**: Dash gives a burst of speed with reduced drag and 56% damage reduction for 0.22 seconds. Void pulse deals 24 damage to all enemies within range 250, stuns them for 1.6 seconds, destroys enemy bullets within range 280, and boosts nearby anchor capture progress by 22.

**Wave progression**: Each wave spawns 8 + wave*3 enemies. Kind 1 (orbiting shooters) appear from wave 3, and kind 2 (heavy elites) from wave 7. Enemy HP scales with wave number. Clearing all enemies in a wave grants 14 bonus energy and starts a 2.8s prep timer before the next wave.

**Win condition**: Capture all 5 anchors and hold them for 10 cumulative seconds (the hold timer decays at 0.6x when not all are owned). **Lose conditions**: HP reaches 0 or time expires.

## Public API Reference

### Package `void_anchor_raid_2026`

> Main entry point and complete game implementation.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width |
| `sh` | `Int` | `760` | Screen height |
| `world_l` | `Float` | `34.0` | Arena left boundary |
| `world_r` | `Float` | `1246.0` | Arena right boundary |
| `world_t` | `Float` | `90.0` | Arena top boundary |
| `world_b` | `Float` | `726.0` | Arena bottom boundary |
| `max_anchors` | `Int` | `12` | Maximum anchor pool size |
| `max_enemies` | `Int` | `260` | Maximum enemy pool size |
| `max_bullets` | `Int` | `1200` | Maximum bullet pool size |
| `max_orbs` | `Int` | `300` | Maximum orb pool size |
| `max_walls` | `Int` | `80` | Maximum wall pool size |
| `max_particles` | `Int` | `1800` | Maximum particle pool size |
| `anchor_hold_goal` | `Float` | `10.0` | Seconds required holding all anchors to win |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Player` | `x`, `y`, `vx`, `vy`, `aim_x`, `aim_y`, `hp`, `energy`, `heat`, `inv_t`, `fire_cd`, `dash_cd`, `dash_t`, `pulse_cd`, `score`, `combo`, `best_combo` | Player state: position, velocity, aim vector, resources, cooldowns, and scoring |
| `Anchor` | `active`, `x`, `y`, `r`, `progress`, `owner`, `fire_cd`, `t` | Void anchor control point with capture progress and ownership state |
| `Enemy` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `hp`, `fire_cd`, `stun_t`, `t` | Enemy entity with type (0/1/2), physics, health, fire cooldown, and stun timer |
| `Bullet` | `active`, `team`, `kind`, `x`, `y`, `vx`, `vy`, `dmg`, `r`, `life` | Projectile with team affiliation (1=player, 2=enemy), damage, radius, and lifetime |
| `Orb` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `value`, `life`, `t` | Pickup dropped by enemies -- kind 0 gives score, kind 1 gives energy |
| `Wall` | `active`, `x`, `y`, `w`, `h` | Axis-aligned rectangular wall for collision and line-of-fire blocking |
| `Particle` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `size`, `life`, `t` | Visual particle for explosions, muzzle flash, pulse, and pickup effects |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between low and high bounds |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two 2D points |
| `randf` | `(Float, Float) -> Float` | Random float in range using raylib RNG |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Point-in-rectangle test |
| `enemy_radius` | `(Int) -> Float` | Returns collision radius for enemy kind (15/20/26) |
| `enemy_hp` | `(Int, Int) -> Float` | Computes enemy HP based on kind and wave number |
| `circle_rect_hit` | `(Float, Float, Float, Float, Float, Float, Float) -> Bool` | Circle-rectangle intersection test |
| `any_wall_hit` | `(Float, Float, Float, Array[Wall]) -> Bool` | Tests if a circle overlaps any active wall |
| `move_with_walls` | `(Float, Float, Float, Float, Float, Float, Array[Wall]) -> (Float, Float, Float, Float)` | Moves entity with axis-separated wall collision, returns new (x, y, vx, vy) |
| `clear_anchors` | `(Array[Anchor]) -> Unit` | Resets all anchors to inactive state |
| `clear_enemies` | `(Array[Enemy]) -> Unit` | Resets all enemies to inactive state |
| `clear_bullets` | `(Array[Bullet]) -> Unit` | Resets all bullets to inactive state |
| `clear_orbs` | `(Array[Orb]) -> Unit` | Resets all orbs to inactive state |
| `clear_walls` | `(Array[Wall]) -> Unit` | Resets all walls to inactive state |
| `clear_particles` | `(Array[Particle]) -> Unit` | Resets all particles to inactive state |
| `add_anchor` | `(Array[Anchor], Float, Float, Float) -> Bool` | Activates the first available anchor at position with given radius |
| `add_enemy` | `(Array[Enemy], Int, Float, Float, Int) -> Bool` | Spawns an enemy of given kind at position with wave-scaled HP |
| `add_bullet` | `(Array[Bullet], Int, Int, Float, Float, Float, Float, Float, Float, Float) -> Bool` | Creates a bullet with team, kind, position, velocity, damage, radius, and lifetime |
| `add_orb` | `(Array[Orb], Int, Float, Float, Float, Float, Int, Float) -> Bool` | Spawns a pickup orb with kind, position, velocity, value, and lifetime |
| `add_wall` | `(Array[Wall], Float, Float, Float, Float) -> Bool` | Adds a rectangular wall to the arena |
| `add_particle` | `(Array[Particle], Int, Float, Float, Float, Float, Float, Float) -> Bool` | Adds a visual particle with kind, position, velocity, size, and lifetime |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Emits n particles with scaled speed/size at a position |
| `count_active_enemies` | `(Array[Enemy]) -> Int` | Counts currently alive enemies |
| `count_owned_anchors` | `(Array[Anchor], Int) -> Int` | Counts anchors owned by a specific team |
| `count_total_anchors` | `(Array[Anchor]) -> Int` | Counts all active anchors |
| `setup_map` | `(Array[Wall], Array[Anchor]) -> Unit` | Builds the arena with perimeter walls, interior blocks, and 5 anchors |
| `draw_touch_ui` | `(Int) -> Unit` | Renders on-screen touch D-pad and action buttons during gameplay |
| `main` | `() -> Unit` | Entry point: initializes window, allocates pools, runs game loop with state machine |

## Architecture

### Package Structure

```
void_anchor_raid_2026/
├── main.mbt              — Complete game: types, logic, rendering, input, main loop
└── moon.pkg              — Package config with raylib and math imports
```

The game is implemented entirely in a single `main.mbt` file. Constants and structs are defined at the top, followed by utility functions, entity pool management (clear/add), gameplay helpers, touch UI rendering, and finally the main function containing the game loop.

### Data Flow

1. **Input**: Keyboard state and mouse position are read each frame. Touch regions are mapped to the same boolean flags as keyboard keys (move_l/r/u/d, fire_hold, capture_hold, dash_press, pulse_press).
2. **Update**: The game state integer (0=menu, 1=play, 2=win, 3=lose) gates logic. During play: cooldowns tick, wave spawning logic runs, player movement is computed with wall collision via `move_with_walls`, anchor capture progress is updated, enemies seek targets (player or anchors), bullets are moved and tested for collisions against walls/enemies/player/anchors, orbs are collected, and win/loss conditions are checked.
3. **Render**: Background grid and stars, arena boundary, walls, anchors with progress bars, orbs, enemies (shape varies by kind), bullets, player with aim line and dash trail, particles, then HUD (timer, wave, score, combo, bars for HP/energy/heat/hold progress).

### Key Design Patterns

- **Object Pool Pattern**: Pre-allocated arrays with `active` flags for all entity types. Pool sizes are defined as top-level constants (max_enemies=260, max_bullets=1200, etc.).
- **Axis-Separated Collision**: `move_with_walls` resolves X then Y movement independently, reversing velocity on wall contact with a 0.16 damping factor.
- **Territory Control**: Anchors have a -100 to +100 progress bar. Positive progress favors the player, negative favors enemies. Ownership thresholds at +/-55 determine which team the anchor fights for.
- **Wave System**: Enemies spawn in waves of 8+wave*3. Wave prep timer delays between waves. Enemy type distribution shifts toward harder types at higher waves.
- **Combo System**: Consecutive kills without taking damage increment a combo counter that adds bonus score per kill.

## Improvement & Refinement Plan

1. **Add minimap or anchor status HUD**: With 5 anchors spread across the arena, the player lacks visibility of distant anchors' capture status. A small minimap or anchor status strip showing progress/ownership would improve strategic decision-making.
2. **Implement wall destruction**: The `Wall` struct has fields ready for a destructible walls system, but walls are currently permanent. Adding health to walls and allowing enemy/player bullets to destroy cover would add dynamic arena evolution.
3. **Balance energy economy**: Energy regenerates at 10/sec passively, but dash costs 18 and pulse costs 36 while capture acceleration drains 14/sec. The passive regen alone barely covers one dash every 2 seconds, making energy orbs critical. Consider adding a slow HP regeneration or adjusting energy costs for better flow.
4. **Extract constants from inline values**: Collision radii (16.0 for player, 15/20/26 for enemies), bullet speeds (700, 520, 360), damage values, and cooldown timers are hardcoded throughout the game loop. Extracting these as named constants would simplify balancing.
5. **Add enemy variety beyond wave 7**: Only 3 enemy types exist. Adding wave-locked enemy variants (e.g., shielded enemies, teleporters) would maintain challenge in later waves beyond just HP/speed scaling.
6. **Improve anchor turret targeting**: Player-owned anchors target the nearest enemy within 320 range, but do not lead their shots. Adding projectile lead prediction based on enemy velocity would make anchor turrets more effective.
7. **Add visual feedback for heat and cooldowns**: The HUD shows bars, but there is no on-screen indicator near the player showing when weapon heat is critical or when dash/pulse are ready. Adding subtle visual cues would reduce HUD scanning.
