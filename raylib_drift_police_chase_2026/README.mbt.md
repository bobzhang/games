# Drift Police Chase 2026

Drift Police Chase 2026 is a top-down arcade driving game set in a sprawling neon-lit city grid. The player controls a getaway car fleeing through a 4600x3200 world while collecting scattered cash drops, outrunning police cruisers, and managing a rising wanted heat level. Two types of cops -- regular patrol cars and faster interceptors -- pursue the player with predictive AI that leads its targeting ahead of the player's velocity.

The core gameplay loop revolves around collecting enough cash to meet a per-level goal before time runs out or the car's integrity (HP) reaches zero. Players can activate a speed boost with a 3.2-second cooldown to ram through stunned cops and gain a cash bonus, or deploy a smoke screen on a 4.6-second cooldown to blind nearby cops and reduce the wanted heat meter. Picking up cash drops increases heat and builds a combo multiplier (up to x20), while boosting through cops at high speed stuns them and reduces heat. Each level escalates the cash goal, shortens the timer, and spawns more aggressive cops.

The game features a full particle system with three particle kinds (trail, fire, ice), camera shake on damage, world-space rendering with viewport culling, and touch-screen virtual controls for mobile play. Drifting at speed accumulates a visual drift-mark effect rendered as widening lines behind the car.

## Build and Run

```bash
moon build --target native raylib_drift_police_chase_2026/
./_build/native/debug/build/raylib_drift_police_chase_2026/raylib_drift_police_chase_2026.exe
```

## Controls

- **W / Up Arrow**: Accelerate up
- **S / Down Arrow**: Accelerate down
- **A / Left Arrow**: Accelerate left
- **D / Right Arrow**: Accelerate right
- **Left Shift / Space**: Activate boost (1.2s burst, 3.2s cooldown)
- **E**: Deploy smoke screen (blinds cops, cools heat, 4.6s cooldown)
- **R**: Restart current level
- **Enter / Space**: Start game / advance after round end
- **F11**: Toggle fullscreen
- **Touch Controls**: On-screen D-pad (left side) and BOOST/SMOKE buttons (right side)

## How to Play

Start from the title screen by pressing Enter. Each level has a cash goal (starting at 1700, increasing by 620 per level) and a countdown timer (starting at 184 seconds, decreasing by 14 per level, minimum 98). Move the car with WASD or arrow keys to collect golden cash pickups scattered across the world. Each pickup awards its base value plus a combo bonus (combo * 5), and the combo counter increments with each consecutive pickup up to 20.

Police cars chase the player using predictive targeting with randomized aggression values. Regular cops (kind 0) are red and move at base speed 228; interceptors (kind 1) are orange and move at 286. Cop speed scales with the global heat meter. Getting hit by a cop while not boosting deals 13 + heat*0.12 damage, resets the combo, increases heat by 9, and triggers a knockback with screen shake. Boosting into a cop at speeds above 220 stuns the cop for 1.1 seconds and awards 26 cash.

Smoke screens expand to a 280-unit radius over 3.8 seconds. Any cop inside a smoke cloud gets stunned for 0.85 seconds, and the player's heat decreases by 12 per second while inside the cloud. Heat naturally rises over time and caps at 120.

Completing the cash goal awards bonus points from remaining time and HP, then advances to the next level (up to level 7). The game ends in a "BUSTED" screen if HP reaches zero or time runs out.

## Public API Reference

### Package `raylib_drift_police_chase_2026`

> Main entry point and entire game implementation (single-file architecture).

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width in pixels |
| `sh` | `Int` | `800` | Screen height in pixels |
| `world_w` | `Float` | `4600.0` | World width in game units |
| `world_h` | `Float` | `3200.0` | World height in game units |
| `max_cops` | `Int` | `26` | Maximum number of police cars |
| `max_pickups` | `Int` | `44` | Maximum number of cash pickups |
| `max_smokes` | `Int` | `12` | Maximum number of smoke screens |
| `max_particles` | `Int` | `1200` | Maximum number of particles |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Player` | `x`, `y`, `vx`, `vy`, `hp`, `boost_t`, `smoke_cd`, `cash`, `combo`, `drift` | Player car state including position, velocity, health, ability cooldowns, and scoring |
| `Cop` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `stun_t`, `agro` | Police car with kind (0=regular, 1=interceptor), stun timer, and aggression multiplier |
| `Pickup` | `active`, `x`, `y`, `value`, `spin_t`, `pulse_t` | Cash pickup with position, value, and animation timers |
| `Smoke` | `active`, `x`, `y`, `r`, `t`, `life` | Expanding smoke cloud with radius and lifetime |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `size`, `t`, `life`, `kind` | Visual particle with kind (0=trail, 1=fire, 2=ice) |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value between low and high bounds |
| `randf` | `(Float, Float) -> Float` | Returns a random float in the given range using raylib RNG |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two 2D points |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Point-in-rectangle test for touch input regions |
| `emit_particle` | `(FixedArray[Particle], Float, Float, Float, Float, Float, Float, Int) -> Unit` | Emits a single particle into the first available slot |
| `burst_particles` | `(FixedArray[Particle], Float, Float, Int, Float, Int) -> Unit` | Emits a radial burst of particles at a position |
| `respawn_pickup` | `(FixedArray[Pickup], Int, Int) -> Unit` | Respawns a pickup at a random world position with level-scaled value |
| `init_pickups` | `(FixedArray[Pickup], Int) -> Unit` | Initializes all pickups for a level |
| `init_cops` | `(FixedArray[Cop], Int) -> Unit` | Spawns cops scaled to the current level (10 + level*3, max 26) |
| `spawn_smoke` | `(FixedArray[Smoke], Float, Float) -> Unit` | Creates a smoke cloud at the given position |
| `draw_bar` | `(Int, Int, Int, Int, Float, Color, Color) -> Unit` | Draws a filled progress bar with border |
| `draw_touch_controls` | `(Bool) -> Unit` | Renders on-screen touch control buttons |

## Architecture

### Package Structure

```
raylib_drift_police_chase_2026/
├── main.mbt              -- Entry point, game loop, all logic and rendering
└── moon.pkg              -- Package config, imports raylib and math
```

This is a single-file game. All structs, game logic, input handling, physics, AI, rendering, and UI are contained in `main.mbt`. The main function initializes all entity arrays as `FixedArray` pools, then runs a game loop at 60 FPS with delta-time capping at 33ms.

### Data Flow

Input is sampled at the top of each frame via `is_key_down` and `is_key_pressed` calls, combined with touch input from `inside_rect` hit tests. The game state is driven by an integer `state` variable (0=title, 1=playing, 2=win, 3=busted). During play, the player's velocity is updated via acceleration/drag physics, cops run predictive chase AI with reroute timers, pickups check proximity for collection, smoke clouds expand and decay, and particles are updated independently. Rendering uses world-to-screen coordinate transformation via `cam_x`/`cam_y` offsets with viewport culling for all entities.

### Key Design Patterns

- **Object pool pattern**: All entities (cops, pickups, smokes, particles) use pre-allocated `FixedArray` pools with `active` flags, avoiding dynamic allocation during gameplay.
- **Predictive AI**: Cops target a position ahead of the player (`player.x + player.vx * 0.35`) with random jitter and per-cop aggression values, creating varied pursuit behavior.
- **Heat escalation system**: A global heat meter scales cop speed, damage, and spawn pressure, creating a natural difficulty curve within each level.
- **Camera with shake**: Viewport follows the player with world-boundary clamping, and damage triggers random shake offsets that decay over time.
- **Touch input abstraction**: Virtual button regions are tested against mouse position, allowing the same movement/action flags to drive gameplay regardless of input method.

## Improvement & Refinement Plan

1. **Extract state into a Game struct**: Currently all game state lives as local variables inside `main`. Consolidating them into a `Game` struct (like the multi-package games do) would improve readability and enable extracting update/render into separate functions.

2. **Replace integer state with an enum**: The `state` variable uses raw integers (0-3). A proper `GameState` enum (`Title`, `Playing`, `Won`, `Busted`) would make the match branches self-documenting and prevent invalid states.

3. **Add cop type variety beyond speed**: Currently `kind` only affects base speed (228 vs 286) and a small damage bonus. Adding behavioral differences (e.g., interceptors that dash ahead to cut off the player, patrol cars that set up roadblocks) would deepen the tactical layer.

4. **Implement proper drift mechanics**: The `drift` field accumulates based on speed but has no gameplay effect beyond a visual mark width. Tying drift to a scoring multiplier or making it affect handling would make the "drift" theme more meaningful.

5. **Add a minimap**: With a 4600x3200 world and only a 1280x800 viewport, players have no situational awareness of distant cops or pickups. A corner minimap showing cop positions and pickup clusters would improve strategic play.

6. **Pool smoke clouds more efficiently**: `spawn_smoke` linearly scans the `FixedArray` for an inactive slot. With only 12 slots this is fine, but the same pattern in the 1200-element particle array (`emit_particle`) could benefit from a free-list index.

7. **Separate rendering from game logic**: The `main` function interleaves update logic and draw calls in a single 1400-line function. Splitting into `update(dt)` and `draw()` functions would improve maintainability and enable features like replay or headless testing.
