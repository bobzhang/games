# Stealth Heist 2026

Stealth Heist 2026 is a turn-based stealth puzzle game set in a grid-based facility. The player controls an infiltrator who must navigate an 18x12 tile map, avoid four patrolling guards, collect three keycards, and reach the extraction point without being caught or raising too many alerts.

The core gameplay is strictly turn-based: each movement the player makes advances the world by one step. Guards patrol in their current direction, bouncing off walls and rotating clockwise when blocked. When a guard has a clear line of sight (along cardinal axes, unobstructed by walls) to the player, it raises an alert and chases the player. The player has three smoke bombs that stun all guards within a Manhattan distance of 4 for three turns, providing critical escape windows. Getting caught (adjacent to a guard) or accumulating 5 alerts ends the mission.

The game features a hand-crafted map layout with interior walls forming corridors and rooms, creating natural chokepoints and hiding spots. All logic runs in a single `main.mbt` file with clean separation between map construction, guard AI, line-of-sight checks, and rendering.

## Build and Run

```bash
moon build --target native raylib_stealth_heist_2026/
./_build/native/debug/build/raylib_stealth_heist_2026/raylib_stealth_heist_2026.exe
```

## Controls

- **W / Up Arrow**: Move up one tile
- **A / Left Arrow**: Move left one tile
- **S / Down Arrow**: Move down one tile
- **D / Right Arrow**: Move right one tile
- **Space**: Use smoke bomb (stuns guards within Manhattan distance 4 for 3 turns)
- **R**: Reset the level

## How to Play

The player starts at tile (1, 1) in the top-left corner of the facility. Three keycards are placed at fixed locations: (2, 2), (12, 2), and (7, 10). The extraction point marked "E" is at tile (16, 10) in the bottom-right area.

Each key press moves the player one tile in the chosen direction, which also advances the simulation by one turn. Four guards patrol the facility, each starting with a different direction. When a guard cannot continue in its current direction (wall ahead), it rotates clockwise until it finds an open path. If a guard has unobstructed line of sight along a row or column to the player, it raises the alert level by 1 and moves one step toward the player instead of following its patrol.

Stunned guards (from smoke bombs) skip their turn and do not detect the player. The stun lasts 3 turns and is indicated by a "Z" above the guard and gray coloring.

The mission fails if: (1) a guard is adjacent to the player (Manhattan distance <= 1), or (2) the alert level reaches 5. The mission succeeds when all 3 keycards are collected and the player stands on the extraction tile. Press R at any time to restart.

## Public API Reference

### Package `raylib_stealth_heist_2026`

> Main entry point and complete game implementation.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1080` | Screen width in pixels |
| `sh` | `Int` | `720` | Screen height in pixels |
| `map_w` | `Int` | `18` | Map width in tiles |
| `map_h` | `Int` | `12` | Map height in tiles |
| `tile` | `Int` | `48` | Tile size in pixels |
| `map_x` | `Int` | `108` | Map rendering X offset in pixels |
| `map_y` | `Int` | `92` | Map rendering Y offset in pixels |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Guard` | `x`, `y`, `dir`, `stunned` | Guard entity with tile position, patrol direction (0=right, 1=down, 2=left, 3=up), and stun turn counter |
| `Card` | `x`, `y`, `collected` | Keycard collectible with tile position and collection state |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `idx` | `(Int, Int) -> Int` | Converts 2D tile coordinates to a 1D array index |
| `set_wall` | `(Array[Int], Int, Int) -> Unit` | Sets a tile as a wall in the map array |
| `is_wall` | `(Array[Int], Int, Int) -> Bool` | Checks if a tile is a wall or out of bounds |
| `build_map` | `(Array[Int]) -> Unit` | Constructs the facility layout with border walls and interior wall segments |
| `reset_cards` | `(Array[Card]) -> Unit` | Places keycards at their fixed starting positions and marks them uncollected |
| `reset_guards` | `(Array[Guard]) -> Unit` | Places guards at their fixed starting positions with initial patrol directions |
| `has_line_of_sight` | `(Array[Int], Int, Int, Int, Int) -> Bool` | Checks if a guard at (gx, gy) has unobstructed cardinal-axis line of sight to the player at (px, py) |
| `try_step` | `(Array[Int], Int, Int, Int) -> (Int, Int, Bool)` | Attempts to move from a position in a direction; returns new position and success flag |
| `move_guard_toward_player` | `(Array[Int], Guard, Int, Int) -> Unit` | Moves a guard one step toward the player along the shared axis |
| `all_cards_collected` | `(Array[Card]) -> Bool` | Returns true if every keycard has been collected |
| `collected_cards` | `(Array[Card]) -> Int` | Returns the count of collected keycards |

## Architecture

### Package Structure

```
raylib_stealth_heist_2026/
├── main.mbt              -- Entry point, game loop, map, AI, rendering
└── moon.pkg              -- Package config with raylib import
```

This is a single-file turn-based game. All map data, guard AI, player input, and rendering are in `main.mbt`.

### Data Flow

1. **Input**: Key presses are checked each frame. Movement keys set `move_dir` (0-3). Space triggers smoke bomb usage. Only one action per frame.

2. **Update** (only when `acted` is true):
   - Turn counter increments
   - Guards process in order: stunned guards decrement stun counter and skip. Guards with line of sight (`has_line_of_sight`) raise alert and chase via `move_guard_toward_player`. Other guards patrol: `try_step` in current direction, rotating clockwise on failure.
   - Detection check: if any guard saw the player, alert increments
   - Capture check: if any guard is adjacent (Manhattan distance <= 1), mission fails
   - Alert threshold: if alert >= 5, mission fails
   - Win check: all cards collected and player on exit tile

3. **Render**: Map tiles drawn as wall/floor rectangles. Exit tile drawn with green square and "E" label. Keycards as gold circles. Guards as red circles (gray when stunned). Player as sky-blue circle. HUD shows turns, smoke count, alert level, card count. Message bar at bottom. Win/lose overlay when game ends.

### Key Design Patterns

- **Turn-based simulation**: World only advances when the player acts (`acted` flag), creating a puzzle-like rhythm where the player can think between moves.
- **Cardinal line-of-sight**: `has_line_of_sight` only checks along rows and columns, stepping tile-by-tile and stopping at walls. This creates predictable sight lines that the player can reason about.
- **Patrol with clockwise rotation**: Guards try their current direction first, then rotate clockwise up to 4 times. This creates deterministic patrol patterns the player can learn.
- **Manhattan distance for area effects**: Smoke bombs use Manhattan distance (`dx + dy <= 4`) rather than Euclidean, matching the grid-based movement model.
- **Integer state flags**: Game uses simple boolean flags (`won`, `lost`) rather than an enum state machine, appropriate for the two terminal states.

## Improvement & Refinement Plan

1. **Add vision cone visualization**: Guards detect along cardinal axes but there is no visual indicator of their sight lines. Drawing colored lines or highlighted tiles along each guard's potential line of sight would help players plan routes.

2. **Implement procedural map generation**: The map is hard-coded in `build_map` with specific wall placements. A maze or room generation algorithm would add replay value while ensuring solvability.

3. **Add a noise/distraction mechanic**: Currently the only tool is smoke bombs. A noise-making item that attracts guards to a location would add tactical depth, especially for redirecting patrol routes.

4. **Track and display optimal solution**: Since the game is deterministic (fixed guard patterns), tracking the minimum number of turns to complete the heist and displaying it as a par score would encourage optimization.

5. **Extract guard AI into separate functions**: The guard behavior in the main loop mixes patrol logic, chase logic, and stun handling. Extracting a `update_guard(map, guard, player_x, player_y)` function would improve clarity.

6. **Add alert decay mechanic**: Currently alert only increases and never decreases. Adding slow alert decay when unseen for several consecutive turns would make the game more forgiving and encourage patience.

7. **Implement undo functionality**: Since the game is turn-based and deterministic, adding an undo feature (store previous positions) would reduce frustration when a single misclick ends a long run.
