# Archery Tournament 2026

A physics-based archery game where you adjust power and arc to hit moving targets at varying distances while compensating for wind.

## Build and Run

```bash
moon build --target native raylib_archery_tournament_2026/
./_build/native/debug/build/raylib_archery_tournament_2026/raylib_archery_tournament_2026.exe
```

## Controls

- **A/D or Left/Right**: Adjust shot power
- **W/S or Up/Down**: Adjust arc (vertical lift)
- **Space**: Shoot arrow
- **R**: Restart tournament

## How to Play

Aim your bow by tuning power (horizontal velocity) and arc (vertical lift), then fire. Targets move horizontally at different heights and speeds -- smaller targets are worth more points. Wind shifts periodically and affects arrow trajectory. You have 18 arrows; hit as many targets as possible to maximize your score. Build combos with consecutive hits.

## Public API Reference

### Package `raylib_archery_tournament_2026`
> Single-package game. All structs, constants, helper functions, and the main game loop live in `main.mbt`. There are no exported symbols.

#### Constants
| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1200` | Window width in pixels |
| `sh` | `Int` | `740` | Window height in pixels |
| `ground_y` | `Float` | `640.0` | Y-coordinate of the ground line; arrows deactivate on crossing it |

#### Structs
| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Arrow` | `alive, x, y, vx, vy` | The single in-flight arrow; only one can be active at a time |
| `Target` | `alive, x, y, r, vx, points` | A circular moving target; `r` is the collision radius and `points` is the score value |

#### Functions
| Function | Signature | Description |
|----------|-----------|-------------|
| `reset_targets` | `(Array[Target]) -> Unit` | Resets all four targets to their initial positions, radii, speeds, and point values |
| `main` | `() -> Unit` | Entry point: opens the window, allocates the arrow and target array, runs the game loop handling input, physics, hit detection, wind, wave reset, and rendering |

#### Target Configuration (set by `reset_targets`)
| Index | y | r | vx | points |
|-------|---|---|----|--------|
| 0 | 430.0 | 34.0 | 90.0 | 30 |
| 1 | 360.0 | 26.0 | -120.0 | 45 |
| 2 | 300.0 | 20.0 | 70.0 | 60 |
| 3 | 250.0 | 16.0 | -95.0 | 75 |

#### Gameplay Variables (local to `main`)
| Variable | Initial Value | Description |
|----------|--------------|-------------|
| `arc_power` | `500.0` | Horizontal launch velocity; clamped to [260, 760] |
| `arc_lift` | `280.0` | Vertical launch velocity (upward); clamped to [120, 460] |
| `wind` | `0.0` | Horizontal acceleration applied to the arrow each frame |
| `wind_tick` | `0.0` | Accumulator; wind re-rolls every 2.8 seconds |
| `arrows_left` | `18` | Remaining shots; game ends when this reaches 0 |
| `combo` | `0` | Consecutive hits without a miss; adds `combo * 6` bonus per hit |

## Architecture

### Package Structure
```
raylib_archery_tournament_2026/
└── main.mbt              — all constants, structs, the reset_targets helper, and the complete game loop
```

### Data Flow
1. `main` allocates one `Arrow` and an `Array[Target]` of four elements, then calls `reset_targets` to populate them.
2. Each frame input is read: A/D (or Left/Right) adjust `arc_power`, W/S (or Up/Down) adjust `arc_lift`, Space launches the arrow if `arrows_left > 0` and no arrow is in flight.
3. The wind accumulator `wind_tick` increments by `dt`; when it exceeds 2.8 s the wind value is re-randomised in [-90, 90].
4. Live targets move by `target.vx * dt` and bounce off the horizontal boundary `[760, sw-80]`.
5. The in-flight arrow integrates wind acceleration (`wind * dt * 0.28`), gravity (`620.0 * dt`), and velocity each frame. Circular hit detection against each alive target uses the squared-distance formula to avoid a square-root call.
6. A hit scores `target.points + combo * 6`, increments `combo`, and deactivates both the arrow and the target. A miss (arrow exits the screen or crosses `ground_y`) resets `combo`.
7. When all four targets are simultaneously inactive they are reset via `reset_targets` and a 50-point wave-clear bonus is added.
8. The render pass draws sky background, ground strip, the static archer figure, all alive targets with concentric ring art, the in-flight arrow as a line-plus-triangle, HUD bars for power/arc, wind indicator, score, and status messages.

### Key Design Patterns
- **Single-arrow constraint**: Only one `Arrow` struct exists; a guard on `arrow.alive` prevents firing until it lands or exits the screen, creating deliberate pacing.
- **Shared struct mutation**: Both `Arrow` and `Target` are mutable structs whose fields are updated directly each frame. No allocation occurs during play after the initial setup.
- **Wave reset instead of game over on targets**: Clearing all four targets resets them and awards a bonus rather than ending the game, giving players a reason to keep shooting efficiently even late in their arrow supply.
- **Wind as a signed horizontal force**: Wind is sampled uniformly from [-90, 90] and applied as `wind * dt * 0.28` to `arrow.vx`, making it a persistent drift rather than an instant impulse. Players must compensate by pre-angling `arc_power`.
- **Combo multiplier on hit score**: The bonus `combo * 6` grows quadratically with consecutive hits, heavily rewarding unbroken hit streaks over individual high-value targets.

## Improvement & Refinement Plan

- **Arrow trajectory preview**: Before firing, render a dotted parabolic arc computed from the current `arc_power`, `arc_lift`, and `wind` values. This gives players actionable feedback on aim without removing the skill of compensating for moving targets and would require only a short simulation loop in the render pass.
- **Multiple simultaneous arrows**: Allow queuing up to 3 arrows in flight (tracking them in a small fixed array) to give the game a faster pace and open skill expression for leading multiple targets at once.
- **Per-target hit zone scoring**: Replace the single collision radius with concentric rings (bullseye, middle, outer), awarding 100 %, 60 %, and 30 % of `target.points` respectively. The data already supports this since each target's `r` is available.
- **Wind visualisation**: Add a directional arrow or animated streaks across the sky background to make the current wind value spatially intuitive rather than just a number in the HUD.
- **Escalating difficulty across waves**: `reset_targets` always restores the same speeds and positions. Increasing `vx` and decreasing `r` slightly with each cleared wave would create a natural difficulty ramp without additional state.
- **Best-score persistence**: The current score is displayed but there is no all-time high. Saving `best_score` between sessions (or at minimum tracking it across resets within one run) would give players a concrete long-term target.
- **Sound effects**: No audio calls are present. Adding distinct sounds for arrow launch, bullseye hit, miss, and wave clear would make each action feel more satisfying with minimal code added.
