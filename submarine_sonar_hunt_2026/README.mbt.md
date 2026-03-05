# Submarine Sonar Hunt 2026

Submarine Sonar Hunt 2026 is a resource-management exploration game set in an underwater arena. The player pilots a submarine through mine-infested waters, using sonar pulses to locate hidden wreck beacons (targets) while carefully managing three depleting resources: oxygen, fuel, and hull integrity.

The core gameplay revolves around a risk/reward sonar mechanic. Sonar pulses reveal both nearby targets and mines within range, but consume fuel (5.6) and oxygen (4.8) with each use. A "thermal hot zone" on the map amplifies sonar range by 110 units but accelerates oxygen drain by 4.4/sec. Successfully detecting targets rewards small oxygen and fuel bonuses, creating a positive feedback loop for efficient scanning. Colliding with armed mines deals heavy damage (36 hull, 18 oxygen, 11 fuel) and creates a knockback impulse.

The game features 9 progressive missions, each adding more targets to find (4 at mission 1, up to 12 at mission 9) and more mines (16 base, +4 per mission up to 54). A bearing indicator compass points toward the nearest undetected target. Oxygen recovers when surfacing in the top band of the arena, creating a natural rhythm of diving to scan and surfacing to breathe.

## Build and Run

```bash
moon build --target native submarine_sonar_hunt_2026/
./_build/native/debug/build/submarine_sonar_hunt_2026/submarine_sonar_hunt_2026.exe
```

## Controls

- **W / Up Arrow**: Move up
- **A / Left Arrow**: Move left
- **S / Down Arrow**: Move down
- **D / Right Arrow**: Move right
- **Space / F**: Emit sonar pulse (1.28-second cooldown)
- **Left Shift / Right Shift**: Boost speed (hold; drains extra fuel and oxygen)
- **R**: Restart current mission
- **Escape**: Return to title screen
- **N**: Advance to next mission (on win screen only)
- **T / Escape**: Return to title (on result screen)
- **Enter / Space**: Start game / restart (on title/result screens)
- **Touch controls**: Directional pad (bottom-left), PING and BOOST buttons (bottom-right), RESTART (top-right)

## How to Play

From the title screen, press Enter/Space or tap START to begin at your highest unlocked mission. The submarine spawns in the left portion of the arena with full resources (100 oxygen, 100 fuel, 100 hull).

Navigate through the arena using WASD or arrow keys. The submarine has physics-based movement with acceleration (420 normal, 760 boost), drag (4.8), and speed capping (220 normal, 340 boost). Hold Shift to boost, which consumes extra fuel (7.6/sec) and oxygen (1.8/sec) but allows faster traversal.

Press Space or F to emit a sonar pulse. The pulse expands outward as a visible ring over 0.82 seconds. Any target within the pulse range (192 base, 302 in the thermal zone) becomes permanently detected and visible as a green dot. Mines within 108% of pulse range are temporarily revealed for 3 seconds. Each detected target awards 4.8 oxygen and 3.2 fuel as a bonus.

Resources drain continuously: oxygen at 3.2/sec base (plus 4.4/sec in the hot zone, plus 1.8/sec while boosting), fuel at 0.5/sec idle plus 3.1/sec while moving plus 7.6/sec while boosting. Surface in the top 86-pixel band of the arena to recover oxygen at 10.2/sec, which offsets the base drain.

Armed mines explode on contact, dealing 36 hull, 18 oxygen, and 11 fuel damage with a knockback force. Mines become visible briefly after sonar detection; the first 3 mines of each mission start pre-revealed for 1.1 seconds.

The mission succeeds when all targets are detected. The mission fails if any resource (oxygen, fuel, or hull) reaches zero. On success, the next mission unlocks with more targets and denser minefields, up to mission 9.

## Public API Reference

### Package `submarine_sonar_hunt_2026`

> Main entry point.

The main function initializes the window with MSAA 4x hint, creates a `Game` instance, and runs the game loop calling `update_game` and `draw_frame`.

### Package `submarine_sonar_hunt_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Play`, `Win`, `Lose` | Game state machine states |
| `LoseReason` | `None`, `Oxygen`, `Fuel`, `Hull` | Reason for mission failure |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Mine` | `active`, `x`, `y`, `r`, `reveal_t`, `armed` | Underwater mine with position, variable radius, reveal timer, and armed state |
| `Target` | `active`, `x`, `y`, `detected`, `pulse_t` | Hidden wreck beacon with position, detection state, and pulse animation timer |
| `Game` | `mines`, `targets`, `state`, `mission`, `best_mission`, `sub_x`, `sub_y`, `oxygen`, `fuel`, `hull`, `sonar_cd`, `sonar_wave_t`, `lose_reason` | Main game state container with all entities, submarine state, resources, and UI state |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1280` | Screen width |
| `screen_h` | `Int` | `720` | Screen height |
| `target_fps` | `Int` | `120` | Target frame rate |
| `arena_x0`, `arena_y0` | `Int` | `78`, `84` | Arena top-left corner |
| `arena_w`, `arena_h` | `Int` | `1124`, `574` | Arena dimensions |
| `surface_band_h` | `Int` | `86` | Surface recovery zone height |
| `hot_zone_r` | `Float` | `148.0` | Thermal hot zone radius |
| `max_mines` | `Int` | `54` | Maximum mine pool size |
| `max_targets` | `Int` | `16` | Maximum target pool size |
| `base_target_goal` | `Int` | `4` | Targets to find at mission 1 |
| `target_goal_cap` | `Int` | `12` | Maximum targets at highest mission |
| `base_mine_count` | `Int` | `16` | Mine count at mission 1 |
| `oxygen_max`, `fuel_max`, `hull_max` | `Float` | `100.0` | Maximum resource values |
| `sonar_cd_time` | `Float` | `1.28` | Sonar cooldown duration |
| `sonar_base_range` | `Float` | `192.0` | Base sonar pulse range |
| `sonar_hot_bonus` | `Float` | `110.0` | Additional range in thermal zone |
| `mine_damage_hull` | `Float` | `36.0` | Hull damage from mine collision |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Mine::new` | `() -> Mine` | Creates an inactive mine with default values |
| `Target::new` | `() -> Target` | Creates an inactive target with default values |
| `Game::new` | `() -> Game` | Creates a new game with all pools allocated and default state |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between bounds |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between bounds |
| `absf` | `(Float) -> Float` | Absolute value of a float |
| `maxf` | `(Float, Float) -> Float` | Returns the greater of two floats |
| `minf` | `(Float, Float) -> Float` | Returns the lesser of two floats |
| `sqrtf` | `(Float) -> Float` | Square root of a float |
| `sinf` | `(Float) -> Float` | Sine of a float (via Double conversion) |
| `cosf` | `(Float) -> Float` | Cosine of a float (via Double conversion) |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two 2D points |
| `randf` | `(Float, Float) -> Float` | Random float in [lo, hi] range |
| `arena_left` | `() -> Float` | Left edge of arena as float |
| `arena_right` | `() -> Float` | Right edge of arena as float |
| `arena_top` | `() -> Float` | Top edge of arena as float |
| `arena_bottom` | `() -> Float` | Bottom edge of arena as float |
| `title_start_button_rect` | `() -> (Int, Int, Int, Int)` | Returns rectangle for title screen start button |
| `result_restart_button_rect` | `() -> (Int, Int, Int, Int)` | Returns rectangle for result screen restart button |
| `result_next_button_rect` | `() -> (Int, Int, Int, Int)` | Returns rectangle for result screen next button |
| `result_title_button_rect` | `() -> (Int, Int, Int, Int)` | Returns rectangle for result screen title button |
| `mobile_left_btn` | `() -> (Int, Int, Int, Int)` | Returns rectangle for mobile left directional button |
| `mobile_right_btn` | `() -> (Int, Int, Int, Int)` | Returns rectangle for mobile right directional button |
| `mobile_up_btn` | `() -> (Int, Int, Int, Int)` | Returns rectangle for mobile up directional button |
| `mobile_down_btn` | `() -> (Int, Int, Int, Int)` | Returns rectangle for mobile down directional button |
| `mobile_sonar_btn` | `() -> (Int, Int, Int, Int)` | Returns rectangle for mobile sonar button |
| `mobile_boost_btn` | `() -> (Int, Int, Int, Int)` | Returns rectangle for mobile boost button |
| `mobile_restart_btn` | `() -> (Int, Int, Int, Int)` | Returns rectangle for mobile restart button |
| `in_hot_zone_xy` | `(Float, Float) -> Bool` | Tests if a point is within the thermal hot zone |
| `point_in_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside a rectangle |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Tests if mouse or any touch point is on a rectangle |
| `nearest_undetected_target` | `(Game) -> (Float, Float, Bool)` | Finds the nearest undetected target's position and whether one exists |
| `lose_reason_text` | `(Game) -> String` | Returns a human-readable description of the loss reason |

### Package `submarine_sonar_hunt_2026/internal/game`

> Game logic, input handling, and update systems.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main update entry point: reads input state, processes input by game state, updates timers, and runs play state logic |
| `update_title_input` | `(Game) -> Unit` | Handles title screen input (Enter/Space/tap to start) |
| `update_play_input` | `(Game) -> Unit` | Handles play state input: movement, boost, sonar trigger, restart, escape |
| `update_result_input` | `(Game) -> Unit` | Handles win/lose screen input: restart, next mission, return to title |
| `reset_controls` | `(Game) -> Unit` | Clears all input flags on the game struct |
| `clear_world` | `(Game) -> Unit` | Deactivates all mines and targets |
| `target_goal_for_mission` | `(Int) -> Int` | Calculates target count for a given mission number |
| `mine_count_for_mission` | `(Int) -> Int` | Calculates mine count for a given mission number |
| `sonar_range_at` | `(Game) -> Float` | Returns effective sonar range based on submarine position (base + hot zone bonus) |
| `random_arena_point` | `(Float) -> (Float, Float)` | Generates a random point within the arena with given margin |
| `spawn_targets` | `(Game) -> Unit` | Places targets with separation constraints, away from start and below surface |
| `spawn_mines` | `(Game) -> Unit` | Places mines with separation and proximity constraints; 1/3 cluster near hot zone |
| `init_title_scene` | `(Game) -> Unit` | Resets game to title screen state |
| `start_mission` | `(Game, Int) -> Unit` | Initializes a mission: resets resources, spawns targets and mines |
| `restart_mission` | `(Game) -> Unit` | Restarts the current mission |
| `next_mission` | `(Game) -> Unit` | Advances to the next mission number |
| `fire_sonar` | `(Game) -> Unit` | Fires a sonar pulse: checks cooldown/resources, detects targets in range, reveals mines, awards bonuses |
| `update_sonar_wave` | `(Game, Float) -> Unit` | Animates the expanding sonar wave ring |
| `update_submarine_motion` | `(Game, Float) -> Unit` | Applies acceleration, drag, speed cap, and arena boundary clamping to submarine |
| `update_resources` | `(Game, Float) -> Unit` | Drains fuel and oxygen based on movement/boost/zone; recovers oxygen at surface |
| `update_contacts` | `(Game, Float) -> Unit` | Updates target pulse timers, mine reveal timers, and checks mine collision with submarine |
| `resolve_round_state` | `(Game) -> Unit` | Checks win (all targets found) and lose (any resource depleted) conditions |
| `update_play_state` | `(Game, Float) -> Unit` | Orchestrates play state: sonar, motion, resources, contacts, and state resolution |

### Package `submarine_sonar_hunt_2026/internal/render`

> Rendering and drawing routines.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main rendering entry point: dispatches drawing based on game state |
| `draw_ocean_background` | `(Game) -> Unit` | Draws gradient ocean background with animated wave lines |
| `draw_arena` | `() -> Unit` | Draws the arena rectangle with surface band and wave decorations |
| `draw_hot_zone` | `(Game) -> Unit` | Draws the thermal hot zone circle with brightness based on submarine proximity |
| `draw_targets` | `(Game) -> Unit` | Draws detected targets as green dots with pulse animation; shows sonar wavefront hints for undetected targets |
| `draw_mines` | `(Game) -> Unit` | Draws mines: fully visible when revealed or disarmed, faint dots when hidden |
| `draw_submarine` | `(Game) -> Unit` | Draws the submarine with body, tower, fins, viewport, and animated propeller with screen shake |
| `draw_sonar_wave` | `(Game) -> Unit` | Draws the expanding sonar pulse ring with fade-out alpha |
| `draw_bearing_indicator` | `(Game) -> Unit` | Draws a compass at screen top pointing to nearest undetected target |
| `draw_value_bar` | `(Int, Int, Int, Int, Float, Float, String, Color) -> Unit` | Draws a labeled resource bar with fill ratio |
| `draw_hud` | `(Game) -> Unit` | Draws oxygen/fuel/hull bars, mission info, sonar status, and zone tip text |
| `draw_touch_button` | `((Int,Int,Int,Int), String, Bool, Bool, (Int,Int,Int)) -> Unit` | Draws a styled touch button with label, active/hover states, and accent color |
| `draw_touch_controls` | `(Game) -> Unit` | Draws all mobile touch buttons during play state |
| `draw_center_text` | `(String, Int, Int, Color) -> Unit` | Draws horizontally centered text at given Y position |
| `draw_menu_button` | `((Int,Int,Int,Int), String, Bool, (Int,Int,Int)) -> Unit` | Draws a menu button with hover highlight |
| `draw_title_overlay` | `(Game) -> Unit` | Draws the title screen overlay with instructions and start button |
| `draw_result_overlay` | `(Game) -> Unit` | Draws the win/lose result overlay with restart/next/title buttons |
| `draw_title_preview` | `(Game) -> Unit` | Draws an animated submarine and sonar wave preview on the title screen |

## Architecture

### Package Structure

```
submarine_sonar_hunt_2026/
├── main.mbt                    -- Entry point: window init, game loop
├── moon.pkg                    -- Root package config
└── internal/
    ├── types/
    │   ├── types.mbt           -- Core structs (Game, Mine, Target) and enums (GameState, LoseReason)
    │   ├── constants.mbt       -- All game constants and tuning values
    │   └── utils.mbt           -- Math utilities, rect helpers, bearing calculations
    ├── game/
    │   ├── logic.mbt           -- Game state updates: motion, resources, contacts, sonar, spawning
    │   └── input.mbt           -- Input handling for title, play, and result screens
    └── render/
        └── render.mbt          -- All drawing: background, entities, HUD, overlays, touch controls
```

### Data Flow

1. **Input** (`input.mbt`): Each frame, `update_game` reads mouse/touch state into `Game` fields, then dispatches to the appropriate input handler based on `game.state`. `update_play_input` sets `move_x`, `move_y`, `boost_hold`, and `sonar_trigger` flags on the game struct, reading from both keyboard and touch button hit-testing via `pointer_on_rect`.

2. **Update** (`logic.mbt`): `update_play_state` orchestrates the play phase:
   - `fire_sonar` checks cooldown/resources, scans targets within range, reveals mines, awards resource bonuses
   - `update_submarine_motion` applies acceleration/drag/boundary clamping
   - `update_resources` computes oxygen and fuel drain rates based on movement, boost, and zone
   - `update_contacts` checks mine collisions and updates reveal/pulse timers
   - `resolve_round_state` transitions to Win or Lose if conditions are met

3. **Render** (`render.mbt`): `draw_frame` dispatches based on state. During Play, it draws: ocean gradient background, arena with surface band, hot zone, targets, mines, sonar wave, submarine, bearing indicator, HUD bars, and touch controls. Title and result screens use overlay panels with menu buttons.

### Key Design Patterns

- **ECS-like separation**: Types/constants in `types`, logic in `game`, rendering in `render`. All communicate through the shared `Game` struct.
- **State machine**: `GameState` enum (`Title`, `Play`, `Win`, `Lose`) drives both input dispatch and rendering.
- **Resource management triangle**: Three resources (oxygen, fuel, hull) create interlocking constraints -- oxygen forces surfacing, fuel limits movement, hull punishes mine contact.
- **Hot zone risk/reward**: The thermal zone amplifies sonar range but accelerates oxygen drain, creating a strategic decision about when to enter.
- **Mission progression**: `target_goal_for_mission` and `mine_count_for_mission` scale difficulty linearly with mission number, with caps.
- **Constrained placement**: `spawn_targets` and `spawn_mines` use rejection sampling with separation constraints to ensure fair layouts.
- **Bearing indicator**: `nearest_undetected_target` provides a directional compass hint without revealing exact positions.

## Improvement & Refinement Plan

1. **Add current detection for submarine drift**: The submarine has no environmental forces. Adding ocean currents that push the submarine (varying by depth or zone) would create an additional navigation challenge and more interesting movement dynamics.

2. **Implement mine chain reactions**: When a mine explodes, nearby armed mines within a radius could also detonate. This would make mine-dense areas more dangerous and reward careful sonar usage before entering tight spaces.

3. **Add a depth dimension**: Currently the arena is 2D with a surface band. Adding a depth mechanic where deeper diving reveals more targets but drains oxygen faster would add another strategic layer to complement the hot zone mechanic.

4. **Create target types with different behaviors**: All targets are static points. Adding moving targets, targets that emit periodic signals (brief visibility), or targets behind mine clusters would vary the scanning challenge across missions.

5. **Implement a score/ranking system**: The game only tracks mission completion. Adding a scoring system based on remaining resources, time taken, and mines avoided would give players optimization goals beyond mere completion.

6. **Add audio feedback for sonar**: The sonar mechanic is purely visual. A sonar ping sound with return echo variations based on proximity to targets would add immersion and could provide gameplay-relevant audio cues.

7. **Reduce code duplication in touch button handling**: The `draw_touch_controls` and input functions repeat `pointer_on_rect` calls with expanded tuple fields. Extracting a helper that takes a button rect tuple directly would significantly reduce boilerplate.
