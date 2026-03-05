# Neon Taxi Rush 2026

A top-down arcade taxi driving game set on a neon-lit cyberpunk city grid. The player drives a taxi through a network of 4 horizontal and 5 vertical roads, picking up waiting passengers, delivering them to their destination intersections, collecting fuel pickups, and weaving through a constant stream of traffic vehicles. The city map features 20 intersection markers where passengers spawn and destinations are placed.

The core gameplay loop is a timed shift with a cash quota: earn 1,600 cash within 210 seconds to complete the shift. Cash comes from passenger fares, which increase with delivery distance and combo chains. Every 3 consecutive successful deliveries increases the wave (difficulty), spawning more traffic at higher speeds and raising the target cash by 280. The taxi has HP (220), fuel (100%), a boost ability (0.36s burst of 1.65x acceleration, costs 12 fuel, 1.2s cooldown), and a horn that pushes nearby traffic away. Running out of fuel drains HP at 16/s, and traffic collisions deal 17 HP damage.

The game also tracks a driver rating (starting at 4.2/5.0) that increases with successful deliveries (+0.08) and decreases when passengers time out waiting (-0.05), adding a quality-of-service dimension to the score.

## Build and Run

```bash
moon build --target native neon_taxi_rush_2026/
./_build/native/debug/build/neon_taxi_rush_2026/neon_taxi_rush_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Drive the taxi (acceleration-based with drag)
- **J / Space**: Boost (costs 12 fuel, 0.36s duration, 1.2s cooldown)
- **K**: Horn (pushes nearby traffic away within 110 pixel radius, 2.1s cooldown)
- **L / Enter**: Pick up passenger (when near a waiting passenger) / Drop off (when near destination with passenger aboard)
- **R**: Restart
- **Enter**: Start from title / Return to title from results
- **F11**: Toggle fullscreen
- **Touch**: Left D-pad for movement, right buttons for BOOST, HORN, and PICK/DROP

## How to Play

1. **Start**: Press Enter or tap on the title screen.
2. **Pick up passengers**: Waiting passengers appear as pulsing gold circles at road intersections. Drive near one (within 28 pixels) and press L/Enter to pick them up. Only one passenger can ride at a time.
3. **Deliver to destination**: When carrying a passenger, a blue circle marks their destination intersection. Drive there and press L/Enter to complete the delivery. Payout = base fare (28 + wave*3) + distance bonus (8 or 22) + ride time bonus (meter * 4) + combo bonus (combo * 9).
4. **Build combos**: Each consecutive delivery without a crash or missed passenger increases the combo counter. Every 3 combos advances the wave, increasing traffic density and speed but also raising fares.
5. **Manage fuel**: Fuel depletes based on speed (1.6 + speed/180 per second) plus an extra 12/s during boost. Collect green fuel pickups (blinking circles at intersections) that restore 18-34% fuel. When fuel hits 0, HP drains at 16/s.
6. **Avoid traffic**: Colored vehicles travel along the roads in fixed directions. Collisions deal 17 HP damage, knock the taxi back, and reset combo. Use the horn (K) to push nearby traffic away.
7. **Stay on roads**: Driving off-road (not on a road lane) increases drag from 2.7 to 4.3, slowing the taxi significantly.
8. **Win/Lose**: Earn the target cash (starting 1,600, increasing with waves) to complete the shift. Fail if the timer (210s) expires or HP reaches 0.
9. **Missed passengers**: Passengers wait 46 seconds before leaving. Missing one resets combo and reduces your rating by 0.05.

## Public API Reference

### Package `neon_taxi_rush_2026`

> Main entry point and complete game implementation in a single file.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width |
| `sh` | `Int` | `760` | Screen height |
| `world_w` | `Float` | `1280.0` | World width in pixels |
| `world_h` | `Float` | `760.0` | World height in pixels |
| `max_traffic` | `Int` | `120` | Maximum traffic vehicle pool size |
| `max_passengers` | `Int` | `36` | Maximum passenger pool size |
| `max_fuels` | `Int` | `24` | Maximum fuel pickup pool size |
| `max_particles` | `Int` | `760` | Maximum particle pool size |
| `max_markers` | `Int` | `32` | Maximum intersection marker count |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Taxi` | `x`, `y`, `vx`, `vy`, `hp`, `fuel`, `cash`, `combo`, `rating`, `flash_t`, `boost_t`, `boost_cd`, `horn_cd`, `carry_idx`, `drop_x`, `drop_y`, `meter` | Player taxi with position, velocity, resources, abilities, and passenger tracking |
| `Traffic` | `active`, `x`, `y`, `vx`, `vy`, `speed`, `lane`, `size`, `horn_t` | NPC traffic vehicle traveling along a fixed lane |
| `Passenger` | `active`, `x`, `y`, `dx`, `dy`, `fare`, `wait_t`, `state`, `pulse_t` | Passenger with pickup location, destination, fare, wait timer, and state (0=waiting, 1=riding) |
| `FuelPickup` | `active`, `x`, `y`, `amount`, `t`, `life` | Timed fuel pickup at an intersection |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `size`, `t`, `life`, `kind` | Visual particle with 4 color kinds (cyan/green/orange/red) |
| `Marker` | `x`, `y` | Road intersection coordinate used for spawning passengers and fuel |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between lo and hi |
| `absf` | `(Float) -> Float` | Returns absolute value of a float |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two points |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Point-in-rectangle test for touch UI |
| `randf` | `(Float, Float) -> Float` | Random float in range [lo, hi] |
| `rating_str` | `(Float) -> String` | Formats a rating float as "X.Y" string |
| `road_hit` | `(Float, Float) -> Bool` | Tests if a position is on a road lane (affects drag) |
| `clear_traffic` | `(Array[Traffic]) -> Unit` | Resets all traffic vehicles to inactive |
| `clear_passengers` | `(Array[Passenger]) -> Unit` | Resets all passengers to inactive |
| `clear_fuels` | `(Array[FuelPickup]) -> Unit` | Resets all fuel pickups to inactive |
| `clear_particles` | `(Array[Particle]) -> Unit` | Resets all particles to inactive |
| `clear_markers` | `(Array[Marker]) -> Unit` | Resets all marker positions to zero |
| `spawn_particle` | `(Array[Particle], Float, Float, Float, Int) -> Unit` | Spawns a single particle with random velocity |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Spawns multiple particles in a burst |
| `setup_markers` | `(Array[Marker]) -> Int` | Initializes 20 intersection markers at road crossings, returns count |
| `spawn_traffic` | `(Array[Traffic], Int) -> Bool` | Spawns a traffic vehicle on a random lane with wave-scaled speed |
| `spawn_passenger` | `(Array[Passenger], Array[Marker], Int, Int) -> Bool` | Spawns a passenger at a random marker with random destination |
| `spawn_fuel` | `(Array[FuelPickup], Array[Marker], Int) -> Bool` | Spawns a fuel pickup near a random marker |
| `main` | `() -> Unit` | Entry point: initializes window, allocates pools, runs game loop |

## Architecture

### Package Structure

```
neon_taxi_rush_2026/
├── main.mbt    — Complete game: types, road geometry, spawning, game loop, rendering
└── moon.pkg    — Package config with raylib and math imports
```

Single-file game with all logic in `main.mbt`. Organized top-to-bottom: constants, struct definitions, utility functions, pool management, spawning functions, main function with nested reset closure, game loop with input/update/render.

### Data Flow

1. **Input**: Reads WASD/arrows for movement, J/Space for boost, K for horn, L/Enter for pick/drop. Touch inputs are mapped from on-screen D-pad and button rectangles via `inside_rect`.

2. **Update**: In state 1 (playing): timer countdown, cooldown ticks, movement with acceleration/drag (higher drag off-road via `road_hit`), speed clamping, fuel consumption (base + speed-proportional + boost extra), boost/horn activation, traffic spawning on cooldowns, traffic movement along lanes, taxi-traffic collision (distance check, impulse response, HP damage), passenger state machine (waiting -> boarding -> riding -> delivered), fuel pickup collection, particle physics, win/lose checks.

3. **Rendering**: Background with animated road grid (4 horizontal + 5 vertical roads with scrolling lane dashes), fuel pickups (blinking circles), passengers (pulsing gold circles), destination marker (blue circle when carrying), traffic vehicles (colored rectangles), particles, taxi (yellow rectangle with windshield), HUD (cash/time/served/wave/combo/rating/misses, HP and fuel bars), touch controls, message bar, state overlays.

### Key Design Patterns

- **Object pool pattern**: Pre-allocated arrays with `active` flags for traffic, passengers, fuel, and particles. Linear scan for first free slot.
- **Intersection marker system**: 20 fixed markers at road intersections serve as spawn points for passengers and fuel, creating predictable strategic locations.
- **Combo-driven wave escalation**: Every 3 consecutive deliveries advances the wave, creating a positive feedback loop where skilled play increases both difficulty and reward.
- **Fuel economy system**: Fuel consumption scales with speed and boost usage, creating a tension between fast delivery (more fuel cost) and fuel conservation.
- **Horn crowd control**: The horn ability pushes traffic within 110 pixels outward and applies a 0.9s visual flash, providing a non-damaging defensive tool.

## Improvement & Refinement Plan

1. **Add a minimap or passenger indicator arrows**: With passengers spawning across the entire map, players must visually scan to find them. Edge-of-screen arrows pointing to active passengers would improve navigation.

2. **Implement traffic AI variety**: All traffic vehicles move in straight lines at constant speed. Adding lane-changing behavior, stopping at intersections, or speed variation would make traffic more realistic and challenging.

3. **Add passenger satisfaction feedback**: The rating system tracks quality but is only shown as a number. Adding visual indicators (happy/angry emoji on delivery, streak effects) would make the rating feel more impactful.

4. **Replace state integers with an enum**: Game states (0=title, 1=play, 2=win, 3=lose) and passenger states (0=waiting, 1=riding) should use named enums for clarity.

5. **Separate game logic from rendering**: The 1600-line main function interleaves update and render code. Extracting `update_game` and `draw_game` functions would improve maintainability.

6. **Add traffic density visualization**: As waves increase, traffic spawns faster but there is no visual indicator of the current wave's intensity. A traffic density meter or color-coded road sections would help players anticipate danger zones.

7. **Add sound effects**: Horn honking, engine boost, coin collection, collision impacts, and delivery chimes would significantly enhance the driving experience.

8. **Implement fuel station locations**: Instead of random fuel spawns at intersections, having fixed fuel station locations that periodically restock would add route-planning strategy.
