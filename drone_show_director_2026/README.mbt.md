# Drone Show Director 2026

A real-time drone choreography management game set on a nighttime aerial stage. As the director, you command a swarm of 58 drones to form spectacular patterns -- Solar Ring, Dragon Spiral, River Wave, Lotus Bloom, and Phoenix Wings -- while fulfilling audience requests within tight deadlines. The show takes place against a dark sky punctuated by fireworks and atmospheric wind gusts that threaten to scatter your formation.

The core gameplay loop revolves around switching between five formation patterns to match incoming audience requests, maintaining formation quality above each request's minimum threshold, and managing drone health (battery and temperature). Three ground stations (Recharge, Cooling, Broadcast) provide critical support: recharging batteries, cooling overheated drones, or boosting formation sync. The director moves across the field, activating stations and using a boost ability for faster traversal at the cost of energy.

The game features an object-pool architecture with pre-allocated arrays for drones, gusts, fireworks, and particles. A wave-based difficulty system increases request frequency, gust intensity, and deadline pressure as the timer counts down from 7 minutes. The reputation system adds a persistent risk layer -- losing drones or failing requests erodes reputation, and if it hits zero the show collapses.

## Build and Run

```bash
moon build --target native drone_show_director_2026/
./_build/native/debug/build/drone_show_director_2026/drone_show_director_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move the director around the field
- **Space / J**: Boost (increased movement speed, drains energy)
- **L / U**: Action (activate nearby station: Recharge, Cooling, or Broadcast)
- **Q / E**: Cycle to next formation pattern
- **Enter**: Start game / Restart after game over
- **R**: Restart after game over
- **F11**: Toggle fullscreen
- **Touch D-pad**: Move (mobile)
- **Touch BOOST button**: Boost (mobile)
- **Touch ACT button**: Activate station (mobile)
- **Touch NEXT button**: Cycle pattern (mobile)

## How to Play

You have 7 minutes (420 seconds) to reach a score target of 9,800 while maintaining your reputation above zero. Audience requests appear periodically, each requiring a specific formation pattern at a minimum quality level before a deadline expires.

1. **Switch patterns** with Q/E to match the pattern an active request demands (Solar Ring, Dragon Spiral, River Wave, Lotus Bloom, Phoenix Wings).
2. **Maintain formation quality** by keeping drones alive and near their target positions. The quality meter (0-100%) must exceed the request's minimum quality threshold for progress to accumulate.
3. **Fulfill requests** by holding the matching pattern at sufficient quality until the progress bar fills to 100%. Completing requests earns points (base reward + urgency bonus + combo bonus).
4. **Manage drone health**: Drones consume battery and accumulate heat over time. Low battery (below 24%) degrades a drone to state 1 (slower attraction), and high temperature (above 82%) degrades to state 2 (even slower). Battery depletion or overheating (116+) destroys a drone.
5. **Use stations**: Move near a station and press L/U to activate. RECHARGE restores battery to all drones and can revive one lost drone. COOLING reduces swarm temperature. BROADCAST activates a 4.2-second sync pulse that strengthens formation attraction.
6. **Dodge wind gusts**: Gusts spawn from screen edges and push drones off course while heating them. Their frequency and strength increase over time.
7. **Build combos**: Consecutively fulfilled requests increase your combo multiplier (up to 30x), boosting score gains and reputation recovery.

**Win conditions**: Reach 9,800 score with 62%+ reputation and 16+ served requests (early win), or finish the timer with score target met and 40%+ reputation. **Lose conditions**: Reputation drops to 0%, fewer than 8 drones remain active, or timer expires without meeting targets.

## Public API Reference

### Package `drone_show_director_2026`

> Main entry point and complete game implementation (single-file architecture).

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Director` | `x`, `y`, `vx`, `vy`, `energy`, `energy_max`, `action_cd`, `sync_t`, `boost_heat`, `step_t` | Player-controlled director character with position, velocity, energy, and cooldown state |
| `Drone` | `active`, `x`, `y`, `vx`, `vy`, `battery`, `temp`, `state`, `flash_t` | Individual drone with position, health metrics (battery/temperature), and degradation state (0=normal, 1=low battery, 2=overheated) |
| `Request` | `active`, `id`, `pattern`, `deadline`, `max_deadline`, `min_quality`, `reward`, `progress`, `pulse` | Audience request requiring a specific formation pattern at minimum quality before deadline |
| `Gust` | `active`, `x`, `y`, `vx`, `vy`, `radius`, `life`, `strength`, `pulse` | Wind gust hazard that pushes drones and raises their temperature |
| `Firework` | `active`, `x`, `y`, `vx`, `vy`, `life`, `burst_t`, `color` | Decorative firework projectile that bursts into particles |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | Visual particle for effects (kind 0=blue, 1=red, 2=gold) |
| `Station` | `x`, `y`, `w`, `h`, `kind` | Ground station (kind 0=Recharge, 1=Cooling, 2=Broadcast) |
| `Vec2f` | `x`, `y` | Simple 2D float vector for pattern target positions |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value between low and high bounds |
| `minf` | `(Float, Float) -> Float` | Returns the minimum of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns the maximum of two floats |
| `mini` | `(Int, Int) -> Int` | Returns the minimum of two integers |
| `maxi` | `(Int, Int) -> Int` | Returns the maximum of two integers |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `sinf` | `(Float) -> Float` | Computes sine via `@math.sin` with float conversion |
| `cosf` | `(Float) -> Float` | Computes cosine via `@math.cos` with float conversion |
| `randf` | `(Float, Float) -> Float` | Generates a random float in [lo, hi] using raylib's RNG |
| `randi` | `(Int, Int) -> Int` | Generates a random integer in [lo, hi] |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Computes squared Euclidean distance between two 2D points |
| `inside_rectf` | `(Float, Float, Float, Float, Float, Float) -> Bool` | Tests if a point is inside a float-coordinate rectangle |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside an int-coordinate rectangle |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Tests if mouse or any touch point is inside a rectangle |
| `pointer_on_circle` | `(Float, Float, Bool, Int, Float, Float, Float) -> Bool` | Tests if mouse or any touch point is inside a circle |
| `pattern_name` | `(Int) -> String` | Returns the full name for a pattern index (0-4) |
| `pattern_short` | `(Int) -> String` | Returns the short name for a pattern index |
| `pattern_color` | `(Int) -> @raylib.Color` | Returns the display color for a pattern index |
| `pattern_target` | `(Int, Int, Int, Float, Float, Float) -> Vec2f` | Computes the target position for a drone in a given pattern formation |
| `clear_requests` | `(Array[Request]) -> Unit` | Deactivates and resets all requests in the pool |
| `clear_gusts` | `(Array[Gust]) -> Unit` | Deactivates and resets all gusts in the pool |
| `clear_fireworks` | `(Array[Firework]) -> Unit` | Deactivates and resets all fireworks in the pool |
| `clear_particles` | `(Array[Particle]) -> Unit` | Deactivates and resets all particles in the pool |
| `spawn_particle` | `(Array[Particle], Float, Float, Float, Float, Float, Float, Int) -> Unit` | Activates the first inactive particle with given position, velocity, lifetime, size, and kind |
| `burst_particles` | `(Array[Particle], Float, Float, Int, Int) -> Unit` | Spawns N particles in a burst at a position with random spread |
| `update_particles` | `(Array[Particle], Float) -> Unit` | Updates all active particles: applies velocity, drag, gravity, and lifetime decay |
| `spawn_request` | `(Array[Request], Int, Int) -> Bool` | Spawns a new audience request with wave-scaled difficulty |
| `spawn_gust` | `(Array[Gust], Float, Float, Float, Float, Float) -> Bool` | Spawns a wind gust from a random world edge with pressure-scaled strength |
| `spawn_firework` | `(Array[Firework], Float, Float, Float) -> Bool` | Spawns an upward-traveling firework from the bottom of the world |
| `formation_quality` | `(Array[Drone], Int, Float, Float, Float) -> Float` | Calculates formation quality (0-100) based on drone distances to pattern targets and state penalties |
| `nearest_station_kind` | `(Array[Station], Float, Float, Float) -> Int` | Returns the kind of the nearest station within a radius, or -1 if none |
| `active_requests_count` | `(Array[Request]) -> Int` | Counts the number of currently active audience requests |
| `draw_background` | `(Int, Int, Int, Int, Float) -> Unit` | Renders the dark gradient background with animated scan lines |
| `draw_stage` | `(Float, Float, Float, Float) -> Unit` | Renders the circular performance stage with concentric ring effects |
| `draw_targets` | `(Array[Drone], Int, Float, Float, Float, Float) -> Unit` | Renders target position markers for the current formation pattern |
| `draw_stations` | `(Array[Station], Director, Float) -> Unit` | Renders ground stations with proximity highlighting and labels |
| `draw_gusts` | `(Array[Gust], Float) -> Unit` | Renders wind gust indicators as pulsing concentric circles |
| `draw_drones` | `(Array[Drone], Float) -> Unit` | Renders drones with color based on battery/temperature and flashing glow |
| `draw_fireworks` | `(Array[Firework]) -> Unit` | Renders active firework projectiles |
| `draw_particles` | `(Array[Particle]) -> Unit` | Renders active particles with lifetime-based alpha fade |
| `draw_director` | `(Director, Float) -> Unit` | Renders the director character with bobbing animation and sync pulse ring |
| `draw_requests_panel` | `(Int, Int, Int, Array[Request], Int, Float, Float) -> Unit` | Renders the side panel showing all active audience requests with progress bars |
| `draw_hud` | `(Int, Int, Int, Int, Float, Int, Int, Float, Float, Float, Float, Int, Int, Int, Int, String) -> Unit` | Renders the full HUD: timer, score, pattern, combo, meters (reputation, quality, energy, heat), and controls legend |
| `draw_touch_controls` | `(Int, Int, Float, Float, Bool, Int) -> Unit` | Renders mobile touch controls (D-pad and action buttons) |
| `draw_menu` | `(Int, Int, Float) -> Unit` | Renders the title screen with animated background and start prompt |
| `draw_end` | `(Int, Int, Bool, Int, Int, Float, Int, Int, Int) -> Unit` | Renders the game over screen with final statistics |
| `main` | `() -> Unit` | Entry point: initializes window (1700x960), creates game objects, runs main loop |

## Architecture

### Package Structure

```
drone_show_director_2026/
├── main.mbt              — Complete game: types, logic, rendering, entry point
└── moon.pkg              — Package config with raylib and math imports
```

This is a single-file game architecture where all structs, game logic, rendering, and the main loop reside in `main.mbt`. The file is organized top-down: struct definitions, utility functions, pattern computation, entity management (spawn/clear/update), rendering functions, and finally the main game loop.

### Data Flow

1. **Input**: The main loop reads keyboard state (`is_key_down`/`is_key_pressed`) and touch input (`get_touch_position`/`get_touch_point_count`) to determine movement direction, boost, action, and pattern cycling.
2. **Update**: Director position is updated with velocity and clamped to world bounds. Drones are attracted toward `pattern_target` positions with strength modified by sync state. Gusts apply forces to nearby drones. Request progress accumulates when the current pattern matches and quality exceeds the minimum. Battery drains and temperature rises based on speed and storm pressure.
3. **Render**: `draw_background` and `draw_stage` establish the scene, then entities are layered: targets, stations, gusts, fireworks, drones, particles, director. The HUD panel and request list are drawn to the right side. Touch controls overlay the bottom corners.

### Key Design Patterns

- **Object pool pattern**: All entity arrays (`drones[58]`, `requests[10]`, `gusts[24]`, `fireworks[20]`, `particles[1200]`) are pre-allocated with `active` flags. Spawn functions scan for the first inactive slot.
- **State machine**: Integer `state` variable drives top-level flow (0=menu, 1=play, 2=win, 3=lose) with distinct update and render paths.
- **Wave-based difficulty**: `wave` increases with score, scaling request deadlines, quality thresholds, rewards, and gust spawn rates via `storm_pressure` (derived from elapsed time).
- **Formation system**: Five parametric pattern functions (`pattern_target`) compute per-drone target positions using trigonometric formulas with a continuously advancing `pattern_phase`.
- **Combo system**: Consecutive fulfilled requests build a combo multiplier (capped at 30) that boosts score gains and reputation recovery.
- **Multi-input support**: All interactive elements check both keyboard and touch/mouse input through `pointer_on_rect` and `pointer_on_circle` helpers.

## Improvement & Refinement Plan

1. **Extract structs and logic into internal packages**: The 2,360-line `main.mbt` would benefit from splitting into `internal/types` (structs), `internal/game` (update logic, spawning), and `internal/render` (all `draw_*` functions) for better maintainability.
2. **Replace integer state encoding with enums**: `Director.state`, drone `state` (0/1/2), game `state` (0/1/2/3), and station `kind` (0/1/2) use raw integers. Named enums like `DroneState::Normal | LowBattery | Overheated` would improve readability.
3. **Add difficulty configuration**: The hardcoded constants (timer 420s, score target 9800, drone count 58, reputation penalties) could be extracted into a config struct to enable difficulty presets.
4. **Implement station cooldowns**: Currently the director can spam the Action button at a station every 0.26 seconds. Adding per-station cooldowns in the `Station` struct would add strategic depth.
5. **Add drone separation forces**: Drones can overlap when attracted to closely-spaced pattern targets. A simple separation force in the drone update loop would improve visual clarity of formations.
6. **Optimize formation quality calculation**: `formation_quality` iterates all drones and calls `pattern_target` for each. Caching target positions when the pattern or phase changes would reduce redundant trigonometric computations.
7. **Add visual feedback for pattern transitions**: When cycling patterns with Q/E, drones silently re-target. A brief transition animation or trail effect would make pattern switches more visually satisfying.
