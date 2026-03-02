# Battle Kart Arena 2026

Battle Kart Arena 2026 is a top-down kart racing combat game where the player races against three AI opponents on a rectangular track with inner and outer walls. The track is a hollow rectangle with 8 waypoints, and the goal is to complete 3 laps before any AI kart does.

The core gameplay combines arcade racing physics with vehicular combat. The player's kart uses angle-based steering with speed-dependent turn rates, velocity damping, and wall bounce mechanics. Players can fire projectiles to damage AI karts (4 HP each; destroyed karts respawn), collect pickups scattered around the track (ammo, boost fuel, or integrity/HP), and use a rechargeable boost system for speed bursts. AI karts navigate via waypoint following with direct line-of-sight shooting when the player is within 250 units.

The game features touch-screen controls via on-screen buttons (LEFT, RIGHT, ACC, BRK, FIRE, BOOST) alongside keyboard input, making it suitable for both desktop and touch-enabled devices. Spark particle effects provide visual feedback for pickups, hits, and kart destruction.

## Build and Run

```bash
moon build --target native raylib_battle_kart_arena_2026/
./_build/native/debug/build/raylib_battle_kart_arena_2026/raylib_battle_kart_arena_2026.exe
```

## Controls

- **W / Up Arrow**: Accelerate (280 force)
- **S / Down Arrow**: Brake/reverse (340 force)
- **A / Left Arrow**: Steer left
- **D / Right Arrow**: Steer right
- **Space / J**: Fire projectile (requires ammo, 0.14s cooldown)
- **Left Shift / K**: Activate boost (drains boost meter at 22/s, adds 220 acceleration)
- **R**: Restart the game
- **Mouse/Touch**: On-screen buttons for LEFT, RIGHT, ACC, BRK, FIRE, and BOOST

## How to Play

Race around the rectangular track by passing through 8 waypoints in order. The first kart (player or AI) to complete 3 full laps wins. Your kart (cyan) starts on the left side of the track along with 3 AI opponents (red, yellow, purple).

**Driving**: Accelerate with W/Up, brake with S/Down. Steering rate depends on current speed (base 120 + |speed| * 0.22 degrees/second). Speed is clamped to [-180, 390] with 0.90/s damping. Driving off-track (outside the track rectangle) applies additional speed reduction (0.86 multiplier). Hitting walls bounces you back with reversed speed (38% or 32% depending on outer/inner wall).

**Combat**: Fire forward-facing projectiles with Space/J. Each shot travels at 680 speed with 1.6s time-to-live. Hitting an AI kart deals 1 HP damage (24 score per hit). Destroying an AI kart (reducing to 0 HP) awards 120 score and respawns it at its starting position with full HP. AI karts shoot at you when within 250-unit range with a random 0.9-1.5s cooldown between shots.

**Pickups**: Six pickup locations on the track respawn 8 seconds after collection.
- Kind 0 (cyan): +4 ammo (max 16)
- Kind 1 (gold): +35 boost fuel (max 100)
- Kind 2 (green): +1 HP (max 5)

**Boost**: Hold Shift/K to boost (+220 acceleration, drains at 22/s). Boost regenerates at 10/s when not in use (max 100).

**Win condition**: Complete 3 laps. Finishing awards 500 + remaining HP * 60 bonus score.
**Lose conditions**: Your HP reaches 0 (destroyed), or an AI kart finishes 3 laps first.

## Public API Reference

### Package `raylib_battle_kart_arena_2026`

> Single-file game with all logic, rendering, and input in `main.mbt`.

This game has no public types or functions -- all items are package-private.

#### Structs (package-private)

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Kart` | `x`, `y`, `angle`, `speed`, `hp`, `lap`, `next_wp`, `shoot_cd` | A racing kart with position, steering angle, HP, lap progress, and shooting cooldown |
| `Shot` | `x`, `y`, `vx`, `vy`, `ttl`, `owner`, `active` | A projectile with velocity, time-to-live, and owner index |
| `Pickup` | `x`, `y`, `kind`, `active`, `respawn` | A collectible item with type (0=ammo, 1=boost, 2=HP) and respawn timer |
| `Spark` | `x`, `y`, `vx`, `vy`, `ttl`, `kind`, `active` | A visual particle for impact and collection effects |

#### Constants (package-private)

| Constant | Value | Description |
|----------|-------|-------------|
| `sw` / `sh` | `1280` / `820` | Screen dimensions |
| `outer_l/t/r/b` | `120/110/1160/710` | Outer track wall boundaries |
| `inner_l/t/r/b` | `360/250/920/570` | Inner track wall boundaries |
| `wp_n` | `8` | Number of waypoints around the track |
| `kart_n` | `4` | Number of karts (1 player + 3 AI) |
| `max_shots` | `200` | Shot object pool size |
| `max_pickups` | `6` | Number of pickup locations |
| `max_sparks` | `260` | Spark particle pool size |

#### Functions (package-private)

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value to [lo, hi] |
| `absf` | `(Float) -> Float` | Returns absolute value of a float |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside a rectangle (for touch controls) |
| `deg2rad` | `(Float) -> Double` | Converts degrees to radians |
| `sinf_deg` | `(Float) -> Float` | Sine of an angle in degrees |
| `cosf_deg` | `(Float) -> Float` | Cosine of an angle in degrees |
| `track_contains` | `(Float, Float, Float) -> Bool` | Tests if a point is within the track (inside outer, outside inner) with margin |
| `set_wp` | `(Array[Float], Array[Float], Int, Float, Float) -> Unit` | Sets a waypoint's x,y coordinates |
| `init_waypoints` | `(Array[Float], Array[Float]) -> Unit` | Initializes 8 waypoint positions around the track |
| `reset_karts` | `(Array[Kart]) -> Unit` | Resets all 4 karts to starting positions with 4 HP |
| `clear_shots` | `(Array[Shot]) -> Unit` | Deactivates all shots in the pool |
| `set_pickup` | `(Array[Pickup], Int, Float, Float, Int) -> Unit` | Sets a pickup at position with kind |
| `reset_pickups` | `(Array[Pickup]) -> Unit` | Resets all 6 pickups to their default positions and kinds |
| `clear_sparks` | `(Array[Spark]) -> Unit` | Deactivates all spark particles |
| `spawn_spark` | `(Array[Spark], Float, Float, Float, Int) -> Unit` | Creates a spark particle at position with random velocity |
| `burst` | `(Array[Spark], Float, Float, Int, Float, Int) -> Unit` | Spawns N spark particles at a position for visual effects |
| `spawn_shot` | `(Array[Shot], Float, Float, Float, Float, Int) -> Unit` | Creates a projectile moving at 680 speed in the given direction |
| `update_waypoint_progress` | `(Kart, Array[Float], Array[Float]) -> Unit` | Checks if kart is within 58 units of its next waypoint and advances lap/wp counter |
| `resolve_track_collision` | `(Kart) -> Unit` | Bounces kart off outer and inner track walls with speed reversal |
| `respawn_kart` | `(Array[Kart], Int) -> Unit` | Resets a specific kart to its starting position |

## Architecture

### Package Structure

```
raylib_battle_kart_arena_2026/
├── main.mbt    -- Single file: all game logic, physics, AI, rendering, and input
└── moon.pkg    -- Package config with raylib and math imports
```

This is a single-file game. All state variables are local to the `main` function, including kart array, shot pool, pickup array, spark pool, and game-state flags (`over`, `won`, `score`, `ammo`, `boost`).

### Data Flow

1. **Input**: Keyboard and mouse/touch input is polled each frame. On-screen button rectangles are tested against mouse position for touch control.
2. **Player physics**: Steering angle is updated based on turn input and speed-dependent turn rate. Speed is modified by acceleration, braking, boost, and damping. Position is updated by angle-based velocity.
3. **AI navigation**: AI karts (indices 1-3) move directly toward their next waypoint at speeds of 200/210/220. They shoot at the player when within 250-unit range.
4. **Collisions**: `resolve_track_collision` bounces karts off walls. Shots are tested against kart positions (18-unit radius). Pickups are collected within 28-unit radius.
5. **Waypoint tracking**: `update_waypoint_progress` checks proximity to the next waypoint (58-unit threshold) and advances the waypoint/lap counter.
6. **Win/lose check**: The game ends when any kart completes 3 laps or the player's HP reaches 0.
7. **Rendering**: Layered drawing of track (outer gray rectangle, inner green island), center lane dashes, start line, pickups, karts (circles with direction lines), shots, sparks, HUD bar, and on-screen touch buttons.

### Key Design Patterns

- **Object pool pattern**: Shots (200), sparks (260), and pickups (6) use pre-allocated arrays with `active` flags.
- **Angle-based kart physics**: Karts use a heading angle with `cosf_deg`/`sinf_deg` for forward movement, providing arcade-style steering rather than realistic physics.
- **Dual input system**: Both keyboard and mouse/touch controls are supported simultaneously, with on-screen button rectangles drawn and tested each frame.
- **Waypoint-based AI**: AI karts follow 8 waypoints placed around the track using direct-to-target movement with `atan2` for heading calculation.
- **Wall bounce physics**: Track collision reverses and reduces speed (38% outer, 32% inner), creating a bouncy rubber-wall feel.
- **Screen shake and hit flash**: `shake_t` offsets all rendered X positions, and `hit_flash` tints the background red for feedback.

## Improvement & Refinement Plan

1. **Add kart-to-kart collision**: Currently karts pass through each other without interaction. Adding circle-circle collision resolution between all 4 karts would create more dynamic racing.

2. **Improve AI pathfinding**: AI karts move in straight lines between waypoints, often cutting corners through the inner island before `resolve_track_collision` bounces them back. Waypoints could be adjusted or AI could use track-aware steering.

3. **Add lap-specific scoring or difficulty scaling**: All 3 laps are identical. AI speed could increase each lap, or new hazards could appear, to create escalating tension.

4. **Extract structs to an enum for pickup kinds**: `pickup.kind` uses integers 0/1/2 with match-like if/else chains. A `PickupKind` enum would be clearer.

5. **Fix off-track speed penalty**: The `track_contains` check in the player update applies a 0.86 speed multiplier per frame when off-track, but AI karts never receive this penalty since they don't use the same code path.

6. **Add minimap or lap progress indicator**: The HUD shows lap count but not position relative to AI karts. A minimap or position indicator (1st/2nd/3rd/4th) would help the player gauge race progress.

7. **Improve spark particle system**: The `spawn_spark` function uses a linear scan with a `done` flag workaround instead of breaking early. Using a dedicated `find_free_slot` function would be cleaner.
