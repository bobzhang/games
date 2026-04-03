# Night Market Chef Duel 2026

A cooking management game set in a bustling night market, where the player navigates between kitchen stations to prepare, cook, and serve dishes under pressure. Orders arrive continuously with countdown patience timers, and the player must efficiently move a cursor between an order queue, a prep station, two cooking stations (grill and wok), and a serving pass to fulfill each order before it expires. The game ends when the player accumulates 6 failed orders.

The kitchen workflow follows a two-phase pipeline: first, select an order and begin prepping the dish by pressing J repeatedly at the prep station to fill the prep bar; once prep is complete, the dish moves to the heat phase at either the grill (for Skewers and Char Squid) or the wok (for Noodles and Fried Rice), where pressing J fills the cook bar. When cooking finishes, the completed dish appears at the serve pass, where pressing K delivers it to fulfill the matching order. Four dish types with varying prep/cook requirements and base rewards create a balancing act between quick easy dishes and high-value complex ones.

A combo system rewards consecutive successful deliveries with bonus points (18 per combo level), while a boost ability (Space key, 1.15s duration, 5s cooldown) accelerates both prep and cooking progress. Scoring factors in the base dish reward, remaining patience ratio, cooking quality (penalized by overcooking), and combo multiplier. The spawn rate of new orders accelerates as the game progresses, creating an ever-increasing pace that tests the player's multitasking ability.

## Build and Run

```bash
moon build --target native night_market_chef_duel_2026/
./_build/native/debug/build/night_market_chef_duel_2026/night_market_chef_duel_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move cursor between stations and order slots
- **J**: Cook/Select (start prep, advance prep/cook progress, or select an order)
- **K**: Serve dish at pass / Cancel (deselect order, cancel cooking)
- **Space**: Activate boost (1.15s duration, 5s cooldown, accelerates prep and cooking)
- **P / Escape**: Pause
- **R**: Restart
- **Enter**: Start game (also works as J)

## How to Play

1. **Start**: Press J or Enter on the title screen to begin the duel.
2. **Orders arrive**: Orders appear in the queue panel (left side) with a dish name, ticket number, and a patience bar that counts down. Up to 6 orders can be queued simultaneously.
3. **Select an order**: Move the cursor to an order slot and press J to mark it as the target. The target order determines which dish you will prep next. If no order is selected, the system auto-targets the order with the least patience remaining.
4. **Prep the dish**: Move the cursor to the Prep station and press J to begin prepping the targeted dish. Press J repeatedly to fill the prep bar. Each press adds 0.9 progress (multiplied by 1.7 during boost). Different dishes require different amounts: Skewers (3.2), Fried Rice (3.5), Noodles (3.8), Squid (4.2).
5. **Cook the dish**: Once prep is complete, the dish automatically enters the heat phase. Move the cursor to the correct cooking station -- Grill for Skewers/Squid, Wok for Noodles/Fried Rice -- and press J to add heat progress (1.0 per press, multiplied during boost). Pressing J at the wrong station resets your combo.
6. **Serve the dish**: When cooking finishes, the completed dish appears at the Serve Pass with a quality bar that slowly degrades over time. Move the cursor to the pass and press K to serve it, fulfilling the matching order.
7. **Scoring**: Points = base reward (120-170) + patience bonus (up to 45% of base) + quality bonus (up to 34% of base) + combo bonus (combo x 18). Minimum payout is 18 points per delivery.
8. **Build combos**: Each successful delivery increases the combo counter. The combo resets if no delivery is made within 5 seconds, if cooking is cancelled, or if the wrong station is used.
9. **Use boost wisely**: Press Space when boost is ready to activate a 1.15s speed buff that passively advances prep (at 1.7/s) and heat (at 1.1/s when cursor is on the correct station). Cooldown is 5 seconds.
10. **Avoid failures**: Orders that expire count as failures. Serving a dish with no matching order also counts as a failure. Accumulating 6 failures ends the game.
11. **Difficulty ramp**: As you serve and fail more orders, the spawn interval decreases from 3.4s down to a minimum of 1.15s, and harder dishes (Squid, Fried Rice) appear more frequently.

## Public API Reference

### Package `night_market_chef_duel_2026/internal/types`

> Type definitions, enums, constants, constructors, and utility functions.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `Paused`, `GameOver` | Game state machine states |
| `Dish` | `DishNone`, `Skewers`, `Noodles`, `Squid`, `FriedRice` | Dish types available for cooking |
| `Lane` | `Grill`, `Wok` | Cooking station lanes |
| `CookStage` | `Prep`, `Heat` | Two-phase cooking pipeline stages |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Order` | `active`, `dish`, `patience`, `patience_max`, `reward`, `ticket_no` | Customer order with dish type, countdown timer, and reward value |
| `InputState` | `move_x`, `move_y`, `press_j`, `press_k`, `press_space`, `press_pause`, `press_restart`, `press_start` | Per-frame input capture state |
| `CookingState` | `active`, `dish`, `lane`, `stage`, `prep_progress`, `cook_progress` | Current cooking pipeline state tracking dish, station, phase, and progress |
| `Game` | `orders`, `input`, `cooking`, `state`, `cursor`, `selected_order`, `ready_dish`, `ready_quality`, `score`, `best_score`, `combo`, `combo_timer`, `served_orders`, `failed_orders`, `next_order_id`, `spawn_t`, `elapsed_t`, `boost_t`, `boost_cd`, `flash_t`, `shake_t` | Central game state containing all subsystems |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1280` | Screen width |
| `screen_h` | `Int` | `720` | Screen height |
| `target_fps` | `Int` | `120` | Target frames per second |
| `hud_h` | `Int` | `112` | HUD panel height in pixels |
| `max_orders` | `Int` | `6` | Maximum simultaneous orders in queue |
| `fail_limit` | `Int` | `6` | Number of failed orders that triggers game over |
| `combo_window` | `Float` | `5.0` | Seconds before combo resets without a delivery |
| `spawn_interval_start` | `Float` | `3.4` | Initial order spawn interval in seconds |
| `spawn_interval_min` | `Float` | `1.15` | Minimum order spawn interval at high pressure |
| `patience_base` | `Float` | `19.0` | Base patience time for orders in seconds |
| `patience_floor` | `Float` | `8.5` | Minimum patience time for orders |
| `prep_press_gain` | `Float` | `0.9` | Prep progress per J press |
| `heat_press_gain` | `Float` | `1.0` | Heat progress per J press |
| `boost_time` | `Float` | `1.15` | Boost duration in seconds |
| `boost_cooldown` | `Float` | `5.0` | Boost cooldown in seconds |
| `boost_prep_rate` | `Float` | `1.7` | Passive prep progress per second during boost |
| `boost_heat_rate` | `Float` | `1.1` | Passive heat progress per second during boost (when on correct station) |
| `orders_x` | `Float` | `206.0` | X position of order slots |
| `orders_y0` | `Float` | `176.0` | Y position of first order slot |
| `orders_gap` | `Float` | `76.0` | Vertical gap between order slots |
| `prep_x`, `prep_y` | `Float` | `592.0`, `224.0` | Prep station center position |
| `grill_x`, `grill_y` | `Float` | `470.0`, `454.0` | Grill station center position |
| `wok_x`, `wok_y` | `Float` | `716.0`, `454.0` | Wok station center position |
| `pass_x`, `pass_y` | `Float` | `1030.0`, `312.0` | Serve pass center position |
| `node_prep` | `Int` | `max_orders` (6) | Node index for prep station |
| `node_grill` | `Int` | `max_orders + 1` (7) | Node index for grill station |
| `node_wok` | `Int` | `max_orders + 2` (8) | Node index for wok station |
| `node_pass` | `Int` | `max_orders + 3` (9) | Node index for serve pass |
| `node_count` | `Int` | `max_orders + 4` (10) | Total number of navigable nodes |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Order::new` | `() -> Order` | Creates a new inactive order with default fields |
| `InputState::new` | `() -> InputState` | Creates a new zeroed input state |
| `CookingState::new` | `() -> CookingState` | Creates a new inactive cooking state |
| `Game::new` | `() -> Game` | Creates a new game with all subsystems initialized |
| `order_node_y` | `(Int) -> Float` | Returns the Y coordinate for an order slot |
| `node_pos` | `(Int) -> (Float, Float)` | Returns the (x, y) position for a given node index |
| `node_name` | `(Int) -> String` | Returns a human-readable name for a node |
| `dish_name` | `(Dish) -> String` | Returns the display name of a dish |
| `dish_lane` | `(Dish) -> Lane` | Returns which cooking lane a dish uses (Grill or Wok) |
| `dish_base_reward` | `(Dish) -> Int` | Returns the base point reward for a dish (90-170) |
| `dish_prep_need` | `(Dish) -> Float` | Returns the prep progress required for a dish (3.0-4.2) |
| `dish_cook_need` | `(Dish) -> Float` | Returns the cooking progress required for a dish (3.0-4.0) |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between lo and hi |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between lo and hi |
| `maxf` | `(Float, Float) -> Float` | Returns the larger of two floats |
| `maxi` | `(Int, Int) -> Int` | Returns the larger of two integers |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `randf` | `(Float, Float) -> Float` | Returns a random float in [lo, hi] |
| `randi` | `(Int, Int) -> Int` | Returns a random integer in [lo, hi] |
| `sinf` | `(Float) -> Float` | Sine of a float via core/math |
| `cosf` | `(Float) -> Float` | Cosine of a float via core/math |

### Package `night_market_chef_duel_2026/internal/game`

> Input capture and game logic: order spawning, cooking pipeline, serving, cursor navigation, boost system.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(@types.Game, Float) -> Unit` | Main update entry point: captures input, dispatches to state handlers (title/play/paused/game_over), updates effects |

### Package `night_market_chef_duel_2026/internal/render`

> All rendering: background, stations, order queue, cursor, HUD, and state overlays.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(@types.Game) -> Unit` | Main render entry point: draws background, all stations, orders panel, cursor, HUD, hint line, and state overlays |

### Package `night_market_chef_duel_2026` (main)

> Entry point that initializes the window and runs the game loop.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Initializes raylib window at 1280x720 with MSAA 4x, creates Game, runs update/draw loop |

## Architecture

### Package Structure

```
night_market_chef_duel_2026/
├── main.mbt                    — Entry point: window init, game loop
├── moon.pkg                    — Main package config with imports
└── internal/
    ├── types/
    │   ├── types.mbt           — Enums (GameState, Dish, Lane, CookStage), structs (Order, InputState, CookingState, Game), constructors
    │   ├── constants.mbt       — All game constants: screen size, station positions, timing, progression
    │   ├── utils.mbt           — Utility functions: node position mapping, dish properties, math helpers
    │   └── moon.pkg            — Package config
    ├── game/
    │   ├── input.mbt           — Input capture: keyboard reading into InputState
    │   ├── logic.mbt           — Core game logic: order spawning, cooking pipeline, serving, cursor navigation, boost, state transitions
    │   └── moon.pkg            — Package config
    └── render/
        ├── render.mbt          — All rendering: background, stations, orders, cursor, HUD, overlays
        └── moon.pkg            — Package config
```

Clean separation of concerns across four packages. The `types` package defines all data structures and pure utility functions with no side effects. The `game` package handles input and mutation of the `Game` struct. The `render` package is read-only on `Game` state, producing all visual output. The main package wires them together in a minimal game loop.

### Data Flow

1. **Input**: Each frame, `capture_input` reads keyboard state and populates the `InputState` struct with directional movement (`move_x`, `move_y`) and button presses (`press_j`, `press_k`, `press_space`, `press_pause`, `press_restart`, `press_start`). All inputs are single-frame edge-triggered via `is_key_pressed`.

2. **Update**: The `update_game` function dispatches to state-specific handlers. In the `Play` state: cursor navigation uses a spatial nearest-neighbor algorithm (`move_cursor`) that finds the closest node in the pressed direction across all 10 nodes; J presses are routed based on cursor position (order slot -> select, prep -> start/advance prep, grill/wok -> advance heat, pass -> no action); K presses serve at the pass or cancel cooking/deselect orders; order patience counts down and expired orders register failures; new orders spawn on a timer that accelerates with game progression; the boost system ticks down active time and cooldown; cooking quality degrades passively at the serve pass.

3. **Rendering**: `draw_frame` renders in layer order: gradient background with animated lantern circles, three background panels (order queue area, cooking area, serve area), order slots with dish colors and patience bars, prep/grill/wok/pass stations with progress bars and animations (grill flames), pulsing cursor ring, HUD bar with score/combo/served/failed/boost status, hint line, and state overlays (title/pause/game over).

### Key Design Patterns

- **Node-based cursor navigation**: The UI is navigated via 10 discrete nodes (6 order slots + 4 stations) with spatial directional movement, replacing a grid layout with position-aware nearest-neighbor selection weighted by forward/side distance.
- **Two-phase cooking pipeline**: Each dish goes through Prep (mashing J to fill a bar) and Heat (mashing J at the correct station), creating a physical workflow that mimics real cooking stations.
- **Lane-dish binding**: Dishes are bound to specific cooking lanes via `dish_lane` -- Skewers and Squid use the Grill, Noodles and Fried Rice use the Wok -- forcing the player to plan station usage.
- **Adaptive difficulty**: Order spawn interval decreases from 3.4s toward 1.15s based on cumulative served+failed orders, and dish difficulty distribution shifts toward harder dishes as elapsed time increases.
- **Quality degradation**: Once a dish is ready at the serve pass, its quality drops at 0.045/s, penalizing slow serving and adding time pressure even after cooking completes.
- **Separated state management**: The `Game` struct holds all mutable state, passed by reference to both `update_game` and `draw_frame`, with the render package being purely read-only.

## Improvement & Refinement Plan

1. **Add touch/mobile input support**: The game currently only supports keyboard input. Adding on-screen buttons for station selection, cook action, and serve would make it playable on touch devices, matching other games in this collection.

2. **Add visual particle effects**: Successful deliveries, failed orders, and boost activation have no particle feedback. Adding burst particles on serve (gold), failure (red), and boost activation (blue) would improve the visual experience.

3. **Implement a shift/wave system with win condition**: The game currently has no win state -- it runs until 6 failures. Adding timed shifts with target scores (e.g., "earn 2000 points in 180 seconds") would give players a clear goal and sense of progression.

4. **Add dish cooking animations**: The grill station has flame animations, but the actual food being prepared is not visually represented. Drawing the dish icon or a simplified food graphic on the active station during cooking would improve visual feedback.

5. **Add sound effects**: The game has no audio. Sizzling sounds for grill/wok, a bell chime on successful delivery, a buzzer on failure, and a rhythmic chop sound during prep would significantly enhance immersion.

6. **Show combo timer visually**: The combo timer (5 seconds) is tracked but not displayed to the player. Adding a shrinking arc or bar near the combo counter would help players time their deliveries to maintain combos.

7. **Add order preview and queue management**: Players cannot see upcoming orders or influence which dish to cook next beyond manual selection. A preview of the next incoming dish or the ability to refuse orders would add strategic depth.

8. **Implement difficulty levels**: The single difficulty curve may be too fast for new players or too slow for experts. Adding Easy/Normal/Hard modes with different `spawn_interval_min`, `patience_base`, and `fail_limit` values would improve accessibility.
