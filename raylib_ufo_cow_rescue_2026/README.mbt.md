# UFO Cow Rescue 2026

UFO Cow Rescue is an action arcade game where the player pilots a flying saucer over farmland at night, using a tractor beam to abduct cows and deliver them to a mothership hovering at the top of the screen. Farmers patrol the ground, shooting at the UFO and seizing cows that remain on the surface too long.

The core loop involves positioning the UFO above cows, holding the tractor beam (J key) to pull them upward through three states (ground, being lifted, attached), then flying to the mothership's position to complete the rescue. The UFO has three abilities that consume energy: the tractor beam (24 energy/sec while active), a dash burst (18 energy, 0.26s speed boost with 1.45s cooldown), and an EMP pulse (28 energy, damages and panics all farmers within 180px radius, also destroys nearby bullets, 2.2s cooldown). Energy regenerates at 13/sec.

The game features a full touch-compatible control scheme with on-screen D-pad and action buttons alongside keyboard controls, a particle effects system with four visual types, three pickup categories (battery for energy, repair for HP, data cache for score), and escalating difficulty where farmer stats increase every 4 rescues. The mission requires rescuing 22 cows within a 224-second time limit, with the UFO having 220 HP that depletes from farmer gunfire.

## Build and Run

```bash
moon build --target native raylib_ufo_cow_rescue_2026/
./_build/native/debug/build/raylib_ufo_cow_rescue_2026/raylib_ufo_cow_rescue_2026.exe
```

## Controls

- **W/Up**: Move UFO up
- **A/Left**: Move UFO left
- **S/Down**: Move UFO down
- **D/Right**: Move UFO right
- **J**: Activate tractor beam (hold to maintain)
- **K**: Dash burst (costs 18 energy, 1.45s cooldown)
- **L**: EMP pulse (costs 28 energy, damages nearby farmers and destroys bullets, 2.2s cooldown)
- **Enter**: Start game / return to title menu
- **R**: Restart mission
- **F11**: Toggle fullscreen
- **Touch/Mouse**: On-screen D-pad (bottom-left) for movement; BEAM, DASH, and EMP buttons (bottom-right) for abilities

## How to Play

Press Enter or tap to start. The UFO spawns in the upper portion of the screen. Cows wander on the ground; farmers patrol and shoot at you.

**Tractor Beam:** Hold J (or touch the BEAM button) while hovering above cows. Cows within 120px of the beam target (below UFO) begin rising toward the UFO. Once attached, fly the cow to the mothership (the blue ship at the top of the screen). If you release the beam while lifting, the cow drops back to the ground.

**Rescuing:** Deliver attached cows to the mothership by flying near it (within 96px horizontally while y < 116). Each rescue awards 120 + combo * 8 points and increments the combo. The mission requires 22 rescues.

**Farmers:** Ground enemies that patrol near cows and the UFO. They fire bullets that deal 11 + level * 1.4 damage every 0.86-1.5 seconds when within 260px of the UFO. Farmers can also seize ground cows within 18px, counting as missed rescues and resetting combo. Use EMP (L key) to deal 36 + level * 2 damage to farmers within 180px and panic them for 1.1s.

**Pickups:** Three types spawn periodically on the ground: Battery (blue, restores 26 energy), Repair (red, restores 24 HP), and Data Cache (yellow, awards 64 score). Pickups are collected by flying the UFO's beam area (34px radius) near them.

**Difficulty:** Level increases every 4 rescues, making farmers tougher (higher HP) and their bullets more damaging.

**Win condition:** Rescue 22 cows. **Lose conditions:** UFO HP reaches 0, or the 224-second timer expires.

## Public API Reference

### Package `raylib_ufo_cow_rescue_2026`

> Main entry point and complete game implementation.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Ufo` | `x`, `y`, `vx`, `vy`, `hp`, `energy`, `beam_t`, `dash_t`, `dash_cd`, `emp_cd`, `flash_t`, `score`, `combo`, `rescued` | Player-controlled UFO with physics, abilities, and scoring |
| `Cow` | `active`, `x`, `y`, `vx`, `state`, `t`, `panic_t` | A cow entity; state 0 = ground, 1 = being lifted, 2 = attached to UFO |
| `Farmer` | `active`, `x`, `y`, `vx`, `hp`, `fire_cd`, `panic_t` | Ground enemy that patrols, shoots, and seizes cows |
| `Bullet` | `active`, `x`, `y`, `vx`, `vy`, `dmg`, `life` | Projectile fired by farmers toward the UFO |
| `Pickup` | `active`, `x`, `y`, `kind`, `t` | Collectible item; kind 0 = battery, 1 = repair, 2 = data cache |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `size`, `t`, `life`, `kind` | Visual particle effect; kind 0-3 for different colors |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to a range |
| `absf` | `(Float) -> Float` | Absolute value of a float |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared Euclidean distance between two points |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside a rectangle (for touch button detection) |
| `randf` | `(Float, Float) -> Float` | Random float in the given range |
| `clear_cows` | `(Array[Cow]) -> Unit` | Deactivates all cows in the pool |
| `clear_farmers` | `(Array[Farmer]) -> Unit` | Deactivates all farmers in the pool |
| `clear_bullets` | `(Array[Bullet]) -> Unit` | Deactivates all bullets in the pool |
| `clear_pickups` | `(Array[Pickup]) -> Unit` | Deactivates all pickups in the pool |
| `clear_particles` | `(Array[Particle]) -> Unit` | Deactivates all particles in the pool |
| `spawn_particle` | `(Array[Particle], Float, Float, Float, Int) -> Unit` | Creates a single particle at position with speed and kind |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Spawns multiple particles at once for visual effects |
| `spawn_cow` | `(Array[Cow]) -> Bool` | Spawns a cow at a random ground position |
| `spawn_farmer` | `(Array[Farmer], Int) -> Bool` | Spawns a farmer with HP scaled by level |
| `spawn_enemy_bullet` | `(Array[Bullet], Float, Float, Float, Float, Float) -> Bool` | Fires a bullet from a position toward a target at 320 speed |
| `spawn_pickup` | `(Array[Pickup]) -> Bool` | Spawns a random pickup type on the ground |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | 1280 | Window width |
| `sh` | `Int` | 760 | Window height |
| `ground_y` | `Float` | 648.0 | Y position of the ground level |
| `world_w` | `Float` | 1280.0 | World bounds width |
| `world_h` | `Float` | 760.0 | World bounds height |
| `max_cows` | `Int` | 96 | Object pool size for cows |
| `max_farmers` | `Int` | 72 | Object pool size for farmers |
| `max_bullets` | `Int` | 420 | Object pool size for bullets |
| `max_pickups` | `Int` | 80 | Object pool size for pickups |
| `max_particles` | `Int` | 960 | Object pool size for particles |

#### Game State Variables (in `main`)

| Variable | Type | Initial | Description |
|----------|------|---------|-------------|
| `state` | `Int` | 0 | Game state: 0 = title, 1 = playing, 2 = win, 3 = lose |
| `level` | `Int` | 1 | Current difficulty level (increases every 4 rescues) |
| `timer` | `Float` | 224.0 | Mission countdown timer |
| `target` | `Int` | 22 | Number of cows needed to win |
| `kills` | `Int` | 0 | Farmers neutralized |
| `missed` | `Int` | 0 | Cows seized by farmers |

## Architecture

### Package Structure

```
raylib_ufo_cow_rescue_2026/
├── main.mbt              -- Complete game: all structs, physics, AI, abilities, spawning, rendering
└── moon.pkg              -- Package config (is-main, imports raylib and math)
```

Single-file architecture containing all 1560+ lines of game logic and rendering.

### Data Flow

1. **Input:** Keyboard and touch input are merged each frame. Touch uses `inside_rect` to check virtual button regions. Movement keys produce acceleration vectors; ability keys trigger beam, dash, or EMP.
2. **UFO physics:** Acceleration is applied to velocity, velocity is damped by drag (2.6/s), and position is clamped to bounds (x: 34..1246, y: 70..420). During dash, acceleration and max speed are multiplied.
3. **Cow state machine:** State 0 (ground) -- cows wander with sinusoidal drift. If the beam is active and a cow is within 120px of the beam target, it transitions to state 1. State 1 (lifting) -- cow moves toward UFO at 4x speed; if beam is released, drops back to state 0. State 2 (attached) -- cow tracks UFO position; if near the mothership (< 96px horizontal, y < 116), the cow is rescued.
4. **Farmer AI:** Farmers move toward nearby cows or the UFO. When the beam is active, all farmers target the UFO. Farmers fire bullets every 0.86-1.5s at the UFO when within range. Farmers can seize ground cows within 18px.
5. **Spawning:** Separate cooldown timers for cows (0.72-1.44s), farmers (0.8-1.6s), and pickups (4-7s) continuously replenish entities.
6. **Rendering:** Layered drawing: sky with stars, city buildings, ground, pickups, cows, farmers, bullets, particles, UFO with beam, then HUD bars and on-screen controls.

### Key Design Patterns

- **Object pool pattern**: Six entity types (cows, farmers, bullets, pickups, particles, and the single UFO) use pre-allocated arrays with `active` flags. Pool sizes range from 72 (farmers) to 960 (particles).
- **Integer state machine**: Game state uses integer values (0-3) rather than an enum, with the UFO's `Cow.state` field also using integers (0-2) for ground/lifting/attached.
- **Merged input sources**: Keyboard and touch controls write to the same boolean flags (`move_l`, `beam_down`, etc.), enabling seamless hybrid input.
- **Lambda-based game reset**: The `reset_run` function is a closure that captures all game state, allowing clean resets without a container struct.
- **Proximity-based interactions**: All entity interactions (beam pickup, bullet hits, EMP radius, farmer seize, pickup collection) use squared distance checks via `dist2` for efficient collision detection.

## Improvement & Refinement Plan

1. **Replace integer state values with enums**: `state` uses integers 0-3 and `Cow.state` uses 0-2. Defining `GamePhase` and `CowState` enums would make the state machine logic self-documenting and prevent invalid state transitions.

2. **Extract game state into a struct**: All game variables (`state`, `level`, `timer`, `target`, etc.) are loose `let mut` bindings in `main`. Consolidating them into a `Game` struct would improve organization and eliminate the need for closures to capture state.

3. **Split into internal packages**: At 1560+ lines, `main.mbt` handles types, physics, AI, spawning, and rendering. Separating into `types`, `game`, and `render` packages would follow the pattern used by Tea Mountain Express.

4. **Add farmer type variety**: All farmers behave identically. Adding ranged snipers (longer range, slower fire), patrol guards (faster movement, lower HP), or net-launchers (immobilize cows instead of seizing) would diversify combat encounters.

5. **Implement mothership movement feedback**: The mothership (`ship_x`) bounces between x=220 and x=1060, but there is no visual indicator of where it will be. Adding a target reticle or trajectory line would help players plan delivery routes.

6. **Add a level progression system**: Currently the mission ends after 22 rescues. Adding multiple levels with different targets, time limits, and farmer densities would extend gameplay.

7. **Implement cow panic behavior**: Cows have a `panic_t` field that is set when beamed but never affects ground movement behavior. Making panicked cows run away from the UFO would add an interesting timing challenge.

8. **Add screen shake on damage**: The `flash_t` field changes UFO color briefly on hit, but there is no camera shake. Adding brief screen offset on damage would make hits feel more impactful.
