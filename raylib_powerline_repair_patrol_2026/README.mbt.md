# Powerline Repair Patrol 2026

A top-down action-strategy game where the player pilots a patrol craft across a city power grid, racing between transmission towers to repair line faults before their deadlines expire. The game is set in a stormy urban landscape with 10 transmission towers connected by power lines, a supply depot, a substation, roaming storm cells, wind tunnels, and supply drops scattered across the map.

The core gameplay loop involves three interleaved systems: resource management (collecting wire and fuse supplies from the depot or field drops), navigation hazards (wind tunnels that push the craft off course and storm cells that deal hull damage and stress towers), and fault repair (approaching damaged towers and spending wire/fuse resources to fix faults for score and grid health). A combo system rewards consecutive successful repairs, and a pulse ability lets the player weaken nearby storms and extend fault deadlines. The game runs on a 430-second timer with a score target of 9,800 points and a minimum 40% grid health to win.

The game features full touch/mobile support with an on-screen D-pad and circular action buttons, plus comprehensive object pool management for faults (18 slots), storms (26 slots), supply drops (18 slots), and particles (1,200 slots). The wave difficulty system scales fault spawn rates, deadlines, and storm frequency based on the player's score progression.

## Build and Run

```bash
moon build --target native raylib_powerline_repair_patrol_2026/
./_build/native/debug/build/raylib_powerline_repair_patrol_2026/raylib_powerline_repair_patrol_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Steer the patrol craft (hold for continuous movement)
- **Space / J** (hold): Boost -- increases acceleration and max speed, consumes extra battery
- **L / U**: Action -- load supplies at depot, service at substation, or repair nearest fault at a tower
- **K / H**: Pulse -- fires a grid pulse that weakens nearby storms and extends nearby fault deadlines (costs 8 battery, 9s cooldown)
- **F11**: Toggle fullscreen
- **R / Enter**: Restart (on game over/win screen)
- **On-screen D-pad**: Touch/mouse movement (bottom-left)
- **BOOST button**: Touch/mouse boost (bottom-right area)
- **ACT button**: Touch/mouse action
- **PULSE button**: Touch/mouse pulse

## How to Play

You patrol a city power grid as a repair craft. Faults spawn on the 10 transmission towers at increasing rates, each with a severity level (1-3), resource requirements (wire and fuses), a countdown deadline, and a point reward. Your job is to fly to the supply depot (bottom-left) to load wire and fuses, then navigate to damaged towers and press the action key within 90 pixels to repair them.

**Resource Management**: The depot fully loads your wire (capacity 12) and fuse (capacity 8) inventory. The substation (bottom-right) restores battery and hull. Supply drops appear on the field every 10-18 seconds offering wire bundles, fuse packs, or battery cells. The depot also passively recharges battery while you hover over it.

**Hazards**: Seven static wind tunnels push your craft with varying force and direction, and high-turbulence winds deal hull damage. Storm cells spawn from map edges at increasing rates, dealing hull damage and stressing nearby towers (which accelerates fault deadlines). Use the pulse ability to weaken storms and extend fault timers within range.

**Scoring**: Repair rewards scale with severity (base 120 + severity * 36 + wave * 8), plus a time bonus based on remaining deadline and a combo multiplier (+10 per consecutive repair). Each repair also restores grid health. Failed faults (expired deadlines) cost grid health (6.5 + severity * 2.0) and reset the combo.

**Win/Lose Conditions**:
- **Win**: Reach 9,800 score with grid health at or above 40% when time expires, OR reach the score target with 44+ repairs and 55%+ grid health for an early victory.
- **Lose**: Hull reaches 0, grid health reaches 0, 24 faults fail, or time expires below the score/health targets.

## Public API Reference

### Package `raylib_powerline_repair_patrol_2026`

> Main entry point and complete game implementation.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `PatrolCraft` | `x`, `y`, `vx`, `vy`, `battery`, `hull`, `wire`, `fuse`, `action_cd`, `pulse_cd`, `pulse_t`, `boost_heat`, `step_t` | The player's repair craft with position, velocity, resources, and ability cooldowns |
| `Depot` | `x`, `y`, `w`, `h` | Supply depot rectangle where the craft loads wire and fuses |
| `Substation` | `x`, `y`, `w`, `h` | Substation rectangle where the craft repairs hull and battery |
| `Tower` | `x`, `y`, `id`, `stress`, `alarm_t` | A transmission tower that can develop faults; stress accelerates fault deadlines |
| `Fault` | `active`, `id`, `tower_id`, `severity`, `deadline`, `max_deadline`, `need_wire`, `need_fuse`, `reward`, `pulse` | A fault on a tower requiring resources to repair before the deadline |
| `WindTunnel` | `active`, `x`, `y`, `w`, `h`, `vx`, `vy`, `turbulence`, `pulse` | A rectangular wind zone that pushes the craft and optionally deals hull damage |
| `StormCell` | `active`, `x`, `y`, `vx`, `vy`, `radius`, `intensity`, `life`, `pulse` | A moving circular storm that damages hull, pushes the craft, and stresses towers |
| `SupplyDrop` | `active`, `x`, `y`, `vx`, `vy`, `kind`, `amount`, `life`, `pulse` | A field pickup: kind 0=wire, 1=fuse, 2=battery |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | Visual particle for effects: kind 0=blue trail, 1=red fault, 2=gold repair/pulse |

#### Utility Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between low and high bounds |
| `minf` | `(Float, Float) -> Float` | Returns the minimum of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns the maximum of two floats |
| `mini` | `(Int, Int) -> Int` | Returns the minimum of two integers |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `sinf` | `(Float) -> Float` | Computes sine of a float via `@math.sin` |
| `randf` | `(Float, Float) -> Float` | Generates a random float in [lo, hi] using raylib's random |
| `randi` | `(Int, Int) -> Int` | Generates a random integer in [lo, hi] |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two 2D points |
| `inside_rectf` | `(Float, Float, Float, Float, Float, Float) -> Bool` | Tests if a point is inside a float-coordinate rectangle |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside an int-coordinate rectangle |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Tests if mouse/touch is over a rectangle (for touch controls) |
| `pointer_on_circle` | `(Float, Float, Bool, Int, Float, Float, Float) -> Bool` | Tests if mouse/touch is over a circle (for touch buttons) |

#### Entity Management Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clear_faults` | `(Array[Fault]) -> Unit` | Deactivates and resets all fault slots |
| `clear_winds` | `(Array[WindTunnel]) -> Unit` | Deactivates and resets all wind tunnel slots |
| `clear_storms` | `(Array[StormCell]) -> Unit` | Deactivates and resets all storm cell slots |
| `clear_drops` | `(Array[SupplyDrop]) -> Unit` | Deactivates and resets all supply drop slots |
| `clear_particles` | `(Array[Particle]) -> Unit` | Deactivates and resets all particle slots |
| `spawn_particle` | `(Array[Particle], Float, Float, Float, Float, Float, Float, Int) -> Unit` | Activates the first inactive particle with given position, velocity, life, size, and kind |
| `burst_particles` | `(Array[Particle], Float, Float, Int, Int) -> Unit` | Spawns N particles in a burst pattern around a position |
| `update_particles` | `(Array[Particle], Float) -> Unit` | Updates all active particles: moves, applies drag/gravity, and expires |
| `active_faults_count` | `(Array[Fault]) -> Int` | Counts the number of currently active faults |

#### World Initialization Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `init_towers` | `(Array[Tower], Float, Float, Float, Float) -> Unit` | Places 10 towers at fixed positions across the world (two rows of 5) |
| `init_winds` | `(Array[WindTunnel], Float, Float, Float, Float) -> Unit` | Creates 7 static wind tunnels at fixed positions with preset velocities |

#### Spawn Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `spawn_fault` | `(Array[Fault], Array[Tower], Int, Int) -> Bool` | Spawns a fault on a random tower (avoiding duplicates); severity and deadline scale with wave |
| `spawn_storm_cell` | `(Array[StormCell], Float, Float, Float, Float, Float) -> Bool` | Spawns a storm entering from a random edge with pressure-scaled intensity |
| `spawn_drop` | `(Array[SupplyDrop], Float, Float, Float, Float) -> Bool` | Spawns a supply drop at a random position in the world |
| `tower_has_fault` | `(Array[Fault], Int) -> Bool` | Checks if a tower already has an active fault |
| `nearest_fault_index` | `(Array[Fault], Array[Tower], Float, Float, Float) -> Int` | Finds the nearest faulted tower within a radius, returns fault index or -1 |

#### Drawing Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_sky_background` | `(Int, Int, Int, Int, Float) -> Unit` | Renders the gradient sky with animated wave lines |
| `draw_city_blocks` | `(Int, Int, Int, Float) -> Unit` | Draws 24 city building silhouettes with blinking windows |
| `draw_depot` | `(Depot, Float) -> Unit` | Renders the supply depot with pulsing beacon |
| `draw_substation` | `(Substation, Float) -> Unit` | Renders the substation with pulsing beacon |
| `draw_power_lines` | `(Array[Tower], Array[Fault], Float) -> Unit` | Draws power line edges between connected towers, color-coded by fault status |
| `draw_towers` | `(Array[Tower], Array[Fault], Float) -> Unit` | Renders all towers with fault indicators and alarm pulses |
| `draw_winds` | `(Array[WindTunnel], Float) -> Unit` | Renders wind tunnel zones with directional arrows |
| `draw_storms` | `(Array[StormCell], Float) -> Unit` | Renders storm cells as pulsing circles |
| `draw_drops` | `(Array[SupplyDrop], Float) -> Unit` | Renders supply drops with kind-based coloring and amount labels |
| `draw_particles` | `(Array[Particle]) -> Unit` | Renders all active particles with alpha-fade based on life |
| `draw_glider` | `(PatrolCraft, Float) -> Unit` | Renders the patrol craft as a triangle with bob animation and boost/pulse effects |
| `draw_faults_panel` | `(Int, Int, Int, Array[Fault], Float) -> Unit` | Draws the fault queue panel showing active faults with urgency bars |
| `draw_hud` | `(Int, Int, Int, Int, Float, Int, Int, Float, Float, Float, Int, Int, Int, Int, Int, String) -> Unit` | Renders the full HUD panel with time, score, meters, cargo, combo, and controls |
| `draw_touch_controls` | `(Int, Int, Float, Float, Bool, Int) -> Unit` | Draws on-screen D-pad and circular action buttons |
| `draw_menu` | `(Int, Int, Float) -> Unit` | Renders the title/menu screen with animated background |
| `draw_end` | `(Int, Int, Bool, Int, Int, Float, Int, Int) -> Unit` | Renders the win/lose end screen with statistics |

## Architecture

### Package Structure

```
raylib_powerline_repair_patrol_2026/
├── main.mbt       — All game logic, rendering, entity management, and input handling (~2626 lines)
└── moon.pkg       — Package config with raylib and math imports
```

This is a large single-file game. All entity structs, utility functions, spawn/clear/update functions, drawing functions, and the main game loop are contained in `main.mbt`. The code is well-organized with clear function separation despite being in one file.

### Data Flow

1. **Menu State (0)**: Renders animated title screen. Enter/click/touch transitions to play state.
2. **Play State (1)**: Each frame processes input (keyboard + touch via `pointer_on_rect`/`pointer_on_circle`), applies physics (acceleration, wind effects, speed clamping, world bounds), runs spawn timers (faults via `spawn_fault`, storms via `spawn_storm_cell`, drops via `spawn_drop`), updates entity interactions (storm damage, drop pickup, fault countdown, depot/substation recharging), checks action presses (repair via `nearest_fault_index`, depot load, substation service), and evaluates win/lose conditions.
3. **End States (2/3)**: `draw_end` displays results. Enter/R/click restarts via `reset_run`.

### Key Design Patterns

- **Object Pool Pattern**: Faults (18), storms (26), drops (18), and particles (1200) use pre-allocated arrays with `active` flags, avoiding runtime allocation. Each entity type has a `clear_*` function for reset and a `spawn_*` function that finds the first inactive slot.
- **Wave-based difficulty scaling**: `wave` increases with score (1 per 1100 points, max 12), reducing fault deadlines and spawn intervals while increasing fault rewards.
- **Dual-input support**: Every control has both keyboard and touch equivalents. Touch detection uses `pointer_on_rect` and `pointer_on_circle` with support for multi-touch via `get_touch_position`.
- **Interconnected stress system**: Tower stress accumulates from storms and faults, which then accelerates fault deadline countdowns via `stress_penalty`. Active fault count also adds a queue penalty to all fault deadlines.
- **Pulse ability**: A cooldown-gated area-of-effect ability that extends fault deadlines and weakens storms, creating tactical decision-making around when and where to use it.

## Improvement & Refinement Plan

1. **Extract game state into a struct**: The `main` function contains 20+ mutable local variables (`score`, `timer`, `grid_health`, `combo`, `wave`, spawn cooldowns, etc.) and a closure-based `reset_run`. Moving these into a `GameState` struct would simplify state management and make the reset logic more maintainable.

2. **Split into internal packages**: At ~2,626 lines, `main.mbt` is a strong candidate for the `internal/types`, `internal/game`, `internal/render` pattern. The 9 structs belong in types, the spawn/update/interaction logic in game, and the 15+ `draw_*` functions in render.

3. **Add tower-specific repair priority indicators**: The `nearest_fault_index` function finds the closest fault within 90 pixels, but when multiple towers are close together, the player has no visual cue about which fault is most urgent. Drawing a directional indicator toward the highest-priority (lowest deadline) fault would improve gameplay.

4. **Implement battery-dependent speed scaling**: When `battery <= 0`, the craft only gets mild velocity damping (`1.0 - dt * 1.0`). A more dramatic speed reduction or an inability to boost would create stronger resource pressure and make the depot visits more strategic.

5. **Add storm interaction with power lines**: Storms stress towers but do not visually affect the power lines drawn by `draw_power_lines`. Having lines flicker or dim when their endpoint towers are under storm stress would communicate the danger more clearly.

6. **Balance the early game**: The initial `fault_spawn_cd` of 1.2 seconds means faults spawn almost immediately, but the player starts with 0 wire and 0 fuses. Adding a brief grace period or starting with a small supply inventory would reduce the initial rush to the depot.

7. **Add a minimap or radar**: The world is large (1220x920 playable area) with 10 towers spread across it. A small minimap showing tower positions, active faults, and storm locations would reduce the need to memorize the layout and improve navigation to urgent faults.
