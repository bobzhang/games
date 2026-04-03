# Time Loop Arena 2026

A twin-stick arena shooter built around a time loop mechanic. You pilot a ship inside a rectangular arena, shooting enemies, dashing to dodge, and deploying chrono bombs. Every 20 seconds (or 1300 frames), the loop resets: your position returns to center, and a ghost -- an AI replay of your recorded inputs from the previous loop -- spawns to fight alongside you. Up to 4 ghost echoes can be active simultaneously, creating an army of past selves.

The core gameplay revolves around recording efficient combat loops and then benefiting from those replays. Each ghost faithfully reproduces your movement, shooting, and dashing from the loop it was recorded in. Enemies spawn from the arena edges with increasing frequency and HP, targeting the nearest entity (pilot or ghost). Combat produces energy cores that grant score and replenish your energy gauge, which fuels dashes and chrono bombs. Bullets have team allegiance -- friendly bullets (team 1) from pilot and ghosts hit enemies, while enemy bullets (team 2) damage the pilot.

The game uses a bitmask-based input recording system, storing up to 7 input flags (up, down, left, right, shoot, dash, bomb) per frame across 4 loop slots of 1300 frames each. A 240-second mission timer and the target score of 3200 define the win/loss conditions. Touch controls with on-screen D-pad and action buttons provide mobile support.

## Build and Run

```bash
moon build --target native time_loop_arena_2026/
./_build/native/debug/build/time_loop_arena_2026/time_loop_arena_2026.exe
```

## Controls

- **W / Up Arrow**: Move up
- **A / Left Arrow**: Move left
- **S / Down Arrow**: Move down
- **D / Right Arrow**: Move right
- **J (hold)**: Fire bullets in movement/aim direction (0.105s cooldown)
- **K**: Dash (velocity boost, costs 16 energy, 1.3s cooldown)
- **L**: Chrono Bomb (180-radius area damage + bullet clear, costs 26 energy, 4.8s cooldown)
- **R**: Restart run
- **Enter**: Start game / return to menu
- **F11**: Toggle fullscreen
- **Touch/Mouse**: On-screen D-pad (left side) and DASH / BOMB / FIRE buttons (right side)

## How to Play

Press Enter or tap to start. You begin at the arena center with 220 HP and 100 energy.

**Combat loop (20 seconds each):**
1. Move with WASD, hold J to fire bullets in your movement direction. Bullets auto-aim along your velocity if no directional input is active.
2. Kill enemies to earn score (34 + kind * 18 + combo * 3 per kill). Destroyed enemies have a 42% chance to drop energy cores worth 24-80 points.
3. Collect cores by touching them -- they also restore energy (value * 0.22).
4. Use **Dash (K)** for quick evasion. Costs 16 energy with a 1.3s cooldown.
5. Use **Chrono Bomb (L)** to deal 30 + level * 1.4 damage to all enemies within radius 180, stun them for 1.1s, and clear nearby enemy bullets. Costs 26 energy with a 4.8s cooldown.

**Time loop mechanic:**
- After 20 seconds or 1300 frames, the loop ends. Your input recording is saved, you return to center, and a ghost echo spawns that replays your recorded actions.
- Each subsequent loop adds another ghost (up to 4). Ghosts move, shoot, and dash based on their recorded inputs. They fire slightly weaker bullets (12 damage vs 20) with a slightly slower fire rate.
- Loop slot cycling: with 4 max loops, the oldest recording is overwritten by slot rotation (`current_slot = recorded_loops % max_loops`).

**Win condition:** Reach the target score of 3200.
**Lose conditions:** HP drops to 0, or the 240-second mission timer expires.

Energy regenerates at 12/second (max 100). Pilot max speed is 320, ghosts max speed is 270. Enemy contact deals 7 + kind * 2.2 damage. Enemy bullets deal 9 + kind * 2.4 damage.

## Public API Reference

### Package `time_loop_arena_2026`

> Single-file game with all types, logic, rendering, and input recording in main.mbt.

All structs and functions are package-private. The key internal types and functions are documented below.

#### Structs (package-private)

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Pilot` | `x`, `y`, `vx`, `vy`, `angle`, `hp`, `energy`, `fire_cd`, `dash_cd`, `bomb_cd`, `flash_t`, `score`, `combo`, `loops_cleared` | Player ship with movement, health, energy, ability cooldowns, and scoring |
| `Ghost` | `active`, `slot`, `x`, `y`, `vx`, `vy`, `angle`, `fire_cd`, `dash_cd`, `flash_t` | AI-replayed past self that reproduces recorded inputs from a specific loop slot |
| `Enemy` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `hp`, `fire_cd`, `stun_t`, `t` | Arena enemy with 3 kinds (0-2), chasing AI, and ranged attacks |
| `Bullet` | `active`, `x`, `y`, `vx`, `vy`, `dmg`, `life`, `team` | Projectile with team allegiance (1=friendly, 2=enemy) |
| `Core` | `active`, `x`, `y`, `t`, `life`, `value` | Collectible energy core dropped by destroyed enemies |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `size`, `t`, `life`, `kind` | Visual particle effect (4 kinds: blue, orange, green, pink) |

#### Key Functions (package-private)

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between bounds |
| `absf` | `(Float) -> Float` | Absolute value of a float |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two points |
| `randf` | `(Float, Float) -> Float` | Random float in range |
| `sinf_deg` | `(Float) -> Float` | Sine of an angle in degrees |
| `cosf_deg` | `(Float) -> Float` | Cosine of an angle in degrees |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Point-in-rectangle test for touch input |
| `encode_input` | `(Bool, Bool, Bool, Bool, Bool, Bool, Bool) -> Int` | Encodes 7 input flags into a bitmask integer |
| `has_flag` | `(Int, Int) -> Bool` | Checks if a bitmask contains a specific flag |
| `spawn_enemy` | `(Array[Enemy], Int) -> Bool` | Spawns an enemy at a random arena edge with level-scaled HP |
| `spawn_bullet` | `(Array[Bullet], Float, Float, Float, Float, Float, Float, Int) -> Bool` | Creates a bullet with position, velocity, damage, lifetime, and team |
| `spawn_core` | `(Array[Core], Float, Float, Int) -> Bool` | Creates an energy core pickup at a position |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Emits a burst of particles |
| `reset_actor` | `(Pilot) -> Unit` | Resets pilot position and velocity to arena center |
| `rebuild_ghosts` | `(Array[Ghost], Int, Int) -> Int` | Activates ghosts from recorded loop slots, returns ghost count |
| `clear_ghosts` | `(Array[Ghost]) -> Unit` | Deactivates all ghosts |
| `clear_enemies` | `(Array[Enemy]) -> Unit` | Deactivates all enemies |
| `clear_bullets` | `(Array[Bullet]) -> Unit` | Deactivates all bullets |
| `clear_cores` | `(Array[Core]) -> Unit` | Deactivates all cores |
| `clear_particles` | `(Array[Particle]) -> Unit` | Deactivates all particles |

#### Constants (package-private)

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` / `sh` | `Int` | 1280 / 760 | Screen dimensions |
| `arena_l` / `arena_t` / `arena_r` / `arena_b` | `Float` | 96 / 88 / 1184 / 672 | Arena boundaries |
| `center_x` / `center_y` | `Float` | 640 / 380 | Arena center position |
| `loop_seconds` | `Float` | 20.0 | Duration of each time loop |
| `max_frames` | `Int` | 1300 | Maximum recorded frames per loop |
| `max_loops` | `Int` | 4 | Maximum loop recording slots |
| `max_ghosts` | `Int` | 4 | Maximum simultaneous ghost echoes |
| `max_enemies` | `Int` | 140 | Enemy pool size |
| `max_bullets` | `Int` | 640 | Bullet pool size |
| `max_cores` | `Int` | 120 | Core pool size |
| `max_particles` | `Int` | 1000 | Particle pool size |
| `bit_up` .. `bit_bomb` | `Int` | 1, 2, 4, 8, 16, 32, 64 | Input bitmask flags |

## Architecture

### Package Structure

```
time_loop_arena_2026/
├── main.mbt    — Single-file game: types, input recording, combat, ghost replay, rendering
└── moon.pkg    — Package config with raylib and math imports
```

This is a single-file game. All logic, from input recording to ghost replay to enemy AI, lives in `main.mbt`. Local closures (`reset_run`, `on_hit`) capture mutable state variables declared in the main function scope.

### Data Flow

1. `main` allocates entity pools (pilot, ghosts, enemies, bullets, cores, particles) and the `loop_masks` input recording buffer (4 slots x 1300 frames).
2. `reset_run()` initializes all state and spawns 9 initial enemies.
3. Each frame during gameplay (state 1):
   - Input is read from keyboard and touch, then encoded via `encode_input()` and stored in `loop_masks[current_slot * max_frames + frame_idx]`.
   - Pilot physics: acceleration from input, drag (2.9x), speed cap (320), arena boundary clamping with bounce.
   - Dash and bomb abilities are processed with energy and cooldown checks.
   - Ghost replay: for each active ghost, the stored bitmask at the current frame index is decoded, and the ghost mirrors the recorded movement/shooting/dashing.
   - Enemy AI: enemies chase the nearest target (pilot or ghost), fire bullets when in range (380 units), and deal contact damage.
   - Bullet-enemy and bullet-pilot collision checks with radius-based hit detection.
   - Core collection via proximity check.
4. At frame 1300 or when loop_t reaches 0, the loop ends: `recorded_loops` increments, `rebuild_ghosts()` activates echoes from all recorded slots except the current one, and the pilot resets to center.
5. Win at score >= 3200, lose at HP <= 0 or mission_time <= 0.

### Key Design Patterns

- **Input Recording/Replay**: Each frame's input is compressed into a 7-bit integer bitmask and stored in a flat array indexed by `slot * max_frames + frame_idx`. Ghosts decode these masks during replay to reproduce the player's actions.
- **Object Pool Pattern**: Fixed-size arrays with `active` flags for all entity types. Linear scan finds free slots for spawning.
- **Team-Based Bullet System**: Bullets carry a `team` field (1=friendly, 2=enemy) that determines collision targets, allowing both pilot and ghost bullets to damage enemies.
- **Level Scaling**: A derived `level` value (`score / 520 + loops_cleared + 1`) scales enemy HP, speed, acceleration, bullet speed, damage, and spawn frequency.
- **Closure-Based State Management**: The `reset_run` and `on_hit` closures capture mutable local variables, providing a lightweight alternative to a monolithic Game struct.
- **Ghost Slot Rotation**: With `max_loops = 4`, the recording slot cycles via modulo (`recorded_loops % max_loops`), overwriting the oldest recording when all slots are full.

## Improvement & Refinement Plan

1. **Extract into internal packages**: The 1800+ line `main.mbt` handles everything from input recording to enemy AI to rendering. Splitting into `types`, `game` (with `input.mbt`, `logic.mbt`, `ghost.mbt`), and `render` packages would significantly improve maintainability.

2. **Add ghost visual differentiation**: All ghosts render identically as green circles. Assigning different hues or numbered labels per ghost slot would help the player identify which loop each echo represents, useful for strategic loop planning.

3. **Implement ghost damage/death**: Currently ghosts are invulnerable -- enemy bullets and contact damage only affect the pilot. Making ghosts damageable (with separate HP) would add stakes to positioning during recordings and make the time loop mechanic more strategic.

4. **Add a loop preview/planning phase**: The loop transitions immediately on timer expiry. Adding a brief pause showing the upcoming ghost positions and a countdown would help the player mentally plan their next 20-second recording.

5. **Replace bitmask integer division with bitwise AND**: The `has_flag()` function uses `mask / flag % 2 == 1` for flag checking, which works but is less efficient and less idiomatic than bitwise AND operations.

6. **Add sound effects for key events**: The audio device is not initialized. Adding sound for shooting, explosions, loop rewind, core pickup, and damage would greatly enhance game feel.

7. **Scale target score with loops cleared**: The fixed target score of 3200 does not adapt to player skill. Scaling the target based on the number of loops cleared or implementing a wave-based scoring system would provide better difficulty progression.

8. **Add visual indicator for loop timer**: The loop timer is shown as text ("Loop t Ns") in the HUD. A prominent circular or bar countdown visualization on the arena border would make the remaining loop time more visible during intense combat.
