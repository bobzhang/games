# Ancient Temple Trap Run 2026

A top-down action-puzzle game where the player navigates an ancient temple filled with timed traps, lava hazards, pressure plates, and sealed doors across three handcrafted stages. The goal is to collect all relics in each chamber to unseal the exit gate and advance to the next stage, using precise movement and a stamina-based dash to survive.

Each stage presents a unique layout of spike traps, dart launchers, and lava pits that must be avoided while collecting scattered relics. Pressure plates temporarily open massive stone doors that block passage between sections of the chamber, requiring the player to step on a plate and then dash through before the hold timer expires. The dash mechanic drains stamina at 44 units per second but doubles movement speed from 260 to 520 px/s, while stamina recovers at 28 units per second when not dashing. Collecting a relic restores 12 stamina, rewarding efficient routing.

The three stages -- "Sunken Antechamber," "Obsidian Gauntlet," and "Crown Vault" -- progressively increase in complexity, adding more relics (3, 4, and 5 respectively), additional traps and hazards, and more doors requiring plate activation. Completing all three stages wins the game. Any contact with a hot trap or lava hazard instantly fails the current stage, requiring a retry.

## Build and Run

```bash
moon build --target native raylib_ancient_temple_trap_run_2026/
./_build/native/debug/build/raylib_ancient_temple_trap_run_2026/raylib_ancient_temple_trap_run_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move the player character
- **Shift / K**: Hold to dash (doubles speed, drains stamina)
- **R**: Restart current stage
- **Space / Enter**: Start game from title screen; advance to next stage on clear screen
- **Escape / T**: Return to title screen from failed/victory screens
- **Touch D-pad**: On-screen directional buttons (bottom-left corner)
- **Touch DASH**: On-screen dash button (bottom-right area of HUD panel)
- **Mouse click**: Click on-screen buttons for Start, Next, Retry, Title

## How to Play

From the title screen, press Space/Enter or click "Start Expedition" to begin Stage 1. Your character spawns at a designated start position within the temple chamber. Move through the chamber to collect all golden relics (shown as glowing circles). Once all relics are collected, the exit gate changes from red "SEALED" to green "EXIT" and you can pass through it.

**Traps** cycle between safe and dangerous ("HOT") states on fixed timers. Each trap has a cycle period, a hot window duration, and a phase offset. Spike traps and dart launchers appear as rectangles that flash red and display "HOT" when active. Contact with a hot trap instantly fails the stage with a descriptive message like "Spikes burst from the floor."

**Hazards** (lava pits) are always dangerous. Stepping into one immediately fails the stage. They appear as dark red rectangles with orange borders.

**Pressure plates** are green rectangles labeled "PLATE." Standing on a plate activates it, which opens its linked door. Doors have a hold timer (0.56-0.66 seconds) that starts counting down the moment you step off the plate. You must dash through the door before the timer expires. Doors will not close while the player is inside the doorway, preventing instant-fail from slow passage.

**Stamina** is shown as a bar in the HUD panel. Dashing requires at least 8 stamina to initiate and drains at 44/s. When not dashing, stamina recovers at 28/s. Each collected relic grants +12 stamina.

**Stage progression**: Clear all three stages to see the "Temple Escaped" victory screen. From any failed state, you can retry the current stage or return to the title. From stage clear, advance to the next stage or retry for a faster time.

## Public API Reference

### Package `raylib_ancient_temple_trap_run_2026/internal/types`

> Core types, constants, and utility functions shared across the game.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1500` | Window width in pixels |
| `screen_h` | `Int` | `900` | Window height in pixels |
| `target_fps` | `Int` | `120` | Target frame rate |
| `stage_total` | `Int` | `3` | Total number of stages |
| `world_x` | `Float` | `40.0` | World area left edge |
| `world_y` | `Float` | `70.0` | World area top edge |
| `world_w` | `Float` | `1020.0` | World area width |
| `world_h` | `Float` | `790.0` | World area height |
| `player_w` | `Float` | `34.0` | Player hitbox width |
| `player_h` | `Float` | `34.0` | Player hitbox height |
| `player_speed_walk` | `Float` | `260.0` | Walking speed in px/s |
| `player_speed_dash` | `Float` | `520.0` | Dashing speed in px/s |
| `stamina_max` | `Float` | `100.0` | Maximum stamina value |
| `stamina_drain_per_s` | `Float` | `44.0` | Stamina drain rate while dashing |
| `stamina_recover_per_s` | `Float` | `28.0` | Stamina recovery rate when not dashing |
| `dash_min_stamina` | `Float` | `8.0` | Minimum stamina required to initiate dash |
| `relic_stamina_bonus` | `Float` | `12.0` | Stamina restored per relic collected |
| `trap_kind_spike` | `Int` | `0` | Spike trap kind identifier |
| `trap_kind_dart` | `Int` | `1` | Dart trap kind identifier |
| `hazard_kind_lava` | `Int` | `0` | Lava hazard kind identifier |

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `StageClear`, `Failed`, `Victory` | State machine for game flow; derives `Eq` |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Relic` | `active : Bool`, `x : Float`, `y : Float`, `r : Float` | A collectible relic with position and radius |
| `Trap` | `x`, `y`, `w`, `h`, `cycle`, `hot_window`, `phase`, `kind : Int`, `label : String`, `timer : Float` | A timed trap that cycles between safe and dangerous states |
| `Hazard` | `x`, `y`, `w`, `h`, `kind : Int`, `label : String` | A static hazard zone (lava) that instantly fails the stage on contact |
| `Plate` | `x`, `y`, `w`, `h`, `pressed : Bool` | A pressure plate that opens a linked door when the player stands on it |
| `Door` | `x`, `y`, `w`, `h`, `plate_index : Int`, `hold_time : Float`, `timer : Float`, `open : Bool` | A door linked to a plate that stays open for `hold_time` seconds after plate release |
| `StageLayout` | `start_x`, `start_y`, `exit_x/y/w/h`, `relics`, `traps`, `hazards`, `plates`, `doors` | Complete layout specification for a stage including all entities and spawn/exit positions |
| `Player` | `x`, `y`, `w`, `h`, `stamina : Float`, `dash_on : Bool` | The player character with position, size, stamina resource, and dash state |
| `Game` | `player`, `relics`, `traps`, `hazards`, `plates`, `doors`, `state`, `stage_index`, `stage_count`, `required_relics`, `collected_relics`, `exit_x/y/w/h`, `stage_time`, `fail_reason`, `banner_text/t`, `input_*`, `touch_*`, `mouse_*` | Top-level game state holding all entities, stage progress, input state, and UI state |

All structs use `pub(all)` visibility for cross-package access.

#### Factory Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Player::new` | `() -> Player` | Creates a player at default position with full stamina |
| `Game::new` | `() -> Game` | Creates a fresh game in `Title` state with empty entity arrays |
| `make_relic` | `(Float, Float) -> Relic` | Creates an active relic at (x, y) with radius 13 |
| `make_trap` | `(Float, Float, Float, Float, Float, Float, Float, Int, String) -> Trap` | Creates a trap with position, size, cycle timing, kind, and label |
| `make_hazard` | `(Float, Float, Float, Float, Int, String) -> Hazard` | Creates a hazard with position, size, kind, and label |
| `make_plate` | `(Float, Float, Float, Float) -> Plate` | Creates an unpressed plate at the given position and size |
| `make_door` | `(Float, Float, Float, Float, Int, Float) -> Door` | Creates a closed door linked to a plate index with a hold time |

#### Utility Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `minf` | `(Float, Float) -> Float` | Returns the smaller of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns the larger of two floats |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to [lo, hi] |
| `absf` | `(Float) -> Float` | Absolute value of a float |
| `sq` | `(Float) -> Float` | Squares a float value |
| `rects_overlap` | `(Float, Float, Float, Float, Float, Float, Float, Float) -> Bool` | AABB overlap test between two rectangles |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside an integer-coordinate rectangle |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Tests if mouse or any touch point is inside a rectangle |
| `mouse_click_on_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if left mouse button was just pressed inside a rectangle |
| `player_rect_at` | `(Game, Float, Float) -> (Float, Float, Float, Float)` | Returns the player's bounding rectangle centered at a given position |
| `player_hits_rect` | `(Game, Float, Float, Float, Float) -> Bool` | Tests if the player's current position overlaps a given rectangle |
| `trap_is_hot` | `(Trap) -> Bool` | Returns true if the trap is currently in its dangerous phase |
| `exit_unlocked` | `(Game) -> Bool` | Returns true if all required relics have been collected |
| `stage_name` | `(Int) -> String` | Returns the display name for a stage index (0-2) |
| `set_banner` | `(Game, String, Float) -> Unit` | Sets the banner text and its display duration |

#### UI Layout Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `panel_rect` | `(Int, Int, Int, Int)` | HUD panel bounds: (1080, 20, 390, 860) |
| `title_start_rect` | `(Int, Int, Int, Int)` | Start button bounds on title screen |
| `panel_next_rect` | `(Int, Int, Int, Int)` | "Next" button bounds on overlay screens |
| `panel_restart_rect` | `(Int, Int, Int, Int)` | "Restart/Retry" button bounds on overlay screens |
| `play_restart_rect` | `(Int, Int, Int, Int)` | Restart button bounds on the in-game HUD panel |
| `touch_left_rect` | `(Int, Int, Int, Int)` | Touch D-pad left button bounds |
| `touch_right_rect` | `(Int, Int, Int, Int)` | Touch D-pad right button bounds |
| `touch_up_rect` | `(Int, Int, Int, Int)` | Touch D-pad up button bounds |
| `touch_down_rect` | `(Int, Int, Int, Int)` | Touch D-pad down button bounds |
| `touch_dash_rect` | `(Int, Int, Int, Int)` | Touch dash button bounds |

### Package `raylib_ancient_temple_trap_run_2026/internal/game`

> Game logic, stage layouts, input handling, and state updates.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main per-frame update: processes input for the current state, decays banner timer, then dispatches to the state-specific update function |
| `init_title_scene` | `(Game) -> Unit` | Resets game to the title screen state with default values |

### Package `raylib_ancient_temple_trap_run_2026/internal/render`

> All drawing and rendering functions.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Renders one complete frame: background, world (hazards, traps, plates, relics, doors, exit, player), HUD panel, touch controls (if in touch mode), banner, and state-specific overlays |

### Package `raylib_ancient_temple_trap_run_2026` (root)

> Entry point that wires together types, game logic, and rendering.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Creates a 1500x900 window at 120 FPS with MSAA 4x, initializes the game, and runs the main loop: reads input, calls `update_game`, draws via `draw_frame` |

## Architecture

### Package Structure

```
raylib_ancient_temple_trap_run_2026/
├── main.mbt                        — Entry point with game loop (~28 lines)
├── moon.pkg                        — Root package config (imports types, game, render, raylib)
└── internal/
    ├── types/
    │   ├── types.mbt               — GameState enum, all entity structs, factory functions (~224 lines)
    │   ├── constants.mbt           — Screen dimensions, physics constants, UI rect functions (~112 lines)
    │   ├── utils.mbt               — Math helpers, collision detection, input helpers (~165 lines)
    │   └── moon.pkg                — Types package config (imports math, raylib)
    ├── game/
    │   ├── logic.mbt               — Stage layouts, state update functions, movement, collision (~568 lines)
    │   ├── input.mbt               — Per-state input handlers with keyboard/mouse/touch (~351 lines)
    │   └── moon.pkg                — Game package config (imports math, raylib, types)
    └── render/
        ├── render.mbt              — All drawing functions: world, HUD, overlays, touch controls (~993 lines)
        └── moon.pkg                — Render package config (imports math, raylib, types)
```

The game follows a clean three-package internal architecture. The `types` package defines all data structures, constants, and utility functions with no game logic. The `game` package contains all update logic and input processing. The `render` package handles all drawing. The root package's `main.mbt` simply creates the window, initializes state, and runs the game loop.

### Data Flow

1. **Initialization**: `main` creates a `Game` via `Game::new()`, then calls `init_title_scene` to set the state to `Title`. The game window is 1500x900 at 120 FPS with MSAA 4x anti-aliasing.

2. **Input collection**: Each frame, `main.mbt` reads mouse position, mouse button state, and touch point count into the `Game` struct. Then `update_game` dispatches to a state-specific input handler (e.g., `update_play_input`) that reads keyboard keys, checks touch/mouse against UI rectangles, and sets normalized input fields (`input_x`, `input_y`, `input_dash_hold`, etc.).

3. **State update**: After input, `update_game` dispatches to a state-specific update function. During `Play`: trap timers advance, pressure plates check player overlap, doors update their hold timers, the player moves with door collision blocking, relics are collected on proximity, hazards and hot traps are checked for player contact, and the exit gate is checked. Any hazard/trap contact calls `fail_stage` which sets state to `Failed`. Reaching the exit with all relics either advances to `StageClear` or `Victory`.

4. **Stage loading**: When starting or advancing, `load_stage` retrieves one of three hardcoded `StageLayout` structs (via `stage_layout_one/two/three`), then `apply_layout` copies all entity arrays into the `Game` struct, resets the player position and stamina, and sets state to `Play`.

5. **Rendering**: `draw_frame` first draws the ambient background with pulsing circles, then for non-title states draws the world (bounds, hazards, traps, plates, relics, doors, exit gate, player), the HUD panel with stage info and stamina bar, touch controls if in touch mode, and the banner. State-specific overlays (title card, stage clear, failed, victory) are drawn on top.

### Key Design Patterns

- **Enum-driven state machine**: `GameState` with five variants (`Title`, `Play`, `StageClear`, `Failed`, `Victory`) controls both input dispatch and update logic via match expressions, ensuring exhaustive handling.
- **Handcrafted stage layouts**: Rather than procedural generation, each stage is a manually designed `StageLayout` with precise entity placement, allowing deliberate difficulty progression and puzzle design.
- **Plate-door temporal coupling**: Pressure plates open doors with a hold timer (0.56-0.66s), creating a timing puzzle that combines with dash mechanics. Doors also check player overlap to prevent trapping.
- **Trap phase cycling**: Traps use a `timer + phase` modulo `cycle` comparison against `hot_window` to create staggered activation patterns, forcing the player to learn timing and use dash to cross during safe windows.
- **Unified input abstraction**: Each input handler combines keyboard, mouse, and touch into normalized fields (`input_x`, `input_y`, `input_dash_hold`), allowing the update logic to be input-source agnostic.
- **Delta time clamping**: The frame time is clamped to 0.033s (about 30 FPS minimum) in `main.mbt`, preventing physics instability from frame rate drops.
- **Separation of concerns**: The three internal packages strictly separate data definitions (types), game logic (game), and rendering (render), with the root package serving only as a thin entry point.

## Improvement & Refinement Plan

1. **Add a stage timer and scoring system**: The game tracks `stage_time` but does not use it for scoring. Adding a time-based score with star ratings (e.g., under 15s for 3 stars) would incentivize replaying stages for faster completion and add competitive depth.

2. **Implement trap visual telegraph**: Traps currently flash red only when "HOT" with no warning before activation. Adding a 0.3-0.5 second yellow warning phase before the hot window would give players visual feedback to time their dashes, reducing frustration from memorization-only gameplay.

3. **Add moving traps or patrol hazards**: All traps and hazards are static rectangles. Introducing patrol-path hazards that move along fixed routes would create dynamic obstacles that interact with the plate-door timing puzzles in interesting ways.

4. **Replace integer trap/hazard kinds with enums**: `trap_kind_spike`, `trap_kind_dart`, and `hazard_kind_lava` are integer constants. Converting these to proper MoonBit enums would improve type safety and make match expressions exhaustive.

5. **Add checkpoint system for longer stages**: Currently failing at any point in a stage resets to the beginning. Adding optional checkpoint relics that save progress within a stage would reduce repetition in the longer "Crown Vault" stage while keeping the core challenge intact.

6. **Implement door hold timer visualization**: Doors change color when open vs closed but do not visually indicate how much hold time remains. Adding a shrinking bar or color gradient tied to `door.timer / door.hold_time` would help players judge whether they can still make it through.

7. **Add sound effects and ambient audio**: The game is completely silent. Adding footstep sounds, a dash whoosh, trap activation clicks, relic collection chimes, and ambient temple dripping would significantly improve the atmosphere and provide audio cues for trap timing.

8. **Support configurable stage order and difficulty**: The three stages are always played in the same order. Adding a stage select screen after completing the game once, or offering a "hard mode" with tighter hold times and faster trap cycles, would extend replayability.
