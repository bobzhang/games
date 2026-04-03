# RTS Skirmish 2026

RTS Skirmish 2026 is a minimalist real-time strategy game played across three horizontal lanes. The player and an AI opponent each start with a base (320 HP) on opposite sides of the screen, training workers for economic income and deploying combat units to push down the enemy base. The visual style is simple and functional, with colored circles representing units and rectangular bases.

The core gameplay loop revolves around economic management and unit deployment. Workers generate 5 resources per second each, and the player must balance investing in more workers (long-term income) versus spending on combat units (immediate military pressure). Two unit types are available: swordsmen (melee, 34 HP, 7 attack, 26 range, 58 speed, costs 70) and rangers (ranged, 24 HP, 9 attack, 120 range, 46 speed, costs 90). Units auto-march toward the enemy base in their assigned lane, engage the nearest enemy, and deal double attack damage to the base if they reach the end.

The AI produces units on a 1.3-second timer with probabilistic decision-making: 20% chance to train a worker, 50% chance to spawn a swordsman, and 30% chance to spawn a ranger, all dependent on available resources. Killing enemy units awards 8 resources as a bounty.

## Build and Run

```bash
moon build --target native rts_skirmish_2026/
./_build/native/debug/build/rts_skirmish_2026/rts_skirmish_2026.exe
```

## Controls

- **1**: Select lane 1 (top)
- **2**: Select lane 2 (middle)
- **3**: Select lane 3 (bottom)
- **Q**: Train a worker (costs 45 resources, permanently increases income by 5/sec)
- **W**: Spawn a swordsman in the selected lane (costs 70 resources)
- **E**: Spawn a ranger in the selected lane (costs 90 resources)
- **R**: Restart the match

## How to Play

Both sides start with 2 workers and 120 resources. Workers passively generate 5 resources per second each (ticking every 1.0 second). Your goal is to destroy the enemy base (320 HP) while protecting your own.

Spend resources strategically:
- **Workers** (Q, 45 res): Invest in long-term economy. Each worker adds 5 resources/second permanently.
- **Swordsmen** (W, 70 res): Melee fighters with 34 HP, 7 attack, and 26-unit range. They are tankier but must get close.
- **Rangers** (E, 90 res): Ranged attackers with 24 HP, 9 attack, and 120-unit range. They deal more damage but are fragile.

Select a lane (1/2/3) before spawning units. Units auto-march toward the enemy base at their speed value. When an enemy is within range in the same lane, units stop and attack every 0.6 seconds. If a unit reaches the opposite end (x > sw-80 for player units, x < 80 for enemy units), it damages the base by attack * 2 and is removed.

Killing an enemy unit awards 8 resources as a bounty to the killer's team. The game ends when either base reaches 0 HP.

## Public API Reference

### Package `rts_skirmish_2026`

> Main entry point. Single-file RTS game with unit management, AI, and rendering.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1080` | Screen width in pixels |
| `sh` | `Int` | `700` | Screen height in pixels |
| `lanes` | `Int` | `3` | Number of combat lanes |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Unit` | `alive`, `team`, `kind`, `lane`, `x`, `hp`, `atk`, `range`, `speed`, `cooldown` | A combat unit with team affiliation (0=player, 1=enemy), type (0=swordsman, 1=ranger), lane assignment, position, stats, and attack cooldown |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `lane_y` | `(Int) -> Int` | Converts a lane index (0-2) to a screen y-coordinate (180 + lane * 170) |
| `spawn_unit` | `(Array[Unit], Int, Int, Int) -> Bool` | Spawns a new unit for the given team, kind, and lane in the first available pool slot; returns false if pool is full |
| `closest_enemy` | `(Array[Unit], Int) -> Int` | Finds the index of the nearest living enemy in the same lane, or -1 if none exists |

## Architecture

### Package Structure

```
rts_skirmish_2026/
├── main.mbt              -- Entry point: all types, game logic, AI, rendering, and main loop
└── moon.pkg              -- Package config with raylib import
```

This is a compact single-file RTS game (~368 lines). The code flows from constants and type definitions, through unit spawning and targeting functions, to the main loop containing input handling, economic simulation, AI decision-making, unit update logic, and rendering.

### Data Flow

1. **Input**: Keys 1/2/3 set `lane_select`. Keys Q/W/E check resource availability and call `spawn_unit` or increment `player_workers`.
2. **Economy**: A 1.0-second `gather_tick` timer adds `workers * 5` resources to both player and enemy each tick.
3. **AI**: A 1.3-second `enemy_ai_tick` timer triggers probabilistic production: 20% worker, 50% swordsman, 30% ranger (with resource checks).
4. **Unit update**: Each living unit finds its `closest_enemy` in the same lane. If within range, it attacks on a 0.6s cooldown, dealing `atk` damage. If not, it marches toward the enemy base. Units reaching the base boundary deal `atk * 2` to the base and are removed.
5. **Win/lose**: Base HP <= 0 triggers game over.
6. **Rendering**: Lanes drawn as green-tinted rectangles with the selected lane highlighted in yellow. Units shown as colored circles (skyblue/lime for player, maroon/orange for enemy) with HP numbers above.

### Key Design Patterns

- **Object pool**: 240 pre-allocated `Unit` slots with `alive` flags avoid dynamic allocation during gameplay.
- **Lane-based combat**: Units only interact with enemies in the same lane, simplifying targeting via `closest_enemy` filtering by `lane`.
- **Probabilistic AI**: The enemy AI uses random rolls to decide between economic and military investment, creating varied opponent behavior.
- **Resource economy**: A simple worker-based economy where each worker generates fixed income, creating a classic RTS "econ vs aggro" tradeoff.

## Improvement & Refinement Plan

1. **Add unit count display**: There is no indication of how many units are alive per lane. A per-lane unit count in the HUD would help with tactical decisions about which lane to reinforce.

2. **Implement unit variety**: Only two unit types exist (swordsman and ranger). Adding a third type (e.g., cavalry with high speed and moderate stats) or unit upgrades would increase strategic depth.

3. **Scale AI difficulty**: The AI uses fixed parameters (1.3s timer, 20/50/30 production split). Scaling these based on elapsed time or score differential would create progressive difficulty.

4. **Add attack animations**: Units attack silently with no visual feedback. Drawing a brief line between attacker and target, or a damage flash on the target, would make combat more readable.

5. **Extract game state into a struct**: Variables like `player_base_hp`, `enemy_base_hp`, `player_workers`, `enemy_workers`, `player_res`, `enemy_res` are separate mutable locals. A `GameState` struct would centralize state and simplify the restart logic.

6. **Add resource generation indicator**: The per-second income (`workers * 5`) is not displayed. Showing "Income: X/sec" next to the resource count would help players understand their economic growth rate.

7. **Implement lane-specific strategy feedback**: The AI spawns units in random lanes. A more sophisticated AI that detects which lanes are underdefended and targets them would create more interesting gameplay dynamics.
