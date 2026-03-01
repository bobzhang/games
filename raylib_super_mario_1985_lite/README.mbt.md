# Super Mario 1985 Lite

Super Mario 1985 Lite is a side-scrolling platformer inspired by the classic NES game, built with MoonBit and raylib. Set in a colorful World 1-1 style level with a 236-tile-wide scrolling landscape, the player controls a Mario-like character who must navigate past bottomless pits, stomp on goomba-like enemies, smash brick and question blocks, and collect coins scattered throughout the stage.

The core gameplay loop involves running and jumping through the procedurally laid-out level, using momentum-based physics with acceleration, friction, and variable-height jumps. The player earns points by collecting coins (200 points each), stomping enemies (400 points), and hitting blocks (50 points). A 400-second countdown timer adds urgency. Reaching the flagpole near the end triggers a cinematic sequence where the player slides down the pole and walks to the castle, earning a time bonus. Lives are tracked, and taking damage costs coins and resets the player's position with temporary invulnerability.

Technically, the game features a clean ECS-like architecture split across five packages (types, game, particles, render, and main), with a tile-based world using an integer tile array, object pools for enemies/coins/particles, coyote time and jump buffering for responsive controls, camera smoothing with directional lead, and screen shake feedback. The codebase also includes a comprehensive test suite validating physics, collision, and gameplay mechanics.

## Build and Run

```bash
moon build --target native raylib_super_mario_1985_lite/
./_build/native/debug/build/raylib_super_mario_1985_lite/raylib_super_mario_1985_lite.exe
```

## Controls

- **A / Left Arrow**: Move left
- **D / Right Arrow**: Move right
- **W / Up Arrow / Space**: Jump (press to initiate, hold for full height)
- **Enter / Space**: Start game from title screen, accept
- **Enter / Space / R**: Restart after win or game over

## How to Play

The game starts on a title screen displaying the level name "WORLD 1-1" with instructions. Press Enter or Space to begin playing.

Run through the level from left to right. The player accelerates on the ground at 2300 units/s^2 and in the air at 1500 units/s^2, with a maximum run speed of 270. Friction decelerates the player when no movement keys are held. Jumping launches the player upward at 760 units/s, and releasing the jump key early cuts the jump short via a multiplier (0.52), enabling variable-height jumps. Coyote time (0.09s) and jump buffering (0.11s) make the controls feel responsive.

Enemies (goomba-like creatures) patrol the ground, reversing direction when they hit walls or reach platform edges. Stomp enemies from above (the player must be falling with vy > 110 and positioned above the enemy) to squash them and earn 400 points plus a bounce. Side collisions with enemies cause damage: the player loses a life, drops up to 5 coins, and respawns at the start with 1.3 seconds of invulnerability. Falling off the bottom of the world also triggers a respawn (or death if not invulnerable).

Hit brick blocks from below to destroy them (50 points), and hit question blocks from below to collect a coin from inside (200 + 50 points). Question blocks become used blocks after being hit. Coins floating in the air can be collected by touching them; they bob up and down with a sine wave animation.

Reach the flagpole near tile column 214 to trigger the victory sequence. The player slides down the pole, walks to the castle, and receives a score bonus of 1000 + (time remaining * 5). The game transitions to the win screen showing the final score. If all lives are lost or the timer reaches zero, the game over screen appears. Press Enter or R to restart from the beginning.

The HUD displays score, coins collected, lives remaining, time left, active enemy count, and remaining coins.

## Public API Reference

### Package `raylib_super_mario_1985_lite`

> Main entry point: initializes the window, runs the game loop, and handles input.

There are no public functions or types in this package. The `main` function and `read_input` function are package-private.

### Package `raylib_super_mario_1985_lite/internal/types`

> Core type definitions, constants, and utility functions.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Input` | `move_left`, `move_right`, `jump_pressed`, `jump_held`, `accept`, `restart` | Snapshot of player input state for one frame |
| `Player` | `x`, `y`, `vx`, `vy`, `facing`, `on_ground`, `coyote_t`, `jump_buf_t`, `invuln_t`, `lives`, `coins`, `score`, `reached_flag`, `flag_phase` | Player state including position, velocity, physics timers, and progression |
| `Enemy` | `active`, `squashed`, `squash_t`, `x`, `y`, `vx`, `vy`, `dir` | Enemy state with object pool active flag and squash animation timer |
| `Coin` | `active`, `x`, `y`, `base_y`, `phase` | Collectible coin with sine-wave bobbing animation |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `max_life`, `size`, `color` | Visual particle with lifetime-based alpha fade |
| `Game` | `state`, `elapsed`, `time_accum`, `time_left`, `camera_x`, `flag_x`, `flag_top_y`, `flag_bottom_y`, `castle_x`, `start_y`, `shake_t`, `tiles`, `player`, `enemies`, `coins`, `particles` | Main game state container holding all world data |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Input::none` | `() -> Input` | Creates an input with all fields set to false |
| `Player::new` | `() -> Player` | Creates a new player at the starting position with 3 lives |
| `Enemy::inactive` | `() -> Enemy` | Creates an inactive enemy for pool pre-allocation |
| `Enemy::spawn` | `(Float, Float, Int) -> Enemy` | Creates an active enemy at position (x, y) moving in direction dir |
| `Coin::inactive` | `() -> Coin` | Creates an inactive coin for pool pre-allocation |
| `Coin::spawn` | `(Float, Float, Float) -> Coin` | Creates an active coin at position (x, y) with animation phase |
| `Particle::inactive` | `() -> Particle` | Creates an inactive particle for pool pre-allocation |
| `Game::new` | `() -> Game` | Creates a new game with default state, pre-allocated pools (56 enemies, 256 coins, 720 particles) |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer value to [lo, hi] |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value to [lo, hi] |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `signf` | `(Float) -> Int` | Returns -1, 0, or 1 based on the sign of a float |
| `tile_index` | `(Int, Int) -> Int` | Converts tile coordinates (tx, ty) to a 1D array index |
| `tile_left` | `(Int) -> Float` | Returns the left pixel coordinate of tile column tx |
| `tile_top` | `(Int) -> Float` | Returns the top pixel coordinate of tile row ty |
| `tile_center_x` | `(Int) -> Float` | Returns the center x pixel coordinate of tile column tx |
| `tile_center_y` | `(Int) -> Float` | Returns the center y pixel coordinate of tile row ty |
| `world_to_tile_x` | `(Float) -> Int` | Converts a world x coordinate to a tile column index, clamped |
| `world_to_tile_y` | `(Float) -> Int` | Converts a world y coordinate to a tile row index, clamped |
| `set_tile` | `(Game, Int, Int, Int) -> Unit` | Sets the tile at (tx, ty) to the given tile type, bounds-checked |
| `get_tile` | `(Game, Int, Int) -> Int` | Gets the tile at (tx, ty); returns ground for out-of-bounds x, empty for negative y |
| `fill_rect_tile` | `(Game, Int, Int, Int, Int, Int) -> Unit` | Fills a rectangular region of tiles with the given type |
| `clear_tiles` | `(Game) -> Unit` | Sets all tiles to empty |
| `tile_is_solid` | `(Int) -> Bool` | Returns true for ground, brick, question, used, pipe, and castle tiles |
| `rects_overlap` | `(Float, Float, Float, Float, Float, Float, Float, Float) -> Bool` | Tests if two axis-aligned rectangles (x0,y0,x1,y1) overlap |
| `world_to_screen_x` | `(Float, Float) -> Float` | Converts world x coordinate to screen x by subtracting camera offset |
| `player_half_w` | `() -> Float` | Returns half the player width (12.0) |
| `player_half_h` | `() -> Float` | Returns half the player height (15.0) |
| `enemy_half_w` | `() -> Float` | Returns half the enemy width (12.0) |
| `enemy_half_h` | `() -> Float` | Returns half the enemy height (11.0) |
| `randf` | `(Float, Float) -> Float` | Returns a random float in [min, max] using raylib's random |
| `remaining_coins` | `(Game) -> Int` | Counts active coins remaining in the level |
| `active_enemy_count` | `(Game) -> Int` | Counts active enemies remaining in the level |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_width` | `Int` | 1280 | Window width in pixels |
| `screen_height` | `Int` | 720 | Window height in pixels |
| `hud_height` | `Int` | 84 | Height of the HUD bar in pixels |
| `tile_size` | `Int` | 32 | Tile dimension in pixels |
| `tile_size_f` | `Float` | 32.0 | Tile dimension as float |
| `world_tiles_w` | `Int` | 236 | World width in tiles |
| `world_tiles_h` | `Int` | 22 | World height in tiles |
| `world_width_px` | `Float` | 7552.0 | World width in pixels |
| `world_height_px` | `Float` | 704.0 | World height in pixels |
| `ground_row` | `Int` | 17 | Tile row where ground starts |
| `state_title` | `Int` | 0 | Title screen state |
| `state_playing` | `Int` | 1 | Active gameplay state |
| `state_win` | `Int` | 2 | Victory screen state |
| `state_game_over` | `Int` | 3 | Game over screen state |
| `tile_empty` | `Int` | 0 | Empty/air tile |
| `tile_ground` | `Int` | 1 | Solid ground tile |
| `tile_brick` | `Int` | 2 | Breakable brick tile |
| `tile_question` | `Int` | 3 | Question mark block tile |
| `tile_used` | `Int` | 4 | Used (hit) question block tile |
| `tile_pipe` | `Int` | 5 | Pipe tile |
| `tile_flag_pole` | `Int` | 6 | Flag pole tile (non-solid) |
| `tile_castle` | `Int` | 7 | Castle tile |
| `player_w` | `Float` | 24.0 | Player hitbox width |
| `player_h` | `Float` | 30.0 | Player hitbox height |
| `player_start_x` | `Float` | 96.0 | Player starting x position (3 tiles) |
| `gravity` | `Float` | 2150.0 | Gravity acceleration |
| `run_accel_ground` | `Float` | 2300.0 | Ground movement acceleration |
| `run_accel_air` | `Float` | 1500.0 | Air movement acceleration |
| `run_friction` | `Float` | 2700.0 | Ground friction deceleration |
| `max_run_speed` | `Float` | 270.0 | Maximum horizontal speed |
| `max_fall_speed` | `Float` | 950.0 | Terminal fall velocity |
| `jump_speed` | `Float` | 760.0 | Initial jump velocity |
| `stomp_bounce_speed` | `Float` | 510.0 | Bounce velocity after stomping enemy |
| `coyote_time` | `Float` | 0.09 | Grace period for jumping after leaving ground |
| `jump_buffer_time` | `Float` | 0.11 | Input buffer for jump press before landing |
| `jump_cut_multiplier` | `Float` | 0.52 | Gravity multiplier for short hops |
| `player_invuln_time` | `Float` | 1.3 | Invulnerability duration after taking damage |
| `start_time_seconds` | `Int` | 400 | Level countdown timer starting value |
| `flag_slide_speed` | `Float` | 210.0 | Speed of flag pole slide animation |
| `castle_walk_speed` | `Float` | 130.0 | Player walk speed toward castle after flag |
| `camera_lerp` | `Float` | 9.0 | Camera smoothing interpolation factor |
| `camera_lead_px` | `Float` | 165.0 | Camera lead distance in player facing direction |
| `enemy_w` | `Float` | 24.0 | Enemy hitbox width |
| `enemy_h` | `Float` | 22.0 | Enemy hitbox height |
| `enemy_speed` | `Float` | 88.0 | Enemy patrol speed |
| `max_enemies` | `Int` | 56 | Enemy pool capacity |
| `max_coins` | `Int` | 256 | Coin pool capacity |
| `max_particles` | `Int` | 720 | Particle pool capacity |
| `coin_collect_score` | `Int` | 200 | Points for collecting a coin |
| `stomp_score` | `Int` | 400 | Points for stomping an enemy |
| `block_hit_score` | `Int` | 50 | Points for hitting a block |

### Package `raylib_super_mario_1985_lite/internal/game`

> Game logic including player physics, enemy AI, coin collection, level construction, and state management.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `init_game` | `(Game) -> Unit` | Builds the level geometry and entities, sets the game to title state |
| `update_game` | `(Game, Input, Float) -> Unit` | Main update dispatcher: handles title, playing, win, and game over states |

### Package `raylib_super_mario_1985_lite/internal/particles`

> Particle system for visual feedback effects.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clear_particles` | `(Game) -> Unit` | Resets all particles to inactive |
| `spawn_coin_burst` | `(Game, Float, Float) -> Unit` | Spawns 10 gold particles at (x, y) for coin collection |
| `spawn_block_burst` | `(Game, Float, Float, Color) -> Unit` | Spawns 12 colored particles at (x, y) for block destruction |
| `spawn_stomp_burst` | `(Game, Float, Float) -> Unit` | Spawns 15 brown particles at (x, y) for enemy stomp |
| `spawn_hurt_burst` | `(Game, Float, Float) -> Unit` | Spawns 18 red particles at (x, y) for player damage |
| `update_particles` | `(Game, Float) -> Unit` | Updates all active particles: applies gravity (420), moves, and expires by lifetime |

### Package `raylib_super_mario_1985_lite/internal/render`

> Rendering routines for the world, entities, and UI overlays.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_world` | `(Game) -> Unit` | Main world rendering entry: draws background, tiles, flag, coins, enemies, player, and particles with camera and screen shake |
| `draw_ui` | `(Game) -> Unit` | Draws the HUD bar and state-dependent overlays (title, win, game over panels) |

## Architecture

### Package Structure

```
raylib_super_mario_1985_lite/
├── main.mbt                          -- Entry point: window init, input reading, game loop
├── moon.pkg                          -- Package config (is-main), imports types/game/render
└── internal/
    ├── types/
    │   ├── types.mbt                 -- Core structs: Input, Player, Enemy, Coin, Particle, Game
    │   ├── constants.mbt             -- All tuning constants (physics, sizes, pools, scoring)
    │   ├── utils.mbt                 -- Math utilities, tile operations, collision detection
    │   ├── utils_test.mbt            -- Unit tests for tile_is_solid, rects_overlap, clamp, coordinate conversion
    │   └── moon.pkg                  -- Imports math, raylib
    ├── game/
    │   ├── game_update.mbt           -- Top-level update: camera, timer, state dispatch, init/reset
    │   ├── player_system.mbt         -- Player physics: movement, jumping, collision resolution, flag sequence, damage
    │   ├── enemy_system.mbt          -- Enemy AI: patrol, collision resolution, stomp/hurt detection
    │   ├── coin_system.mbt           -- Coin collection: overlap test and scoring
    │   ├── level.mbt                 -- Level construction: geometry, entity placement, reset
    │   ├── game_test.mbt             -- Integration tests: gravity, collision, jumping, stomping, flag, timer
    │   └── moon.pkg                  -- Imports types, particles, math, raylib
    ├── particles/
    │   ├── particles.mbt             -- Particle pool management, burst spawners, update loop
    │   └── moon.pkg                  -- Imports types, math, raylib
    └── render/
        ├── render_world.mbt          -- World rendering: background, tiles, flag, coins, enemies, player, particles
        ├── render_ui.mbt             -- HUD drawing, title/win/game-over overlay panels
        └── moon.pkg                  -- Imports types, math, raylib
```

The code is organized into five packages following an ECS-like separation of concerns. The `types` package defines all data structures and constants with zero gameplay logic. The `game` package contains all mutation and simulation logic, further split by system (player, enemy, coin, level). The `particles` package manages visual effects independently. The `render` package reads game state immutably and produces visuals. The main package ties everything together with the game loop.

### Data Flow

1. **Input**: `read_input()` in `main.mbt` polls raylib for keyboard state and produces an `Input` struct.
2. **Update**: `update_game(game, input, dt)` dispatches based on `game.state`. During playing, it calls `tick_level_timer`, `update_player`, `update_enemies`, `update_coins`, `update_particles`, and `update_camera` in sequence.
3. **Player Physics**: `update_player` processes input for movement/jumping, applies gravity and friction, resolves X and Y collisions against the tile grid separately, checks for flag trigger, and handles falling off the world.
4. **Enemy AI**: `update_enemies` applies gravity to each enemy, resolves tile collisions, reverses direction at ledges via `enemy_ground_ahead`, and tests player-enemy overlap for stomp (from above) or damage (from the side).
5. **Render**: `draw_world` computes camera offset and screen shake, then draws layers in order: parallax background, visible tiles (culled by camera), flag, coins, enemies, player (with invulnerability flicker), and particles. `draw_ui` overlays the HUD and state-specific panels.

### Key Design Patterns

- **Object Pool Pattern**: Enemies (56), coins (256), and particles (720) are pre-allocated in `Array` with `active` flags. Pool allocation scans for the first inactive slot. This avoids garbage collection pressure during gameplay.
- **Tile-Based Collision**: The world is a 236x22 integer grid. Collision resolution tests the player/enemy bounding box against tiles in both X and Y axes independently, resolving penetration by snapping to tile edges.
- **Coyote Time + Jump Buffering**: `coyote_t` allows jumping briefly after walking off a ledge (0.09s). `jump_buf_t` remembers jump input before landing (0.11s). Both improve perceived responsiveness.
- **Variable-Height Jumping**: Releasing the jump key while ascending applies extra gravity via `jump_cut_multiplier` (0.52), allowing short hops and full jumps from the same button.
- **Camera with Directional Lead**: The camera target leads the player in the direction they face by `camera_lead_px` (165 pixels), smoothed with a lerp factor of 9.0 per second.
- **Delta-Time Physics with Cap**: Frame time is capped at 0.05s (20 FPS minimum) to prevent physics explosions on lag spikes.
- **Screen Shake Feedback**: `shake_t` triggers random camera offset on enemy stomp, player damage, and flag arrival, adding juice to key moments.
- **Comprehensive Test Suite**: Both `utils_test.mbt` and `game_test.mbt` validate tile logic, coordinate conversion, and full integration scenarios (gravity, stomping, flag trigger, timer expiry).

## Improvement & Refinement Plan

1. **Replace integer state constants with an enum**: Game states (`state_title`, `state_playing`, etc.) and tile types (`tile_empty`, `tile_ground`, etc.) are represented as `Int` constants in `constants.mbt`. Using proper MoonBit enums with pattern matching would provide exhaustiveness checking and prevent invalid state values.

2. **Extract camera system into its own file**: `update_camera` in `game_update.mbt` handles camera lerp and lead logic. As the game grows with more camera behaviors (cutscene camera, zoom), separating it into a dedicated `camera.mbt` would improve modularity.

3. **Add scrolling-based enemy activation**: Currently all 13 enemies are active from the start. In `populate_level_entities` in `level.mbt`, enemies could be spawned with an activation x-threshold so they only begin patrolling when the camera scrolls near them, improving performance and gameplay pacing.

4. **Implement proper collision response for enemy-enemy interactions**: In `enemy_system.mbt`, enemies independently patrol and can overlap each other. Adding enemy-enemy collision detection would make them bounce off each other like in the original game, creating more dynamic encounters.

5. **Add power-up system**: The `on_player_hit_block` function in `player_system.mbt` only handles brick destruction and coin drops from question blocks. Adding mushroom/star power-ups that modify `Player` state (e.g., a `power_level` field) would deepen gameplay.

6. **Optimize tile rendering with dirty rectangles**: `draw_tiles` in `render_world.mbt` redraws all visible tiles every frame. Since most tiles are static, caching tile rendering to a texture and only redrawing when tiles change (brick destruction, question block hits) would reduce draw calls significantly.

7. **Add sound effects using raylib audio**: The game has visual feedback through particles and screen shake but no audio. Adding sound effect calls in `collect_coin`, `stomp_enemy`, `on_player_hurt`, and `try_trigger_flag` would greatly improve game feel.

8. **Improve the level timer with visual urgency**: In `tick_level_timer` in `game_update.mbt`, the timer simply counts down. Adding visual/audio cues when time is low (e.g., flashing the timer text red in `draw_hud` when `time_left < 60`, increasing music tempo) would create more tension in the final seconds.
