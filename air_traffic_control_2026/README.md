# Air Traffic Control 2026

A minimalist air traffic management simulation where you oversee three parallel runways, toggling them open or closed to guide a steady stream of descending aircraft to safe landings. The game tests your multitasking and timing as planes approach with limited fuel and runways require cooldown periods between landings.

Planes spawn every 0.7 seconds at the top of the screen, each assigned to a random runway with a random descent speed (65-110 px/s) and limited fuel (16-26 seconds). A plane lands safely when it reaches the landing zone (y >= 560) on an open, non-busy runway. If a plane reaches y >= 650 on a closed or busy runway, it crashes. Running out of fuel also destroys the plane. The player's only control is toggling runways open/closed with the number keys, creating a rhythm of opening runways just in time for approaching planes while closing them to prevent collisions during the 2-second busy cooldown after each landing.

A stress meter adds tension: near-collisions between planes on the same runway (within 48px vertical distance) continuously raise stress, and failures spike it. If stress reaches 100, the player loses a life. The game ends when all 5 lives are lost.

## Build and Run

```bash
moon build --target native air_traffic_control_2026/
./_build/native/debug/build/air_traffic_control_2026/air_traffic_control_2026.exe
```

## Controls

- **1**: Toggle Runway 1 open/closed
- **2**: Toggle Runway 2 open/closed
- **3**: Toggle Runway 3 open/closed
- **R**: Restart the game

## How to Play

Planes appear at the top of the screen and descend toward one of three runways. Each plane shows its remaining fuel as a number beside it (turns red when fuel < 6). Your job is to ensure runways are open when planes arrive at the landing zone.

**Landing rules:**
- A plane lands safely when it reaches y=560 if its runway is open AND not busy (no recent landing). Safe landings award 70 + remaining fuel points.
- After a safe landing, the runway becomes busy for 2 seconds (shown as an orange zone at the bottom).
- If a plane reaches y=650 on a closed or busy runway, it crashes: -1 life, -45 score, +25 stress.
- If a plane's fuel reaches 0, it is lost: -1 life, +22 stress.

**Stress system:**
- Stress decays at 4.0/s naturally.
- Each safe landing adds 4 stress. Each crash adds 25 stress. Each fuel-out adds 22 stress.
- Planes on the same runway within 48px of each other add 22 stress/s continuously.
- If stress reaches 100, you lose a life and stress resets.

**Game over:** When lives reach 0, the tower closes. Press R to restart.

## Public API Reference

### Package `air_traffic_control_2026`

> Single-file game with all logic and rendering in `main.mbt`.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1160` | Screen width |
| `sh` | `Int` | `740` | Screen height |
| `runway_count` | `Int` | `3` | Number of parallel runways |

#### Structs (package-private)

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Plane` | `alive`, `runway`, `x`, `y`, `vy`, `fuel` | An aircraft descending toward an assigned runway with limited fuel |

#### Functions (package-private)

| Function | Signature | Description |
|----------|-----------|-------------|
| `runway_x` | `(Int) -> Float` | Returns the X coordinate of a runway by index (250 + idx * 330) |
| `spawn_plane` | `(Array[Plane]) -> Unit` | Activates the first inactive plane with random runway, position, speed, and fuel |
| `reset_planes` | `(Array[Plane]) -> Unit` | Deactivates all planes in the pool |
| `main` | `() -> Unit` | Entry point: 1160x740 window at 60 FPS, game loop with spawn/update/render |

## Architecture

### Package Structure

```
air_traffic_control_2026/
├── main.mbt    — All game logic, rendering, and entry point (~300 lines)
└── moon.pkg    — Package config with raylib import
```

This is a compact single-file game. The code is structured linearly: constants and struct at the top, spawn/reset utility functions, then the `main` function containing all game state as local variables, the game loop, update logic, and rendering.

### Data Flow

1. **Spawn**: Every 0.7 seconds, `spawn_plane` finds the first inactive slot in the 100-plane pool, assigns a random runway (0-2), random X offset near the runway center, random descent speed, and random fuel.

2. **Update**: Each frame, planes descend by `vy * dt` and burn fuel. When a plane reaches y=560, the game checks the runway state. If open and not busy, the plane lands safely. If the plane reaches y=650 without landing, it crashes. Fuel-out planes are removed immediately.

3. **Stress calculation**: After updating all planes, a nested loop checks all pairs of active planes on the same runway. If their vertical distance is < 48px, stress increases proportionally to dt. Stress decays at 4.0/s.

4. **Render**: The scene draws a sky background, green ground, three runway rectangles with center lines and status indicators, plane triangles with fuel labels, a HUD panel with score/landed/missed/lives, a stress bar, and a message strip at the bottom. Game over overlay shows when lives reach 0.

### Key Design Patterns

- **Object pool**: 100 pre-allocated `Plane` structs with `alive` flags. `spawn_plane` scans linearly for the first inactive slot.
- **Toggle-based gameplay**: The only player interaction is toggling three boolean flags (`runway_open`), creating a simple but engaging decision space.
- **Busy cooldown**: Each runway has a `runway_busy` timer (2 seconds after landing) that prevents back-to-back landings, forcing the player to stagger traffic.
- **Stress as a secondary health system**: Stress acts as a continuous penalty for poor management, decaying naturally but spiking from failures and near-misses, adding a life cost when it overflows.

## Improvement & Refinement Plan

1. **Plane reassignment mechanic**: Currently planes are locked to their assigned runway. Adding the ability to redirect a plane to a different runway (e.g., click on a plane then press 1/2/3) would add strategic depth and reduce frustration from impossible scenarios.

2. **Visual approach path**: Planes descend with no visual indication of their landing zone. Drawing a dotted approach line from each plane to its runway's landing zone would help the player anticipate timing.

3. **Difficulty progression**: The spawn rate (0.70s) and plane parameters are constant throughout the game. Gradually decreasing spawn interval and increasing speed ranges over time would create a natural difficulty curve.

4. **Collision detection between planes**: The near-collision check only increases stress but never causes actual crashes. Adding a true collision check (when two planes on the same runway overlap) that destroys both would raise the stakes for mismanaged traffic.

5. **Wind or weather system**: All planes descend at a fixed `vy`. Adding a random wind factor that shifts planes horizontally or changes their speed would increase variability and require more active management.

6. **Sound effects**: The game has no audio. Adding a landing confirmation sound, fuel warning beep, crash sound, and ambient tower chatter would significantly improve the atmosphere and player feedback.
