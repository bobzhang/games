# City Builder Mini 2026

A simplified city-building simulation on a 16x12 grid where players zone residential, commercial, and industrial areas connected by roads to grow a thriving city. The terrain includes randomly placed rocky tiles that block construction, and the economy ticks forward every second (one "day"), simulating population growth, job creation, income, and upkeep.

The core gameplay loop involves selecting a tool (road, residential, commercial, industrial, or bulldoze), clicking grid cells to place zones, and watching the city evolve each day. Residential zones provide population capacity (10 if road-adjacent, 3 otherwise). Commercial zones create 12 jobs each, industrial zones create 16 jobs each. Population grows toward the minimum of housing capacity and available jobs (+20 buffer), capped at +12 per day. Income comes from population, commercial/industrial zones, and happiness, while upkeep costs scale with road count and zone count. The game is won when population reaches 450 and money reaches $1200; it is lost when money drops below -$500.

## Build and Run

```bash
moon build --target native raylib_city_builder_mini_2026/
./_build/native/debug/build/raylib_city_builder_mini_2026/raylib_city_builder_mini_2026.exe
```

## Controls

- **0**: Select bulldoze tool (removes zones)
- **1**: Select road tool ($5 per tile)
- **2**: Select residential zone ($22 per tile)
- **3**: Select commercial zone ($30 per tile)
- **4**: Select industrial zone ($36 per tile)
- **Mouse Click**: Place selected zone on the grid (or bulldoze with tool 0)
- **R**: Restart with a new random terrain

## How to Play

Start with $420, population 0, and happiness 55. The 16x12 grid has some rocky terrain tiles (gray) that cannot be built on.

**Building**: Select a tool with number keys, then click grid cells to place zones. Zones cannot be placed on rocky terrain (terrain value 1). Use the bulldoze tool (0) to clear any placed zone.

**Zone types**:
- **Road** (gray, $5): Required for residential zones to reach full capacity. Costs $1 upkeep per day.
- **Residential** (green, $22): Provides population capacity. Adjacent to a road: 10 capacity and counts as "serviced" (+2 happiness). Without road: only 3 capacity.
- **Commercial** (blue, $30): Provides 12 jobs. Adds $5 income/day. Costs $2 upkeep/day.
- **Industrial** (orange, $36): Provides 16 jobs. Adds $6 income/day. Costs $2 upkeep/day. Reduces happiness by 2 per zone.

**Economy (per day)**:
- Income = population/4 + commercial*5 + industrial*6 + happiness/8
- Upkeep = roads + commercial*2 + industrial*2
- Net = income - upkeep

**Population**: Grows toward min(residential_capacity, jobs + 20), changing by at most +12 or -8 per day.

**Happiness**: Base 50 + serviced_residential*2 - industrial*2, clamped between 5 and 95.

**Win**: Population >= 450 AND money >= $1200. **Lose**: Money drops below -$500.

## Public API Reference

### Package `raylib_city_builder_mini_2026`

> Main entry point and complete game implementation (single-file architecture).

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `gw` | `Int` | `16` | Grid width in cells |
| `gh` | `Int` | `12` | Grid height in cells |
| `cell` | `Int` | `44` | Cell size in pixels |
| `ox` | `Int` | `36` | Grid X offset from screen edge |
| `oy` | `Int` | `90` | Grid Y offset from screen top |
| `sw` | `Int` | `776` | Screen width (ox*2 + gw*cell) |
| `sh` | `Int` | `700` | Screen height |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `gidx` | `(Int, Int) -> Int` | Converts (x, y) grid coordinates to linear array index |
| `inb` | `(Int, Int) -> Bool` | Tests if grid coordinates are within bounds |
| `zone_cost` | `(Int) -> Int` | Returns the cost to place a zone type (1=road $5, 2=res $22, 3=com $30, 4=ind $36) |
| `zone_color` | `(Int) -> Color` | Returns the display color for a zone type |
| `terrain_color` | `(Int) -> Color` | Returns the display color for terrain (0=grass green, 1=rocky gray) |
| `adjacent_roads` | `(Array[Int], Int, Int) -> Int` | Counts road tiles in the 4 cardinal directions from a grid position |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between low and high bounds |
| `regen_world` | `(Array[Int], Array[Int]) -> Unit` | Generates random terrain (10% rocky) and clears all zones; ensures a clear starting area at (2,2)-(3,3) |
| `main` | `() -> Unit` | Entry point: initializes window, terrain/zone arrays, and runs the game loop with tool selection, placement, economy simulation, and rendering |

## Architecture

### Package Structure

```
raylib_city_builder_mini_2026/
├── main.mbt              — Complete game: grid logic, economy simulation, rendering
└── moon.pkg              — Package config with raylib import
```

Single-file architecture. Two parallel arrays (`terrain` and `zone`, each `gw*gh = 192` elements) store the grid state. All game state (money, population, happiness, day, tool) is managed as mutable local variables in `main`.

### Data Flow

1. **Input**: Number keys (0-4) select the active tool. Mouse clicks identify grid cells via pixel-to-grid conversion. Placement checks terrain validity and budget before modifying the `zone` array.
2. **Simulation**: Every 1.0 seconds (`tick >= 1.0`), a day passes. The full grid is scanned to count roads, residential capacity (with road adjacency bonus), commercial zones, and industrial zones. Population adjusts toward equilibrium, happiness recalculates, and net income (income - upkeep) modifies money.
3. **Win/Loss**: Checked after each day tick. Win requires population >= 450 AND money >= $1200. Loss triggers at money < -$500.
4. **Render**: Draws terrain tiles as colored rectangles, zone overlays (inset rectangles), grid lines, HUD text (day, money, population, happiness), current tool display, and win/loss overlay.

### Key Design Patterns

- **Dual-layer grid**: Terrain (immutable obstacles) and zones (player-placed) stored as separate arrays, with terrain blocking zone placement but not affecting existing zones.
- **Tick-based simulation**: Economy updates once per second (one "day"), with population, happiness, and money recalculated from the full grid state each tick.
- **Road adjacency bonus**: Residential zones produce 10 population capacity when adjacent to a road vs. 3 without, incentivizing road network planning.
- **Equilibrium-seeking population**: Population moves toward a target (min of housing and jobs+20) by at most +12/-8 per day, creating gradual growth rather than instant changes.

## Improvement & Refinement Plan

1. **Add zone upgrade system**: All zones are single-tier. Allowing upgrades (e.g., clicking an existing residential to upgrade it for more capacity at higher cost) would add mid-game depth without expanding the grid.

2. **Visualize road connections**: Roads are drawn as simple gray squares. Drawing connecting lines or intersection shapes based on adjacent road tiles would make the road network more visually clear.

3. **Add terrain variety**: Only two terrain types exist (grass and rock). Adding water, trees, or elevation would create more interesting planning challenges.

4. **Show per-tile income/cost breakdown**: Players must mentally calculate economics. Adding a tooltip when hovering over a zone showing its contribution to income and upkeep would improve the information display.

5. **Implement zone decay**: Zones never degrade. Adding a maintenance mechanic (zones deteriorating without road access, requiring periodic reinvestment) would create ongoing management challenges.

6. **Add population demand visualization**: There is no visual indicator of where people want to live. Showing demand heatmaps or icons on under-served residential areas would guide player decisions.
