# Ice Fishing Blitz 2026

Ice Fishing Blitz 2026 is an arcade action game set on a frozen lake where the player controls a fishing hook dangled through an ice hole into deep water. The goal is to catch fish of varying species and value -- trout, salmon, and rare golden fish -- while dodging underwater hazards including jellyfish, electric eels, and falling ice chunks.

The core gameplay loop involves steering the hook through the underwater world, engaging the hook clamp near a fish to grab it, then reeling the hooked fish up to the catch zone near the ice hole surface. Successfully landing fish earns points with a combo multiplier, while collisions with hazards damage the fishing line. Pickups floating in the water provide bait refills, line repairs, and thermos-powered turbo speed boosts. The player must reach a score goal of 1600 points before running out of lives (3 lives, each lost when line HP hits zero) or before the 200-second time limit expires.

The game features wave-based difficulty scaling (10 waves over the session), touch-screen controls alongside keyboard input, a hint system that highlights high-value targets, and a manual line repair mechanic that consumes bait energy. Bait drains continuously and faster during boost, and when bait reaches zero the line HP deteriorates automatically.

## Build and Run

```bash
moon build --target native ice_fishing_blitz_2026/
./_build/native/debug/build/ice_fishing_blitz_2026/ice_fishing_blitz_2026.exe
```

## Controls

### Keyboard
- **W / Up Arrow**: Move hook up
- **S / Down Arrow**: Move hook down
- **A / Left Arrow**: Move hook left
- **D / Right Arrow**: Move hook right
- **Space**: Toggle hook clamp on/off (grab or release fish)
- **Left Shift / Right Shift / J**: Boost (increase hook speed while held)
- **E**: Repair line (requires being near the ice hole surface and 8+ bait energy)
- **H**: Use hint (highlights the best nearby target, costs 5 score, 3 hints per run)
- **R**: Restart the run
- **Escape**: Return to title screen
- **Enter / Space**: Start game from title, retry from result screen

### Touch Controls (Mobile)
- **L / R / U / D buttons**: Directional movement
- **HOOK button**: Toggle hook clamp
- **BST button**: Boost speed
- **RPR button**: Repair line
- **HNT button**: Use hint
- **RST button**: Restart

## How to Play

From the title screen, press Enter, Space, or click/tap the START FISHING button. The hook starts just below the ice hole.

**Catching fish**: Steer the hook toward a fish using WASD. When close enough, press Space to engage the clamp. The fish attaches to the hook and follows it. Reel the hooked fish up to the CATCH ZONE area near the ice hole surface to land it and score points. Points are calculated as the fish's base value plus combo bonus (combo level x 2) plus current wave number.

**Fish types**: Trout (58% spawn rate, radius 16-22, value 22-35), Salmon (32% spawn rate, radius 22-28, value 38-56), and Golden fish (10% spawn rate, radius 14-20, value 70-110, may randomly despawn).

**Hazards**: Jellyfish drift with sinusoidal motion (7-12 damage), Eels actively chase the hook (10-16 damage), and Ice chunks fall from the surface at increasing speeds (14-24 damage). Hazard collisions can also knock a hooked fish loose (34% chance).

**Pickups**: Bait crates restore 34 bait energy, Repair kits restore 26 line HP, and Thermos pickups grant 7 seconds of turbo speed.

**Resource management**: Bait energy drains at 1.0 + wave*0.07 per second (2.5 + wave*0.10 during boost). When bait hits zero, line HP deteriorates at 6 HP/sec. Manual repair (E key) costs 8 bait and restores 30 line HP with a 1.1s cooldown, but only works near the ice hole surface. When line HP reaches zero, you lose a life (3 total), the line resets with 14 bait deducted.

**Win/lose conditions**: Reaching 1600 score wins. Running out of all 3 lives loses. If the 200-second timer expires, you win if score is at least 80% of the goal (1280), otherwise lose.

## Public API Reference

### Package `ice_fishing_blitz_2026`

> Main entry point.

The `main` function initializes a 1720x980 window with MSAA 4x and audio device, creates a `Game` instance, and runs the game loop at 120 FPS calling `update_game` and `draw_frame` each frame.

### Package `ice_fishing_blitz_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `Result` | Game state machine states |
| `PickupKind` | `Bait`, `Repair`, `Thermos` | Types of collectible pickups |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Fish` | `active`, `x`, `y`, `vx`, `vy`, `r`, `value`, `kind`, `phase`, `hooked` | A fish entity with position, velocity, radius, point value, species type, and hooked status |
| `Hazard` | `active`, `x`, `y`, `vx`, `vy`, `r`, `dmg`, `kind`, `phase` | An underwater hazard with position, velocity, collision radius, damage, and type (jelly/eel/ice) |
| `Pickup` | `active`, `x`, `y`, `vx`, `vy`, `kind`, `phase` | A collectible item floating underwater |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | A visual particle for burst effects |
| `Game` | `fish`, `hazards`, `pickups`, `particles`, `state`, `hook_x`, `hook_y`, `line_hp`, `bait`, `score`, `lives`, `wave`, `combo`, `hint_left`, etc. | Master game state containing all entity arrays, hook position/velocity, resource bars, scoring, and UI state |

#### Constructor Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Fish::new` | `() -> Fish` | Creates an inactive fish with default values |
| `Hazard::new` | `() -> Hazard` | Creates an inactive hazard with default values |
| `Pickup::new` | `() -> Pickup` | Creates an inactive pickup |
| `Particle::new` | `() -> Particle` | Creates an inactive particle |
| `Game::new` | `() -> Game` | Creates a new game in Title state with pre-allocated entity pools (180 fish, 120 hazards, 80 pickups, 1500 particles) |

#### Layout and Geometry Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `catch_zone_x` | `() -> Int` | X coordinate of the catch zone rectangle |
| `catch_zone_y` | `() -> Int` | Y coordinate of the catch zone rectangle |
| `catch_zone_w` | `() -> Int` | Width of the catch zone (240) |
| `catch_zone_h` | `() -> Int` | Height of the catch zone (76) |
| `start_button_rect` | `() -> (Int, Int, Int, Int)` | Title screen start button rectangle |
| `retry_button_rect` | `() -> (Int, Int, Int, Int)` | Result screen retry button rectangle |
| `btn_left` .. `btn_repair` | `() -> (Int, Int, Int, Int)` | Touch control button rectangles for left, right, up, down, hook, boost, hint, restart, and repair |

#### Utility Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `mini` | `(Int, Int) -> Int` | Returns the smaller of two integers |
| `maxi` | `(Int, Int) -> Int` | Returns the larger of two integers |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between lo and hi |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between lo and hi |
| `minf` | `(Float, Float) -> Float` | Returns the smaller of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns the larger of two floats |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `sinf` | `(Float) -> Float` | Computes sine via core math library |
| `cosf` | `(Float) -> Float` | Computes cosine via core math library |
| `randf` | `(Float, Float) -> Float` | Generates a random float in [lo, hi] range |
| `world_left` | `() -> Float` | Left edge of the water world as float |
| `world_right` | `() -> Float` | Right edge of the water world as float |
| `topf` | `() -> Float` | Top of the water area as float |
| `bottomf` | `() -> Float` | Bottom of the water area as float |
| `hole_xf` | `() -> Float` | Ice hole X position as float |
| `hole_yf` | `() -> Float` | Ice hole Y position as float |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two 2D points |
| `in_catch_zone` | `(Float, Float) -> Bool` | Tests if a point is inside the catch zone rectangle |
| `set_msg` | `(Game, String, Float) -> Unit` | Sets the on-screen message and its time-to-live |
| `point_in_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a float point is inside an integer rectangle |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Tests if mouse or any touch point is inside a rectangle |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | 1720 | Window width |
| `screen_h` | `Int` | 980 | Window height |
| `target_fps` | `Int` | 120 | Target frame rate |
| `fish_trout` | `Int` | 0 | Trout fish type |
| `fish_salmon` | `Int` | 1 | Salmon fish type |
| `fish_gold` | `Int` | 2 | Golden fish type |
| `hazard_jelly` | `Int` | 0 | Jellyfish hazard type |
| `hazard_eel` | `Int` | 1 | Eel hazard type |
| `hazard_ice` | `Int` | 2 | Ice chunk hazard type |
| `max_fish` | `Int` | 180 | Fish pool size |
| `max_hazards` | `Int` | 120 | Hazard pool size |
| `max_pickups` | `Int` | 80 | Pickup pool size |
| `max_particles` | `Int` | 1500 | Particle pool size |
| `world_x0`, `world_y0`, `world_w`, `world_h` | `Int` | 24, 20, 1120, 940 | World area bounds |
| `panel_x0`, `panel_w` | `Int` | computed | Side panel position and width |
| `water_top`, `water_bottom` | `Int` | computed | Vertical bounds of the water area |
| `hole_x`, `hole_y` | `Int` | computed | Ice hole position |
| `hook_r` | `Float` | 13.0 | Hook collision radius |
| `run_time_goal` | `Float` | 200.0 | Time limit in seconds |
| `score_goal` | `Int` | 1600 | Score needed to win |
| `max_line_len` | `Float` | 760.0 | Maximum fishing line length |
| `min_line_len` | `Float` | 60.0 | Minimum fishing line length |

### Package `ice_fishing_blitz_2026/internal/game`

> Game logic, input handling, and update systems.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main update entry point: polls mouse/touch state, then dispatches to title, play, or result input and update routines |

### Package `ice_fishing_blitz_2026/internal/render`

> Rendering and drawing routines.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main rendering entry point: draws layered background, underwater world with fish/hazards/pickups/particles/hook, side info panel with stats and bars, touch controls, messages, and state overlays (title/result) |

## Architecture

### Package Structure

```
ice_fishing_blitz_2026/
├── main.mbt              — Entry point: window init, audio init, game loop
├── moon.pkg              — Package config, imports
└── internal/
    ├── types/
    │   ├── types.mbt     — Core structs (Game, Fish, Hazard, Pickup, Particle) and enums (GameState, PickupKind)
    │   ├── constants.mbt — Screen dimensions, entity pool sizes, layout rects, gameplay tuning
    │   └── utils.mbt     — Math helpers, coordinate conversions, collision tests, message setter
    ├── game/
    │   ├── logic.mbt     — Entity spawning, hook physics, fish/hazard/pickup updates, scoring, win/lose logic
    │   ├── input.mbt     — Keyboard and touch input handling for title, play, and result states
    │   └── moon.pkg      — Package config
    └── render/
        ├── render.mbt    — Drawing: background, underwater world, entities, HUD panel, touch buttons, overlays
        └── moon.pkg      — Package config
```

The types package is data-only (no raylib rendering calls) except for `randf` and `pointer_on_rect` which use raylib for random values and touch positions. The game package handles all state mutation. The render package is read-only with respect to game state.

### Data Flow

1. `main.mbt` calls `update_game(game, dt)` which first captures mouse/touch state into `game.mouse_x`, `game.mouse_y`, `game.mouse_hold`, `game.touch_count`.
2. Based on `game.state`, input is routed to `update_title_input`, `update_play_input`, or `update_result_input`.
3. `update_play` advances all timers, spawns entities at wave-dependent intervals, calls `update_hook` for physics, `update_fish` for fish AI and hooking, `update_hazards` for hazard movement and collision, and `update_pickups` for pickup collection.
4. `draw_frame` renders the layered scene with screen shake offset, then draws the side panel and state overlays.

### Key Design Patterns

- **Object pool pattern**: Fish, hazards, pickups, and particles are pre-allocated in fixed-size arrays with `active` flags, avoiding runtime allocation.
- **State machine**: `GameState` enum (`Title`, `Play`, `Result`) drives both input routing and overlay rendering via `match` expressions.
- **Wave-based difficulty scaling**: Wave number (1-10) is derived from elapsed time and affects spawn intervals, hazard speed, and bait drain rate.
- **Touch+keyboard dual input**: The game supports both keyboard controls and on-screen touch buttons, with `pointer_on_rect` checking mouse position and all active touch points.
- **Physics with sway**: Hook movement combines player input acceleration, drag deceleration, and sinusoidal sway forces for underwater feel.
- **Hint system**: `use_hint` intelligently selects the best target (hooked fish -> bait pickup -> highest value fish) and displays a pulsing indicator.

## Improvement & Refinement Plan

1. **Use enums for fish and hazard kinds**: Currently `fish_trout`, `fish_salmon`, `fish_gold` and `hazard_jelly`, `hazard_eel`, `hazard_ice` are `Int` constants despite `PickupKind` already being a proper enum. Converting these to enums would enable exhaustive matching and eliminate magic number comparisons throughout `update_fish`, `update_hazards`, and `spawn_fish`.

2. **Extract hook physics into a dedicated module**: `update_hook` contains sway calculations, velocity damping, and line length clamping that could live in a separate `hook.mbt` file, making `logic.mbt` easier to navigate.

3. **Implement a proper sqrt for distance checks**: The `dist2` function computes squared distance and comparisons use `rr * rr`, which works but could benefit from a `dist` function for clarity in `use_hint` where Manhattan-like distance is used differently.

4. **Add sound effects using the initialized audio device**: The `main.mbt` initializes and closes the audio device but no sounds are played anywhere. Adding catch, collision, pickup, and ambient water sounds would significantly enhance the experience.

5. **Reduce entity pool sizes based on actual usage**: `max_fish` is 180 and `max_hazards` is 120, but spawn rates suggest far fewer are active simultaneously. Profiling active counts would allow right-sizing the pools.

6. **Add visual depth cue for hook depth**: Currently all entities are drawn at the same visual layer. A depth-based alpha or size scaling based on `hook_y` position would make the underwater environment feel more three-dimensional.

7. **Separate bait drain rate into a named constant**: The drain values `2.5 + wave * 0.10` and `1.0 + wave * 0.07` are inline in `update_play`. Extracting these as named constants in `constants.mbt` would make difficulty tuning easier.
