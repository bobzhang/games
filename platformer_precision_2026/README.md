# Platformer Precision 2026

Platformer Precision 2026 is a side-scrolling 2D precision platformer built with MoonBit and raylib. The player controls a small blue character traversing a long obstacle course of floating platforms, ground-level spike traps, and bottomless pits, with the goal of reaching a yellow finish marker at the far right of the level.

The course is a single continuous level spanning approximately 4200 pixels horizontally, featuring 12 elevated platforms at progressively increasing heights and 8 spike hazards placed along the ground floor. A horizontal scrolling camera follows the player, and 4 checkpoints are spaced throughout the course so that dying (from spikes or falling off-screen) only costs progress back to the last checkpoint reached. A death counter tracks total failures. Reaching x-position 3780 triggers the victory screen.

The game is implemented as a single-file architecture with straightforward integer-based physics: fixed horizontal velocity of 6 pixels/frame, gravity of 1 pixel/frame^2 with a terminal velocity of 20, and a jump impulse of -19. Platform collisions use AABB overlap testing with separate X and Y resolution passes to prevent tunneling.

## Build and Run

```bash
moon build --target native platformer_precision_2026/
./_build/native/debug/build/platformer_precision_2026/platformer_precision_2026.exe
```

## Controls

- **A / Left Arrow**: Move left
- **D / Right Arrow**: Move right
- **Space / W / Up Arrow**: Jump (when grounded)
- **R**: Full restart (resets checkpoint, deaths, and position)

## How to Play

Run and jump across the scrolling course of brown platforms, avoiding red spike traps on the ground and bottomless pits below the screen. The course features 12 elevated platforms at increasing heights, requiring progressively longer and more precise jumps. Four checkpoints are placed at x-positions 80, 1000, 2050, and 3000 -- passing each one updates your respawn point. Touching a spike or falling off the bottom of the screen (y > 700) triggers a death: the player respawns at the last checkpoint and the death counter increments.

The yellow goal marker is at x-position 3800. Reaching x >= 3780 triggers the "COURSE CLEARED" victory screen. Press R to restart the entire course from the beginning with zero deaths.

There is no score beyond the death counter -- the implicit challenge is to complete the course with as few deaths as possible, making this a pure test of platforming precision.

## Public API Reference

### Package `platformer_precision_2026`

> Main entry point and sole package. Contains all game logic in a single file.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1100` | Screen width in pixels |
| `sh` | `Int` | `700` | Screen height in pixels |

#### Structs

| Struct | Fields | Description |
|--------|--------|-------------|
| `Platform` | `x : Int`, `y : Int`, `w : Int`, `h : Int` | A rectangular platform defined by position and dimensions |
| `Spike` | `x : Int`, `y : Int`, `w : Int`, `h : Int` | A rectangular spike hazard defined by position and dimensions |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `hit` | `(Int, Int, Int, Int, Int, Int, Int, Int) -> Bool` | AABB collision test between two rectangles defined by (x, y, w, h) pairs |

## Architecture

### Package Structure

```
platformer_precision_2026/
├── main.mbt    — All game logic: init, input, physics, collision, rendering
└── moon.pkg    — Package config with raylib import
```

This is a single-file game with all logic in `main`. The `main` function contains the entire game loop: initialization, input handling, physics simulation, collision detection, checkpoint management, death/respawn logic, camera calculation, and rendering.

### Data Flow

1. **Input**: Each frame reads `KeyLeft`/`KeyA` and `KeyRight`/`KeyD` to set horizontal velocity (`vx`) to -6 or 6. Jump is triggered by `KeySpace`/`KeyUp`/`KeyW` when grounded.
2. **Grounded check**: Iterates all platforms to detect if the player's bottom edge is within 14 pixels of a platform's top edge (with 2-pixel inset for X overlap), setting a `grounded` flag.
3. **Physics**: Gravity adds 1 to `vy` each frame (capped at 20). A new position `(nx, ny)` is computed from velocity.
4. **Collision resolution**: Two separate passes resolve collisions -- first for horizontal movement (adjusting `nx`), then for vertical movement (adjusting `ny` and zeroing `vy`). This two-pass approach prevents diagonal tunneling.
5. **Checkpoint/death**: After position is finalized, the game checks if the player has passed any checkpoint x-positions, then checks for spike collisions and out-of-bounds death. Deaths respawn at the last checkpoint.
6. **Camera**: `cam_x` is set to `px - 350`, clamped to [0, 3100], creating a horizontal scroll that keeps the player roughly centered.
7. **Rendering**: Platforms are drawn as brown rectangles, spikes as red rectangles, the goal as a yellow rectangle, and the player as a blue rectangle, all offset by `-cam_x`.

### Key Design Patterns

- **Single-file architecture**: The entire game fits in one 243-line file, appropriate for a simple precision platformer with no complex state management.
- **Integer physics**: All positions and velocities are integers, giving pixel-perfect, deterministic movement without floating-point precision issues.
- **Two-pass collision resolution**: Horizontal and vertical collisions are resolved in separate passes against the full platform list, preventing corner-case tunneling.
- **Checkpoint array**: A simple `Array[Int]` of x-positions with a current checkpoint index provides lightweight save-point functionality.

## Improvement & Refinement Plan

1. **Add coyote time and jump buffering**: The current grounded check is strict -- the player must be exactly on a platform to jump. Adding a small coyote-time window (a few frames after walking off an edge) and input buffering (accepting jump presses slightly before landing) would make the controls feel more responsive, which is critical for a precision platformer.

2. **Implement variable jump height**: Currently the jump impulse is a fixed `vy = -19`. Checking `is_key_released(KeySpace)` and halving `vy` when positive would allow short hops for fine control, a standard feature in precision platformers.

3. **Add visual checkpoint indicators**: Checkpoints are invisible in the current rendering code -- only the HUD text shows the current checkpoint number. Drawing markers (flags, colored lines) at each checkpoint x-position would help players understand their progress through the course.

4. **Replace magic numbers with named constants**: Values like `6` (move speed), `-19` (jump force), `1` (gravity), `20` (terminal velocity), `3780` (win threshold), and `700` (death y) are hardcoded throughout `main`. Extracting these to named `let` bindings at the top would improve readability and tuning.

5. **Add a timer display**: A precision platformer benefits from speedrun incentives. Adding an elapsed-time counter displayed in the HUD alongside the death counter would give players a secondary metric to optimize.

6. **Improve spike visibility**: Spikes are 10-pixel-tall red rectangles on the ground, which can be hard to see. Drawing them as triangles or adding a warning pattern would improve visual clarity and reduce unfair deaths.
