# Spellforge Arena 2026

Spellforge Arena 2026 is a twin-stick magic combat arena game set in a dark, grid-lined battlefield. The player controls a mage who must survive escalating waves of enemies across a scrolling world, wielding three elemental spell types -- fire, frost, and storm -- alongside a mana-fueled dash ability.

The core gameplay loop revolves around managing three intertwined resources: health, mana, and spell cooldowns. Fire projectiles are the rapid primary attack, burning enemies over time. Frost emits an area-of-effect pulse that slows nearby enemies and deals damage. Storm chains lightning bolts to the nearest enemies, shocking and stunning them. Defeated enemies drop mana or health orbs that must be collected to sustain the fight. A combo counter increases with each kill and amplifies score gains, but resets when the mage takes a hit.

The game runs as a single-file application with all logic in `main.mbt`. It uses a pre-allocated object pool architecture with `FixedArray` for enemies, projectiles, orbs, and particles, keeping allocations at zero during gameplay. The world is 3400x2400 pixels with a camera system that follows the mage, and enemies spawn from the world edges at intervals that tighten with each level.

## Build and Run

```bash
moon build --target native spellforge_arena_2026/
./_build/native/debug/build/spellforge_arena_2026/spellforge_arena_2026.exe
```

## Controls

- **W / Up Arrow**: Move up
- **A / Left Arrow**: Move left
- **S / Down Arrow**: Move down
- **D / Right Arrow**: Move right
- **Mouse**: Aim direction (cursor position relative to mage in world space)
- **J / Left Mouse Button**: Cast fire spell (rapid projectiles with burn effect)
- **K**: Cast frost spell (area-of-effect slow and damage around the mage)
- **L**: Cast storm spell (chain lightning targeting up to 8 nearest enemies)
- **Space / Left Shift**: Dash (burst of speed with brief invulnerability window)
- **R**: Reset current round
- **Enter / Space**: Start game / advance to next level / retry after death
- **F11**: Toggle fullscreen
- **Touch controls**: On-screen directional pad (bottom-left) and action buttons (bottom-right)

## How to Play

The game begins on a title screen. Press Enter or Space to start the first ritual (level). The mage spawns at the center of the 3400x2400 world with 300 HP and 260 mana.

Enemies spawn from the four edges of the world at regular intervals. There are two enemy types: kind 0 (basic, faster, 14 bite damage) and kind 1 (elite, slower but tougher, 22 bite damage). Elite enemies appear more frequently at higher levels. Enemies chase the mage relentlessly, and contact deals damage with a 0.6-second bite cooldown.

Fire spells cost 7 mana and travel at 690 units/second, dealing 34 damage (42 during dash). They apply a burn effect that deals 12 damage per second over 1.8 seconds. Frost costs 46 mana with a 4.8-second cooldown, dealing 30 damage and slowing all enemies within 250 units by 48% for 2.5 seconds. Storm costs 60 mana with a 7.2-second cooldown, striking up to 8 enemies within 420 units for 48 damage each while shocking them (64% slow for 1.4 seconds). Dash costs 42 mana with a 1.9-second cooldown, granting 0.34 seconds of boosted speed and faster fire rate.

Mana regenerates at 18 units per second. Killed enemies drop orbs -- blue mana orbs (70% chance) restore mana, purple health orbs (30% chance) restore HP. Each kill adds to the combo counter, which provides bonus score per kill. Taking damage resets the combo to zero.

Each level has a timer (starting at 164 seconds, decreasing by 9 seconds per level, minimum 94 seconds). Surviving until the timer expires completes the ritual and advances to the next level (up to level 8). Remaining HP and mana are added to the final score. If the mage's HP drops to zero, the ritual is broken and the player can retry.

## Public API Reference

### Package `spellforge_arena_2026`

> Main entry point and complete game implementation.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width in pixels |
| `sh` | `Int` | `820` | Screen height in pixels |
| `world_w` | `Float` | `3400.0` | World width in pixels |
| `world_h` | `Float` | `2400.0` | World height in pixels |
| `max_enemies` | `Int` | `68` | Maximum concurrent enemies in the pool |
| `max_projectiles` | `Int` | `620` | Maximum concurrent projectiles in the pool |
| `max_orbs` | `Int` | `96` | Maximum concurrent orbs in the pool |
| `max_particles` | `Int` | `1500` | Maximum concurrent particles in the pool |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Mage` | `x`, `y`, `vx`, `vy`, `aim_x`, `aim_y`, `hp`, `mana`, `fire_cd`, `frost_cd`, `storm_cd`, `dash_t`, `dash_cd`, `hit_cd`, `flash_t`, `shake_t`, `score`, `combo` | Player character state including position, velocity, aiming direction, resources, cooldowns, visual effects, and scoring |
| `Enemy` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `hp`, `burn_t`, `slow_t`, `shock_t`, `bite_cd` | Enemy entity with position, type (0=basic, 1=elite), health, status effect timers, and attack cooldown |
| `Projectile` | `active`, `kind`, `from_player`, `x`, `y`, `vx`, `vy`, `dmg`, `life` | Projectile entity with movement, damage, ownership flag, and lifetime |
| `Orb` | `active`, `kind`, `x`, `y`, `value`, `t`, `life` | Collectible orb dropped by enemies; kind 0 restores mana, kind 1 restores HP |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `size`, `t`, `life`, `kind` | Visual particle for effects; kind determines color (0=fire, 1=frost, 2=storm) |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value between a lower and upper bound |
| `randf` | `(Float, Float) -> Float` | Returns a random float in the range [lo, hi] using raylib's RNG |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Computes squared distance between two 2D points |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests whether a point is inside a rectangle defined by position and size |
| `emit_particle` | `(FixedArray[Particle], Float, Float, Float, Float, Float, Float, Int) -> Unit` | Activates a single particle from the pool with given position, velocity, size, lifetime, and kind |
| `burst_particles` | `(FixedArray[Particle], Float, Float, Int, Float, Int) -> Unit` | Emits multiple particles in random directions from a point |
| `spawn_projectile` | `(FixedArray[Projectile], Int, Bool, Float, Float, Float, Float, Float, Float) -> Unit` | Activates a projectile from the pool with kind, ownership, position, velocity, damage, and lifetime |
| `spawn_orb` | `(FixedArray[Orb], Float, Float, Int, Int) -> Unit` | Activates an orb from the pool at a position with kind and value |
| `spawn_enemy` | `(FixedArray[Enemy], Int, Float, Float) -> Unit` | Spawns an enemy at a random world edge, away from the player center |
| `init_wave` | `(FixedArray[Enemy], Int, Float, Float) -> Unit` | Deactivates all enemies and spawns an initial batch for a new wave (14 + level * 4) |
| `draw_bar` | `(Int, Int, Int, Int, Float, Color, Color) -> Unit` | Draws a progress bar with foreground/background colors at the given screen position |
| `draw_touch_controls` | `(Bool) -> Unit` | Renders on-screen touch controls: directional pad and action buttons |

## Architecture

### Package Structure

```
spellforge_arena_2026/
├── main.mbt              -- Entry point, game loop, all logic and rendering
└── moon.pkg              -- Package config with raylib and math imports
```

This is a single-file game with all types, logic, input handling, physics, and rendering contained in `main.mbt`. The architecture is entirely procedural.

### Data Flow

1. **Input**: `is_key_down`/`is_key_pressed` and mouse position are polled each frame. Touch controls are checked via `inside_rect` hit-testing against on-screen button rectangles. Input flags (`move_l`, `move_r`, `fire_down`, `frost_press`, `storm_press`, `dash_press`) are set from either keyboard/mouse or touch.

2. **Update**: The main update block (state == 1) processes in order:
   - Cooldown timers are decremented (`fire_cd`, `frost_cd`, `storm_cd`, `dash_t`, `dash_cd`, `hit_cd`, `flash_t`, `shake_t`)
   - Mana regenerates at 18/sec
   - Mage movement uses acceleration/drag physics with `clampf` world bounds
   - Aim direction computed from mouse-to-world-space offset
   - Spell casting checks mana and cooldowns, then calls `spawn_projectile`, `burst_particles`, or directly damages enemies
   - `spawn_cd` triggers new `spawn_enemy` calls at intervals
   - Enemy AI chases the mage with speed modified by status effects (`slow_t`, `shock_t`)
   - Projectile-enemy collision via `dist2` applies damage and burn
   - Dead enemies spawn orbs via `spawn_orb` and increment combo
   - Orb collection restores mana or HP
   - Particles update with velocity damping

3. **Render**: Camera offset (`cam_x`, `cam_y`) centers on mage. Screen shake offset applied. Grid lines, orbs, enemies (with status effect coloring), projectiles, mage (with aim line), particles, and HUD (bars, score, cooldowns) are drawn in order. State overlays (title, victory, defeat) drawn last.

### Key Design Patterns

- **Object pool pattern**: All entities (enemies, projectiles, orbs, particles) use pre-allocated `FixedArray` with `active` flags. Spawning finds the first inactive slot; "destruction" simply sets `active = false`.
- **State machine**: Integer `state` variable (0=title, 1=playing, 2=victory, 3=defeat) controls update and rendering branches.
- **Status effect stacking**: Enemy status effects (`burn_t`, `slow_t`, `shock_t`) use timer-based stacking -- each application adds duration rather than resetting it.
- **Combo system**: Kill combo increments on each enemy death and adds bonus score, but resets to zero on any hit taken by the mage.
- **Camera follow with clamping**: Camera centers on the mage but is clamped to world bounds so edges are always visible.
- **Delta-time physics**: All movement and timers use frame delta time with a 0.033 cap to prevent physics explosions.

## Improvement & Refinement Plan

1. **Extract spell definitions into data structures**: The fire/frost/storm spell parameters (mana cost, cooldown, damage, range) are scattered as magic numbers throughout the main function. Creating a `Spell` struct with these fields would centralize tuning and make adding new spells straightforward.

2. **Separate update and render phases**: The 1600-line `main` function mixes input, physics, collision, and rendering. Extracting `update_mage`, `update_enemies`, `update_projectiles`, `update_orbs`, `check_collisions`, and `draw_scene` functions would improve readability and maintainability.

3. **Add spatial partitioning for collision detection**: The projectile-enemy collision loop is O(projectiles * enemies), which with 620 projectiles and 68 enemies could be expensive. A simple grid-based spatial hash would reduce checks significantly.

4. **Implement proper invincibility frames during dash**: Currently `mage.dash_t` only boosts speed and fire rate. Adding an invulnerability check in the enemy bite collision (when `dash_t > 0`) would give the dash more tactical depth and match player expectations.

5. **Add visual feedback for cooldown states**: The frost and storm cooldown indicators are text-only. Adding colored bar overlays similar to `draw_bar` for each spell cooldown would provide clearer at-a-glance information during intense combat.

6. **Introduce enemy separation behavior**: Enemies only chase the mage with no inter-enemy avoidance, causing them to stack on top of each other. Adding a simple separation force in the enemy update loop (checking `dist2` between nearby enemies) would create more interesting formations.

7. **Scale particle pool with level**: The `max_particles` of 1500 is fixed, but higher levels spawn more enemies and thus more particle bursts. At level 8 with frequent kills, the pool could saturate. Dynamically adjusting particle counts or prioritizing newer particles would maintain visual quality.
