# Train Dispatch 2026

Train Dispatch is a real-time routing puzzle game where players toggle track switches to guide color-coded cargo trains to their correct destination stations. Red and blue trains spawn from both edges of a 4-lane rail network and must exit on specific lanes determined by their cargo color and travel direction.

The gameplay demands quick spatial reasoning under pressure. Three vertical switches positioned along the tracks can swap trains between adjacent lane pairs (switch 1: lanes 1-2, switch 2: lanes 2-3, switch 3: lanes 3-4). Trains approach the switches from either direction, and each switch only affects a train once per crossing. The challenge escalates as trains spawn every 0.95 seconds from random lanes and directions, creating situations where routing one train correctly may derail another.

The routing rules are direction-dependent: right-moving red cargo targets lane 1 (top) while right-moving blue targets lane 4 (bottom); left-moving trains swap these targets. This creates an inherently conflicting puzzle where the same switch setting cannot satisfy all trains simultaneously. Correct deliveries build a combo multiplier (+3 per combo), while wrong-lane exits and train collisions cost lives and reset the combo.

## Build and Run

```bash
moon build --target native raylib_train_dispatch_2026/
./_build/native/debug/build/raylib_train_dispatch_2026/raylib_train_dispatch_2026.exe
```

## Controls

- **1**: Toggle switch 1 (swaps trains between lanes 1 and 2)
- **2**: Toggle switch 2 (swaps trains between lanes 2 and 3)
- **3**: Toggle switch 3 (swaps trains between lanes 3 and 4)
- **R**: Restart game

## How to Play

Trains spawn every 0.95 seconds on random lanes, traveling in a random direction (left or right) with random speed (130-210). Each train carries either red or blue cargo.

**Routing rules:**
- Right-moving red cargo must exit on lane 1 (top), right-moving blue cargo on lane 4 (bottom)
- Left-moving red cargo must exit on lane 4 (bottom), left-moving blue cargo on lane 1 (top)
- Station indicators on the left and right edges show which color belongs where

**Switches:** Three vertical switch lines cross all lanes. When a switch is ON (green), any train crossing it swaps between the two lanes the switch controls. When OFF (red), trains pass through unchanged. Each train can only be affected by each switch once.

**Scoring:** Correct deliveries earn 12 + combo * 3 points. Wrong-lane exits cost 8 points and one life, resetting the combo. Train collisions (same lane, distance < 44px) destroy both trains, cost 2 lives and 25 points, and reset the combo.

**Game over:** Occurs when lives reach zero (start with 5). Press R to restart.

## Public API Reference

### Package `raylib_train_dispatch_2026`

> Main entry point and complete game implementation.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Train` | `alive`, `x`, `lane`, `dir`, `speed`, `cargo`, `gate_mask` | A train moving across lanes; `cargo` is 0 (red) or 1 (blue); `gate_mask` tracks which switches have been applied |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `lane_y` | `(Int) -> Float` | Returns the vertical pixel position for a given lane index |
| `spawn_train` | `(Array[Train], Bool, Int, Int) -> Unit` | Activates an unused train slot with given direction, lane, and cargo type |
| `gate_bit` | `(Int) -> Int` | Returns the bitmask bit for a given switch index (0, 1, or 2) |
| `apply_gate` | `(Train, Int, Bool) -> Unit` | Applies a switch to a train if not already applied; swaps lane if switch is enabled |
| `target_lane` | `(Int, Int) -> Int` | Returns the target exit lane for a given direction and cargo type |
| `reset_trains` | `(Array[Train]) -> Unit` | Deactivates all trains in the pool |
| `train_color` | `(Int) -> Color` | Returns red or skyblue color based on cargo type |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | 1200 | Window width |
| `sh` | `Int` | 760 | Window height |
| `lanes` | `Int` | 4 | Number of rail lanes |

#### Game Variables (in `main`)

| Variable | Type | Initial | Description |
|----------|------|---------|-------------|
| `gate0` | `Bool` | true | Switch 1 state (lanes 1-2) |
| `gate1` | `Bool` | false | Switch 2 state (lanes 2-3) |
| `gate2` | `Bool` | true | Switch 3 state (lanes 3-4) |
| `score` | `Int` | 0 | Current score |
| `combo` | `Int` | 0 | Current delivery combo streak |
| `lives` | `Int` | 5 | Remaining lives |

## Architecture

### Package Structure

```
raylib_train_dispatch_2026/
├── main.mbt              -- Complete game: structs, switch logic, spawning, collision, rendering
└── moon.pkg              -- Package config (is-main, imports raylib)
```

This is a single-file game with all logic in `main.mbt`.

### Data Flow

1. Input: Keys 1/2/3 toggle the boolean state of `gate0`/`gate1`/`gate2`.
2. Spawning: A timer (`spawn_tick`) counts up; at 0.95s intervals, a new train is placed on a random lane with random direction and cargo.
3. Movement: Each alive train updates `x` by `dir * speed * dt`.
4. Switch application: As a train crosses each switch X position (430, 600, 770), `apply_gate` checks the `gate_mask` bitmask to ensure the switch only fires once per train. If the switch is ON, the train swaps between the two lanes the switch controls.
5. Exit check: When a train reaches x < 40 or x > sw - 40, its lane is compared to `target_lane(dir, cargo)`. Correct match adds score and combo; incorrect costs life.
6. Collision: All alive train pairs on the same lane are checked for proximity (dx < 44). Collisions destroy both trains and cost 2 lives.

### Key Design Patterns

- **Object pool pattern**: 80 train slots are pre-allocated with `alive` flags.
- **Bitmask gate tracking**: Each train's `gate_mask` field uses bit flags (1, 2, 4) to track which of the three switches have already been applied, preventing double-application.
- **Direction-dependent routing**: The `target_lane` function and `apply_gate` logic create an asymmetric puzzle where the same switch setting has different effects on left-moving vs right-moving trains.
- **Single-file architecture**: All code in `main.mbt` suits the game's focused scope.

## Improvement & Refinement Plan

1. **Add visual train trajectory preview**: Players must mentally trace which lane a train will end up on. Drawing a faint path line showing the predicted exit lane based on current switch states would reduce trial-and-error.

2. **Implement escalating spawn difficulty**: Currently trains spawn at a fixed 0.95s interval. Decreasing the interval or increasing speed over time (e.g., every 20 deliveries) would create progressive challenge.

3. **Add sound effects for switch toggles and deliveries**: The game is silent. Audio cues for switch changes (click), correct delivery (chime), wrong delivery (buzz), and collisions (crash) would improve feedback.

4. **Extract gate application logic for testability**: The `apply_gate` function modifies train state in-place. A pure function returning the new lane would be easier to unit test and reason about.

5. **Display upcoming trains**: Adding a preview indicator showing the next train's color and direction before it spawns would give players a moment to prepare switch configurations.

6. **Add scoring tier display**: The combo system exists but is only shown in status messages. A persistent combo counter and bonus multiplier in the HUD would make the reward loop more visible.
