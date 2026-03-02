# raylib_dragon_scroll_keeper_2026

A wave-based defense game set in a dragon scroll vault. As the Keeper, defend the vault's scroll integrity across three interconnected chambers by fighting raiders, extinguishing fires, and sealing breaches.

## Build and Run

```bash
moon build --target native raylib_dragon_scroll_keeper_2026/
./_build/native/debug/build/raylib_dragon_scroll_keeper_2026/raylib_dragon_scroll_keeper_2026.exe
```

## Controls

- **WASD / Arrow keys**: Move the Keeper between chambers
- **J**: Attack raiders / Seal breaches
- **K**: Toggle extinguisher mode (switch between combat and fire-fighting)
- **L**: Deploy ink shield (area damage + fire suppression)
- **P**: Pause
- **R**: Restart
- **F11**: Toggle borderless windowed

## How to Play

- Protect scroll integrity from raiders who invade through breaches and fires that spread between rooms
- Attack raiders in combat mode; switch to extinguisher mode to quench flames
- Seal breaches with seal charges to prevent more raiders and embers from spawning
- Deploy ink shields for emergency area defense (limited stock, long cooldown)
- Survive escalating waves; each wave grants additional seal charges

## Public API Reference

### Package `tonyfettes/raylib-examples/raylib_dragon_scroll_keeper_2026`

Entry point. Initialises a 1366x768 window at 120 fps, allocates `Game::new()`, and drives the game loop by calling `update_game` and `draw_frame` each frame inside `@raylib.begin_drawing` / `@raylib.end_drawing`.

### Package `.../internal/types`

#### Enums

| Enum | Variants |
|---|---|
| `GameState` | `Title`, `Playing`, `Paused`, `GameOver` |

#### Structs

| Struct | Key fields |
|---|---|
| `Breach` | `room : Int`, `severity : Float`, `raider_cd : Float`, `ember_cd : Float` |
| `Raider` | `active`, `room`, `x`, `y`, `hp`, `max_hp`, `panic_t`, `attack_cd` |
| `Flame` | `active`, `room`, `x`, `y`, `intensity : Float`, `spread_cd : Float` |
| `Keeper` | `room`, `x`, `y`, `facing_x`, `facing_y`, `stamina`, `extinguisher_mode`, `action_cd`, `shield_cd`, `shield_t`, `ink_shields` |
| `Game` | `breaches`, `raiders`, `flames`, `keeper`, `state`, `wave`, `wave_t`, `wave_goal_t`, `breach_event_cd`, `scroll_integrity`, `seal_charges`, `score`, `best_score`, `raiders_defeated`, `flames_cleared`, `seals_done`, `time_s`, `message`, `message_t`, input fields |

#### Functions

| Function | Description |
|---|---|
| `pub fn Breach::new(room : Int) -> Breach` | Creates a breach for the given room with randomised cooldowns |
| `pub fn Raider::new() -> Raider` | Returns an inactive raider placeholder |
| `pub fn Flame::new() -> Flame` | Returns an inactive flame placeholder |
| `pub fn Keeper::new() -> Keeper` | Creates a keeper starting in the Vault Core at full stamina |
| `pub fn Game::new() -> Game` | Allocates a full game session with pre-built object pools |
| `pub fn breach_anchor_x(room : Int) -> Float` | World-space X of the breach hotspot for a given room |
| `pub fn breach_anchor_y(room : Int) -> Float` | World-space Y of the breach hotspot for a given room |
| `pub fn chamber_center_x() -> Float` | X centre of the shared chamber viewport |
| `pub fn chamber_center_y() -> Float` | Y centre of the shared chamber viewport |
| `pub fn chamber_right() -> Float` | Right edge of the chamber viewport |
| `pub fn chamber_bottom() -> Float` | Bottom edge of the chamber viewport |
| `pub fn room_name(room : Int) -> String` | Human-readable name for a room index |
| `pub fn raider_goal_x(room : Int) -> Float` | AI navigation target X for a raider in the given room |
| `pub fn raider_goal_y(room : Int) -> Float` | AI navigation target Y for a raider in the given room |
| `pub fn vault_core_x() -> Float` | X position of the scroll vault core objective |
| `pub fn vault_core_y() -> Float` | Y position of the scroll vault core objective |
| `pub fn wave_duration(wave : Int) -> Float` | Duration in seconds of the given wave number |
| `pub fn clampi(Int, Int, Int) -> Int` | Integer clamp to `[lo, hi]` |
| `pub fn clampf(Float, Float, Float) -> Float` | Float clamp to `[lo, hi]` |
| `pub fn clamp01(Float) -> Float` | Float clamp to `[0.0, 1.0]` |
| `pub fn minf(Float, Float) -> Float` | Minimum of two floats |
| `pub fn maxf(Float, Float) -> Float` | Maximum of two floats |
| `pub fn absf(Float) -> Float` | Absolute value of a float |
| `pub fn dist2(Float, Float, Float, Float) -> Float` | Squared Euclidean distance between two 2D points |
| `pub fn sqrtf(Float) -> Float` | Square root of a non-negative float |
| `pub fn randf(Float, Float) -> Float` | Pseudo-random float in `[lo, hi]` |
| `pub fn randi(Int, Int) -> Int` | Pseudo-random integer in `[lo, hi]` |

#### Constants

| Constant | Value | Description |
|---|---|---|
| `screen_w` | `1366` | Window width in pixels |
| `screen_h` | `768` | Window height in pixels |
| `target_fps` | `120` | Target frame rate |
| `chamber_count` | `3` | Number of vault chambers |
| `vault_room` | `1` | Index of the central Vault Core room |
| `chamber_left` | `184.0` | Left edge of the chamber viewport |
| `chamber_top` | `132.0` | Top edge of the chamber viewport |
| `chamber_w` | `998.0` | Chamber viewport width |
| `chamber_h` | `554.0` | Chamber viewport height |
| `door_center_y` | `chamber_top + chamber_h * 0.56` | Vertical centre of inter-room doors |
| `door_half_h` | `78.0` | Half-height of passable door zone |
| `keeper_radius` | `18.0` | Keeper collision radius |
| `keeper_speed` | `270.0` | Keeper movement speed (px/s) |
| `keeper_mode_speed_scale` | `0.76` | Speed multiplier in extinguisher mode |
| `keeper_stamina_max` | `100.0` | Maximum keeper stamina |
| `keeper_stamina_regen` | `24.0` | Stamina regen rate in combat mode |
| `keeper_stamina_regen_mode` | `12.0` | Stamina regen rate in extinguisher mode |
| `stamina_attack_cost` | `13.0` | Stamina cost per attack |
| `stamina_seal_cost` | `20.0` | Stamina cost per seal inscription |
| `stamina_extinguish_cost` | `16.0` | Stamina cost per extinguisher use |
| `attack_range` | `82.0` | Attack and seal action range (px) |
| `attack_damage` | `50.0` | Base attack damage per strike |
| `attack_damage_wave_bonus` | `1.6` | Additional damage per wave level |
| `extinguisher_range` | `118.0` | Extinguisher action range (px) |
| `extinguisher_power` | `62.0` | Intensity reduction per extinguisher use |
| `ink_shield_cooldown` | `7.5` | Cooldown between ink shield uses (s) |
| `ink_shield_duration` | `2.2` | Active duration of ink shield (s) |
| `ink_shield_radius` | `176.0` | Area-of-effect radius of ink shield (px) |
| `ink_shield_damage` | `82.0` | Damage dealt to raiders inside shield burst |
| `ink_shield_fire_quench` | `72.0` | Intensity removed from flames inside shield burst |
| `ink_shield_integrity_block` | `0.55` | Fraction of integrity loss blocked while shield is active |
| `scroll_integrity_max` | `100.0` | Starting scroll integrity |
| `seal_charges_start` | `4` | Seal charges at wave start |
| `seal_charges_max` | `7` | Maximum seal charge cap |
| `seal_charges_wave_gain` | `1` | Seal charges awarded per wave completion |
| `breach_severity_max` | `100.0` | Maximum breach severity |
| `breach_event_cd_base` | `4.1` | Base breach event cooldown (s) |
| `breach_event_cd_floor` | `1.2` | Minimum breach event cooldown (s) |
| `breach_wave_growth` | `0.24` | Breach severity growth rate per wave |
| `breach_integrity_drain` | `5.4` | Integrity drained per second at full breach severity |
| `breach_seal_power` | `42.0` | Base severity reduction per seal charge |
| `breach_seal_wave_bonus` | `2.2` | Additional seal power per wave level |
| `raider_hp_base` | `82.0` | Base raider hit points |
| `raider_hp_wave_bonus` | `8.4` | Additional HP per wave level |
| `raider_speed_base` | `78.0` | Base raider movement speed (px/s) |
| `raider_speed_wave_bonus` | `5.6` | Additional speed per wave level |
| `raider_spawn_cd_base` | `2.2` | Base raider spawn cooldown (s) |
| `raider_spawn_cd_floor` | `0.68` | Minimum raider spawn cooldown (s) |
| `raider_vault_strike` | `6.5` | Integrity damage per raider vault strike |
| `raider_keeper_stamina_hit` | `10.5` | Stamina damage dealt to keeper per raider contact |
| `flame_spawn_cd_base` | `2.8` | Base ember spawn cooldown (s) |
| `flame_spawn_cd_floor` | `0.9` | Minimum ember spawn cooldown (s) |
| `flame_spread_cd_base` | `3.2` | Base flame spread cooldown (s) |
| `flame_spread_cd_floor` | `1.0` | Minimum flame spread cooldown (s) |
| `flame_decay` | `1.2` | Passive intensity decay rate per second |
| `flame_breach_feed` | `0.11` | Breach severity increase per flame intensity per second |
| `flame_integrity_side_mul` | `0.030` | Integrity drain multiplier for side-room flames |
| `flame_integrity_vault_mul` | `0.064` | Integrity drain multiplier for vault-room flames |
| `wave_duration_base` | `28.0` | Duration of wave 1 in seconds |
| `wave_duration_step` | `3.8` | Additional seconds per subsequent wave |
| `max_raiders` | `160` | Raider object-pool capacity |
| `max_flames` | `220` | Flame object-pool capacity |

### Package `.../internal/game`

#### Functions

| Function | Description |
|---|---|
| `pub fn update_game(@types.Game, Float) -> Unit` | Clamps dt, advances time, samples input, and dispatches per-state logic for Title, Playing, Paused, and GameOver states |

Internal helpers (not exported): `update_input`, `clear_input`, `start_new_run`, `return_to_title`, `enter_game_over`, `reset_keeper`, `clear_raiders`, `clear_flames`, `clear_breaches`, `raise_breach`, `alloc_raider`, `alloc_flame`, `spawn_raider_from_room`, `spawn_flame`, `defeat_raider`, `set_message`, `handle_action_input`, `perform_attack_action`, `perform_seal_action`, `perform_extinguish_action`, `trigger_ink_shield`, `toggle_extinguisher_mode`, `update_keeper_motion`, `update_keeper_timers_and_resources`, `update_wave_progress`, `update_breach_system`, `update_raiders`, `update_flames`, `nearest_raider_index`, `nearest_flame_index`, `nearest_open_breach_index`.

### Package `.../internal/render`

#### Functions

| Function | Description |
|---|---|
| `pub fn draw_frame(@types.Game) -> Unit` | Renders background, chamber shell, vault core, breaches, flames, raiders, keeper, minimap, HUD, message bar, and any state overlay |

Internal helpers (not exported): `draw_background`, `draw_chamber_shell`, `draw_vault_core`, `draw_breaches`, `draw_flames`, `draw_raiders`, `draw_keeper`, `draw_room_minimap`, `draw_hud`, `draw_message`, `draw_meter`, `draw_title_overlay`, `draw_paused_overlay`, `draw_game_over_overlay`, `draw_center_text`, `alpha_col`, `room_fill_color`, `count_raiders_in_room`, `count_flames_in_room`.

## Architecture

### Package Structure

```
raylib_dragon_scroll_keeper_2026/
├── main.mbt                  # Entry point: window init, game loop
└── internal/
    ├── types/
    │   ├── constants.mbt     # All numeric tuning constants
    │   ├── types.mbt         # Structs, enum, constructor functions
    │   └── utils.mbt         # Math helpers, geometry queries, PRNG wrappers
    ├── game/
    │   ├── input.mbt         # Keyboard sampling into Game input fields
    │   └── logic.mbt         # update_game: keeper, breaches, raiders, flames, waves
    └── render/
        └── render.mbt        # draw_frame: world, entities, HUD, overlays
```

### Data Flow

Each frame the main loop calls `update_game(game, dt)` followed by `draw_frame(game)`. `update_game` clamps the delta-time to 50 ms, increments `game.time_s`, and samples keyboard state directly into flat input fields on `Game`. The state dispatcher routes to one of four handlers: `update_title_state` listens for any action key to call `start_new_run`; `update_playing_state` runs the full simulation pipeline in order — keeper timers, keeper motion, ink-shield trigger, action input, wave progress, breach system, raider AI, and flame spread — accumulating `integrity_loss` from all three threat systems and applying the ink-shield reduction factor before subtracting from `scroll_integrity`; `update_paused_state` and `update_game_over_state` handle resume, restart, and title transitions.

`draw_frame` is strictly read-only. It renders the chamber shell for whichever room the keeper currently occupies, then draws world objects (vault core, breaches, flames, raiders, keeper with facing indicator and shield ring), followed by the three-room minimap panel, the bottom HUD strip with integrity and stamina meters, and the floating message bar. State overlays (title card, pause screen, game-over screen) are drawn last.

### Key Design Patterns

- **Shared-viewport single-room rendering**: All three rooms share the same pixel viewport; only entities belonging to `game.keeper.room` are drawn each frame, with doorway arrows showing adjacent rooms. Room transitions are handled by boundary crossing in motion code.
- **Object pools with index-based allocation**: Raiders (160 slots) and flames (220 slots) are allocated from fixed arrays by scanning for the first inactive entry, keeping all memory pre-allocated and avoiding GC pressure.
- **Accumulated integrity loss**: Each threat subsystem (`update_breach_system`, `update_raiders`, `update_flames`) returns a `Float` integrity loss that is summed in the playing-state handler, then optionally attenuated by the ink-shield factor before a single deduction, making damage budget arithmetic transparent.
- **Mode-gated action dispatch**: The J key dispatches to either `perform_extinguish_action` or `perform_attack_action` / `perform_seal_action` depending on `keeper.extinguisher_mode`, and the seal path is further conditional on both a breach in range and available seal charges — all evaluated in `handle_action_input` without any event queue.
- **Wave-scaled difficulty**: Raider HP, raider speed, breach severity growth, breach event cooldown, and flame spread rate all incorporate `game.wave - 1` as a linear scalar, so a single integer drives the full difficulty ramp.
- **Flat mutable state struct**: All mutable game state lives in one `Game` record passed by reference to every subsystem, eliminating return-value threading and keeping update and render signatures uniform.

## Improvement & Refinement Plan

1. **Per-room threat visualisation on the minimap**: Augment the minimap cells with colour-coded threat levels (breach severity as orange bar is already present; add a blue flame intensity bar and a red raider count indicator) so the player can triage rooms without entering them.
2. **Raider pathfinding through door zones**: Raiders currently teleport room-to-room when they reach the right- or left-wall boundary inside the door Y range; replacing this with a smooth position interpolation across the door threshold would eliminate the visual jump.
3. **Ink-shield stock fractional display**: `ink_shields` is stored as a float accumulating partial credits from defeats and seals; displaying the fractional portion (e.g. "1.7") rather than truncating to int would give clearer feedback on progress toward the next shield.
4. **Wave completion score breakdown**: The `update_wave_progress` score award (`140 + wave * 22 + scroll_integrity`) is applied silently; surfacing a brief per-wave summary overlay (integrity bonus, wave bonus, time bonus) would make the scoring system legible.
5. **Configurable pool capacities**: `max_raiders` (160) and `max_flames` (220) are compile-time constants; exposing them as moon.pkg parameters would allow memory budgets to be tuned per target platform without source changes.
6. **Stamina starvation feedback**: When stamina is too low for an action, a message is shown but no visual cue appears on the keeper; adding a brief red pulse on the stamina bar or keeper sprite would make the failure reason immediately obvious without reading the message bar.
7. **Breach severity decay when unsealed**: Breaches with active severity grow via `breach_wave_growth` each frame but never decay passively; introducing a slow natural decay when no raiders or flames are present would give the player a moment of relief between events and reward successful clearance of a room.
