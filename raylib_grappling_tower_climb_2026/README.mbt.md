# Grappling Tower Climb 2026

A vertical tower-climbing action game where a pilot ascends a procedurally generated tower shaft using a grappling hook, platforming, and combat abilities. The player must reach the summit at 3200 meters altitude within a 260-second time limit while fending off three types of enemy drones that patrol and shoot from within the tower walls. The tower spans from left wall at x=342 to right wall at x=938, creating a constrained vertical corridor.

The core loop revolves around chaining grappling hook swings between anchor points to gain height rapidly, landing on static and moving platforms for rest, and managing energy for dash and bomb abilities. The grappling hook simulates pendulum physics with rope tension (stretch force of 8.8 per unit) and reduced gravity (56% while attached), rewarding momentum-based play. Crystals dropped by defeated drones and scattered on platforms restore energy and add to the score with a combo multiplier system.

The game features a layered procedural generation system that creates platforms, anchor points, crystals, and drones in vertical segments. Difficulty scales with height through a level calculation (best_height / 380 + 1), increasing drone spawn probability, drone HP, movement speed, fire rate, and bullet speed. Three drone types provide escalating challenge: kind 0 (basic), kind 1 (faster, tougher), and kind 2 (fastest, toughest). All entities use pre-allocated object pools with active flags for zero-allocation gameplay.

## Build and Run

```bash
moon build --target native raylib_grappling_tower_climb_2026/
./_build/native/debug/build/raylib_grappling_tower_climb_2026/raylib_grappling_tower_climb_2026.exe
```

## Controls

- **A / Left Arrow**: Move left
- **D / Right Arrow**: Move right
- **W / Up Arrow**: Hold to ascend (small hop assist when grounded)
- **S / Down Arrow**: Hold to descend (influences dash direction)
- **W / Up Arrow / Space** (press): Jump (with coyote time and jump buffering)
- **J** (hold): Grapple to nearest anchor point (release to detach)
- **K**: Dash (directional burst of speed with invulnerability)
- **L**: Drop shock pulse bomb (damages nearby drones and destroys bullets)
- **R**: Restart current run (from win/lose screen)
- **Enter**: Start game / return to menu (from win/lose screen)
- **F11**: Toggle fullscreen
- **Touch D-pad (left panel)**: L/R/U/D directional movement and jump
- **Touch DASH button**: Trigger dash ability
- **Touch BOMB button**: Trigger bomb ability
- **Touch GRAPPLE button (hold)**: Grapple to nearest anchor

## How to Play

1. **Objective**: Climb the tower to reach 3200 meters altitude before the 260-second timer expires or your HP reaches zero. Your current height and target are displayed in the HUD.

2. **Movement**: Use A/D to move horizontally within the tower walls. Press W/Up/Space to jump. The game supports coyote time (0.12 seconds of jump grace after leaving a platform) and jump buffering (0.15 seconds of input queuing before landing).

3. **Grappling**: Hold J to attach to the nearest anchor point within 290 units. The rope length is clamped between 84 and 232 units. While grappling, gravity is reduced to 56% and the rope exerts tension force proportional to stretch. Release J to detach and use momentum to reach higher platforms or the next anchor. This is the primary method of rapid vertical movement.

4. **Dash**: Press K to dash in the direction you are facing (influenced by held up/down keys). Costs 18 energy, has a 1.28-second cooldown, and grants 0.18 seconds of invulnerability. During dash, you can destroy drones on contact. Dash speed is 560 units/second for 0.20 seconds.

5. **Bomb**: Press L to emit a shock pulse that damages all drones within a 190-unit radius and destroys enemy bullets within a 210-unit radius. Costs 28 energy with a 4.8-second cooldown. Stunned drones cannot move or fire for 1.0 second.

6. **Energy management**: Energy regenerates at 15 units/second up to a maximum of 100. Collecting crystals restores energy proportional to their point value (24% of value). Plan ability usage around energy availability.

7. **Combat**: Drones chase the player horizontally and fire aimed bullets when within 380 units. Bullet damage varies by drone type (9-13.8 damage). Contact with drones also deals damage (8-12). Defeating drones via dash or bomb awards score with combo multiplier and may drop crystals (46-56% chance).

8. **Platforms**: Static platforms provide safe footing. Moving platforms oscillate horizontally with varying amplitude (24-96 units) and speed. Platforms are procedurally generated ahead of the player as they climb.

9. **Scoring**: Score accumulates from crystal collection, drone kills (64-88 base + combo bonus), and bullet deflection during dash (+2 per bullet). The combo counter increments with each crystal pickup and drone kill, resetting when the player takes damage.

10. **Win/Lose**: Reach 3200m to see the "SUMMIT REACHED" victory screen. Lose if HP drops to zero, time runs out, or you fall off the bottom of the screen. Press R to replay or Enter to return to the menu.

## Public API Reference

### Package `raylib_grappling_tower_climb_2026`

> Main entry point and complete game implementation (single-file architecture).

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Window width in pixels |
| `sh` | `Int` | `760` | Window height in pixels |
| `tower_l` | `Float` | `342.0` | Left wall X coordinate of the tower shaft |
| `tower_r` | `Float` | `938.0` | Right wall X coordinate of the tower shaft |
| `tower_w` | `Float` | `596.0` | Tower width (tower_r - tower_l) |
| `gravity` | `Float` | `760.0` | Base gravity acceleration (units/sec^2) |
| `max_platforms` | `Int` | `260` | Object pool size for platforms |
| `max_anchors` | `Int` | `260` | Object pool size for grapple anchor points |
| `max_drones` | `Int` | `140` | Object pool size for enemy drones |
| `max_bullets` | `Int` | `560` | Object pool size for bullets |
| `max_crystals` | `Int` | `200` | Object pool size for collectible crystals |
| `max_particles` | `Int` | `1000` | Object pool size for visual particles |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Pilot` | `x`, `y`, `vx`, `vy`, `face`, `hp`, `energy`, `dash_t`, `dash_cd`, `bomb_cd`, `inv_t`, `grapple_on`, `gx`, `gy`, `gl`, `grounded`, `coyote_t`, `jump_buf_t`, `flash_t`, `score`, `combo`, `best_h` | Player character state including position, velocity, facing direction, health, energy, ability cooldowns, invulnerability timer, grapple state (target position and rope length), grounding/coyote/jump buffer, visual flash, and scoring |
| `Platform` | `active`, `x`, `base_x`, `y`, `w`, `moving`, `amp`, `speed`, `phase` | Horizontal platform with optional sinusoidal movement; base_x stores the center position for oscillation |
| `Anchor` | `active`, `x`, `y` | Grapple hook target point in the tower |
| `Drone` | `active`, `kind`, `x`, `y`, `base_y`, `vx`, `hp`, `fire_cd`, `stun_t`, `t` | Enemy drone with type (0-2), horizontal chase AI, vertical bobbing, firing cooldown, and stun timer |
| `Bullet` | `active`, `x`, `y`, `vx`, `vy`, `dmg`, `life`, `team` | Projectile with velocity, damage, lifetime, and team identifier (2 = enemy) |
| `Crystal` | `active`, `x`, `y`, `value`, `t`, `life` | Collectible crystal with point value and limited lifetime (8-18 seconds) |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `size`, `t`, `life`, `kind` | Visual particle with type-based coloring (0=blue, 1=orange, 2=green, 3=red) |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between low and high bounds |
| `absf` | `(Float) -> Float` | Returns absolute value of a float |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Returns squared Euclidean distance between two points |
| `randf` | `(Float, Float) -> Float` | Returns a random float in the given range using raylib RNG |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Point-in-rectangle hit test for touch/mouse input |
| `clear_platforms` | `(Array[Platform]) -> Unit` | Deactivates and zeroes all platforms in the pool |
| `clear_anchors` | `(Array[Anchor]) -> Unit` | Deactivates and zeroes all anchors in the pool |
| `clear_drones` | `(Array[Drone]) -> Unit` | Deactivates and zeroes all drones in the pool |
| `clear_bullets` | `(Array[Bullet]) -> Unit` | Deactivates and zeroes all bullets in the pool |
| `clear_crystals` | `(Array[Crystal]) -> Unit` | Deactivates and zeroes all crystals in the pool |
| `clear_particles` | `(Array[Particle]) -> Unit` | Deactivates and zeroes all particles in the pool |
| `add_platform` | `(Array[Platform], Float, Float, Float, Bool, Float, Float) -> Bool` | Activates a platform slot with position, width, movement parameters; returns false if pool is full |
| `add_anchor` | `(Array[Anchor], Float, Float) -> Bool` | Activates an anchor slot at the given position; returns false if pool is full |
| `add_drone` | `(Array[Drone], Float, Float, Int, Int) -> Bool` | Activates a drone slot with position, type, and level-scaled HP; returns false if pool is full |
| `add_bullet` | `(Array[Bullet], Float, Float, Float, Float, Float, Float, Int) -> Bool` | Activates a bullet slot with position, velocity, damage, lifetime, and team; returns false if pool is full |
| `add_crystal` | `(Array[Crystal], Float, Float, Int) -> Bool` | Activates a crystal slot with position and point value; returns false if pool is full |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Spawns N particles at a position with random velocities scaled by speed, typed by kind |
| `generate_layer` | `(Array[Platform], Array[Anchor], Array[Crystal], Array[Drone], Float, Int) -> Unit` | Procedurally generates one vertical layer of content at a given Y coordinate with level-scaled difficulty |
| `main` | `() -> Unit` | Entry point: initializes window, creates entity pools, runs the game loop with input handling, physics, AI, collision detection, rendering, and state management |

## Architecture

### Package Structure

```
raylib_grappling_tower_climb_2026/
├── main.mbt              -- Complete game: structs, constants, utilities, generation,
│                            input, physics, AI, collisions, rendering, and game loop
└── moon.pkg              -- Package config: raylib and math imports, is-main option
```

### Data Flow

1. **Input**: Each frame, the `main` loop polls keyboard state via `@raylib.is_key_down` / `@raylib.is_key_pressed` and mouse/touch state via `@raylib.get_mouse_position` and `@raylib.is_mouse_button_*`. Touch input is unified with keyboard through `inside_rect` hit tests on the D-pad and action button regions.

2. **Physics**: The pilot's velocity is updated by horizontal acceleration (520 units/sec^2 from movement keys), gravity (760 or 426 during grapple), and grapple rope tension (stretch * 8.8 force). Velocity drag is applied (2.5 normal, 1.4 during dash, 0.14 vertical during grapple). Position is integrated and clamped to tower walls with bounce.

3. **Platform collision**: One-way platform detection checks if the pilot was above the platform last frame and is at or below it this frame, with horizontal overlap. Landing sets `grounded = true` and starts the 0.12-second coyote timer.

4. **Drone AI**: Each active drone chases the pilot horizontally at level-scaled acceleration (140 + kind*34 + level*3.2), bobs vertically around a slowly-tracking base_y, and fires aimed bullets when within 380 units with level-scaled bullet speed (220 + kind*38 + level*2.0).

5. **Procedural generation**: `generate_layer` is called whenever the pilot is within 1400 units of `gen_top_y`. It places a main platform with optional movement, an anchor above it, a crystal (62% chance), and a drone (level-scaled chance from 14-66%). A secondary side platform has a 42% chance of spawning.

6. **Rendering**: Drawing proceeds in layers: parallax skyline background, tower walls with window details, grid lines, platforms, anchors, crystals, drones (color-coded by kind), bullets (color-coded by team), grapple rope line, pilot (with flash on damage), particles, HUD bars and text, touch control overlays, and state-specific overlays (menu/win/lose).

### Key Design Patterns

- **Object pool pattern**: All entities (platforms, anchors, drones, bullets, crystals, particles) use pre-allocated `Array` pools with `active` boolean flags. The `add_*` functions scan for the first inactive slot; `clear_*` functions reset entire pools on run restart. Pool sizes are tuned constants (260/260/140/560/200/1000).

- **State machine**: An integer `state` variable drives the main loop: 0 = menu (overlay with start prompt), 1 = play (full game simulation), 2 = win (summit reached overlay), 3 = lose (failed overlay). State transitions are explicit: menu->play on Enter/tap, play->win/lose on condition, win/lose->menu on Enter, win/lose->play on R.

- **Coyote time and jump buffering**: The pilot has a 0.12-second `coyote_t` timer that starts when grounded and decays when airborne, allowing late jumps. A 0.15-second `jump_buf_t` timer records jump presses and triggers the jump when both timers overlap. This creates responsive platforming.

- **Pendulum grapple physics**: The grappling hook simulates rope constraints through a spring-like tension force applied when the distance exceeds the rope length `gl`. The force is proportional to stretch (8.8 per unit), creating natural pendulum swings. Gravity is reduced to 56% while grappling to keep swings manageable.

- **Level-scaled difficulty**: The `level` variable (best_height / 380 + 1) scales drone HP, acceleration, bullet speed, spawn probability, and the frequency of moving platforms. This creates progressive difficulty without explicit stage boundaries.

- **Unified touch/keyboard input**: Boolean flags like `move_l`, `jump_press`, `dash_press`, and `grapple_hold` are set by both keyboard checks and `inside_rect` touch region tests, allowing identical game logic for both input methods.

- **Camera tracking**: The camera's Y position smoothly follows the pilot using exponential interpolation: `cam_y += (target - cam_y) * dt * 4.6`. Entities below the visible area plus a margin are deactivated to free pool slots.

## Improvement & Refinement Plan

1. **Extract game state into a struct**: All game state is currently scattered across local variables in `main` (`state`, `cam_y`, `gen_top_y`, `target_h`, `time_left`, `spawn_cd`, `msg`, `msg_t`). Consolidating these into a `Game` struct alongside the entity pools would improve code organization, enable passing state to extracted functions, and allow save/load functionality.

2. **Add wall jump mechanic**: The pilot bounces off tower walls with 24% velocity retention (`pilot.vx = absf(pilot.vx) * 0.24`), but there is no wall jump. Adding a wall jump when the pilot contacts the tower_l or tower_r boundaries while pressing jump would create an additional traversal option and reduce dependence on anchor placement.

3. **Implement drone drop variety**: Defeated drones only drop crystals (`add_crystal` with 46-56% probability). Adding health pickups or temporary power-ups (speed boost, shield) as drone drops would add strategic depth to combat engagement and reward aggressive play.

4. **Add visual feedback for grapple range**: The grapple attaches to the nearest anchor within 290 units (`dist2 <= 290.0 * 290.0`), but there is no visual indicator of which anchor will be targeted or the grapple range. Drawing a subtle ring or highlight on the nearest valid anchor would help players plan their swings.

5. **Support difficulty settings**: The target height (`target_h = 3200.0`), time limit (`time_left = 260.0`), and pilot HP (`hp = 120.0`) are hardcoded in `reset_run`. Adding easy/normal/hard presets that adjust these values along with the drone scaling formula would accommodate different skill levels.

6. **Add checkpoint system**: The `generate_layer` function creates content procedurally without checkpoints. Adding occasional checkpoint platforms at fixed height intervals (e.g., every 800m) that update the respawn position would reduce frustration on longer runs while keeping the challenge intact.

7. **Separate rendering from game logic**: The `main` function interleaves game update logic (lines 734-1281) with rendering code (lines 1283-1901) in a single 1400+ line function. Extracting rendering into dedicated draw functions (`draw_platforms`, `draw_drones`, `draw_hud`, `draw_overlays`) would improve readability and enable visual tweaks without touching game logic.

8. **Add sound effects for key actions**: The game has particle effects for jumps (`burst` with kind 0), drone kills (kind 1), grapple attachment (kind 2), and damage (kind 3), but no audio feedback. Adding sound effects for grapple attach/detach, dash, bomb, crystal pickup, and damage would significantly enhance game feel.
