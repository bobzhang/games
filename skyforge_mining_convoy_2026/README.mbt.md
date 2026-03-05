# Skyforge Mining Convoy

A side-scrolling twin-stick escort shooter set in a hazardous sky-mining zone. The player pilots a nimble combat ship tasked with protecting a convoy of three fragile mining trucks as they traverse a wide 4600x2300 world toward an exit portal. Enemies swarm from both flanks, targeting both the pilot and the trucks, creating a constant tug-of-war between offense and defense.

The core gameplay loop revolves around managing three limited resources -- health, energy, and time -- while keeping the convoy alive. Energy fuels every action: firing primary shots, activating the area-of-effect pulse, unleashing the chain-lightning storm, and boosting with overdrive. Destroying enemies drops ore pickups that restore energy and add to the score, while chaining kills without taking damage builds a combo multiplier (capped at 60) for bonus points. The convoy trucks move autonomously at increasing speeds each level, and the player must clear threats before they close in for melee bites or ranged shots.

The game features a level progression system (up to level 8) where each successive wave spawns more enemies with higher HP and faster movement. The timer shrinks and convoy speed increases, demanding tighter play. Victory on a level awards a score bonus based on remaining HP, energy, and ore collected, then advances to the next round.

## Build and Run

```bash
moon build --target native skyforge_mining_convoy_2026/
./_build/native/debug/build/skyforge_mining_convoy_2026/skyforge_mining_convoy_2026.exe
```

## Controls

- **A / Left Arrow**: Move pilot ship left
- **D / Right Arrow**: Move pilot ship right
- **W / Up Arrow**: Thrust upward (consumes energy)
- **J / Left Mouse Button**: Fire primary weapon (consumes 6 energy per shot)
- **K**: Pulse -- area-of-effect blast that damages and slows nearby enemies (40 energy, 5.8s cooldown)
- **L**: Storm -- chain-lightning targeting up to 7 nearby enemies with shock (56 energy, shares overdrive cooldown)
- **Space / Left Shift**: Overdrive -- speed boost and enhanced fire rate (52 energy, 2.2s cooldown)
- **R**: Restart current level
- **Enter / Space**: Start game / advance to next level / retry after game over
- **F11**: Toggle fullscreen
- **Touch controls**: On-screen buttons for L/R/UP movement and FIRE/PULSE/STORM/OVERDRIVE actions

## How to Play

Escort the three convoy trucks from the left side of the world to the exit portal on the far right. The trucks move automatically at a constant speed that increases each level. Enemies spawn from both sides of the convoy and will target whichever is closer -- the pilot or the trucks. Kill enemies to drop ore pickups; collect ore by flying near them to restore energy and boost your score.

Use the pulse ability (K) to damage and slow all enemies within a 240-unit radius. The storm ability (L) chains to up to 7 enemies within 420 units, shocking them and dramatically reducing their speed. Overdrive (Space/Shift) grants a brief burst of enhanced speed and doubled fire rate. All abilities consume energy, so collect ore frequently to keep your reserves up.

The round is won when at least one truck reaches the far-right edge of the world (x >= world_w - 130). The round is lost if all trucks are destroyed, the pilot's HP drops to zero, or the timer runs out. On victory, remaining HP, energy, and ore are added to the score and the next level begins with harder enemies, faster convoy speed, and a shorter timer. Levels cap at 8.

## Public API Reference

### Package `skyforge_mining_convoy_2026`

> Main entry point and sole package. Contains all types, constants, utility functions, game logic, input handling, and rendering in a single file.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width in pixels |
| `sh` | `Int` | `820` | Screen height in pixels |
| `world_w` | `Float` | `4600.0` | World width for scrolling |
| `world_h` | `Float` | `2300.0` | World height |
| `max_enemies` | `Int` | `72` | Maximum concurrent enemies |
| `max_bullets` | `Int` | `640` | Maximum concurrent bullets |
| `max_ores` | `Int` | `120` | Maximum concurrent ore pickups |
| `max_particles` | `Int` | `1600` | Maximum concurrent particles |
| `convoy_count` | `Int` | `3` | Number of trucks in the convoy |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Pilot` | `x`, `y`, `vx`, `vy`, `aim_x`, `aim_y`, `hp`, `energy`, `fire_cd`, `pulse_cd`, `overdrive_t`, `overdrive_cd`, `hit_cd`, `flash_t`, `shake_t`, `ore`, `score`, `combo` | Player ship state including position, velocity, aim direction, resources, cooldowns, and scoring |
| `Truck` | `active`, `x`, `y`, `vx`, `hp`, `flash_t` | Convoy truck with position, health, and damage flash timer |
| `Enemy` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `hp`, `fire_cd`, `bite_cd`, `slow_t`, `shock_t` | Enemy entity with type (0=basic, 1=ranged), AI state, and status effects |
| `Bullet` | `active`, `from_player`, `x`, `y`, `vx`, `vy`, `dmg`, `life` | Projectile with ownership flag, velocity, damage, and lifetime |
| `Ore` | `active`, `x`, `y`, `value`, `t`, `life` | Ore pickup dropped by killed enemies with score value and decay timer |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `size`, `t`, `life`, `kind` | Visual particle with type-based coloring (0=fire, 1=blue, 2=purple) |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value between low and high bounds |
| `randf` | `(Float, Float) -> Float` | Returns a random float in the given range using raylib RNG |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Computes squared distance between two 2D points |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside an axis-aligned rectangle |
| `emit_particle` | `(FixedArray[Particle], Float, Float, Float, Float, Float, Float, Int) -> Unit` | Emits a single particle into the first available pool slot |
| `burst_particles` | `(FixedArray[Particle], Float, Float, Int, Float, Int) -> Unit` | Emits multiple particles in random directions from a point |
| `spawn_bullet` | `(FixedArray[Bullet], Int, Bool, Float, Float, Float, Float, Float, Float) -> Unit` | Creates a bullet in the first available pool slot |
| `spawn_ore` | `(FixedArray[Ore], Float, Float, Int) -> Unit` | Creates an ore pickup at the given position with a 24-second lifetime |
| `spawn_enemy` | `(FixedArray[Enemy], Int, Float) -> Unit` | Spawns an enemy near the convoy; kind probability and HP scale with level |
| `init_wave` | `(FixedArray[Enemy], Int, Float) -> Unit` | Clears all enemies and spawns an initial batch (14 + level*4) |
| `draw_bar` | `(Int, Int, Int, Int, Float, Color, Color) -> Unit` | Draws a filled progress bar with foreground/background colors |
| `draw_touch_controls` | `(Bool) -> Unit` | Renders on-screen touch control buttons for mobile-style input |
| `main` | `() -> Unit` | Entry point: initializes window, allocates object pools, runs game loop |

## Architecture

### Package Structure

```
skyforge_mining_convoy_2026/
├── main.mbt              — All game code: types, constants, utilities, logic, input, rendering
└── moon.pkg              — Package config with raylib and math imports
```

This game uses a single-file architecture where all structs, constants, helper functions, game logic, input handling, and rendering are contained in `main.mbt`. The main function uses a closure-based `reset_round` for level initialization and a monolithic game loop that processes input, updates physics, runs collision detection, and draws everything in sequence.

### Data Flow

1. **Input**: `is_key_down`/`is_key_pressed` and `is_mouse_button_down` are polled each frame, combined with touch-region hit testing via `inside_rect` for on-screen controls.
2. **Update**: The pilot's velocity is computed from input with acceleration, drag, and gravity. Cooldowns tick down. Abilities (fire, pulse, storm, overdrive) are triggered based on input flags and resource checks. Trucks advance at `convoy_speed`. Enemies chase the nearest target (pilot or truck) with speed modifiers from slow/shock debuffs. Bullets move and check collisions via `dist2`. Dead enemies spawn ore via `spawn_ore`; ore collection restores energy. Particles decay over their lifetime.
3. **State transitions**: State 0 = title, state 1 = playing, state 2 = convoy delivered (win), state 3 = convoy lost (game over). Win condition: any truck reaches `world_w - 130`. Loss: all trucks dead, pilot HP <= 0, or timer expires.
4. **Rendering**: Camera follows the lead truck with `cam_x` offset. Background layers use parallax scrolling. All entities are drawn as circles/rectangles with world-to-screen coordinate transformation (`x - cam_x + shake_x`). HUD overlays show HP, energy, overdrive bars, score, combo, and timer.

### Key Design Patterns

- **Object pool pattern**: All entities (enemies, bullets, ores, particles) use pre-allocated `FixedArray` pools with `active` flags, avoiding runtime allocation.
- **Integer state machine**: Game state is an `Int` (0-3) rather than an enum, driving title/play/win/loss screens.
- **Closure-based reset**: The `reset_round` lambda captures all mutable game state for clean level transitions.
- **Delta-time clamping**: Frame time is capped at 0.033s to prevent physics explosions on lag spikes.
- **Dual-targeting AI**: Enemies dynamically choose between pilot and nearest truck based on proximity (threshold 260 units), creating escort tension.
- **Screen shake**: Hit feedback applies random offsets (`shake_x`, `shake_y`) to all world-space rendering when the pilot takes damage.

## Improvement & Refinement Plan

1. **Extract game state into a struct**: All mutable variables (`level`, `timer`, `spawn_cd`, `convoy_speed`, `state`, `announce_t`) are currently loose locals in `main`. Wrapping them in a `Game` struct would improve readability and make `reset_round` a method instead of a closure.

2. **Replace integer state with an enum**: `state` is an `Int` (0-3) checked via `==`. A `GameState` enum (`Title`, `Play`, `Win`, `Lost`) would make the state machine self-documenting and prevent invalid state values.

3. **Separate rendering from game logic**: The monolithic game loop interleaves update logic and draw calls. Splitting into `update(dt)` and `draw()` functions would improve maintainability and enable potential headless testing.

4. **Add truck HP bars**: Trucks have `hp` fields that decay under attack, but the player has no visual feedback about individual truck health. Drawing small HP bars above each truck (using the existing `draw_bar` function) would improve situational awareness.

5. **Deduplicate cooldown tick-down code**: The pattern `if x > 0.0 { x = x - dt; if x < 0.0 { x = 0.0 } }` is repeated ~10 times for pilot and enemy cooldowns. A helper `tick_down(ref, dt)` function would reduce boilerplate.

6. **Balance storm ability sharing overdrive cooldown**: Currently `storm_press` checks `pilot.overdrive_cd <= 0.0`, meaning storm and overdrive share the same cooldown. This may be intentional but is not communicated to the player; adding distinct cooldown tracking or clearer HUD indication would help.

7. **Add enemy kind variety**: Only two enemy kinds exist (0=basic melee, 1=ranged shooter). Adding a third type (e.g., a fast kamikaze or a shield-bearing tank) would increase tactical depth in later levels.

8. **Implement ore magnet radius**: Currently ore must be collected within a tight 34-unit radius. Adding a larger attraction radius where ore drifts toward the pilot would reduce tedious collection and reward aggressive play.
