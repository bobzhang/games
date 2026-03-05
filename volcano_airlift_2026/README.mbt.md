# Volcano Airlift 2026

A side-scrolling helicopter rescue game set across three volcanic sectors. The player pilots a helicopter over erupting terrain, picking up stranded survivors one at a time and ferrying them to a base landing pad while rising lava consumes the landscape from below and ash clouds damage the aircraft.

The core gameplay loop is a careful balance of fuel management and precision flying. The helicopter has realistic-feeling physics with gravity, thrust, drag, and momentum. Lifting consumes fuel at 16 units per second, and hard landings (high vertical or horizontal speed on touchdown) deal hull damage, potentially destroying the carried survivor and resetting position. Each of the three sectors has a quota of survivors that must be rescued; completing a sector awards a star rating based on how many survivors were lost (0 lost = 3 stars, 1 lost = 2 stars, else 1 star).

The game features a procedural terrain profile defined by the `ground_y` function, creating a varied landscape of hills and valleys where survivors are placed. Ash clouds spawn from screen edges with increasing frequency per sector, adding mobile hazards to navigate around. The lava rises at a speed of 8+level*2 pixels per second, creating an ever-shrinking safe zone.

## Build and Run

```bash
moon build --target native volcano_airlift_2026/
./_build/native/debug/build/volcano_airlift_2026/volcano_airlift_2026.exe
```

## Controls

- **A / Left Arrow**: Steer helicopter left
- **D / Right Arrow**: Steer helicopter right
- **W / Up Arrow**: Lift (thrust upward, consumes fuel)
- **S / Down Arrow**: Descend faster
- **Space / J**: Pick up nearby survivor / Drop off at base
- **R**: Restart from sector 1
- **Touch LEFT/RIGHT**: On-screen directional steering (bottom-left)
- **Touch LIFT/DOWN**: On-screen vertical thrust (bottom-left)
- **Touch PICK/DROP button**: On-screen action button (bottom-right)

## How to Play

Each sector begins with survivors placed along the terrain and a base pad on the left side. The lava rises continuously from below.

**Rescue cycle**: Fly near a survivor (within 36 pixel radius) and press the action key to pick them up. Only one survivor can be carried at a time -- they hang below the helicopter visually. Fly back to the BASE pad (within 74 pixels horizontally and between 18-104 pixels above the pad) and press action again to drop them off. Each delivery scores 120 + timer/2 points.

**Hazards**: Lava rises at 8+level*2 pixels/sec, destroying any survivor it reaches (state changes to lost). Ash clouds spawn from screen edges at intervals of 0.78 - level*0.10 seconds (minimum 0.22s) and deal 1 hull damage on contact with a 1-second immunity cooldown. Hard landings (vertical speed > 110 or horizontal > 130) cost 1 hull, reset position to base, and lose the carried survivor.

**Sector progression**: Sector 1 has 4 survivors (quota 3), sector 2 has 5 (quota 4), sector 3 has 6 (quota 4). After meeting the quota with all survivors accounted for, a bonus is awarded (220 + hull*30 + fuel) and a transition timer advances to the next sector. Clearing all 3 sectors wins the game.

**Lose conditions**: Hull reaches 0, timer expires, or too many survivors are lost to meet the quota.

## Public API Reference

### Package `volcano_airlift_2026`

> Main entry point and complete game implementation.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width |
| `sh` | `Int` | `820` | Screen height |
| `max_survivors` | `Int` | `8` | Maximum survivor pool size |
| `max_clouds` | `Int` | `20` | Maximum ash cloud pool size |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Survivor` | `x`, `y`, `state` | Stranded person with position and state (0=waiting, 1=carried, 2=rescued, 3=lost) |
| `Cloud` | `x`, `y`, `vx`, `r`, `active` | Ash cloud hazard moving horizontally across the screen |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between low and high bounds |
| `absf` | `(Float) -> Float` | Returns absolute value of a float |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside a rectangle |
| `ground_y` | `(Float) -> Float` | Returns terrain height at a given x position using a piecewise linear profile |
| `clear_survivors` | `(Array[Survivor]) -> Unit` | Resets all survivors to lost/inactive state |
| `set_survivor` | `(Array[Survivor], Int, Float, Float) -> Unit` | Places a survivor at a position with waiting state |
| `clear_clouds` | `(Array[Cloud]) -> Unit` | Deactivates all ash clouds |
| `spawn_cloud` | `(Array[Cloud], Int) -> Unit` | Spawns an ash cloud from a random screen edge with level-scaled speed |
| `setup_level` | `(Int, Array[Survivor], Array[Cloud]) -> (Int, Int, Float, Float, Float, Float, Float, Float)` | Configures a sector: returns (total survivors, quota, start x/y, base x/y, lava y, timer) |
| `survivors_count` | `(Array[Survivor], Int, Int) -> Int` | Counts survivors in a given state within the active total |
| `main` | `() -> Unit` | Entry point: window setup, helicopter physics, game loop across 3 sectors |

## Architecture

### Package Structure

```
volcano_airlift_2026/
├── main.mbt              — Complete game: structs, terrain, physics, rendering, main loop
└── moon.pkg              — Package config with raylib and math imports
```

The entire game is a single-file implementation. Constants and structs are at the top, followed by utility and terrain functions, level setup, and the main game loop which handles input, physics, collision, rendering, and sector transitions.

### Data Flow

1. **Input**: Keyboard state and touch regions are read each frame into boolean flags (left, right, up, down, action).
2. **Physics**: The helicopter accumulates acceleration from input (170 horizontal, 420 lift minus 220 gravity), applies drag (0.60 horizontal, 0.30 vertical), clamps velocity, and integrates position. Ground collision checks use `ground_y(hx)` to determine terrain height.
3. **Game logic**: Survivor pickup/dropoff uses distance checks. Lava rises each frame, killing any survivor whose y position is below lava_y. Cloud spawning and movement run each frame. Hull damage is tracked with a 1-second immunity window.
4. **Sector management**: `setup_level` returns a tuple of level parameters. Completing a sector triggers a 1.2s transition, after which the next sector is loaded or the game ends.
5. **Render**: Background, terrain strips, base pad, survivors by state, clouds, helicopter with rotor animation and carried survivor, lava, HUD, touch controls, and message bar.

### Key Design Patterns

- **Piecewise Linear Terrain**: `ground_y` uses a series of if-else branches to define terrain height as a function of x, creating hills and valleys without any data structures.
- **Tuple-based Level Config**: `setup_level` returns an 8-tuple containing all level parameters, avoiding the need for a dedicated level struct.
- **State Integer for Survivors**: Survivors use a simple integer state (0=waiting, 1=carried, 2=rescued, 3=lost) rather than an enum, keeping the design lightweight.
- **Screen-shake and Flash Effects**: `shake_t` and `flash_t` provide brief camera shake and background flash on damage events, adding impact feedback.
- **Star Rating System**: Stars accumulate across sectors based on survivor loss count per sector (0 lost=3, 1 lost=2, else 1).

## Improvement & Refinement Plan

1. **Add fuel pickups or refueling at base**: Fuel only depletes and never regenerates (except losing 18 on crash). Adding automatic refueling when landed at the base would reduce frustrating fuel starvation in later sectors.
2. **Replace survivor state integer with an enum**: The magic numbers 0/1/2/3 for survivor state are error-prone. Defining `enum SurvivorState { Waiting; Carried; Rescued; Lost }` would improve readability.
3. **Extract helicopter state into a struct**: Helicopter properties (hx, hy, hvx, hvy, fuel, hull, carrying, carry_idx) are scattered as mutable local variables. Grouping them into a `Helicopter` struct would improve organization.
4. **Improve terrain variety across sectors**: The `ground_y` function returns the same terrain profile regardless of sector. Making terrain sector-dependent would add visual variety and gameplay challenge.
5. **Add wind effects**: Currently only ash clouds move horizontally. Adding a wind system that affects helicopter drift would add another layer of challenge, especially in later sectors.
6. **Add intermediate landing pads**: With only one base pad, every rescue requires a round trip to the same location. Adding secondary landing pads or fuel depots would create more interesting route planning.
7. **Add visual indicator for pickup range**: The 36-pixel pickup radius is not visually communicated. A subtle circle or highlight around reachable survivors would help players judge positioning.
