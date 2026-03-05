# Ghost Mansion Investigation 2026

A top-down survival horror investigation game where the player controls an investigator exploring a haunted mansion across three increasingly dangerous floors. The investigator must collect scattered clues while avoiding ghosts that wander the corridors and chase when alerted, all within strict time limits.

The core gameplay loop involves navigating through obstacle-filled rooms, shining a directional lantern to slow approaching ghosts, and using an EM pulse ability to stun nearby spirits. Three resource meters create tension: HP drops on ghost contact, sanity drains from proximity to ghosts, and battery powers both the lantern and sprint/pulse abilities. Collecting clues restores battery and awards score/stars, creating a risk-reward dynamic between exploring dangerous areas and conserving resources.

The mansion features hardcoded wall and furniture geometry that changes per level, with additional obstacles appearing on floors 2 and 3. Ghost detection ranges increase with level, spawning accelerates, and clue requirements grow from 8 to 12 to 16, making each floor progressively harder.

## Build and Run

```bash
moon build --target native ghost_mansion_investigation_2026/
./_build/native/debug/build/ghost_mansion_investigation_2026/ghost_mansion_investigation_2026.exe
```

## Controls

- **W / Up Arrow**: Move up
- **A / Left Arrow**: Move left
- **S / Down Arrow**: Move down
- **D / Right Arrow**: Move right
- **J / Left Shift**: Sprint (drains battery faster, 1.34x speed multiplier)
- **K**: EM Pulse (stuns ghosts within 172 unit radius, costs 24 battery, 2.6s cooldown)
- **R**: Restart game from floor 1
- **Touch D-pad**: On-screen directional controls (UP/LT/DN/RT)
- **Touch SPRINT button**: Sprint activation (bottom-right area)
- **Touch PULSE button**: EM pulse activation (bottom-right area)

## How to Play

1. **Explore the mansion**: Navigate through rooms separated by walls and furniture obstacles. Your investigator starts in the bottom-left corner of each floor.

2. **Collect clues**: Walk over glowing clue orbs to collect them. Three clue types exist (kind 0/1/2) with different colors (gold, cyan, purple) and increasing point values (95, 113, 131 points). Collecting clues also restores 8-16 battery.

3. **Avoid ghosts**: Ghosts spawn continuously with randomized timing. They wander randomly until the investigator enters their detection range (220 + level*40 + kind*22 units), then chase aggressively. Ghost contact costs 1 HP and 14 sanity, with a 1-second invulnerability window.

4. **Use your lantern**: The lantern projects a cone in your facing direction. Ghosts inside the cone move at 46% of their chase speed. The cone range is 260 units above 30% battery, shrinking to 190 units below.

5. **EM Pulse**: Press K to stun all ghosts within range for 1.6-2.5 seconds. Costs 24 battery and has a 2.6-second cooldown. Stunned ghosts are immobilized and cannot chase.

6. **Reach the exit**: Once you collect enough clues (8/12/16 for floors 1/2/3), the EXIT zone in the top-right glows green. Walk into it to complete the floor.

7. **Win/Lose**: Complete all 3 floors to solve the case. Lose if HP reaches 0, sanity reaches 0, or the floor timer expires (132/146/162 seconds per floor).

## Public API Reference

### Package `ghost_mansion_investigation_2026`

> Main entry point and all game logic in a single file.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width in pixels |
| `sh` | `Int` | `820` | Screen height in pixels |
| `max_ghosts` | `Int` | `26` | Maximum ghost pool size |
| `max_clues` | `Int` | `42` | Maximum clue pool size |
| `max_particles` | `Int` | `560` | Maximum particle pool size |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Investigator` | `x`, `y`, `vx`, `vy`, `fx`, `fy`, `hp`, `sanity`, `battery`, `pulse_cd`, `hit_cd`, `flash_t` | Player character with position, velocity, facing direction, and resource meters |
| `Ghost` | `x`, `y`, `vx`, `vy`, `speed`, `radius`, `wander_t`, `stun_t`, `alert_t`, `kind`, `active` | Enemy ghost with movement, AI state timers, and type variant |
| `Clue` | `x`, `y`, `kind`, `active` | Collectible evidence item with position and type |
| `Particle` | `x`, `y`, `vx`, `vy`, `ttl`, `kind`, `active` | Visual effect particle with time-to-live |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value between low and high bounds |
| `sqdist` | `(Float, Float, Float, Float) -> Float` | Returns squared distance between two 2D points |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a float point is inside an int-coordinate rectangle |
| `circle_hits_rect` | `(Float, Float, Float, Float, Float, Float, Float) -> Bool` | Tests circle-rectangle collision using closest-point method |
| `blocked` | `(Float, Float, Float, Int) -> Bool` | Checks if a circle at position collides with walls, boundaries, or level-specific obstacles |
| `clear_ghosts` | `(Array[Ghost]) -> Unit` | Deactivates and resets all ghosts in the pool |
| `clear_clues` | `(Array[Clue]) -> Unit` | Deactivates and resets all clues in the pool |
| `clear_particles` | `(Array[Particle]) -> Unit` | Deactivates and resets all particles in the pool |
| `spawn_particle` | `(Array[Particle], Float, Float, Float, Int) -> Unit` | Activates the first inactive particle with randomized velocity and TTL |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Spawns multiple particles at a position for visual feedback |
| `reset_player` | `(Investigator) -> Unit` | Resets investigator to starting position with full HP, sanity, and battery |
| `set_clue` | `(Array[Clue], Int, Float, Float, Int) -> Unit` | Places a clue at a specific array index with given position and kind |
| `init_clues` | `(Int, Array[Clue]) -> Int` | Initializes clue positions for a given level and returns the collection target |
| `spawn_ghost` | `(Array[Ghost], Int) -> Unit` | Activates the first inactive ghost with randomized attributes scaled by level |
| `setup_level` | `(Int, Investigator, Array[Ghost], Array[Clue], Array[Particle]) -> (Int, Float, Float)` | Initializes a floor: resets player, clears entities, returns (target, timer, ghost_spawn_base) |
| `in_lantern` | `(Investigator, Float, Float) -> Bool` | Tests if a point falls within the investigator's lantern cone based on facing direction and battery |
| `main` | `() -> Unit` | Entry point: initializes window, allocates pools, runs the main game loop |

## Architecture

### Package Structure

```
ghost_mansion_investigation_2026/
├── main.mbt              — All game logic, AI, rendering, and entry point
└── moon.pkg              — Package config with raylib and math imports
```

This is a single-file game organized top-down: constants, struct definitions, utility functions, entity management functions, level setup, AI helper (`in_lantern`), and the `main` function containing the full game loop with input handling, physics, AI updates, collision detection, clue collection, and rendering.

### Data Flow

1. **Input**: Keyboard state is read via `is_key_down`/`is_key_pressed` for WASD/arrows/J/K. Touch input maps to the same actions through `inside_rect` hit tests on on-screen button regions.

2. **Player Update**: Acceleration is computed from input direction, optionally multiplied by 1.34x for sprint. Velocity undergoes drag (2.5x per second) and is clamped to max speed (258 normal, 346 sprint). Position updates with collision rollback via `blocked()`. Battery recharges at 14/s but drains at 26/s during sprint.

3. **Ghost AI**: Each ghost has three behavioral states: wandering (random direction changes on timer), chasing (when player is within detection range, steered toward player), and stunned (velocity decays rapidly). Ghosts inside the lantern cone chase at 46% speed. Ghost-player collision deals damage with a 1-second invulnerability cooldown.

4. **Level Progression**: `setup_level` resets all entities and returns the clue target, timer, and ghost spawn rate for the current floor. When enough clues are collected and the player reaches the EXIT zone, `transition_t` triggers a 2.1-second transition before advancing to the next floor.

5. **Rendering**: Layers from back to front: background gradient, mansion floor, wall rectangles (level-dependent), exit zone, clues, ghosts (with alert rings), lantern cone (triangle), player character, particles, HUD bars, touch controls, messages, and overlay screens.

### Key Design Patterns

- **Object pool pattern**: Ghosts (26), clues (42), and particles (560) use pre-allocated arrays with `active` flags. Spawning scans for the first inactive slot.
- **Level-scaled obstacles**: The `blocked()` function adds wall rectangles conditionally based on the current level, creating progressively more complex layouts without separate level data files.
- **Cone-based lantern**: The `in_lantern` function uses dot product against the player's facing direction to create a directional flashlight cone, affecting ghost chase speed.
- **Tuple return for level setup**: `setup_level` returns `(Int, Float, Float)` to communicate the clue target, timer, and spawn rate, avoiding mutable globals.
- **Screen shake and flash**: `shake_t` offsets all rendered positions horizontally, and `flash_t` changes the background color, providing visceral feedback on ghost contact.

## Improvement & Refinement Plan

1. **Extract a GameState enum**: The game uses boolean flags (`over`, `won`) and a float (`transition_t`) to track state. A proper enum (`Playing`, `Transitioning`, `GameOver`, `Victory`) would eliminate invalid combinations and simplify the main loop branching.

2. **Externalize level geometry**: Wall rectangles are hardcoded in both `blocked()` and the rendering section, duplicated in two places. Extracting wall data into an array of rectangles per level would eliminate this duplication and make levels easier to modify.

3. **Add ghost type differentiation**: The `kind` field on `Ghost` (0/1/2) affects radius and detection range but ghosts otherwise behave identically. Giving each kind distinct behaviors (e.g., kind 2 could teleport, kind 1 could be faster but weaker to the lantern) would add strategic depth.

4. **Implement sanity recovery mechanics**: Currently, sanity only drains (from ghost proximity at 4.6 units/s per nearby ghost) with no way to restore it. Adding sanity pickups or a recovery station would prevent inevitable attrition on longer runs.

5. **Separate rendering from game logic**: The main loop interleaves update and render code in a single large block. Extracting drawing into dedicated functions (like `draw_hud`, `draw_ghosts`, `draw_player`) would improve maintainability and match the pattern used in other games in this repository.

6. **Fix battery drain during idle**: Battery recharges at 14/s unconditionally, meaning an idle player reaches 100% battery. Adding a slower passive drain or tying recharge to movement would prevent the trivial strategy of standing still to recharge.

7. **Add ghost despawning**: Ghosts are spawned continuously but never despawned, eventually filling all 26 pool slots. Implementing a maximum active ghost count or despawning ghosts far from the player would prevent late-game saturation.
