# Mech Arena Duel 2026

A top-down arena shooter where you pilot a mech against escalating waves of enemy bots. Move with WASD, aim with the mouse, and fire projectiles to destroy all bots in each wave. The game features weapon heat management, a dash ability with cooldown, and wave-based difficulty scaling where each successive wave spawns more bots with higher HP.

The player's mech has 120 HP, fires projectiles at 540 units/second toward the mouse cursor, and generates 8 heat per shot (overheating at 100 disables firing). Heat cools at 14 units/second. Enemy bots move in bouncing patterns at 120 units/second, have HP scaling with wave number (20 + wave * 2), and fire aimed shots at the player every 1-3 seconds at 340 units/second. Destroying all bots in a wave awards a bonus of 70 + wave * 10 points and spawns the next wave with 3 + wave_number bots. Contact with bots deals 8 damage, enemy shots deal 9 damage, and each kill awards 26 + wave points.

## Build and Run

```bash
moon build --target native raylib_mech_arena_duel_2026/
./_build/native/debug/build/raylib_mech_arena_duel_2026/raylib_mech_arena_duel_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Move the mech (230 units/second)
- **Mouse**: Aim direction for shooting
- **Left Mouse Button / J**: Fire weapon (0.14s cooldown, generates heat)
- **K**: Dash in current movement direction (140-unit burst, 3s cooldown)
- **R**: Restart the game

## How to Play

You start in the center of the arena facing Wave 1 with 4 enemy bots. Move with WASD, aim at enemies with the mouse, and hold left-click or J to fire. Your weapon has a 0.14-second fire cooldown and generates 8 heat per shot. Heat dissipates at 14/s, but if it reaches 100, you cannot fire until it cools down.

Press K to dash in your current movement direction for a 140-unit burst (3-second cooldown). This is useful for dodging incoming fire.

Enemy bots (red squares) move in bouncing patterns and fire aimed shots (orange circles) at your mech every 1-3 seconds. Your shots (skyblue circles) deal 12 damage per hit. Bots have 20 + wave * 2 HP and die when HP reaches 0.

Destroy all bots to complete a wave. You receive a wave bonus (70 + wave * 10 points) and the next wave spawns with 3 + wave_number bots, each with more HP. The game ends when your HP reaches 0.

## Public API Reference

### Package `raylib_mech_arena_duel_2026`

> Main entry point and complete game implementation (single-file game).

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1120` | Screen width in pixels |
| `sh` | `Int` | `740` | Screen height in pixels |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Shot` | `alive`, `x`, `y`, `vx`, `vy`, `from_enemy` | A projectile with position, velocity, and owner flag (player or enemy) |
| `Bot` | `alive`, `x`, `y`, `hp`, `fire_cd`, `dir_x`, `dir_y` | An enemy bot with position, health, fire cooldown, and movement direction |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `spawn_shot` | `(Array[Shot], Float, Float, Float, Float, Bool) -> Unit` | Activates the first inactive shot in the pool with position, velocity, and enemy flag |
| `spawn_bot` | `(Array[Bot], Int) -> Unit` | Activates the first inactive bot with random position, HP scaled by wave, random fire cooldown and movement direction |
| `reset_bots` | `(Array[Bot]) -> Unit` | Deactivates all bots in the pool |
| `reset_shots` | `(Array[Shot]) -> Unit` | Deactivates all shots in the pool |
| `main` | `() -> Unit` | Entry point: initializes 1120x740 window at 60 FPS, pre-allocates 260 shots and 64 bots, runs game loop with movement, shooting, AI, collision detection, wave management, and rendering |

## Architecture

### Package Structure

```
raylib_mech_arena_duel_2026/
├── main.mbt         — Complete game: structs, object pools, AI, physics, rendering
└── moon.pkg         — Package config with raylib import
```

### Data Flow

1. **Initialization**: `main` pre-allocates 260 `Shot` and 64 `Bot` objects in pools, sets player position to screen center with 120 HP, and spawns 4 bots for Wave 1.
2. **Input**: Each frame reads WASD/arrow keys for movement direction, mouse position for aim direction, left-click/J for firing, K for dashing, and R for restart.
3. **Player Update**: Player position is updated by movement direction * 230 * dt, clamped to arena bounds. Fire cooldown and overheat decay over time. Dash teleports the player 140 units in the current movement direction.
4. **Shooting**: When fire button is held, fire cooldown is expired, and heat is below 98, a new shot is spawned aimed at the mouse position with 540 units/second velocity. Each shot adds 8 heat.
5. **Bot AI**: Each alive bot moves along its direction at 120 units/second, bounces off arena walls, and fires aimed shots at the player every 1-3 seconds at 340 units/second. Contact with the player deals 8 damage and destroys the bot.
6. **Collision**: Player shots check against all alive bots (18-unit radius). Hits deal 12 damage and deactivate the shot. Enemy shots check against the player (16-unit radius). Hits deal 9 damage. Shots leaving the arena are deactivated.
7. **Wave Management**: When all bots are destroyed, a wave bonus is awarded, the wave counter increments, and 3 + wave bots spawn with higher HP.
8. **Rendering**: Draws a grid-lined arena floor, bots as red squares with HP labels, shots as colored circles (skyblue for player, orange for enemy), the player as a blue square, HUD (score, kills, wave, HP bar, heat bar, wave bonus), a message bar, and the game-over overlay.

### Key Design Patterns

- **Object pool pattern**: Both shots (260) and bots (64) use pre-allocated arrays with `alive` flags. `spawn_shot` and `spawn_bot` find the first inactive slot, avoiding dynamic allocation during gameplay.
- **Bouncing AI movement**: Bots move linearly and reverse direction on wall contact, creating unpredictable movement patterns without complex pathfinding.
- **Heat management mechanic**: The overheat system (8 heat per shot, 14/s cooldown, 100 cap) creates a fire discipline layer, preventing sustained full-auto and requiring burst-fire tactics.
- **AABB collision**: All collision checks use simple axis-aligned distance thresholds (16-18 units), appropriate for the game's grid-like visual style.
- **Wave difficulty scaling**: Both bot count (3 + wave) and bot HP (20 + wave * 2) scale linearly, creating steady difficulty progression.
- **Single-file architecture**: The entire game fits in one file with straightforward procedural flow, appropriate for an arcade shooter with simple entity types.

## Improvement & Refinement Plan

1. **Add bot variety**: All bots behave identically. Adding specialized types (fast rushers with low HP, slow tanks with high HP, snipers with long range) would create more tactical variety.

2. **Implement dash visual feedback**: The dash teleports the player instantly with no visual effect. Adding a trail, afterimage, or brief invincibility frame would make the mechanic feel more impactful.

3. **Add weapon upgrades**: The single weapon type does not change throughout the game. Collecting power-ups from destroyed bots (spread shot, piercing rounds, increased damage) would add progression within a run.

4. **Improve arena boundaries**: The arena boundary is invisible, defined only by clamping. Drawing arena walls and potentially adding obstacles or cover would enhance tactical gameplay.

5. **Add screen shake and hit flash**: Damage events have no visual impact feedback beyond a message. Adding brief screen shake on hits and flash effects on damaged entities would improve game feel.

6. **Implement scoring persistence**: High scores are not saved between sessions. Adding a high score display would give players a target to beat.

7. **Add sound effects**: The game has no audio. Adding firing sounds, hit impacts, explosion effects for bot destruction, and alarm sounds for low HP would significantly improve the experience.
