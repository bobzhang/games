# Tower Defense Frontier 2026

Tower Defense Frontier is a classic lane-based tower defense game where players place defensive towers on a grid to intercept waves of enemies marching across five horizontal lanes. The game uses a straightforward grid layout of 5 lanes by 8 columns, giving 40 possible tower placement slots.

The core gameplay loop centers on spending gold to build towers that automatically target and shoot the nearest enemy ahead of them in the same lane within a 260-pixel range. Each kill earns 12 gold and 25 score, while completing a wave grants a 30 gold bonus. Waves escalate in difficulty: enemy HP increases by 7 per wave, speed increases by 3, and each successive wave spawns more enemies (8 + wave * 2). The player starts with 20 lives and loses one each time an enemy reaches the left edge.

The game is implemented as a single-file architecture with all logic, rendering, and data in `main.mbt`. Towers fire with a 0.58-second cooldown and deal damage that scales with the current wave number (8 + wave), ensuring towers remain somewhat effective against increasingly tough enemies.

## Build and Run

```bash
moon build --target native raylib_tower_defense_frontier_2026/
./_build/native/debug/build/raylib_tower_defense_frontier_2026/raylib_tower_defense_frontier_2026.exe
```

## Controls

- **Left Mouse Click**: Place a tower in an empty grid slot (costs 40 gold)
- **R**: Restart the game (resets all towers, enemies, gold, score, and waves)

## How to Play

The game begins with wave 1 spawning 8 enemies. Enemies appear on random lanes from the right side of the screen and march leftward at increasing speeds. Click on empty grid cells to build towers (each costs 40 gold; you start with 120 gold).

Towers automatically fire at the nearest enemy ahead of them (rightward) within a 260-pixel range in their lane. Each tower has a 0.58-second fire cooldown. Killing an enemy earns 12 gold and 25 score points.

When all enemies in a wave are defeated, a 2.5-second intermission begins, followed by the next wave. Completing a wave awards 30 bonus gold. Each new wave brings more enemies with higher HP and faster movement speed.

If an enemy reaches the left edge of the grid, you lose one life. At zero lives, the game is over. Press R to restart at any time.

## Public API Reference

### Package `raylib_tower_defense_frontier_2026`

> Main entry point and complete game implementation.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Enemy` | `alive`, `lane`, `x`, `hp`, `speed` | An enemy unit that moves leftward along a lane |
| `Tower` | `built`, `lane`, `slot`, `cooldown` | A defensive tower placed in a grid cell |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `tower_index` | `(Int, Int) -> Int` | Computes flat array index from lane and slot coordinates |
| `enemy_color` | `(Float) -> Color` | Returns a color based on enemy HP ratio (red > orange > gold) |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `lanes` | `Int` | 5 | Number of horizontal lanes |
| `slots` | `Int` | 8 | Number of tower slots per lane |
| `lane_h` | `Int` | 100 | Pixel height of each lane |
| `grid_x` | `Int` | 80 | Grid left edge X offset |
| `grid_y` | `Int` | 90 | Grid top edge Y offset |
| `cell_w` | `Int` | 90 | Width of each grid cell |
| `screen_w` | `Int` | 980 | Window width |
| `screen_h` | `Int` | 650 | Window height |

#### Game Variables (in `main`)

| Variable | Type | Initial | Description |
|----------|------|---------|-------------|
| `lives` | `Int` | 20 | Remaining player lives |
| `gold` | `Int` | 120 | Currency for building towers |
| `score` | `Int` | 0 | Accumulated score |
| `wave` | `Int` | 1 | Current wave number |
| `wave_spawn_left` | `Int` | 8 | Enemies remaining to spawn in current wave |
| `game_over` | `Bool` | false | Whether the game has ended |

## Architecture

### Package Structure

```
raylib_tower_defense_frontier_2026/
├── main.mbt              -- Complete game: structs, logic, input, rendering
└── moon.pkg              -- Package config (is-main, imports raylib)
```

This is a single-file game. All data structures, game logic, input handling, and rendering are contained in `main.mbt`. The `main` function initializes the window and runs the game loop directly.

### Data Flow

1. Each frame, the game checks for R key press to restart.
2. Mouse click position is translated to grid coordinates via `(my - grid_y) / lane_h` and `(mx - grid_x) / cell_w` to determine tower placement.
3. Wave spawning uses a timer (`wave_spawn_timer`) that ticks down; when it hits zero, a new enemy is placed in a random lane from the right edge.
4. Enemy positions update by subtracting `speed * dt` from their X coordinate. Enemies reaching `grid_x - 16` are removed and cost one life.
5. Each tower iterates over enemies to find the nearest one ahead in the same lane within 260 pixels. If found and cooldown is zero, it deals `8 + wave` damage.
6. When no enemies remain and no spawns are left, the game enters a between-wave pause, then advances the wave counter.

### Key Design Patterns

- **Object pool pattern**: Both `towers` (40 slots) and `enemies` (240 slots) are pre-allocated arrays with `built`/`alive` flags controlling active status.
- **Grid-based placement**: Tower positions map directly to lane/slot coordinates, converted to pixel positions via `grid_x + slot * cell_w`.
- **Scaling difficulty**: Enemy HP (20 + wave * 7), speed (42 + wave * 3), and count (8 + wave * 2) all scale linearly with wave number. Tower damage also scales (8 + wave) to partially compensate.
- **Single-file architecture**: All code lives in `main.mbt` with no internal packages, suitable for a small-scope game.

## Improvement & Refinement Plan

1. **Add tower upgrade mechanic**: Currently towers are identical. Adding upgrade tiers (increased damage or range) when clicking an existing tower would add strategic depth beyond placement.

2. **Introduce tower variety**: All towers behave identically (0.58s cooldown, 260px range, `8 + wave` damage). Adding tower types (sniper, splash, slow) with different stats would enrich gameplay.

3. **Add sell/remove tower functionality**: There is no way to remove a misplaced tower. A right-click sell option returning partial gold would improve usability.

4. **Extract structs to separate file or package**: The `Enemy` and `Tower` structs along with helper functions like `tower_index` and `enemy_color` could be separated into a types module for better organization.

5. **Display tower range indicator on hover**: Players cannot see a tower's 260-pixel attack range. Drawing a semi-transparent range indicator when hovering over a slot would help with placement decisions.

6. **Add projectile visualization**: Towers currently damage enemies instantly with no visual feedback. Adding a projectile or hit flash would make combat feel more impactful.

7. **Implement wave preview**: The game provides no information about the next wave. Showing upcoming wave enemy count and stats during the between-wave timer would help players prepare.
