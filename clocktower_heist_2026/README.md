# Clocktower Heist 2026

A top-down stealth action game where the player controls a thief infiltrating a clocktower across 3 progressively harder floors. Each floor requires collecting a target number of keycards, hacking open a vault while standing in its zone, and then reaching the exit to advance. Guards patrol between waypoints and chase the player on detection, firing darts that deal damage.

The player has three resource-managed abilities: sprint (continuous stamina drain for 30% speed boost), EMP pulse (24 stamina, stuns guards within 178 units for 1.6-2.5 seconds), and cloak (28 stamina, reduces guard detection radius by 54% for 2.6 seconds). Stamina regenerates at 20/s and is the shared resource for all abilities. Guards have a facing-based detection cone -- they only spot the player when the dot product between their facing direction and the player direction exceeds 0.12, or while already alert. The game features hand-placed wall obstacles that increase per floor, creating more complex navigation as difficulty rises.

## Build and Run

```bash
moon build --target native clocktower_heist_2026/
./_build/native/debug/build/clocktower_heist_2026/clocktower_heist_2026.exe
```

## Controls

- **W / Up Arrow**: Move up
- **A / Left Arrow**: Move left
- **S / Down Arrow**: Move down
- **D / Right Arrow**: Move right
- **J / Left Shift**: Sprint (hold; drains stamina at 22/s, requires > 6 stamina)
- **K**: EMP pulse (stuns nearby guards; costs 24 stamina, 2.6s cooldown)
- **L**: Cloak (reduces detection radius by 54%; costs 28 stamina, lasts 2.6s)
- **R**: Restart game (resets to floor 1)
- **Touch**: On-screen D-pad (bottom-left) for movement; SPRINT, PULSE, CLOAK buttons (bottom-right) for abilities

## How to Play

Start on floor 1 at position (84, 734) with 6 HP, 100 stamina, and a floor timer (138 seconds on floor 1, 152 on floor 2, 166 on floor 3). The play area is bounded by walls at the screen edges and internal wall segments.

**Keycards**: Collect the required number of keycards scattered across the floor. Floor 1 requires 8 of 13 keycards, floor 2 requires 12 of 18, floor 3 requires 16 of 23. Keycards come in 3 types (kind 0/1/2) worth 88/102/116 points respectively, and also award 1/2/3 stars.

**Vault**: Once enough keycards are collected, stand within the vault zone (upper-right area, at 986,186 to 1204,348) to hack it. Hack progress increases at 34%/s while inside the zone and decays at 12%/s when outside. Reaching 100% unlocks the vault for 320 bonus points and 4 stars.

**Exit**: After the vault is open, reach the exit zone (lower-left, at 36,654 to 196,784) to trigger a 2.1-second transition to the next floor. Completing all 3 floors wins the game.

**Guards**: Patrol between two waypoints (A and B) at their base speed (96-118 units/s). When they detect the player (within detection radius, facing direction dot product >= 0.12), they enter a 1.1-second alert state, chase at 122% speed, and fire darts when within 360 units. Dart speed scales with level (430 + level*36). Guard contact deals 1 HP damage with a 1.0s invulnerability window. Floor 1 has 8 guards, floor 2 adds 4 more, floor 3 adds another 4.

**Abilities**:
- **Sprint**: Hold J/Shift. Multiplies acceleration by 1.30 and raises max speed from 254 to 344. Drains stamina at 22/s (net drain: 2/s since regen is 20/s). Requires > 6 stamina.
- **EMP Pulse**: Press K. Costs 24 stamina, 2.6s cooldown. Stuns all guards within 178 units for 1.6-2.5 seconds, clearing their alert state.
- **Cloak**: Press L. Costs 28 stamina, lasts 2.6 seconds. Reduces all guard detection radii by 54% while active. Also drains stamina at 8/s while active.

**Walls**: The level has permanent wall segments (gray rectangles) that block both player and guard movement, plus bullets. Floor 2 adds an additional wall block. Floor 3 adds another. Walls force indirect routes and create cover opportunities.

**Damage**: Each hit (guard contact or dart) deals 1 HP with a 1.0s invulnerability cooldown. At 0 HP, the heist fails.

**Game Over**: HP reaches 0 or the floor timer expires. Press R to restart from floor 1.

**Win**: Complete all 3 floors by collecting keycards, hacking the vault, and reaching the exit on each.

## Public API Reference

### Package `clocktower_heist_2026`

> Main entry point and complete game implementation (single-file architecture).

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width in pixels |
| `sh` | `Int` | `820` | Screen height in pixels |
| `max_guards` | `Int` | `28` | Guard object pool size |
| `max_keycards` | `Int` | `24` | Keycard object pool size |
| `max_bullets` | `Int` | `320` | Bullet object pool size |
| `max_particles` | `Int` | `640` | Particle object pool size |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Thief` | `x`, `y`, `vx`, `vy` (mut Float), `hp` (mut Int), `stamina`, `pulse_cd`, `cloak_t`, `hit_cd`, `flash_t` (mut Float) | Player character with position, velocity, health, stamina, ability cooldowns, and visual feedback timers |
| `Guard` | `x`, `y`, `vx`, `vy`, `ax`, `ay`, `bx`, `by` (mut Float), `to_b` (mut Bool), `speed`, `detect_r`, `shoot_cd`, `stun_t`, `alert_t` (mut Float), `active` (mut Bool) | A patrolling guard with current position, patrol endpoints (A and B), movement parameters, detection radius, and state timers |
| `Keycard` | `x`, `y` (mut Float), `kind` (mut Int), `active` (mut Bool) | A collectible keycard with position, type (0/1/2 affecting score/stars), and active state |
| `Bullet` | `x`, `y`, `vx`, `vy`, `ttl` (mut Float), `owner` (mut Int), `active` (mut Bool) | A projectile with position, velocity, time-to-live, owner ID (2=guard), and active state |
| `Particle` | `x`, `y`, `vx`, `vy`, `ttl` (mut Float), `kind` (mut Int), `active` (mut Bool) | A visual particle with position, velocity, lifetime, kind (0=damage, 1=collect, 2=cloak, 3=pulse), and active state |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between low and high bounds |
| `sqdist` | `(Float, Float, Float, Float) -> Float` | Returns the squared distance between two 2D points |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point (px, py) is inside a rectangle (rx, ry, rw, rh) |
| `circle_hits_rect` | `(Float, Float, Float, Float, Float, Float, Float) -> Bool` | Tests if a circle (cx, cy, cr) overlaps a rectangle (rx, ry, rw, rh) using nearest-point distance |
| `blocked` | `(Int, Float, Float, Float) -> Bool` | Tests if a circle at position (x, y) with radius r collides with any wall or boundary for the given level |
| `clear_guards` | `(Array[Guard]) -> Unit` | Deactivates all guards and resets their state |
| `clear_keycards` | `(Array[Keycard]) -> Unit` | Deactivates all keycards and resets their state |
| `clear_bullets` | `(Array[Bullet]) -> Unit` | Deactivates all bullets and resets their state |
| `clear_particles` | `(Array[Particle]) -> Unit` | Deactivates all particles and resets their state |
| `spawn_particle` | `(Array[Particle], Float, Float, Float, Int) -> Unit` | Spawns a single particle at position with random velocity scaled by speed, random lifetime (0.10-0.58s), and a visual kind |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Spawns n particles at position in a radial burst pattern |
| `spawn_bullet` | `(Array[Bullet], Float, Float, Float, Float, Int, Float) -> Unit` | Spawns a bullet at position with direction (dx, dy), owner ID, speed, and 1.6s lifetime |
| `reset_player` | `(Thief) -> Unit` | Resets the player to starting position (84, 734) with 6 HP, 100 stamina, and all cooldowns cleared |
| `set_keycard` | `(Array[Keycard], Int, Float, Float, Int) -> Unit` | Initializes a keycard at the given index with position and kind |
| `init_keycards` | `(Int, Array[Keycard]) -> Int` | Places keycards for the given level (13 for level 1, +5 for level 2, +5 for level 3) and returns the collection target (8/12/16) |
| `set_guard` | `(Array[Guard], Int, Float, Float, Float, Float, Float, Float) -> Unit` | Initializes a guard at the given index with patrol endpoints (ax,ay) and (bx,by), speed, and detection radius |
| `init_guards` | `(Int, Array[Guard]) -> Unit` | Places guards for the given level (8 for level 1, +4 for level 2, +4 for level 3) with hand-tuned patrol routes |
| `setup_level` | `(Int, Thief, Array[Guard], Array[Keycard], Array[Bullet], Array[Particle]) -> (Int, Float)` | Initializes a complete level: resets player, places guards and keycards, clears bullets and particles; returns (target_cards, timer) |
| `main` | `() -> Unit` | Entry point: initializes window, creates object pools, and runs the game loop with input handling, physics, guard AI, collision, vault hacking, level transitions, and layered rendering |

## Architecture

### Package Structure

```
clocktower_heist_2026/
├── main.mbt              — Complete game: structs, math, AI, physics, collision, rendering, level setup
└── moon.pkg              — Package config with raylib and math imports
```

Single-file architecture with all logic in `main.mbt` (1657 lines). Five struct types define the entity model. Game state is managed as mutable local variables in `main`, with level setup delegated to `setup_level` which coordinates guard/keycard placement and returns the collection target and timer.

### Data Flow

1. **Input**: Keyboard state and touch button positions are checked each frame. Movement keys set acceleration vectors (460 units/s^2, boosted 1.30x by sprint). Touch D-pad and ability buttons map to the same boolean flags as keyboard input.
2. **Player Physics**: Acceleration is applied to velocity with exponential drag (factor 2.5/s). Velocity is clamped to max_speed (254 normal, 344 sprinting). Position updates are checked against `blocked()` -- if the new position collides with any wall, the move is reverted and velocity is damped to 20%.
3. **Guard AI**: Each guard moves toward its current waypoint (A or B), switching when within 20 units. If the player is within detection range and in the guard's forward cone (dot product >= 0.12), the guard enters alert mode (1.1s timer) and chases at 122% speed. Stunned guards have heavy drag (4.2x) and cannot detect, chase, or shoot. Guards fire aimed darts when within 360 units and their shoot cooldown is ready.
4. **Collision**: Guard-player proximity (30 units) deals contact damage. Bullet-player proximity (18 units) deals dart damage. Both trigger a 1.0s invulnerability window. Bullets collide with walls via `blocked()`.
5. **Vault Hacking**: When enough keycards are collected, standing in the vault zone increases hack progress at 34%/s. Leaving the zone causes 12%/s decay. At 100%, the vault opens and the exit zone becomes active.
6. **Render**: Layers from back to front: animated city skyline background with pulsing glow, floor base rectangles, wall segments, vault and exit zone highlights, keycards (colored rectangles by kind), guard vision cones (semi-transparent triangles), guard figures (head/body/limbs), player figure (with color changes for cloak/damage), EMP pulse ring, bullets (short lines), particles, HUD header (floor/cards/score/HP/stamina/hack/timer/stars/cloak status with progress bars), touch controls, status message, and overlay screens (floor cleared transition, game over/win).

### Key Design Patterns

- **Facing-based detection cone**: Guards detect the player only when the dot product between their movement direction and the player direction exceeds a threshold (0.12), creating directional awareness that rewards approaching from behind.
- **Alert state escalation**: Detection triggers a 1.1-second alert timer during which the guard chases regardless of facing, simulating a guard who has turned to investigate a sighting.
- **Level-progressive wall layout**: The `blocked()` function takes the current level and conditionally includes additional wall segments for levels 2 and 3, creating more complex navigation without a separate level data structure.
- **Shared stamina resource**: Sprint, cloak, and pulse all draw from the same 100-unit stamina pool that regenerates at 20/s, forcing the player to balance offensive (pulse), defensive (cloak), and mobility (sprint) abilities.
- **Hand-placed entity layout**: Guards, keycards, and walls are manually positioned for each level tier rather than procedurally generated, ensuring balanced difficulty and meaningful patrol patterns.

## Improvement & Refinement Plan

1. **Add sound cue for guard alert state**: Guards switch between patrol and chase silently. Adding a visual or audio indicator (e.g., an exclamation mark above their head when entering alert) would give the player clearer feedback about detection.

2. **Implement guard line-of-sight occlusion**: Guards currently detect through walls as long as the player is in their cone. Adding wall occlusion checks would make stealth more realistic and reward using walls as cover.

3. **Add a minimap**: The play area is larger than what can be easily surveyed. A small minimap showing guard positions and keycard locations would reduce frustration from blind exploration.

4. **Vary keycard collection requirements**: All keycards are equally valuable for meeting the target count. Making some keycards "master keys" worth multiple counts, or requiring specific kind combinations, would add collection strategy.

5. **Extract game logic into internal packages**: The 1657-line single file would benefit from splitting into `internal/types` (Thief, Guard, Keycard, Bullet, Particle structs), `internal/game` (AI, physics, collision, level setup), and `internal/render` (all drawing code).

6. **Add guard patrol variety**: All guards follow simple A-to-B linear patrols. Adding circular patrols, multi-waypoint paths, or guards that pause at waypoints would create more interesting stealth challenges.
