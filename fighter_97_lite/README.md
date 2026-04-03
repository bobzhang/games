# Fighter '97 Lite

Fighter '97 Lite is a 2D arcade-style fighting game inspired by KOF (King of Fighters) and other classic 90s fighting games. Set against a nighttime cityscape stage with a scrolling skyline, animated crowd, and moonlit sky, two fighters face off in best-of-three-round matches on a bounded arena floor complete with ring ropes.

The core gameplay revolves around a deep combat system featuring four attack buttons (light punch, heavy punch, light kick, heavy kick), motion-input special moves (quarter-circle-forward and dragon-punch motions), a super meter that fills through attacks and blocking, a guard meter that can be broken through sustained pressure, throws with a tech window, combo chains with damage scaling, and counter-hit mechanics. Players choose from a roster of six distinct characters -- KAI (Northern Fist), YUN (Silent Crane), LEI (Iron Wall), QIN (Night Blade), TORA (Wild Fang), and MEI (Jade Dancer) -- each with unique speed, offense, defense, and meter multipliers, plus fully individualized normal attacks, special moves, and super moves with distinct frame data, hitboxes, and properties.

The game is technically notable for its comprehensive fighting-game systems implemented entirely in MoonBit: frame-accurate action states, a direction-history buffer for motion input detection, AI with multiple behavioral modes (rush/zone/evade), hitstop/hitstun/blockstun frame calculations, cancel windows, combo decay scaling, guard-break mechanics, throw-tech resolution, a dynamic camera system with zoom and shake, and a full particle effect pipeline for hit sparks and stage dust.

## Build and Run

```bash
moon build --target native fighter_97_lite/
./_build/native/debug/build/fighter_97_lite/fighter_97_lite.exe
```

## Controls

### Player 1
- **A / D**: Walk left / right
- **W**: Jump
- **S**: Crouch
- **Double-tap A or D**: Dash backward / forward
- **F**: Light Punch (LP)
- **G**: Heavy Punch (HP)
- **H**: Light Kick (LK)
- **J**: Heavy Kick (HK)
- **LP + LK (F + H)**: Throw (close range)
- **QCF + any attack**: Quarter-circle-forward special (Down, Down-Forward, Forward + attack)
- **DP + any attack**: Dragon-punch special (Forward, Down, Down-Forward + attack)
- **QCF + HP + HK (G + J)**: Super move (requires full meter)
- **Enter**: Confirm selection

### Player 2
- **Arrow Keys**: Movement (Left/Right walk, Up jump, Down crouch)
- **Double-tap Left or Right**: Dash
- **U**: Light Punch (LP)
- **I**: Heavy Punch (HP)
- **O**: Light Kick (LK)
- **P**: Heavy Kick (HK)
- **LP + LK (U + O)**: Throw (close range)
- **Motion inputs**: Same stick motions as P1 but relative to facing direction

### System
- **Enter / Space**: Advance from title screen
- **P**: Pause / unpause during fight
- **Escape**: Return to character select
- **Space**: Toggle VS CPU / P1 vs P2 mode on select screen
- **T**: Toggle training mode on select screen
- **R**: Reset fight (training mode only)
- **F1**: Toggle debug hitbox overlay
- **Backspace**: Deselect character on select screen

## How to Play

From the title screen, press Enter to proceed to character select. Use A/D to browse the roster for Player 1 and Left/Right arrows for Player 2. Confirm with F (P1) or U (P2), or Enter for both. In VS CPU mode, P2 is automatically confirmed. Press T to enable training mode, which provides infinite meter, health regeneration, frame advantage data, and an input display overlay.

Matches are best-of-three rounds with a 99-second timer per round. Each fighter starts with 1000 HP, a guard meter (100 base plus character bonus), and 0 super meter (max 100). Reduce your opponent's health to zero or have more health when time expires to win a round. Win two rounds to win the match.

During combat, land light attacks to start combos, cancel into heavier normals during the cancel window, and chain into special or super moves for maximum damage. Combos apply damage scaling (7.5% reduction per hit, minimum 45%). Counter-hits (landing a blow during the opponent's startup frames) deal 16% bonus damage and extra hitstun. Blocking is performed by holding away from the opponent; low attacks must be blocked crouching, overhead attacks must be blocked standing. Sustained blocking depletes the guard meter -- when it breaks, the defender is left in extended hitstun.

Throws are executed with LP+LK at close range (within 68 pixels). The defender can tech a throw by also pressing LP+LK within an 8-frame window. Throws deal 118 damage and cause a hard knockdown. The round loser receives bonus super meter for the next round, while the winner gets a smaller bonus.

In training mode, press R to reset positions, and observe the frame-advantage readout and input display to practice combos and setups.

## Public API Reference

### Package `fighter_97_lite`

> Main entry point.

The main package initializes the window at 1360x768 with MSAA 4x, creates the `Game` instance, and runs the game loop at 60 FPS. It delegates update logic to `@game.update_game` and rendering to `@render.draw_game`.

### Package `fighter_97_lite/internal/types`

> Core type definitions, constants, utilities, and character roster data.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `StateTitle`, `StateSelect`, `StateIntro`, `StateFight`, `StateRoundOver`, `StateMatchOver`, `StatePause` | Game state machine driving top-level logic flow |
| `Action` | `ActionIdle`, `ActionWalkForward`, `ActionWalkBack`, `ActionCrouch`, `ActionJump`, `ActionDashForward`, `ActionDashBack`, `ActionAttack`, `ActionHitstun`, `ActionBlockstun`, `ActionKnockdown`, `ActionWakeup`, `ActionVictory`, `ActionIntro`, `ActionThrow` | Fighter action states |
| `AttackId` | `AttackNone`, `AttackLp`, `AttackHp`, `AttackLk`, `AttackHk`, `AttackSpecialQcf`, `AttackSpecialDp`, `AttackSuper` | Attack identifier for move lookup |
| `MoveKind` | `MoveKindNormal`, `MoveKindSpecial`, `MoveKindSuper` | Move category affecting meter gain, hitstop, and cancel rules |
| `AiMode` | `AiModeIdle`, `AiModeRush`, `AiModeZone`, `AiModeEvade` | CPU behavioral modes based on distance |
| `Motion` | `MotionNone`, `MotionQcf`, `MotionDp` | Buffered motion input type |
| `Direction` | `DirNeutral`, `DirUp`, `DirDown`, `DirBack`, `DirForward`, `DirDownBack`, `DirDownForward` | Relative directional input for motion detection |
| `SparkKind` | `SparkKindHit`, `SparkKindBlock`, `SparkKindSuper` | Hit spark visual type |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Game` | `state`, `frame_count`, `rng_state`, `roster`, `fighters`, `mode_vs_cpu`, `mode_training`, `round_index`, `round_timer`, `camera_x/y/zoom/shake`, `particles`, `hit_sparks`, `debug_overlay` | Central game state container holding all match data |
| `Fighter` | `slot`, `is_cpu`, `archetype_index`, `x/y/vx/vy`, `facing`, `health`, `guard_meter`, `super_meter`, `round_wins`, `action`, `action_frame`, `current_move`, `hitstop`, `hitstun`, `blockstun`, `knockdown`, `invuln`, `combo_counter`, `ai_mode`, `input` | Complete per-fighter state including position, meters, action, and AI state |
| `InputState` | `x/y`, `hold_forward/back/up/down`, `lp/hp/lk/hk_pressed`, `dir_history`, `buffered_motion`, `motion_timer`, `dash_forward/back_pressed` | Raw and processed input state with direction buffer for motion detection |
| `MoveSpec` | `attack_id`, `move_kind`, `total_frames`, `startup_frames`, `active_frames`, `recovery_frames`, `damage`, `chip_damage`, `hitstun_frames`, `blockstun_frames`, `pushback`, `launch_x/y`, `hitbox_x/y/w/h`, `knockdown`, `low_attack`, `overhead_attack`, `cancel_on_hit`, `auto_dash`, `invuln_end` | Full frame-data specification for a single attack |
| `CharacterArchetype` | `name`, `title`, `intro_quote`, `victory_quote`, `body_main/trim`, `speed_mul`, `jump_mul`, `offense_mul`, `defense_mul`, `meter_mul`, `max_guard_bonus`, `normal_lp/hp/lk/hk`, `special_qcf`, `special_dp`, `super_move` | Character template defining visuals, stats, and moveset |
| `Particle` | `active`, `x/y`, `vx/vy`, `life`, `max_life`, `size`, `growth`, `color` | Individual particle for effects |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Game::new` | `() -> Game` | Creates a new game instance with default state, builds the full roster |
| `Fighter::new` | `(Int, Bool) -> Fighter` | Creates a new fighter at the given slot with CPU flag |
| `InputState::new` | `() -> InputState` | Creates a zeroed input state with direction buffer |
| `MoveSpec::empty` | `() -> MoveSpec` | Returns a no-op move specification |
| `Particle::inactive` | `() -> Particle` | Returns a dormant particle |
| `build_roster` | `() -> Array[CharacterArchetype]` | Constructs the full 6-character roster array |
| `roster_kai` | `() -> CharacterArchetype` | Builds KAI -- balanced all-rounder |
| `roster_yun` | `() -> CharacterArchetype` | Builds YUN -- fast, high meter gain, lower defense |
| `roster_lei` | `() -> CharacterArchetype` | Builds LEI -- slow, high offense/defense, extra guard |
| `roster_qin` | `() -> CharacterArchetype` | Builds QIN -- fastest, glass cannon, highest meter gain |
| `roster_tora` | `() -> CharacterArchetype` | Builds TORA -- aggressive rushdown, slightly above average |
| `roster_mei` | `() -> CharacterArchetype` | Builds MEI -- balanced-fast, highest meter gain multiplier |
| `make_move` | `(String, AttackId, MoveKind, Int, Int, Int, Int, Int, Int, Int, Float, Float, Float, Float, Float, Float, Float, Float) -> MoveSpec` | Factory function to build a MoveSpec with computed recovery, meter gain, and cancel windows |
| `absf` | `(Float) -> Float` | Absolute value for floats |
| `clampf` | `(Float, Float, Float) -> Float` | Clamp float to range |
| `clampi` | `(Int, Int, Int) -> Int` | Clamp integer to range |
| `f` | `(Double) -> Float` | Convert Double to Float |
| `minf` | `(Float, Float) -> Float` | Minimum of two floats |
| `maxf` | `(Float, Float) -> Float` | Maximum of two floats |
| `lerpf` | `(Float, Float, Float) -> Float` | Linear interpolation between two floats |
| `approachf` | `(Float, Float, Float) -> Float` | Approach a target value by a delta step |
| `rand_next` | `(Game) -> Int` | Xorshift PRNG, returns next positive integer |
| `rand_range` | `(Game, Int, Int) -> Int` | Random integer in [low, high] |
| `rand_rangef` | `(Game, Float, Float) -> Float` | Random float in [low, high] |
| `rand_chance` | `(Game, Float) -> Bool` | Returns true with probability p |
| `fighter_archetype` | `(Game, Fighter) -> CharacterArchetype` | Look up the character archetype for a fighter |
| `other_slot` | `(Int) -> Int` | Returns the other player slot (0 -> 1, 1 -> 0) |
| `facing_sign` | `(Int) -> Float` | Returns -1.0 or 1.0 based on facing direction |
| `stage_clamp_x` | `(Float) -> Float` | Clamps an x position to the stage boundaries |
| `fighter_distance_x` | `(Fighter, Fighter) -> Float` | Horizontal distance between two fighters |
| `hurtbox_for` | `(Fighter) -> Rectangle` | Returns the defensive hurtbox, accounting for crouch |
| `attack_hitbox_for` | `(Fighter, MoveSpec) -> Rectangle` | Returns the offensive hitbox in world space |
| `draw_shadow_text` | `(String, Int, Int, Int, Color) -> Unit` | Draws text with a black drop shadow |
| `draw_center_shadow_text` | `(String, Int, Int, Int, Color) -> Unit` | Draws horizontally centered text with shadow |
| `countdown_color` | `(Float) -> Color` | Returns white/gold/red based on timer urgency |
| `fighter_total_guard` | `(CharacterArchetype) -> Int` | Returns total guard meter (base + character bonus) |
| `action_name` | `(Action) -> String` | Debug string for an action state |
| `add_meter` | `(Fighter, Int, CharacterArchetype) -> Unit` | Adds super meter scaled by character multiplier |
| `add_guard` | `(Fighter, Float, CharacterArchetype) -> Unit` | Adds guard meter clamped to character max |
| `reset_fighter_round_state` | `(Fighter) -> Unit` | Resets all transient fighter state for a new round |
| `health_ratio` | `(Fighter) -> Float` | Returns health as a 0.0-1.0 ratio |
| `meter_ratio` | `(Fighter) -> Float` | Returns super meter as a 0.0-1.0 ratio |
| `guard_ratio` | `(Fighter, CharacterArchetype) -> Float` | Returns guard meter as a 0.0-1.0 ratio |
| `throw_input_pressed` | `(InputState) -> Bool` | Detects LP+LK throw input |
| `fighter_is_throw_vulnerable` | `(Fighter) -> Bool` | Returns true if the fighter can be thrown |
| `signed_frames_text` | `(Int) -> String` | Formats frame advantage with +/- sign |
| `set_training_note` | `(Game, String) -> Unit` | Displays a training-mode info note |
| `set_training_frame_adv` | `(Game, Int, String, Int) -> Unit` | Displays frame advantage data in training mode |
| `screen_center_xf` | `() -> Float` | Screen center X as float |
| `screen_center_yf` | `() -> Float` | Screen center Y as float |
| `camera_project_x` | `(Game, Float) -> Float` | Projects a world X coordinate through the camera |
| `camera_project_y` | `(Game, Float) -> Float` | Projects a world Y coordinate through the camera |
| `camera_project_size` | `(Game, Float) -> Float` | Scales a size value by camera zoom |

### Package `fighter_97_lite/internal/game`

> Game logic: input handling, action system, combat resolution, AI, throws, and round management.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Top-level update dispatcher, routes to state-specific handlers |

Internal (non-pub) systems include:

- **input_system.mbt**: `sample_human_input` reads keyboard state for P1/P2, detects motion inputs (QCF/DP) from the 42-entry direction history buffer, manages dash detection via double-tap timers, and buffers attacks. `update_cpu_input` drives AI-controlled fighters. `update_inputs` dispatches per-slot.
- **action_system.mbt**: `update_fighter_core` orchestrates per-fighter per-frame logic -- recovery state, stun/knockdown, jump, walk/crouch, attack initiation, action frame advancement, and physics integration. `try_start_attack` resolves motion inputs into the correct move and handles super activation with dramatic freeze.
- **combat_system.mbt**: `update_combat` checks both attack directions. `process_attack_contact` tests hitbox-hurtbox collision, determines block vs. hit, and delegates to `apply_successful_hit` (damage, hitstun, knockdown, combo tracking, counter-hit bonus) or `apply_blocked_hit` (chip damage, guard damage, guard break).
- **throw_system.mbt**: `update_throws` resolves simultaneous throw attempts with tech resolution, applies throw damage (118), knockdown, and corner-adjusted horizontal velocity.
- **ai_system.mbt**: CPU AI runs on a think timer (~100ms), selects mode by distance (rush/zone/evade), picks movement direction, decides when to block, attempts throws, specials, supers, or normals based on probability rolls.
- **round_system.mbt**: Manages `update_title`, `update_select`, `update_intro`, `update_fight`, `update_round_over`, `update_match_over`, `update_pause`. Handles round timer countdown, winner determination, round/match transitions, character selection, training mode resets, and meter carryover between rounds.

### Package `fighter_97_lite/internal/render`

> All drawing and visual presentation.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_game` | `(Game) -> Unit` | Top-level render dispatcher, draws stage, fighters, HUD, and state-specific overlays |

Internal rendering systems include:

- **render_stage.mbt**: Draws the multi-layer parallax city backdrop (4 city layers with buildings and window lights), animated starfield sky with moon, crowd silhouettes with bobbing animation, stage floor with perspective lines and ring ropes, and stage flash effects for super activations.
- **render_fighter.mbt**: Draws each fighter with a procedural body (torso rectangle, head circle, arm lines with punch extension, legs with stride animation), shadow ellipse, hitbox aura during active frames, victory glow effect, nameplate, and combo counter.
- **render_ui.mbt**: Draws the full fight HUD (health bars, super meter, guard meter, round win markers, timer), announcer text with bounce animation, training mode overlays (input display panel, frame advantage panel), character select screen with stat cards, title screen with control legend, round/match over screens with victory quotes, pause overlay, and debug overlay showing fighter state.

### Package `fighter_97_lite/internal/effects`

> Particle systems and camera dynamics.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `push_camera_shake` | `(Game, Float) -> Unit` | Adds camera shake intensity, capped at 18.0 |
| `allocate_particle_slot` | `(Array[Particle]) -> Int` | Finds first inactive particle slot, returns -1 if full |
| `spawn_stage_dust` | `(Game, Float, Float, Float, Float, Color) -> Unit` | Spawns a ground dust particle with random size and growth |
| `spawn_hit_spark` | `(Game, Float, Float, SparkKind, Int) -> Unit` | Spawns radial hit sparks (hit/block/super variants) at impact point |
| `spawn_ground_skid` | `(Game, Fighter) -> Unit` | Spawns 3 dust particles at a fighter's feet on hit |
| `update_particle_list` | `(Array[Particle], Float) -> Unit` | Advances all active particles (gravity, friction, lifetime) |
| `draw_particle_list` | `(Array[Particle], Float, Float) -> Unit` | Renders all active particles with alpha fade |
| `update_particles` | `(Game, Float) -> Unit` | Updates both stage particles and hit sparks |
| `draw_particles` | `(Game) -> Unit` | Draws both particle pools |
| `update_camera` | `(Game, Float) -> Unit` | Smoothly tracks the midpoint between fighters, adjusts zoom by distance, applies sinusoidal shake decay |

## Architecture

### Package Structure

```
fighter_97_lite/
├── main.mbt                          — Entry point: window init, game loop (60 FPS)
├── moon.pkg                          — Root package config, imports types/game/render
└── internal/
    ├── types/
    │   ├── types.mbt                 — All enums, structs (Game, Fighter, MoveSpec, etc.)
    │   ├── constants.mbt             — ~120 tuning constants (frame data, physics, UI layout)
    │   ├── utils.mbt                 — Math helpers, RNG, hitbox/hurtbox computation, UI text
    │   ├── character_roster.mbt      — 6 character definitions with full movesets
    │   └── moon.pkg                  — Imports core/math, raylib
    ├── game/
    │   ├── action_system.mbt         — Fighter state machine, attack initiation, physics
    │   ├── input_system.mbt          — Keyboard sampling, motion detection, dash detection
    │   ├── combat_system.mbt         — Hit/block resolution, damage calculation, guard break
    │   ├── throw_system.mbt          — Throw attempt, tech resolution, corner adjustment
    │   ├── ai_system.mbt             — CPU opponent behavioral AI (rush/zone/evade modes)
    │   ├── round_system.mbt          — State transitions, round/match flow, character select
    │   └── moon.pkg                  — Imports types, effects, raylib, core/math
    ├── render/
    │   ├── render_stage.mbt          — Multi-layer parallax city, sky, crowd, floor, ropes
    │   ├── render_fighter.mbt        — Procedural fighter drawing, hitbox overlay, shadows
    │   ├── render_ui.mbt             — HUD, menus, announcer, training panels, debug overlay
    │   └── moon.pkg                  — Imports types, effects, raylib, core/math
    └── effects/
        ├── effects.mbt              — Particle pools, camera tracking, shake, zoom
        └── moon.pkg                  — Imports types, raylib, core/math
```

The architecture follows a clean ECS-like separation: `types` holds all data definitions and pure utilities with no side effects; `game` contains all mutation logic; `render` is read-only over game state; `effects` manages visual side effects (particles, camera). The main loop simply calls `update_game` then `draw_game` each frame.

### Data Flow

1. `main.mbt` calls `@game.update_game(game, dt)` each frame
2. `update_game` dispatches based on `game.state` to the appropriate handler (e.g., `update_fight`)
3. `update_fight` calls `update_inputs` which samples keyboard or runs AI per fighter via `sample_human_input` / `update_cpu_input`
4. The action system (`update_fighter_core`) processes each fighter: recovery timers, stun resolution, jump/walk/crouch state, attack initiation through `try_start_attack` which reads buffered motions from the direction history
5. `resolve_push_collision` and `update_facing` ensure spatial consistency
6. `update_throws` checks for throw attempts before `update_combat` resolves attack hitbox-hurtbox collisions
7. `apply_successful_hit` / `apply_blocked_hit` modify defender state, spawn particles via `@effects.spawn_hit_spark`, and trigger camera shake via `@effects.push_camera_shake`
8. `@effects.update_camera` smoothly tracks fighters and decays shake
9. `main.mbt` calls `@render.draw_game(game)` which draws stage, fighters, HUD, and overlays in order

### Key Design Patterns

- **Object pool pattern**: Pre-allocated arrays with `active` flags for both `particles` (860 slots) and `hit_sparks` (360 slots), avoiding runtime allocation during combat
- **State machine**: `GameState` enum drives top-level flow; `Action` enum drives per-fighter behavior with frame-accurate transitions
- **Direction history buffer**: A circular buffer of 42 directional inputs enables motion detection (QCF, DP) by scanning recent history for sequential direction patterns
- **Frame-data-driven combat**: All attacks are defined as `MoveSpec` structs with explicit startup, active, and recovery frames; hitbox dimensions; cancel windows; and damage/hitstun values, mirroring real fighting game design
- **Character archetype system**: Each fighter is a `CharacterArchetype` containing stat multipliers and a complete moveset, allowing easy roster expansion
- **Deterministic PRNG**: A xorshift RNG seeded per game instance ensures reproducible behavior, especially for AI decisions
- **Camera system**: Dynamic zoom (close/base/far based on distance) with sinusoidal shake offset and smooth lerp tracking

## Improvement & Refinement Plan

1. **Projectile system**: The current roster has no ranged attacks. Adding a `Projectile` struct pool (similar to particles) with per-character projectile specs in `CharacterArchetype` would enable zoning characters and increase strategic depth.

2. **Audio integration**: The game has detailed visual feedback (hit sparks, camera shake, announcer text) but no sound. Adding hit sounds, block sounds, super activation cues, and crowd reactions tied to the existing `SparkKind` and announcer events would significantly enhance game feel.

3. **Combo route validation**: `can_cancel_current_move` allows normals to cancel freely within the cancel window. Adding a `cancel_into` field to `MoveSpec` (e.g., normals cancel only into specials/supers, not other normals) would prevent unintended infinite chains and better match traditional fighting game design.

4. **Air combat expansion**: Currently `airborne_only` and `crouch_only` fields exist on `MoveSpec` but no character uses them. Defining air normals and crouching-specific attacks would expand the offensive toolkit and reward spatial awareness.

5. **Guard meter visibility**: The guard meter is displayed but its depletion rate and recovery mechanics are not communicated to the player. Adding a guard-flash visual on the fighter body when guard is low (similar to the existing `flash_timer` system) and a training-mode guard meter readout would help players understand this system.

6. **AI difficulty scaling**: The CPU uses fixed probability constants (`cpu_block_chance = 0.64`, `cpu_special_chance = 0.22`, etc.). Exposing a difficulty setting that modifies these values and `cpu_reaction_base` would allow players of different skill levels to enjoy the single-player experience.

7. **Input display for replays**: The `InputState` direction history buffer (`dir_history`) already stores 42 frames of input. Extending this to store a full round of inputs would enable a replay system, which is standard in competitive fighting games.

8. **Character-specific AI**: Currently all CPU fighters use the same AI logic. Leveraging the `CharacterArchetype` stat multipliers (e.g., making LEI's AI prefer blocking due to his high `defense_mul`, or QIN's AI more aggressive due to high `speed_mul`) would create more distinct CPU personalities.
