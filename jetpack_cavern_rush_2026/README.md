# Jetpack Cavern Rush 2026

A side-scrolling shooter where you pilot a jetpack through procedurally generated caverns, collecting crystals while fighting cave-dwelling enemies. Reach the exit portal with enough crystals to clear each level.

## Build and Run

```bash
cd examples && moon build --target native jetpack_cavern_rush_2026/
cd examples && ./_build/native/debug/build/jetpack_cavern_rush_2026/jetpack_cavern_rush_2026.exe
```

## Controls

- **W/Up**: Thrust (jetpack, costs fuel)
- **A/D or Left/Right**: Horizontal movement
- **J or Mouse Click**: Fire weapon (auto-aim toward mouse)
- **K**: Pulse wave (AoE slow + damage, cooldown)
- **L**: Lightning storm (chain damage to nearby enemies, cooldown)
- **Space/Shift**: Dash (brief speed burst + invulnerability)
- **R**: Restart level
- **F11**: Toggle fullscreen
- **Touch buttons**: On-screen controls for all actions

## How to Play

Fly through a randomly generated cavern using your jetpack. Collect scattered crystals to meet the quota, then reach the exit portal at the far end. Two enemy types chase you -- small fast biters and large ranged shooters. Fuel regenerates slowly and is consumed by thrust, firing, and abilities. Hitting cave walls damages you. Build kill combos for bonus score. Levels get progressively harder with more enemies and tighter crystal quotas across 8 stages.

## Public API Reference

### Package `jetpack_cavern_rush_2026`

> Main entry point and single-file game implementation.

The `main` function initializes the window (1280x820), generates a procedural cave, populates crystals and an initial enemy wave, and runs the frame loop. Each frame reads input, updates game state, and renders all layers.

#### Types

| Type | Description |
|------|-------------|
| `Player` | Player state: position, velocity, aim direction, HP, fuel, fire/pulse/storm/dash cooldowns, hit/flash/shake timers, crystal count, score, and combo. |
| `Enemy` | Enemy record with pooling flag, immutable kind (0=biter, 1=shooter), position, velocity, HP, fire and bite cooldowns, and status effect timers (burn, slow, shock). |
| `Projectile` | Projectile with pooling flag, kind, player/enemy origin flag, position, velocity, damage, and remaining lifetime. |
| `Crystal` | Collectible crystal with pooling flag, fixed position, point value, and spin animation timer. |
| `Particle` | Visual particle with pooling flag, physics, size, age, lifetime, and kind for color selection. |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to `[lo, hi]`. |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer to `[lo, hi]`. |
| `randf` | `(Float, Float) -> Float` | Returns a random float in `[lo, hi]` using raylib RNG. |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Returns squared distance between two points. |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point lies inside a rectangle (for touch input). |
| `sample_line` | `(FixedArray[Float], Float) -> Float` | Interpolates a cave boundary array at a given world x-coordinate. |
| `generate_cave` | `(FixedArray[Float], FixedArray[Float]) -> Unit` | Procedurally fills top and bottom cave boundary arrays using a clamped random walk. |
| `emit_particle` | `(FixedArray[Particle], Float, Float, Float, Float, Float, Float, Int) -> Unit` | Activates an inactive particle slot with given parameters. |
| `burst_particles` | `(FixedArray[Particle], Float, Float, Int, Float, Int) -> Unit` | Emits `count` particles radiating outward with randomized direction. |
| `spawn_projectile` | `(FixedArray[Projectile], Int, Bool, Float, Float, Float, Float, Float, Float) -> Unit` | Activates an inactive projectile slot with all fields. |
| `init_crystals` | `(FixedArray[Crystal], FixedArray[Float], FixedArray[Float], Int) -> Unit` | Places crystals across the cave, activating `target + 20` of them. |
| `spawn_enemy` | `(FixedArray[Enemy], Int, Float, FixedArray[Float], FixedArray[Float]) -> Unit` | Activates an inactive enemy ahead of the player with level-scaled HP. |
| `init_wave` | `(FixedArray[Enemy], Int, Float, FixedArray[Float], FixedArray[Float]) -> Unit` | Clears all enemies and spawns an initial batch scaled by level. |
| `draw_bar` | `(Int, Int, Int, Int, Float, Color, Color) -> Unit` | Draws a progress bar filled to `ratio` in foreground color on background. |
| `draw_touch_controls` | `(Bool) -> Unit` | Renders on-screen touch control buttons if `show` is true. |
| `main` | `() -> Unit` | Entry point: initializes window, generates cave, runs game loop. |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width in pixels. |
| `sh` | `Int` | `820` | Screen height in pixels. |
| `seg_w` | `Float` | `40.0` | Width of each cave segment in world units. |
| `seg_count` | `Int` | `210` | Number of horizontal cave segments. |
| `world_w` | `Float` | `8400.0` | Total world width (seg_w * seg_count). |
| `world_h` | `Float` | `820.0` | World height matching screen height. |
| `max_enemies` | `Int` | `64` | Enemy pool size. |
| `max_projectiles` | `Int` | `620` | Projectile pool size. |
| `max_crystals` | `Int` | `120` | Crystal pool size. |
| `max_particles` | `Int` | `1600` | Particle pool size. |

## Architecture

All game logic is in `main.mbt`. Key patterns:
- **State machine**: An integer `state` variable (0=title, 1=playing, 2=win, 3=dead) drives logic branches and overlay rendering. The current level (1–8) tracks progression.
- **Main data structures**: The `Player` struct holds all player state. Five `FixedArray` pools (enemies, projectiles, crystals, particles) with `active` flags handle all entities. Two `FixedArray[Float]` arrays (`cave_top`, `cave_bottom`) define the procedural level geometry.
- **Delta-time updates**: All physics (thrust, gravity, drag, projectile motion, enemy AI) are scaled by `dt` for frame-rate independence.
- **Camera scrolling**: A single `cam_x` offset tracks the player's horizontal position and is applied to all world-space draw calls.
- **Procedural generation**: `generate_cave` uses a clamped random walk each level to produce a unique cave layout with varying gap sizes.

## Improvement & Refinement Plan

1. **Replace integer state with an enum**: The `state` variable uses magic integers (0–3). A `GameState` enum (`Title`, `Playing`, `Win`, `Dead`) would eliminate invalid states and improve readability.

2. **Extract entity update logic into dedicated functions**: The main game loop is a large monolithic block. Splitting player update, enemy update, projectile update, crystal collection, and collision resolution into named functions would improve navigability and testability.

3. **Add persistent level seeds**: Cave generation currently uses raylib's global RNG state which is not seeded repeatably. Adding a seed value that increments with level would allow players to replay or share specific cave layouts.

4. **Improve enemy variety**: Both enemy kinds share similar movement code. Adding distinct AI strategies (e.g., swarming biters that patrol a segment, shooters that strafe sideways while firing) would create more tactical gameplay.

5. **Add a fuel pickup**: Currently fuel regenerates passively. Placing limited fuel canisters near crystal clusters would create a risk/reward loop for fuel management and reduce passive waiting.

6. **Implement progressive difficulty tuning**: Level scaling currently only affects enemy count and HP. Introducing narrower cave gaps, faster projectiles, and reduced fuel regeneration at higher levels would create a more pronounced difficulty curve.

7. **Add screen-shake on wall collision**: Cave wall impacts deal damage but have no visual feedback beyond HP loss. A brief shake and particle burst on collision would improve game feel significantly.
