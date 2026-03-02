# Drone Delivery 2026

Drone Delivery 2026 is a top-down arcade delivery game set over a stylized city grid. The player pilots a drone through a 1120x740 window, picking up packages from randomly placed pickup points (marked "P") and delivering them to drop-off points (marked "D"), all while dodging bouncing shock orbs that spawn every 0.55 seconds.

The core gameplay loop is a time-pressure delivery circuit: fly to the pickup, grab the package (which adds 7 seconds to the timer, capped at 99), then navigate to the drop-off while avoiding the growing field of shock orbs. Each successful delivery awards 120 + combo*20 points and adds 4 seconds. Getting hit by a shock orb resets the combo, subtracts 40 points, drains 9 battery, and adds 20 heat. The game ends when the 90-second timer expires, battery reaches zero, or heat reaches 100 (overheating).

Resource management is central: the drone has battery that drains at 8/s normally or 17/s in turbo mode, and a heat gauge that rises at 7.5/s normally or 18/s in turbo (offset by a constant 9/s cooling). Turbo mode (Space/J) increases speed from 250 to 370 units/s but accelerates both resource depletion rates, creating a risk-reward tradeoff for every delivery run.

## Build and Run

```bash
moon build --target native raylib_drone_delivery_2026/
./_build/native/debug/build/raylib_drone_delivery_2026/raylib_drone_delivery_2026.exe
```

## Controls

- **W / Up Arrow**: Move drone up
- **S / Down Arrow**: Move drone down
- **A / Left Arrow**: Move drone left
- **D / Right Arrow**: Move drone right
- **Space / J**: Turbo mode (370 speed, higher battery drain and heat gain)
- **R**: Restart game

## How to Play

Fly the drone to the green circle marked "P" to pick up a package. The drone body turns gold when carrying a package. Navigate to the orange circle marked "D" to complete the delivery. Each delivery increases your combo counter by 1, and the score gained is 120 + combo*20, so maintaining a streak is critical for high scores.

Shock orbs (cyan circles) spawn every 0.55 seconds at random positions and bounce off screen edges. Colliding with one within a 26-unit radius resets your combo to zero, deducts 40 points, drains 9 battery, and adds 20 heat. The orb is destroyed on contact.

Watch your battery gauge (green bar) and heat gauge (red bar). Battery drains faster in turbo mode (17/s vs 8/s). Heat rises faster in turbo (net +9/s vs net -1.5/s). If battery hits zero, the shift ends. If heat hits 100, the drone overheats and the shift ends. The drone also earns passive score proportional to distance flown (speed * dt * 0.02).

The 90-second timer counts down continuously. Picking up a package adds 7 seconds; completing a delivery adds 4 seconds (both capped at 99). When time runs out, the game displays "Shift ended." Press R to restart.

## Public API Reference

### Package `raylib_drone_delivery_2026`

> Main entry point and entire game implementation (single-file architecture).

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1120` | Screen width in pixels |
| `sh` | `Int` | `740` | Screen height in pixels |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Orb` | `alive`, `x`, `y`, `vx`, `vy` | A bouncing shock orb hazard |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `spawn_orb` | `(Array[Orb], Float, Float) -> Unit` | Spawns a new orb at the given position with random velocity (-180 to 180) |
| `reset_orbs` | `(Array[Orb]) -> Unit` | Deactivates all orbs in the pool |
| `random_point` | `(Int) -> (Float, Float)` | Generates a random screen position with the given margin from edges |
| `dist_sq` | `(Float, Float, Float, Float) -> Float` | Squared distance between two 2D points |

## Architecture

### Package Structure

```
raylib_drone_delivery_2026/
├── main.mbt              -- Entry point, game loop, all logic and rendering
└── moon.pkg              -- Package config, imports raylib
```

This is a single-file game with all code in `main.mbt`. The main function sets up an array of 110 orb slots, initializes game state as local variables, and runs a 60 FPS game loop.

### Data Flow

Each frame begins with delta-time capping at 50ms. If not in game-over state, input is sampled for movement keys and turbo. The drone position is updated with clamping to screen bounds. Battery and heat are updated based on turbo state. Orbs spawn on a 0.55-second tick, move with velocity, bounce off edges, and check collision against the drone (26-unit radius). Package pickup and delivery are checked via distance tests (28-unit radius). Passive score accrues from distance traveled. Rendering draws city block backgrounds, pickup/drop-off markers, orbs, the drone with rotor lines, HUD bars, and the message bar.

### Key Design Patterns

- **Object pool pattern**: Orbs use a 110-element `Array` with `alive` flags; `spawn_orb` finds the first inactive slot.
- **Resource tension**: Battery and heat create opposing pressures -- turbo drains battery faster but generates more heat, while normal flight is slower but sustainable. The player must balance speed against resource margins.
- **Timer extension mechanic**: Both pickup and delivery extend the countdown timer, rewarding efficient routing with more play time.
- **Single-file simplicity**: The entire game fits in one file with no internal packages, appropriate for the game's modest scope.

## Improvement & Refinement Plan

1. **Extract game state into a struct**: All state lives as `let mut` locals in `main`. A `Game` struct would enable cleaner function signatures and make it possible to break `main` into `update` and `draw` functions.

2. **Add difficulty scaling over time**: Currently orb spawn rate (0.55s) and speeds (-180 to 180) are fixed. Scaling these with deliveries completed or elapsed time would prevent the game from plateauing.

3. **Implement a charging station mechanic**: Battery has no way to recharge during gameplay. Adding battery recharge pads at fixed or rotating locations would introduce routing decisions and reward map awareness.

4. **Visual feedback for turbo mode**: The drone body changes color when carrying a package but has no visual indicator for turbo activation. Adding a speed trail or glow effect would communicate turbo state to the player.

5. **Add orb variety**: All orbs behave identically. Introducing different orb types (faster, homing, larger radius) would increase tactical depth.

6. **Prevent pickup/drop-off overlap**: `random_point` generates positions independently for pickup and drop-off. They could spawn very close together, making a delivery trivially easy. Adding a minimum distance check would ensure meaningful travel between points.
