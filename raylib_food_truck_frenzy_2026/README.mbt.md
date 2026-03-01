# Food Truck Frenzy 2026

A fast-paced kitchen management game set inside a bustling food truck. Players control a chef navigating a compact workspace filled with ingredient bins, stoves, a serving window, a sink, and a ventilation fan. The core loop revolves around collecting ingredients, cooking recipes at stove stations, and serving customer orders before their deadlines expire.

The game introduces escalating pressure through a wave system that increases order frequency and tightens deadlines over time. Three environmental meters -- reputation, truck heat, and cleanliness -- interact with each other: heat rises from cooking and accelerates dirt accumulation, dirt reduces cooking speed and erodes reputation, and neglecting orders directly tanks reputation. Players must balance time between cooking, cleaning, cooling, and serving to survive a six-minute shift and reach the score target of 9,200 points.

The single-file architecture packs all gameplay systems (physics, order management, recipe logic, particle effects, touch controls) into one `main.mbt`, making it a compact but fully-featured time-management game with five recipe types, nine station kinds, combo scoring, and mobile touch support.

## Build and Run

```bash
moon build --target native raylib_food_truck_frenzy_2026/
./_build/native/debug/build/raylib_food_truck_frenzy_2026/raylib_food_truck_frenzy_2026.exe
```

## Controls

- **W / Up Arrow**: Move chef up
- **A / Left Arrow**: Move chef left
- **S / Down Arrow**: Move chef down
- **D / Right Arrow**: Move chef right
- **Space / J**: Boost movement speed (drains stamina)
- **L / U**: Interact with stations (collect ingredients, cook, serve, clean, cool)
- **R / Enter**: Restart (on end screen)
- **F11**: Toggle fullscreen
- **Touch D-pad**: On-screen directional pad (mobile)
- **Touch BOOST button**: Speed boost (mobile)
- **Touch ACT button**: Interact (mobile)

## How to Play

1. **Collect ingredients**: Walk to the five ingredient bins (Bun, Meat, Veg, Sauce, Noodle) along the left wall and press Interact to gather 2-4 units each time. Supply boxes also spawn randomly across the truck floor and are picked up by walking over them.

2. **Cook recipes**: Walk to the Stove station and press Interact. The game automatically selects the most urgent recipe you have ingredients for. There are two stove slots, and cooking takes 4.4 to 6.0 seconds depending on the recipe. Higher truck heat slows cooking.

3. **Serve orders**: Walk to the Window station and press Interact. The earliest order that matches a ready meal is served. You earn the base reward plus a time bonus and combo multiplier. Combo stacks up to 30x and resets when an order expires.

4. **Manage environment**: Walk to the Sink to restore cleanliness (+28) and reduce heat (-8). Walk to the Fan for a larger cooling blast (-24 heat) and stamina recovery (+20). Both are critical as heat and dirt continuously worsen during the shift.

5. **Win/Lose conditions**: The shift lasts 360 seconds (6 minutes). Win by reaching 9,200 points with reputation at or above 40%. Lose if reputation drops to 0% at any time, or if you finish the shift below the score target or below 40% reputation.

### Recipes

| Recipe | Ingredients Required | Cook Time | Base Reward |
|--------|---------------------|-----------|-------------|
| Burger | 1 Bun, 1 Meat, 1 Veg, 1 Sauce | 5.2s | 110 |
| Skewer | 1 Meat, 1 Veg, 1 Sauce | 4.4s | 128 |
| Noodle | 1 Veg, 1 Sauce, 1 Noodle | 4.9s | 136 |
| Double | 1 Bun, 2 Meat, 1 Sauce | 6.0s | 152 |
| Wrap   | 1 Bun, 2 Veg, 1 Sauce | 4.6s | 124 |

## Public API Reference

### Package `raylib_food_truck_frenzy_2026`

> Main entry point and all game logic in a single file.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Chef` | `x`, `y`, `vx`, `vy`, `stamina`, `stamina_max`, `action_cd`, `boost_t`, `step_t` | Player-controlled chef with position, velocity, stamina, and cooldown state |
| `Station` | `x`, `y`, `w`, `h`, `kind` | A fixed workstation in the truck (ingredient bin, stove, window, sink, or fan) |
| `Order` | `active`, `id`, `kind`, `deadline`, `max_deadline`, `reward`, `pulse` | Customer order with countdown timer and recipe type |
| `StoveSlot` | `active`, `kind`, `progress`, `need`, `quality`, `pulse` | A cooking slot on the stove tracking progress toward completion |
| `SupplyBox` | `active`, `x`, `y`, `kind`, `amount`, `life`, `pulse` | A timed supply crate that spawns on the floor with ingredients |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | Visual particle for effects (sparks, steam, bursts) |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value between low and high bounds |
| `minf` | `(Float, Float) -> Float` | Returns the smaller of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns the larger of two floats |
| `mini` | `(Int, Int) -> Int` | Returns the smaller of two integers |
| `maxi` | `(Int, Int) -> Int` | Returns the larger of two integers |
| `sinf` | `(Float) -> Float` | Computes sine from a Float via double conversion |
| `randf` | `(Float, Float) -> Float` | Generates a random float in the given range using raylib RNG |
| `randi` | `(Int, Int) -> Int` | Generates a random integer in the given range |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Computes squared distance between two 2D points |
| `inside_rectf` | `(Float, Float, Float, Float, Float, Float) -> Bool` | Tests if a point is inside a float-coordinate rectangle |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a float point is inside an int-coordinate rectangle |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Checks if mouse or any touch point is inside a rectangle |
| `pointer_on_circle` | `(Float, Float, Bool, Int, Float, Float, Float) -> Bool` | Checks if mouse or any touch point is inside a circle |
| `ingredient_name` | `(Int) -> String` | Maps ingredient kind index to display name (Bun, Meat, Veg, Sauce, Noodle) |
| `recipe_short` | `(Int) -> String` | Maps recipe kind index to short name (Burger, Skewer, Noodle, Double, Wrap) |
| `recipe_reward` | `(Int) -> Int` | Returns base reward for a recipe kind |
| `recipe_cook_time` | `(Int) -> Float` | Returns base cooking duration for a recipe kind |
| `recipe_color` | `(Int) -> @raylib.Color` | Returns the display color for a recipe kind |
| `recipe_need` | `(Int, Int) -> Int` | Returns how many of a given ingredient a recipe requires |
| `recipe_can_make` | `(Int, Array[Int]) -> Bool` | Checks if current ingredients are sufficient for a recipe |
| `recipe_consume` | `(Int, Array[Int]) -> Unit` | Subtracts required ingredients from inventory for a recipe |
| `clear_orders` | `(Array[Order]) -> Unit` | Deactivates and resets all orders in the pool |
| `clear_stoves` | `(Array[StoveSlot]) -> Unit` | Deactivates and resets all stove slots |
| `clear_boxes` | `(Array[SupplyBox]) -> Unit` | Deactivates and resets all supply boxes |
| `clear_particles` | `(Array[Particle]) -> Unit` | Deactivates and resets all particles |
| `spawn_particle` | `(Array[Particle], Float, Float, Float, Float, Float, Float, Int) -> Unit` | Activates the first inactive particle with given parameters |
| `burst_particles` | `(Array[Particle], Float, Float, Int, Int) -> Unit` | Spawns a cluster of particles at a position for visual feedback |
| `update_particles` | `(Array[Particle], Float) -> Unit` | Advances particle positions, applies drag/gravity, and expires dead particles |
| `spawn_order` | `(Array[Order], Int, Int) -> Bool` | Creates a new customer order with random recipe kind and wave-adjusted deadline |
| `spawn_supply_box` | `(Array[SupplyBox], Float, Float, Float, Float) -> Bool` | Spawns a supply box at a random position within the world bounds |
| `find_pending_for_kind` | `(Array[Order], Int) -> Int` | Counts active orders of a given recipe kind |
| `find_cooking_for_kind` | `(Array[StoveSlot], Int) -> Int` | Counts active stove slots cooking a given recipe kind |
| `choose_recipe_for_cook` | `(Array[Order], Array[StoveSlot], Array[Int], Array[Int]) -> Int` | Selects the most urgent recipe kind the player can cook, or a fallback |
| `open_stove_slot` | `(Array[StoveSlot]) -> Int` | Returns the index of the first inactive stove slot, or -1 |
| `earliest_servable_order_index` | `(Array[Order], Array[Int]) -> Int` | Returns the index of the most urgent order that has a matching ready meal |
| `draw_floor_grid` | `(Int, Int, Int, Int, Float) -> Unit` | Renders the animated tile grid background |
| `draw_station` | `(Station, Bool, Float) -> Unit` | Draws a single workstation with highlight when active |
| `draw_chef` | `(Chef, Float) -> Unit` | Renders the chef character with bobbing animation and boost effect |
| `draw_orders_panel` | `(Int, Int, Int, Array[Order], Array[Int], Float) -> Unit` | Draws the scrollable orders list with urgency bars |
| `draw_inventory_panel` | `(Int, Int, Array[Int], Array[Int]) -> Unit` | Displays ingredient counts and ready meal counts |
| `draw_stoves` | `(Array[StoveSlot], Float, Float, Array[Particle], Float) -> Unit` | Renders stove slots with progress bars and steam particles |
| `draw_supply_boxes` | `(Array[SupplyBox], Float) -> Unit` | Draws supply boxes with pulsing glow effect |
| `draw_particles` | `(Array[Particle]) -> Unit` | Renders all active particles with alpha fade |
| `draw_touch_controls` | `(Int, Int, Float, Float, Bool, Int) -> Unit` | Draws on-screen D-pad and action buttons for touch input |
| `draw_hud` | `(Int, Int, Int, Int, Float, Int, Int, Float, Float, Float, Int, Int, Int, Int, String) -> Unit` | Renders the full HUD panel with timer, score, meters, combo, and controls legend |
| `draw_menu` | `(Int, Int, Float) -> Unit` | Draws the animated title screen with start prompt |
| `draw_end` | `(Int, Int, Bool, Int, Int, Float, Int, Int) -> Unit` | Draws the end-of-game overlay showing win/lose status and stats |
| `main` | `() -> Unit` | Entry point: initializes window, allocates game state, runs the main loop |

## Architecture

### Package Structure

```
raylib_food_truck_frenzy_2026/
├── main.mbt              — All game logic, rendering, and entry point
└── moon.pkg              — Package config with raylib and math imports
```

This is a single-file game where all systems coexist in `main.mbt`. The code is organized top-down: struct definitions first, then utility functions, recipe data functions, pool management functions, game logic helpers, drawing routines, and finally the `main` function containing the game loop.

### Data Flow

1. **Input**: The main loop reads keyboard state (`is_key_down`, `is_key_pressed`) and touch positions. Touch input is mapped to the same actions as keyboard through `pointer_on_rect` and `pointer_on_circle` hit testing.

2. **Update**: Chef position is updated with velocity and clamped to world bounds. Environmental meters (heat, clean, reputation) tick continuously. Orders count down with penalties from heat, dirt, and queue pressure. Stoves advance cooking progress scaled by cleanliness. Supply boxes expire over time.

3. **Interaction**: When the player presses Interact, the game checks which station the chef overlaps using `inside_rectf`. The station kind determines the action: ingredient bins restock, stove starts cooking via `choose_recipe_for_cook`, window serves via `earliest_servable_order_index`, sink restores cleanliness, fan reduces heat.

4. **Render**: Drawing proceeds in layers: floor grid, stations, supply boxes, stove overlays, particles, chef, then the side HUD panel with orders, inventory, and meters. End screen overlays on top.

### Key Design Patterns

- **Object pool pattern**: Orders (11 slots), stove slots (2), supply boxes (14), and particles (900) are all pre-allocated arrays with `active` boolean flags. Spawning scans for the first inactive slot.
- **Integer state machine**: Game state is encoded as an Int (0=menu, 1=play, 2=win, 3=lose) rather than an enum, driving conditional branches in update and render.
- **Interacting environmental meters**: Heat, cleanliness, and reputation form a coupled system where neglecting one cascades into the others through penalty multipliers.
- **Auto-recipe selection**: `choose_recipe_for_cook` intelligently picks the most urgent unfulfilled recipe the player can afford, reducing micromanagement.
- **Touch/keyboard unification**: All input goes through helper functions that check both keyboard state and touch positions against UI regions.

## Improvement & Refinement Plan

1. **Extract GameState enum**: The integer state variable (`state : Int` with 0/1/2/3) should be replaced with a proper `GameState` enum (`Menu`, `Play`, `Win`, `Lose`) for type safety and readability in the match branches.

2. **Replace magic station indices**: Stations are accessed by hardcoded indices (`stations[5]` for stove, `stations[6]` for window, etc.). Defining named constants or an enum for station kinds would make the interaction logic in the action_press block much clearer.

3. **Split into internal packages**: The 2,253-line `main.mbt` would benefit from separation into `internal/types` (structs and recipe data), `internal/game` (update logic, order/stove management), and `internal/render` (all draw functions), following the pattern used by other games in this repository.

4. **Add difficulty scaling configuration**: Wave parameters (deadline reduction per wave of 1.35, order spawn interval formula, wave cap of 12) are scattered as inline constants. Grouping them into a config struct would allow easy tuning and potential difficulty selection.

5. **Improve stove slot limit**: Only 2 stove slots exist (`Array::makei(2, ...)`), which can bottleneck gameplay. Making this configurable or adding a station upgrade mechanic would add depth.

6. **Add recipe quality impact on scoring**: The `quality` field on `StoveSlot` is tracked (decays with heat) but never actually used in the scoring calculation when a meal completes. Connecting quality to the reward multiplier would make heat management more meaningful.

7. **Decouple particle rendering from stove drawing**: `draw_stoves` spawns particles during the render pass (calling `spawn_particle` inside a draw function), mixing update logic with rendering. Moving particle spawning to the update phase would produce cleaner separation of concerns.
