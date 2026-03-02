# Bowling Alley Showdown 2026

Bowling Alley Showdown 2026 is a ten-pin bowling simulation built with MoonBit and raylib. Set in a stylized neon-tinged bowling alley, the game delivers a complete 10-frame match experience with realistic ball-to-pin and pin-to-pin collision physics, spin control, and standard bowling scoring including strikes, spares, and the special 10th-frame bonus rules.

The core gameplay loop revolves around aiming, applying spin, and charging throw power before releasing the ball down a rendered lane. The ball's trajectory is influenced by the aim angle and spin value, curving as it travels toward the triangular pin formation. Knocked pins chain-react into neighboring standing pins, creating satisfying cascading knockdowns with particle burst effects and screen shake feedback. After each roll, the game computes the score using standard bowling rules -- strikes earn the next two rolls as bonus, spares earn the next one roll, and the 10th frame allows up to three balls.

Technically, the game uses a pre-allocated object pool for 1200 spark particles, Newton-style iterative square root computation, and a full bowling score recomputation system that handles all edge cases including incomplete frames and 10th-frame bonus balls. Touch-friendly on-screen controls make it playable on mobile devices alongside keyboard input.

## Build and Run

```bash
moon build --target native raylib_bowling_alley_2026/
./_build/native/debug/build/raylib_bowling_alley_2026/raylib_bowling_alley_2026.exe
```

## Controls

- **A / D or Left / Right Arrow**: Adjust aim angle left or right
- **Q / E**: Adjust spin left or right
- **Space / Enter (hold + release)**: Charge throw power and release to throw the ball
- **Left Mouse Button (hold + release)**: Charge throw power and release to throw
- **R**: Restart the match
- **Escape**: Return to title screen
- **Touch Aim-/Aim+ buttons**: Adjust aim on touch devices
- **Touch Spin-/Spin+ buttons**: Adjust spin on touch devices
- **Touch Hold/Release button**: Charge and throw on touch devices

## How to Play

From the title screen, press Enter, Space, or click/tap the "Start Match" button to begin a 10-frame bowling match. Each frame gives you up to two rolls to knock down all 10 pins. Before throwing, use the aim controls to angle the ball left or right (up to 36 degrees) and the spin controls to add curve (-1.0 to +1.0). Hold the power button to charge -- power oscillates between 14% and 100%, so timing the release is key to controlling throw strength.

Once released, the ball travels up the lane, curving based on spin. It collides with pins, knocking them down with physics-based impulse. Fallen pins can chain-hit standing neighbors if moving fast enough, enabling cascading knockdowns. After pins settle, the knocked count is scored.

**Scoring follows standard bowling rules:**
- **Strike** (all 10 pins on first roll): Score 10 plus the next two roll totals as bonus
- **Spare** (all 10 across two rolls): Score 10 plus the next roll total as bonus
- **Open frame**: Score equals total pins knocked in that frame
- **10th frame**: A strike or spare earns bonus balls (up to 3 total rolls); an open frame ends the match

The score grid on the right panel shows frame-by-frame marks (X for strikes, / for spares) and running totals. The match ends after all 10 frames, displaying a grade: "Perfect Storm" (240+), "Pro League" (200+), "Solid Match" (160+), or "Keep Training" (below 160). Your best score persists across matches within the same session.

## Public API Reference

### Package `raylib_bowling_alley_2026`

> Main entry point. Initializes the window at 1720x980 with MSAA 4x, runs the game loop reading input, calling `update_game`, and calling `draw_frame` each frame.

No additional public types or functions beyond the `main` entry point.

### Package `raylib_bowling_alley_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `Result` | State machine controlling which screen is active |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Pin` | `standing`, `x`, `y`, `vx`, `vy`, `ang`, `ang_v` | A bowling pin with position, velocity, rotation angle, and standing status |
| `Spark` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | A particle effect element from the pre-allocated spark pool |
| `Game` | `pins`, `sparks`, `rolls`, `frame_totals`, `state`, `frame`, `ball_x`, `ball_y`, `power`, `aim`, `spin`, `score`, `best_score` | Main game state container holding all match data, ball physics, UI timers, and scoring arrays |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Pin::new` | `() -> Pin` | Creates a new pin with default values, standing at origin |
| `Spark::new` | `() -> Spark` | Creates a new inactive spark particle |
| `Game::new` | `() -> Game` | Creates a new game with 10 pins, 1200 sparks, 24-roll array, and default state |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1720` | Window width in pixels |
| `screen_h` | `Int` | `980` | Window height in pixels |
| `target_fps` | `Int` | `120` | Target frame rate |
| `lane_x` | `Int` | `90` | Lane left edge X position |
| `lane_y` | `Int` | `40` | Lane top edge Y position |
| `lane_w` | `Int` | `970` | Lane width in pixels |
| `lane_h` | `Int` | `900` | Lane height in pixels |
| `lane_left` | `Float` | `90.0` | Lane left boundary as float |
| `lane_top` | `Float` | `40.0` | Lane top boundary as float |
| `lane_right` | `Float` | `1060.0` | Lane right boundary as float |
| `lane_bottom` | `Float` | `940.0` | Lane bottom boundary as float |
| `foul_line_y` | `Float` | `794.0` | Y position of the foul line |
| `pin_deck_y` | `Float` | `188.0` | Y position where pin rows begin |
| `pin_row_gap` | `Float` | `44.0` | Vertical gap between pin rows |
| `pin_col_gap` | `Float` | `41.0` | Horizontal gap between pins in a row |
| `pin_radius` | `Float` | `13.0` | Collision radius of a pin |
| `ball_radius` | `Float` | `18.0` | Collision radius of the ball |
| `ball_start_x` | `Float` | center of lane | Ball initial X position |
| `ball_start_y` | `Float` | lane bottom - 58 | Ball initial Y position |
| `aim_min` | `Float` | `-36.0` | Minimum aim angle in degrees |
| `aim_max` | `Float` | `36.0` | Maximum aim angle in degrees |
| `spin_min` | `Float` | `-1.0` | Minimum spin value |
| `spin_max` | `Float` | `1.0` | Maximum spin value |
| `max_rolls` | `Int` | `24` | Maximum number of rolls stored |
| `max_sparks` | `Int` | `1200` | Size of the pre-allocated spark pool |
| `panel_x0` | `Int` | lane right + 24 | Side panel X origin |
| `panel_w` | `Int` | remaining width - 28 | Side panel width |

#### Utility Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value between lo and hi bounds |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `maxf` | `(Float, Float) -> Float` | Returns the larger of two float values |
| `randf` | `(Float, Float) -> Float` | Returns a random float in [lo, hi] using raylib RNG |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Returns the squared Euclidean distance between two 2D points |
| `deg_to_rad` | `(Float) -> Float` | Converts degrees to radians |
| `sqrtf` | `(Float) -> Float` | Computes square root using 6-iteration Newton's method |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Tests if a mouse/touch pointer is within a rectangle when held |
| `title_start_hover` | `(Float, Float, Bool, Int) -> Bool` | Tests if pointer is over the title screen start button |
| `result_retry_hover` | `(Float, Float, Bool, Int) -> Bool` | Tests if pointer is over the result screen retry button |
| `panel_rect` | `() -> (Int, Int, Int, Int)` | Returns the side panel bounding rectangle |
| `title_start_button` | `() -> (Int, Int, Int, Int)` | Returns the start button bounding rectangle |
| `retry_button` | `() -> (Int, Int, Int, Int)` | Returns the retry button bounding rectangle |
| `touch_aim_left_rect` | `() -> (Int, Int, Int, Int)` | Returns the touch aim-left button rectangle |
| `touch_aim_right_rect` | `() -> (Int, Int, Int, Int)` | Returns the touch aim-right button rectangle |
| `touch_spin_left_rect` | `() -> (Int, Int, Int, Int)` | Returns the touch spin-left button rectangle |
| `touch_spin_right_rect` | `() -> (Int, Int, Int, Int)` | Returns the touch spin-right button rectangle |
| `touch_power_rect` | `() -> (Int, Int, Int, Int)` | Returns the touch power/throw button rectangle |

### Package `raylib_bowling_alley_2026/internal/game`

> Game logic, input handling, physics simulation, and scoring.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main update entry point -- dispatches to title, play, or result input/logic based on game state |
| `frame_marks` | `(Game, Int) -> (String, String, String)` | Returns the display marks for a given frame (X, /, digit, or blank) for up to 3 rolls in the 10th frame |

### Package `raylib_bowling_alley_2026/internal/render`

> Rendering and visual effects.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main rendering entry point -- draws background, lane, pins, ball, sparks, side panel, touch overlay, and title/result screens based on game state |

## Architecture

### Package Structure

```
raylib_bowling_alley_2026/
├── main.mbt              — Entry point: window init, input polling, game loop
├── moon.pkg              — Package config with imports and options
└── internal/
    ├── types/
    │   ├── types.mbt     — GameState enum, Pin/Spark/Game structs, constructors
    │   ├── constants.mbt — Lane dimensions, physics constants, UI rect functions
    │   └── utils.mbt     — Math utilities, pointer hit-testing, button hover checks
    ├── game/
    │   ├── input.mbt     — Keyboard and touch input handling per game state
    │   ├── logic.mbt     — Ball physics, pin collision, chain reactions, match flow
    │   └── scoring.mbt   — Roll tracking, standard bowling score computation, frame marks
    └── render/
        └── render.mbt    — Lane drawing, pin/ball/spark rendering, score grid, UI panels
```

The `types` package is the foundation, providing all data structures and constants with no game logic dependencies. The `game` package imports `types` and implements all gameplay systems: input processing, ball physics, pin collision detection, chain-hit propagation, and the full bowling scoring algorithm. The `render` package imports both `types` and `game` (for `frame_marks`) and handles all visual output. The root package ties everything together in a standard init-loop-cleanup pattern.

### Data Flow

1. **Input gathering**: `main.mbt` reads mouse position, touch count, and hold state from raylib each frame, storing them in the `Game` struct. `update_play_input` reads keyboard keys (A/D, Q/E, Space, Enter) and touch button regions to update `aim`, `spin`, and `power` values. Power oscillates while held; release triggers `throw_ball`.

2. **Physics update**: `update_ball` moves the ball by velocity, applies spin-induced lateral drift, and dampens speed over time. Wall bounces reflect velocity. `collide_ball_pins` checks ball-pin distances against combined radii and applies impulse-based knockdowns. `update_pin_motion` moves fallen pins with friction and wall clamping. `chain_pin_hits` propagates fast-moving fallen pins into standing neighbors.

3. **Scoring**: When pins settle (`pins_are_quiet`), `on_roll_scored` records the knocked count, determines if the frame was a strike or spare, advances the frame counter, and calls `recompute_score` which walks the roll array applying standard bowling bonus rules.

4. **Rendering**: `draw_frame` branches by state. During play, it draws the lane with screen-shake offset, the aim guide line, all pins (standing or fallen), the ball, spark particles, the side panel (score grid, stats, power bar, controls), and the touch overlay. The result screen overlays a grade card with final stats.

### Key Design Patterns

- **Object pool pattern**: 1200 `Spark` particles are pre-allocated in an array. `spawn_spark` finds the first inactive slot; `update_sparks` deactivates expired particles. No runtime allocation occurs during gameplay.
- **State machine**: The `GameState` enum (`Title`, `Play`, `Result`) cleanly separates input handling and rendering branches via match expressions.
- **ECS-like separation**: Types, game logic, and rendering are in separate packages. The `Game` struct is the single source of truth passed through all systems.
- **Physics with collision chaining**: Ball-pin collisions use impulse-based knockdown, and `chain_pin_hits` checks if fast-moving fallen pins collide with standing ones, creating realistic cascading knockdowns.
- **Oscillating power meter**: Power charges up and down between 14% and 100% while held, requiring timing skill to release at the desired power level.
- **Standard bowling scoring**: The `recompute_score` function correctly handles all edge cases: strikes consuming one roll index, spares needing look-ahead, incomplete frames, and the 10th frame's special 3-ball rules.

## Improvement & Refinement Plan

1. **Add gutter detection and gutter ball feedback**: Currently the ball bounces off lane walls (`update_ball` clamps to `lane_left + 28` and `lane_right - 28`). Real bowling has gutters that eliminate the ball. Adding gutter zones outside the lane edges would increase realism and challenge.

2. **Implement pin-to-pin collision with proper mass transfer**: The `chain_pin_hits` function uses a flat 0.62 velocity transfer. Implementing proper elastic collision with mass ratios would create more realistic pin scatter patterns and improve the feel of near-miss shots.

3. **Extract magic numbers into named constants**: Physics values like `520.0 + game.power * 780.0` (throw speed), `44.0` (spin lateral force), `95.0` (ball deflection on pin hit), and damping factors (0.56, 0.42, 0.83) in `logic.mbt` should be promoted to named constants in `constants.mbt` for easier tuning.

4. **Add sound effects using the initialized audio device**: `main.mbt` calls `init_audio_device` and `close_audio_device` but no sounds are ever played. Adding strike/spare celebration sounds, pin collision impacts, ball rolling, and gutter sounds would significantly enhance the experience.

5. **Improve the `sqrtf` implementation**: The custom 6-iteration Newton's method in `utils.mbt` starts with `x = v` for values >= 1, which converges slowly for large inputs. Using a better initial estimate (e.g., bit manipulation or starting at `v/2`) would improve convergence, or simply use the standard library `@math.sqrt`.

6. **Add ball position adjustment before throwing**: Currently the ball always starts at the lane center (`ball_start_x`). Real bowling allows lateral positioning before the throw. Adding left/right ball placement would add strategic depth for targeting specific pin pockets.

7. **Persist best score across sessions**: The `best_score` field resets when the game restarts. Saving it to a file or local storage would give players a persistent high score to beat, adding long-term motivation.

8. **Add frame-by-frame replay or slow motion on strikes**: When a strike occurs, the game could briefly slow down time or replay the pin scatter, giving visual reward for the achievement and leveraging the already-existing spark particle system for dramatic effect.
