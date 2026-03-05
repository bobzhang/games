# Post Office Sorter 2026

A fast-paced postal sorting simulation where players operate a conveyor-belt gate in a busy mail distribution center. Packages color-coded with four destination labels (A, B, C, D) spawn on the left side and slide rightward across four horizontal lanes. The player must position a movable sorter gate on the correct lane and horizontal position to intercept packages before they reach the end of the belt.

The core gameplay loop revolves around two simultaneous tasks: physically positioning the sorter gate using directional keys, and configuring each lane's destination mapping with the number keys. When a package hits the gate on its lane, the game checks if the lane's current destination mapping matches the package's label. Correct sorts award 28 points, wrong sorts penalize 18 points and cost a life, and missed packages that fly off the right edge cost 12 points and a life. With only 5 lives, players must balance speed and accuracy under increasing pressure as packages spawn roughly every 0.33 seconds at randomized speeds between 140 and 230 pixels per second.

The game uses an object-pool pattern for packages, pre-allocating 120 `Package` slots and recycling them with an `alive` flag, which keeps memory allocation stable throughout the session.

## Build and Run

```bash
moon build --target native post_office_sorter_2026/
./_build/native/debug/build/post_office_sorter_2026/post_office_sorter_2026.exe
```

## Controls

- **W / Up Arrow**: Move sorter gate up one lane
- **S / Down Arrow**: Move sorter gate down one lane
- **A / Left Arrow**: Shift sorter gate position left (by 44 pixels, minimum 320)
- **D / Right Arrow**: Shift sorter gate position right (by 44 pixels, maximum 760)
- **1**: Set current lane's destination mapping to A
- **2**: Set current lane's destination mapping to B
- **3**: Set current lane's destination mapping to C
- **4**: Set current lane's destination mapping to D
- **R**: Restart the game

## How to Play

Packages labeled A through D spawn on the left side of the screen and slide rightward across four horizontal lanes. Each package has a random destination code (A/B/C/D), a random lane assignment, and a random speed between 140 and 230 pixels per second. New packages spawn every 0.33 seconds.

Position the blue sorter gate on the correct lane using W/S and adjust its horizontal position with A/D. When a package enters the gate's horizontal range on the same lane, it is intercepted and sorted. The game checks whether the lane's current destination mapping matches the package's code: a correct match earns +28 points, while a mismatch costs -18 points and one life.

Each lane has a configurable destination mapping displayed on the right side. By default, lane 0 maps to A, lane 1 to B, lane 2 to C, and lane 3 to D. Use number keys 1-4 while a lane is selected to remap it. This allows strategic reconfiguration when many packages of one type cluster on a particular lane.

Packages that reach the right edge without being intercepted cost -12 points and one life. The game starts with 5 lives. When lives reach zero, the sorting line shuts down and the game ends. Press R to restart.

## Public API Reference

### Package `post_office_sorter_2026`

> Main entry point and complete game implementation.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1140` | Screen width in pixels |
| `sh` | `Int` | `720` | Screen height in pixels |
| `lane_count` | `Int` | `4` | Number of horizontal conveyor lanes |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Package` | `alive`, `x`, `y`, `lane`, `code`, `speed` | Represents a mail package on the conveyor belt with position, destination code (0-3), and movement speed |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `lane_y` | `(Int) -> Float` | Calculates the vertical screen position for a given lane index (base 220 + lane * 105) |
| `reset_packages` | `(Array[Package]) -> Unit` | Marks all packages in the pool as inactive |
| `spawn_package` | `(Array[Package]) -> Unit` | Activates the first inactive package in the pool with random lane, code, and speed |
| `code_color` | `(Int) -> @raylib.Color` | Returns the display color for a destination code (0=red, 1=skyblue, 2=lime, 3=gold) |
| `code_label` | `(Int) -> String` | Returns the string label for a destination code (0="A", 1="B", 2="C", 3="D") |

## Architecture

### Package Structure

```
post_office_sorter_2026/
├── main.mbt       — Entry point, game loop, all logic, rendering, and input handling
└── moon.pkg       — Package config with raylib import
```

This is a single-file game with all logic contained in `main.mbt`. The `Package` struct and helper functions are defined at the top level, while the `main` function contains the full game loop including initialization, input handling, update logic, and rendering.

### Data Flow

1. **Input**: `main` checks for key presses each frame to update `sorter_lane`, `sorter_x`, and `chute_map` (the lane-to-destination mapping array).
2. **Spawn**: A `spawn_tick` timer accumulates delta time and calls `spawn_package` every 0.33 seconds, which finds the first inactive `Package` in the pool and initializes it with random values.
3. **Update**: Each alive package moves rightward by `speed * dt`. If it overlaps the gate's horizontal range on the gate's lane, it is intercepted and scored. If it passes the right edge, it counts as missed.
4. **Render**: The drawing phase renders the background, lane lines, destination labels, the sorter gate, all alive packages, HUD stats, and the game-over overlay.

### Key Design Patterns

- **Object Pool**: 120 `Package` structs are pre-allocated at startup. The `alive` flag controls which are active, avoiding runtime allocation.
- **Lane-based mapping system**: The `chute_map` array maps each lane index to a destination code, allowing players to reconfigure sorting logic dynamically.
- **Delta-time movement**: Package movement is scaled by frame delta time (clamped to 0.05 max) for consistent speed regardless of frame rate.

## Improvement & Refinement Plan

1. **Extract game state into a struct**: All mutable game variables (`score`, `lives`, `sorter_lane`, etc.) are loose `let mut` bindings in `main`. Grouping them into a `GameState` struct would improve organization and make reset logic cleaner than reassigning each variable individually.

2. **Add difficulty progression**: Currently `spawn_tick` threshold (0.33s) and speed range (140-230) are fixed. Scaling these based on `score` or elapsed time would create escalating challenge and longer play sessions.

3. **Improve gate collision logic**: The gate intercepts any package on its lane within the horizontal range, but there is no visual feedback for the interception moment. Adding a brief flash or particle effect at the `code_color` of the package would improve game feel.

4. **Add lane labels on the left side**: The lanes are visually distinguished only by the destination code on the right. Adding lane numbers or labels on the left edge (near x=60) would help players orient more quickly.

5. **Prevent packages from spawning on top of each other**: `spawn_package` does not check whether another package is already at x=80 on the same lane, which can cause visual overlap. A minimum-spacing check would improve clarity.

6. **Add a high-score tracking system**: The game resets all state on R press. Preserving the best score across restarts and displaying it in the HUD would add replay motivation.

7. **Make the chute_map remapping more visible**: When a player changes a lane's mapping with 1-4, only the small colored rectangle on the right updates. A brief animation or highlight on the lane would make the remapping action more noticeable.
