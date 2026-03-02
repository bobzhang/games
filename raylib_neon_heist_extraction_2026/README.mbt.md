# Neon Heist Extraction 2026

A top-down twin-stick stealth-action game set in a neon-lit cyberpunk facility. The player takes on the role of a lone infiltrator who must hack security terminals, crack open vaults, collect loot, and extract before time runs out or the alarm maxes out. The dark facility is patrolled by guards and surveilled by sweeping security cameras that raise the alarm when they detect the player.

The core gameplay loop revolves around a multi-stage heist: first, hack all three terminals scattered across the map to unlock the vaults; then, approach the vaults to spill their loot; collect enough loot items (42 total) and deliver them to the extraction zone in the top-right corner. Meanwhile, the player must manage HP, energy for dashing and EMP pulses, and weapon heat while fighting off three tiers of increasingly dangerous guards that reinforce as the alarm level rises.

The game features an object-pool architecture with pre-allocated arrays for guards (220), bullets (1200), cameras (18), terminals (8), vaults (8), loot (360), walls (80), and particles (1800), all managed within a single-file design. A wave-based difficulty system scales guard HP, spawn rate, and player fire rate as the heist progresses. Touch controls with on-screen virtual buttons are also supported.

## Build and Run

```bash
moon build --target native raylib_neon_heist_extraction_2026/
./_build/native/debug/build/raylib_neon_heist_extraction_2026/raylib_neon_heist_extraction_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move player
- **J / Space**: Fire weapon (hold)
- **K**: Hack nearby terminals (hold)
- **L / Right Shift**: Dash (costs 20 energy, 1.16s cooldown)
- **O**: EMP pulse (costs 40 energy, 6s cooldown) -- stuns guards, disables cameras, destroys enemy bullets, reduces alarm
- **Enter**: Start game / Restart after win or loss
- **R**: Restart after win or loss
- **F11**: Toggle fullscreen
- **Mouse**: Aim direction (when cursor is inside the arena)
- **Touch/Click**: On-screen virtual D-pad (left side) and action buttons (right side) for mobile play

## How to Play

1. **Start**: Press Enter or tap the screen on the title screen.
2. **Hack terminals**: There are 3 terminals on the map (shown as orange squares). Stand near one and hold K to hack it. The progress bar fills over time; releasing K causes progress to slowly decay. Hacking all 3 terminals unlocks the vaults and earns 180 points each.
3. **Avoid cameras**: 5 security cameras sweep back and forth. If their cone of vision catches you, the alarm level rises. Shoot cameras to temporarily disable them (9s), or use an EMP pulse to disable nearby cameras (5.2s).
4. **Open vaults**: Once all terminals are hacked, the 3 vaults (colored rectangles) unlock. Approach an open vault to trigger its loot spawn (14 items each).
5. **Collect loot**: Walk over loot items (colored circles) to pick them up. Loot also drops from defeated guards.
6. **Extract**: Deliver collected loot to the extraction zone (top-right circle labeled "EXTRACT"). You can only deposit when all terminals are hacked. Deliver 42 or more total loot units to win.
7. **Manage resources**: HP regeneration is absent -- avoid damage. Energy regenerates at 10/s and powers Dash (20 cost) and EMP (40 cost). Weapon heat builds with firing and cools at 36/s; overheating (above 94) prevents firing.
8. **Alarm system**: Cameras and certain events raise the alarm. If alarm reaches 100, the heist fails. High alarm (35+) triggers guard reinforcements from map edges. Hacking terminals and EMP reduce alarm.
9. **Guard types**: Kind 0 (red circles, light, single-shot), Kind 1 (orange rectangles, medium, dual-shot spread), Kind 2 (purple rectangles, heavy, slow but high HP, fires large projectiles). Guards scale in HP with wave number.
10. **Win/Lose**: Win by delivering 42+ loot. Lose if HP drops to 0, timer (430s) expires, or alarm hits 100.

## Public API Reference

### Package `raylib_neon_heist_extraction_2026`

> Main entry point and complete game implementation in a single file.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width in pixels |
| `sh` | `Int` | `760` | Screen height in pixels |
| `world_l` | `Float` | `34.0` | Left boundary of the playable area |
| `world_r` | `Float` | `1246.0` | Right boundary of the playable area |
| `world_t` | `Float` | `90.0` | Top boundary of the playable area |
| `world_b` | `Float` | `726.0` | Bottom boundary of the playable area |
| `max_guards` | `Int` | `220` | Maximum number of guards in the pool |
| `max_bullets` | `Int` | `1200` | Maximum number of bullets in the pool |
| `max_cameras` | `Int` | `18` | Maximum number of security cameras |
| `max_terminals` | `Int` | `8` | Maximum number of hackable terminals |
| `max_vaults` | `Int` | `8` | Maximum number of loot vaults |
| `max_loot` | `Int` | `360` | Maximum number of loot items |
| `max_walls` | `Int` | `80` | Maximum number of wall segments |
| `max_particles` | `Int` | `1800` | Maximum number of visual particles |
| `extraction_x` | `Float` | `world_r - 80.0` | X position of extraction zone |
| `extraction_y` | `Float` | `world_t + 80.0` | Y position of extraction zone |
| `extraction_r` | `Float` | `72.0` | Radius of extraction zone |
| `loot_goal` | `Int` | `42` | Loot units required to win |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Player` | `x`, `y`, `vx`, `vy`, `aim_x`, `aim_y`, `hp`, `energy`, `heat`, `inv_t`, `fire_cd`, `dash_cd`, `dash_t`, `emp_cd`, `loot`, `delivered`, `score`, `combo`, `best_combo` | Player state including position, velocity, aim direction, resources, cooldowns, and scoring |
| `Guard` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `hp`, `fire_cd`, `state`, `home_x`, `home_y`, `target_x`, `target_y`, `stun_t`, `t` | Enemy guard with patrol/chase AI, 3 kinds (0=light, 1=medium, 2=heavy) |
| `Bullet` | `active`, `team`, `kind`, `x`, `y`, `vx`, `vy`, `dmg`, `r`, `life` | Projectile with team affiliation (1=player, 2=enemy) |
| `CameraUnit` | `active`, `x`, `y`, `base`, `sweep`, `speed`, `range`, `gain`, `hp`, `disabled_t`, `t` | Security camera with sweeping cone detection |
| `Terminal` | `active`, `x`, `y`, `hacked`, `progress` | Hackable terminal that unlocks vaults when all are hacked |
| `Vault` | `active`, `x`, `y`, `open`, `spawned` | Loot vault that opens after all terminals are hacked |
| `Loot` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `value`, `life`, `t` | Collectible loot item with timed lifetime |
| `Wall` | `active`, `x`, `y`, `w`, `h` | Axis-aligned rectangular wall for collision |
| `Particle` | `active`, `kind`, `x`, `y`, `vx`, `vy`, `size`, `life`, `t` | Visual particle effect with 4 color kinds |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value between lo and hi bounds |
| `absf` | `(Float) -> Float` | Returns absolute value of a float |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Returns squared distance between two points |
| `randf` | `(Float, Float) -> Float` | Returns a random float between lo and hi |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside a rectangle (for touch UI) |
| `guard_radius` | `(Int) -> Float` | Returns collision radius for guard kind (15/20/26) |
| `guard_hp` | `(Int, Int) -> Float` | Calculates guard HP based on kind and wave number |
| `circle_rect_hit` | `(Float, Float, Float, Float, Float, Float, Float) -> Bool` | Circle-rectangle collision test |
| `bounce_from_walls` | `(Float, Float, Float, Float, Float, Array[Wall]) -> (Float, Float, Float, Float)` | Resolves circle-wall collisions with velocity bounce |
| `clear_guards` | `(Array[Guard]) -> Unit` | Resets all guards in the pool to inactive |
| `clear_bullets` | `(Array[Bullet]) -> Unit` | Resets all bullets in the pool to inactive |
| `clear_cameras` | `(Array[CameraUnit]) -> Unit` | Resets all cameras in the pool to inactive |
| `clear_terminals` | `(Array[Terminal]) -> Unit` | Resets all terminals in the pool to inactive |
| `clear_vaults` | `(Array[Vault]) -> Unit` | Resets all vaults in the pool to inactive |
| `clear_loot` | `(Array[Loot]) -> Unit` | Resets all loot items in the pool to inactive |
| `clear_walls` | `(Array[Wall]) -> Unit` | Resets all walls in the pool to inactive |
| `clear_particles` | `(Array[Particle]) -> Unit` | Resets all particles in the pool to inactive |
| `add_guard` | `(Array[Guard], Int, Float, Float, Float, Float, Int) -> Bool` | Spawns a guard of given kind at position with home coordinates |
| `add_bullet` | `(Array[Bullet], Int, Int, Float, Float, Float, Float, Float, Float, Float) -> Bool` | Spawns a bullet with team, kind, position, velocity, damage, radius, and lifetime |
| `add_camera` | `(Array[CameraUnit], Float, Float, Float, Float, Float, Float, Float) -> Bool` | Spawns a security camera with sweep parameters |
| `add_terminal` | `(Array[Terminal], Float, Float) -> Bool` | Spawns a hackable terminal at position |
| `add_vault` | `(Array[Vault], Float, Float) -> Bool` | Spawns a loot vault at position |
| `add_loot` | `(Array[Loot], Int, Float, Float, Float, Float, Int, Float) -> Bool` | Spawns a loot item with kind, position, velocity, value, and lifetime |
| `add_wall` | `(Array[Wall], Float, Float, Float, Float) -> Bool` | Spawns a wall segment at position with dimensions |
| `add_particle` | `(Array[Particle], Int, Float, Float, Float, Float, Float, Float) -> Bool` | Spawns a visual particle with kind, position, velocity, size, and lifetime |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Creates a burst of particles at a position with count and scale |
| `count_hacked` | `(Array[Terminal]) -> Int` | Counts the number of hacked terminals |
| `count_terminals` | `(Array[Terminal]) -> Int` | Counts the number of active terminals |
| `count_active_guards` | `(Array[Guard]) -> Int` | Counts the number of active guards |
| `setup_map` | `(Array[Wall], Array[Terminal], Array[Vault], Array[CameraUnit]) -> Unit` | Initializes the map layout with walls, terminals, vaults, and cameras |
| `draw_touch_ui` | `(Int) -> Unit` | Draws on-screen virtual controls for touch/mobile input |
| `main` | `() -> Unit` | Entry point: initializes window, allocates pools, runs game loop |

## Architecture

### Package Structure

```
raylib_neon_heist_extraction_2026/
├── main.mbt    — Complete game: types, constants, utilities, game logic, input, rendering
└── moon.pkg    — Package config with raylib and math imports
```

This is a single-file game with all logic contained in `main.mbt`. The file is organized into sections: constants and type definitions at the top, followed by utility functions, object pool management (clear/add functions), map setup, touch UI rendering, and finally the main game loop which handles input, game state updates, collision detection, and rendering.

### Data Flow

1. **Input**: The `main` loop reads keyboard state (`is_key_down`, `is_key_pressed`) and mouse/touch position each frame. Touch inputs are mapped to the same logical actions (move, fire, hack, dash, EMP) by checking if the touch position falls within on-screen button rectangles via `inside_rect`.

2. **Update**: Game state `0` (title) waits for Enter/tap. State `1` (playing) processes: timer countdown, player cooldown/energy/heat regeneration, alarm decay, guard reinforcement spawning, player movement with wall bounce (`bounce_from_walls`), shooting, terminal hacking, vault unlocking, camera sweep detection, guard AI (patrol/chase states), loot pickup, extraction deposit, bullet-wall/bullet-guard/bullet-player collisions, and particle updates. States `2` (win) and `3` (lose) wait for restart input.

3. **Rendering**: Drawing order: background grid and stars, playable zone, extraction zone, walls, terminals with progress bars, vaults, camera cones, loot, guards, bullets, player with aim line, particles, HUD bars (alarm/HP/energy/heat), status text, message bar, touch UI overlay, and state-specific screens (title/win/lose).

### Key Design Patterns

- **Object pool pattern**: All entity types (guards, bullets, cameras, terminals, vaults, loot, walls, particles) use pre-allocated `Array` pools with `active` flags. `add_*` functions scan for the first inactive slot; `clear_*` functions reset entire pools.
- **Integer state machine**: Game state is a simple `Int` (0=title, 1=playing, 2=win, 3=lose) that drives the main update and render branches.
- **Guard AI states**: Guards use an integer `state` field (0=patrol, 1=chase) with distance-based detection and alarm-driven aggression. Three guard kinds have different stats (radius, HP, fire patterns).
- **Alarm escalation system**: A floating-point alarm level drives difficulty scaling -- cameras raise it, hacking/EMP reduce it, and crossing threshold 35 triggers reinforcement spawns with decreasing cooldowns.
- **Wave-based difficulty scaling**: Wave number increases with each reinforcement, scaling guard HP (`guard_hp`), guard speed, player fire rate, and unlocking triple-shot at wave 5.
- **Delta-time simulation**: All movement, cooldowns, and timers use frame delta time (capped at 0.033s) for frame-rate independent gameplay.

## Improvement & Refinement Plan

1. **Extract guard kinds into an enum**: The three guard types (0/1/2) are distinguished by magic integer constants throughout `guard_radius`, `guard_hp`, and the guard update/render logic. Defining a `GuardKind` enum with `Light`, `Medium`, `Heavy` variants would improve readability and type safety.

2. **Separate game phases into distinct state handlers**: The main game loop in `main` has deeply nested logic for state 1 (playing). Breaking update logic into dedicated functions like `update_player`, `update_guards`, `update_bullets`, `update_cameras`, and `check_win_lose` would make the code more maintainable.

3. **Add HP regeneration or healing mechanic**: Currently there is no way to recover HP once lost. Adding health pickups from vault loot or a slow passive regeneration would make longer runs more viable and reduce frustration from early damage.

4. **Introduce camera field-of-view visualization**: The camera cones are drawn as three lines but do not fill the area. Using a triangle fan or semi-transparent filled cone would make it much clearer to players which area is being surveilled, reducing unfair detection.

5. **Pool exhaustion handling**: The `add_*` functions return `Bool` to indicate success, but the return value is consistently ignored with `ignore()`. Tracking pool exhaustion could trigger cleanup of expired entities or provide player feedback.

6. **Replace particle kind integers with an enum**: Particle kinds (0=cyan, 1=yellow, 2=red, 3=purple) are magic numbers. A `ParticleKind` enum would document the visual effect categories and prevent errors.

7. **Add sound effects**: The game has rich visual feedback (particle bursts, flash on hit) but no audio. Adding sound for firing, hacking completion, alarm triggers, and vault opening would significantly enhance the gameplay feel.

8. **Configurable difficulty**: The `loot_goal` (42), timer (430s), and alarm threshold (100) are hardcoded constants. Exposing these as difficulty presets (Easy/Normal/Hard) would add replayability.
