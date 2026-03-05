# Quantum Skater 2026

An endless runner set in a neon-lit quantum corridor, where a lone skater hurtles through a five-lane track dodging walls, jumping over barriers, and phasing between alpha and beta dimensions to pass through phase-locked gates. The game blends classic lane-runner mechanics with a quantum phase-shifting system that forces the player to manage phase energy as a secondary resource alongside health.

The core gameplay loop centers on survival and scoring: obstacles scroll toward the player at increasing speed, and the player must switch lanes, jump, and toggle quantum phase to avoid damage. Orbs scattered along the track build a combo multiplier that decays over time, rewarding aggressive collection. Each stage has a distance goal; clearing a stage grants a health bonus and a score bonus before the next corridor begins at higher speed. Boost pads temporarily increase scroll speed for extra points, while jump bars punish players who fail to leap over them.

Technically, the game uses a pseudo-3D perspective projection system that maps world-space lane coordinates and depth values onto screen positions with a `proj_scale` function, creating a convincing sense of depth without a full 3D pipeline. Object pools for track objects, particles, and trails keep allocation-free during gameplay, and a full touch/mouse input layer makes the game playable on mobile devices.

## Build and Run

```bash
moon build --target native quantum_skater_2026/
./_build/native/debug/build/quantum_skater_2026/quantum_skater_2026.exe
```

## Controls

- **A / Left Arrow**: Move one lane left
- **D / Right Arrow**: Move one lane right
- **W / Up Arrow / Space**: Jump (hold for higher jump)
- **E / K / Left Shift**: Toggle quantum phase (alpha/beta)
- **R**: Restart run
- **Escape**: Return to title screen (pause)
- **Space / Enter**: Start game from title screen
- **Mouse Click / Touch**: Start game from title or game-over screen
- **Touch Buttons (mobile)**: On-screen left, right, jump, and phase buttons appear during play

## How to Play

From the title screen, press Space, Enter, click, or tap to begin a run. You start in lane 3 (center) of a five-lane track in alpha phase with 100 health and 100 phase energy.

Obstacles approach along the track: **walls** (20 damage), **phase gates** (17 damage if you are in the wrong phase), and **jump bars** (14 damage if you are grounded). Switch lanes to avoid walls, jump over jump bars, and toggle your quantum phase to pass through phase-locked gates -- alpha gates are solid in alpha phase and transparent in beta phase, and vice versa.

Collect **orbs** to build your combo counter. Each orb collected within the 3.8-second combo decay window increases the multiplier (1 + combo x 0.08). Distance-based points also scale with the combo multiplier. **Boost pads** temporarily raise your speed to 1.78x normal for 1.4 seconds and award 280 bonus points.

Phase energy drains at 21 units/second while in beta phase and recovers at 18 units/second in alpha phase. Switching costs 8 energy and has a 0.24-second cooldown. If energy hits zero, you revert to alpha automatically.

Each stage requires covering a set distance (starting at 5200 units, growing by 1800 per stage). Clearing a stage awards a bonus based on combo count and remaining health, restores 15 health (capped at 100), and advances to the next stage with speed increased by 70 units/second. If health reaches zero, the run ends and you see your final score alongside your best score.

## Public API Reference

### Package `quantum_skater_2026`

> Main entry point.

The main package contains only the `main` function (not pub), which initializes the window at 1366x768 with 4x MSAA, creates a `Game` instance, and runs the game loop. Each frame reads mouse/touch state, calls `update_game` with a delta time capped at 0.033s, then calls `draw_frame`.

### Package `quantum_skater_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `TrackObj` | `active`, `kind`, `lane`, `z`, `y_off`, `w`, `h`, `phase_only`, `spin`, `hit_lock` | A track obstacle or collectible in the object pool |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | A visual particle effect element |
| `Trail` | `active`, `x`, `y`, `w`, `h`, `life`, `beta` | A trail segment left behind the player |
| `Player` | `lane`, `lane_f`, `y`, `vy`, `jump_buf`, `grounded`, `invuln_t`, `hurt_t`, `anim_t` | Player state including position, physics, and timers |
| `Game` | `objs`, `particles`, `trails`, `hero`, `state`, `stage`, `speed`, `score`, `health`, `phase_energy`, `phase_beta`, `combo`, ... | Main game state container with all pools, player, and input state |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1366` | Window width in pixels |
| `screen_h` | `Int` | `768` | Window height in pixels |
| `target_fps` | `Int` | `120` | Target frame rate |
| `state_title` | `Int` | `0` | Title screen state |
| `state_play` | `Int` | `1` | Active gameplay state |
| `state_stage_clear` | `Int` | `2` | Stage clear transition state |
| `state_game_over` | `Int` | `3` | Game over state |
| `obj_wall` | `Int` | `0` | Wall obstacle type |
| `obj_orb` | `Int` | `1` | Collectible orb type |
| `obj_gate_alpha` | `Int` | `2` | Alpha phase gate type |
| `obj_gate_beta` | `Int` | `3` | Beta phase gate type |
| `obj_boost` | `Int` | `4` | Speed boost pad type |
| `obj_jump_bar` | `Int` | `5` | Jump bar obstacle type |
| `lane_count` | `Int` | `5` | Number of lanes on the track |
| `max_objs` | `Int` | `360` | Object pool capacity |
| `max_particles` | `Int` | `460` | Particle pool capacity |
| `max_trails` | `Int` | `180` | Trail pool capacity |
| `base_speed` | `Float` | `680.0` | Starting scroll speed (units/s) |
| `speed_stage_gain` | `Float` | `70.0` | Speed increase per stage |
| `player_jump_speed` | `Float` | `860.0` | Initial upward velocity on jump |
| `player_gravity` | `Float` | `2550.0` | Gravity acceleration |
| `stage_base_distance` | `Float` | `5200.0` | Distance goal for stage 1 |
| `stage_distance_growth` | `Float` | `1800.0` | Additional distance per stage |
| `phase_drain_per_sec` | `Float` | `21.0` | Phase energy drain rate in beta |
| `phase_recover_per_sec` | `Float` | `18.0` | Phase energy recovery rate in alpha |
| `phase_switch_cd` | `Float` | `0.24` | Cooldown between phase toggles |
| `invuln_time` | `Float` | `0.65` | Invulnerability duration after taking damage |
| `combo_decay_time` | `Float` | `3.8` | Time before combo resets to zero |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `TrackObj::new` | `() -> TrackObj` | Creates a default inactive track object |
| `Particle::new` | `() -> Particle` | Creates a default inactive particle |
| `Trail::new` | `() -> Trail` | Creates a default inactive trail segment |
| `Player::new` | `() -> Player` | Creates a player starting in lane 2, grounded |
| `Game::new` | `() -> Game` | Creates a new game with pre-allocated object pools |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between lo and hi |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between lo and hi |
| `maxf` | `(Float, Float) -> Float` | Returns the larger of two floats |
| `minf` | `(Float, Float) -> Float` | Returns the smaller of two floats |
| `lerpf` | `(Float, Float, Float) -> Float` | Linear interpolation between two floats |
| `approachf` | `(Float, Float, Float) -> Float` | Moves a value toward a target by a fixed step |
| `sinf` | `(Float) -> Float` | Sine function wrapping `@math.sin` |
| `cosf` | `(Float) -> Float` | Cosine function wrapping `@math.cos` |
| `randf` | `(Float, Float) -> Float` | Random float in [lo, hi] via raylib RNG |
| `randi` | `(Int, Int) -> Int` | Random integer in [lo, hi] via raylib RNG |
| `chance` | `(Int) -> Bool` | Returns true with p% probability |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two 2D points |
| `proj_scale` | `(Float) -> Float` | Perspective scale factor: `1 / (1 + z * 0.0042)` |
| `lane_world_x` | `(Int) -> Float` | Converts a lane index to world-space X coordinate |
| `lane_screen_x` | `(Float, Float) -> Float` | Projects a world-space lane X to screen X at depth z |
| `track_y` | `(Float) -> Float` | Maps depth z to screen Y coordinate for the track surface |
| `color_bg_top` | `() -> Color` | Dark blue background gradient top color |
| `color_bg_bottom` | `() -> Color` | Dark blue background gradient bottom color |
| `color_lane_alpha` | `() -> Color` | Cyan color for alpha phase visuals |
| `color_lane_beta` | `() -> Color` | Pink color for beta phase visuals |
| `color_phase_bar` | `() -> Color` | Light cyan color for the phase energy bar |
| `color_hp_bar` | `() -> Color` | Pink-red color for the health bar |
| `button_left_rect` | `() -> (Float, Float, Float, Float)` | Touch button rect for left movement |
| `button_right_rect` | `() -> (Float, Float, Float, Float)` | Touch button rect for right movement |
| `button_jump_rect` | `() -> (Float, Float, Float, Float)` | Touch button rect for jump |
| `button_phase_rect` | `() -> (Float, Float, Float, Float)` | Touch button rect for phase toggle |

### Package `quantum_skater_2026/internal/game`

> Game logic, input handling, spawning, and state transitions.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `init_game` | `(Game) -> Unit` | Initializes the game to the title scene |
| `update_game` | `(Game, Float) -> Unit` | Main update entry point: dispatches input and logic by state |

All other functions in this package are private:

| Function | Description |
|----------|-------------|
| `clear_objs` | Deactivates all objects in the pool |
| `clear_particles` | Deactivates all particles in the pool |
| `clear_trails` | Deactivates all trails in the pool |
| `reset_hero` | Resets the player to lane 2, grounded, no timers |
| `alloc_obj_slot` | Finds an inactive object slot or evicts the nearest |
| `alloc_particle_slot` | Finds an inactive particle slot or evicts the shortest-lived |
| `alloc_trail_slot` | Finds an inactive trail slot or evicts the shortest-lived |
| `spawn_obj` | Activates an object with given kind, lane, z-depth, and dimensions |
| `spawn_particle` | Activates a particle with position, velocity, lifetime, and kind |
| `spawn_trail` | Creates a trail segment at the player's current position |
| `burst` | Spawns multiple particles in a radial pattern for visual effects |
| `spawn_orb_strip` | Places a line of orbs along a lane with sinusoidal vertical offset |
| `spawn_wave` | Randomly generates one of six wave patterns (wall rows, gate pairs, boost lanes, jump bar sequences, mixed scatter) |
| `ensure_spawns` | Continuously spawns waves ahead of the camera until depth coverage is met |
| `set_stage` | Updates stage number, distance goal, and base speed |
| `start_run` | Resets all state and begins a new run from stage 1 |
| `init_title_scene` | Sets up the title screen with slow demo scrolling |
| `handle_lane_input` | Moves the player left or right based on input_move |
| `update_player` | Handles lane interpolation, jump physics with variable height, trail spawning, and invulnerability timers |
| `update_phase` | Manages phase toggle, energy drain/recovery, and auto-revert |
| `update_objects` | Scrolls objects, checks collisions, applies damage or awards score, handles boost decay |
| `update_particles` | Advances particle positions and removes expired particles and trails |
| `update_score` | Decays combo timer, adds distance-based score scaled by combo multiplier |
| `update_play` | Orchestrates all play-state systems and checks stage completion |
| `update_stage_clear` | Counts down transition timer, then advances to next stage |
| `update_game_over` | Waits for restart input after game over |
| `update_title_scene` | Scrolls demo objects and waits for start input |
| `combo_mul` | Calculates combo score multiplier: `1.0 + combo * 0.08` |
| `apply_damage` | Reduces health, triggers invulnerability, resets combo, spawns hurt particles |
| `mark_hit_obj` | Sets hit_lock timer on an object to prevent repeated hits |
| `obj_affects_phase` | Checks whether an object is solid in the current phase |
| `clear_input` | Resets all input flags to their default state |
| `update_pointer` | Updates pointer position from mouse or first touch point |
| `update_title_input` | Reads start inputs on the title screen |
| `update_play_input` | Reads lane, jump, phase, restart, and pause inputs during gameplay |
| `update_stage_clear_input` | Reads restart input during stage clear transition |
| `update_result_input` | Reads retry input on the game over screen |

### Package `quantum_skater_2026/internal/render`

> Rendering, visual effects, and UI drawing.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main render entry point: clears screen, draws world, HUD, overlays, and flash effects |

All other functions in this package are private:

| Function | Description |
|----------|-------------|
| `draw_center_text` | Draws horizontally centered text at a given Y position |
| `shake_offset` | Computes random screen shake displacement based on shake timer |
| `world_to_screen` | Projects world coordinates (lane_x, y_off, z) to screen (x, y, scale) |
| `draw_backdrop` | Renders gradient sky, animated stars, and parallax city silhouettes |
| `draw_track_grid` | Draws perspective lane lines and cross-track grid lines with pulsing alpha |
| `obj_color` | Returns the display color for an object based on its kind and current phase |
| `draw_obj` | Renders a single track object (orb, wall, gate, boost, jump bar) with perspective scaling |
| `draw_trails` | Renders fading trail rectangles behind the player |
| `draw_particles` | Renders all active particles as colored circles |
| `draw_player` | Draws the skater body, head, phase-colored boots, and invulnerability blink |
| `draw_touch_controls` | Draws on-screen touch buttons with highlight on press |
| `draw_hud` | Draws score, stage info, combo, health bar, phase energy bar, track progress meter, restart button, and hint text |
| `draw_title_overlay` | Renders the title screen with controls list and blinking start prompt |
| `draw_stage_clear_overlay` | Shows stage clear banner with bonus score |
| `draw_game_over_overlay` | Shows game over screen with final and best scores and retry prompt |
| `draw_world` | Orchestrates drawing backdrop, grid, objects, trails, particles, and player |
| `ui_text` | Returns white or muted text color based on button active state |
| `point_in_rect` | Tests if a point is inside a rectangle |
| `pointer_on_rect` | Tests if mouse or any touch point is inside a rectangle |

## Architecture

### Package Structure

```
quantum_skater_2026/
├── main.mbt              -- Entry point: window init, input polling, game loop
├── moon.pkg              -- Package config, imports types/game/render
└── internal/
    ├── types/
    │   ├── types.mbt     -- Core structs: TrackObj, Particle, Trail, Player, Game
    │   ├── constants.mbt -- All tuning constants (speeds, damage, pool sizes, etc.)
    │   ├── utils.mbt     -- Math utilities, projection, lane mapping, color helpers
    │   └── moon.pkg
    ├── game/
    │   ├── logic.mbt     -- Spawning, physics, collision, scoring, state transitions
    │   ├── input.mbt     -- Keyboard/mouse/touch input handling per game state
    │   └── moon.pkg
    └── render/
        ├── render.mbt    -- All drawing: world, objects, player, HUD, overlays, touch UI
        └── moon.pkg
```

The types package is a pure data layer with no game logic -- it defines all structs, constants, and stateless utility functions. The game package depends on types and implements all mutation: input processing, physics simulation, collision detection, spawning, and state transitions. The render package depends on types and is strictly read-only, drawing the game state each frame without modifying it. The main package wires these three together in a straightforward init-update-draw loop.

### Data Flow

1. **Input Collection**: `main.mbt` reads raw mouse/touch state each frame and stores it on the `Game` struct. Then `update_game` dispatches to a state-specific input handler (`update_title_input`, `update_play_input`, `update_stage_clear_input`, or `update_result_input`) that converts raw input into semantic flags (`input_move`, `input_jump_press`, `input_phase_press`, etc.).

2. **Logic Update**: `update_game` then dispatches to the state-specific logic function. During play, `update_play` calls `update_player` (movement and jump physics), `update_phase` (energy management), `update_objects` (scrolling, collision, damage), `update_particles` (visual effects decay), and `update_score` (combo decay, distance scoring). Stage completion and game-over transitions are checked at the end of `update_play`.

3. **Rendering**: `draw_frame` reads the `Game` struct without modification. It computes camera shake, draws the world (backdrop, grid, objects, trails, particles, player), overlays the HUD during play, draws touch controls if touch mode is active, and renders state-specific overlays (title, stage clear, game over). A full-screen flash effect fades out after damage or stage clear events.

### Key Design Patterns

- **Object Pool Pattern**: `TrackObj`, `Particle`, and `Trail` arrays are pre-allocated at fixed sizes (360, 460, 180) with `active` boolean flags. Allocation functions (`alloc_obj_slot`, `alloc_particle_slot`, `alloc_trail_slot`) scan for inactive slots and fall back to evicting the least-useful entry (nearest object, shortest-lived particle/trail).

- **Integer State Machine**: Game state is encoded as integer constants (`state_title=0`, `state_play=1`, `state_stage_clear=2`, `state_game_over=3`) rather than an enum. Both `update_game` and `draw_frame` dispatch on these values with if-else chains.

- **Pseudo-3D Perspective Projection**: The `proj_scale(z)` function maps depth to a scale factor, while `lane_screen_x` and `track_y` convert world coordinates to screen positions. This creates a convincing 3D tunnel effect using only 2D drawing primitives.

- **Input Abstraction Layer**: Raw keyboard, mouse, and touch inputs are unified into semantic flags (`input_move`, `input_jump_press`, `input_phase_press`, etc.) by state-specific input handlers, allowing game logic to be input-source agnostic. Touch button edge detection uses `_prev` flags to distinguish press from hold.

- **Variable-Height Jump**: Jump physics use a buffer (`jump_buf`) for input leniency and apply extra gravity when the jump key is released early, giving the player fine-grained jump height control.

- **Delta-Time Movement with Frame Cap**: The main loop caps `dt` at 0.033s (about 30 FPS minimum) to prevent physics instabilities on frame spikes, while targeting 120 FPS for smooth animation.

## Improvement & Refinement Plan

1. **Replace Integer Constants with Enums**: The game state (`state_title`, `state_play`, etc.) and object kinds (`obj_wall`, `obj_orb`, etc.) are plain `Int` constants in `constants.mbt`. Replacing them with proper MoonBit enums would provide exhaustiveness checking in match expressions and prevent invalid state values.

2. **Extract Wave Pattern Definitions**: The `spawn_wave` function in `logic.mbt` contains six hardcoded wave patterns selected by random percentage ranges. Extracting these into a data-driven wave definition table would make it easier to add new patterns and tune spawn probabilities independently.

3. **Add Sound Effects**: The `main.mbt` initializes the audio device (`init_audio_device`) but no sounds are ever played. Adding audio feedback for orb collection, phase shifts, damage hits, and stage clears would significantly improve game feel.

4. **Reduce Duplicate Hit-Test Code**: The `pointer_on_rect` and `point_in_rect` functions appear in both `input.mbt` and `render.mbt`. Moving these to `utils.mbt` in the types package would eliminate duplication and ensure consistent behavior.

5. **Implement Score Persistence**: The `best_score` field in `Game` resets when the application restarts. Adding file-based persistence would let players track their all-time best score across sessions.

6. **Add Difficulty Curve Variety**: Currently difficulty scales linearly via `speed_stage_gain` (70 units/s per stage) and `stage_distance_growth` (1800 units per stage). Introducing new obstacle types, faster spawn rates, or narrower safe lanes at higher stages would create more gameplay variety.

7. **Improve Phase Gate Visual Distinction**: When a gate is non-solid (wrong phase), it renders as a muted gray (`Color::new(120, 140, 170, 170)`) which can be hard to distinguish from solid gates at high speed. Adding a transparency shimmer or wireframe effect would make the safe-to-pass state more immediately readable.

8. **Optimize Object Iteration**: Both `update_objects` and `draw_obj` iterate over all 360 pool slots even when most are inactive. Maintaining a count of active objects or using a compact active list would reduce unnecessary iteration, especially on lower-powered devices.
