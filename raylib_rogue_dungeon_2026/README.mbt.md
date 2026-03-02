# Rogue Dungeon 2026

Rogue Dungeon 2026 is a classic turn-based roguelike dungeon crawler rendered on a 21x15 tile grid. The player controls a hero represented by the "@" glyph, navigating procedurally generated dungeon corridors and fighting monsters in melee combat. The dark, minimalist aesthetic evokes traditional ASCII roguelikes while using colored rectangles and text for a clean visual presentation.

The core gameplay loop is turn-based: each time the player moves or attacks, all enemies take their turn in sequence. The hero deals 3 damage per attack by walking into an adjacent monster, while monsters chase the hero using simple greedy pathfinding and deal damage when adjacent (2 damage if already adjacent at the start of the turn, 1 damage if they move next to the hero). The goal is to eliminate all four monsters before running out of 14 HP. Score accumulates from movement (+2), hits (+20), kills (+100), and a dungeon-clear bonus (+500).

The level generator creates random walls with a 22% density, guarantees a center horizontal corridor for traversability, and clears the starting corner. Enemy AI uses `step_toward` to greedily move along the dominant axis toward the hero, with random fallback movement when blocked.

## Build and Run

```bash
moon build --target native raylib_rogue_dungeon_2026/
./_build/native/debug/build/raylib_rogue_dungeon_2026/raylib_rogue_dungeon_2026.exe
```

## Controls

- **W / Up Arrow**: Move one tile up (or attack adjacent enemy above)
- **S / Down Arrow**: Move one tile down (or attack adjacent enemy below)
- **A / Left Arrow**: Move one tile left (or attack adjacent enemy to the left)
- **D / Right Arrow**: Move one tile right (or attack adjacent enemy to the right)
- **R**: Restart with a freshly generated dungeon and reset all state

## How to Play

You control the "@" hero starting at position (1,1) in the top-left corner of a 21x15 dungeon grid. The dungeon is populated with random walls (22% chance per interior tile) and four monsters ("M") placed at strategic positions near the right side of the map.

Each direction key press constitutes one turn. If the target tile contains a monster, you attack it for 3 damage instead of moving. Monsters have 4-6 HP each. After your action, every living monster takes a turn:
- If a monster is already adjacent to you (Manhattan distance 1), it attacks for 2 damage and stays put.
- Otherwise, it tries to step toward you along the axis with the greatest distance. If blocked, it attempts a random valid direction.
- If a monster ends up adjacent to you after moving, it attacks for 1 additional damage.

Your hero starts with 14 HP. Defeat all four monsters to clear the dungeon and earn a 500-point bonus. If your HP drops to 0, the game ends in defeat. Press R at any time to restart with a new map layout.

## Public API Reference

### Package `raylib_rogue_dungeon_2026`

> Main entry point. Single-file game containing all types, logic, rendering, and the main loop.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `map_w` | `Int` | `21` | Dungeon map width in tiles |
| `map_h` | `Int` | `15` | Dungeon map height in tiles |
| `tile_sz` | `Int` | `36` | Tile size in pixels |
| `view_x` | `Int` | `34` | X offset of the map viewport in pixels |
| `view_y` | `Int` | `86` | Y offset of the map viewport in pixels |
| `screen_w` | `Int` | computed | Screen width (2 * view_x + map_w * tile_sz = 824) |
| `screen_h` | `Int` | `720` | Screen height in pixels |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Mob` | `alive`, `x`, `y`, `hp` | A dungeon monster with grid position, alive status, and hit points |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `mindex` | `(Int, Int) -> Int` | Converts (x, y) grid coordinates to a 1D array index |
| `inside` | `(Int, Int) -> Bool` | Returns true if coordinates are within the map bounds |
| `gen_level` | `() -> Array[Int]` | Generates a dungeon level: 0 = floor, 1 = wall. Adds random walls at 22% density, carves a center corridor, and clears the start area |
| `mob_at` | `(Array[Mob], Int, Int) -> Int` | Returns the index of a living mob at the given position, or -1 if none |
| `passable` | `(Array[Int], Array[Mob], Int, Int) -> Bool` | Returns true if a tile is in bounds, is floor, and has no mob on it |
| `step_toward` | `(Int, Int, Int, Int) -> (Int, Int)` | Computes a single-step direction (dx, dy) from point A toward point B along the dominant axis |
| `draw_board` | `(Array[Int]) -> Unit` | Draws the entire dungeon grid: dark floor tiles with grid lines and lighter wall tiles |
| `draw_unit` | `(Int, Int, Color, String) -> Unit` | Draws a unit (hero or mob) as a colored square with a text glyph at the given grid position |
| `alive_mobs` | `(Array[Mob]) -> Int` | Returns the count of living monsters in the array |

## Architecture

### Package Structure

```
raylib_rogue_dungeon_2026/
├── main.mbt              -- Entry point: all game types, logic, rendering, and main loop
└── moon.pkg              -- Package config with raylib import
```

This is a single-file roguelike with all code in `main.mbt`. The file follows a top-down organization: constants, struct definition, utility functions, level generation, AI logic, rendering functions, and the main game loop.

### Data Flow

1. **Level generation**: `gen_level` creates a flat `Array[Int]` representing the tile map (0=floor, 1=wall) with random placement and guaranteed corridors.
2. **Input**: Each frame, `is_key_pressed` checks for WASD/arrow keys. A non-zero (dx, dy) triggers one game turn.
3. **Player turn**: If the target tile has a mob (`mob_at`), the hero attacks; otherwise, if the tile is floor, the hero moves.
4. **Enemy turn**: Each living mob checks adjacency for melee attacks, then uses `step_toward` for greedy pathfinding, with random fallback when blocked by walls or other mobs.
5. **Win/loss check**: After each turn, `alive_mobs` checks for victory; hero HP <= 0 triggers defeat.
6. **Rendering**: `draw_board` renders the tile grid, `draw_unit` draws the hero and each living mob, and HUD text shows HP, score, turns, and enemy count.

### Key Design Patterns

- **Turn-based architecture**: Input is processed only on key press (not key held), and each input triggers exactly one game turn with sequential enemy updates.
- **Flat array map**: The dungeon uses a 1D `Array[Int]` indexed by `mindex(x, y) = y * map_w + x`, a classic roguelike pattern for efficient tile lookup.
- **Greedy AI with fallback**: Enemies use `step_toward` for dominant-axis pursuit, falling back to random valid directions when blocked, preventing stuck enemies.
- **Bump-to-attack**: Moving into an occupied tile triggers combat instead of movement, a standard roguelike interaction pattern.
- **Procedural generation**: `gen_level` uses random wall placement with guaranteed corridors and clear zones to ensure playability without complex room-generation algorithms.

## Improvement & Refinement Plan

1. **Add connectivity validation**: `gen_level` randomly places walls at 22% density but does not verify that all floor tiles are reachable from the start. Adding a flood-fill check after generation would prevent unwinnable maps where monsters are walled off.

2. **Introduce item pickups**: The dungeon currently has no items. Adding health potions or weapon upgrades on random floor tiles would add strategic depth to movement decisions.

3. **Improve enemy variety**: All four `Mob` instances differ only in HP (4-6) and starting position. Adding a `kind` field with different damage values, movement patterns, or abilities would create more varied encounters.

4. **Add fog of war**: Currently the entire map is visible. Implementing line-of-sight or distance-based visibility would add tension and reward careful exploration, leveraging the existing `inside` and `mindex` functions.

5. **Extract game state into a struct**: The hero state (`hero_x`, `hero_y`, `hero_hp`, `turns`, `score`, `victory`, `defeat`) uses separate mutable variables in `main`. A `GameState` struct would centralize state management and simplify reset logic.

6. **Support multi-level dungeons**: When all mobs are defeated, a staircase could lead to a new `gen_level` with more enemies or higher HP values, extending the game beyond a single floor.

7. **Add damage feedback**: There is no visual indication when the hero or a mob takes damage. A brief color flash on `draw_unit` (similar to the stun flash in other games) or floating damage numbers would improve combat feedback.
