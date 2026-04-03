# Reactor Siege 2026

A top-down twin-stick defense game where you protect a reactor core at the center of a 3600x2600 world from waves of swarming enemies. As the sole pilot, you move with WASD, aim with the mouse cursor, fire bullets, dash for burst mobility, deploy EMP pulses to stun nearby enemies, and build or repair auto-targeting turrets on six pads arranged in a ring around the core. Enemies drop scrap on death, which funds turret construction and repair.

The core gameplay loop alternates between timed defense waves and brief intermissions. Each wave spawns enemies from the world edges that path toward the reactor core (or toward the hero if close enough). Two enemy types exist: standard swarmer enemies (kind 0) with lower HP but faster movement, and heavy enemies (kind 1) with higher HP and stronger bites. The reactor has a regenerating shield that absorbs damage before the core HP is touched. Turrets auto-target the nearest enemy within 460 units and fire every 0.26 seconds. The wave is cleared when the timer runs out; the run fails if the hero's HP or the reactor's HP reaches zero.

The game is implemented as a single-file design with all structs, game logic, input handling, and rendering in `main.mbt`. It uses `FixedArray` for all object pools (bullets, enemies, drops, turrets, particles), and the camera follows the hero with clamping to world bounds and screen shake on damage.

## Build and Run

```bash
moon build --target native reactor_siege_2026/
./_build/native/debug/build/reactor_siege_2026/reactor_siege_2026.exe
```

## Controls

- **W / Up Arrow**: Move up
- **A / Left Arrow**: Move left
- **S / Down Arrow**: Move down
- **D / Right Arrow**: Move right
- **Mouse Cursor**: Aim direction for bullets
- **Mouse Left Button / J**: Fire bullets toward cursor (0.1s cooldown, 0.06s during dash)
- **Space / Left Shift**: Dash (0.36s burst of speed, 2.1s cooldown)
- **Q**: EMP Pulse (stuns and deals 24 damage to enemies within 230 units, 8s cooldown)
- **E**: Build turret on a nearby pad (120 scrap) or repair an existing turret (80 scrap, restores 95 HP up to 220 max)
- **R**: Restart the current wave
- **Enter / Space**: Start game from title screen; advance to next wave from wave-clear screen
- **F11**: Toggle fullscreen
- **Touch Controls (mobile)**: On-screen D-pad (L/R/U/D), FIRE, DASH, PULSE, and BUILD buttons

## How to Play

Press Enter or Space on the title screen to begin wave 1. You control the hero pilot (blue circle with aim line) in a scrollable 3600x2600 world. The reactor core sits at the center with a blue energy glow and a regenerating shield ring.

**Combat**: Hold J or mouse button to auto-fire bullets toward the cursor. Bullets deal 34 damage (42 during dash) and travel at 620 speed (690 during dash) with 1.1s lifetime. Enemies take damage and accumulate stun time from hits. When an enemy's HP drops to zero, it dies, drops scrap, and awards kill score (18 for standard, 42 for heavy).

**Abilities**: Dash gives 0.36 seconds of increased acceleration (860 vs 520), higher max speed (520 vs 312), reduced drag, and faster fire rate. EMP Pulse stuns all enemies within 230 units for 1.5 seconds and deals 24 damage, with an 8-second cooldown.

**Turrets**: Six build pads are arranged in a ring (340-unit radius) around the reactor core. Stand near a pad and press E to build a turret for 120 scrap. Turrets auto-fire at the nearest enemy within 460 units every 0.26 seconds, dealing 22 damage per shot. They have 180 HP and can be repaired for 80 scrap (restoring 95 HP, capped at 220). Enemies can attack turrets, dealing 18-26 damage per bite.

**Enemy Behavior**: Enemies spawn from world edges and path toward the reactor core. If the hero is within 280 units, they redirect toward the hero instead. Standard enemies move at 170 + (level-1) x 15 speed; heavy enemies at 126 + (level-1) x 12. Enemies bite on contact: standard deal 16 damage, heavy deal 22 damage to the hero (0.4s hit immunity); 14 and 22 to the core; 18 and 26 to turrets.

**Wave Progression**: Each wave has a timer (starting at 152s, decreasing by 10s per level, minimum 86s). Enemies spawn continuously at intervals that decrease with level (0.9 - (level-1) x 0.06, minimum 0.28s). The initial wave spawns 12 + level x 3 enemies. When the timer expires, the wave is cleared and your score includes remaining scrap and core HP. Press Enter to advance to the next wave (up to level 8). If hero HP or core HP reaches zero, the siege is lost.

**Resources**: The hero regenerates 2.6 HP/s. The core shield regenerates at 7.0/s (cap 260). Core HP scales with level: 1000 + (level-1) x 130. Hero starts with 180 scrap each wave.

## Public API Reference

### Package `reactor_siege_2026`

> Single-file game with all types, logic, and rendering in main.mbt.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Hero` | `x`, `y`, `vx`, `vy`, `aim_x`, `aim_y`, `hp`, `shoot_cd`, `pulse_cd`, `dash_t`, `dash_cd`, `hit_cd`, `flash_t`, `shake_t`, `scrap`, `score` | Player pilot with position, velocity, aim direction, cooldowns, and resources |
| `Core` | `x`, `y`, `hp`, `shield` | The reactor core with position, health pool, and regenerating shield |
| `Enemy` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `hp`, `stun_t`, `bite_cd` | A swarming enemy with movement, health, stun timer, and bite cooldown |
| `Bullet` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `dmg`, `life` | A projectile fired by hero (kind 0) or turret (kind 1) |
| `Drop` | `active`, `x`, `y`, `value`, `t`, `life` | A scrap drop left by a dead enemy with pulsing animation and lifetime |
| `Turret` | `active`, `x`, `y`, `hp`, `cd` | An auto-targeting turret placed on a build pad |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `size`, `t`, `life`, `kind` | A visual particle effect element |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width |
| `sh` | `Int` | `820` | Screen height |
| `world_w` | `Float` | `3600.0` | World width |
| `world_h` | `Float` | `2600.0` | World height |
| `max_enemies` | `Int` | `56` | Enemy pool capacity |
| `max_bullets` | `Int` | `520` | Bullet pool capacity |
| `max_drops` | `Int` | `84` | Drop pool capacity |
| `max_turrets` | `Int` | `8` | Turret pool capacity |
| `max_particles` | `Int` | `1500` | Particle pool capacity |
| `pad_count` | `Int` | `6` | Number of turret build pads |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between lo and hi |
| `randf` | `(Float, Float) -> Float` | Random float in [lo, hi] via raylib RNG |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two 2D points |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside a rectangle |
| `emit_particle` | `(FixedArray[Particle], Float, Float, Float, Float, Float, Float, Int) -> Unit` | Activates a single particle in the pool |
| `burst_particles` | `(FixedArray[Particle], Float, Float, Int, Float, Int) -> Unit` | Spawns multiple particles in a radial burst |
| `spawn_bullet` | `(FixedArray[Bullet], Int, Float, Float, Float, Float, Float, Float) -> Unit` | Creates a new bullet in the pool |
| `spawn_drop` | `(FixedArray[Drop], Float, Float, Int) -> Unit` | Creates a scrap drop in the pool |
| `spawn_enemy` | `(FixedArray[Enemy], Int, Float, Float) -> Unit` | Spawns an enemy from a random world edge, avoiding the core |
| `init_enemy_wave` | `(FixedArray[Enemy], Int, Float, Float) -> Unit` | Clears enemies and spawns the initial wave batch |
| `draw_bar` | `(Int, Int, Int, Int, Float, Color, Color) -> Unit` | Draws a progress bar with fill ratio, foreground/background colors |
| `draw_touch_controls` | `(Bool) -> Unit` | Draws on-screen touch control buttons |

## Architecture

### Package Structure

```
reactor_siege_2026/
├── main.mbt    -- All structs, game logic, input, rendering in a single file
└── moon.pkg    -- Package config with math and raylib imports
```

This is a single-file game. The `main` function initializes all FixedArray pools, creates the hero and core, sets up build pad positions in a ring, and enters the game loop. A `reset_round` closure handles per-wave initialization. The game state machine uses integer states: 0=title, 1=play, 2=wave_cleared, 3=defeated.

### Data Flow

1. **Input**: Each frame reads keyboard state for WASD movement, J/mouse for firing, Space/Shift for dash, Q for pulse, E for build, and touch button positions. Diagonal movement is normalized to prevent faster diagonal speed.

2. **Hero Update**: Movement uses acceleration/drag physics with different parameters during dash. The aim direction tracks the mouse cursor in world space (camera offset + mouse position). Cooldowns for shooting, dash, pulse, and hit immunity tick down each frame. Bullets spawn at the hero's position aimed along the aim vector.

3. **Enemy AI**: Each enemy computes a target (core or hero if within 280 units), applies steering forces toward the target, and checks bite range against hero, core, and turrets. Stunned enemies have their velocity damped instead of steered.

4. **Turret AI**: Each active turret scans all enemies for the nearest one within 460 units and fires a bullet toward it every 0.26 seconds.

5. **Collision**: Bullets iterate against enemies for hit detection (22-unit radius). Enemy bites check distance against hero (30 units), core (42 units), and turrets (30 units). Drop collection uses a pulsing radius.

6. **Rendering**: The camera centers on the hero with world-bound clamping and shake offset. The world draws a grid, core, build pads, turrets, drops, enemies, bullets, hero, particles, then HUD bars and text overlays.

### Key Design Patterns

- **FixedArray Object Pools**: All entities (bullets, enemies, drops, turrets, particles) use `FixedArray` with `active` flags. This ensures zero heap allocation during gameplay and predictable memory usage.

- **Closure-Based Reset**: The `reset_round` function is a closure that captures all mutable game state, allowing clean per-wave reinitialization without passing dozens of parameters.

- **Hero-Centric Camera**: The camera simply follows the hero with world-bound clamping, keeping the core visible when the hero is nearby and allowing exploration of the full world.

- **Shield-First Damage Model**: The reactor core has a separate shield pool (260, regenerating at 7/s) that absorbs damage before core HP is touched, creating a buffer that rewards killing enemies quickly.

- **Turret Economy**: Building turrets (120 scrap) and repairing them (80 scrap) creates a meaningful resource tradeoff -- scrap from kills must be invested in defense infrastructure.

- **Delta-Time with Cap**: Frame time is capped at 0.033s to prevent physics instabilities.

## Improvement & Refinement Plan

1. **Extract into Multi-Package Architecture**: The entire game is in a single 1700+ line `main.mbt` file. Splitting into `internal/types`, `internal/game`, and `internal/render` packages would dramatically improve organization and allow the render pass to be strictly read-only.

2. **Replace Integer State Machine with Enum**: Game states (0=title, 1=play, 2=wave_cleared, 3=defeated) and enemy kinds (0=standard, 1=heavy) are raw integers. MoonBit enums would provide exhaustiveness checking and self-documenting code.

3. **Add More Enemy Types**: Currently only two enemy types exist (standard and heavy), differentiated by speed, HP, and damage. Adding ranged enemies, bomber enemies that explode near the core, or fast scout enemies would increase tactical depth.

4. **Implement Turret Upgrade Tiers**: Turrets can only be built or repaired. Adding upgrade tiers (faster fire rate, splash damage, longer range) at increasing scrap costs would deepen the turret economy.

5. **Add Sound Effects**: The game has no audio despite `@raylib` providing audio capabilities. Adding firing sounds, explosion effects, dash wooshes, and ambient hum would greatly improve immersion.

6. **Improve Touch Control Responsiveness**: Touch input reuses the same `inside_rect` check as keyboard input without edge detection for dash and pulse. This means holding the dash button area continuously re-triggers dash. Adding press-edge detection would prevent unintended ability usage.

7. **Add Wave Preview**: Between waves there is no indication of upcoming difficulty. Showing the next wave's enemy count, speed multiplier, or new enemy types would help players prepare their turret placement strategy.

8. **Persist High Scores**: Score and wave progress are lost on restart. Adding file-based persistence would allow players to track their best wave reached and highest score across sessions.
