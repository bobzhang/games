# Moon Gate Defense 2026

A grid-based tower defense game set on a lunar surface, where you place and upgrade directional guardian nodes on an 11x7 grid to protect a central moon gate from waves of alien enemies. The game features three enemy types (Skitter, Carapace, Wraith), a three-level node upgrade system, a combo-charged barrier burst ultimate ability, and an escalating wave difficulty system.

The core gameplay loop involves spending energy to build guardian nodes on grid cells, orienting them to face incoming enemies, and upgrading them through three tiers that increase range, damage, and fire rate. Nodes fire projectile bolts in a forward cone at enemies within range. Killing enemies earns energy and score, with a combo multiplier that builds when kills happen within a 2.5-second window. Consecutive kills also charge the barrier meter; once full, activating the barrier deals 95 damage and pushes enemies within a 235-pixel radius away from the gate.

The visual design creates an atmospheric space setting with a starfield background, animated moon, pulsing gate portal, and color-coded node levels (blue L1, teal L2, gold L3). Screen shake on gate hits and expanding pulse ring effects on kills provide satisfying combat feedback.

## Build and Run

```bash
moon build --target native moon_gate_defense_2026/
./_build/native/debug/build/moon_gate_defense_2026/moon_gate_defense_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Move cursor on the grid (also sets facing direction)
- **J**: Place new guardian node / upgrade existing node / rotate facing direction
- **K**: Sell node at cursor (refunds 65% of total build cost) / cancel / resume from pause
- **Space**: Activate barrier burst (requires full charge of 100)
- **P**: Pause / unpause game
- **R**: Restart game instantly
- **F11**: Toggle borderless windowed mode

## How to Play

Press J on the title screen to begin. Enemies spawn from all four edges of the board and path toward the central moon gate. Place guardian nodes on empty grid cells by moving the cursor and pressing J (costs 36 energy). Nodes fire bolts in their facing direction within a forward cone.

**Node management**: Pressing J on a node that already faces your cursor direction upgrades it (L2 costs 52, L3 costs 76 energy). If the node faces a different direction, pressing J rotates it to match. Press K to sell a node for 65% of its total investment. Max level L3 nodes cycle facing direction on J press.

**Enemy types**: Skitters (yellow, fast, low HP), Carapaces (orange, slow, tanky, high reward), and Wraiths (purple, moderate speed, with an aura visual). Enemy HP and speed scale each wave. When an enemy reaches the gate, it deals contact damage and resets your combo.

**Combo system**: Kill enemies within 2.5 seconds of each other to build a combo chain. Every 4 combo steps increases the score multiplier. Combos also charge the barrier meter (11 per kill + combo * 1.8, capped at combo 12).

**Barrier burst**: When the barrier charge reaches 100, press Space to unleash a burst dealing 95 damage to all enemies within 235px of the gate and pushing survivors outward by 72px.

**Wave progression**: Waves automatically advance when all enemies are cleared. Each wave spawns more enemies (base 7 + 3 per wave) at faster intervals. Energy regenerates at 13.5/s + 0.22 per wave, plus a wave bonus at the start of each wave.

**Game over**: The gate has 260 HP. When it reaches 0, the game ends. Your score and best score are displayed.

## Public API Reference

### Package `moon_gate_defense_2026`

> Main entry point.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Entry point: initializes window (1420x900) with MSAA, runs game loop at 120 FPS |

### Package `moon_gate_defense_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Enums / Constants (Integer-based)

| Constant Group | Values | Description |
|----------------|--------|-------------|
| Game states | `state_title` (0), `state_playing` (1), `state_paused` (2), `state_game_over` (3) | State machine states |
| Directions | `dir_up` (0), `dir_right` (1), `dir_down` (2), `dir_left` (3) | Cardinal direction indices |
| Enemy kinds | `enemy_kind_skitter` (0), `enemy_kind_carapace` (1), `enemy_kind_wraith` (2) | Enemy type identifiers |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Node` | `active`, `gx`, `gy`, `level`, `facing`, `cooldown`, `pulse` | Guardian turret node placed on a grid cell with level, direction, and fire cooldown |
| `Enemy` | `active`, `kind`, `x`, `y`, `hp`, `max_hp`, `speed`, `radius`, `reward`, `gate_damage` | Enemy entity with type, position, health, movement, and gate damage stats |
| `Bolt` | `active`, `x`, `y`, `vx`, `vy`, `life`, `dmg` | Projectile fired by nodes with velocity, lifetime, and damage |
| `PulseFx` | `active`, `x`, `y`, `radius`, `life`, `max_life`, `kind` | Expanding ring visual effect (kind 0=gate, 1=energy, 2=barrier color) |
| `Game` | `nodes`, `enemies`, `bolts`, `pulses`, `state`, `score`, `wave`, `gate_hp`, `energy`, `barrier_charge`, `combo` | Main game state container with all entity pools, scoring, and resource meters |

#### Constants (Selected)

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` / `screen_h` | `Int` | `1420` / `900` | Window dimensions |
| `grid_cols` / `grid_rows` | `Int` | `11` / `7` | Grid dimensions |
| `cell_size` | `Int` | `82` | Pixel size of each grid cell |
| `gate_hp_max` | `Float` | `260.0` | Maximum gate hit points |
| `energy_start` / `energy_max` | `Float` | `120.0` / `320.0` | Starting and maximum energy |
| `node_build_cost` | `Float` | `36.0` | Energy cost to place a new L1 node |
| `node_upgrade_cost_l2` / `l3` | `Float` | `52.0` / `76.0` | Upgrade costs for L2 and L3 |
| `node_sell_ratio` | `Float` | `0.65` | Refund percentage when selling a node |
| `barrier_charge_goal` | `Float` | `100.0` | Charge needed to activate barrier burst |
| `barrier_damage` / `barrier_push` | `Float` | `95.0` / `72.0` | Barrier burst damage and knockback distance |
| `combo_window` | `Float` | `2.5` | Seconds between kills to maintain combo |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Node::new` | `() -> Node` | Creates a default inactive node |
| `Enemy::new` | `() -> Enemy` | Creates a default inactive enemy |
| `Bolt::new` | `() -> Bolt` | Creates a default inactive bolt |
| `PulseFx::new` | `() -> PulseFx` | Creates a default inactive pulse effect |
| `Game::new` | `() -> Game` | Creates a new game with pre-allocated pools (77 nodes, 200 enemies, 300 bolts, 320 pulses) |
| `mini` | `(Int, Int) -> Int` | Returns the minimum of two integers |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer to [lo, hi] range |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to [lo, hi] range |
| `minf` / `maxf` | `(Float, Float) -> Float` | Returns min/max of two floats |
| `sinf` / `cosf` | `(Float) -> Float` | Sine/cosine wrappers via `@math` |
| `sqrtf` | `(Float) -> Float` | Square root wrapper |
| `randf` | `(Float, Float) -> Float` | Random float in [lo, hi] |
| `randi` | `(Int, Int) -> Int` | Random integer in [lo, hi] |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Squared distance between two points |
| `board_left` / `board_top` / `board_right` / `board_bottom` | `() -> Float` | Board boundary pixel coordinates |
| `cell_center_x` / `cell_center_y` | `(Int) -> Float` | Pixel center of a grid cell |
| `gate_x` / `gate_y` | `() -> Float` | Gate center pixel position |
| `is_gate_cell` | `(Int, Int) -> Bool` | Tests if (gx, gy) is the gate cell |
| `node_upgrade_cost` | `(Int) -> Float` | Returns energy cost for upgrading to given level |
| `node_total_cost` | `(Int) -> Float` | Returns cumulative energy cost for a given level |
| `node_sell_refund` | `(Int) -> Float` | Returns energy refund for selling a node at given level |
| `node_range` / `node_damage` / `node_fire_cd` | `(Int) -> Float` | Returns range/damage/fire cooldown for a given node level |
| `wave_spawn_count` | `(Int) -> Int` | Returns number of enemies in a given wave |
| `wave_spawn_cd` | `(Int) -> Float` | Returns spawn interval for a given wave |
| `dir_vec_x` / `dir_vec_y` | `(Int) -> Float` | Returns the x/y component of a direction vector |
| `col_bg_top` / `col_bg_bottom` / `col_grid` / `col_gate` / `col_energy` / `col_barrier` | `() -> @raylib.Color` | Theme colors for various UI elements |
| `col_enemy` | `(Int) -> @raylib.Color` | Returns color for an enemy kind |
| `col_node` | `(Int) -> @raylib.Color` | Returns color for a node level |

### Package `moon_gate_defense_2026/internal/game`

> Game logic, wave spawning, combat, and input handling.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(@types.Game, Float) -> Unit` | Main update: reads input, dispatches to state-specific update, manages timers |

### Package `moon_gate_defense_2026/internal/render`

> All rendering routines.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(@types.Game) -> Unit` | Main render: draws background, grid, gate, pulses, nodes, enemies, bolts, cursor, HUD, and overlays |

## Architecture

### Package Structure

```
moon_gate_defense_2026/
├── main.mbt              — Entry point: window init, game loop
├── moon.pkg              — Package config, imports
└── internal/
    ├── types/
    │   ├── types.mbt     — Core structs (Node, Enemy, Bolt, PulseFx, Game) with constructors
    │   ├── constants.mbt — Grid dimensions, balance constants, pool sizes, color functions
    │   └── utils.mbt     — Math utilities, board geometry helpers, balance formulas
    ├── game/
    │   ├── logic.mbt     — Wave spawning, node firing, bolt physics, enemy AI, barrier burst, combo tracking
    │   └── input.mbt     — Keyboard input reading into Game.input_* fields
    └── render/
        └── render.mbt    — Background stars/moon, grid, gate portal, nodes, enemies, bolts, pulses, HUD, overlays
```

### Data Flow

1. **Input**: `update_input` reads all keyboard presses into `Game.input_*` boolean/int fields, providing a clean input buffer for the logic layer.
2. **State Dispatch**: `update_game` dispatches to `update_title_state`, `update_playing_state`, `update_paused_state`, or `update_game_over_state` based on `game.state`.
3. **Playing Update**: `update_playing_state` processes cursor movement via `move_cursor`, build/upgrade via `try_build_or_upgrade`, sell via `try_sell_node`, and barrier via `trigger_barrier`. Then it runs the simulation: `update_wave_spawner` -> `update_nodes` (target acquisition + bolt spawning) -> `update_bolts` (physics + hit detection) -> `update_enemies` (movement toward gate + gate collision) -> `update_pulses` (visual decay).
4. **Combat Flow**: Nodes scan for enemies in their forward cone using dot product filtering. Bolts check distance to all active enemies each frame. `kill_enemy` awards score with combo multiplier, grants energy, charges barrier, and emits pulse effects.
5. **Rendering**: `draw_frame` renders in order: background -> grid -> gate -> pulses -> nodes -> enemies -> bolts -> cursor -> HUD -> state overlay, all offset by camera shake.

### Key Design Patterns

- **Object pools with linear scan allocation**: Fixed-size arrays for nodes (77), enemies (200), bolts (300), and pulses (320) with `active` flags and `alloc_*` functions that scan for inactive slots.
- **Input buffer pattern**: All input is read once per frame into `Game.input_*` fields, decoupling input reading from game logic and allowing the same logic to process different input sources.
- **Directional cone targeting**: Nodes use a dot product check (`dot * dot >= d2 * node_cone_dot_sq`) to only fire at enemies within their facing cone, creating strategic placement decisions.
- **Combo-charged ultimate**: The barrier system creates a risk/reward loop where maintaining kill combos charges a powerful area-of-effect ability.
- **Wave escalation**: Enemy count, spawn rate, HP, speed, and contact damage all scale with wave number via explicit formulas in `wave_spawn_count`, `wave_spawn_cd`, and `spawn_enemy`.

## Improvement & Refinement Plan

1. **Use enums for state and direction**: `state` (0-3), directions (0-3), and enemy kinds (0-2) are all integer constants. Converting to proper enums would enable exhaustive pattern matching and eliminate invalid state bugs.
2. **Add mouse/touch support for node placement**: Currently only keyboard input is supported. Adding mouse click-to-cell conversion (similar to the cursor system) would improve accessibility, especially since the grid cells are large (82px).
3. **Visualize node targeting cone**: The node range circle is drawn but the firing cone is not visible. Drawing the cone arc would help players understand node coverage and optimize placement.
4. **Add enemy variety beyond stats**: All three enemy types share identical movement behavior (path to gate with wobble). Giving Wraiths phasing ability or Carapaces a shield mechanic would deepen strategy.
5. **Balance energy economy**: Starting energy (120) allows only 3 L1 nodes before the first wave. Combined with slow regen (13.5/s), early waves can feel resource-starved. Increasing starting energy or reducing L1 cost would improve early-game feel.
6. **Add wave preview**: There is no indication of what enemy types will appear in the next wave. A brief preview showing upcoming enemy composition would allow strategic node placement.
7. **Persist best score**: `best_score` resets each application session. Saving to a file would provide lasting progression incentive.
