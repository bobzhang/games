# Meteor Miner Convoy 2026

An action-defense game where you pilot a command ship protecting a convoy of mining trucks from incoming meteors across 3 sectors. Shoot meteors to shatter them into collectible ore, collect the ore to bank it or let trucks automatically load it, and repair damaged trucks using banked ore. Each sector has a delivery quota that trucks must fulfill by traversing the screen. The game combines escort defense, resource management, and shooting mechanics with full keyboard, mouse, and touch input support.

The game features 3 progressive sectors with increasing meteor spawn rates, speeds, sizes, and delivery quotas (10/14/18). The player ship has 6 HP with invulnerability frames on hit, fires bullets at 720 units/second consuming 6 energy per shot (energy regenerates at 20/s), and can repair nearby trucks for 2 ore each. Three convoy trucks travel along 3 lanes at sector-dependent speeds. Meteors spawn from above with gravity, have size-dependent HP (1-3) and ore drops (1-3), and threaten both trucks and the player. Trucks that are destroyed respawn after a delay of 10 + level * 2 seconds.

## Build and Run

```bash
moon build --target native raylib_meteor_miner_convoy_2026/
./_build/native/debug/build/raylib_meteor_miner_convoy_2026/raylib_meteor_miner_convoy_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Move the command ship (acceleration-based movement, 420 units/s^2, 290 max velocity)
- **J / Space**: Fire bullets rightward (0.09s cooldown, 6 energy cost)
- **K**: Repair nearest damaged truck within range (costs 2 ore, 0.32s cooldown)
- **R**: Restart the game from Sector 1
- **Touch D-pad**: On-screen directional buttons (lower-left)
- **FIRE button**: On-screen fire button (lower-right)
- **REPAIR button**: On-screen repair button (lower-right)

## How to Play

You pilot the command ship (triangular craft) above 3 convoy lanes. Meteors rain down from the top of the screen, aimed at the lanes where your trucks travel. Your job is to protect the convoy and help it meet delivery quotas.

**Shooting meteors**: Fire bullets rightward with J/Space. Bullets travel at 720 units/second and have a 1.25-second lifespan. Each shot costs 6 energy (max 100, regenerates at 20/s). Meteors have 1-3 HP depending on size. Destroying a meteor drops an ore pickup worth 1-3 units.

**Collecting ore**: Ore drops bounce with gravity and last 10 seconds. Fly over ore to collect it into your ore bank. Ore that lands near a truck is automatically loaded as cargo. Ore in trucks adds to delivery value when the truck reaches the right edge.

**Truck management**: Three trucks travel along the 3 lanes from left to right. When a truck exits the right edge, a delivery is counted, the truck respawns from the left with cargo based on sector level, and you earn 160 + cargo * 24 points. Trucks have HP (4 + level for initial spawn, 3 + level for respawns, max 8). Meteor hits deal 1 damage and reduce cargo. At 0 HP, the truck is destroyed and respawns after 10 + level * 2 seconds.

**Repairing trucks**: When near a damaged truck (within 130 units) with at least 2 ore banked, press K to repair it (+1 HP) for 2 ore and 42 score.

**Sector progression**: Meet the delivery quota (10/14/18 deliveries) within the time limit (140s/160s/185s) to advance. Completing all 3 sectors wins the game. Losing all trucks or running out of time ends the mission.

## Public API Reference

### Package `raylib_meteor_miner_convoy_2026`

> Main entry point and complete game implementation (single-file game).

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width in pixels |
| `sh` | `Int` | `820` | Screen height in pixels |
| `lane_n` | `Int` | `3` | Number of convoy lanes |
| `truck_n` | `Int` | `3` | Number of trucks in the convoy |
| `max_meteors` | `Int` | `120` | Maximum concurrent meteors |
| `max_bullets` | `Int` | `260` | Maximum concurrent bullets |
| `max_ores` | `Int` | `140` | Maximum concurrent ore pickups |
| `max_sparks` | `Int` | `360` | Maximum concurrent spark particles |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Truck` | `x`, `lane`, `hp`, `cargo`, `alive`, `respawn_t` | A convoy truck with horizontal position, lane assignment, health, cargo load, and respawn timer |
| `Meteor` | `x`, `y`, `vx`, `vy`, `r`, `hp`, `ore`, `active` | A falling meteor with position, velocity, radius, health, ore value, and active flag |
| `Bullet` | `x`, `y`, `vx`, `vy`, `ttl`, `active` | A player bullet with position, velocity, time-to-live, and active flag |
| `Ore` | `x`, `y`, `vx`, `vy`, `amount`, `ttl`, `active` | A collectible ore drop with position, velocity, value, and expiration timer |
| `Spark` | `x`, `y`, `vx`, `vy`, `ttl`, `kind`, `active` | A particle effect with position, velocity, lifespan, and visual kind |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between lo and hi bounds |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `sqdist` | `(Float, Float, Float, Float) -> Float` | Returns the squared distance between two points |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Point-in-rectangle test for touch/mouse hit detection |
| `lane_y` | `(Int) -> Float` | Returns the Y coordinate for a given lane (0=560, 1=628, 2=696) |
| `reset_trucks` | `(Array[Truck], Int) -> Unit` | Resets all trucks to starting positions with HP scaled by level |
| `clear_meteors` | `(Array[Meteor]) -> Unit` | Deactivates all meteors |
| `clear_bullets` | `(Array[Bullet]) -> Unit` | Deactivates all bullets |
| `clear_ores` | `(Array[Ore]) -> Unit` | Deactivates all ore pickups |
| `clear_sparks` | `(Array[Spark]) -> Unit` | Deactivates all spark particles |
| `spawn_spark` | `(Array[Spark], Float, Float, Float, Int) -> Unit` | Activates the first inactive spark with position, random velocity scaled by speed, random TTL, and kind |
| `burst` | `(Array[Spark], Float, Float, Int, Float, Int) -> Unit` | Spawns n sparks at a position for explosion/impact effects |
| `spawn_bullet` | `(Array[Bullet], Float, Float, Float, Float) -> Unit` | Spawns a normalized bullet at 720 units/second with 1.25s TTL |
| `spawn_meteor` | `(Array[Meteor], Int) -> Unit` | Spawns a meteor targeting a random lane with speed and size scaled by level |
| `spawn_ore` | `(Array[Ore], Float, Float, Int) -> Unit` | Spawns an ore pickup with upward velocity and 10s TTL |
| `setup_level` | `(Int, Array[Truck], Array[Meteor], Array[Bullet], Array[Ore], Array[Spark]) -> (Int, Float, Float)` | Resets all entities and returns (delivery target, timer, spawn interval) for the given level |
| `alive_truck_count` | `(Array[Truck]) -> Int` | Returns the number of alive trucks |
| `nearest_truck_for_repair` | `(Array[Truck], Float, Float) -> Int` | Returns the index of the nearest damaged truck within 130 units, or -1 |
| `main` | `() -> Unit` | Entry point: initializes 1280x820 window at 60 FPS, pre-allocates all entity pools, runs game loop with physics, combat, truck management, level progression, and rendering |

## Architecture

### Package Structure

```
raylib_meteor_miner_convoy_2026/
├── main.mbt         — Complete game: structs, entity pools, physics, combat, convoy logic, rendering
└── moon.pkg         — Package config with raylib and math imports
```

### Data Flow

1. **Initialization**: `main` pre-allocates object pools (120 meteors, 260 bullets, 140 ores, 360 sparks, 3 trucks). `setup_level` configures the first sector with delivery target, timer, and spawn interval.
2. **Input**: Each frame reads WASD/arrow keys for movement, J/Space for firing, K for repair. Touch D-pad and on-screen FIRE/REPAIR buttons provide alternative input via `inside_rect` hit testing.
3. **Player Physics**: Acceleration-based movement (420 units/s^2) with drag (1.7x), clamped velocity (290 max), and arena boundary enforcement. Energy regenerates at 20/s for firing.
4. **Meteor Spawning**: A jittered spawn timer generates meteors aimed at random lanes with speed and size scaling by level. Meteors experience gravity (20 units/s^2 downward).
5. **Combat**: Bullets check collision against meteors using squared distance. Hits reduce meteor HP; destroyed meteors drop ore. Meteors check collision against the player (with invulnerability frames) and trucks. Truck hits reduce HP and cargo; destroyed trucks enter respawn timers.
6. **Ore Collection**: Ore drops bounce with gravity on the lane floor. Player proximity (24 units) collects ore to bank. Truck proximity (28x18 units) auto-loads ore as cargo.
7. **Truck Convoy**: Trucks travel rightward at sector-dependent speed, boosted slightly by cargo. Reaching the right edge counts as a delivery, earns score, and respawns the truck from the left.
8. **Level Progression**: When deliveries meet the target, the next sector loads with higher quota, longer timer, and faster meteor spawns. Completing Sector 3 wins; losing all trucks or timing out fails.
9. **Rendering**: Draws a space background with twinkling stars, 3 lane tracks with moving sleepers, a refinery building, trucks with cargo labels and HP bars, meteors with size-dependent shading, ore drops, bullets, spark particles, the player ship with invulnerability flash, HUD with HP/energy/timer bars, touch controls, and game-over/victory overlay.

### Key Design Patterns

- **Object pool pattern**: All entity types (meteors, bullets, ores, sparks, trucks) use pre-allocated arrays with `active`/`alive` flags. Spawn functions find the first inactive slot, avoiding allocation during gameplay.
- **Acceleration-based movement**: The player ship uses acceleration + drag physics rather than direct velocity, creating smoother, more realistic-feeling movement with momentum.
- **Lane-based escort defense**: The 3 fixed lanes create a spatial structure that forces the player to prioritize which lane to defend, adding tactical depth to the action gameplay.
- **Resource chain**: Meteors drop ore, ore is collected or auto-loaded onto trucks, trucks deliver cargo for score. This creates a multi-step resource pipeline beyond simple shooting.
- **Level progression via setup function**: `setup_level` returns a tuple of (target, timer, spawn_interval), cleanly separating level configuration from game logic. Only 3 levels exist, with difficulty tuned via these parameters.
- **Invulnerability frames**: After taking damage, the player has 1 second of invulnerability (rendered as a blinking effect) to prevent rapid multi-hit deaths.
- **Touch-first UI**: On-screen D-pad, FIRE, and REPAIR buttons provide full gameplay access for touch/mouse input alongside keyboard controls.

## Improvement & Refinement Plan

1. **Add meteor warning indicators**: Meteors spawn from above with no preview. Adding shadow indicators on the lanes showing where meteors will land would give players time to react and position defensively.

2. **Implement weapon upgrades**: The single rightward-firing bullet does not change. Adding spread shots, faster fire rate, or guided missiles as purchasable upgrades between sectors would add progression depth.

3. **Add truck AI variety**: All trucks move at the same speed and have no autonomy. Adding trucks that slow down when damaged, swerve to avoid visible meteors, or signal for help would make the escort feel more dynamic.

4. **Implement ore magnet ability**: Collecting ore requires flying over each pickup individually. A temporary area-of-effect magnet ability would reduce tedium and create interesting trade-offs between collecting and defending.

5. **Add visual truck customization**: All trucks look identical. Differentiating them by color per lane and adding visual cargo indicators (piled ore, glowing when full) would improve readability.

6. **Implement boss meteors**: All meteors follow the same behavior. Adding periodic large boss meteors that require sustained fire and drop massive ore rewards would create exciting peak moments.

7. **Add sound effects**: The game has no audio. Adding bullet fire, meteor impact, ore collection chimes, truck engine sounds, and alarm klaxons for low truck HP would greatly enhance the experience.
