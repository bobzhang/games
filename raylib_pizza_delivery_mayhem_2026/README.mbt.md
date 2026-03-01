# Pizza Delivery Mayhem 2026

Pizza Delivery Mayhem 2026 is a top-down arcade delivery game where the player rides a scooter through a grid-based city, picking up pizza orders from three restaurants and racing to deliver them to customers scattered across the map. The city is filled with traffic -- sedans, vans, and buses -- that damages the scooter on collision, along with fuel canisters, repair kits, and nitro drinks that spawn on the roads.

The core gameplay loop involves navigating to a restaurant (marked P1, P2, P3) to pick up an order using the action key, then racing to the customer's delivery location before the order timer expires. Successful deliveries earn points based on order value, time bonus, and combo multiplier. The run lasts 210 seconds with a score goal of 2200 points; reaching the goal triggers a win, while losing all 3 lives or running out of time results in failure. Traffic density and order frequency escalate across 12 waves.

The game features a physics-driven scooter with velocity damping and environmental drift, a boost system (Shift key or nitro pickup) that increases speed at the cost of higher fuel consumption, a depot for repairs, and a context-sensitive hint system that points to the most useful target based on the player's current situation.

## Build and Run

```bash
moon build --target native raylib_pizza_delivery_mayhem_2026/
./_build/native/debug/build/raylib_pizza_delivery_mayhem_2026/raylib_pizza_delivery_mayhem_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Steer the scooter
- **Shift / J**: Boost (increases speed by 55%, consumes fuel faster)
- **Space / E**: Action -- pick up orders near restaurants, deliver orders near customers, repair at depot
- **Q**: Repair scooter at depot (costs 8 fuel, restores 30 HP)
- **H**: Use a hint (shows nearest relevant target; limited to 3 per run, costs 5 score)
- **R**: Restart the run
- **Escape**: Return to title screen
- **Mouse / Touch**: On-screen D-pad (L/R/U/D), Boost (BST), Action (ACT), Hint (HNT), Restart (RST) buttons

## How to Play

Press Enter, Space, or click "Start Shift" on the title screen to begin. Your scooter starts in the center of the city grid. Three pizza restaurants (P1, P2, P3) are positioned around the map, and a depot is in the upper right for scooter repairs.

Orders spawn periodically with a pickup location (a restaurant) and a delivery destination. Navigate to the restaurant and press Space/E when within range to pick up the order. A small cargo indicator appears on your scooter. Then navigate to the delivery point (marked with a green DL circle) and press Space/E again to complete the delivery. Each delivery earns the order's base value (70-130 points) plus a time bonus (4-36 points based on remaining timer) plus 3 points per combo level.

Deliveries must be completed before their individual timers expire (16-42 seconds depending on wave). A maximum of 4 orders can be active simultaneously. Missing an order costs 22 score and resets your combo.

Traffic spawns from the edges of the map along road lanes. Sedans deal 16 damage, vans deal 22, and buses deal 32. When scooter HP reaches zero, you lose a life and respawn at the center with full HP but reduced fuel. If you are carrying cargo when wrecked, the order drops at your crash location (it can still be picked up).

Fuel drains at 1.1/s normally or 2.5/s while boosting (plus a small wave scaling). Running out of fuel causes HP to drain at 6/s. Collect fuel canisters (yellow, +30 fuel), repair kits (pink, +24 HP), and nitro drinks (purple, +7s turbo) that spawn every 3.3 seconds.

The depot allows manual repairs: press Q or the ACT touch button while near the depot to spend 8 fuel for 30 HP and 12 score points. The hint system (H key or HNT button) highlights the most relevant target: your delivery destination if carrying cargo, nearest fuel pickup if fuel is below 40, or the nearest unpicked order otherwise.

The run ends at 210 seconds or when all lives are lost. Reaching 2200 points at any time wins immediately. Reaching 80% of the goal (1760) by timeout also counts as a win.

## Public API Reference

### Package `raylib_pizza_delivery_mayhem_2026`

> Main entry point. Initializes window and audio, creates game state, runs main loop with mouse/touch input sampling.

No additional public types or functions beyond the `main` entry point.

### Package `raylib_pizza_delivery_mayhem_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Traffic` | `active`, `x`, `y`, `vx`, `vy`, `w`, `h`, `kind`, `phase` | A traffic vehicle with position, velocity, dimensions, type, and animation phase |
| `Order` | `active`, `picked`, `x_from`, `y_from`, `x_to`, `y_to`, `timer`, `value` | A delivery order with pickup/delivery locations, countdown timer, and point value |
| `Pickup` | `active`, `x`, `y`, `vx`, `vy`, `kind`, `phase` | A collectible item (fuel, repair, or speed) floating on the map |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | Visual particle effect with position, velocity, lifetime, and type |
| `Game` | `traffic`, `orders`, `pickups`, `particles`, `state`, `rider_x`, `rider_y`, `lives`, `scooter_hp`, `fuel`, `score`, `combo`, `wave` | Main game state containing all entity pools, rider state, resources, and progression |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Traffic::new` | `() -> Traffic` | Creates an inactive traffic vehicle |
| `Order::new` | `() -> Order` | Creates an inactive delivery order |
| `Pickup::new` | `() -> Pickup` | Creates an inactive pickup item |
| `Particle::new` | `() -> Particle` | Creates an inactive particle |
| `Game::new` | `() -> Game` | Creates a new game with pre-allocated pools (220 traffic, 90 orders, 80 pickups, 1600 particles) |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | 1720 | Window width |
| `screen_h` | `Int` | 980 | Window height |
| `target_fps` | `Int` | 120 | Target frame rate |
| `state_title` | `Int` | 0 | Title screen state |
| `state_play` | `Int` | 1 | Active gameplay state |
| `state_result` | `Int` | 2 | End-of-run result screen state |
| `traffic_sedan` | `Int` | 0 | Sedan vehicle type (16 dmg) |
| `traffic_bus` | `Int` | 1 | Bus vehicle type (32 dmg) |
| `traffic_van` | `Int` | 2 | Van vehicle type (22 dmg) |
| `pickup_fuel` | `Int` | 0 | Fuel canister pickup (+30 fuel) |
| `pickup_repair` | `Int` | 1 | Repair kit pickup (+24 HP) |
| `pickup_speed` | `Int` | 2 | Nitro drink pickup (+7s turbo) |
| `max_traffic` | `Int` | 220 | Maximum traffic pool size |
| `max_orders` | `Int` | 90 | Maximum order pool size |
| `max_pickups` | `Int` | 80 | Maximum pickup pool size |
| `max_particles` | `Int` | 1600 | Maximum particle pool size |
| `world_x0` | `Int` | 24 | World area left edge |
| `world_y0` | `Int` | 20 | World area top edge |
| `world_w` | `Int` | 1120 | World area width |
| `world_h` | `Int` | 940 | World area height |
| `panel_x0` | `Int` | 1168 | Side panel left edge |
| `panel_w` | `Int` | 528 | Side panel width |
| `road_step` | `Int` | 112 | Grid road spacing in pixels |
| `rider_r` | `Float` | 20.0 | Rider collision radius |
| `run_time_goal` | `Float` | 210.0 | Maximum run duration in seconds |
| `score_goal` | `Int` | 2200 | Score needed for immediate win |

#### UI Rect Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `start_button_rect` | `() -> (Int, Int, Int, Int)` | Title screen start button bounds |
| `retry_button_rect` | `() -> (Int, Int, Int, Int)` | Result screen retry button bounds |
| `btn_left` | `() -> (Int, Int, Int, Int)` | Touch D-pad left button bounds |
| `btn_right` | `() -> (Int, Int, Int, Int)` | Touch D-pad right button bounds |
| `btn_up` | `() -> (Int, Int, Int, Int)` | Touch D-pad up button bounds |
| `btn_down` | `() -> (Int, Int, Int, Int)` | Touch D-pad down button bounds |
| `btn_boost` | `() -> (Int, Int, Int, Int)` | Touch boost button bounds |
| `btn_action` | `() -> (Int, Int, Int, Int)` | Touch action button bounds |
| `btn_hint` | `() -> (Int, Int, Int, Int)` | Touch hint button bounds |
| `btn_restart` | `() -> (Int, Int, Int, Int)` | Touch restart button bounds |
| `restaurant_x` | `(Int) -> Float` | Returns X position of restaurant i (0-2) |
| `restaurant_y` | `(Int) -> Float` | Returns Y position of restaurant i (0-2) |
| `depot_x` | `() -> Float` | Returns depot center X |
| `depot_y` | `() -> Float` | Returns depot center Y |
| `depot_w` | `() -> Int` | Returns depot width (160) |
| `depot_h` | `() -> Int` | Returns depot height (120) |

#### Utility Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `mini` | `(Int, Int) -> Int` | Minimum of two integers |
| `maxi` | `(Int, Int) -> Int` | Maximum of two integers |
| `clampi` | `(Int, Int, Int) -> Int` | Clamp integer to range |
| `clampf` | `(Float, Float, Float) -> Float` | Clamp float to range |
| `minf` | `(Float, Float) -> Float` | Minimum of two floats |
| `maxf` | `(Float, Float) -> Float` | Maximum of two floats |
| `absf` | `(Float) -> Float` | Absolute value of float |
| `sinf` | `(Float) -> Float` | Sine of float |
| `cosf` | `(Float) -> Float` | Cosine of float |
| `randf` | `(Float, Float) -> Float` | Random float in [lo, hi] |
| `world_left` | `() -> Float` | World left boundary as float |
| `world_right` | `() -> Float` | World right boundary as float |
| `world_top` | `() -> Float` | World top boundary as float |
| `world_bottom` | `() -> Float` | World bottom boundary as float |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two points |
| `point_in_rectf` | `(Float, Float, Float, Float, Float, Float) -> Bool` | Point-in-rectangle test (float coords) |
| `circle_rect_hit` | `(Float, Float, Float, Float, Float, Float, Float) -> Bool` | Circle-rectangle collision test |
| `point_in_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Point-in-rectangle test (int rect) |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Mouse/touch hit test on rectangle |

### Package `raylib_pizza_delivery_mayhem_2026/internal/game`

> Game logic, entity spawning/updating, and input handling.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(@types.Game, Float) -> Unit` | Main per-frame update: dispatches input handling and gameplay update based on current state |

### Package `raylib_pizza_delivery_mayhem_2026/internal/render`

> Rendering for the city map, entities, HUD panel, touch controls, and state overlays.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(@types.Game) -> Unit` | Main rendering entry point: draws city background, orders, traffic, pickups, rider, panel, touch controls, messages, and state overlays |

## Architecture

### Package Structure

```
raylib_pizza_delivery_mayhem_2026/
├── main.mbt              — Entry point: window/audio init, mouse/touch sampling, game loop
├── moon.pkg              — Package config with imports
└── internal/
    ├── types/
    │   ├── types.mbt     — Traffic, Order, Pickup, Particle, Game structs and constructors
    │   ├── constants.mbt — State IDs, entity types, pool sizes, world dimensions, UI rects
    │   └── utils.mbt     — Math helpers, collision tests, pointer hit detection
    ├── game/
    │   ├── logic.mbt     — Run lifecycle, spawning, rider physics, order/traffic/pickup updates, hint system
    │   └── input.mbt     — Keyboard and touch input detection per state
    └── render/
        └── render.mbt    — City grid, restaurants, depot, traffic/pickup/order drawing, rider, panel, overlays
```

The `types` package holds all shared data structures, pool size constants, world geometry, and collision utilities. The `game` package manages all state mutation including entity spawning with weighted random distributions, rider physics with velocity damping and environmental drift, order lifecycle (spawn, pick, deliver, expire), traffic collision with damage and life loss, and pickup collection. The `render` package draws the city grid, all entities with shake offset, a comprehensive side panel with stats and controls, and state-dependent overlays.

### Data Flow

1. **Input**: `main.mbt` samples mouse position and touch count each frame. `input.mbt` dispatches to state-specific handlers: `update_title_input` checks for start, `update_play_input` reads WASD/arrow keys and touch buttons to set `move_x`, `move_y`, `boost_on`, and `action_on` on the Game struct, and `update_result_input` checks for retry.
2. **Update**: `update_play` in `logic.mbt` runs timers, checks win/loss conditions, scales wave difficulty, spawns orders/traffic/pickups on interval timers, updates rider physics via `update_rider`, processes orders via `update_orders`, resolves traffic collisions via `update_traffic`, collects pickups via `update_pickups`, and drains fuel.
3. **Render**: `draw_frame` computes screen shake offset, draws the city grid with road lines, restaurants, and depot, then renders all active orders (pickup/delivery markers with connecting lines), traffic vehicles, pickups, hint indicator, particles, rider, side panel, touch controls, and message banner.

### Key Design Patterns

- **Object pool pattern**: Four pre-allocated pools (traffic: 220, orders: 90, pickups: 80, particles: 1600) with `active` flags avoid runtime allocation.
- **Wave-based difficulty scaling**: Wave number (1-12, advancing every 22 seconds) reduces order timers, increases traffic spawn rate, and adds environmental drift.
- **Context-sensitive hint system**: `use_hint` examines the player's current state (carrying cargo, low fuel, or looking for orders) to select the most helpful target.
- **Combo multiplier**: Consecutive deliveries within a 2.2-second window build a combo (capped at 18) that adds 3 points per level to each delivery.
- **Dual resource pressure**: Scooter HP and fuel are independent resources that interact -- boosting drains fuel faster, running empty drains HP, and wrecking costs both fuel and cargo.
- **Order drop-on-wreck**: When the rider is wrecked while carrying cargo, the order's pickup location is moved to the crash site rather than being lost, giving a second chance.
- **Shake offset rendering**: `shake_x` and `shake_y` generate random per-frame offsets during `shake_t > 0`, applied to all world-space drawing for impact feedback.

## Improvement & Refinement Plan

1. **Use enums for state, traffic kind, and pickup kind**: Integer constants like `state_title`, `traffic_sedan`, and `pickup_fuel` would benefit from proper enum types for type safety and exhaustive pattern matching throughout `logic.mbt` and `render.mbt`.

2. **Implement a minimap or compass**: The world is 1120x940 pixels with orders and pickups scattered across it. Adding a minimap in the panel showing active order locations and nearby pickups would reduce reliance on the limited hint system, especially since orders can be far from the rider.

3. **Add traffic lane awareness to spawn logic**: `spawn_traffic` in `logic.mbt` places vehicles on random road lanes. Adding awareness of existing traffic to avoid spawning new vehicles directly on top of others would improve fairness and visual clarity.

4. **Balance fuel drain rates per wave**: The base fuel drain (1.1/s normal, 2.5/s boost) scales only slightly with wave (0.06/0.10 per wave). At higher waves, fuel becomes trivially managed if pickups spawn consistently. Tying fuel drain more aggressively to wave number or reducing pickup spawn rate at higher waves would maintain pressure.

5. **Extract entity update functions into separate modules**: `logic.mbt` contains all spawning, updating, and collision logic for traffic, orders, pickups, and the rider in a single 810-line file. Splitting into `internal/traffic/`, `internal/orders/`, and `internal/pickups/` packages would improve organization.

6. **Add a delivery route preview**: When carrying cargo, drawing a line or arrow from the rider to the delivery destination (similar to the hint line but permanent) would reduce navigation confusion without requiring hint usage.

7. **Implement a scoring breakdown on the result screen**: The result overlay shows total score but not how it was earned. Adding a breakdown (delivery points, pickup bonuses, combo bonuses, repair bonuses) using data already tracked in the Game struct would give players better feedback on their performance.
