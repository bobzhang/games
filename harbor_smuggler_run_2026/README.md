# Harbor Smuggler Run 2026

A stealth-action game where you pilot a smuggler boat through patrol-infested waters, collecting floating crates and delivering them to the drop zone before dawn.

## Build and Run

```bash
cd examples && moon build --target native harbor_smuggler_run_2026/
cd examples && ./_build/native/debug/build/harbor_smuggler_run_2026/harbor_smuggler_run_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Steer the boat
- **J or Space**: Turbo boost (costs fuel)
- **K**: Stealth cloak (reduces detection range, costs fuel)
- **R**: Restart game
- **On-screen touch buttons**: Also available for mobile-style input

## How to Play

Navigate the dark harbor waters across 3 night missions. Pick up floating cargo crates (worth 1-3 value) and deliver them to the DROP zone on the right side. Patrol boats detect you within a radius and give chase -- use stealth cloak to shrink detection range or turbo boost to ram through them at high speed. Meet the delivery quota each night before the timer runs out. Fuel regenerates slowly but is consumed by boost and stealth abilities.

## Public API Reference

### Package `harbor_smuggler_run_2026`

> Main entry point.

The `main` function initialises a 1280x820 window, creates all entity arrays at fixed capacity, sets up level state via `setup_level`, and runs the frame loop that handles input, physics, patrol AI, cargo delivery, and rendering.

#### Types

| Type | Description |
|------|-------------|
| `Smuggler` | Player-controlled boat; tracks position, velocity, HP, fuel, carried cargo value, turbo/stealth/hit/flash/delivery cooldown timers. |
| `Patrol` | Enemy patrol vessel; tracks position, velocity, base speed, detection radius, type (0-2), alert timer, and activation flag. |
| `Crate` | Floating cargo item; stores position, velocity, point value, and activation flag. |
| `Particle` | Short-lived visual spark; stores position, velocity, time-to-live, visual kind, and activation flag. |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to the inclusive `[lo, hi]` range. |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float. |
| `sqdist` | `(Float, Float, Float, Float) -> Float` | Returns the squared Euclidean distance between two points. |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests whether a float point lies inside an integer-defined axis-aligned rectangle. |
| `clear_patrols` | `(Array[Patrol]) -> Unit` | Deactivates and zeroes all patrol boat slots. |
| `clear_crates` | `(Array[Crate]) -> Unit` | Deactivates and zeroes all crate slots. |
| `clear_particles` | `(Array[Particle]) -> Unit` | Deactivates and zeroes all particle slots. |
| `spawn_particle` | `(Array[Particle], Float, Float, Float, Int) -> Unit` | Finds the first inactive particle slot and initialises it with random velocity scaled by `speed`. |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Emits `n` particles at the given position by calling `spawn_particle` repeatedly. |
| `reset_player` | `(Smuggler) -> Unit` | Resets all player fields to their starting position and default values. |
| `spawn_patrol` | `(Array[Patrol], Int, Float) -> Unit` | Spawns a patrol boat from a random side with speed and detection scaled to the current level. |
| `spawn_crate` | `(Array[Crate], Int, Float) -> Unit` | Spawns a cargo crate at a random lane position with value weighted by level. |
| `setup_level` | `(Int, Smuggler, Array[Patrol], Array[Crate], Array[Particle]) -> (Int, Float, Float, Float)` | Resets all entities and returns `(quota, timer, patrol_cd, crate_cd)` for the given level. |
| `main` | `() -> Unit` | Entry point: initialises Raylib, allocates arrays, runs the game loop, and closes on exit. |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width in pixels. |
| `sh` | `Int` | `820` | Screen height in pixels. |
| `water_top` | `Float` | `122.0` | Top edge of the navigable water area. |
| `water_bottom` | `Float` | `760.0` | Bottom edge of the navigable water area. |
| `max_patrol` | `Int` | `24` | Maximum number of simultaneous patrol boats. |
| `max_crates` | `Int` | `56` | Maximum number of simultaneous cargo crates. |
| `max_particles` | `Int` | `520` | Maximum number of simultaneous particles. |

## Architecture

All game logic resides in `main.mbt`. Key design patterns:
- Fixed-capacity arrays for all entity types (patrols, crates, particles) with linear-scan slot reuse avoid per-frame heap allocation.
- The `setup_level` function returns a tuple of level parameters `(quota, timer, patrol_cd, crate_cd)` so each of the 3 night missions has distinct difficulty without branching in the update loop.
- Patrol AI uses a detection radius that shrinks by 58% when the player activates stealth cloak, and patrols switch from drift movement to player-chasing when the distance falls within range.
- Turbo boost multiplies acceleration by 1.32 and raises the speed cap from 272 to 360 px/s; ramming a patrol while boosting at speed > 220 destroys the patrol instead of taking damage.
- Fuel is a shared resource consumed by both boost and stealth, regenerating at 16 units/s up to a maximum of 100.
- Delta-time updates capped at 50 ms prevent tunnelling at low frame rates.
- A `transition_t` timer separates night completion from level load, showing a "NIGHT CLEAR" overlay before advancing.

## Improvement & Refinement Plan

1. Replace the flat boolean `over`/`won` state with a `GameState` enum to make state transitions more readable.
2. Extract the large patrol AI block into a dedicated `update_patrol` function for clarity and independent testability.
3. Add a mini-map or compass indicator showing patrol positions relative to the player to give more strategic depth.
4. Introduce a persistent leaderboard across the 3 nights using Raylib's storage API so players can compare mission scores.
5. Vary patrol boat visuals per `kind` (0, 1, 2) more distinctly; currently all three share the same triangle shape and differ only in colour.
6. Add audio effects for turbo burst, stealth activation, and patrol intercept using Raylib's audio API.
7. Allow partial cargo loss on intercept to scale with cargo held rather than always losing exactly 1 unit, making high-cargo runs riskier.
