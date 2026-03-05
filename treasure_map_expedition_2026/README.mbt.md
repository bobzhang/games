# Treasure Map Expedition 2026

Treasure Map Expedition is a turn-based fog-of-war exploration game set in a jungle grid. Players navigate a hidden map, revealing terrain as they move, searching for four scattered relics of increasing value. The game evokes classic roguelike exploration with a focus on efficient pathing and resource management.

The core loop involves moving through an 18x12 tile grid where most of the map starts hidden in fog. Each step costs 2 stamina (starting at 100), and reveals a 5x5 area around the player. Relics must be physically walked over to pick up, then carried back to the base camp tile to bank their value. Returning to camp also restores stamina (+2 per visit). The expedition ends successfully when all four relics are collected and banked, or fails if stamina reaches zero or the 240-second storm timer expires.

The map features fixed wall boundaries around the edges, interior jungle obstacles at predetermined positions, and four relics placed at specific coordinates with values of 80, 120, 160, and 210 points. The game tests the player's ability to plan efficient routes through partially revealed terrain under dual resource pressure (stamina and time).

## Build and Run

```bash
moon build --target native treasure_map_expedition_2026/
./_build/native/debug/build/treasure_map_expedition_2026/treasure_map_expedition_2026.exe
```

## Controls

- **W/Up**: Move up
- **A/Left**: Move left
- **S/Down**: Move down
- **D/Right**: Move right
- **R**: Restart expedition

## How to Play

You start at camp (top-left corner, marked "C") with 100 stamina and a 240-second timer. The map is mostly fog; moving reveals a 5x5 area (radius 2) around your position.

**Movement:** Each step costs 2 stamina. You cannot move into wall tiles (map borders and interior jungle obstacles). If stamina reaches zero, you are stranded and the expedition ends.

**Relics:** Four golden relics are hidden across the map at fixed positions. Walk over a relic to pick it up (it adds to your bag value). Relics are only visible once their tile has been revealed through fog.

**Banking:** Return to the camp tile (1,1) to bank all relics in your bag. Banking converts bag value to permanent bank score and restores 2 stamina (capped at 100). You must bank relics to secure their value.

**Winning:** Collect and bank all 4 relics (total value 570) to complete the expedition. The game also ends if the 240-second storm timer runs out.

**Relic locations and values:**
- (2, 9) -- 80 points
- (15, 2) -- 120 points
- (14, 9) -- 160 points
- (8, 6) -- 210 points

## Public API Reference

### Package `treasure_map_expedition_2026`

> Main entry point and complete game implementation.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Relic` | `x`, `y`, `taken`, `value` | A collectible treasure at a fixed grid position |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `idx` | `(Int, Int) -> Int` | Converts 2D grid coordinates to flat array index (`y * gw + x`) |
| `reset_map` | `(Array[Bool], Array[Bool]) -> Unit` | Clears blocked/seen arrays and places border walls and interior obstacles |
| `reset_relics` | `(Array[Relic]) -> Unit` | Resets all 4 relics to their fixed positions with default values |
| `reveal` | `(Array[Bool], Int, Int, Int) -> Unit` | Marks all tiles within a square radius as seen |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | 1120 | Window width |
| `sh` | `Int` | 760 | Window height |
| `gw` | `Int` | 18 | Grid width in tiles |
| `gh` | `Int` | 12 | Grid height in tiles |
| `cell` | `Int` | 48 | Pixel size of each grid cell |
| `ox` | `Int` | 120 | Grid render X offset |
| `oy` | `Int` | 110 | Grid render Y offset |

#### Game Variables (in `main`)

| Variable | Type | Initial | Description |
|----------|------|---------|-------------|
| `px`, `py` | `Int` | 1, 1 | Player grid position |
| `stamina` | `Int` | 100 | Current stamina (2 per step) |
| `steps` | `Int` | 0 | Total steps taken |
| `bag_value` | `Int` | 0 | Value of relics currently carried |
| `bank` | `Int` | 0 | Permanently banked relic value |
| `timer` | `Float` | 240.0 | Storm countdown timer |

## Architecture

### Package Structure

```
treasure_map_expedition_2026/
├── main.mbt              -- Complete game: grid setup, movement, fog reveal, relic logic, rendering
└── moon.pkg              -- Package config (is-main, imports raylib)
```

Single-file architecture with all code in `main.mbt`.

### Data Flow

1. **Initialization:** `reset_map` creates border walls and interior obstacles in the `blocked` array. `reset_relics` places 4 relics. `reveal` opens the starting area around camp.
2. **Input:** WASD/Arrow keys set `dx`/`dy` offsets. The new position `(px+dx, py+dy)` is bounds-checked and blocked-tile checked before applying.
3. **Movement:** On valid movement, stamina decreases by 2, step count increments, and `reveal` opens a 5x5 area around the new position.
4. **Camp check:** If the player is on the camp tile (1,1), any bag value is transferred to bank and stamina is restored by 2.
5. **Relic pickup:** Each relic is checked for position match with the player; if found, its value is added to `bag_value` and it is marked as taken.
6. **End conditions:** Stamina <= 0 ends the game. Timer <= 0 ends the game. All relics taken and banked at camp ends the game successfully.
7. **Rendering:** The grid draws unseen tiles as dark, seen tiles as green (passable) or darker green (blocked), with camp marked "C", relics as gold circles, and the player as a skyblue circle.

### Key Design Patterns

- **Fog-of-war grid**: Two parallel boolean arrays (`blocked` and `seen`) overlay the same grid. Only `seen` tiles are rendered with their actual content.
- **Carry-and-bank mechanic**: Relics are not scored immediately; they must be physically returned to camp. This creates risk/reward decisions about how many relics to carry before banking.
- **Fixed map layout**: Obstacles and relic positions are hardcoded, making the game a spatial puzzle rather than procedurally generated.
- **Dual resource pressure**: Stamina (limited by movement) and time (real-time countdown) create two independent constraints the player must satisfy.

## Improvement & Refinement Plan

1. **Add procedural map generation**: The obstacle and relic positions in `reset_map` and `reset_relics` are hardcoded. A procedural generator ensuring reachability would add replay value.

2. **Implement danger zones or enemies**: The jungle is currently static and safe. Adding roaming threats that deplete stamina on contact would create tension during exploration.

3. **Scale stamina cost by terrain type**: Currently every step costs exactly 2 stamina. Adding terrain types (swamp costs 4, path costs 1) would make route planning more strategic.

4. **Add minimap showing explored areas**: With an 18x12 grid and 48px cells, the full map is visible but fog-hidden. A small corner minimap showing explored/unexplored ratios would help orientation.

5. **Implement multiple expedition levels**: The single fixed map provides limited replayability. Adding multiple maps with different layouts, more relics, or larger grids would extend the game.

6. **Add visual stamina warning**: Stamina depletion ends the game immediately. A screen tint or pulsing HUD effect when stamina drops below 20 would give players an urgent warning to return to camp.

7. **Display distance to camp**: Adding a HUD element showing Manhattan distance to camp would help players judge whether they have enough stamina to return safely.
