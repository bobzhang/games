# Snake Battle Arena

A competitive snake duel on a 34x20 wrapping grid against two AI-controlled rivals. The player grows their snake by eating food, avoids traps and collisions, and tries to outscore the AI opponents before a 180-second timer expires. The arena features two food types (normal and gold), randomly spawning traps with limited lifetimes, a boost system for temporary speed increases, a combo scoring chain, and a hint system that suggests safe directions.

The core loop is classic snake movement on a fixed-step timer, but elevated by the competitive element: rivals independently pathfind toward food, avoid hazards, and can crash into the player. Head-on collisions with rivals damage the player, while rivals crashing into the player's body earn kill points. The match ends when time runs out (win/lose determined by total score vs rivals' combined score) or when all 3 player lives are lost.

## Build and Run

```bash
moon build --target native raylib_snake_battle_arena_2026/
./_build/native/debug/build/raylib_snake_battle_arena_2026/raylib_snake_battle_arena_2026.exe
```

## Controls

- **W / Up Arrow**: Change direction to up
- **A / Left Arrow**: Change direction to left
- **S / Down Arrow**: Change direction to down
- **D / Right Arrow**: Change direction to right
- **Left Shift / Right Shift / J**: Activate boost (faster step rate, drains boost meter)
- **H**: Use hint (suggests safe direction toward food, 3 per match)
- **R**: Restart match
- **Escape**: Return to title screen
- **Enter / Space**: Start match / retry after result
- **Mouse click on board**: Change direction toward clicked cell
- **Touch controls**: D-pad (L/R/U/D), BOOST, HINT, RESTART buttons on side panel

## How to Play

Navigate a 34x20 grid that wraps on all edges. The player's green snake starts at the center with length 5. Two AI rival snakes (red and blue) start in opposite corners with length 4.

**Food**: Collect food to grow and score. Normal food (blue) gives +1 length and 80 points. Gold food (yellow, 22% spawn chance) gives +3 length and 210 points plus double combo value. After eating, a new food item spawns immediately, and there is a 16% chance a trap also spawns.

**Traps**: Red pulsing circles that appear on the grid with a lifetime of 8-14 seconds. Stepping on a trap damages the player (loses a life) or kills a rival. Traps spawn probabilistically after food is eaten and randomly each step (0.8% chance).

**Boost**: Hold Shift/J to increase step speed (0.078s vs normal 0.118s per step). The boost meter drains at 0.52/s while active and recharges at 0.22/s when inactive. Boost disables automatically when the meter empties (below 0.08).

**Combo**: Consecutive food pickups without dying increment a combo counter. Combos above 1 award bonus points (combo * 12 per food). The combo decays over time when no food is eaten.

**Hints**: Press H to get a directional hint. The AI evaluates all 4 directions for the player, scoring them by food distance, obstacle avoidance, and open-space availability. The best direction is auto-set, and a pulsing circle marks the suggested cell. 3 hints per match.

**Collisions**: Hitting your own body, a rival's body, or a trap costs a life. Head-to-head with a rival also costs a life. When a rival crashes into the player's body segments, the rival respawns and the player earns 120 points and a kill.

**Win condition**: When the 180-second timer expires, if the player's score is greater than or equal to the rivals' combined score, the player wins. Lose if all 3 lives are lost before time expires.

## Public API Reference

### Package `raylib_snake_battle_arena_2026`

> Main entry point. Initializes the window at 1720x980 at 120 FPS with audio device, creates the Game, and runs the update/draw loop.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Entry point: sets up window with MSAA and audio, creates Game, runs update_game and draw_frame each frame |

### Package `raylib_snake_battle_arena_2026/internal/types`

> Core type definitions, constants, direction helpers, grid utilities, and input abstraction.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1720` | Screen width in pixels |
| `screen_h` | `Int` | `980` | Screen height in pixels |
| `target_fps` | `Int` | `120` | Target frame rate |
| `grid_w` | `Int` | `34` | Grid width in cells |
| `grid_h` | `Int` | `20` | Grid height in cells |
| `max_cells` | `Int` | `grid_w * grid_h` | Total grid cells (680) |
| `max_segments` | `Int` | `max_cells` | Maximum snake segment count |
| `max_rivals` | `Int` | `2` | Number of AI rival snakes |
| `state_title` | `Int` | `0` | Title screen state |
| `state_play` | `Int` | `1` | Active gameplay state |
| `state_result` | `Int` | `2` | Result/game over screen state |
| `dir_left` | `Int` | `0` | Left direction constant |
| `dir_right` | `Int` | `1` | Right direction constant |
| `dir_up` | `Int` | `2` | Up direction constant |
| `dir_down` | `Int` | `3` | Down direction constant |
| `food_normal` | `Int` | `0` | Normal food type |
| `food_gold` | `Int` | `1` | Gold food type |
| `lives_default` | `Int` | `3` | Starting lives per match |
| `match_time_limit` | `Float` | `180.0` | Match duration in seconds |
| `panel_x0` | `Int` | `1146` | Side panel left edge |
| `panel_w` | `Int` | `screen_w - panel_x0 - 24` | Side panel width |
| `board_area_x/y/w/h` | `Int` | `40, 30, ...` | Board drawing area bounds |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Spark` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | Visual particle effect with type-based coloring |
| `Rival` | `alive`, `len`, `dir`, `next_dir`, `grow`, `score`, `deaths`, `color_kind`, `seg_x`, `seg_y` | AI-controlled rival snake with segment arrays, scoring, and death tracking |
| `Game` | `p_seg_x/y`, `p_alive`, `p_len`, `p_dir`, `p_next_dir`, `p_grow`, `rivals`, `food_x/y/kind`, `trap_*`, `state`, `score`, `lives`, `combo`, `boost_meter`, `hint_left`, ... | Main game state with player snake, rivals, food, traps, scoring, and input state |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Spark::new` | `() -> Spark` | Creates an inactive spark particle |
| `Rival::new` | `(Int) -> Rival` | Creates a rival snake with color kind and allocated segment arrays |
| `Game::new` | `() -> Game` | Creates a new game instance with all pools and default values |
| `mini` | `(Int, Int) -> Int` | Returns the minimum of two integers |
| `maxi` | `(Int, Int) -> Int` | Returns the maximum of two integers |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between bounds |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between bounds |
| `maxf` | `(Float, Float) -> Float` | Returns the maximum of two floats |
| `absf` | `(Float) -> Float` | Returns absolute value of a float |
| `randf` | `(Float, Float) -> Float` | Random float in range using raylib RNG |
| `dir_dx` | `(Int) -> Int` | Returns x-axis delta for a direction (-1, 0, or 1) |
| `dir_dy` | `(Int) -> Int` | Returns y-axis delta for a direction (-1, 0, or 1) |
| `opposite_dir` | `(Int, Int) -> Bool` | Tests if two directions are 180-degree opposites |
| `wrap_x` | `(Int) -> Int` | Wraps an x coordinate to the grid horizontally |
| `wrap_y` | `(Int) -> Int` | Wraps a y coordinate to the grid vertically |
| `board_metrics` | `(Float) -> (Int, Int, Int)` | Computes board pixel position and tile size with optional screen shake offset |
| `cell_world_center` | `(Game, Int, Int) -> (Float, Float)` | Returns world-space center of a grid cell |
| `set_msg` | `(Game, String, Float) -> Unit` | Sets the HUD message with a display duration |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Tests mouse/touch position against a rectangle |
| `start_button_rect` | `() -> (Int, Int, Int, Int)` | Returns title screen start button bounds |
| `retry_button_rect` | `() -> (Int, Int, Int, Int)` | Returns result screen retry button bounds |
| `btn_left` | `() -> (Int, Int, Int, Int)` | Touch control: left button bounds |
| `btn_right` | `() -> (Int, Int, Int, Int)` | Touch control: right button bounds |
| `btn_up` | `() -> (Int, Int, Int, Int)` | Touch control: up button bounds |
| `btn_down` | `() -> (Int, Int, Int, Int)` | Touch control: down button bounds |
| `btn_boost` | `() -> (Int, Int, Int, Int)` | Touch control: boost button bounds |
| `btn_restart` | `() -> (Int, Int, Int, Int)` | Touch control: restart button bounds |
| `btn_hint` | `() -> (Int, Int, Int, Int)` | Touch control: hint button bounds |

### Package `raylib_snake_battle_arena_2026/internal/game`

> Game logic, AI decision-making, input handling, and match management.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Top-level update: polls input, dispatches to state-specific input handlers and play update with clamped delta time |

### Package `raylib_snake_battle_arena_2026/internal/render`

> All rendering and visual effects.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main render entry: draws background, board, grid, food, traps, snakes, hints, sparks, HUD panel, touch controls, and result overlay |

## Architecture

### Package Structure

```
raylib_snake_battle_arena_2026/
├── main.mbt                          -- Entry point: window/audio init, game loop
├── moon.pkg                          -- Root package config
└── internal/
    ├── types/
    │   ├── types.mbt                 -- Structs (Spark, Rival, Game) and constructors
    │   ├── constants.mbt             -- Grid/screen/state/direction constants, button rects
    │   ├── utils.mbt                 -- Math helpers, direction logic, grid wrapping, board metrics, collision tests
    │   └── moon.pkg                  -- Types package config
    ├── game/
    │   ├── ai.mbt                    -- AI decision-making for rivals and player hint system
    │   ├── input.mbt                 -- Input polling for title/play/result states with mouse, keyboard, and touch
    │   ├── logic.mbt                 -- Match management, snake movement, food/trap spawning, collision resolution, scoring
    │   └── moon.pkg                  -- Game package config
    └── render/
        ├── render.mbt                -- All drawing: background, board, snakes, food, traps, HUD, overlays
        └── moon.pkg                  -- Render package config
```

The code follows a three-layer architecture with an additional AI module. `types` defines data structures and pure utilities. `game` handles all mutable state with `ai.mbt` providing direction-scoring logic, `input.mbt` polling controls, and `logic.mbt` managing the simulation. `render` is a read-only consumer of game state.

### Data Flow

1. **Input**: `update_game` polls mouse/touch state into `Game` fields, then dispatches to `update_title_input`, `update_play_input`, or `update_result_input`. Play input maps WASD/arrows to `p_next_dir`, handles boost toggle, and supports mouse-click-to-cell direction targeting via `direction_to_cell` with Manhattan distance and wrapping.

2. **Fixed-step simulation**: `update_play` accumulates delta time in `step_acc` and triggers `step_once` when it exceeds the step interval (0.118s normal, 0.078s boosted). Each step moves the player snake first, then all rivals sequentially, checking collisions at each step.

3. **Snake movement**: `player_step` validates the queued direction (preventing 180-degree reversal), computes the next head cell with wrapping, checks for self-collision, rival collision, and trap collision. On food pickup, `grow_player_after_food` adds length, scores, spawns new food, and may spawn a trap. `shift_player_forward` slides all segments forward, growing the snake if `p_grow > 0`.

4. **AI**: `ai_choose_dir` evaluates all 4 directions for a rival using `direction_score_rival`, which scores by: food distance (-64 per Manhattan step), player avoidance (-120 if within 2 cells), open neighbors (+26 each), collision penalties (-90000), and random noise (+/-44). The hint system uses `suggest_player_dir` with a similar scoring function for the player.

5. **Rendering**: `draw_frame` layers: animated background with circles and scanlines, board back with shake effect, grid lines, food (normal blue / gold yellow), traps (pulsing red), rival snakes, player snake (with head eyes), hint indicator, spark particles, side panel HUD (score, lives, kills, time, combo, boost bar, controls, rival scores, messages), touch buttons, and result overlay.

### Key Design Patterns

- **Grid-wrapping arena**: `wrap_x`/`wrap_y` enable toroidal topology where snakes seamlessly wrap around all edges.
- **Fixed-step accumulator**: Movement uses `step_acc` to decouple visual frame rate from game logic, ensuring consistent snake speed regardless of FPS.
- **AI scoring with noise**: Rival AI evaluates directions with deterministic factors (food distance, collision avoidance) plus random noise (+/-44) to create varied, non-deterministic behavior.
- **Boost resource management**: Speed boost drains a meter (0.52/s) that recharges when unused (0.22/s), creating a strategic resource to manage.
- **Object pool pattern**: Sparks use a pre-allocated array with `active` flags, scanned linearly for the first available slot.
- **Combo decay system**: The combo counter ticks down on a 0.26s timer when no food is eaten, and awards `combo * 12` bonus points per pickup while active.
- **Board metrics with shake**: `board_metrics` computes tile size and board position, adding random pixel offsets during screen shake for hit feedback.

## Improvement & Refinement Plan

1. **Replace integer constants with enums**: `state`, `dir`, and `food_kind` all use integer constants. Using MoonBit enums would provide type safety and enable pattern matching throughout the game and AI logic.

2. **Add power-up items beyond food**: Currently only food and traps exist on the grid. Adding power-ups (invincibility, length reduction, speed burst, rival freeze) would create more strategic variety.

3. **Improve rival AI difficulty scaling**: Both rivals use the same scoring function with the same parameters. Making AI smarter over time (reducing noise, increasing food priority, adding player-targeting behavior) would create progression difficulty.

4. **Add wrap-aware distance in rendering**: The hint indicator and food distance use Manhattan distance with wrapping, but there is no visual indicator showing the wrap path. Drawing ghost food/hints near edges would help players understand the wrapping topology.

5. **Implement match progression**: Currently every match is identical. Adding rounds with increasing rival count, faster step rates, or more traps would create a campaign-like structure.

6. **Add sound effects**: The audio device is initialized but no sounds are played. Adding effects for eating food, dying, boosting, rival kills, and combo milestones would significantly improve game feel.

7. **Separate player snake from loose game fields**: Player state (`p_seg_x`, `p_seg_y`, `p_alive`, `p_len`, `p_dir`, etc.) is stored as flat fields in `Game`. Extracting it into a `PlayerSnake` struct similar to `Rival` would improve consistency and reduce code duplication between player and rival movement functions.
