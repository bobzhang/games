# Bomber Grid 2026

Bomber Grid 2026 is a classic Bomberman-style arcade game played on a 15x13 tile grid. The player navigates a maze of indestructible pillars and randomly generated breakable walls, placing bombs to clear paths and eliminate two enemy units lurking on the opposite corner of the map.

The core gameplay revolves around strategic bomb placement. Only one bomb can be active at a time, with a 2-second fuse timer followed by a 0.55-second blast phase. Explosions extend 3 tiles in each cardinal direction, stopping at indestructible walls (type 1) or destroying the first breakable wall (type 2) they encounter. The player must avoid both the bomb blast radius and direct contact with enemies, who wander the grid randomly every 0.32 seconds.

The map is procedurally generated: borders and even-coordinate intersections form permanent pillars, while 58% of remaining empty cells are filled with breakable walls. Spawn zones at positions (1,1) and (cols-2, rows-2) are guaranteed clear to give both the player and enemies room to start.

## Build and Run

```bash
moon build --target native bomber_grid_2026/
./_build/native/debug/build/bomber_grid_2026/bomber_grid_2026.exe
```

## Controls

- **W / Up Arrow**: Move up
- **S / Down Arrow**: Move down
- **A / Left Arrow**: Move left
- **D / Right Arrow**: Move right
- **Space**: Place bomb at current position (only one active at a time)
- **R**: Restart with a fresh random map

## How to Play

You start at position (1,1) in the top-left corner of the grid (cyan square). Two enemies (red squares) start at the bottom-right. Move through the grid using WASD or arrow keys -- movement is tile-based with a 0.09-second cooldown between steps.

Press Space to place a bomb at your current tile. The bomb has a 2-second fuse, shown as a black circle. When it detonates, fire extends 3 tiles in all four cardinal directions. Fire stops at indestructible walls and destroys the first breakable wall it hits. Each destroyed wall awards 12 points.

Enemies killed by bomb blasts award 120 points. Enemies move randomly every 0.32 seconds, choosing a random walkable adjacent cell. Walking into an enemy's tile (or them walking into yours) results in a loss. Standing in your own bomb's blast radius also kills you.

You cannot walk through an active bomb (before it detonates). Once the blast phase ends (0.55 seconds), the bomb disappears and you can place a new one.

**Win**: Eliminate all enemies.
**Lose**: Get caught in a bomb blast or touched by an enemy.

## Public API Reference

### Package `bomber_grid_2026`

> Single-file game with all logic, rendering, and input in `main.mbt`.

This game has no public types or functions -- all items are package-private.

#### Structs (package-private)

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Enemy` | `alive`, `x`, `y`, `step_timer` | An enemy unit with grid position and movement timer |
| `Bomb` | `active`, `x`, `y`, `fuse`, `blast` | The single bomb entity with fuse countdown and blast duration |

#### Constants (package-private)

| Constant | Value | Description |
|----------|-------|-------------|
| `cols` | `15` | Grid width in tiles |
| `rows` | `13` | Grid height in tiles |
| `tile` | `46` | Tile size in pixels |
| `off_x` | `38` | Grid X offset from screen edge |
| `off_y` | `70` | Grid Y offset from top |
| `screen_w` | `766` | Screen width (derived: 38*2 + 15*46) |
| `screen_h` | `738` | Screen height (derived: 70 + 13*46 + 70) |

#### Functions (package-private)

| Function | Signature | Description |
|----------|-----------|-------------|
| `idx` | `(Int, Int) -> Int` | Converts grid (x, y) to flat array index |
| `in_grid` | `(Int, Int) -> Bool` | Checks if coordinates are within grid bounds |
| `init_map` | `() -> Array[Int]` | Generates a random map with walls (1=indestructible, 2=breakable, 0=empty) |
| `is_walkable` | `(Array[Int], Int, Int, Bomb) -> Bool` | Checks if a cell is empty and not blocked by an active bomb |
| `fire_hits` | `(Array[Int], Bomb, Int, Int) -> Bool` | Tests if a target cell is within the bomb's blast radius (3 tiles in each direction) |
| `apply_explosion` | `(Array[Int], Bomb) -> Int` | Destroys breakable walls in blast radius, returns count of destroyed walls |
| `draw_fire_arm` | `(Array[Int], Bomb, Int, Int, Color) -> Unit` | Draws one arm of the bomb explosion in a given direction |

## Architecture

### Package Structure

```
bomber_grid_2026/
├── main.mbt    -- Single file: map generation, bomb logic, enemy AI, rendering
└── moon.pkg    -- Package config with raylib import
```

This is a single-file game with all state as local variables in `main`. The map is a flat `Array[Int]` of size 195 (15*13), where 0=empty, 1=indestructible wall, 2=breakable wall. Only one bomb exists as a single `Bomb` struct, and enemies are stored in a fixed-size array.

### Data Flow

1. **Map generation**: `init_map` creates the grid with border walls, pillar walls at even coordinates, random breakable walls (58% chance), and cleared spawn zones.
2. **Player movement**: Key presses move the player one tile per press with a 0.09s cooldown. `is_walkable` checks target cell validity (empty, in-bounds, not blocked by active bomb).
3. **Bomb lifecycle**: Space places a bomb at the player's position. `fuse` counts down for 2 seconds, then `blast` is set to 0.55 seconds. During blast, `apply_explosion` destroys breakable walls and `fire_hits` checks if player/enemies are caught.
4. **Enemy AI**: Each enemy has a `step_timer` that ticks up; at 0.32 seconds, it picks a random starting direction and tries all 4 cardinal directions for a walkable cell.
5. **Win/lose check**: Direct overlap with an enemy or being in blast radius triggers a loss. All enemies dead triggers a win.
6. **Rendering**: Grid cells are drawn as rectangles (dark gray for walls, brown for breakable). Bomb shows as a black circle (fuse phase) or orange rectangles (blast phase). Player is cyan, enemies are red.

### Key Design Patterns

- **Flat array grid**: The map uses a 1D array indexed by `y * cols + x`, a standard pattern for 2D grid games.
- **Single-bomb constraint**: Only one `Bomb` struct exists, enforcing the classic Bomberman one-bomb-at-a-time rule.
- **Directional blast propagation**: `fire_hits`, `apply_explosion`, and `draw_fire_arm` all share the same 4-direction, 3-step traversal logic, stopping at indestructible walls and breaking at destructible ones.
- **Random enemy movement**: Enemies pick a random starting direction each step, trying all 4 directions from that starting point, creating simple but unpredictable movement.
- **Procedural map with guaranteed spawn zones**: The `clear_cells` array ensures both player and enemy starting areas have free space regardless of random wall placement.

## Improvement & Refinement Plan

1. **Add multiple bomb support**: The current single `Bomb` struct limits gameplay depth. A bomb pool (e.g., 3 bombs) with staggered fuse timers would create richer strategic possibilities.

2. **Improve enemy AI with pathfinding**: Enemies in `main.mbt` move randomly, often getting stuck against walls. A simple chase behavior (move toward player using Manhattan distance) would increase difficulty.

3. **Add power-up items from destroyed walls**: `apply_explosion` destroys walls but drops nothing. Classic Bomberman features power-ups (blast range, bomb count, speed) hidden in breakable walls.

4. **Extract map cell types to an enum**: The map uses integers 0/1/2 with match statements. A `CellType` enum (`Empty`, `Wall`, `Breakable`) would be more readable.

5. **Fix blast applying damage every frame**: `apply_explosion` is called every frame during the 0.55s blast phase, scoring 12 points per destroyed wall per frame. The wall is set to 0 on the first call, so subsequent calls return 0, but this is fragile -- wall destruction and scoring should be separated into a one-time event.

6. **Add animation for wall destruction**: Breakable walls vanish instantly when `map[id] = 0` is set. A brief destruction animation (particles, fade-out) would provide better visual feedback.

7. **Support larger maps or level progression**: The fixed 15x13 grid and 2 enemies make the game short. Adding level progression with increasing grid sizes, more enemies, or tighter wall density would extend replayability.
