# Teahouse Midnight Service 2026

A fast-paced teahouse management game set in a cozy late-night establishment. You play as a lone server tasked with brewing and delivering five varieties of tea -- Jasmine, Oolong, Pu-erh, Matcha, and Berry -- to a stream of impatient midnight customers. The dark, starlit atmosphere is rendered with a parallax moon, twinkling ambient particles, and warm wooden interiors.

The core gameplay loop revolves around a multi-step service pipeline: fetch water from the kettle, pick tea leaves from one of five racks, combine them at the brewer station, then rush the finished cup to the correct waiting customer near the counter. Customers arrive in slots, each with a patience timer that drains faster at higher stages. Serving the correct tea earns score and builds a combo multiplier; serving the wrong tea or letting customers leave damages your reputation meter. A Focus Mode mechanic lets you slow patience drain and speed up brewing at the cost of a regenerating focus gauge, while a dash ability provides quick repositioning.

The game features a stage-based progression system where each stage raises the score goal, shortens customer patience, and increases spawn pressure. A reputation bar acts as a health system -- if it empties, or time runs out, the service collapses. Touch controls with on-screen buttons provide full mobile support alongside keyboard and mouse input.

## Build and Run

```bash
moon build --target native teahouse_midnight_service_2026/
./_build/native/debug/build/teahouse_midnight_service_2026/teahouse_midnight_service_2026.exe
```

## Controls

- **W / Up Arrow**: Move up
- **A / Left Arrow**: Move left
- **S / Down Arrow**: Move down
- **D / Right Arrow**: Move right
- **J / E / Space / Left Mouse Button**: Interact (pick up water, select leaves, start brewing, serve tea)
- **K / Left Shift / Right Shift (hold)**: Activate Focus Mode (slows customer patience drain, speeds up brewing)
- **L / Right Mouse Button**: Dash (quick burst of speed in movement direction, costs 14 focus)
- **Enter / R**: Restart / advance stage / return to title
- **Space / Enter**: Start game from title screen
- **Touch controls**: On-screen D-pad (left, right, up, down) plus ACT, FOCUS, and DASH buttons appear in touch mode

## How to Play

From the title screen, press Space or Enter to begin. The teahouse has four stations arranged across the play area:

1. **Kettle** (upper-left area) -- Walk near and press interact to pick up water. A water indicator appears on your character.
2. **Leaf Racks** (left column, five shelves) -- Each shelf holds a different tea type (Jasmine, Oolong, Pu-erh, Matcha, Berry). Walk near and press interact to pick the leaves. A colored dot appears on your character showing which tea you carry.
3. **Brewer** (center-left area) -- When carrying both water and leaves, walk to the brewer and press interact to start brewing. A progress bar fills over ~1.9 seconds (faster at higher stages, and 36% faster in Focus Mode). When complete, a ready cup appears.
4. **Counter / Serve Area** (right side) -- Customers sit in up to 6 slots in the lower-right area. Walk to the counter with a ready cup and press interact near a customer to serve them.

Serving the correct tea type earns base reward points (96 + tea_type * 24 + stage * 12) with a combo multiplier (combo / 5 bonus). Wrong tea angers the customer, reduces reputation by 8, drains focus, and breaks your combo. Customers whose patience runs out leave, costing 12 reputation and 10 focus.

**Focus Mode**: Hold K or Shift to activate. Patience drains at 58% speed, brewing is 36% faster, and movement speed gets a 15% boost. Focus drains at 28 units/second and regenerates at 20 units/second when not held.

**Dash**: Press L or right-click to dash in your movement direction. Costs 14 focus with a 1.5-second cooldown. Useful for rushing between stations.

Each stage requires reaching a score goal (base 1300, +760 per stage). Clearing a stage awards a bonus (340 + stage * 120 points) and auto-advances after 1.9 seconds. The game ends when reputation hits zero or time expires.

## Public API Reference

### Package `teahouse_midnight_service_2026`

> Main entry point. Initializes window (1280x720), audio, and runs the game loop with clamped delta time.

No additional public types or functions beyond `main`.

### Package `teahouse_midnight_service_2026/internal/types`

> Core type definitions, game constants, utility functions, and color helpers.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Customer` | `active`, `tea_type`, `slot`, `patience`, `patience_max`, `reward`, `mood`, `angry` | Represents a seated customer waiting for a specific tea type with a patience timer |
| `Spark` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | Particle effect element for visual feedback (bursts, ambient) |
| `Ring` | `active`, `x`, `y`, `r`, `life`, `kind` | Expanding circle effect used for interaction and event feedback |
| `Shadow` | `active`, `x`, `y`, `w`, `h`, `life`, `rot` | Afterimage shadow left behind during dashes |
| `Player` | `x`, `y`, `vx`, `vy`, `dash_cd`, `dash_t`, `carry_water`, `carry_leaf`, `anim_t` | The server character with movement, dash cooldown, and carried items |
| `Game` | `customers`, `sparks`, `rings`, `shadows`, `player`, `state`, `stage`, `score`, `reputation`, `focus`, `time_left`, `brew_active`, `ready_cup`, `combo` | Main game state container holding all entities, resources, and input state |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Customer::new` | `() -> Customer` | Creates an inactive customer with default values |
| `Spark::new` | `() -> Spark` | Creates an inactive spark particle |
| `Ring::new` | `() -> Ring` | Creates an inactive ring effect |
| `Shadow::new` | `() -> Shadow` | Creates an inactive shadow afterimage |
| `Player::new` | `() -> Player` | Creates a player at default position (628, 468) with no carried items |
| `Game::new` | `() -> Game` | Allocates all object pools and initializes game state to title screen |
| `init_title_scene` | `(Game) -> Unit` | Resets all entities, player, and game state for the title screen |
| `leaf_x` | `() -> Float` | Returns the x-coordinate of the leaf rack column (270.0) |
| `leaf_y` | `(Int) -> Float` | Returns the y-coordinate for a given tea type's leaf shelf |
| `customer_slot_pos` | `(Int) -> (Float, Float)` | Returns the (x, y) position for a customer seating slot (6 slots in 2 rows of 3) |
| `tea_name` | `(Int) -> String` | Returns display name for a tea type index (JASMINE, OOLONG, PU-ERH, MATCHA, BERRY) |
| `tea_color` | `(Int) -> @raylib.Color` | Returns the signature display color for a tea type |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer value between lo and hi |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value between lo and hi |
| `minf` | `(Float, Float) -> Float` | Returns the minimum of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns the maximum of two floats |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `sinf` | `(Float) -> Float` | Computes sine via core math library |
| `cosf` | `(Float) -> Float` | Computes cosine via core math library |
| `sqrtf` | `(Float) -> Float` | Computes square root of a float |
| `lerpf` | `(Float, Float, Float) -> Float` | Linear interpolation between two values |
| `ease_out_cubic` | `(Float) -> Float` | Cubic ease-out function for smooth animations |
| `randf` | `(Float, Float) -> Float` | Random float in [lo, hi] range using raylib RNG |
| `randi` | `(Int, Int) -> Int` | Random integer in [lo, hi] range |
| `chance` | `(Int) -> Bool` | Returns true with pct% probability |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two points |
| `point_in_rect` | `(Float, Float, Float, Float, Float, Float) -> Bool` | Point-in-rectangle hit test |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Float, Float, Float, Float) -> Bool` | Mouse/touch pointer hit test against a rectangle |
| `near_station` | `(Float, Float, Float, Float, Float) -> Bool` | Checks if player is within reach of a station |
| `a_col` | `(@raylib.Color, Int) -> @raylib.Color` | Creates a copy of a color with modified alpha |
| `bg_top` | `() -> @raylib.Color` | Dark blue gradient top color |
| `bg_bottom` | `() -> @raylib.Color` | Medium blue gradient bottom color |
| `amber` | `() -> @raylib.Color` | Warm amber accent color |
| `pink` | `() -> @raylib.Color` | Pink accent color (errors, anger) |
| `cyan` | `() -> @raylib.Color` | Cyan accent color (time bar) |
| `jade` | `() -> @raylib.Color` | Jade green accent color (success, focus) |
| `reputation_col` | `() -> @raylib.Color` | Pink color for reputation bar |
| `focus_col` | `() -> @raylib.Color` | Green color for focus bar |
| `btn_size` | `() -> Float` | Touch button size (98.0) |
| `btn_left_rect` | `() -> (Float, Float, Float, Float)` | Bounding rect for touch left button |
| `btn_right_rect` | `() -> (Float, Float, Float, Float)` | Bounding rect for touch right button |
| `btn_up_rect` | `() -> (Float, Float, Float, Float)` | Bounding rect for touch up button |
| `btn_down_rect` | `() -> (Float, Float, Float, Float)` | Bounding rect for touch down button |
| `btn_interact_rect` | `() -> (Float, Float, Float, Float)` | Bounding rect for touch interact button |
| `btn_focus_rect` | `() -> (Float, Float, Float, Float)` | Bounding rect for touch focus button |
| `btn_dash_rect` | `() -> (Float, Float, Float, Float)` | Bounding rect for touch dash button |
| `title_start_rect` | `() -> (Float, Float, Float, Float)` | Bounding rect for title screen start button |
| `retry_rect` | `() -> (Float, Float, Float, Float)` | Bounding rect for game-over retry button |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | 1280 | Window width |
| `screen_h` | `Int` | 720 | Window height |
| `target_fps` | `Int` | 120 | Target frame rate |
| `hud_h` | `Int` | 110 | HUD bar height in pixels |
| `play_left` | `Float` | 46.0 | Left boundary of play area |
| `play_right` | `Float` | 1234.0 | Right boundary of play area |
| `play_top` | `Float` | 128.0 | Top boundary of play area |
| `play_bottom` | `Float` | 694.0 | Bottom boundary of play area |
| `state_title` | `Int` | 0 | Title screen state |
| `state_play` | `Int` | 1 | Active gameplay state |
| `state_stage_clear` | `Int` | 2 | Stage clear transition state |
| `state_game_over` | `Int` | 3 | Game over state |
| `tea_jasmine` | `Int` | 0 | Jasmine tea type index |
| `tea_oolong` | `Int` | 1 | Oolong tea type index |
| `tea_puer` | `Int` | 2 | Pu-erh tea type index |
| `tea_matcha` | `Int` | 3 | Matcha tea type index |
| `tea_berry` | `Int` | 4 | Berry tea type index |
| `tea_count` | `Int` | 5 | Total number of tea types |
| `max_customers` | `Int` | 24 | Customer object pool size |
| `max_sparks` | `Int` | 860 | Spark particle pool size |
| `max_rings` | `Int` | 86 | Ring effect pool size |
| `max_shadows` | `Int` | 320 | Shadow afterimage pool size |
| `customer_slots` | `Int` | 6 | Number of seating positions |
| `player_w` | `Float` | 46.0 | Player width |
| `player_h` | `Float` | 58.0 | Player height |
| `player_accel` | `Float` | 1260.0 | Player acceleration |
| `player_drag` | `Float` | 3.4 | Player drag coefficient |
| `player_max_speed` | `Float` | 360.0 | Player maximum speed |
| `dash_cd_time` | `Float` | 1.5 | Dash cooldown in seconds |
| `dash_time` | `Float` | 0.2 | Dash duration in seconds |
| `dash_speed` | `Float` | 620.0 | Dash movement speed |
| `interact_reach` | `Float` | 84.0 | Interaction reach distance |
| `serve_reach` | `Float` | 104.0 | Customer serving reach distance |
| `brew_time_base` | `Float` | 1.9 | Base brewing time in seconds |
| `brew_time_min` | `Float` | 1.1 | Minimum brewing time |
| `stage_goal_base` | `Int` | 1300 | Score goal for stage 1 |
| `stage_goal_bonus` | `Int` | 760 | Additional goal per stage |
| `stage_time_base` | `Float` | 72.0 | Base time per stage in seconds |
| `stage_time_bonus` | `Float` | 10.0 | Additional time per stage |
| `reputation_max` | `Float` | 100.0 | Maximum reputation |
| `focus_max` | `Float` | 100.0 | Maximum focus |
| `focus_drain` | `Float` | 28.0 | Focus drain rate per second in Focus Mode |
| `focus_regen` | `Float` | 20.0 | Focus regeneration rate per second |
| `dash_focus_cost` | `Float` | 14.0 | Focus cost per dash |
| `wrong_serve_penalty` | `Float` | 8.0 | Reputation loss for wrong tea |
| `miss_penalty` | `Float` | 12.0 | Reputation loss for missed customer |
| `stage_clear_bonus` | `Int` | 340 | Base score bonus on stage clear |
| `kettle_x` / `kettle_y` | `Float` | 164.0 / 248.0 | Kettle station position |
| `brew_x` / `brew_y` | `Float` | 480.0 / 258.0 | Brewer station position |
| `counter_x` / `counter_y` | `Float` | 958.0 / 250.0 | Serve counter position |

### Package `teahouse_midnight_service_2026/internal/game`

> Game logic, update systems, and input handling.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(@types.Game, Float) -> Unit` | Main update entry point: reads input, dispatches state-specific update, manages timers |

### Package `teahouse_midnight_service_2026/internal/render`

> Rendering and visual effects for all game states.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(@types.Game) -> Unit` | Main render entry point: draws world with camera shake, HUD, state overlays, touch controls, and flash effects |

## Architecture

### Package Structure

```
teahouse_midnight_service_2026/
├── main.mbt              — Entry point: window init (1280x720), audio, game loop
├── moon.pkg              — Package config with raylib and internal imports
└── internal/
    ├── types/
    │   ├── types.mbt     — Core structs (Game, Player, Customer, Spark, Ring, Shadow) and constructors
    │   ├── constants.mbt — All game constants, station positions, color helpers, button rects
    │   └── utils.mbt     — Math utilities (clamp, lerp, trig, random, distance, hit testing)
    ├── game/
    │   ├── logic.mbt     — Game state updates: player movement, brewing, customer spawning/serving, stage progression
    │   └── input.mbt     — Input reading for keyboard, mouse, and touch across all game states
    └── render/
        └── render.mbt    — Full rendering pipeline: sky, room, stations, customers, player, particles, HUD, overlays
```

The types package is the shared data layer with zero logic dependencies. The game package imports types and raylib for input reading. The render package imports types and raylib for drawing. Both game and render are imported by the root package which orchestrates the main loop.

### Data Flow

1. `main` creates a `Game` via `Game::new()` and calls `init_title_scene()` to set up the title state.
2. Each frame, `update_game()` is called with a clamped delta time (max 33ms).
3. Inside `update_game()`, mouse/touch state is read from raylib into `Game` fields. Then a state-specific input function (`update_title_input`, `update_play_input`, or `update_result_input`) maps hardware input to logical input flags (`input_x`, `input_y`, `input_interact_press`, `input_focus_hold`, `input_dash_press`, `input_restart_press`).
4. `update_timers()` advances all cooldowns and animation timers.
5. The state-specific update function runs: `update_title` handles ambient effects, `update_play` drives the full gameplay simulation (focus, player, brew, spawning, customers, effects, win/loss checks), `update_stage_clear` and `update_game_over` handle transition effects.
6. After updates, `draw_frame()` renders the world with optional camera shake, then overlays the HUD and any state-specific overlay (title, stage clear, game over).

### Key Design Patterns

- **Object Pool Pattern**: All dynamic entities (customers, sparks, rings, shadows) use pre-allocated fixed-size arrays with `active` flags and `alloc_*` functions that find the first inactive slot or evict the oldest entry.
- **State Machine**: Integer-based game state (`state_title`, `state_play`, `state_stage_clear`, `state_game_over`) drives both update and render dispatch via if-else chains.
- **Input Abstraction Layer**: Physical inputs (keyboard, mouse, touch) are unified into logical flags in the `Game` struct during the input phase, so game logic only reads abstract actions. Touch edge detection uses `_prev` tracking fields.
- **Station Interaction Model**: Stations are fixed positions with proximity-based interaction. The `apply_interact()` function checks each station in priority order (kettle, leaves, brewer, counter) and applies the first matching action.
- **Combo System**: Consecutive correct serves build a combo counter (up to 30) with a 3.8-second decay timer. Score gain is scaled by `base + base * combo / 5`.
- **Focus Mode**: A hold-to-activate mechanic that trades focus gauge for reduced patience drain (0.58x), faster brewing (1.36x), and increased movement speed (1.15x).
- **Camera Shake**: Screen shake is implemented as random offsets passed through the entire rendering pipeline as `cam_x`/`cam_y` parameters.

## Improvement & Refinement Plan

1. **Replace integer state/tea constants with enums**: The `state_title`/`state_play` and `tea_jasmine`/`tea_oolong` integer constants could be proper MoonBit enums, enabling pattern matching with exhaustiveness checking instead of if-else chains throughout `logic.mbt` and `render.mbt`.

2. **Extract station interaction into a dedicated system**: The `apply_interact()` function handles kettle, leaf, brewer, and counter logic in one monolithic function. Splitting each station into its own interaction handler would improve readability and make it easier to add new stations.

3. **Add audio feedback for key actions**: The `init_audio_device()` call in `main.mbt` initializes audio but no sounds are loaded or played. Adding sound effects for brewing completion, correct/wrong serves, customer arrival, and dash would significantly improve game feel.

4. **Implement difficulty curve smoothing**: The `customer_base_patience()` function linearly reduces patience by 1.1 per stage with a floor of 8.0, and `spawn_cd` pressure increases by 0.08 per stage. These could use a curve (e.g., `ease_out_cubic`) to smooth the difficulty ramp and prevent sudden spikes.

5. **Pool the combo text rendering**: The combo display in `draw_hud()` recalculates alpha every frame. A dedicated `ComboPopup` struct with position animation would allow the combo indicator to pop up near the served customer rather than always appearing at the top of the screen.

6. **Add visual differentiation for customer tea requests**: Currently customers display a small colored circle for their requested tea type. Adding the tea name text or a distinct icon shape per tea type would make it easier for players to quickly identify what each customer wants, especially since five tea colors can be hard to distinguish at a glance.

7. **Persist best score across sessions**: The `best_score` field resets when the game restarts. Writing it to a file or using raylib's storage functions would let players track their high score across play sessions.

8. **Decouple touch button layout from hardcoded positions**: The `btn_*_rect()` functions in `constants.mbt` return fixed pixel positions. Extracting these into a configurable layout system would make it easier to adapt the UI for different screen sizes or aspect ratios.
