# Tea Mountain Express 2026

Tea Mountain Express is a high-speed mountain delivery racing game set on treacherous winding passes. Players pilot a tea caravan through a perspective-scrolling road, dodging rockfalls, landslides, and crosswinds while keeping cargo quality, cart durability, and contract reputation above zero.

The core gameplay loop revolves around reaching successive checkpoints before a schedule timer expires. Each checkpoint acts as a delivery point: arriving on time with acceptable cargo quality and cart durability earns a successful delivery, increasing the score multiplier up to x6. Failed deliveries (late, damaged cargo, or broken cart) reset the multiplier and slash reputation. The player must constantly balance speed (boosting generates boiler heat) against safety (stabilizing dampens wobble but slows you down).

Technically, the game features a pseudo-3D perspective road system where road center and lane positions are computed per-scanline using sinusoidal curves driven by a world time parameter, creating convincing mountain curves without 3D rendering. A near-miss combo system rewards lane-sharing hazards that just barely pass behind the cart, and a full boiler heat/overheat mechanic adds resource management depth beyond simple obstacle avoidance.

## Build and Run

```bash
moon build --target native tea_mountain_express_2026/
./_build/native/debug/build/tea_mountain_express_2026/tea_mountain_express_2026.exe
```

## Controls

- **A/D or Left/Right**: Switch lane (3 lanes total)
- **W/S or Up/Down**: Tilt the cart (affects wobble absorption against hazards)
- **J**: Quick brake (reduces speed, cools boiler heat by 10, costs 0.2s schedule time) and confirm/start
- **K (hold)**: Stabilize cargo (dampens tilt wobble, reduces speed via penalty, cools boiler heat faster, slightly restores cargo quality)
- **Space**: Fire booster (0.9s burst of extra acceleration; locked if boiler heat >= 88; 2.3s cooldown)
- **P**: Pause / unpause
- **R**: Restart run
- **F11**: Toggle borderless windowed mode

## How to Play

Press J on the title screen to dispatch the caravan. The cart starts in the center lane at base speed (260 km/h) and automatically accelerates toward the road ahead. Steer between three lanes to avoid hazards that scroll toward you.

**Hazards** come in three types: Rocks (circle, neutral tilt bias, 15 durability / 13 cargo damage), Landslides (triangle debris, left tilt bias, 21 durability / 16 cargo damage), and Crosswinds (ring pattern, right tilt bias, 11 durability / 18 cargo damage). Tilting toward a hazard's bias direction reduces collision damage; holding K (stabilize) further reduces it by 24%. High boiler heat amplifies damage.

**Checkpoints** are spaced at increasing distances (base 1500m + 180m per checkpoint). Each checkpoint has a shrinking time limit (starting at 23s, minimum 10.5s). At a checkpoint, three conditions are evaluated: on-time arrival, cargo quality >= 34%, and cart durability >= 26%. Meeting all three earns a successful delivery with score bonus, multiplier increase, and reputation gain. Failing any condition incurs reputation loss and multiplier reset.

**Booster** provides a 0.9-second speed burst with 540 extra acceleration but generates 38 heat/second. If boiler heat exceeds 100, the cart takes continuous durability, cargo quality, and reputation damage until heat cools. Stabilizing (K) cools heat faster (18/s vs 14/s idle). Braking instantly cancels boost and removes 10 heat.

**Game Over** occurs when durability, cargo quality, or reputation reaches zero.

## Public API Reference

### Package `tea_mountain_express_2026`

> Main entry point.

The `main` function initializes a 1440x900 window with MSAA 4x, creates a `Game` instance, and runs the game loop with clamped delta time. It delegates updates to `@game.update_game` and rendering to `@render.draw_frame`.

### Package `tea_mountain_express_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Playing`, `Paused`, `GameOver` | Game state machine states |
| `HazardKind` | `Rock`, `Landslide`, `Crosswind` | Types of road hazards with different damage profiles |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Hazard` | `active`, `lane`, `y`, `speed`, `size`, `kind`, `near_miss_awarded` | An obstacle on the road that scrolls toward the player |
| `Game` | `state`, `lane`, `lane_x`, `tilt`, `speed`, `distance`, `cargo_quality`, `durability`, `reputation`, `multiplier`, `score`, `boost_heat`, `hazards` | Main game state container holding all gameplay variables |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | 1440 | Window width |
| `screen_h` | `Int` | 900 | Window height |
| `target_fps` | `Int` | 120 | Target frame rate |
| `lane_count` | `Int` | 3 | Number of road lanes |
| `max_hazards` | `Int` | 72 | Object pool size for hazards |
| `speed_base` | `Float` | 260.0 | Starting speed |
| `speed_max` | `Float` | 430.0 | Maximum normal speed |
| `boost_duration` | `Float` | 0.9 | Boost burst duration in seconds |
| `boost_cooldown` | `Float` | 2.3 | Cooldown between boosts |
| `boost_heat_critical` | `Float` | 100.0 | Overheat threshold |
| `checkpoint_distance_base` | `Float` | 1500.0 | Base distance between checkpoints |
| `delivery_score_base` | `Int` | 180 | Base score for a successful delivery |
| `delivery_multiplier_max` | `Int` | 6 | Maximum score multiplier |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Hazard::new` | `() -> Hazard` | Creates an inactive hazard with default values |
| `Game::new` | `() -> Game` | Creates a new game in Title state with all defaults initialized |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer to a range |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to a range |
| `minf` | `(Float, Float) -> Float` | Returns the smaller of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns the larger of two floats |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `clamp01` | `(Float) -> Float` | Clamps a float to the 0.0..1.0 range |
| `sinf` | `(Float) -> Float` | Sine function via Float conversion |
| `cosf` | `(Float) -> Float` | Cosine function via Float conversion |
| `randf` | `(Float, Float) -> Float` | Random float in the given range |
| `randi` | `(Int, Int) -> Int` | Random integer in the given range |
| `road_depth` | `(Float) -> Float` | Computes normalized depth (0..1) for a given screen Y |
| `road_half_width` | `(Float) -> Float` | Returns the road half-width at a given Y for perspective scaling |
| `road_center_x` | `(Float, Float) -> Float` | Computes the road center X using sinusoidal curves at given world time and Y |
| `lane_center_x` | `(Float, Int, Float) -> Float` | Returns the X position for a specific lane at given world time and Y |
| `checkpoint_segment_distance` | `(Int) -> Float` | Distance for a checkpoint segment given its index |
| `checkpoint_time_limit` | `(Int) -> Float` | Time limit for a checkpoint given its index |
| `hazard_name` | `(HazardKind) -> String` | Display name for a hazard kind |
| `hazard_tilt_bias` | `(HazardKind) -> Float` | Optimal tilt direction to reduce damage from a hazard |
| `hazard_durability_hit` | `(HazardKind) -> Float` | Durability damage dealt by a hazard on collision |
| `hazard_cargo_hit` | `(HazardKind) -> Float` | Cargo quality damage dealt by a hazard on collision |

### Package `tea_mountain_express_2026/internal/game`

> Game logic, input handling, and update systems.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main update entry point: processes input, advances world time, dispatches to state-specific handlers |

### Package `tea_mountain_express_2026/internal/render`

> Rendering and visual effects.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main rendering entry point: draws background, road, hazards, cart, HUD, and state overlays |

## Architecture

### Package Structure

```
tea_mountain_express_2026/
├── main.mbt              -- Entry point: window init, game loop, F11 toggle
├── moon.pkg              -- Package config, imports all internal packages
└── internal/
    ├── types/
    │   ├── types.mbt     -- GameState, HazardKind enums; Game, Hazard structs; constructors
    │   ├── constants.mbt -- All tuning values (speeds, damages, distances, thresholds)
    │   └── utils.mbt     -- Math helpers, road geometry, checkpoint calculations, hazard property lookups
    ├── game/
    │   ├── input.mbt     -- Keyboard input polling into Game fields
    │   └── logic.mbt     -- State machine, movement, boost/heat, hazard spawning/collision, checkpoint resolution
    └── render/
        └── render.mbt    -- Background mountains, perspective road, hazard sprites, cart, HUD meters, overlays
```

The main package creates the window and runs a simple loop that calls `update_game` and `draw_frame` each frame. The types package defines all data structures and constants in a dependency-free manner (aside from `math` and `raylib` for random/trig). The game package reads input into fields on the Game struct, then the logic module uses those fields to drive state transitions and physics. The render package reads the Game struct to draw everything, never modifying game state.

### Data Flow

1. `main.mbt` calls `@game.update_game(game, dt)` which first calls `update_input(game)` to poll all keys and write results into `game.input_*` fields.
2. A state machine dispatches to the appropriate handler: `update_playing` for active gameplay, or simple restart/unpause checks for other states.
3. `update_playing` processes lane switching, tilt interpolation, brake/boost, speed/drag physics, heat management, distance accumulation, hazard spawning via `spawn_hazard`, hazard movement and collision via `update_hazards`, and checkpoint resolution via `resolve_checkpoint`.
4. `main.mbt` then calls `@render.draw_frame(game)` which draws the background mountains, perspective road scanlines, hazards at their lane positions, the tilting cart, HUD meters (cargo, durability, reputation, heat, schedule), and any state overlay (title, pause, game over).

### Key Design Patterns

- **Object pool pattern**: The `hazards` array is pre-allocated to `max_hazards` (72) with `active` flags. `alloc_hazard_slot` finds an inactive slot or evicts the farthest hazard.
- **State machine**: `GameState` enum drives which update and render logic runs. State transitions happen through explicit field assignment (`game.state = Playing`).
- **ECS-like separation**: Types, game logic, and rendering are strictly separated into their own packages. The `Game` struct is the single shared data object.
- **Pseudo-3D perspective**: `road_center_x`, `road_half_width`, and `lane_center_x` compute positions per-scanline row using depth-dependent scaling and sinusoidal curves, creating a convincing winding road effect.
- **Input buffering**: All input is polled once per frame into `input_*` fields on the Game struct, ensuring consistent reads throughout the update.
- **Near-miss combo**: Hazards that share the player's lane but pass beyond `cart_y + hazard_pass_window` without collision award increasing combo points.

## Improvement & Refinement Plan

1. **Add difficulty scaling for hazard variety**: Currently `spawn_hazard` uses fixed probability weights (45% Rock, 34% Landslide, 21% Crosswind). Adjusting weights based on `checkpoint_index` would create more varied late-game challenges.

2. **Implement persistent high score**: The `best_score` field resets when the program exits. Adding file-based persistence would let players track progress across sessions.

3. **Decouple road geometry from screen dimensions**: `road_center_x` hardcodes `screen_w * 0.5` and `road_half_width` uses magic numbers (130.0, 440.0). Deriving these from `screen_w` constants would support resolution changes.

4. **Add audio feedback for hazard collisions and checkpoints**: The game has no sound. Adding collision impact sounds and checkpoint chimes using raylib audio functions would significantly improve game feel.

5. **Extract hazard damage calculation into a pure function**: `handle_hazard_collision` mixes damage computation with state mutation. A pure `compute_hazard_damage(kind, tilt, stabilize, heat) -> (Float, Float)` function would be easier to test and tune.

6. **Add visual telegraph for incoming hazards**: Hazards spawn above the visible road area and arrive suddenly. A lane-colored indicator at the road top would give players more reaction time, especially at high speeds.

7. **Implement checkpoint visual markers on the road**: The `next_checkpoint_distance` is only shown as a number in the HUD. Drawing a visual marker on the road surface (like a colored line approaching) would make distance feel more tangible.
