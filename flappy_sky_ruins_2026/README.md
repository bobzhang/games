# flappy_sky_ruins_2026

A flappy-bird-style game set in ancient sky ruins. Flap through gates, dodge beams and spinners, collect pickups (score, boost, shield, hearts), and survive as long as possible with escalating difficulty levels.

## Build and Run

```bash
moon build --target native flappy_sky_ruins_2026/
./_build/native/debug/build/flappy_sky_ruins_2026/flappy_sky_ruins_2026.exe
```

## Controls

- **Space/J or click FLAP button**: Flap (gain altitude)
- **K or click BOOST button**: Activate boost (temporary speed and invulnerability)
- **R**: Restart
- Touch buttons available in the side panel

## How to Play

- Tap to flap and navigate through gaps in obstacle gates
- Three obstacle types: standard gates, horizontal beams, and rotating spinners
- Collect pickups: score gems, boost charges, shields (temporary invulnerability), and extra hearts
- Build combos by passing through gates without getting hit
- Shield absorbs one hit; boost meter fills from pickups
- Difficulty increases over time with faster and tighter obstacles
- 3 lives; game ends when all are lost

## Public API Reference

### Package `tonyfettes/raylib-examples/flappy_sky_ruins_2026`

#### Functions

- **`fn main`** — Entry point. Opens a 1720 x 980 window at 120 fps, creates a `Game` with `Game::new()`, routes input and simulation through the `@game` and `@render` packages each frame, and closes the window on exit.

---

### Package `tonyfettes/raylib-examples/flappy_sky_ruins_2026/internal/types`

#### Enums

- **`enum GameState`** — High-level phase of a run: `Title`, `Play`, `Result`. Derives `Eq`.

#### Structs

- **`struct Game`** — Full mutable game state. Fields: `obstacles : Array[Obstacle]`, `pickups : Array[Pickup]`, `particles : Array[Particle]`, `state : GameState`, `px / py / vy : Float` (player position and vertical velocity), `lives : Int`, `shield_t : Float`, `boost_meter : Float`, `boost_on : Bool`, `boost_t : Float`, `score / best_score / distance / combo : Int`, `combo_t / level / spawn_t / pickup_t / game_t / ui_t : Float`, `msg : String`, `msg_t : Float`, `hint_left : Int`, `hint_t / hint_y / shake_t / touch_cd : Float`, `win : Bool`, `mouse_x / mouse_y : Float`, `mouse_hold : Bool`, `touch_count : Int`.
- **`struct Obstacle`** — Active scrolling hazard. Fields: `active : Bool`, `x / gap_y / gap_h / w / speed / phase : Float`, `kind / scored : Int/Bool`.
- **`struct Pickup`** — Active collectible. Fields: `active : Bool`, `x / y / phase : Float`, `kind : Int`.
- **`struct Particle`** — Pooled visual particle. Fields: `active : Bool`, `x / y / vx / vy / life / size : Float`, `kind : Int`.

#### Functions

- **`fn Game::new() -> Game`** — Allocates object pools (72 obstacles, 64 pickups, 1300 particles) and initialises all fields to title-screen defaults.
- **`fn Obstacle::new() -> Obstacle`** — Creates an inactive obstacle with gate-kind defaults.
- **`fn Pickup::new() -> Pickup`** — Creates an inactive pickup with score-kind defaults.
- **`fn Particle::new() -> Particle`** — Creates an inactive particle for pool use.
- **`fn mini(Int, Int) -> Int`** — Returns the smaller of two integers.
- **`fn clampi(Int, Int, Int) -> Int`** — Clamps an integer to `[lo, hi]`.
- **`fn clampf(Float, Float, Float) -> Float`** — Clamps a float to `[lo, hi]`.
- **`fn maxf(Float, Float) -> Float`** — Returns the larger of two floats.
- **`fn randf(Float, Float) -> Float`** — Returns a pseudo-random float in `[lo, hi]`.
- **`fn world_left() -> Float`** — Left edge of the playable world area.
- **`fn world_right() -> Float`** — Right edge of the playable world area.
- **`fn world_top() -> Float`** — Top edge of the playable world area.
- **`fn world_bottom() -> Float`** — Bottom edge of the playable world area.
- **`fn set_msg(Game, String, Float) -> Unit`** — Sets the transient HUD message and its lifetime in seconds.
- **`fn pointer_on_rect(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool`** — Returns true when an active pointer (mouse hold or touch) is inside the given rectangle.
- **`fn obstacle_gap_mid(Obstacle) -> Float`** — Returns the effective vertical gap centre, accounting for spinner oscillation (`sin(phase) * 120`).
- **`fn start_button_rect() -> (Int, Int, Int, Int)`** — Title-screen start button region.
- **`fn retry_button_rect() -> (Int, Int, Int, Int)`** — Result-screen retry button region.
- **`fn btn_flap_rect() -> (Int, Int, Int, Int)`** — Touch panel flap button region.
- **`fn btn_boost_rect() -> (Int, Int, Int, Int)`** — Touch panel boost button region.
- **`fn btn_restart_rect() -> (Int, Int, Int, Int)`** — Touch panel restart button region.
- **`fn btn_hint_rect() -> (Int, Int, Int, Int)`** — Touch panel hint button region.

#### Constants

| Name | Value | Description |
|------|-------|-------------|
| `screen_w` | `1720` | Window width in pixels |
| `screen_h` | `980` | Window height in pixels |
| `target_fps` | `120` | Target frame rate |
| `player_r` | `24.0` | Player collision radius |
| `gravity` | `1220.0` | Downward acceleration (px/s²) |
| `flap_impulse` | `-420.0` | Upward velocity applied on flap |
| `max_obs` | `72` | Obstacle pool size |
| `max_pickups` | `64` | Pickup pool size |
| `max_particles` | `1300` | Particle pool size |
| `obstacle_kind_gate` | `0` | Static gate obstacle |
| `obstacle_kind_beam` | `1` | Horizontal beam hazard |
| `obstacle_kind_spinner` | `2` | Oscillating spinner hazard |
| `pickup_score` | `0` | Score-bonus pickup |
| `pickup_boost` | `1` | Boost-refill pickup |
| `pickup_shield` | `2` | Shield pickup |
| `pickup_heart` | `3` | Extra-life pickup |
| `panel_x0` | `1180` | Left edge of the side panel |
| `panel_w` | `516` | Width of the side panel |
| `world_x0` | `24` | Left edge of the play area |
| `world_y0` | `20` | Top edge of the play area |
| `world_w` | `1132` | Width of the play area |
| `world_h` | `940` | Height of the play area |

---

### Package `tonyfettes/raylib-examples/flappy_sky_ruins_2026/internal/game`

#### Functions

- **`pub fn update_play(@types.Game, Float) -> Unit`** — Advances one simulation step: ticks timers (boost, shield, hint, shake, combo), integrates physics, spawns and scrolls obstacles and pickups, runs collision detection, checks level-up and win condition.
- **`pub fn update_play_input(@types.Game, Float) -> Unit`** — Processes in-run keyboard, mouse, and touch input: flap, boost hold, hint use, restart, and return-to-title.
- **`pub fn update_title_input(@types.Game) -> Unit`** — Handles title-screen input (Space, Enter, click, or touch on start button) and calls `start_match`.
- **`pub fn update_result_input(@types.Game) -> Unit`** — Handles result-screen retry input (R, Enter, click, or touch on retry button) and calls `start_match`.

---

### Package `tonyfettes/raylib-examples/flappy_sky_ruins_2026/internal/render`

#### Functions

- **`pub fn draw_frame(@types.Game) -> Unit`** — Draws the complete frame: animated background, world viewport, all active obstacles with their kind-specific shapes, pickups with sine-wave bob, particles, the player sprite with shield ring and boost trail, the side panel with score and controls, HUD message, and title/result overlays with screen-shake offset.

## Architecture

### Package Structure

```
flappy_sky_ruins_2026/
├── main.mbt                    # Entry point: window, game loop, state dispatch
├── moon.pkg                    # Package manifest
└── internal/
    ├── types/
    │   ├── constants.mbt       # All pub let constants and button rect functions
    │   ├── types.mbt           # Structs (Game, Obstacle, Pickup, Particle), GameState enum, constructors
    │   └── utils.mbt           # Math helpers, world boundary functions, set_msg, pointer_on_rect, obstacle_gap_mid
    ├── game/
    │   ├── input.mbt           # update_title_input, update_result_input, update_play_input
    │   └── logic.mbt           # update_play, physics, spawning, collision, scoring, level-up, win check
    └── render/
        └── render.mbt          # draw_frame and all draw_* helpers
```

### Data Flow

`main.mbt` owns the single `Game` value and drives the loop. Each frame it reads raw input into `game.mouse_x`, `game.mouse_y`, `game.mouse_hold`, and `game.touch_count`, then dispatches to `@game.update_title_input`, `@game.update_play_input`, or `@game.update_result_input` based on `game.state`, followed unconditionally by `@game.update_play`. Drawing is performed by a single `@render.draw_frame` call inside `begin_drawing`/`end_drawing`.

The `internal/types` package is the sole shared dependency. All other packages import it with `@types`; no package imports `@game` or `@render` internally, which enforces a strict layered dependency: `types` ← `game`, `render` ← `main`.

`update_play` in `game/logic.mbt` owns all simulation: it advances the boost meter, runs the particle system, then (only when `state == Play`) integrates player velocity under gravity, clamps to world bounds, scrolls and culls obstacles and pickups, performs circle-vs-AABB and circle-vs-circle collision tests, updates score and combo, and checks for level-up (every 520 score points) and win (at `game_t >= 180 s`). Input functions mutate `Game` fields directly; they call private helpers (`flap`, `use_hint`, `start_match`) that are not exported.

The render package reads `Game` fields purely for drawing; it writes no simulation state. `draw_frame` applies a camera shake offset (`shake_t > 0`) to the world viewport translation before drawing obstacles, pickups, and particles, keeping the shake effect self-contained in the render layer.

### Key Design Patterns

- **Three-layer package separation** — `types` (data) / `game` (logic) / `render` (drawing) enforces unidirectional data flow and makes each layer independently testable.
- **Fixed-size object pools** — Obstacles (72), pickups (64), and particles (1300) are pre-allocated as `Array` and reused via `active` flags, eliminating GC pressure during gameplay.
- **State-dispatched input** — The main loop routes to a different input function for each `GameState`, so `update_play_input` never needs to guard against being called during the title screen.
- **Continuous difficulty scaling** — Obstacle speed, gap size, and spawn interval all depend on `game.level`, which is recomputed every frame as `clamp(1 + score / 520, 1, 10)`, providing smooth escalation without discrete difficulty tiers.
- **Unified touch and mouse input** — `pointer_on_rect` accepts both `mouse_hold` and `touch_count`, so all button hit-tests are written once and work for desktop and mobile input without conditional branches at the call site.
- **Deferred win/loss in result state** — After transitioning to `Result`, `update_play` continues ticking particles and boost meter, so visual feedback (particle burst, screen shake) completes naturally without a separate cleanup pass.

## Improvement & Refinement Plan

1. **Persistent best-score storage** — `best_score` resets to 0 when the process exits because it is stored only in `Game` memory. Writing it to `@raylib.save_storage_value` would allow the high-score display to survive restarts.
2. **Per-kind obstacle visual differentiation** — Beams and spinners use distinct `kind` values but their rendering could be more visually distinct. Adding a rotating sprite or animated colour cycle for spinners proportional to `obstacle.phase` would improve readability at higher speeds.
3. **Combo multiplier on score pickups** — Collecting a `pickup_score` gem awards a flat `90 + level * 4` bonus regardless of combo. Applying the current combo count as a multiplier would reward players who chain pickups between obstacles.
4. **Hint arrow fade-out** — The hint ring snaps off when `hint_t` reaches 0. Fading the ring alpha over the last 0.4 s using `hint_t / 1.6` would make the disappearance less abrupt.
5. **Boost audio feedback** — The boost system has a dedicated `boost_t` counter but no sound effect. Adding a pitched whoosh tied to `boost_on` state would communicate the speed increase without relying on visual cues alone.
6. **Obstacle gap narrowing cap** — `gap_h` at level 10 reaches `340 - 10 * 4 = 300`, already clamped to 170 at minimum. Exposing the minimum gap as a named constant in `constants.mbt` would make balance tuning explicit.
7. **Result screen score breakdown** — The result overlay shows only total score and best score. Adding distance and combo-peak fields (already tracked in `Game`) would give players more feedback on which part of their run scored the most.
