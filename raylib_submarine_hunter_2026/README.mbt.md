# Submarine Hunter 2026

Submarine Hunter 2026 is a side-scrolling underwater combat game where the player commands a submarine defending against endless waves of enemy submarines approaching from the right side of the screen. The game takes place in a deep ocean environment with surface and depth bands rendered as horizontal layers.

The core gameplay loop involves maneuvering the player submarine within the left half of the screen, firing torpedoes rightward to intercept incoming enemies, and using a sonar ping ability to reveal stealthy submarines. Enemy submarines vary in durability (1 or 2 HP) and 45% of them are stealthy, appearing as barely visible shadows until a sonar ping is activated. Enemies fire their own torpedoes back at the player and slowly drift vertically while advancing. Enemies that escape past the left edge of the screen deal 6 hull damage, while direct torpedo hits deal 11 damage.

The scoring system rewards stealth kills with 70 points versus 45 for regular kills, encouraging strategic use of the sonar ability. The game is an endurance challenge with no win condition -- the player fights until hull integrity reaches zero.

## Build and Run

```bash
moon build --target native raylib_submarine_hunter_2026/
./_build/native/debug/build/raylib_submarine_hunter_2026/raylib_submarine_hunter_2026.exe
```

## Controls

- **W / Up Arrow**: Move up
- **A / Left Arrow**: Move left
- **S / Down Arrow**: Move down
- **D / Right Arrow**: Move right
- **J / Space**: Fire torpedo (0.18-second cooldown, travels rightward at 420 units/sec)
- **K**: Activate sonar ping (reveals all stealth enemies for 1.4 seconds, 4-second cooldown)
- **R**: Restart mission

## How to Play

The player submarine starts at position (170, 370) in the left portion of the screen. Movement is constrained to the left half of the screen (x: 40-580) and below the surface (y: 150 to screen bottom minus 40).

Enemy submarines spawn from the right edge every 0.75 seconds, moving leftward at speeds between -150 and -90 units/second with random vertical drift. Each enemy has either 1 or 2 HP (25% chance of 2 HP). Stealth enemies (45% of spawns) appear as very faint shapes unless a sonar ping is active.

Fire torpedoes with J or Space. Player torpedoes travel rightward at 420 units/second. A hit reduces enemy HP by 1; when HP reaches 0, the submarine is destroyed and awards score (70 points for stealth enemies, 45 for regular). Enemies fire back every 2-4 seconds with torpedoes traveling leftward at 300 units/second.

Hull damage occurs from two sources: enemy torpedoes hitting the player (11 damage, detected within 20 pixels) and enemies escaping past the left screen edge (6 damage). The mission ends when hull integrity drops to 0.

Press K to activate sonar, which reveals all stealth enemies for 1.4 seconds with expanding green rings centered on the player. The sonar has a 4-second cooldown. Time sonar pings carefully to reveal clusters of stealth submarines for efficient torpedo fire.

## Public API Reference

### Package `raylib_submarine_hunter_2026`

> Main entry point and complete game implementation.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1160` | Screen width in pixels |
| `sh` | `Int` | `740` | Screen height in pixels |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Torpedo` | `alive`, `x`, `y`, `vx` | Torpedo projectile with position and horizontal velocity; used for both player and enemy torpedoes |
| `Enemy` | `alive`, `x`, `y`, `vx`, `hp`, `shoot_cd`, `stealth` | Enemy submarine with position, speed, hit points (1-2), firing cooldown, and stealth flag |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `spawn_torpedo` | `(Array[Torpedo], Float, Float, Float) -> Unit` | Activates the first inactive torpedo in the pool with given position and velocity |
| `spawn_enemy` | `(Array[Enemy]) -> Unit` | Spawns a new enemy at the right screen edge with random depth, speed, HP, fire rate, and stealth chance |
| `reset_torpedoes` | `(Array[Torpedo]) -> Unit` | Deactivates all torpedoes in a pool |
| `reset_enemies` | `(Array[Enemy]) -> Unit` | Deactivates all enemies |
| `dist_sq` | `(Float, Float, Float, Float) -> Float` | Computes squared distance between two 2D points |

## Architecture

### Package Structure

```
raylib_submarine_hunter_2026/
├── main.mbt              -- Entry point, game loop, all logic and rendering
└── moon.pkg              -- Package config with raylib import
```

Single-file game with all entity management, physics, collision detection, and rendering in `main.mbt`.

### Data Flow

1. **Input**: WASD/arrows for movement (continuous), J/Space for firing (held with cooldown), K for sonar ping (pressed with cooldown).

2. **Update**:
   - Player position updated with constant speed (220 horizontal, 180 vertical), clamped to left half and below surface
   - Cooldowns decrement: `fire_cd`, `sonar_cd`, `sonar_active`
   - Enemy spawn timer increments; at 0.75 seconds, `spawn_enemy` creates a new enemy
   - Enemies move leftward with random vertical drift; fire torpedoes when `shoot_cd` expires
   - Enemies escaping left edge: deactivated with 6 hull damage
   - Player torpedoes: move right, deactivate off-screen
   - Enemy torpedoes: move left, deactivate off-screen; check proximity to player (20-pixel radius) for 11 hull damage
   - Player torpedo vs enemy collision: `dist_sq` within 19-pixel radius, reduce enemy HP, destroy on 0 HP

3. **Render**: Background with surface band (blue) and deep band (dark blue), horizontal depth lines, sonar rings when active, enemies as ellipses (red when visible, faint when stealthy), player/enemy torpedoes as colored rectangles, player submarine as ellipse with tower, HUD with score/kills/hull bar/sonar cooldown.

### Key Design Patterns

- **Object pool pattern**: Three separate pools for player torpedoes (90), enemy torpedoes (120), and enemies (80), each using `alive` flag for activation.
- **Stealth mechanic with sonar reveal**: Enemy `stealth` flag controls visibility; `sonar_active` timer temporarily overrides stealth, creating a reveal/hide cycle.
- **Asymmetric play area**: Player is restricted to the left half of the screen while enemies approach from the right, creating a defensive gameplay style.
- **Shared Torpedo struct**: Both player and enemy projectiles use the same `Torpedo` struct, differentiated only by pool membership and velocity direction.

## Improvement & Refinement Plan

1. **Add depth charge weapon**: Currently only horizontal torpedoes are available. A depth charge that sinks vertically and explodes in an area would add tactical variety, especially for stealthy enemies below the player.

2. **Implement difficulty scaling**: Enemy spawn rate (0.75s), speed range, and fire rate are static. Gradually increasing these based on kills or time survived would create a proper difficulty curve.

3. **Add visual effects for hits and explosions**: Destroying an enemy just sets `alive = false` with no visual feedback. Adding particle bursts or explosion animations using a particle pool would make combat more satisfying.

4. **Implement enemy variety**: All enemies behave identically (move left, shoot periodically). Adding types such as fast torpedo boats, mine-layers, or boss submarines would increase gameplay depth.

5. **Add minimap or radar display**: With 80 potential enemies and stealth mechanics, a corner minimap showing detected enemy positions would help with situational awareness beyond the sonar ping window.

6. **Extract collision detection into reusable functions**: The main loop contains inline collision checks for player-torpedo/enemy-torpedo/torpedo-player. A generic `check_circle_collision` function would reduce duplication.

7. **Add hull repair mechanic**: The game is pure attrition with no way to recover hull. Dropping repair pickups from destroyed enemies would extend gameplay sessions and reward aggressive play.
