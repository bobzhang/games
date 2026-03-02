# Chef Rush 2026

A lane-based ingredient-catching arcade game set in a fast-paced kitchen where the player controls a chef moving between five lanes to catch falling ingredients. Each round presents a customer order requiring a specific ingredient type and quantity, and the player must selectively catch the correct items while avoiding trash.

The gameplay loop centers on fulfilling sequential orders: each order specifies an ingredient (tomato, beef, fish, or lettuce) and a quantity (2 to 4). Ingredients and trash drop from the top of the screen at varying speeds across five lanes. Catching the correct ingredient earns 18 points and fills the order counter. Catching the wrong ingredient costs 6 points and 1.8 seconds of time. Catching trash costs a life and 30 points. Once the order is complete, pressing Space serves it for a large bonus (100 + quantity * 20 points) and adds 7 seconds to the 120-second timer. Missing a needed ingredient off the bottom costs 8 points.

The game uses a simple but effective single-file architecture with a pre-allocated drop pool of 140 objects and a 0.30-second spawn interval. The order system generates random ingredient/quantity pairs, creating a constant decision-making challenge about which lane to occupy and which drops to pursue.

## Build and Run

```bash
moon build --target native raylib_chef_rush_2026/
./_build/native/debug/build/raylib_chef_rush_2026/raylib_chef_rush_2026.exe
```

## Controls

- **A / Left Arrow**: Move chef one lane to the left
- **D / Right Arrow**: Move chef one lane to the right
- **Space / Enter**: Serve completed order (when order_have >= order_need)
- **R**: Restart the game

## How to Play

You start with 120 seconds on the clock and 3 lives. Ingredients fall down five vertical lanes. An order panel in the top-left shows which ingredient and how many you need (e.g., "Beef 0/3").

Move your chef left and right to catch falling items in the correct lane. The chef snaps to lane positions -- there is no continuous movement. When an ingredient of the correct type reaches your chef (within 34 pixels vertically), it is caught and the order counter increments.

**Scoring**:
- Correct ingredient caught: +18 points
- Order served: +100 + (quantity * 20) points, +7 seconds (capped at 130s)
- Wrong ingredient caught: -6 points, -1.8 seconds
- Trash caught: -30 points, -1 life
- Needed ingredient missed off screen: -8 points
- Extra correct ingredient (after order full): +4 points

When the order counter reaches the required amount, "READY!" appears. Press Space/Enter to serve and receive the next order.

The game ends when time reaches zero or lives reach zero. Press R to restart at any time.

**Ingredient types**: Tomato (red), Beef (brown), Fish (sky blue), Lettuce (lime green), Trash (dark gray, marked with "X").

Trash has a 14% spawn chance; the remaining 86% is split evenly among the four ingredient types.

## Public API Reference

### Package `raylib_chef_rush_2026`

> Main entry point and complete game implementation (single-file architecture).

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1080` | Screen width in pixels |
| `sh` | `Int` | `720` | Screen height in pixels |
| `lane_count` | `Int` | `5` | Number of ingredient lanes |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Drop` | `alive`, `lane`, `x`, `y`, `kind`, `vy` | A falling ingredient or trash item with lane assignment and vertical speed |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `lane_x` | `(Int) -> Float` | Computes the X coordinate for a given lane index (0-4), starting at 160 with 185px spacing |
| `ingredient_name` | `(Int) -> String` | Returns the display name for an ingredient kind (0=Tomato, 1=Beef, 2=Fish, 3=Lettuce, 4=Trash) |
| `ingredient_color` | `(Int) -> Color` | Returns the color associated with an ingredient kind |
| `reset_drops` | `(Array[Drop]) -> Unit` | Deactivates all drops in the pool |
| `spawn_drop` | `(Array[Drop], Int, Int, Float) -> Unit` | Activates the first inactive drop in the pool at the specified lane, kind, and speed |
| `next_order` | `() -> (Int, Int)` | Generates a random order: ingredient kind (0-3) and quantity (2-4) |
| `main` | `() -> Unit` | Entry point: initializes window, drop pool, and runs the game loop with input, logic, and rendering |

## Architecture

### Package Structure

```
raylib_chef_rush_2026/
├── main.mbt              — Complete game: constants, Drop struct, utility functions, game loop
└── moon.pkg              — Package config with raylib import
```

This is a single-file game. The `Drop` struct represents falling items, and all game state (player position, timer, lives, score, order tracking) is managed as mutable local variables inside `main`. The drop pool is a pre-allocated array of 140 `Drop` objects reused via `alive` flags.

### Data Flow

1. **Input**: `is_key_pressed` checks for A/D/Left/Right to change `player_lane`, and Space/Enter to serve completed orders. R resets all state.
2. **Spawning**: A `spawn_tick` timer triggers every 0.30 seconds, spawning a drop in a random lane with a random kind (14% trash, otherwise random ingredient) and random speed (180-320).
3. **Physics**: Each active drop moves downward by `vy * dt`. Drops exiting the screen bottom are deactivated, with a score penalty if they were the needed ingredient.
4. **Collision**: Drops in the same lane as the player are checked for vertical proximity (within 34 pixels of the chef's Y position). Matching triggers catch logic based on ingredient type.
5. **Rendering**: Draws a kitchen background with lane lines, falling ingredient circles (trash marked with "X"), the chef (head circle + body rectangle + hat), order panel, score/lives/timer display, and status message bar.

### Key Design Patterns

- **Object pool**: 140 pre-allocated `Drop` structs with `alive` flags, avoiding runtime allocation during gameplay.
- **Lane-based movement**: Player snaps to discrete lane positions via `lane_x()`, simplifying both input and collision logic.
- **Order queue**: A simple (kind, need) pair system with `next_order()` generating random requirements, creating varied gameplay without complex recipe systems.
- **Time pressure with recovery**: The 120-second timer creates urgency, but serving orders extends time by 7 seconds (capped at 130s), rewarding efficient play.

## Improvement & Refinement Plan

1. **Add progressive difficulty**: Drop speed is currently random (180-320) regardless of score or time elapsed. Increasing the speed range or decreasing spawn intervals as orders are served would create escalating challenge.

2. **Add visual order preview**: The order panel shows text only. Drawing colored circles matching the required ingredient type next to the order text would make it faster to identify what to catch at a glance.

3. **Extract game state into a struct**: All state is stored as mutable local variables in `main`. A `Game` struct would improve code organization and enable features like save/load or multiple game modes.

4. **Add combo scoring**: Currently each catch is scored independently. Tracking consecutive correct catches and applying a multiplier would reward skillful play and add depth.

5. **Improve collision detection**: The current check uses a simple 34-pixel vertical threshold with lane matching. Adding a brief "catch window" animation or showing a visual indicator when a drop enters the catch zone would improve player feedback.

6. **Add ingredient variety per order**: Orders currently require a single ingredient type. Multi-ingredient orders (e.g., "2 Tomato + 1 Beef") would significantly increase strategic depth and make lane switching more meaningful.
