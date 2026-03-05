# Cyber Firewall Breach 2026

Cyber Firewall Breach 2026 is a side-scrolling tower defense shooter set in a cyberpunk network security theme. The player controls a firewall turret positioned on the left side of a grid-lined arena, defending a core system from waves of malware entities that approach from the right. The game spans three escalating "sectors," each lasting 42 seconds, with enemy speed and spawn rates increasing per sector.

The core mechanic balances two weapons -- a rapid-fire projectile launcher and a short-range area-of-effect pulse attack -- against a shared heat meter. Firing generates heat (9 per shot), and the pulse attack generates significant heat (22 per use) with a 2.2-second cooldown. Heat dissipates at 26 units/second, but exceeding 96 heat disables firing and exceeding 70 disables the pulse. Three enemy types provide tactical variety: small fast scouts (kind 0, 1 HP), medium enemies (kind 1, 2 HP) that deal more core damage, and large heavy enemies (kind 2, 4 HP) that split into two small scouts on death. The core starts with 280 HP and the game is lost if it reaches zero.

The game features a touch-friendly UI with on-screen directional and action buttons, making it playable on both keyboard and touch-capable devices. Visual feedback includes screen shake on core damage, flash effects, particle bursts on kills, and a grid-lined arena backdrop.

## Build and Run

```bash
moon build --target native cyber_firewall_breach_2026/
./_build/native/debug/build/cyber_firewall_breach_2026/cyber_firewall_breach_2026.exe
```

## Controls

- **W / Up Arrow**: Move turret up
- **S / Down Arrow**: Move turret down
- **Space / J**: Fire projectile (rapid fire, generates heat)
- **K / L**: Pulse attack (area damage within 162px radius, 2.2s cooldown)
- **R**: Restart / Reboot game
- **On-screen touch buttons**: UP, DOWN, FIRE, PULSE (mouse click supported)

## How to Play

The game starts at Sector 1. Enemies spawn from the right edge and move leftward toward the core (the tall cyan bar on the left). Your turret moves vertically along the core, firing projectiles rightward to intercept enemies.

Three enemy types appear with weighted randomness (56% small, 30% medium, 14% large). Small enemies (yellow circles) have 1 HP and deal 8 core damage. Medium enemies (orange rectangles) have 2 HP and deal 14 damage. Large enemies (red rectangles) have 4 HP, deal 22 damage, and split into two small fast enemies when destroyed. Enemy speed scales with sector number (base 140/114/92 + sector * 20/18/16).

Manage your heat carefully: the heat bar fills with each shot (+9) and pulse (+22), dissipating at 26/s. Firing is locked when heat exceeds 96, and pulse is locked above 70. The pulse attack hits all enemies within a 162-pixel radius of the turret for 2 damage.

Each sector lasts 42 seconds. Survive all 3 sectors to win ("Breach contained. Network secured."). If the core HP bar (starting at 280) reaches zero, the firewall collapses. Press R at any time to reboot and restart.

Spawn intervals decrease per sector: sector 1 spawns every 0.48-0.90s, sector 2 every 0.32-0.70s, and sector 3 every 0.16-0.50s.

## Public API Reference

### Package `cyber_firewall_breach_2026`

> Single-file game with all logic in main.mbt.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Enemy` | `x`, `y`, `vx`, `vy`, `hp`, `kind`, `active` | Malware entity moving leftward with kind-specific stats |
| `Shot` | `x`, `y`, `vx`, `ttl`, `active` | Player projectile traveling rightward with time-to-live |
| `Part` | `x`, `y`, `vx`, `vy`, `ttl`, `kind`, `active` | Visual particle with velocity, drag, and kind-based coloring |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value to a range |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside a rectangle (for touch input) |
| `enemy_hp` | `(Int) -> Int` | Returns HP for enemy kind (1, 2, or 4) |
| `enemy_damage` | `(Int) -> Int` | Returns core damage for enemy kind (8, 14, or 22) |
| `enemy_score` | `(Int) -> Int` | Returns score value for enemy kind (26, 46, or 90) |
| `enemy_r` | `(Int) -> Float` | Returns collision radius for enemy kind (11, 16, or 22) |
| `clear_enemies` | `(Array[Enemy]) -> Unit` | Resets all enemies to inactive state |
| `clear_shots` | `(Array[Shot]) -> Unit` | Resets all shots to inactive state |
| `clear_parts` | `(Array[Part]) -> Unit` | Resets all particles to inactive state |
| `spawn_part` | `(Array[Part], Float, Float, Float, Int) -> Unit` | Spawns a single particle with random velocity scaled by speed factor |
| `burst` | `(Array[Part], Float, Float, Int, Float, Int) -> Unit` | Spawns multiple particles at a position (explosion/hit effect) |
| `spawn_shot` | `(Array[Shot], Float, Float) -> Unit` | Fires a projectile at 700px/s with 1.7s TTL |
| `spawn_enemy` | `(Array[Enemy], Int) -> Unit` | Spawns an enemy off-screen right with kind and speed based on sector |
| `spawn_split` | `(Array[Enemy], Float, Float, Int) -> Unit` | Spawns two small fast enemies when a large enemy dies |
| `spawn_interval` | `(Int) -> Float` | Returns random spawn delay based on current sector |

#### Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `sw` | 1280 | Screen width |
| `sh` | 820 | Screen height |
| `arena_x` / `arena_y` | 210 / 118 | Arena top-left position |
| `arena_w` / `arena_h` | 1020 / 628 | Arena dimensions |
| `core_x` | 150.0 | Core X position |
| `player_x` | 132.0 | Player turret X position |
| `max_enemies` | 84 | Enemy pool size |
| `max_shots` | 180 | Shot pool size |
| `max_parts` | 220 | Particle pool size |

## Architecture

### Package Structure

```
cyber_firewall_breach_2026/
├── main.mbt    — Complete game: structs, logic, input, rendering
└── moon.pkg    — Package config (single main package)
```

This is a single-file game with all game state managed as local variables in the `main` function. The game loop handles input, physics, collision, spawning, and rendering sequentially within a single `while` loop.

### Data Flow

1. **Input**: Keyboard state is read each frame via `@raylib.is_key_down`/`is_key_pressed`. Mouse position is checked against on-screen button rectangles for touch support. Input flags (`up`, `down`, `fire`, `pulse`) are unified from both sources.
2. **Update**: Sector timer advances; when it reaches 42s, the next sector starts (or win). Player position is updated from input. Fire/pulse actions check heat thresholds and cooldowns. Enemy spawn timer ticks down and calls `spawn_enemy`. Entity positions update with velocity and boundary clamping.
3. **Collision**: Enemy-vs-core collision checks if `enemy.x <= core_x + enemy_r(kind)`. Shot-vs-enemy collision uses circle distance `dx*dx + dy*dy <= rr*rr`. The pulse attack checks all enemies within a fixed radius of the player.
4. **Rendering**: Drawn in z-order: background, grid, core bar, player turret, shots, enemies (drawn by kind with distinct shapes), particles, HUD (scores, bars, touch buttons), status message, and game-over overlay.

### Key Design Patterns

- **Object Pool Pattern**: `Enemy`, `Shot`, and `Part` arrays are pre-allocated with `Array::makei` and reused via `active` flags.
- **Heat Throttling**: The dual-weapon system shares a single heat resource that decays over time, creating a fire-vs-pulse resource management decision.
- **Sector Progression**: Three 42-second sectors with cleared entities between transitions. Difficulty scales via `spawn_interval` and enemy speed formulas.
- **Split Mechanic**: Kind-2 (large) enemies call `spawn_split` on death, spawning two fast small enemies that are harder to intercept.
- **Touch-Keyboard Parity**: All actions have both keyboard bindings and clickable screen regions, merged into unified boolean flags.

## Improvement & Refinement Plan

1. **Extract game state into a struct**: All game state is stored as ~20 mutable local variables in `main`. Consolidating into a `Game` struct would improve organization and enable extracting update/render into separate functions.

2. **Separate update and render phases**: The current `main` function mixes input, update logic, and rendering in a 650-line block. Splitting into `update(game, dt)` and `render(game)` functions would improve readability and maintainability.

3. **Add enemy approach variation**: Currently all enemies move in straight lines leftward with fixed vertical drift. Adding sine-wave or zigzag patterns would increase tactical depth and make the pulse attack more strategically important.

4. **Use an enum for enemy kind**: The `kind` field is an integer (0, 1, 2) with `enemy_hp`/`enemy_damage`/`enemy_score`/`enemy_r` all switching on it. A proper enum with associated methods would be more idiomatic and prevent invalid kind values.

5. **Add visual feedback for heat threshold**: Players cannot fire above 96 heat or pulse above 70, but the heat bar gives no visual indication of these thresholds. Drawing threshold markers on the heat bar would communicate these limits clearly.

6. **Scale core HP bar proportionally**: The core HP display uses `core_hp * 320 / 280` which assumes the starting HP is always 280. If starting HP were to change, this would break. Using a stored `max_core_hp` constant would be more robust.
