# Rooftop Mail Glider 2026

Rooftop Mail Glider 2026 is a delivery flight simulation game where the player pilots a glider across a scrolling urban cityscape, picking up mail bags from a central depot and delivering them to eight rooftop landing pads before deadlines expire. The game features a side panel HUD with delivery tracking, resource meters, and real-time mission updates set against a gradient sky background with animated city buildings.

The core gameplay loop is a time-pressured delivery circuit: fly to the depot to load bags (up to 18), then navigate to the correct rooftop pad matching an active delivery request, press the action key to deliver, and earn rewards scaled by remaining deadline time and combo multiplier. Environmental hazards include seven wind tunnels that push the glider off course and drain hull integrity at high turbulence, and flocks of birds that deal hull damage and drop cargo on collision. The player can fire flares to scatter nearby birds. Supply crates floating in the world provide fuel, hull repairs, or extra mail bags.

The game features a wave-based difficulty system where wave number increases with score (1 wave per 1000 points, max 12), affecting delivery deadlines, spawn rates, and bird danger levels. Win conditions require reaching a 9,600-point score target with at least 40% reputation, or clearing 52+ deliveries early with 55%+ reputation. Lose conditions include hull destruction, reputation collapse to 0%, exceeding 22 failed deliveries, or failing to meet the score target when the 420-second timer expires.

## Build and Run

```bash
moon build --target native rooftop_mail_glider_2026/
./_build/native/debug/build/rooftop_mail_glider_2026/rooftop_mail_glider_2026.exe
```

## Controls

- **W / Up Arrow**: Move glider up
- **A / Left Arrow**: Move glider left
- **S / Down Arrow**: Move glider down
- **D / Right Arrow**: Move glider right
- **Space / J** (hold): Boost (increases acceleration from 360 to 560, max speed from 300 to 430, drains fuel faster)
- **L / U**: Action -- load bags at depot / deliver bags at landing pads
- **K / H**: Fire flare (scatters birds within 220px radius for 3.8s, costs 6 fuel, 9s cooldown)
- **Enter**: Start game from menu
- **R**: Restart after game over
- **F11**: Toggle fullscreen
- **Touch/Mouse**: On-screen D-pad (bottom-left) and circular BOOST/ACT/FLARE buttons (bottom-right)

## How to Play

You start at the mail depot in the bottom-left of the world. Press the action key (L/U) while at the depot to load your glider with mail bags up to the 18-bag capacity. Hovering over the depot also gradually refuels and repairs your glider.

Active delivery requests appear in the right-side panel, each showing a target pad (P1-P8), reward amount, and countdown timer. Fly to the correct pad and press the action key while carrying bags to complete a delivery. Rewards include the base amount plus a time bonus (remaining deadline * 2.2) plus a combo bonus (combo * 10). Consecutive successful deliveries increase your combo multiplier (max 30x).

Watch out for hazards:
- **Wind tunnels** (7 fixed zones shown as translucent blue rectangles with direction arrows) push your glider off course and can damage your hull if turbulence exceeds 0.42
- **Birds** spawn from the edges of the world with increasing frequency. Collisions deal 4-13 damage to your hull, knock you back, drop 1 bag, reset your combo, and reduce reputation by 1.6 points
- Use **flares** to repel birds within a 220-pixel radius

Three types of supply crates spawn every 10-18 seconds:
- **Fuel crate** (blue): Restores 10-22 fuel
- **Repair kit** (red): Restores 10-20 hull
- **Bag crate** (green): Adds 1-3 extra bags

The game ends in **victory** if you reach the 9,600 score target with 40%+ reputation when the 420-second timer expires, or if you complete 52+ deliveries early with 55%+ reputation and the score target met. You **lose** if hull reaches 0, reputation drops to 0, you accumulate 22+ failed deliveries, or you fail to meet the score target at timer expiration.

## Public API Reference

### Package `rooftop_mail_glider_2026`

> Main entry point. Single-file game with all types, logic, rendering, and main loop.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Glider` | `x`, `y`, `vx`, `vy`, `fuel`, `fuel_max`, `hull`, `hull_max`, `bags`, `bag_cap`, `action_cd`, `flare_cd`, `flare_t`, `boost_heat`, `step_t` | Player-controlled glider with position, velocity, resources, capacities, ability cooldowns, and visual state |
| `Depot` | `x`, `y`, `w`, `h` | The mail depot rectangle where bags are loaded and the glider refuels |
| `Pad` | `x`, `y`, `w`, `h`, `id` | A rooftop delivery landing pad with position, dimensions, and unique ID |
| `Delivery` | `active`, `id`, `pad_id`, `deadline`, `max_deadline`, `reward`, `pulse` | An active delivery request targeting a specific pad with countdown and reward |
| `WindTunnel` | `active`, `x`, `y`, `w`, `h`, `vx`, `vy`, `turbulence`, `pulse` | A wind zone that pushes the glider with directional force and optional hull damage |
| `Bird` | `active`, `x`, `y`, `vx`, `vy`, `size`, `danger`, `life`, `wing_t` | A flying bird hazard with velocity, collision size, damage scaling, lifetime, and wing animation phase |
| `Crate` | `active`, `x`, `y`, `vx`, `vy`, `kind`, `amount`, `life`, `pulse` | A floating supply crate (0=fuel, 1=repair, 2=bags) with amount and lifetime |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | A visual particle with velocity, lifetime, size, and color kind |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between low and high bounds |
| `minf` | `(Float, Float) -> Float` | Returns the minimum of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns the maximum of two floats |
| `mini` | `(Int, Int) -> Int` | Returns the minimum of two integers |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `sinf` | `(Float) -> Float` | Returns the sine of a radian angle as Float |
| `randf` | `(Float, Float) -> Float` | Returns a random float between low and high |
| `randi` | `(Int, Int) -> Int` | Returns a random integer between low and high (inclusive) |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Returns the squared distance between two points |
| `inside_rectf` | `(Float, Float, Float, Float, Float, Float) -> Bool` | Tests if a point is inside a float-based rectangle |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside an int-based rectangle |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Tests if mouse or any touch point is inside a rectangle |
| `pointer_on_circle` | `(Float, Float, Bool, Int, Float, Float, Float) -> Bool` | Tests if mouse or any touch point is inside a circle |
| `clear_deliveries` | `(Array[Delivery]) -> Unit` | Deactivates and resets all delivery slots |
| `clear_winds` | `(Array[WindTunnel]) -> Unit` | Deactivates and resets all wind tunnels |
| `clear_birds` | `(Array[Bird]) -> Unit` | Deactivates and resets all birds |
| `clear_crates` | `(Array[Crate]) -> Unit` | Deactivates and resets all crates |
| `clear_particles` | `(Array[Particle]) -> Unit` | Deactivates and resets all particles |
| `spawn_particle` | `(Array[Particle], Float, Float, Float, Float, Float, Float, Int) -> Unit` | Spawns a single particle at position with velocity, lifetime, size, and kind |
| `burst_particles` | `(Array[Particle], Float, Float, Int, Int) -> Unit` | Emits multiple random particles at a position with a given kind |
| `update_particles` | `(Array[Particle], Float) -> Unit` | Updates all active particles: position, drag, gravity, lifetime decay |
| `init_wind_tunnels` | `(Array[WindTunnel], Float, Float, Float, Float) -> Unit` | Initializes 7 fixed wind tunnel zones within the world bounds |
| `active_delivery_count` | `(Array[Delivery]) -> Int` | Returns the count of currently active deliveries |
| `active_delivery_for_pad` | `(Array[Delivery], Int) -> Int` | Returns the count of active deliveries targeting a specific pad ID |
| `spawn_delivery` | `(Array[Delivery], Int, Int, Int) -> Bool` | Spawns a new delivery request with wave-scaled deadline and reward |
| `spawn_bird` | `(Array[Bird], Float, Float, Float, Float, Float) -> Bool` | Spawns a bird from a random edge with pressure-scaled danger |
| `spawn_crate` | `(Array[Crate], Float, Float, Float, Float) -> Bool` | Spawns a random supply crate within world bounds |
| `nearest_pad_id` | `(Array[Pad], Float, Float, Float) -> Int` | Finds the closest pad within radius and returns its ID, or -1 |
| `draw_sky_background` | `(Int, Int, Int, Int, Float) -> Unit` | Draws the gradient sky with animated horizontal wave lines |
| `draw_city_blocks` | `(Int, Int, Int, Int, Float) -> Unit` | Draws the city skyline along the bottom with blinking windows |
| `draw_depot` | `(Depot, Float) -> Unit` | Draws the mail depot with pulsing indicator |
| `draw_pads` | `(Array[Pad], Array[Delivery], Float) -> Unit` | Draws all landing pads, highlighting those with active deliveries |
| `draw_wind_tunnels` | `(Array[WindTunnel], Float) -> Unit` | Draws wind zones with direction arrows and pulsing transparency |
| `draw_birds` | `(Array[Bird], Float) -> Unit` | Draws birds as animated wing-flapping triangles |
| `draw_crates` | `(Array[Crate], Float) -> Unit` | Draws supply crates with colored squares and pulsing glow |
| `draw_particles` | `(Array[Particle]) -> Unit` | Draws all active particles as colored circles with alpha fade |
| `draw_glider` | `(Glider, Float) -> Unit` | Draws the glider as a triangle with boost glow and flare ring |
| `draw_deliveries_panel` | `(Int, Int, Int, Array[Delivery], Float) -> Unit` | Draws the active delivery list with urgency bars and reward info |
| `draw_hud` | `(Int, Int, Int, Int, Float, Int, Int, Float, Float, Float, Int, Int, Int, Int, Int, String) -> Unit` | Draws the full side-panel HUD: timer, score, combo, resource meters, controls, and message |
| `draw_touch_controls` | `(Int, Int, Float, Float, Bool, Int) -> Unit` | Draws the on-screen touch UI with D-pad and action buttons |
| `draw_menu` | `(Int, Int, Float) -> Unit` | Draws the title screen with animated background and start prompt |
| `draw_end` | `(Int, Int, Bool, Int, Int, Float, Int, Int) -> Unit` | Draws the end screen showing win/lose, score, reputation, and stats |

## Architecture

### Package Structure

```
rooftop_mail_glider_2026/
├── main.mbt              -- Entry point: all types, game logic, rendering, and main loop
└── moon.pkg              -- Package config with raylib and math imports
```

This is a single-file game with all code in `main.mbt` (~2350 lines). The file is organized in sections: struct definitions, utility functions, pool management functions, spawning logic, rendering functions, and the main game loop.

### Data Flow

1. **Input**: Each frame reads keyboard state and touch/mouse positions, unifying them into boolean flags (`move_l`, `move_r`, `move_u`, `move_d`, `boost_hold`, `action_press`, `flare_press`) using `pointer_on_rect` and `pointer_on_circle` for touch support.
2. **Physics**: Input is normalized to unit vector, multiplied by acceleration (360 or 560 with boost), added to velocity. Wind tunnels apply directional force with wave-modulated intensity. Velocity is damped and speed-capped. Fuel drains based on speed, boost, and wind turbulence.
3. **Spawning**: Delivery, bird, and crate spawn timers tick down and call their respective spawn functions. Delivery deadlines decrease over time with queue pressure scaling.
4. **Collision**: Birds check squared distance to glider for collision (damage, cargo loss, combo reset). Crates check proximity for pickup (fuel/hull/bags). Station interactions check `inside_rectf` for depot and `nearest_pad_id` for pads.
5. **Win/Lose**: Multiple conditions checked each frame: hull <= 0, reputation <= 0, failed >= 22, timer expiry with score/rep check, or early completion with 52+ deliveries.
6. **Rendering**: Layered drawing: sky background, city blocks, wind tunnels, depot, pads, crates, birds, particles, glider, HUD panel, delivery panel, touch controls. End/menu screens overlay on top.

### Key Design Patterns

- **Object pool pattern**: Birds (120), crates (18), particles (1100), and deliveries (14) all use pre-allocated arrays with `active` flags, preventing heap allocation during gameplay.
- **State machine**: Integer `state` (0=menu, 1=play, 2=win, 3=lose) controls game flow.
- **Wave-based difficulty**: `wave` scales with score (1 per 1000 points), reducing delivery deadlines, increasing bird spawn rate and danger, and accelerating delivery spawning.
- **Dual input system**: Keyboard and touch/mouse inputs are unified through `pointer_on_rect` and `pointer_on_circle` helpers that check both mouse position and all touch points.
- **Reputation meter**: A slowly-decaying reputation value (0-100) acts as a secondary resource, penalized by failed deliveries and bird strikes, rewarded by successful deliveries with combo scaling.
- **Delta-time physics**: All movement and timers use frame-capped `dt` (max 0.033s) for consistent behavior.

## Improvement & Refinement Plan

1. **Extract game state into a struct**: The main function manages over 15 mutable variables (`state`, `timer`, `score`, `rep`, `combo`, `completed`, `failed`, `wave`, `delivery_serial`, spawn cooldowns, `msg`, `msg_t`). Grouping these into a `GameState` struct would simplify `reset_run` and reduce the closure-captured variable count.

2. **Add a minimap or direction indicators**: With 8 pads spread across a large world, players can struggle to locate target pads. Adding directional arrows or a minimap showing active delivery targets would improve navigation.

3. **Reduce `draw_hud` parameter count**: The `draw_hud` function takes 16 parameters. Passing a struct instead would be cleaner and more maintainable.

4. **Implement wind tunnel variation over time**: Currently `init_wind_tunnels` places 7 static zones. Rotating or shifting wind tunnel positions as waves increase would add variety and prevent route memorization.

5. **Add fuel station pads**: Currently only the depot refuels the glider. Adding fuel stations at some pads or as deployable items would create more strategic route options, reducing the forced round-trip to the depot.

6. **Improve bird avoidance feedback**: The flare mechanic scatters birds within 220 pixels but gives limited visual feedback about the effective radius. Drawing the flare radius circle more prominently and showing scattered bird trails would improve player understanding.

7. **Balance reputation decay**: Passive reputation drift (`0.018 + active_count * 0.002` per second) compounds with the 7.6 penalty per failed delivery. At high delivery counts, reputation can collapse quickly. Scaling the passive drift to be inversely proportional to completed deliveries would reward experienced players.
