# Breakout Lab 2026

A classic brick-breaker game with multi-hit bricks, power-ups, and 3 lives.

## Build and Run

```bash
moon build --target native breakout_lab_2026/
./_build/native/debug/build/breakout_lab_2026/breakout_lab_2026.exe
```

## Controls

- **A/D or Left/Right**: Move paddle
- **R**: Restart

## How to Play

Bounce a ball off your paddle to break bricks arranged at the top of the screen. Bricks have 1-3 HP depending on their row -- top rows require more hits and are worth more points. The ball speeds up as bricks are destroyed. Losing the ball below the paddle costs a life. Some bricks drop a wide-paddle power-up. Clear all 96 bricks to win.

## Public API Reference

### Package `breakout_lab_2026`
> Single-file game. All types, constants, helpers, and the main loop live in `main.mbt`. There are no internal sub-packages.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Brick` | `alive : Bool`, `x : Int`, `y : Int`, `hp : Int` | One brick on the grid. `hp` starts at 3 (rows 0-1), 2 (rows 2-4), or 1 (rows 5-7). When `hp` reaches 0 the brick is marked dead and a wide-paddle power-up may trigger. |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `fi` | `(Int) -> Float` | Convenience alias for `Float::from_int`. Used throughout physics calculations. |
| `make_bricks` | `() -> Array[Brick]` | Allocates all 96 bricks in row-major order at their pixel positions with HP assigned by row. |
| `reset_ball` | `() -> (Float, Float, Float, Float)` | Returns initial ball state `(x, y, vx, vy)`: centred horizontally, 120 px above the bottom, with velocity (180, -250) px/s. |
| `brick_color` | `(Int) -> @raylib.Color` | Maps HP to colour: 3 → maroon, 2 → orange, 1 → gold. |
| `main` | `() -> Unit` | Opens the window, runs the game loop: input, paddle movement, ball physics, brick collision, lives management, and drawing. |

#### Constants

| Constant | Type | Description |
|----------|------|-------------|
| `arena_w` | `Int` | Window width: 960 px. |
| `arena_h` | `Int` | Window height: 720 px. |
| `bricks_cols` | `Int` | Brick columns: 12. |
| `bricks_rows` | `Int` | Brick rows: 8 (96 bricks total). |
| `brick_w` | `Int` | Brick width: 70 px. |
| `brick_h` | `Int` | Brick height: 24 px. |
| `brick_gap` | `Int` | Gap between bricks: 5 px. |
| `bricks_x0` | `Int` | Left edge of brick grid: 36 px. |
| `bricks_y0` | `Int` | Top edge of brick grid: 80 px. |

## Architecture

### Package Structure

```
breakout_lab_2026/
└── main.mbt   — constants, Brick struct, make_bricks, reset_ball, brick_color, main loop
```

### Data Flow

The entire game is contained in `main{}`. On startup `make_bricks()` creates the 96-brick array and `reset_ball()` returns the initial ball position and velocity. All state (brick array, paddle position and width, ball position and velocity, lives, score, flags) is held in local `let mut` variables in the loop scope. Each frame reads `get_frame_time()`, clamps it to 50 ms to prevent tunnelling on frame spikes, then processes input, physics, and drawing sequentially.

Paddle movement is computed at 480 px/s from left/right input and clamped to arena bounds. Ball-wall reflection uses direct sign flips on `vx` or `vy`. Paddle collision uses a penetration check and re-positions the ball just above the paddle to prevent sticking; the exit angle is set by the hit position relative to paddle centre (`t` in [0,1] mapped to vx), and `vy` is multiplied by 1.02 to gradually increase vertical speed over the course of the game.

Brick collision iterates the full array each frame and breaks after the first hit. It uses minimum penetration depth across the four sides to decide whether to reflect `vx` (left/right hit) or `vy` (top/bottom hit). Every hit scores 10 points; destroying a brick (hp reaching 0) adds 40 more. When a brick is destroyed the code does a 1-in-12 chance roll (`get_random_value(0, 11) == 0`) to trigger the wide-paddle power-up, capped at 190 px. The `win` flag is set when `alive_count` reaches 0 at the end of the brick iteration.

### Key Design Patterns

- **Single-file, flat state**: No structs for game-wide state; all variables live as named locals in `main`, making the full state immediately visible without navigating multiple files.
- **Penetration-based brick reflection**: Instead of testing which face was approached first, the code measures overlap on each axis and reflects the axis with the smaller penetration depth. This handles corner hits gracefully without requiring swept collision.
- **Immediate power-up activation**: There is no power-up item that falls on screen. The wide-paddle effect is applied instantly and invisibly when a brick is destroyed; the paddle simply grows. This keeps the implementation minimal while still rewarding brick clears.
- **Frame-time clamping**: `dt` is capped at 0.05 s (20 fps equivalent) so that a lag spike or debugger pause does not cause the ball to tunnel through bricks or the paddle.

## Improvement & Refinement Plan

1. **Falling power-up items**: Rather than applying the wide-paddle effect instantly, spawn a falling icon at the brick position that the player must catch with the paddle. This would add a second layer of active gameplay and make power-up acquisition feel earned.
2. **Multiple ball types and speeds**: The ball speed increases only on paddle bounces via the 1.02 multiplier. Adding a cap and a separate launch speed per level would make later waves feel progressively more intense without the speed growing unboundedly.
3. **Score multiplier for combos**: Back-to-back brick hits without the ball touching the paddle or walls could increment a multiplier shown on screen, rewarding skilled positioning.
4. **Persistent high score**: The current `score` variable resets on `R`. Saving the best score to a file between sessions would give players a target to beat across multiple runs.
5. **Level progression**: After all bricks are cleared the game shows "STAGE CLEAR" and waits for `R`. Adding automatic progression to a next stage with a different brick layout or tighter initial ball speed would extend replayability beyond a single session.
6. **Sound effects**: There are no audio calls. Short beeps on wall/paddle hits and a higher-pitched tone on brick destruction would give essential tactile feedback that the purely visual game currently lacks.
7. **Touch and mouse input**: The game only reads keyboard input. Adding mouse or touch drag for paddle control would allow play on devices without a physical keyboard.
