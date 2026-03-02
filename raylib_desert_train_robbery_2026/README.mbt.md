# Desert Train Robbery 2026

Desert Train Robbery 2026 is a side-scrolling action-platformer set in a Wild West desert where the player controls an outlaw robbing a moving train. The game takes place on a 1280x820 pixel screen featuring a scrolling desert landscape with parallax sand dunes, railroad ties, and a convoy of 6 wagons that drift leftward at increasing speed. The player must jump between wagon rooftops, shoot patrolling sheriffs, dash to evade gunfire, and loot cargo from each wagon before time runs out.

The game spans three chapters with escalating difficulty. Chapter 1 requires 9 loot with a 128-second timer and slow train speed (-122 px/s), chapter 2 requires 13 loot with 142 seconds at -144 px/s, and chapter 3 demands 18 loot in 156 seconds at -168 px/s. Sheriffs spawn at decreasing intervals (1.18s, 0.94s, 0.72s base cooldowns) and scale in HP (2, 3, 4) and patrol speed (88, 102, 116 px/s) per chapter. The player has 6 HP, 7-round ammo with auto-reload after 1.5 seconds, a stamina-based dash (costs 22 stamina, recharges at 22/s), and can loot wagons by pressing L when standing on the roof near cargo. Stars accumulate from looting and killing sheriffs, tracking total accomplishments across all chapters.

Visual feedback includes screen shake on damage, flash effects when hit, particle bursts on kills and loot grabs, and a dynamic desert skyline with animated dune silhouettes. Touch controls provide full playability on mobile with on-screen D-pad, jump, shoot, dash, and loot buttons.

## Build and Run

```bash
moon build --target native raylib_desert_train_robbery_2026/
./_build/native/debug/build/raylib_desert_train_robbery_2026/raylib_desert_train_robbery_2026.exe
```

## Controls

- **A / Left Arrow**: Move left
- **D / Right Arrow**: Move right
- **W / Up Arrow / Space**: Jump (from ground or wagon roof)
- **J**: Shoot (fires in facing direction, 7 rounds then auto-reload)
- **K / Left Shift**: Dash (burst of speed, costs 22 stamina)
- **L**: Loot cargo from wagon (must be on roof near cargo)
- **R**: Restart game from chapter 1
- **On-screen touch buttons**: JMP, LT, RT, SHOOT, DASH, LOOT (mouse click supported)

## How to Play

The outlaw spawns at x=164 on the ground. Use A/D to move horizontally and W/Space to jump. The player has physics-based movement with acceleration (1020 px/s^2, 1380 during dash), drag (7.0 deceleration multiplier), and gravity (1180 px/s^2). Jump velocity is -596 px/s, allowing the player to reach wagon rooftops which vary in height (y=496-562).

Wagons scroll leftward continuously. When a wagon exits the left screen edge, it recycles to the right with new random dimensions (176-228px length), roof height, and 1-3 loot. Standing on a wagon roof moves the player with the train. Jump between wagons and press L near cargo to loot -- each loot grab scores 62 points and 1 star. Meet the chapter's loot target to advance.

Sheriffs spawn on random wagon rooftops and patrol toward the player at level-scaled speed. They shoot at the player when within 340px range with 0.72-1.36 second cooldowns. Sheriff bullets travel at 520 px/s; player bullets at 760 px/s. Player ammo (7 rounds) auto-reloads in 1.5 seconds after emptying. Each sheriff kill awards 78 points and 1 star.

Taking damage (from bullets or melee contact within 34px) costs 1 HP with a 0.95-second invincibility window. The player has 6 HP total. Dash provides a 0.20-second speed boost (max 418 px/s instead of 294) at the cost of 22 stamina (which regenerates at 22/s, max 100). The game is lost if HP reaches 0 or the timer expires. Complete all 3 chapters to achieve "Legendary Heist."

## Public API Reference

### Package `raylib_desert_train_robbery_2026`

> Single-file game with all logic in main.mbt.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Rider` | `x`, `y`, `vx`, `vy`, `hp`, `stamina`, `ammo`, `shoot_cd`, `reload_t`, `dash_t`, `loot_cd`, `hit_cd`, `flash_t` | Player character with position, velocity, HP (6 max), stamina (100 max), ammo (7 rounds), and cooldown timers for shooting, reloading, dashing, looting, invincibility, and hit flash |
| `Wagon` | `x`, `len`, `roof_y`, `loot` | Train wagon with position, length (176-228px), roof height (496-562px), and remaining loot count (1-3) |
| `Sheriff` | `wagon_idx`, `rel_x`, `hp`, `shoot_cd`, `hit_cd`, `active` | Enemy guard assigned to a wagon, with relative position on wagon, HP (2-4 by level), shoot cooldown, and hit flash timer |
| `Bullet` | `x`, `y`, `vx`, `vy`, `ttl`, `owner`, `active` | Projectile with position, velocity, 1.7s time-to-live, and owner flag (1=player, 2=sheriff) |
| `Particle` | `x`, `y`, `vx`, `vy`, `ttl`, `kind`, `active` | Visual particle with velocity, gravity-affected lifetime, and kind-based coloring (0=red hit, 1=yellow muzzle, 2=purple kill, 3=cyan loot) |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value between low and high bounds |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `sqdist` | `(Float, Float, Float, Float) -> Float` | Returns the squared Euclidean distance between two 2D points |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point (px, py) is inside a rectangle (x, y, w, h) for touch input |
| `clear_sheriffs` | `(Array[Sheriff]) -> Unit` | Deactivates all sheriffs and resets their fields |
| `clear_bullets` | `(Array[Bullet]) -> Unit` | Deactivates all bullets and resets their fields |
| `clear_particles` | `(Array[Particle]) -> Unit` | Deactivates all particles and resets their fields |
| `spawn_particle` | `(Array[Particle], Float, Float, Float, Int) -> Unit` | Activates one inactive particle at (x, y) with random velocity scaled by speed factor, random TTL (0.12-0.64s), and specified kind |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Spawns N particles at a position with a speed multiplier and kind (batch explosion effect) |
| `spawn_bullet` | `(Array[Bullet], Float, Float, Float, Float, Int, Float) -> Unit` | Fires a bullet from (x, y) in direction (dx, dy), normalized to given speed, with owner and 1.7s TTL |
| `rightmost_wagon_x` | `(Array[Wagon]) -> Float` | Returns the rightmost edge X coordinate among all wagons (for recycling positioning) |
| `init_wagons` | `(Array[Wagon]) -> Unit` | Initializes all 6 wagons with random lengths (176-228px), roof heights (500-560px), loot (1-3), and gaps (24-58px) starting from x=-40 |
| `reset_player` | `(Rider) -> Unit` | Resets player to starting position (164, ground_y) with 6 HP, 100 stamina, 7 ammo, and all cooldowns cleared |
| `setup_level` | `(Int, Rider, Array[Wagon], Array[Sheriff], Array[Bullet], Array[Particle]) -> (Int, Float, Float, Float)` | Initializes a chapter: resets player, wagons, clears all pools. Returns (target_loot, timer, train_speed, sheriff_base_cd) based on level (1-3) |
| `spawn_sheriff` | `(Array[Sheriff], Array[Wagon], Int) -> Unit` | Activates one inactive sheriff on a random wagon with level-scaled HP (2/3/4) and random shoot cooldown |
| `player_support_wagon` | `(Rider, Array[Wagon]) -> Int` | Returns the index of the wagon the player is standing on (within 6px of roof_y and between edges), or -1 if airborne/on ground |

#### Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `sw` | 1280 | Screen width in pixels |
| `sh` | 820 | Screen height in pixels |
| `ground_y` | 710.0 | Ground level Y coordinate |
| `wagon_n` | 6 | Number of train wagons |
| `sheriff_n` | 18 | Sheriff pool size |
| `bullet_n` | 320 | Bullet pool size |
| `particle_n` | 620 | Particle pool size |

## Architecture

### Package Structure

```
raylib_desert_train_robbery_2026/
├── main.mbt    -- Complete game: structs, level setup, AI, physics, combat, rendering
└── moon.pkg    -- Package config (single main package, imports math + raylib)
```

This is a single-file game with all state managed as local variables in the `main` function. The game loop handles input, physics, entity management, collision detection, and rendering sequentially. Level transitions use a `transition_t` timer to show a "Chapter Clear" overlay before advancing.

### Data Flow

1. **Input**: WASD/Arrow keys read via `@raylib.is_key_down` (movement) and `@raylib.is_key_pressed` (jump/shoot/dash/loot). Mouse position checked against on-screen button rectangles for touch support. Unified into boolean flags (`move_l`, `move_r`, `jump`, `shoot`, `dash`, `loot`).
2. **Wagon Scrolling**: All wagons move leftward at `train_speed` per frame. Wagons exiting the left edge are recycled to the right of the rightmost wagon with new random properties. Sheriffs on recycled wagons are deactivated.
3. **Player Physics**: Acceleration-based movement with drag when no input. Gravity at 1180 px/s^2, jump velocity -596 px/s. Landing detection checks ground (y >= 710) and wagon roofs (crossing from above with positive vy). Player moves with wagon when standing on it.
4. **Combat**: Player shoots directionally (left/right based on input, slight upward angle). Sheriffs patrol toward player on their wagon and shoot when in 340px range. Circle-based collision for bullet-vs-sheriff (radius 20) and bullet-vs-player (radius 22). Melee contact at 34px range.
5. **Looting**: L key triggers loot when within 42px of wagon center cargo. Each loot reduces wagon.loot and increments looted count. Meeting target_loot triggers chapter transition.
6. **Rendering**: Layered: sky gradient, parallax dune silhouettes (46 triangles), ground with railroad ties, wagons (body + roof line + wheels + cargo indicator), sheriffs (head + body + limbs + hat), player (head + body + limbs, flash when hit, dash trails), bullets (short lines), particles (circles), HUD (chapter/loot/score/HP/stamina/ammo/timer/stars + bars), touch buttons, message bar, transition/game-over overlays.

### Key Design Patterns

- **Object Pool Pattern**: Sheriffs (18), bullets (320), and particles (620) use pre-allocated arrays with `active` flags.
- **Wagon Recycling**: Wagons that scroll off-screen are repositioned to the right with new random properties, creating an infinite scrolling train effect.
- **Platform Standing Detection**: `player_support_wagon` checks if the player is on a wagon roof, enabling train-relative movement and jump authorization.
- **Chapter Progression**: Three difficulty tiers with distinct parameters (loot targets, timers, speeds, sheriff spawn rates and HP). Transition timer provides visual feedback between chapters.
- **Touch-Keyboard Parity**: All actions have both keyboard bindings and clickable screen regions, merged into unified boolean flags.
- **Screen Shake & Flash**: Damage events trigger both `shake_t` (random X offset on all rendered elements) and `flash_t` (background color change) for impactful feedback.

## Improvement & Refinement Plan

1. **Extract game state into a struct**: Over 20 mutable local variables (level, target_loot, timer, train_speed, looted, score, stars, sheriff_cd, wave_t, transition_t, flash_t, shake_t, over, won, msg) could be consolidated into a `Game` struct, enabling extraction of update and render into separate functions.

2. **Add vertical aiming for the player**: Currently the player can only shoot horizontally (with a slight -0.06 or -0.22 upward angle when pressing Up). Adding full 8-directional aiming or analog aim would make combat more tactical, especially when sheriffs are on higher or lower wagon roofs.

3. **Use an enum for bullet owner**: The `owner` field is an integer (1=player, 2=sheriff). A proper enum would be more type-safe and self-documenting than the current magic number comparisons.

4. **Add wagon-specific loot types**: All loot is currently uniform (62 points each). Differentiating loot types (gold bars worth more, dynamite that adds ammo, medical kits that restore HP) would add strategic depth to wagon selection.

5. **Implement sheriff behavior variety**: All sheriffs have identical AI (move toward player, shoot when in range). Adding different types (snipers with longer range but slower fire, shotgunners with spread shots, melee-only brawlers) would increase tactical variety.

6. **Add momentum transfer on wagon jumps**: The player currently loses all horizontal velocity independent of wagon speed. Inheriting some of the wagon's velocity when jumping off would create a more physical feel and make jumping between wagons more interesting.

7. **Scale visual desert background with chapter**: The desert backdrop is static across all chapters. Changing the color palette (sunset orange for chapter 2, night blue for chapter 3) would visually communicate progression and create atmosphere.

8. **Add a combo/multiplier system for rapid kills**: Currently each sheriff kill is worth a flat 78 points. Adding a combo multiplier for kills in quick succession would reward aggressive playstyles and create risk-reward tension between playing safe and going for streaks.
