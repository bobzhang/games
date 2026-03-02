# raylib_fishing_tycoon_2026

A fishing simulation tycoon game. Move your boat across the water surface, cast your hook to catch fish of varying rarity, sell catches to earn gold, and upgrade your equipment over multiple in-game days.

## Build and Run

```bash
moon build --target native raylib_fishing_tycoon_2026/
./_build/native/debug/build/raylib_fishing_tycoon_2026/raylib_fishing_tycoon_2026.exe
```

## Controls

- **A/D or Left/Right**: Move boat horizontally
- **Space**: Drop/raise hook
- **R**: Restart

## How to Play

- Position your boat and drop the hook into the water
- Fish swim across the screen at different depths -- common (green), silver (blue), and golden (rare)
- The hook catches a fish when it touches one while descending
- Reel the hook back up to land the catch and earn gold
- Use gold to upgrade hook depth, reel speed, and rare fish chance
- Each day has a timer; maximize profit before the day ends

## Public API Reference

### Package `tonyfettes/raylib-examples/raylib_fishing_tycoon_2026`

#### Types and Structs

- **`struct Fish`** — Represents one fish in the pool. Fields: `alive : Bool`, `x : Float`, `y : Float`, `vx : Float`, `kind : Int` (0 = common, 1 = silver, 2 = golden), `size : Float`.

#### Functions

- **`fn fish_color(kind : Int) -> @raylib.Color`** — Returns the display colour for a fish kind: lime (common), skyblue (silver), gold (golden).
- **`fn fish_value(kind : Int) -> Int`** — Returns the gold reward for catching a fish: 18 (common), 42 (silver), 88 (golden).
- **`fn spawn_fish(fishes : Array[Fish], rare_bonus : Int) -> Unit`** — Activates the first idle slot in the pool. Fish kind is chosen by a weighted roll adjusted by `rare_bonus`; entry direction and speed are randomised.
- **`fn reset_fishes(fishes : Array[Fish]) -> Unit`** — Marks every fish in the pool as inactive without clearing position data.
- **`fn main`** — Entry point. Opens the window (1100 x 720), runs the game loop, and calls `@raylib.close_window()` on exit.

#### Constants (module-level `let` bindings)

| Name | Value | Description |
|------|-------|-------------|
| `sw` | `1100` | Window width in pixels |
| `sh` | `720` | Window height in pixels |

## Architecture

### Package Structure

```
raylib_fishing_tycoon_2026/
└── main.mbt          # All structs, helpers, game loop, and rendering (374 lines)
```

### Data Flow

Input is read every frame inside `fn main`. Boat position is updated directly from keyboard state; the hook state machine (`hook_state`: 0 idle, 1 dropping, 2 rising) advances the hook position at `drop_speed` (240 px/s) and `reel_speed` (280 px/s, upgradeable). Fish positions are integrated with their `vx` velocities and culled when they leave the screen bounds.

The spawn timer fires every 0.42 seconds and picks the first inactive `Fish` slot in a pool of 90, assigning kind via a weighted roll that shifts toward rarer fish as `rare_bonus` increases (each Bait+ upgrade adds 8, capped at 34). Collision detection is a simple radius check between the hook circle and each live fish's `size * 0.8` radius.

When the hook returns to the surface with a captured fish, the fish's value is computed by `fish_value`, added to `money`, and the slot is freed. Upgrades are purchased inline with key presses 1/2/3 and modify `reel_speed`, `max_depth`, or `rare_bonus` immediately. The 180-second `day_timer` counts down each frame; reaching zero sets `over = true` and freezes all updates.

Rendering is immediate-mode: background rectangles simulate sky and water depth gradients, fish are drawn as ellipses with triangular tails, and the HUD texts (money, catch count, time) are redrawn every frame from the mutable state variables.

### Key Design Patterns

- **Object pooling** — A fixed `Array[Fish]` of size 90 is allocated once; `spawn_fish` scans for the first `alive == false` slot, eliminating per-frame heap allocation.
- **Hook state machine** — The single `hook_state` integer (0/1/2) drives all hook physics; state transitions are guarded by depth and position comparisons rather than timers.
- **Weighted random spawning** — The rarity roll uses the expression `roll < 62 - rare_bonus` so a single integer upgrade variable continuously biases the distribution without requiring a lookup table.
- **Delta-time clamped loop** — `dt` is capped at 0.05 s per frame to prevent large physics steps from tunnelling the hook or fish through boundaries during lag spikes.
- **Upgrade side-effects** — Each upgrade key directly mutates the relevant float variable (`reel_speed`, `max_depth`, `rare_bonus`) in the same scope as the money deduction, keeping upgrade logic self-contained.
- **Monolithic main loop** — All game logic and rendering live inside `fn main`, which removes inter-package coupling overhead and keeps the single-file structure easy to follow for a short game.

## Improvement & Refinement Plan

1. **Separate fish speed scaling by kind** — Currently all fish share the same `get_random_value(60, 130)` speed range. Golden fish should move faster (e.g. 100–180 px/s) to make them harder to intercept and justify their higher value.
2. **Per-upgrade cost scaling** — All three upgrades have fixed costs. Introducing incremental cost increases (e.g. Reel+ costs 90, 140, 200 for successive purchases) would maintain economic tension throughout a longer session.
3. **Depth-stratified fish distribution** — Fish spawn at `get_random_value(220, sh - 70)` uniformly. Stratifying by kind (common near the surface, golden near `max_depth`) would reward the Depth+ upgrade more meaningfully.
4. **Multi-day progression** — The day ends at 180 s but there is no carry-over mechanic. Persisting money between days with escalating upgrade costs and faster fish speeds would create a tycoon loop.
5. **Hook collision while rising** — The `captured_idx` check only fires when `hook_state != 0`. A fish that swims into the rising hook's path is not catchable. Enabling capture on the rising phase would add a skill element.
6. **Visual feedback for upgrade limits** — When `rare_bonus` reaches 34 or `max_depth` hits `sh - 30`, there is no HUD indication that the upgrade is maxed. Greying out the upgrade label would prevent wasted key presses.
7. **Sound and screen-shake on catch** — There is no audio or camera feedback when a fish is hooked. A brief screen shake and a sound cue would improve game feel without requiring structural changes.
