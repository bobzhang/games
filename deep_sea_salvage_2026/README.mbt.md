# Deep Sea Salvage 2026

Deep Sea Salvage 2026 is an underwater exploration and resource-management game where the player pilots a submarine to collect valuable relics from the ocean floor. The playing field is split into a surface zone (above 116px) and a deep-sea zone below, with distinct water color gradients and faint horizontal depth lines creating a layered oceanic atmosphere.

The core gameplay loop revolves around a risk-reward diving cycle. Relics (gold circles worth 20-90 points) spawn throughout the deep zone, while drifting mines (maroon circles) patrol horizontally. The submarine consumes oxygen at 6 units/second while submerged, and fuel depletes constantly at 2 units/second. Collecting relics adds to a temporary cargo hold, but the value is only permanently banked when the player surfaces -- where oxygen also refills at 24 units/second and fuel regenerates at 20 units/second. This creates a tension between maximizing dive depth and duration versus the risk of running out of resources before surfacing.

The game runs on a 210-second mission timer with new relics spawning every 2.8 seconds and new mines every 4.6 seconds. Three failure conditions exist: hull reaching zero (from mine impacts that deal 10 hull and 6 fuel damage each), fuel depletion, or timer expiry. The goal is to maximize the banked score before the mission ends.

## Build and Run

```bash
moon build --target native deep_sea_salvage_2026/
./_build/native/debug/build/deep_sea_salvage_2026/deep_sea_salvage_2026.exe
```

## Controls

- **W / Up Arrow**: Move submarine up
- **A / Left Arrow**: Move submarine left
- **S / Down Arrow**: Move submarine down
- **D / Right Arrow**: Move submarine right
- **R**: Restart game

## How to Play

Pilot the yellow submarine using WASD or arrow keys. The submarine moves at 210 pixels/second in any direction, clamped within the play area (60px from edges horizontally, 76px from top, 40px from bottom).

Dive below the surface line to find golden relics scattered across the seabed. Touch a relic to collect it into your cargo hold. Cargo value accumulates but is NOT safe -- it is only permanently added to your bank score when you return to the surface (above the water line at y=116). Surfacing also rapidly refills oxygen and fuel.

Avoid red mines that drift horizontally. Mine collisions deal 10 hull damage and drain 6 fuel. When oxygen runs out underwater, the submarine takes continuous hull damage (1 per frame). The game ends when hull, fuel, or the 210-second timer reaches zero.

New relics appear every 2.8 seconds and new mines every 4.6 seconds, so the ocean becomes increasingly populated -- and dangerous -- over time. The strategy is to make efficient deep dives, grab high-value relics, and surface regularly to bank cargo and restore resources.

## Public API Reference

### Package `deep_sea_salvage_2026`

> Single-file game with all logic in main.mbt.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Relic` | `alive`, `x`, `y`, `size`, `value` | Collectible treasure with random position, size (12-22px radius), and value (20-90) |
| `Mine` | `alive`, `x`, `y`, `vx`, `r` | Hazard that drifts horizontally, bouncing off arena edges, with radius 12-20px |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `spawn_relic` | `(Array[Relic]) -> Unit` | Activates one inactive relic with random position and value |
| `spawn_mine` | `(Array[Mine]) -> Unit` | Activates one inactive mine with random position and horizontal drift velocity |
| `reset_relics` | `(Array[Relic]) -> Unit` | Deactivates all relics |
| `reset_mines` | `(Array[Mine]) -> Unit` | Deactivates all mines |

#### Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `sw` | 1160 | Screen width |
| `sh` | 760 | Screen height |
| `surface_y` | 116.0 | Y coordinate of the water surface line |

## Architecture

### Package Structure

```
deep_sea_salvage_2026/
├── main.mbt    — Complete game: structs, spawning, game loop, rendering
└── moon.pkg    — Package config (single main package)
```

This is a single-file game with all state as local variables in `main`. The game loop handles input, resource depletion, entity spawning, collision detection, and rendering sequentially.

### Data Flow

1. **Input**: WASD/Arrow keys read via `@raylib.is_key_down`, converted to a movement vector `(mx, my)` applied at 210 px/s.
2. **Resources**: Oxygen drains at 6/s while submerged (py > surface_y + 20), refills at 24/s at surface. Fuel drains at 2/s always, refills at 20/s at surface. When oxygen reaches 0, hull takes 1 damage per frame.
3. **Spawning**: `relic_tick` and `mine_tick` timers spawn new entities at 2.8s and 4.6s intervals respectively. Mines drift horizontally with velocity bouncing off arena edges.
4. **Collision**: Circle-based distance checks for mine-vs-player (radius = mine.r + 12) and relic-vs-player (radius = relic.size + 12).
5. **Banking**: When py <= surface_y + 20, cargo_value transfers to bank and resets to 0.
6. **Rendering**: Background gradient (sky blue above surface, dark blue below), depth lines, relics (gold circles), mines (maroon circles), submarine (yellow ellipse with orange porthole and gray conning tower), HUD bars, and status messages.

### Key Design Patterns

- **Object Pool Pattern**: Relics (90 slots) and mines (60 slots) use pre-allocated arrays with `alive` flags. Spawning scans for the first inactive slot.
- **Risk-Reward Resource Cycle**: The surface is safe (oxygen/fuel refill, cargo banking) but has no relics. Deep water has treasures but drains resources and has mines.
- **Timer-Based Spawning**: Separate tick timers for relics and mines with fixed intervals create gradually increasing ocean density.
- **Boundary Bounce**: Mines bounce off arena edges by flipping `vx` sign, creating unpredictable patrol patterns.

## Improvement & Refinement Plan

1. **Extract game state into a struct**: The 15+ mutable local variables (px, py, hull, oxygen, fuel, cargo_value, bank, timer, etc.) would be cleaner as a `Game` struct, enabling separation of update and render logic.

2. **Add depth-based relic value scaling**: Currently relic value is uniformly random (20-90) regardless of depth. Making deeper relics worth more would strengthen the risk-reward mechanic and incentivize dangerous dives.

3. **Add visual feedback for cargo banking**: The banking action at the surface only shows a text message. Adding a particle burst or score popup animation when cargo is banked would make the reward moment more satisfying.

4. **Implement mine proximity warning**: Mines have no warning indicator. Adding a pulsing glow or proximity sound cue when mines are nearby would give players more tactical awareness.

5. **Add submarine momentum/inertia**: The submarine currently moves at a fixed speed with instant stop. Adding slight drift and deceleration would create a more realistic underwater movement feel and increase mine-avoidance difficulty.

6. **Scale mine spawn rate with time**: Currently mines spawn at a constant 4.6s interval. Decreasing the interval as the mission progresses would create escalating tension toward the end of the 210-second timer.
