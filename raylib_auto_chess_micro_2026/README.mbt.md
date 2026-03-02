# Auto Chess Micro 2026

Auto Chess Micro 2026 is a lightweight auto-battler strategy game played on a 7x5 grid. During a preparation phase the player drafts and positions units on the left three columns of the board, then watches them fight automatically against AI-spawned enemies on the right side. The game spans up to 10 rounds with escalating difficulty.

The core loop alternates between two phases: **Prep** (buy and place units using gold) and **Battle** (units autonomously move toward enemies and attack based on Manhattan distance, attack range, and a 0.55-second cooldown). Three unit roles are available -- Tank (high HP, melee), Archer (ranged, moderate HP), and Blade (high ATK, melee) -- each with distinct cost, HP, attack, and range stats. Winning a round awards bonus gold (6 + round number), while losing costs 1 life but still grants 4 consolation gold. The player wins by surviving all 10 rounds ("CHAMPION") and loses if life drops to zero ("ELIMINATED").

The game is implemented as a single-file architecture with all logic, rendering, and input handling in `main.mbt`. Units are stored in a dynamic `Array[Piece]` that is rebuilt from the board layout each round, and the board itself is a flat `Array[Int]` mapping grid cells to role IDs.

## Build and Run

```bash
moon build --target native raylib_auto_chess_micro_2026/
./_build/native/debug/build/raylib_auto_chess_micro_2026/raylib_auto_chess_micro_2026.exe
```

## Controls

- **1**: Select Tank role (cost 5 gold)
- **2**: Select Archer role (cost 4 gold)
- **3**: Select Blade role (cost 4 gold)
- **Left Mouse Click**: Place selected unit on an empty left-side tile (columns 0-2), or remove an existing unit (+2 gold refund)
- **Enter**: Start the battle phase (requires at least one placed unit)
- **R**: Restart the entire game at any time

## How to Play

You begin with 12 gold and 12 life points. During the prep phase, press 1/2/3 to select a unit role, then click on tiles in the left three columns (your side) to place them. Each unit costs gold (Tank = 5, Archer = 4, Blade = 4). Clicking an occupied tile removes the unit and refunds 2 gold. You must place at least one unit before pressing Enter to begin the battle.

In battle, units automatically find the nearest enemy (by Manhattan distance), move one tile toward them per update tick, and attack when within range. Each attack deals the unit's ATK value as damage and triggers a 0.55-second cooldown. Archers can attack at range 3, while Tanks and Blades must be adjacent (range 1).

- **Win the round**: All enemy units are eliminated. You earn (6 + round number) gold.
- **Lose the round**: All your units are eliminated. You lose 1 life but earn 4 consolation gold.
- **Win the game**: Survive through round 10 (displayed as "CHAMPION").
- **Lose the game**: Life reaches 0 (displayed as "ELIMINATED").

Enemy count scales with the round number: each round spawns (2 + round) enemy units with random roles placed on the right side of the board.

### Unit Stats

| Role | Cost | HP | ATK | Range |
|------|------|----|-----|-------|
| Tank | 5 | 24 | 5 | 1 |
| Archer | 4 | 13 | 6 | 3 |
| Blade | 4 | 16 | 7 | 1 |

## Public API Reference

### Package `raylib_auto_chess_micro_2026`

> Main entry point and entire game implementation (single-file architecture).

This game has no public types or functions -- all items are package-private. The following are the key internal items:

#### Structs (package-private)

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Piece` | `alive`, `team`, `role`, `x`, `y`, `hp`, `atk`, `rng`, `cooldown` | A unit on the battlefield with team affiliation, stats, and attack cooldown timer |

#### Constants (package-private)

| Constant | Value | Description |
|----------|-------|-------------|
| `gw` | `7` | Grid width in tiles |
| `gh` | `5` | Grid height in tiles |
| `tile` | `86` | Tile size in pixels |
| `ox` | `120` | Grid origin X offset in pixels |
| `oy` | `120` | Grid origin Y offset in pixels |
| `sw` | `980` | Screen width in pixels |
| `sh` | `680` | Screen height in pixels |
| `phase_prep` | `0` | Preparation phase identifier |
| `phase_battle` | `1` | Battle phase identifier |

#### Functions (package-private)

| Function | Signature | Description |
|----------|-----------|-------------|
| `role_name` | `(Int) -> String` | Returns display name for a role ID (0=Tank, 1=Archer, 2=Blade) |
| `role_cost` | `(Int) -> Int` | Returns gold cost for a role |
| `role_hp` | `(Int) -> Int` | Returns base HP for a role |
| `role_atk` | `(Int) -> Int` | Returns attack damage for a role |
| `role_rng` | `(Int) -> Int` | Returns attack range for a role |
| `setup_piece` | `(Int, Int, Int, Int) -> Piece` | Creates a new alive piece with computed stats from role |
| `manhattan` | `(Int, Int, Int, Int) -> Int` | Computes Manhattan distance between two grid positions |
| `find_target` | `(Array[Piece], Int) -> Int` | Finds the index of the nearest enemy for a given unit, returns -1 if none |
| `occupied` | `(Array[Piece], Int, Int) -> Bool` | Checks if any alive unit occupies a grid cell |
| `copy_board_to_units` | `(Array[Int], Array[Piece]) -> Unit` | Converts the prep-phase board layout into battle-phase unit array (team 0) |
| `spawn_enemy_round` | `(Int, Array[Piece]) -> Unit` | Spawns (2 + round) random enemy units on the right side of the grid |
| `alive_team` | `(Array[Piece], Int) -> Int` | Counts alive units belonging to a given team |

## Architecture

### Package Structure

```
raylib_auto_chess_micro_2026/
├── main.mbt    -- Single file: all game logic, rendering, and input handling
└── moon.pkg    -- Package config with raylib import
```

This is a single-file game. All state (board layout, units, gold, life, round, phase) is managed as local variables inside `main`. The `board` array (`Array[Int]`, size 35) stores placed roles during prep phase, and `units` (`Array[Piece]`) holds active pieces during battle.

### Data Flow

1. **Prep Phase Input**: Key presses (1/2/3) set `selected_role`. Mouse clicks on left-side tiles (columns 0-2) place or remove units on the `board` array, adjusting gold accordingly.
2. **Battle Start**: On Enter press, `copy_board_to_units` reads the `board` array and creates `Piece` objects for team 0. `spawn_enemy_round` adds team 1 pieces. Phase switches to `phase_battle`.
3. **Battle Simulation**: Each frame, every alive unit decrements its cooldown, finds its nearest enemy via `find_target` (Manhattan distance), and either attacks if in range (dealing ATK damage) or moves one step closer if the target cell is unoccupied.
4. **Round Resolution**: When one team is fully eliminated, the phase returns to `phase_prep`. Gold and life are updated based on the outcome.
5. **Rendering**: The grid is drawn with blue-tinted left columns (player side) and red-tinted right columns (enemy side). Units appear as colored rectangles with HP text overlays. During prep phase, units are read from `board`; during battle, from `units`.

### Key Design Patterns

- **Phase state machine**: The game uses integer constants (`phase_prep = 0`, `phase_battle = 1`) to switch between preparation and auto-battle modes.
- **Flat array board**: The prep-phase board uses a 1D `Array[Int]` indexed as `y * gw + x`, with -1 indicating empty cells. This is rebuilt into unit objects each round.
- **Role-based stat lookup**: Five pure functions (`role_name`, `role_cost`, `role_hp`, `role_atk`, `role_rng`) map integer role IDs to stats, acting as a lightweight data-driven design.
- **Manhattan distance AI**: Units use Manhattan distance for both target selection (nearest enemy) and movement decisions (step toward target along the axis with the greater difference).

## Improvement & Refinement Plan

1. **Extract unit roles into an enum**: The `role` field is an `Int` (0/1/2) with five separate lookup functions. An enum `Role { Tank; Archer; Blade }` with methods would be type-safe and self-documenting.

2. **Fix enemy placement collisions**: `spawn_enemy_round` places enemies at random positions without checking for overlap. Multiple enemies can stack on the same tile, which the movement code's `occupied` check then cannot resolve.

3. **Add unit removal during prep on right-click**: Currently, left-click on an occupied tile removes it. A right-click-to-remove convention would prevent accidental removals when trying to reposition units.

4. **Improve battle movement with proper pathfinding**: Units move along the axis with the greatest difference to the target, but cannot navigate around obstacles. Units may get stuck behind friendly units. A simple BFS or A* would improve battle flow.

5. **Add animation and visual feedback for attacks**: During battle, damage is applied instantly with no visual indicator. A brief flash, damage number popup, or projectile for Archers would make battles more readable.

6. **Balance enemy scaling**: Enemy count grows linearly as (2 + round), reaching 12 units by round 10. Combined with random role selection, later rounds may be either trivially easy or impossibly hard. Consider fixed enemy compositions or scaling stats instead.

7. **Persist board layout between rounds**: `copy_board_to_units` reads the board each round, so placed units persist across rounds, which is good. However, the UI does not clearly indicate this. A visual indicator showing "your army" between rounds would help.
