# Festival Lion Dance Defense 2026

A lane-defense action game set during a festival parade. You control a lion dance troupe moving freely across 6 horizontal lanes to intercept two types of threats: firecrackers (fast, directly clearable) and crowd incidents (must be stunned first, then struck). The troupe has three actions: Strike (J) clears firecrackers and stunned incidents in a radius, Guard (K) stuns nearby incidents and deflects firecrackers on contact, and Hype Burst (Space) consumes hype meter to clear everything in a large radius.

The game tracks three meters: Hype (built by clearing threats in combos, spent on burst), Crowd Order (recovers over time, drains when threats leak or hit the troupe, triggers morale drain below a threshold), and Morale (the health bar -- when it hits zero the parade is over). Threat spawn rate and speed scale with elapsed time, creating steadily increasing pressure. Chaining clears builds a combo multiplier that boosts score, hype gains, and order recovery. Missing a strike resets the combo.

The visual style features a dark festival atmosphere with glowing lantern-like background effects, lane-based street layout, animated threat sprites, expanding action effect rings, and screen shake/flash on impacts.

## Build and Run

```bash
moon build --target native festival_lion_dance_defense_2026/
./_build/native/debug/build/festival_lion_dance_defense_2026/festival_lion_dance_defense_2026.exe
```

## Controls

- **WASD / Arrow Keys**: Move the troupe across lanes and along the street
- **J**: Strike -- clears firecrackers and stunned incidents within strike radius
- **K**: Guard -- stuns nearby incidents, raises guard stance that deflects firecrackers on contact
- **Space**: Hype Burst -- spends 62 hype to clear all threats within a large radius (6.2s cooldown)
- **P**: Pause / Resume
- **R**: Restart run
- **J / Enter / Space**: Start game from title screen

## How to Play

1. **Move the troupe**: Use WASD or arrow keys to position the lion dance troupe across the 6 lanes. Movement is free (not snapped to lanes), allowing diagonal positioning. Speed is 620 units/sec.
2. **Strike firecrackers**: Press J to perform a drum strike that clears all firecrackers within a 132-unit radius. Firecrackers are red/orange circles that move left across the lanes. They can be struck directly without preparation.
3. **Stun then strike incidents**: Crowd incidents (amber blobs) cannot be struck directly. Press K to Guard, which stuns all incidents within 150 units for 1.8 seconds (turning them blue). Once stunned, they can be cleared with a Strike. Stunned incidents move at 30% speed.
4. **Guard stance on contact**: While the guard animation is active (0.4s), contact with a firecracker auto-clears it, and contact with an incident stuns and pushes it back.
5. **Build combos**: Each cleared threat increments the combo counter (resets after 2.6 seconds without a clear or on a missed strike). Higher combos grant bonus score (+16 per combo level), extra hype (+1.6 per level), and faster order recovery.
6. **Use Hype Burst**: When hype reaches 62+, press Space to unleash a burst that clears all threats within a 320-unit radius for 0.92 seconds. The burst has a 6.2-second cooldown.
7. **Manage crowd order**: Order recovers at 2.2/sec naturally and gains +2.0 per cleared threat. Leaked threats and troupe contact drain order (11-16 for leaks, 6-9 for contact). When order drops below 42, morale starts draining proportionally.
8. **Survive**: The run ends when morale reaches zero. Threat spawn rate decreases from 1.0s to 0.24s over time, and threat speed increases up to +240 bonus. The goal is to maximize score and survival time.

**Scoring**: Firecrackers = 120 base, Incidents = 170 base. Guard clears reduce score by 14, burst clears by 24. Stunned bonus +28. Combo multiplier +16 per level. Guard stun awards 24 points.

## Public API Reference

### Package `festival_lion_dance_defense_2026`

> Main entry point.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Entry point: creates 1600x960 window with MSAA 4x, 120 FPS, runs update/render loop |

### Package `festival_lion_dance_defense_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Playing`, `Paused`, `GameOver` | Game state machine states |
| `Action` | `Strike`, `Guard`, `Burst` | Types of player actions for scoring differentiation |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `InputState` | `move_x`, `move_y`, `press_strike`, `press_guard`, `press_burst`, `press_pause`, `press_restart`, `press_start` | Per-frame input state with movement direction and action presses |
| `Threat` | `active`, `kind`, `x`, `y`, `speed`, `radius`, `stun_t`, `spin` | A threat entity (firecracker or incident) moving left across lanes with optional stun timer and spin animation |
| `Game` | `input`, `threats`, `state`, `troupe_x/y`, `troupe_lane`, `score`, `best_score`, `cleared`, `leaked`, `combo`, `combo_t`, `hype`, `morale`, `crowd_order`, `strike_cd/t`, `guard_cd/t`, `burst_cd/t`, `spawn_t`, `elapsed`, `flash_t`, `shake_t`, `msg`, `msg_t`, `time_s` | Main game state with troupe position, meters, action cooldowns, spawn timer, and UI state |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1600` | Window width |
| `screen_h` | `Int` | `960` | Window height |
| `target_fps` | `Int` | `120` | Target frame rate |
| `threat_firecracker` | `Int` | `0` | Firecracker threat type (directly clearable) |
| `threat_incident` | `Int` | `1` | Incident threat type (must be stunned first) |
| `lane_count` | `Int` | `6` | Number of horizontal lanes |
| `lane_top` | `Int` | `170` | Y position of top lane start |
| `lane_gap` | `Int` | `108` | Vertical gap between lane centers |
| `lane_height` | `Int` | `70` | Visual height of each lane |
| `street_left` | `Int` | `120` | Left boundary of the street |
| `street_right` | `Int` | `1480` | Right boundary of the street |
| `troupe_w` | `Float` | `96.0` | Troupe width for collision |
| `troupe_move_speed` | `Float` | `620.0` | Troupe movement speed |
| `troupe_start_lane` | `Int` | `2` | Starting lane index |
| `max_threats` | `Int` | `96` | Maximum threat pool size |
| `spawn_time_start` | `Float` | `1.00` | Initial spawn interval |
| `spawn_time_floor` | `Float` | `0.24` | Minimum spawn interval |
| `spawn_difficulty_ramp` | `Float` | `0.010` | Spawn interval reduction per second elapsed |
| `firecracker_speed_base` | `Float` | `350.0` | Base firecracker speed |
| `incident_speed_base` | `Float` | `260.0` | Base incident speed |
| `speed_scale_max_bonus` | `Float` | `240.0` | Maximum speed bonus from elapsed time |
| `strike_radius` | `Float` | `132.0` | Strike action radius |
| `strike_cd_time` | `Float` | `0.24` | Strike cooldown |
| `strike_fx_time` | `Float` | `0.15` | Strike visual effect duration |
| `guard_radius` | `Float` | `150.0` | Guard stun radius |
| `guard_cd_time` | `Float` | `0.72` | Guard cooldown |
| `guard_hold_time` | `Float` | `0.40` | Guard active stance duration |
| `guard_stun_time` | `Float` | `1.80` | Duration of guard stun on incidents |
| `burst_cost` | `Float` | `62.0` | Hype cost for burst |
| `burst_duration` | `Float` | `0.92` | Burst active duration |
| `burst_radius` | `Float` | `320.0` | Burst clear radius |
| `burst_cd_time` | `Float` | `6.2` | Burst cooldown |
| `hype_max` | `Float` | `100.0` | Maximum hype meter |
| `morale_max` | `Float` | `100.0` | Maximum morale |
| `order_max` | `Float` | `100.0` | Maximum crowd order |
| `morale_start` | `Float` | `82.0` | Starting morale |
| `order_start` | `Float` | `84.0` | Starting crowd order |
| `combo_keep_time` | `Float` | `2.6` | Seconds before combo resets without a clear |
| `order_gain_on_clear` | `Float` | `2.0` | Base order gain per cleared threat |
| `order_recover_rate` | `Float` | `2.2` | Passive order recovery per second |
| `order_pressure_threshold` | `Float` | `42.0` | Order level below which morale drains |
| `order_pressure_drain_rate` | `Float` | `0.29` | Morale drain multiplier when order is below threshold |
| `breach_order_loss_firecracker` | `Float` | `11.0` | Order loss when firecracker leaks past street |
| `breach_order_loss_incident` | `Float` | `16.0` | Order loss when incident leaks past street |
| `breach_morale_loss_firecracker` | `Float` | `7.0` | Morale loss on firecracker breach |
| `breach_morale_loss_incident` | `Float` | `10.0` | Morale loss on incident breach |
| `collision_morale_loss_firecracker` | `Float` | `8.0` | Morale loss on firecracker contact with troupe |
| `collision_morale_loss_incident` | `Float` | `11.0` | Morale loss on incident contact with troupe |
| `score_firecracker` | `Int` | `120` | Base score for clearing a firecracker |
| `score_incident` | `Int` | `170` | Base score for clearing an incident |
| `score_guard_stun` | `Int` | `24` | Score for stunning an incident with guard |
| `hype_gain_firecracker` | `Float` | `8.0` | Hype gained from clearing a firecracker |
| `hype_gain_incident` | `Float` | `12.0` | Hype gained from clearing an incident |
| `hype_gain_guard_stun` | `Float` | `4.0` | Hype gained from stunning an incident |
| `hype_gain_combo_step` | `Float` | `1.6` | Additional hype per combo level |
| `msg_ttl` | `Float` | `1.6` | Default message display time |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `InputState::new` | `() -> InputState` | Creates a zeroed input state |
| `Threat::new` | `() -> Threat` | Creates an inactive firecracker threat |
| `Game::new` | `() -> Game` | Creates a new game in Title state with all defaults |
| `street_w` | `() -> Int` | Returns playable street width (street_right - street_left) |
| `street_h` | `() -> Int` | Returns total street height across all lanes |
| `lane_y` | `(Int) -> Float` | Returns Y center position for a lane index |
| `lane_from_y` | `(Float) -> Int` | Returns nearest lane index for a Y position |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between bounds |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between bounds |
| `maxf` | `(Float, Float) -> Float` | Returns maximum of two floats |
| `minf` | `(Float, Float) -> Float` | Returns minimum of two floats |
| `squaref` | `(Float) -> Float` | Squares a float value |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two 2D points |
| `randf` | `(Float, Float) -> Float` | Random float in [lo, hi] using raylib RNG |
| `set_msg` | `(Game, String, Float) -> Unit` | Sets the on-screen message with a display duration |
| `pulse` | `(Game, Float) -> Float` | Returns a 0-1 sine pulse at the given frequency using game time |

### Package `festival_lion_dance_defense_2026/internal/game`

> Game logic, input handling, and state management.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Top-level update: reads input, dispatches to state-specific logic (Title/Playing/Paused/GameOver) |

### Package `festival_lion_dance_defense_2026/internal/render`

> Rendering and visual effects.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main render entry point: draws background with lantern glows, lanes with labels, threats (firecrackers as circles with cross rays, incidents as blob clusters), action effect rings, troupe with guard aura, HUD with three meters, controls legend, message bar, and state overlays |

## Architecture

### Package Structure

```
festival_lion_dance_defense_2026/
├── main.mbt              — Entry point: window init, game loop
├── moon.pkg              — Package config, imports
└── internal/
    ├── types/
    │   ├── types.mbt     — Enums (GameState, Action), structs (InputState, Threat, Game), constructors
    │   ├── constants.mbt — Tuning constants (screen, lanes, troupe, threats, actions, meters, scoring)
    │   └── utils.mbt     — Math utilities (clamp, dist, randf), lane helpers, message setter, pulse
    ├── game/
    │   ├── input.mbt     — Keyboard input reading into InputState
    │   └── logic.mbt     — Threat spawning/movement, troupe movement, strike/guard/burst actions, combo tracking, order/morale pressure, difficulty scaling, state transitions
    └── render/
        └── render.mbt    — All drawing: background with glow circles, lanes, firecrackers (circle+rays), incidents (blob cluster), troupe (lion shape with eyes), action FX rings, HUD meters, controls legend, message bar, title/pause/game over overlays
```

The `types` package is the shared foundation with no game logic. The `game` package imports `types` and handles all simulation. The `render` package imports `types` (but not `game`) and performs read-only rendering from the `Game` struct.

### Data Flow

1. **Input**: `update_input` reads keyboard state and populates `game.input` (an `InputState` struct) each frame, then clears previous frame state.
2. **Update**: `update_game` dispatches based on `game.state`. In `Playing` mode, `update_playing_state` sequences: action timer decay, troupe movement, guard/strike/burst handling, threat spawning (interval shrinks with elapsed time), threat movement with stun slowdown and contact/breach checks, burst field application, order pressure and morale drain, and game-over check.
3. **Threat System**: Threats spawn at the right edge of the street in random lanes. Spawn interval decreases from 1.0s to 0.24s (rate = start - elapsed x 0.01). Speed increases with a bonus up to +240. Incidents have a 24-62% spawn chance that increases over time. Threats move left; stunned threats move at 30% (incidents) or 55% (firecrackers) speed.
4. **Action System**: Strike checks all threats within radius for clearability (firecrackers always, incidents only if stunned). Guard stuns incidents within radius and activates a passive deflection stance. Burst clears everything in a large radius each frame for its duration. All actions have separate cooldown timers.
5. **Scoring and Meters**: Each clear registers a combo step, awards score (base + combo bonus - action penalty + stun bonus), grants hype, and recovers order. Leaked or contacted threats drain order and morale, reset combo. When order drops below 42, morale drains proportionally. Morale reaching zero triggers game over.
6. **Render**: `draw_frame` layers: gradient background with animated glow circles, lane grid with labels, threat sprites (firecrackers as circles with cross-pattern rays, incidents as blob clusters with stun aura), expanding action effect rings, troupe body with guard ring overlay, HUD panel with score/combo/meters, controls legend bar, fading message bar, and state overlays (title card, pause panel, game over summary).

### Key Design Patterns

- **Object pool pattern**: Threats array of 96 slots with `active` flags and linear scan allocation.
- **State machine**: `GameState` enum with clean transitions. Playing state handles all gameplay; Title/Paused/GameOver are overlay states.
- **Dual-threat system**: Two threat types with different clearance rules (direct vs stun-then-strike) creates tactical depth and forces action variety.
- **Triple-meter pressure**: Hype (resource to spend), Order (environmental health), and Morale (player health) create interconnected resource management where neglecting crowd order cascades into morale loss.
- **Combo system**: Time-limited combo chain with score/hype/order bonuses incentivizes aggressive, rhythmic play. Missed strikes punish by resetting the chain.
- **Continuous difficulty scaling**: Both spawn interval and threat speed scale with elapsed time using clamped linear functions, providing smooth difficulty increase without discrete waves.
- **Separation of concerns**: Input, logic, and rendering are cleanly separated. The render package only reads game state and never modifies it.

## Improvement & Refinement Plan

1. **Add particle effects for threat clears**: Currently threat clearing is immediate with no visual feedback beyond the flash overlay. Adding burst particles at the cleared threat's position would make combat feel more impactful.
2. **Implement threat variety beyond two types**: The dual-threat system is solid but could be extended with additional threat types (e.g., a fast threat that zigzags between lanes, or a large threat that requires multiple strikes).
3. **Add power-up drops**: Cleared threats could occasionally drop power-ups (temporary speed boost, wider strike radius, instant hype refill) to reward skillful play and add variety.
4. **Replace integer threat kinds with an enum**: `threat_firecracker` and `threat_incident` are integer constants. Using a proper enum would enable exhaustive match checking in the action handlers.
5. **Add audio feedback**: The game has no sound. Adding drum beat sounds for strikes, gong for guard, and crowd roar for hype burst would greatly enhance the festival atmosphere.
6. **Implement touch/mobile input**: The game only supports keyboard input. Adding touch regions for the three actions and swipe-based lane movement would enable mobile play.
7. **Add progressive wave structure**: The current continuous difficulty ramp could be supplemented with wave-based structure (e.g., every 30 seconds, a named "wave" with specific threat patterns) to give the player milestone goals.
