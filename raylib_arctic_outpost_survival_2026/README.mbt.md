# Arctic Outpost Survival 2026

A top-down survival shooter set in a frozen outpost where you defend a thermal core against waves of arctic creatures while managing suit HP, fuel, and ammo.

## Build and Run

```bash
moon build --target native raylib_arctic_outpost_survival_2026/
./_build/native/debug/build/raylib_arctic_outpost_survival_2026/raylib_arctic_outpost_survival_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move
- **J / Space**: Fire weapon
- **K**: Repair suit (uses core heat)
- **L**: Hint (shows nearest threat)
- **R**: Restart
- Touch buttons available on-screen

## How to Play

Survive 200 seconds against wolves, brutes, and ice shards attacking your outpost. Collect fuel, medkits, ammo, and overdrive pickups that spawn periodically. Monitor suit HP, core heat (your repair resource), and fuel. Storms periodically reduce visibility and increase enemy aggression. Eliminate enemies in quick succession for combo bonuses.

## Public API Reference

### Package `raylib_arctic_outpost_survival_2026`
> Entry point package. `main.mbt` initialises the window and audio device, creates the `Game` instance, and runs the main loop delegating to `@game.update_game` and `@render.draw_frame`.

#### Functions
| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Entry point: opens a 1720×980 window at 120 fps, allocates a `Game` via `Game::new`, polls input state into the game struct each frame, then calls `update_game` and `draw_frame` |

---

### Package `raylib_arctic_outpost_survival_2026/internal/types`
> Shared data definitions, constants, and utility functions used by both `game` and `render` packages.

#### Enums
| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `Result` | High-level game flow state; drives which overlay is drawn and which input handler runs |

#### Structs
| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Game` | `enemies, pickups, bullets, particles, state, player_x/y, player_vx/vy, aim_x/y, move_x/y, lives, suit_hp, core_heat, fuel, ammo, overdrive_t, fire_cd, repair_cd, score, best_score, wave, combo, combo_t, spawn_t, pickup_t, storm_t, game_t, ui_t, hint_left, hint_t, hint_x/y, msg, msg_t, shake_t, touch_cd, win, mouse_x/y, mouse_hold, touch_count` | Complete runtime state for one session; holds all object pools and every mutable gameplay variable |
| `Enemy` | `active, x, y, vx, vy, r, hp, kind, phase` | Enemy entity; `kind` selects behaviour (wolf/brute/shard), `phase` drives sinusoidal swirl |
| `Pickup` | `active, x, y, vx, vy, kind, phase` | Collectible that falls from the top of the world with slight horizontal drift |
| `Bullet` | `active, x, y, vx, vy, life, power, kind` | Player projectile; `kind` determines normal vs. piercing behaviour |
| `Particle` | `active, x, y, vx, vy, life, size, kind` | Short-lived visual spark; `kind` selects colour (0=cyan, 1=red, 2=purple) |

#### Constants
| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1720` | Window width in pixels |
| `screen_h` | `Int` | `980` | Window height in pixels |
| `target_fps` | `Int` | `120` | Target frame rate |
| `enemy_wolf` | `Int` | `0` | Fast melee enemy kind |
| `enemy_brute` | `Int` | `1` | Slow armoured enemy kind |
| `enemy_shard` | `Int` | `2` | Agile shard enemy kind |
| `pickup_fuel` | `Int` | `0` | Fuel canister pickup kind |
| `pickup_medkit` | `Int` | `1` | Medkit pickup kind |
| `pickup_ammo` | `Int` | `2` | Ammo crate pickup kind |
| `pickup_overdrive` | `Int` | `3` | Overdrive boost pickup kind |
| `bullet_normal` | `Int` | `0` | Standard projectile kind |
| `bullet_pierce` | `Int` | `1` | Piercing overdrive projectile kind |
| `max_enemies` | `Int` | `200` | Enemy pool capacity |
| `max_pickups` | `Int` | `100` | Pickup pool capacity |
| `max_bullets` | `Int` | `240` | Bullet pool capacity |
| `max_particles` | `Int` | `1600` | Particle pool capacity |
| `world_x0` | `Int` | `24` | World left edge in pixels |
| `world_y0` | `Int` | `20` | World top edge in pixels |
| `world_w` | `Int` | `1120` | World width in pixels |
| `world_h` | `Int` | `940` | World height in pixels |
| `panel_x0` | `Int` | `world_x0 + world_w + 24` | Right-side HUD panel left edge |
| `panel_w` | `Int` | `screen_w - panel_x0 - 24` | Right-side HUD panel width |
| `player_r` | `Float` | `22.0` | Player collision radius |
| `core_r` | `Float` | `72.0` | Core generator collision radius |
| `survival_time_goal` | `Float` | `200.0` | Seconds to survive for a win |

#### Functions
| Function | Signature | Description |
|----------|-----------|-------------|
| `Game::new` | `() -> Game` | Allocates all object pools and returns a game in the `Title` state with default resource values |
| `Enemy::new` | `() -> Enemy` | Creates an inactive enemy with zeroed fields |
| `Pickup::new` | `() -> Pickup` | Creates an inactive pickup with zeroed fields |
| `Bullet::new` | `() -> Bullet` | Creates an inactive bullet with zeroed fields |
| `Particle::new` | `() -> Particle` | Creates an inactive particle with zeroed fields |
| `core_x` | `() -> Float` | Returns the horizontal centre of the core generator |
| `core_y` | `() -> Float` | Returns the vertical centre of the core generator |
| `start_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) of the title-screen start button |
| `retry_button_rect` | `() -> (Int, Int, Int, Int)` | Returns (x, y, w, h) of the result-screen retry button |
| `btn_left/right/up/down` | `() -> (Int, Int, Int, Int)` | On-screen directional button rectangles |
| `btn_fire/repair/hint/restart` | `() -> (Int, Int, Int, Int)` | On-screen action button rectangles |
| `set_msg` | `(Game, String, Float) -> Unit` | Sets the transient HUD message and its display duration |
| `pickup_radius` | `(Int) -> Float` | Returns the collision radius for a given pickup kind |
| `point_in_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests whether a point lies inside an integer rectangle |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Tests mouse hold or any touch point against a rectangle |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Returns the squared Euclidean distance between two points |
| `normalize` | `(Float, Float) -> (Float, Float)` | Returns an L1-normalised direction vector |
| `world_left/right/top/bottom` | `() -> Float` | World boundary accessors |
| `mini/maxi` | `(Int, Int) -> Int` | Integer min/max |
| `minf/maxf` | `(Float, Float) -> Float` | Float min/max |
| `clampi` | `(Int, Int, Int) -> Int` | Integer clamp to [lo, hi] |
| `clampf` | `(Float, Float, Float) -> Float` | Float clamp to [lo, hi] |
| `absf` | `(Float) -> Float` | Float absolute value |
| `sinf/cosf` | `(Float) -> Float` | Sine/cosine via the core math backend |
| `randf` | `(Float, Float) -> Float` | Uniform random float in [lo, hi] |

---

### Package `raylib_arctic_outpost_survival_2026/internal/game`
> Simulation logic: input handling, state transitions, enemy/bullet/pickup/particle updates, and all gameplay rules. Exposes one public function consumed by `main`.

#### Functions
| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(@types.Game, Float) -> Unit` | Advances one simulation frame; dispatches to the appropriate input handler for the current `GameState` and then runs `update_play` |

---

### Package `raylib_arctic_outpost_survival_2026/internal/render`
> All drawing code. Reads `Game` state and issues raylib draw calls. Exposes one public function consumed by `main`.

#### Functions
| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(@types.Game) -> Unit` | Draws the complete frame: background, storm, core, enemies, pickups, bullets, hint marker, particles, player, HUD panel, touch controls, HUD message, and state overlays (title/result) |

## Architecture

### Package Structure
```
raylib_arctic_outpost_survival_2026/
├── main.mbt                        — window init, game loop, input polling
└── internal/
    ├── types/
    │   ├── constants.mbt           — all numeric constants and button-rect accessors
    │   ├── types.mbt               — struct/enum definitions and constructor functions
    │   └── utils.mbt               — math helpers, boundary accessors, pointer-hit tests, set_msg
    ├── game/
    │   ├── input.mbt               — input handlers for Title, Play, and Result states; auto-aim for touch fire
    │   └── logic.mbt               — spawning, physics, AI, collision, scoring, state transitions
    └── render/
        └── render.mbt              — all raylib draw calls, HUD, overlays, touch button rendering
```

### Data Flow
1. `main` polls mouse/touch state into the `Game` struct before each update, so input.mbt can read it without calling raylib directly.
2. `update_game` pattern-matches on `game.state` to select the correct input handler (`update_title_input`, `update_play_input`, or `update_result_input`), then calls `update_play` unconditionally so particles and timers animate on every screen.
3. `update_play` clamps `dt` to 0.04 s, ticks all cooldown timers, then runs the full simulation sub-pipeline: `update_particles`, `update_player`, `update_bullets`, `update_enemies`, `update_pickups`, and passive core-heat decay.
4. Enemy AI reads `game.wave` to scale speed and HP; wolves switch from targeting the core to targeting the player when within 280 px, while brutes and shards always chase the core with sinusoidal swirl offsets.
5. `draw_frame` applies a camera shake offset (`shake_x`/`shake_y`) derived from `game.shake_t` to every world-space draw call, keeping the HUD panel and overlays stable.
6. State transitions (`start_run`, `finish_run`) clear all pools and reset resource variables; `best_score` is preserved across runs.

### Key Design Patterns
- **ECS-style flat object pools**: All entity arrays (`enemies`, `bullets`, `pickups`, `particles`) are pre-allocated at startup with fixed capacities. Each element carries an `active` flag; iteration skips inactive slots and spawning claims the first inactive slot found.
- **Separation of concerns across packages**: `types` owns data, `game` owns simulation, `render` owns drawing. Neither `game` nor `render` imports the other, and both depend only on `types`. `main` wires them together.
- **State-machine game flow**: `GameState` drives which input handler and which overlay is active. `update_play` runs unconditionally so visual effects continue animating on the title and result screens.
- **Dual input model**: Keyboard/mouse and on-screen touch buttons are both handled in `input.mbt` via `pointer_on_rect` checks. Touch fire uses `best_auto_aim` to target the nearest enemy automatically.
- **Wave-scaled difficulty**: `game.wave` is derived from elapsed time (`1 + game_t / 22.0`, clamped to 12). Enemy spawn interval, enemy HP, enemy speed, and storm intensity all scale with `wave`, creating a smooth difficulty ramp without discrete level transitions.
- **Hint system with cost**: Players have 3 tactical hints that mark either the nearest needed supply pickup or the safest lane near the core. Each hint costs 6 score points, creating a meaningful trade-off between information and ranking.

## Improvement & Refinement Plan

- **Pathfinding around the core**: Enemies currently move in a straight line toward the core or player using L1 normalisation. Adding simple steering around the core's collision radius (e.g., a repulsion force when too close to the centre) would prevent enemies from stacking on the core and create more visible attack patterns.
- **Ammo type selection**: The game has `bullet_normal` and `bullet_pierce` but pierce is only accessible via the overdrive pickup. Introducing a second explicit ammo type (e.g., a spread shot) as a pickup or upgrade would add more decision-making to resource management.
- **Storm visual escalation**: `draw_storm` renders 80 animated line streaks with an alpha that scales with `game.wave`. Extending this to also reduce world visibility (e.g., a semi-transparent overlay that thickens with `storm_t`) would reinforce the arctic theme and make high-wave play feel more desperate.
- **Per-enemy-kind death animation**: All enemies call the same `burst` function on death. Giving wolves a fast white scatter, brutes a slow orange explosion, and shards a shattering pattern (e.g., 4 triangles flying outward) would make eliminations feel more distinct.
- **Core heat repair cooldown indicator**: `repair_cd` has a 1.10 s cooldown but there is no visual indicator in the HUD. Adding a small cooldown bar under the "Core heat" bar in the panel would let players time repairs without guessing.
- **Score breakdown on result screen**: The result overlay shows only total score, best score, wave, and time. Adding a breakdown (kills, repairs, pickups collected, combo peak) would give players more feedback for improving their next run.
- **Persistent best score across sessions**: `game.best_score` is reset when a new `Game` is allocated (i.e., on process restart). Writing it to a file or platform save would give the value meaning beyond a single session.
