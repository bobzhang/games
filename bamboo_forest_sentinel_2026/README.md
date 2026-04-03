# Bamboo Forest Sentinel 2026

Bamboo Forest Sentinel 2026 is an action-defense game set in a mystical bamboo forest. The player controls a sentinel warrior tasked with protecting three shrine beacons from waves of infiltrators that approach through a 3-lane corridor system. The game features a dark green aesthetic with swaying bamboo stalks and atmospheric lighting.

The core gameplay loop combines direct melee combat, a dash ability, bamboo snare traps, and a powerful "moon sweep" area-of-effect attack. Enemies spawn from the edges of the world along 6-8 routes and march toward the nearest beacon. The sentinel must balance an energy resource (used for attacks, dashes, and trap placement) against incoming threats, while building sweep charge through combat to unleash devastating area attacks. Nights escalate in difficulty with more enemies, faster spawn rates, and stronger infiltrators.

Technically, the game features a pre-allocated enemy pool of 260 slots, three enemy variants with distinct stat profiles, a sophisticated energy/charge resource system, and enemies that sway sinusoidally while patrolling to create organic movement. The trap system uses fixed grid slots positioned along the three lanes, and traps deal damage with a slow debuff on a rearm timer.

## Build and Run

```bash
moon build --target native bamboo_forest_sentinel_2026/
./_build/native/debug/build/bamboo_forest_sentinel_2026/bamboo_forest_sentinel_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move the sentinel in 8 directions
- **J**: Place a bamboo snare trap (if near an empty trap slot and enough energy) or perform a melee slash attack
- **K**: Remove a nearby active trap (refunds 8 energy)
- **Space**: Trigger moon sweep (if sweep charge is full) or dash in the movement/facing direction
- **P**: Pause / unpause the game
- **R**: Restart the game at any time
- **Enter / J / Space**: Start the game from the title screen

## How to Play

On the title screen, press J, Enter, or Space to begin. The sentinel starts in the center of the middle lane with 74 energy and 24 sweep charge. Enemies spawn from the left, right, and (from night 4+) top edges of the play area, marching toward the three shrine beacons positioned on the right side of the corridor.

**Combat**: Press J to slash enemies in a frontal arc (range 90, arc dot threshold 0.28). Each slash costs 6 energy and deals 34 damage with a 0.22s cooldown. If you are near an empty trap slot, J places a trap instead (costs 18 energy, 0.46s cooldown).

**Dash**: Press Space to dash in your movement direction at 860 speed for 0.12 seconds, costing 18 energy with a 0.92s cooldown. If no movement keys are held, you dash in your facing direction.

**Moon Sweep**: When sweep charge reaches 100 (charged passively at 3.8/s, +8 per hit, +16 per kill), pressing Space unleashes a 250-radius area attack dealing 88 damage to all nearby enemies.

**Traps**: Bamboo snares are placed on fixed grid positions (6 columns x 3 rows = 18 slots). They trigger automatically when an enemy enters their 54-unit radius, dealing 44 + (night-1)*1.8 damage and slowing the enemy by 44% for 1.1 seconds. Traps rearm after 1.18 seconds.

**Beacons**: Each beacon has 140 integrity. When an enemy reaches a beacon, it deals its damage value and self-destructs. The game ends when all beacon integrity is depleted.

**Night progression**: Each night spawns (10 + (night-1)*4) enemies. Spawn interval starts at 1.04s and decreases by 0.06s per night (floor 0.28s). Clearing a night awards 220 + night*34 score, 20 energy, and 22 sweep charge. Enemy stats scale with night: HP = 58 + (night-1)*6.4, speed = 92 + (night-1)*7.2, damage = 14 + (night-1)*1.5.

**Enemy types**: Kind 0 (standard, green), Kind 1 (fast/fragile, yellow, -10 HP, +22 speed, smaller radius), Kind 2 (heavy, red, +24 HP, -12 speed, +3 damage, larger radius). From night 6+, heavy enemies have a 24% spawn chance.

Energy regenerates at 14/s. Kills grant +4.8 energy. Score per kill = 40 + (night-1)*6 + kind*9.

## Public API Reference

### Package `bamboo_forest_sentinel_2026`

> Main entry point. Initializes window with MSAA 4x, creates the game, runs the update/draw loop.

No public types or functions are exported from this package.

### Package `bamboo_forest_sentinel_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Playing`, `Paused`, `GameOver` | State machine controlling game phase transitions |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Game` | `input`, `player`, `beacons`, `traps`, `enemies`, `state`, `night`, `score`, `best_score`, `kills`, `energy`, `sweep_charge`, `spawn_pool`, `spawn_cd`, `sweep_t`, `shake_t`, `game_over_reason` | Main game state container |
| `InputState` | `move_x`, `move_y`, `press_j`, `press_k`, `press_space`, `press_pause`, `press_restart`, `press_start` | Buffered input state polled each frame |
| `Player` | `x`, `y`, `facing_x`, `facing_y`, `dash_vx`, `dash_vy`, `dash_t`, `dash_cd`, `attack_cd`, `attack_t` | Player position, facing direction, and ability timers |
| `Beacon` | `x`, `y`, `integrity`, `pulse_t` | Shrine beacon with fixed position and destructible integrity |
| `Trap` | `active`, `x`, `y`, `trigger_cd`, `flash_t` | Bamboo snare trap on a fixed grid slot |
| `Enemy` | `active`, `x`, `y`, `vx`, `vy`, `hp`, `max_hp`, `speed`, `damage`, `target`, `slow_t`, `kind`, `anim_t` | Enemy infiltrator with movement, targeting, and slow debuff |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1500` | Window width |
| `screen_h` | `Int` | `900` | Window height |
| `target_fps` | `Int` | `120` | Target frame rate |
| `world_x` / `world_y` | `Int` | `44` / `48` | World area origin |
| `world_w` / `world_h` | `Int` | `1040` / `804` | World area dimensions |
| `hud_x` / `hud_y` | `Int` | derived | HUD panel origin |
| `hud_w` / `hud_h` | `Int` | `348` / derived | HUD panel dimensions |
| `corridor_lanes` | `Int` | `3` | Number of horizontal lanes |
| `player_radius` | `Float` | `16.0` | Player collision radius |
| `player_speed` | `Float` | `312.0` | Normal movement speed |
| `dash_speed` | `Float` | `860.0` | Dash velocity |
| `dash_time` | `Float` | `0.12` | Dash duration in seconds |
| `dash_cooldown` | `Float` | `0.92` | Dash cooldown in seconds |
| `dash_energy_cost` | `Float` | `18.0` | Energy cost per dash |
| `basic_attack_damage` | `Float` | `34.0` | Melee slash damage |
| `basic_attack_range` | `Float` | `90.0` | Melee slash reach |
| `basic_attack_arc_dot` | `Float` | `0.28` | Dot product threshold for arc hit detection |
| `basic_attack_energy_cost` | `Float` | `6.0` | Energy cost per slash |
| `basic_attack_cooldown` | `Float` | `0.22` | Slash cooldown in seconds |
| `energy_max` | `Float` | `100.0` | Maximum energy |
| `energy_regen` | `Float` | `14.0` | Energy regeneration per second |
| `sweep_charge_max` | `Float` | `100.0` | Maximum sweep charge |
| `sweep_radius` | `Float` | `250.0` | Moon sweep area-of-effect radius |
| `sweep_damage` | `Float` | `88.0` | Moon sweep damage |
| `trap_slot_count` | `Int` | `18` | Total trap grid slots (6 cols x 3 rows) |
| `trap_damage` | `Float` | `44.0` | Base trap damage |
| `trap_trigger_radius` | `Float` | `54.0` | Trap activation radius |
| `trap_rearm_time` | `Float` | `1.18` | Time between trap triggers |
| `trap_slow_factor` | `Float` | `0.56` | Speed multiplier when slowed |
| `beacon_count` | `Int` | `3` | Number of shrine beacons |
| `beacon_integrity_max` | `Float` | `140.0` | Maximum beacon HP |
| `max_enemies` | `Int` | `260` | Enemy pool size |
| `enemy_radius` | `Float` | `14.0` | Default enemy collision radius |
| `night_spawn_base` | `Int` | `10` | Base enemies per night |
| `night_spawn_step` | `Int` | `4` | Additional enemies per night |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `InputState::new` | `() -> InputState` | Creates a zeroed input state |
| `Player::new` | `() -> Player` | Creates player at default position in middle lane |
| `Beacon::new` | `(Int) -> Beacon` | Creates a beacon at the position for the given index |
| `Trap::new` | `(Int) -> Trap` | Creates an inactive trap at the slot position for the given index |
| `Enemy::new` | `() -> Enemy` | Creates an inactive enemy with zeroed fields |
| `Game::new` | `() -> Game` | Creates a full game state with pre-allocated pools |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer to [lo, hi] |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to [lo, hi] |
| `maxf` | `(Float, Float) -> Float` | Returns the larger of two floats |
| `maxi` | `(Int, Int) -> Int` | Returns the larger of two integers |
| `squaref` | `(Float) -> Float` | Returns v * v |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Returns squared distance between two 2D points |
| `randf` | `(Float, Float) -> Float` | Returns a random float in [lo, hi] |
| `sinf` | `(Float) -> Float` | Computes sine of a float value |
| `normalize2` | `(Float, Float) -> (Float, Float)` | Normalizes a 2D vector, returns (0,0) for near-zero length |
| `lane_y` | `(Int) -> Float` | Returns the Y coordinate for a lane index (0=top, 1=mid, 2=bottom) |
| `beacon_position` | `(Int) -> (Float, Float)` | Returns the fixed (x, y) position for a beacon index |
| `trap_slot_position` | `(Int) -> (Float, Float)` | Returns the fixed (x, y) position for a trap slot index |
| `spawn_route_count` | `(Int) -> Int` | Returns available spawn routes for a given night (6 or 8) |
| `spawn_route_position` | `(Int) -> (Float, Float)` | Returns spawn position for a route index |
| `spawn_route_target` | `(Int) -> Int` | Returns the preferred beacon target for a spawn route |
| `spawn_interval_for_night` | `(Int) -> Float` | Computes spawn interval based on night number |
| `enemy_hit_radius` | `(Int) -> Float` | Returns collision radius for an enemy kind |
| `active_enemy_count` | `(Game) -> Int` | Counts currently active enemies |
| `living_beacon_count` | `(Game) -> Int` | Counts beacons with positive integrity |
| `beacon_total_integrity` | `(Game) -> Float` | Sums integrity across all beacons |

### Package `bamboo_forest_sentinel_2026/internal/game`

> Game logic, input handling, and state updates.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main update entry point: polls input, ticks status timer, dispatches to state-specific update |

### Package `bamboo_forest_sentinel_2026/internal/render`

> Rendering and visual effects.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main rendering entry point: draws background, corridors, traps, beacons, enemies, player, HUD, banners, and state overlays |

## Architecture

### Package Structure

```
bamboo_forest_sentinel_2026/
├── main.mbt              -- Entry point: window init with MSAA, game loop with clamped dt
├── moon.pkg              -- Package config, imports
└── internal/
    ├── types/
    │   ├── types.mbt     -- GameState enum, Game/Player/Beacon/Trap/Enemy/InputState structs
    │   ├── constants.mbt -- ~60 tuning constants for all game systems
    │   └── utils.mbt     -- Math helpers, RNG, lane/beacon/trap/spawn position calculations
    ├── game/
    │   ├── input.mbt     -- Keyboard input polling into InputState buffer
    │   └── logic.mbt     -- Player movement, combat, traps, enemy AI, spawning, wave/loss evaluation
    └── render/
        └── render.mbt    -- Forest background, corridors, entities, HUD meters, overlays
```

The `types` package is unusually rich, containing not just data definitions but also all position-computation helpers and game-query functions. The `game` package handles all mutable state updates including a complex action priority system (J tries trap placement before attack, Space tries sweep before dash). The `render` package draws layered visuals with procedural bamboo stalks and animated meter bars.

### Data Flow

1. **Input**: `update_input` polls raylib key states each frame and writes a clean `InputState` struct (movement as -1/0/+1, action presses as booleans).
2. **State dispatch**: `update_game` routes to `update_title_state`, `update_playing_state`, `update_paused_state`, or `update_game_over_state` based on the `GameState` enum.
3. **Playing tick**: `tick_play_timers` regenerates energy/sweep charge and decrements all cooldown timers. `handle_player_actions` reads buffered input to perform attacks, place/remove traps, dash, or trigger sweeps. `update_player_movement` applies velocity with world-boundary clamping.
4. **Spawning**: `update_spawning` counts down `spawn_cd` and calls `spawn_enemy` to fill the enemy pool from random routes targeting the nearest alive beacon.
5. **Traps**: `update_traps` checks each active trap against nearby enemies for proximity triggers, dealing damage with slow debuff on hit.
6. **Enemies**: `update_enemies` moves each enemy toward its target beacon with sinusoidal sway, applying slow factor if debuffed. On reaching a beacon, the enemy deals damage and self-destructs.
7. **Evaluation**: `evaluate_wave_and_loss` checks for beacon destruction (game over) or wave completion (advance to next night with bonus rewards).
8. **Rendering**: `draw_frame` layers procedural bamboo background, lane corridors, trap slots, beacons with integrity bars, enemies with HP bars, player with attack/dash/sweep effects, HUD meters, night banner, and status text.

### Key Design Patterns

- **Buffered input state**: Rather than checking `is_key_down` inline, input is polled once per frame into an `InputState` struct, decoupling input from game logic.
- **Pre-allocated object pool**: 260 enemy slots are pre-allocated. `free_enemy_slot` scans for inactive entries to reuse.
- **Fixed grid trap slots**: Traps are placed on a predefined 6x3 grid rather than arbitrary positions, simplifying spatial reasoning and preventing trap stacking.
- **Action priority system**: J key tries trap placement first (near empty slot + enough energy), falling back to melee attack. Space tries moon sweep first (full charge), falling back to dash.
- **Night-based scaling**: All enemy stats, spawn counts, and intervals scale linearly with the night counter through constants in `constants.mbt`.
- **State machine with overlays**: Four game states (Title, Playing, Paused, GameOver) control logic flow, with the renderer drawing state-specific overlays on top of the persistent game scene.
- **Sinusoidal enemy sway**: Enemies oscillate perpendicular to their movement direction using `sin(anim_t * 7.5 + index * 0.4) * 14.0`, creating organic wave-like motion.

## Improvement & Refinement Plan

1. **Add beacon repair mechanic**: Beacons in `types.mbt` can only lose integrity, never regain it. A repair action (e.g., hold J near a beacon) would give the player recovery options between waves.

2. **Implement enemy-enemy collision avoidance**: `update_enemies` in `logic.mbt` moves enemies independently, causing them to overlap and stack on top of each other. A separation force or collision resolution pass would improve visual clarity.

3. **Replace integer kind with an enum**: The `Enemy.kind` field uses integers (0, 1, 2) with match statements scattered across `logic.mbt` and `render.mbt`. An `EnemyKind` enum would be more self-documenting and type-safe.

4. **Add visual feedback for energy-insufficient actions**: `start_dash` shows a status message for insufficient energy, but `perform_basic_attack` silently fails when energy is low. Consistent feedback across all actions would improve usability.

5. **Improve trap placement UX**: The current system requires the player to be within 46 units of a trap slot (`trap_place_range`), but there is no visual indicator of which slot will be activated. Highlighting the nearest valid slot would help.

6. **Balance late-game enemy scaling**: Enemy HP scales at 6.4 per night while player damage stays at 34 (slash) or 88 (sweep). By night 15+, standard enemies have ~150 HP requiring 5+ slashes to kill. Consider scaling player damage or adding upgrade mechanics.

7. **Add sound effects**: The game has visual flash effects for attacks (`attack_flash_time`), trap triggers (`trap_flash_time`), and screen shake (`shake_t`), but no audio. Sound would greatly enhance the action feedback loop.
