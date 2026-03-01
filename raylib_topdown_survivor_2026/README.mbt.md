# Topdown Survivor 2026

A minimalist top-down auto-shooting survival game inspired by the Vampire Survivors genre. You control a character (rendered as a blue circle) on a dark green field, dodging an ever-growing swarm of red enemies that spawn from the screen edges and chase you relentlessly. Your weapon fires automatically at the nearest enemy, so the core skill is movement and positioning.

The gameplay loop is simple but compelling: enemies spawn from random edges at an accelerating rate, chase the player, and deal contact damage (1 HP per frame of overlap). Killing enemies grants 1 XP each, and filling the XP bar triggers a level-up screen where the player chooses one of three upgrades: faster fire rate, increased bullet damage, or improved movement speed with bonus HP. The spawn rate starts at 1.1 seconds and decreases by 0.0025 per spawn down to a minimum of 0.28 seconds, creating mounting pressure over time.

The goal is to survive for 180 seconds (3 minutes). Enemy speed scales with elapsed time (base 52 + time * 1.5 + random 0-12), making late-game enemies significantly faster than early ones. The game's simplicity makes it an excellent example of a complete game loop in under 440 lines of MoonBit.

## Build and Run

```bash
moon build --target native raylib_topdown_survivor_2026/
./_build/native/debug/build/raylib_topdown_survivor_2026/raylib_topdown_survivor_2026.exe
```

## Controls

- **W / Up Arrow**: Move up
- **A / Left Arrow**: Move left
- **S / Down Arrow**: Move down
- **D / Right Arrow**: Move right
- **1**: Level-up upgrade: Faster fire rate (fire cooldown * 0.84, min 0.12s)
- **2**: Level-up upgrade: More bullet damage (+3)
- **3**: Level-up upgrade: Speed (+26) and HP (+10)
- **R**: Restart game

## How to Play

The game starts immediately. Move your blue circle to avoid red enemies that spawn from the screen edges and chase you. Your character auto-fires at the nearest enemy -- no aiming required.

**Combat:**
- Bullets fire at the nearest enemy with a starting cooldown of 0.50s, speed of 430, and damage of 7.
- Bullets have a 1.2-second lifetime and disappear on hit or screen exit.
- Enemies have 8-16 HP, so weaker ones die in 1-2 shots while tougher ones take 3.
- Contact with enemies drains 1 HP per frame, so getting swarmed is quickly fatal.

**Progression:**
- Each enemy kill grants 1 XP. The first level-up requires 12 XP, with the threshold increasing by 7 per level.
- On level-up, the game pauses and presents three upgrade choices:
  - **1 - Faster fire**: Reduces fire cooldown by 16% (multiplicative, min 0.12s)
  - **2 - More damage**: Adds +3 bullet damage
  - **3 - Speed + HP**: Adds +26 movement speed and +10 max HP (also heals +10)

**Win condition:** Survive for 180 seconds (3 minutes).
**Lose condition:** HP reaches 0.

## Public API Reference

### Package `raylib_topdown_survivor_2026`

> Single-file game with all types, logic, and rendering in main.mbt.

All structs and functions are package-private. Key internal types and functions are documented below.

#### Structs (package-private)

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Enemy` | `alive`, `x`, `y`, `hp`, `speed` | A chasing enemy with position, health, and individual speed |
| `Shot` | `active`, `x`, `y`, `vx`, `vy`, `dmg`, `ttl` | An auto-fired bullet with velocity, damage, and time-to-live |

#### Functions (package-private)

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between bounds |
| `spawn_enemy` | `(Array[Enemy], Float) -> Unit` | Spawns an enemy at a random screen edge with time-scaled speed and random HP (8-16) |
| `fire_shot` | `(Array[Shot], Float, Float, Float, Float, Float, Int) -> Unit` | Creates a bullet traveling from (x,y) toward (tx,ty) with given speed and damage |

#### Constants (package-private)

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | 1000 | Screen width |
| `sh` | `Int` | 700 | Screen height |

#### Key Game Variables (inside main)

| Variable | Initial Value | Description |
|----------|--------------|-------------|
| `hp` / `max_hp` | 100 / 100 | Player health |
| `move_speed` | 210.0 | Player movement speed |
| `fire_cd` | 0.50 | Fire cooldown interval in seconds |
| `bullet_speed` | 430.0 | Bullet travel speed |
| `bullet_dmg` | 7 | Bullet damage per hit |
| `spawn_rate` | 1.1 | Initial spawn interval, decreases over time |
| `xp_need` | 12 | XP threshold for next level-up, increases by 7 per level |
| Enemy pool | 260 | Maximum simultaneous enemies |
| Shot pool | 220 | Maximum simultaneous bullets |

## Architecture

### Package Structure

```
raylib_topdown_survivor_2026/
├── main.mbt    — Single-file game: types, spawning, auto-fire, movement, upgrades, rendering
└── moon.pkg    — Package config with raylib import
```

This is a compact single-file game (~438 lines) with no internal package structure. All game state is managed via local mutable variables inside the `main` function.

### Data Flow

1. `main` allocates enemy (260) and shot (220) pools and initializes player variables.
2. Each frame:
   - Input: WASD/arrows set a direction vector, normalized for diagonal movement, then multiplied by `move_speed * dt`. Player is clamped to screen bounds.
   - Spawning: A timer counts down; on expiry, `spawn_enemy()` places an enemy at a random screen edge with time-scaled speed.
   - Auto-fire: The nearest alive enemy is found via linear scan. If the fire timer has elapsed, `fire_shot()` creates a bullet aimed at that enemy.
   - Bullet update: Bullets move by velocity * dt, check lifetime and screen bounds, then test collision with each enemy (radius 14).
   - Enemy update: Enemies move toward the player at their individual speed. If within radius 20, they deal 1 HP of contact damage per frame.
   - XP/Level: When `xp >= xp_need`, the `selecting` flag pauses gameplay and shows upgrade choices.
3. Win at 180 seconds survived, lose at HP <= 0.

### Key Design Patterns

- **Auto-Fire System**: The player never manually aims or shoots. The game automatically targets the nearest enemy each fire cycle, making movement the sole player skill.
- **Object Pool Pattern**: Fixed arrays with boolean active flags for enemies (260 slots) and shots (220 slots).
- **Time-Scaled Difficulty**: Enemy speed scales linearly with `survive_time * 1.5`, and spawn rate decreases from 1.1s toward 0.28s, creating a smooth difficulty ramp.
- **Multiplicative Upgrade Scaling**: The fire rate upgrade uses a multiplicative factor (0.84x per level), creating diminishing returns that prevent extreme values while remaining impactful.
- **Pause-on-Level-Up**: The `selecting` boolean pauses all game logic while the upgrade menu is shown, preventing unfair damage during the choice.

## Improvement & Refinement Plan

1. **Add particle effects for kills and hits**: Enemy deaths and bullet impacts have no visual feedback. Adding burst particles (as seen in other games in this collection) would make combat more satisfying.

2. **Implement enemy variety**: All enemies are identical red circles with random HP/speed. Adding 2-3 enemy types (e.g., fast/weak, slow/tanky, ranged) would increase tactical depth and make upgrade choices more meaningful.

3. **Add a damage invincibility window**: Contact damage is applied every frame, meaning touching an enemy even briefly costs multiple HP. A brief invincibility period (e.g., 0.1-0.2 seconds) after taking damage would make contact less punishing and give the player time to dodge away.

4. **Add more upgrade options**: The three upgrade paths (fire rate, damage, speed+HP) are always the same. Adding variety (multi-shot, piercing bullets, area damage, health regeneration) would make each run feel different.

5. **Scale bullet damage with enemy HP growth**: Enemy HP is random (8-16) and does not scale with time, while spawn rate and speed increase. Late-game enemies become dangerous primarily due to speed and numbers, but adding HP scaling would make damage upgrades more valuable.

6. **Add a score display**: The game tracks `survive_time` and `level` but has no explicit score. Adding a score based on kills, time survived, and level reached would give players a metric to compare runs.

7. **Extract types and logic into packages**: While the game's simplicity suits a single file, extracting `Enemy`/`Shot` structs and game logic into internal packages would make the code more consistent with the collection's architecture patterns and enable documentation of public APIs.

8. **Add touch/mobile input support**: Unlike other games in this collection, there are no on-screen touch controls. Adding a virtual D-pad would make the game playable on touch devices.
