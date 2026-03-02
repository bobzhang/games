# Power Grid Operator 2026

A real-time power grid management simulation where players operate three power plants to satisfy fluctuating electricity demand across four city sectors. The game presents a continuous balancing challenge: keep total supply close to total demand or face cascading penalties from blackouts and overheating equipment.

Each sector has an independently varying demand value (40-190 range) that drifts over time with random trends and noise. Players must continuously adjust three plant outputs (each clamped 0-220) to match the combined demand. When supply falls more than 25 units below demand, outage risk accumulates; when it exceeds demand by more than 35, overheat builds. Both conditions eventually trigger penalties that cost lives and points. Maintaining a tight balance within plus or minus 15 units earns bonus points. An emergency battery reserve provides a temporary +90 supply boost on a 20-second cooldown for critical situations.

The game features an elegant risk management system where the overheat and outage accumulators act as soft timers -- players have a window to correct imbalances before penalties trigger, creating tension without instant-fail mechanics.

## Build and Run

```bash
moon build --target native raylib_power_grid_operator_2026/
./_build/native/debug/build/raylib_power_grid_operator_2026/raylib_power_grid_operator_2026.exe
```

## Controls

- **Q** (hold): Increase Plant 1 output (+2 per frame)
- **A** (hold): Decrease Plant 1 output (-2 per frame)
- **W** (hold): Increase Plant 2 output (+2 per frame)
- **S** (hold): Decrease Plant 2 output (-2 per frame)
- **E** (hold): Increase Plant 3 output (+2 per frame)
- **D** (hold): Decrease Plant 3 output (-2 per frame)
- **Space**: Activate emergency battery reserve (+90 supply for 6 seconds, 20-second cooldown)
- **R**: Restart the game

## How to Play

Four city sectors (S1-S4) each have an independent power demand that fluctuates over time. Every second, each sector's demand changes based on its current trend value plus random noise (-5 to +5). Trends themselves shift randomly (24% chance per second of changing by -3 to +3), creating unpredictable demand curves.

Adjust the three power plants (P1-P3) by holding the appropriate keys. Each plant's output is clamped between 0 and 220 and changes by 2 units per frame while a key is held. The goal is to keep total supply close to total demand.

The game tracks two stress accumulators:
- **Outage Risk**: Increases when supply is more than 25 below demand; the rate scales with the severity of the shortage. When it reaches 12.0, you lose a life and 35 points.
- **Overheat**: Increases when supply exceeds demand by more than 35; the rate scales with excess. When it reaches 100.0, you lose a life and 45 points (overheat resets to 28, not zero).

Both accumulators decay naturally when the grid is balanced, giving a recovery window. Keeping the balance within -15 to +15 earns +1 bonus point per frame. Base score increases by +6 every second.

The emergency battery reserve (Space) adds +90 to supply for 6 seconds with a 20-second cooldown. Use it to bridge sudden demand spikes. The game starts with 5 lives; reaching zero triggers grid collapse.

## Public API Reference

### Package `raylib_power_grid_operator_2026`

> Main entry point and complete game implementation.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1140` | Screen width in pixels |
| `sh` | `Int` | `740` | Screen height in pixels |
| `sector_n` | `Int` | `4` | Number of city sectors with independent demand |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Sector` | `demand`, `trend` | Represents a city sector with current power demand and drift trend |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clamp_int` | `(Int, Int, Int) -> Int` | Clamps an integer value between low and high bounds |
| `total_demand` | `(Array[Sector]) -> Int` | Sums the demand values across all sectors |
| `total_supply` | `(Array[Int], Float) -> Int` | Sums all plant outputs, adding +90 if emergency battery is active |
| `reset_sector_values` | `(Array[Sector]) -> Unit` | Randomizes each sector's demand (70-130) and trend (-8 to 8) |

## Architecture

### Package Structure

```
raylib_power_grid_operator_2026/
├── main.mbt       — Entry point, game loop, all logic, rendering, and input handling
└── moon.pkg       — Package config with raylib import
```

This is a single-file game with all logic in `main.mbt`. Helper functions for clamping, demand/supply calculation, and sector reset are defined at the top level, while the `main` function contains the game loop with initialization, input, update, and rendering phases.

### Data Flow

1. **Input**: The game checks for held keys (not just pressed) using `is_key_down` for plant adjustments, and `is_key_pressed` for the emergency battery. Plant outputs are clamped via `clamp_int` after each adjustment.
2. **Sector Update**: Every 1.0 seconds (tracked by `tick` accumulator), each sector's demand is updated with `trend + noise`, and trends may randomly shift. Score increases by +6 per tick.
3. **Balance Check**: Each frame, `total_demand` and `total_supply` are computed. The difference drives the overheat and outage accumulators, which increase or decay based on thresholds.
4. **Penalty Resolution**: When `outage_acc >= 12.0` or `overheat >= 100.0`, a life is lost and the accumulator is reset (or partially reset for overheat).
5. **Render**: Bar charts display sector demands and plant outputs, stress bars show overheat and outage risk, and the HUD displays balance, score, and lives.

### Key Design Patterns

- **Dual-accumulator stress system**: Overheat and outage risk are continuous float accumulators that increase and decay based on supply-demand imbalance, creating soft failure windows rather than hard thresholds.
- **Trend-based demand simulation**: Each sector has a persistent trend value that drifts randomly, creating realistic demand curves that players must anticipate and track.
- **Hold-key continuous input**: Plant outputs use `is_key_down` (held) rather than `is_key_pressed` (single press), enabling smooth analog-style control at +/-2 per frame.
- **Delta-time clamping**: Frame delta time is capped at 0.05 to prevent large jumps in accumulator values.

## Improvement & Refinement Plan

1. **Extract game state into a struct**: The 10+ mutable local variables in `main` (`score`, `lives`, `overheat`, `outage_acc`, `tick`, `emergency_time`, `emergency_cd`, etc.) would benefit from being grouped into a `GridState` struct for cleaner reset logic and state management.

2. **Add sector-specific supply routing**: Currently all supply is pooled globally. Adding the ability to allocate specific plants to specific sectors would deepen the strategic layer and make the sector bar chart more meaningful.

3. **Implement demand forecast indicators**: Since sectors have a `trend` field that persists across updates, displaying trend arrows (up/down/stable) next to each sector's bar would give players actionable information and reward anticipation.

4. **Add visual feedback for balance zone**: The +/-15 bonus zone is invisible to the player. Drawing a green zone indicator on the balance display or adding a color change when inside the zone would clarify the scoring mechanics.

5. **Scale difficulty over time**: Demand ranges, trend volatility, and noise are constant throughout the game. Gradually widening sector demand bounds or increasing trend magnitude would create escalating difficulty.

6. **Add overheat partial-reset feedback**: When `overheat >= 100.0`, it resets to 28.0 rather than 0, meaning the player starts at elevated risk. This non-obvious mechanic should be communicated with a warning message or visual indicator showing residual heat.

7. **Decouple rendering from game state computation**: The `demand`/`supply`/`diff` values are computed twice per frame -- once in the update block and once before rendering. Storing them in variables before the draw phase would eliminate the redundant calculation.
