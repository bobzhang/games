# Icebreaker Convoy Command 2026

Icebreaker Convoy Command 2026 is a tactical escort simulation set in Arctic waters where the player pilots an icebreaker ship through dense pack ice, clearing lanes for cargo convoy ships traveling along waypoint routes from a base harbor to an exit harbor. Storms drift across the map, intensifying ice formation and damaging both the player and convoy ships.

The core gameplay loop involves steering the icebreaker ahead of convoy ships, activating the ice cutter (held action) to carve through ice floes of varying hardness, repairing damaged convoy ships within close range, and using sonar pings to scout for dense ice or incoming storms. Convoy ships follow a procedurally generated waypoint route and get stuck on hard ice, taking hull damage and accumulating panic. The player must deliver 34 convoy ships before the 420-second timer expires, while keeping convoy losses below 10 and the icebreaker's hull above zero.

The game features tier-based difficulty scaling (tier increases every 5 deliveries, up to tier 9), a base harbor recharge zone that restores hull and energy, cutter heat management that increases cutting power but also energy consumption, ice refill mechanics that maintain pressure, and full touch/mobile control support alongside keyboard input.

## Build and Run

```bash
moon build --target native raylib_icebreaker_convoy_command_2026/
./_build/native/debug/build/raylib_icebreaker_convoy_command_2026/raylib_icebreaker_convoy_command_2026.exe
```

## Controls

### Keyboard
- **W / Up Arrow**: Move icebreaker up
- **S / Down Arrow**: Move icebreaker down
- **A / Left Arrow**: Move icebreaker left
- **D / Right Arrow**: Move icebreaker right
- **J / Space**: Hold to activate ice cutter (breaks nearby ice, consumes energy, builds heat)
- **L / U**: Repair nearby damaged convoy ships (costs 9 energy, 0.65s cooldown)
- **K / H**: Sonar ping (highlights nearest dense ice or storm, 2.4s cooldown)
- **R / Enter**: Restart from result screen
- **F11**: Toggle fullscreen

### Touch Controls (Mobile)
- **D-Pad (U/L/R/D)**: Directional movement
- **CUT button**: Hold to activate ice cutter
- **FIX button**: Repair nearby convoy ships
- **SCAN button**: Sonar ping

## How to Play

From the title screen, click or press Enter/Space to start the operation. The icebreaker spawns at the base harbor on the left side of the map.

**Objective**: Deliver 34 convoy ships from the BASE harbor to the EXIT harbor within 420 seconds, losing fewer than 10 convoy ships, while keeping your icebreaker intact.

**Ice cutting**: Hold J or Space to activate the cutter. It damages all ice within a 44-unit radius of the ship. Cutting builds cutter heat (0 to 1.0), which increases impact power (26 + heat*55 per second) but also energy drain (6 + heat*9 per second). When not cutting, heat cools at 1.7/s.

**Convoy behavior**: Convoy ships spawn from the base harbor and follow 8 waypoints to the exit. When blocked by hard ice (hardness > 20), they stop, accumulate stuck time, take hull damage, and build panic. Ships stuck for over 4.5 seconds take accelerated damage. When a convoy's HP reaches zero, it sinks (costing 60 score). Successfully delivered convoys earn cargo*9 + remaining HP in score.

**Storms**: Storm cells drift across the map with pulsing intensity. Ships inside a storm's radius take damage proportional to intensity and proximity, and convoy ships are slowed. Storms also drain the icebreaker's energy.

**Repair**: Press L/U near damaged convoy ships (within 90 units) to repair them for 26 HP each, costing 9 energy with a 0.65s cooldown.

**Sonar**: Press K/H to ping for the nearest dense ice chunk or storm. A visual indicator appears for 2.1 seconds. Sonar has a 2.4s cooldown.

**Base harbor recharge**: Returning to the base harbor area (left side) restores energy at 20/s and hull at 7.2/s.

**Failure conditions**: Timer reaches zero, 10+ convoy ships sunk, or icebreaker hull reaches zero.

**Tier system**: Tier increases by 1 for every 5 deliveries (max tier 9). Higher tiers spawn convoys faster, with more cargo, and storms become more intense and frequent.

## Public API Reference

### Package `raylib_icebreaker_convoy_command_2026`

> Single-file game with all logic, rendering, and state in main.mbt.

This game uses a single-file architecture with no public API. All structs, functions, and game state are package-private within `main.mbt`.

#### Structs (package-private)

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `PlayerShip` | `x`, `y`, `vx`, `vy`, `heading`, `hull`, `energy`, `cutter_heat`, `cutter_cd`, `repair_cd`, `sonar_cd`, `sonar_t`, `ping_x`, `ping_y`, `wake_t` | The player's icebreaker ship with position, velocity, resources, and ability cooldowns |
| `IceChunk` | `active`, `x`, `y`, `vx`, `vy`, `radius`, `hard`, `crack_t`, `tone` | An ice floe with position, size, hardness (HP), and visual state |
| `ConvoyShip` | `active`, `x`, `y`, `vx`, `vy`, `speed`, `hp`, `cargo`, `route_i`, `stuck_t`, `panic`, `blink_t`, `id` | A convoy cargo ship following waypoints with HP, cargo value, and stuck/panic state |
| `StormCell` | `active`, `x`, `y`, `vx`, `vy`, `radius`, `intensity`, `life`, `phase` | A drifting storm that damages ships and drains energy |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | A visual effect particle |
| `Waypoint` | `x`, `y` | A position along the convoy route |

#### Key Functions (package-private)

| Function | Description |
|----------|-------------|
| `init_route` | Generates a procedural 8-waypoint route across the map |
| `setup_ice_field` | Fills the ice array with randomly placed chunks, avoiding route lanes |
| `spawn_convoy` | Creates a new convoy ship at the route start |
| `spawn_storm` | Creates a new storm cell entering from a random map edge |
| `carve_ice_with_cutter` | Applies cutter damage to ice within range, returns cleared count and score |
| `repair_nearby_convoys` | Heals convoy ships within 90 units of the player |
| `scan_hazards` | Finds the nearest dense ice or storm for sonar display |
| `update_ice` | Drifts ice chunks, decays hardness, returns total hazard sum |
| `update_storms` | Moves storm cells with pulsing velocity |
| `update_player_damage_from_hazards` | Calculates and applies damage from storms and ice collisions to the player |
| `update_convoys` | Advances convoy ships along route, handles blocking/damage/delivery/sinking |

## Architecture

### Package Structure

```
raylib_icebreaker_convoy_command_2026/
├── main.mbt    — All game logic, rendering, and state in a single file
└── moon.pkg    — Package config, imports (raylib, core/math)
```

This is a single-file game where all entity definitions, utility functions, game logic, rendering, and the main loop are contained in `main.mbt`. Local variables in `main` hold the game state (arrays of entities, player ship, timers, scores) and a nested `reset_run` closure reinitializes everything.

### Data Flow

1. The main loop captures mouse/keyboard/touch input and maps it to boolean movement and action flags.
2. Player physics applies acceleration (430 units/s^2), drag (5.8/s), and speed capping (240 max).
3. `carve_ice_with_cutter` damages nearby ice when the cutter is held. `repair_nearby_convoys` heals convoy ships on press. `scan_hazards` activates sonar on press.
4. `update_storms` and `update_ice` advance environmental entities. `update_player_damage_from_hazards` applies collision and storm damage. `update_convoys` handles convoy pathfinding, blocking, and delivery/sinking.
5. Win/lose conditions are checked: delivered >= 34 (win), timer <= 0 or sunk >= 10 or hull <= 0 (lose).
6. Rendering draws ocean, route, harbors, storms, ice, convoys, player, sonar ping, particles, HUD panel, touch controls, messages, and state overlays.

### Key Design Patterns

- **Single-file monolith**: All code in one file with package-private structs, using closures (`reset_run`) for state reset.
- **Object pool pattern**: Ice (260), convoys (26), storms (18), and particles (920) are pre-allocated arrays with active flags.
- **Procedural route generation**: `init_route` creates a zigzag waypoint path with random vertical offsets, and `setup_ice_field` avoids placing ice directly on the route.
- **Tier-based difficulty scaling**: Tier derived from deliveries affects convoy spawn rate, cargo size, storm intensity, storm frequency, and ice chunk falling speed.
- **Resource management trio**: Hull (health), energy (fuel for cutter/repair/movement), and cutter heat (power vs. cost tradeoff) create interacting resource pressures.
- **Harbor recharge zone**: The base harbor area provides passive hull and energy regeneration, incentivizing strategic retreats.

## Improvement & Refinement Plan

1. **Refactor into internal packages**: The 2500+ line `main.mbt` would benefit from splitting into `types/`, `game/`, and `render/` packages. The `PlayerShip`, `IceChunk`, `ConvoyShip`, `StormCell` structs belong in a types module, and the update/draw functions in separate game/render modules.

2. **Use enums for game state and particle kinds**: The `state` variable uses magic integers (0=menu, 1=play, 2=win, 3=lose) and particle kinds are 0/1/2 integers. Proper enums would improve readability and enable exhaustive matching.

3. **Add ice regrowth near storms**: Currently ice refills when count drops below 38, spawning random new chunks. Storms could spawn new ice within their radius, creating a more thematic connection between hazards.

4. **Extract convoy pathfinding into a reusable function**: `update_convoys` is a large function (~120 lines) that handles movement, blocking detection, storm slowdown, damage, delivery, and sinking. Breaking this into smaller helper functions would improve maintainability.

5. **Add convoy ship variety**: All convoy ships have the same visual representation and differ only in speed and cargo. Adding ship size classes with different HP/speed/cargo tradeoffs would add strategic depth to escort prioritization.

6. **Implement energy regeneration from ice clearing**: Currently energy only recharges at the base harbor. Rewarding small energy gains for destroying ice would reduce the need for frequent harbor trips and keep the action flowing.

7. **Add sound effects for cutter, sonar, repair, and delivery**: The game has no audio despite being a highly action-oriented title. Key moments like ice shattering, sonar pings, repair completion, and convoy delivery would benefit greatly from audio feedback.
