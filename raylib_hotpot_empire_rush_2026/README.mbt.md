# Hotpot Empire Rush 2026

Hotpot Empire Rush 2026 is a kitchen management game set in a bustling hotpot restaurant. Players navigate a 4x3 grid of kitchen stations -- from the Broth Kettle and Protein Crate to the Prep Board, Hotpot Base, and Serve Counter -- assembling customized hotpot bowls for an ever-growing queue of impatient customers.

The core gameplay loop revolves around reading customer orders from the queue, gathering the correct broth (Mala, Tomato, or Mushroom), protein (Beef, Lamb, or Tofu), vegetable (Lotus, Spinach, or Enoki), and spice level (Mild, Bold, or Inferno), then prepping raw ingredients on the Prep Board, combining everything in the Hotpot Base, and serving the finished bowl at the Serve Counter. Every correct serve builds a score combo multiplier and restores reputation, while wrong orders, expired patience, and queue overflows drain reputation toward zero.

The game features a boost mechanic that temporarily doubles prep and cook speed, a Rush Bell station that refills the boost meter on a cooldown, and a Dry Storage station that shuffles upcoming ingredient picks. Difficulty ramps automatically as elapsed time increases: order spawn intervals shrink, customer patience decreases, and higher spice levels unlock.

## Build and Run

```bash
moon build --target native raylib_hotpot_empire_rush_2026/
./_build/native/debug/build/raylib_hotpot_empire_rush_2026/raylib_hotpot_empire_rush_2026.exe
```

## Controls

- **W / Up Arrow**: Move cursor up
- **S / Down Arrow**: Move cursor down
- **A / Left Arrow**: Move cursor left
- **D / Right Arrow**: Move cursor right
- **J**: Interact with station (pick ingredient, start prep, collect prepped item, add to pot, start cooking, check queue, ring rush bell, trash item, shuffle storage)
- **K**: Serve finished pot at the Serve Counter, cancel/discard pot contents at the Hotpot Base, cancel prep at the Prep Board, or drop held item
- **Space**: Activate speed boost (costs 35 boost meter, doubles prep/cook speed for 2.8 seconds)
- **P**: Pause / unpause
- **R**: Restart the game at any time
- **J / Enter**: Start game from title screen, return to title from game over

## How to Play

When the game starts, you are presented with a title screen. Press J or Enter to begin a shift. Two customer orders spawn immediately in the queue, and more arrive on a timer that gets faster over time.

Each order demands a specific combination of broth type, protein, vegetable, and spice level. To fulfill the head-of-queue order:

1. **Select broth**: Navigate to the Broth Kettle (row 0, col 0) and press J to cycle through Mala, Tomato, and Mushroom until the pot's broth matches the order.
2. **Pick and prep protein**: Go to the Protein Crate (row 0, col 1), press J to pick raw protein, then move to the Prep Board (row 1, col 0) and press J to start prepping. Wait for the progress bar to fill, then press J again to collect the sliced protein.
3. **Pick and prep vegetables**: Similarly, go to the Veg Basket (row 0, col 2), pick raw veg, prep it on the Prep Board, and collect.
4. **Set spice level**: Navigate to the Chili Rack (row 0, col 3) and press J to cycle the pot's spice level.
5. **Load the pot**: With a prepped protein/veg in hand, move to the Hotpot Base (row 1, col 1) and press J to load each ingredient. Once broth + protein + veg are all loaded, press J again to start cooking.
6. **Serve**: When cooking finishes (progress bar fills), move to the Serve Counter (row 1, col 2) and press K to serve. If the pot matches the queue head, you score points (base 120 + patience bonus up to 90 + combo bonus of 20 per combo level).

Reputation starts at 72 out of 100. It increases by 4 per correct serve and decreases by 9.5 for timed-out orders, 7 for wrong serves, 3 for discarding pot contents, and 2.2 for queue overflow. The game ends when reputation reaches zero. The combo timer resets on any failure and lasts 4.2 seconds between successful serves.

Use the Speed Boost (Space) to double prep and cook speed for 2.8 seconds. The boost meter recharges at 11 units per second and each boost costs 35 units. The Rush Bell (row 1, col 3) instantly adds 24 boost meter but has a 7-second cooldown.

## Public API Reference

### Package `raylib_hotpot_empire_rush_2026`

> Main entry point.

The `main` function initializes a 1680x960 window with MSAA 4x, creates a `Game` instance, and runs the game loop calling `update_game` and `draw_frame` each frame at 120 FPS.

### Package `raylib_hotpot_empire_rush_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `InputState` | `move_x`, `move_y`, `press_interact`, `press_serve_cancel`, `press_boost`, `press_pause`, `press_restart`, `press_start` | Captures per-frame input state for directional movement and action buttons |
| `Order` | `active`, `id`, `broth`, `protein`, `veg`, `spice`, `patience`, `max_patience`, `pulse` | Represents a customer order with ingredient requirements and a patience countdown timer |
| `Item` | `kind`, `flavor`, `prepped` | An ingredient the player can hold, with type (protein/veg/none), flavor variant, and prep status |
| `PrepState` | `active`, `kind`, `flavor`, `progress`, `target`, `output_ready`, `out_kind`, `out_flavor` | Tracks the prep station's current processing state and output |
| `PotState` | `broth`, `protein`, `veg`, `spice`, `cooking`, `progress`, `target`, `ready` | Tracks the hotpot's loaded ingredients, cooking progress, and readiness |
| `Game` | `input`, `orders`, `prep`, `pot`, `hand`, `state`, `cursor_x`, `cursor_y`, `score`, `best_score`, `combo`, `reputation`, `boost_meter`, `boost_t`, `rush_cd`, `spawn_cd`, `elapsed`, `served`, `failed`, `msg`, `msg_t`, `flash_t` | Master game state container holding all sub-states, scoring, timers, and UI data |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `InputState::new` | `() -> InputState` | Creates a zeroed-out input state |
| `Order::new` | `(Int) -> Order` | Creates an inactive order with the given ID |
| `Item::empty` | `() -> Item` | Creates an empty hand item (kind = none) |
| `PrepState::new` | `() -> PrepState` | Creates a default inactive prep state |
| `PotState::new` | `() -> PotState` | Creates an empty pot state with no ingredients loaded |
| `Game::new` | `() -> Game` | Creates a new game in title state with default values for all fields |
| `set_message` | `(Game, String) -> Unit` | Sets the on-screen message text and resets its display timer to 2.4 seconds |

#### Layout and Mapping Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `kitchen_w` | `() -> Int` | Computes the total pixel width of the kitchen grid |
| `kitchen_h` | `() -> Int` | Computes the total pixel height of the kitchen grid |
| `station_x` | `(Int) -> Int` | Returns the pixel X coordinate for a given column index |
| `station_y` | `(Int) -> Int` | Returns the pixel Y coordinate for a given row index |
| `panel_x` | `() -> Int` | Returns the X position of the right-side info panel |
| `panel_w` | `() -> Int` | Returns the width of the right-side info panel |
| `station_at` | `(Int, Int) -> Int` | Maps a grid (col, row) coordinate to a station type constant |
| `station_name` | `(Int) -> String` | Returns the human-readable name for a station constant |

#### Naming Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `broth_name` | `(Int) -> String` | Returns the name for a broth variant (Mala, Tomato, Mushroom) |
| `protein_name` | `(Int) -> String` | Returns the name for a protein variant (Beef, Lamb, Tofu) |
| `veg_name` | `(Int) -> String` | Returns the name for a vegetable variant (Lotus, Spinach, Enoki) |
| `spice_name` | `(Int) -> String` | Returns the name for a spice level (Mild, Bold, Inferno) |

#### Utility Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer value between lo and hi bounds |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value between lo and hi bounds |
| `maxf` | `(Float, Float) -> Float` | Returns the larger of two floats |
| `minf` | `(Float, Float) -> Float` | Returns the smaller of two floats |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | 1680 | Window width in pixels |
| `screen_h` | `Int` | 960 | Window height in pixels |
| `target_fps` | `Int` | 120 | Target frame rate |
| `state_title` | `Int` | 0 | Title screen state |
| `state_playing` | `Int` | 1 | Active gameplay state |
| `state_paused` | `Int` | 2 | Paused state |
| `state_game_over` | `Int` | 3 | Game over state |
| `station_cols` | `Int` | 4 | Number of columns in the kitchen grid |
| `station_rows` | `Int` | 3 | Number of rows in the kitchen grid |
| `station_tile_w` | `Int` | 232 | Pixel width of a station tile |
| `station_tile_h` | `Int` | 178 | Pixel height of a station tile |
| `station_gap` | `Int` | 14 | Pixel gap between station tiles |
| `kitchen_left` | `Int` | 52 | Left margin of the kitchen grid |
| `kitchen_top` | `Int` | 130 | Top margin of the kitchen grid |
| `station_none` .. `station_storage` | `Int` | -1..11 | Station type constants for each grid cell |
| `ingredient_none` | `Int` | 0 | No ingredient held |
| `ingredient_protein` | `Int` | 1 | Protein ingredient type |
| `ingredient_veg` | `Int` | 2 | Vegetable ingredient type |
| `broth_count` | `Int` | 3 | Number of broth varieties |
| `protein_count` | `Int` | 3 | Number of protein varieties |
| `veg_count` | `Int` | 3 | Number of vegetable varieties |
| `spice_levels` | `Int` | 3 | Number of spice levels |
| `max_orders` | `Int` | 6 | Maximum simultaneous customer orders |
| `reputation_max` | `Float` | 100.0 | Maximum reputation value |
| `reputation_start` | `Float` | 72.0 | Starting reputation |
| `rep_gain_served` | `Float` | 4.0 | Reputation gained per correct serve |
| `rep_loss_timeout` | `Float` | 9.5 | Reputation lost when an order times out |
| `rep_loss_wrong_serve` | `Float` | 7.0 | Reputation lost for a wrong serve |
| `rep_loss_discard_pot` | `Float` | 3.0 | Reputation lost for discarding pot contents |
| `score_base_serve` | `Int` | 120 | Base score for a correct serve |
| `combo_keep_time` | `Float` | 4.2 | Seconds before combo resets without another serve |
| `prep_target_base` | `Float` | 3.2 | Base time in seconds to prep an ingredient |
| `cook_target_base` | `Float` | 6.4 | Base time in seconds to cook a pot |
| `boost_meter_max` | `Float` | 100.0 | Maximum boost meter capacity |
| `boost_cost` | `Float` | 35.0 | Boost meter cost per activation |
| `boost_duration` | `Float` | 2.8 | Boost active duration in seconds |
| `boost_charge_per_s` | `Float` | 11.0 | Boost meter recharge rate per second |
| `boost_speed_mult` | `Float` | 1.9 | Speed multiplier when boost is active |
| `rush_cooldown` | `Float` | 7.0 | Rush Bell cooldown in seconds |
| `msg_ttl` | `Float` | 2.4 | Message display duration in seconds |

### Package `raylib_hotpot_empire_rush_2026/internal/game`

> Game logic, input handling, and update systems.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main update entry point: polls input, handles state transitions (title/playing/paused/game over), and dispatches to the appropriate update routine |

### Package `raylib_hotpot_empire_rush_2026/internal/render`

> Rendering and drawing routines.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main rendering entry point: draws background with animated gradient circles and flash overlay, the kitchen grid with station tiles and cursor highlight, the side panel with score/combo/reputation/boost/hand/queue, and state-specific overlays (title, pause, game over) |

## Architecture

### Package Structure

```
raylib_hotpot_empire_rush_2026/
├── main.mbt              — Entry point: window init, game loop
├── moon.pkg              — Package config, imports
└── internal/
    ├── types/
    │   ├── types.mbt     — Core structs (Game, Order, Item, PrepState, PotState, InputState)
    │   ├── constants.mbt — Game constants and tuning values (56 pub let bindings)
    │   └── utils.mbt     — Layout calculations, station mapping, name lookups, math helpers
    ├── game/
    │   ├── logic.mbt     — Game state update logic, order spawning, interaction handlers, serving
    │   ├── input.mbt     — Input polling and mapping to InputState
    │   └── moon.pkg      — Package config
    └── render/
        ├── render.mbt    — Drawing: background, kitchen grid, station info, side panel, overlays
        └── moon.pkg      — Package config
```

The types package defines all data structures and constants with no dependencies on raylib (except `moonbitlang/core/math`), keeping it purely data-oriented. The game package handles all mutation of `Game` state including input polling, station interactions, order lifecycle, and state machine transitions. The render package reads from `Game` state to draw the UI, never mutating game data.

### Data Flow

1. `main.mbt` calls `update_input` (inside `update_game`) which polls raylib key states and populates `game.input` fields.
2. `update_game` checks for restart (R key) first, then dispatches to `update_title`, `update_playing`, `update_paused`, or `update_game_over` based on `game.state`.
3. During `update_playing`, cursor movement, boost activation, interactions (J), and serve/cancel (K) are processed from `game.input`. Then `update_play_timers`, `update_prep_and_pot`, `update_order_patience`, and `update_order_spawn` advance continuous game systems.
4. `draw_frame` reads the finalized `Game` state and renders the kitchen grid, side panel, and any state overlay.

### Key Design Patterns

- **Grid-based station system**: The 4x3 kitchen grid uses `station_at(x, y)` to map cursor coordinates to station type constants, with each station having a dedicated `interact_*` handler function.
- **Integer-encoded enums**: Game states, station types, ingredient types, and flavor variants are all encoded as `Int` constants rather than MoonBit enums, providing a lightweight approach to state representation.
- **Queue-based order management**: Orders are stored in a fixed-size array with active flags and are shifted down (compacted) when removed, so the head of the queue is always index 0.
- **Boost multiplier pattern**: The `boost_multiplier` function returns either 1.0 or `boost_speed_mult` (1.9) based on `boost_t`, applied directly to prep and cook progress increments.
- **Reputation-as-HP**: Reputation serves as the player's health bar -- it starts at 72/100, gains/losses are tuned to create pressure, and reaching zero triggers game over.
- **Delta-time progression**: All timers and progress bars use `dt` (clamped to 0.05s max) for frame-rate independent updates.

## Improvement & Refinement Plan

1. **Use MoonBit enums instead of integer constants for station and ingredient types**: The current approach with `station_broth`, `ingredient_protein`, etc. as `Int` constants sacrifices type safety. Converting to proper enums would enable exhaustive match checking and prevent invalid state combinations in `station_at` and `handle_interact`.

2. **Extract order matching into a dedicated function**: The `serve_matches_head` function compares pot fields one by one against `orders[0]`. An `Order::matches_pot(PotState)` method on the `Order` struct would be more encapsulated and reusable.

3. **Add visual feedback for prep station status**: The prep board's progress bar is only visible when hovering the station. A small indicator on the station tile itself (even when the cursor is elsewhere) would help players track prep completion while working at other stations.

4. **Implement difficulty levels or shift progression**: Currently difficulty ramps solely via `spawn_interval` and `spawn_patience` functions tied to elapsed time. Adding explicit shift/level milestones with unique constraints (e.g., limited stations, new ingredients) would add variety.

5. **Replace order array compaction with a ring buffer**: `remove_order_at` shifts all orders down one slot each time an order is removed, which is O(n) per removal. A ring buffer with head/tail pointers would make order removal O(1).

6. **Add sound effects at key interaction points**: The game currently has no audio. Adding feedback sounds for prep completion (`update_prep_and_pot`), successful serve (`serve_head_order`), wrong serve, and patience timeout would significantly improve game feel.

7. **Separate boost meter recharge from boost activation logic**: The `trigger_boost` and `boost_multiplier` functions are in `logic.mbt` alongside order and cooking logic. Extracting boost management into its own section or file would improve code organization as the system grows.
