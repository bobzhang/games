# Aftershock Rescue Convoy 2026

A top-down urban rescue simulation set in an earthquake-ravaged city. The player drives a convoy vehicle across a large scrolling map, picking up stranded survivor groups and delivering them to a central medical hub while managing hull integrity, battery power, and medkit supplies. Seismic crack zones and dust clouds continuously threaten both the convoy and survivors.

The core gameplay loop involves shuttling between survivor groups scattered across the map and the MED HUB hospital. Survivors spawn at random map edges with a panic meter that rises over time, especially near crack zones and dust clouds. When panic reaches 100%, the group is lost. The player must prioritize which groups to rescue based on proximity and urgency, use medkits to stabilize dangerous crack zones (reducing their intensity and radius), and keep the hospital queue from overflowing by steadily delivering survivors. Seven city districts act as population centers whose queues rise over time and overflow if neglected, causing additional civilian losses.

The game features a tier system that escalates difficulty based on total rescues (tier = 1 + rescues/120, max 9), increasing spawn rates, crack frequency, and group sizes. The player has three special abilities: boost (hold for faster movement at higher battery cost), action (context-sensitive rescue or crack stabilization), and ping (locates the nearest urgent target). Win by rescuing 680 civilians before the 430-second timer expires; lose if time runs out, too many civilians are lost (170 limit), hull reaches zero, or the hospital queue maxes out.

## Build and Run

```bash
moon build --target native aftershock_rescue_convoy_2026/
./_build/native/debug/build/aftershock_rescue_convoy_2026/aftershock_rescue_convoy_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Drive the convoy vehicle
- **J / Space (hold)**: Boost (faster acceleration and higher max speed, drains battery faster)
- **L / U**: Action -- rescues nearby survivor groups (within 84px) or stabilizes crack zones using medkits (prioritizes cracks over rescues)
- **K / H**: Ping -- locates and marks the nearest urgent target (groups with panic >= 30, or cracks with intensity >= 0.8); 2-second cooldown
- **Enter / Space / Click**: Start game from menu; return to menu from win/lose screen
- **R / Enter**: Return to menu from result screen
- **F11**: Toggle fullscreen
- **Touch controls**: On-screen D-pad (bottom-left) and circle buttons for BOOST, ACT, PING (bottom-right)

## How to Play

From the title screen, click or press Enter/Space to begin. Your convoy starts at the MED HUB hospital on the left side of the map. Drive to survivor groups (shown as glowing circles with group ID, count, and panic level) and press L/U to pick them up (up to 38 capacity). Return to the hospital to unload survivors -- this happens automatically when you are near the MED HUB with passengers aboard (3 at a time, with a 0.12s cooldown between batches).

**Survivor groups** spawn from map edges with 4-14 people (scaling with tier). Their panic rises at a base rate of 2.1/s, faster when far from the hospital (>390px) or near crack zones and dust clouds. At 100% panic, the entire group is lost. Groups with panic >= 70 are shown in red and counted as "critical."

**Crack zones** are seismic hazards that spawn from map edges and slowly drift. They have a radius (70-146px), an intensity that increases over time (0.06/s), and a lifetime (20-42s). Inside a crack zone, the player experiences movement drag, increased battery drain, and hull damage. Crack zones also increase panic in nearby survivor groups and stress in districts. Use the Action key near a crack to spend a medkit and reduce its intensity by 0.24 + medkits*0.02, potentially deactivating it entirely.

**Districts** (7 total) have queues that rise over time and spike near hazards. When a district queue exceeds 100, it resets to ~80 but 3 people are lost. Keep district stress manageable by stabilizing nearby cracks.

**Hospital queue** rises at 2.2 + tier*0.18 per second. Delivering survivors reduces it. If the queue reaches 280 (the max), you lose.

**Scoring**: +10 per survivor delivered, +6 per rescued person + 8 per group touched, +80 * intensity_reduction for crack stabilization. -5 per person lost to panic.

**Win condition**: Rescue 680 total civilians within 430 seconds.
**Lose conditions**: Timer expires, 170+ civilians lost, hull reaches zero, or hospital queue reaches capacity.

## Public API Reference

### Package `aftershock_rescue_convoy_2026`

> Single-file game with all types, logic, rendering, and the main loop in `main.mbt`.

Since this is a single-file game, all structs and functions are package-private (no `pub` modifier). The only public entry point is the `main` function.

#### Structs (package-private)

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Player` | `x`, `y`, `vx`, `vy`, `heading`, `hull`, `battery`, `onboard`, `capacity`, `medkits`, `action_cd`, `ping_cd`, `ping_t` | Convoy vehicle state: position, velocity, heading angle, resources, and ability cooldowns |
| `Hospital` | `x`, `y`, `w`, `h` | The MED HUB delivery point with fixed position and dimensions |
| `District` | `active`, `x`, `y`, `queue`, `stress`, `alarm_t`, `id` | A city district with a population queue that overflows when neglected |
| `SurvivorGroup` | `active`, `x`, `y`, `count`, `panic`, `drift_x`, `drift_y`, `flare_t`, `id` | A group of stranded civilians with a panic timer and drift movement |
| `CrackZone` | `active`, `x`, `y`, `vx`, `vy`, `radius`, `intensity`, `life`, `phase` | A seismic hazard zone that damages nearby entities and increases panic |
| `DustCloud` | `active`, `x`, `y`, `vx`, `vy`, `radius`, `density`, `life`, `phase` | A secondary hazard spawned by crack zones that slows and damages the player |
| `Obstacle` | `active`, `x`, `y`, `vx`, `vy`, `size`, `hard`, `spin` | Static debris scattered across the map that causes collision damage |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | Visual particle for burst effects (4 kinds: default, fire, water, golden) |

#### Functions (package-private)

| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Entry point: creates 1680x940 window, allocates pools, runs game loop with state machine (0=menu, 1=play, 2=win, 3=lose) |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to [lo, hi] |
| `minf` / `maxf` | `(Float, Float) -> Float` | Returns min/max of two floats |
| `mini` | `(Int, Int) -> Int` | Returns the smaller of two ints |
| `absf` | `(Float) -> Float` | Absolute value of a float |
| `randf` | `(Float, Float) -> Float` | Random float in [lo, hi] |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two points |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Point-in-rectangle test |
| `init_districts` | `(Array[District], Int, Int, Int, Int) -> Unit` | Places 7 districts at hardcoded positions within the world bounds |
| `init_obstacles` | `(Array[Obstacle], Array[District], ...) -> Unit` | Scatters ~188 debris obstacles avoiding districts and hospital |
| `spawn_group` | `(Array[SurvivorGroup], ..., Int, Int) -> Bool` | Spawns a survivor group at a random map edge |
| `spawn_crack` | `(Array[CrackZone], ..., Int) -> Bool` | Spawns a crack zone from a random map edge |
| `spawn_dust` | `(Array[DustCloud], Float, Float, Float) -> Bool` | Spawns a dust cloud near a crack zone |
| `rescue_groups` | `(Player, Array[SurvivorGroup], Array[Particle]) -> (Int, Int)` | Picks up survivors from groups within 84px of the player |
| `stabilize_cracks` | `(Player, Array[CrackZone], Array[Particle]) -> (Int, Float)` | Uses medkits to reduce crack zone intensity |
| `nearest_urgent_group` | `(Array[SurvivorGroup], Float, Float) -> (Bool, Float, Float, Float)` | Finds the closest group with panic >= 30 |
| `nearest_hot_crack` | `(Array[CrackZone], Float, Float) -> (Bool, Float, Float, Float)` | Finds the closest crack with intensity >= 0.8 |
| `update_cracks` | `(Array[CrackZone], Array[DustCloud], Float, ...) -> Unit` | Moves crack zones, bounces off world edges, increases intensity, spawns dust |
| `update_dusts` | `(Array[DustCloud], Float, ...) -> Unit` | Moves and decays dust clouds |
| `update_obstacles` | `(Array[Obstacle], Float, ...) -> Unit` | Drifts obstacles and bounces off world edges |
| `update_groups` | `(Array[SurvivorGroup], Array[CrackZone], Array[DustCloud], ...) -> (Int, Float)` | Updates group drift, calculates panic from hazards, returns lost count |
| `draw_city` | `(Int, Int, Int, Int, Float) -> Unit` | Draws the background city grid with animated gradient |
| `draw_hospital` | `(Hospital) -> Unit` | Draws the MED HUB building |
| `draw_districts` | `(Array[District], Float) -> Unit` | Draws district markers with queue/stress labels |
| `draw_groups` | `(Array[SurvivorGroup], Float) -> Unit` | Draws survivor group circles with panic indicators |
| `draw_cracks` | `(Array[CrackZone], Float) -> Unit` | Draws crack zone circles with pulsing intensity |
| `draw_dusts` | `(Array[DustCloud], Float) -> Unit` | Draws dust cloud circles |
| `draw_obstacles` | `(Array[Obstacle], Float) -> Unit` | Draws debris circles with hardness-based coloring |
| `draw_player` | `(Player, Float) -> Unit` | Draws the convoy vehicle with heading indicator, passenger dots, medkit bar, and ping ring |
| `draw_parts` | `(Array[Particle]) -> Unit` | Draws active particles by kind |
| `draw_touch_controls` | `(Int, Int, Float, Float, Bool) -> Unit` | Draws D-pad and circle action buttons |
| `draw_bar` | `(Int, Int, String, Float, Float, @raylib.Color) -> Unit` | Draws a labeled progress bar on the HUD panel |
| `draw_button` | `(Int, Int, Int, Int, String, Bool) -> Unit` | Draws a clickable button with hover state |

## Architecture

### Package Structure

```
aftershock_rescue_convoy_2026/
├── main.mbt    — All structs, logic, rendering, and game loop in a single file
└── moon.pkg    — Package config with raylib and math imports
```

This is a single-file game (~2880 lines). All entity types, utility functions, update logic, rendering, and the main game loop coexist in `main.mbt`. The code is organized top-to-bottom: struct definitions, utility functions, clear/init functions, spawn functions, update functions, draw functions, and finally the `main` function containing the game loop.

### Data Flow

1. **Initialization**: `reset_run()` (a closure inside `main`) calls `init_districts` to place 7 districts and `init_obstacles` to scatter ~188 debris obstacles, then clears all pools and resets player/timer/score state.

2. **Input phase**: During `state == 1` (play), the game loop checks keyboard and touch inputs for movement (WASD/arrows + D-pad), boost (J/Space + touch), action (L/U + touch), and ping (K/H + touch). Touch input uses `inside_rect` for D-pad and `dist2` for circular buttons.

3. **Physics and hazard effects**: The player's velocity is updated with acceleration from input, drag (increased near crack zones), and speed capping. Crack zones and dust clouds apply movement drag, extra battery drain, and hull damage proportional to proximity. Obstacle collisions push the player and deal speed-dependent damage.

4. **World updates**: `update_cracks` moves crack zones, bounces them off world edges, increases their intensity, and randomly spawns dust clouds. `update_groups` calculates panic gain from base rate plus proximity to cracks, dust, and distance from hospital. `update_obstacles` drifts debris. District queues rise over time, scaled by nearby hazard intensity and tier.

5. **State transitions**: Win when `rescued_total >= 680`. Lose when `timer <= 0`, `lost_people >= 170`, `player.hull <= 0`, or `hospital_queue >= 278`.

6. **Rendering**: Draws city background grid, hospital, obstacles, districts, survivor groups, crack zones, dust clouds, player, ping indicator, particles, then the right-side HUD panel with all stats and bars. Touch controls are drawn over everything. State overlays (menu, win, lose) draw semi-transparent fullscreen panels.

### Key Design Patterns

- **Single-file monolith**: All game logic in one file, using local closures (`reset_run`) for initialization. Entity types are package-private structs without `pub`.
- **Object pool pattern**: Fixed-size arrays for entities (26 groups, 24 cracks, 40 dust clouds, 200 obstacles, 920 particles) with `active` flags. Spawn functions scan for inactive slots.
- **Integer state machine**: `state` is an `Int` (0=menu, 1=play, 2=win, 3=lose) driving the main game loop branch.
- **Proximity-based interactions**: All interactions (rescue, stabilize, hazard effects, collision) use squared-distance checks via `dist2` to avoid square root calculations in hot paths.
- **Tiered difficulty scaling**: The `tier` variable (1 + rescued/120, max 9) affects group sizes, spawn cooldowns, crack frequency limits, district queue growth rate, and crack intensity gain.
- **Context-sensitive action**: The L/U key first attempts crack stabilization (using medkits), then falls back to survivor rescue, providing a single-button interaction model.

## Improvement & Refinement Plan

1. **Extract entity types and logic into internal packages**: The 2880-line `main.mbt` would benefit from separation into `types/`, `game/`, and `render/` packages. This would make the codebase easier to navigate and allow independent compilation of logic and rendering.

2. **Replace integer state machine with enum**: The `state` variable uses magic integers (0-3). Converting to a `GameState` enum would improve readability and catch missing match arms at compile time.

3. **Decouple action key behavior**: `stabilize_cracks` is always checked before `rescue_groups`, meaning the player cannot rescue nearby survivors if standing near a crack zone with medkits remaining. Adding separate keybinds for rescue and stabilize would give the player more tactical control.

4. **Hospital unloading feedback**: Unloading happens automatically when near the hospital at 3 people per 0.12s tick, with no visual or audio feedback beyond particles. A progress indicator or sound effect would make deliveries feel more satisfying.

5. **Survivor group pathfinding toward hospital**: Groups drift with fixed random vectors that bounce off walls. Adding a slight bias toward the hospital when panic is low would make the game world feel more alive and give players a reward for reducing panic.

6. **Crack zone visual telegraph**: Crack zones spawn instantly at map edges. Adding a 1-2 second warning indicator (e.g., a pulsing marker) before the crack becomes active would give players time to plan their response.

7. **Battery recharge stations**: Currently the only way to recharge battery is returning to the hospital. Adding secondary recharge stations or battery pickup items in the world would encourage more varied routing strategies.
