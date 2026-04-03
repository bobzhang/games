# River Raid 2026

A vertical-scrolling shoot-em-up inspired by the Atari classic River Raid, built with MoonBit and raylib. The player pilots a small aircraft up a winding river corridor, shooting enemies and collecting fuel crates to stay airborne. The river bends dynamically with randomized center shifts and curve adjustments every 1.15 seconds, creating an ever-changing flight path.

The core gameplay loop revolves around three simultaneous challenges: navigating the narrowing river banks (collision deals 8 HP damage), shooting down drones and gunboats for score, and managing a constantly depleting fuel gauge. Three enemy types populate the river -- fast-weaving drones worth 30 points, player-tracking gunboats worth 55 points with 2 HP, and gold fuel crates that restore fuel on contact or when shot. Speed increases with distance traveled, raising both the challenge and the rate of fuel consumption.

The game is implemented as a single-file architecture with object pool patterns for bullets and enemies, each pre-allocated at 140 slots. All game state is managed via local mutable variables in the main function, making it a compact but complete action game.

## Build and Run

```bash
moon build --target native river_raid_2026/
./_build/native/debug/build/river_raid_2026/river_raid_2026.exe
```

## Controls

- **W / Up Arrow**: Move aircraft upward
- **S / Down Arrow**: Move aircraft downward
- **A / Left Arrow**: Move aircraft left
- **D / Right Arrow**: Move aircraft right
- **Space / J**: Fire bullets (auto-fire while held, 0.11s cooldown)
- **R**: Restart mission

## How to Play

Fly your aircraft up a winding river, staying within the blue water channel bounded by brown banks on either side. The river scrolls downward automatically at a base speed of 160 units/s, increasing by 8 units/s for every 600 meters of distance traveled.

**Movement**: The aircraft moves at 280 units/s horizontally and 230 units/s vertically. Vertical position is clamped between y=420 (upper limit) and y=676 (near bottom of screen), preventing the player from flying too far ahead or behind.

**Fuel management**: Fuel drains at 7.5 units per second. Shooting a fuel crate adds 10 fuel, while flying into one adds 24 fuel (capped at 100). Running out of fuel ends the mission.

**Enemies**: Drones (red triangles) weave horizontally within the river at 90 units/s downward. Gunboats (maroon rectangles) track the player's x-position and move at 70 units/s downward with 2 HP. Fuel crates (gold squares marked "F") drift at 40 units/s downward. Enemy spawning occurs every 0.45 seconds with a 58% chance of drones, 28% chance of gunboats, and 14% chance of fuel crates.

**Combat**: Bullets travel upward at 620 units/s. Bullet-enemy collision uses a radius of 18 pixels. Player-enemy collision uses a radius of 26 pixels and deals 16 HP damage for drones/gunboats.

**Bank collision**: Hitting a river bank deals 8 HP damage with a 0.35-second invulnerability cooldown. The player is pushed back to the bank edge.

**Lose conditions**: HP reaches zero (aircraft destroyed) or fuel reaches zero (out of fuel).

## Public API Reference

### Package `river_raid_2026`

> Main entry point and complete game implementation in a single file.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1100` | Screen width in pixels |
| `sh` | `Int` | `720` | Screen height in pixels |
| `river_half_width` | `Float` | `180.0` | Half-width of the river channel |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Bullet` | `alive`, `x`, `y`, `vy` | A projectile fired by the player |
| `Enemy` | `alive`, `kind`, `x`, `y`, `vx`, `vy`, `hp` | An enemy entity (drone, gunboat, or fuel crate) |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `river_center_at` | `(Int, Float, Float) -> Float` | Calculates river center x-position at a given y coordinate using center offset and curve |
| `left_bank` | `(Int, Float, Float) -> Float` | Returns the left bank x-position at a given y coordinate |
| `right_bank` | `(Int, Float, Float) -> Float` | Returns the right bank x-position at a given y coordinate |
| `spawn_bullet` | `(Array[Bullet], Float, Float) -> Unit` | Allocates a bullet from the pool at the given position |
| `spawn_enemy` | `(Array[Enemy], Int, Float, Float) -> Unit` | Allocates an enemy from the pool with kind-dependent stats |
| `reset_bullets` | `(Array[Bullet]) -> Unit` | Deactivates all bullets in the pool |
| `reset_enemies` | `(Array[Enemy]) -> Unit` | Deactivates all enemies in the pool |
| `main` | `() -> Unit` | Entry point: window init, game loop, input handling, physics, rendering |

## Architecture

### Package Structure

```
river_raid_2026/
├── main.mbt              -- Complete game: entry point, types, logic, rendering
└── moon.pkg              -- Package config with raylib import
```

This is a single-file game. All type definitions, game logic, input handling, physics, collision detection, and rendering are contained in `main.mbt`. Game state is managed through local mutable variables in the `main` function rather than a centralized game struct.

### Data Flow

1. **Input**: Movement keys (WASD/Arrows) are polled each frame via `is_key_down` and combined into a movement vector. Fire input (Space/J) checks a cooldown timer before spawning bullets via `spawn_bullet`. Restart (R) resets all state variables and clears object pools.

2. **River generation**: Every 1.15 seconds, `river_center` shifts by a random amount (-60 to +60, clamped to 250-850) and `river_curve` adjusts (-40 to +40, clamped to +/-130). The `river_center_at` function interpolates the river center at any y-coordinate using the current center and curve values.

3. **Enemy behavior**: Drones weave horizontally within the river banks. Gunboats chase the player's x-position at 58 units/s. Fuel crates drift straight down. All enemies are clamped within the river banks and scroll downward with the river.

4. **Collision**: Bullet-enemy collisions use squared-distance checks against an 18-pixel radius. Player-enemy collisions use a 26-pixel radius. Bank collisions check the player's x against `left_bank` and `right_bank` at the player's y-position.

5. **Rendering**: The river is drawn scanline-style in 4-pixel horizontal strips. Enemies are drawn as triangles (drones), rectangles with turrets (gunboats), or labeled squares (fuel crates). The player is a sky-blue triangle with white outline. HUD shows score, distance, HP bar, and fuel bar.

### Key Design Patterns

- **Object pool pattern**: Both bullets and enemies use pre-allocated arrays of 140 elements with `alive` flags. Spawning scans for the first inactive slot.
- **Single-file architecture**: All code lives in one file with no internal packages, making it simple to read but limiting separation of concerns.
- **Implicit state machine**: Game state (playing vs game over) is tracked via a single `over` boolean rather than an enum.
- **Scanline river rendering**: The river is drawn as horizontal strips every 4 pixels, with bank positions calculated per-row via `left_bank`/`right_bank`, creating a smooth curving channel.
- **Delta-time clamped updates**: Frame time is clamped to 0.05s maximum to prevent physics tunneling on frame spikes.

## Improvement & Refinement Plan

1. **Extract a Game struct**: All game state is currently spread across local `mut` variables in `main`. Grouping them into a `Game` struct would improve code organization and enable passing state to helper functions more cleanly.

2. **Add an explicit GameState enum**: The `over` boolean and `msg` string informally track game state. Replacing these with a proper enum (`Title`, `Play`, `GameOver`) would make state transitions clearer and enable a title screen.

3. **Implement enemy bullets**: Gunboats (`kind == 1`) track the player but cannot shoot back. Adding return fire from gunboats would increase tactical depth, requiring the player to dodge while managing fuel.

4. **Add progressive difficulty scaling**: Currently `scroll_speed` increases linearly with distance, but enemy spawn rate and composition remain constant at 0.45s intervals. Tying spawn frequency and enemy mix to distance milestones would create natural difficulty ramps.

5. **Split rendering into a separate package**: The 130+ lines of drawing code in `main.mbt` could be extracted to an `internal/render` package, following the pattern used by other games in this repository and improving maintainability.

6. **Add a scoring multiplier system**: Consecutive kills without taking damage could build a score multiplier. This would reward aggressive play and skilled maneuvering, adding depth to the scoring beyond flat per-kill values of 30/55/20 points.

7. **Improve fuel crate collision feedback**: Shooting a fuel crate (+10 fuel) gives less fuel than flying through it (+24 fuel), but there is no visual feedback distinguishing the two. A different particle effect or message for each would clarify the mechanic.
