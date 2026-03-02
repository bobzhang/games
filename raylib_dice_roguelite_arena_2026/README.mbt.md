# Dice Roguelite Arena 2026

Dice Roguelite Arena 2026 is a turn-based roguelite combat game where the player rolls dice and assigns them to actions against a series of increasingly powerful enemies across 12 floors. Each turn, the player receives 6 dice with random values (1-6) and randomly assigned faces (Strike, Guard, Focus, Mend, Venom, Crush), spending energy to activate them one at a time. The game features a clean cyberpunk-themed UI on a 1366x768 screen with animated background elements, spark particle effects, and color-coded panels for player and enemy status.

The core mechanic revolves around dice face assignment and energy management. The player starts each turn with 3 energy (+ focus bonus) and 2 rerolls (+ reroll bonus). Each die activation costs 1 energy, and rerolling unused dice costs 1 energy and 1 reroll charge. Six face types provide distinct tactical options: Strike deals value*4 + attack bonus damage with crit chance, Guard adds value*3 + 3 + guard bonus shield, Focus grants 1 + value/2 energy, Mend heals value*2 + heal bonus HP, Venom applies value + venom bonus poison, and Crush deals value*5 + 5 + crush bonus damage (bonus from current shield). Enemies telegraph their next intent (attack, guard, rage, or poison), allowing strategic counter-play.

After each victory, the player chooses from 3 randomly generated reward cards that permanently upgrade artifacts (attack bonus, guard bonus, heal bonus, venom bonus, crush bonus, reroll charges, starting shield, crit chance, or gold). Four enemy types with distinct behavior profiles and floor-scaling stats create variety: Scrap Berserkers favor attacking, Aegis Sentinels prioritize shielding, Venom Archivists apply poison, and Null Reapers (appearing from floor 9) combine all threats with the highest stats. The player wins by clearing all 12 floors.

## Build and Run

```bash
moon build --target native raylib_dice_roguelite_arena_2026/
./_build/native/debug/build/raylib_dice_roguelite_arena_2026/raylib_dice_roguelite_arena_2026.exe
```

## Controls

- **Mouse Click**: Click a die to activate its face action (costs 1 energy)
- **R**: Reroll all unused dice (costs 1 energy + 1 reroll charge)
- **E**: End turn (triggers enemy action)
- **1 / 2 / 3**: Select reward card after victory
- **Enter**: Start game / Continue after win/loss
- **F11**: Toggle fullscreen
- **On-screen buttons**: REROLL and END TURN buttons (click/tap supported)

## How to Play

Each combat turn begins with 6 freshly rolled dice displayed in a 3x2 grid. Each die shows a random value (1-6) and a face type (Strike, Guard, Focus, Mend, Venom, or Crush). Click any unused die to activate it, consuming 1 energy. Face probabilities are weighted and influenced by artifact bonuses.

**Face Actions:**
- **Strike** (sword icon): Deals value * 4 + atk_bonus * 2 damage. Has crit_chance% to deal extra value * 2 + atk_bonus bonus damage.
- **Guard** (square icon): Adds value * 3 + 3 + guard_bonus * 2 to player shield. Shield absorbs damage before HP.
- **Focus** (circle icon): Grants 1 + value/2 + focus_bonus energy (max 9), allowing more dice activations this turn.
- **Mend** (cross icon): Restores value * 2 + heal_bonus * 3 HP (up to max HP).
- **Venom** (triangle icon): Applies value + venom_bonus poison to enemy. Poison deals its current value as damage each turn, then decrements by 1.
- **Crush** (X icon): Deals value * 5 + 5 + crush_bonus * 2 damage, plus shield/3 bonus if the player has shield active.

The enemy telegraphs their intent each turn (attack, guard, rage, or poison). After activating dice or pressing E, the enemy executes their intent. Rage permanently increases an enemy's attack damage. Poison works the same way on both sides.

After defeating an enemy, choose 1 of 3 reward cards to permanently upgrade your run. Rewards include Max HP increases, face bonuses, extra rerolls, starting shield, crit chance, or gold. Progress through all 12 floors with scaling enemy HP and damage to achieve victory.

## Public API Reference

### Package `raylib_dice_roguelite_arena_2026`

> Single-file game with all logic in main.mbt.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Player` | `hp`, `max_hp`, `shield`, `poison`, `energy`, `gold`, `floor`, `wins` | Player state with HP (120 start), shield buffer, poison counter, energy for dice activation, gold from victories, current floor (1-12), and total wins |
| `Enemy` | `kind`, `hp`, `max_hp`, `shield`, `poison`, `rage`, `intent_kind`, `intent_value` | Enemy with type (0-3), HP scaling with floor, shield/poison/rage counters, and telegraphed intent (0=attack, 1=guard, 2=rage, 3=poison) |
| `Dice` | `value`, `face`, `used`, `x`, `y`, `pulse_t` | A single die with numeric value (1-6), face type (0-5), usage flag, display position, and animation pulse timer |
| `RewardCard` | `kind`, `value`, `title`, `desc` | Post-victory upgrade card with kind (0-9), numeric value, display title, and description |
| `Artifacts` | `atk_bonus`, `guard_bonus`, `heal_bonus`, `venom_bonus`, `focus_bonus`, `crush_bonus`, `reroll_bonus`, `start_shield`, `crit_chance` | Permanent run upgrades accumulated from reward cards, affecting face calculations and turn resources |
| `Spark` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | Visual particle with pool flag, physics velocity with drag, shrinking lifetime, and kind-based coloring (0=gold, 1=green, 2=red, 3=blue) |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer value between low and high bounds |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float value between low and high bounds |
| `randf` | `(Float, Float) -> Float` | Returns a random float in [lo, hi] using raylib's RNG |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point (px, py) is inside a rectangle (x, y, w, h) |
| `enemy_name` | `(Int) -> String` | Returns display name for enemy kind (0="Scrap Berserker", 1="Aegis Sentinel", 2="Venom Archivist", 3="Null Reaper") |
| `face_name` | `(Int) -> String` | Returns display name for dice face (0="STRIKE", 1="GUARD", 2="FOCUS", 3="MEND", 4="VENOM", 5="CRUSH") |
| `face_desc` | `(Int) -> String` | Returns description for dice face (e.g., "Deal damage", "Gain shield") |
| `clear_sparks` | `(Array[Spark]) -> Unit` | Deactivates all spark particles and resets their fields |
| `add_spark` | `(Array[Spark], Float, Float, Int) -> Unit` | Activates one inactive spark at position with random radial velocity (40-240 px/s), size (3-8), and lifetime (0.25-0.7s) |
| `burst_sparks` | `(Array[Spark], Float, Float, Int, Int) -> Unit` | Spawns N sparks at a position with a given kind (batch effect) |
| `update_sparks` | `(Array[Spark], Float) -> Unit` | Updates active sparks: decays lifetime, applies velocity with drag and light gravity |
| `draw_sparks` | `(Array[Spark]) -> Unit` | Renders active sparks as shrinking circles with kind-based coloring |
| `enemy_color` | `(Int) -> @raylib.Color` | Returns the display color for enemy kind (red, blue, green, purple) |
| `set_enemy` | `(Enemy, Int) -> Unit` | Initializes an enemy with random kind and floor-scaled HP (64-98 base + 13-18 per floor). Null Reapers (kind 3) appear 46% of the time from floor 9 |
| `roll_enemy_intent` | `(Enemy, Int) -> Unit` | Randomly selects enemy's next action based on kind-specific probability distributions. Values scale with floor and rage |
| `intent_text` | `(Enemy) -> String` | Returns display text for enemy's current intent (e.g., "Attack 14", "Guard 12") |
| `roll_face` | `(Artifacts) -> Int` | Returns a random dice face (0-5) with weighted probabilities influenced by artifact bonuses |
| `init_dice` | `(Array[Dice]) -> Unit` | Resets all dice to default state (value 1, face 0, unused) |
| `roll_dice` | `(Array[Dice], Artifacts, Bool) -> Unit` | Rolls dice: assigns random faces and values. If force_all is true, rolls all dice; otherwise only rolls unused ones |
| `compute_damage_to_enemy` | `(Enemy, Int) -> Int` | Applies damage to enemy, absorbed by shield first. Returns actual HP damage dealt |
| `compute_damage_to_player` | `(Player, Int) -> Int` | Applies damage to player, absorbed by shield first. Returns actual HP damage dealt |
| `apply_face` | `(Int, Int, Player, Enemy, Artifacts, Array[Spark], Int) -> (String, Int)` | Executes a dice face action: applies effect based on face type, value, and artifact bonuses. Returns (message, damage_dealt) |
| `set_reward_card` | `(RewardCard, Int, Int) -> Unit` | Configures a reward card with kind and value, setting title and description strings |
| `generate_rewards` | `(Array[RewardCard], Int) -> Unit` | Generates 3 random reward cards with kind-appropriate values. Crit chance cards excluded before floor 3 |
| `apply_reward` | `(RewardCard, Player, Artifacts) -> String` | Applies a chosen reward card's effect to player/artifacts and returns a confirmation message |
| `draw_panel` | `(Int, Int, Int, Int, @raylib.Color) -> Unit` | Renders a dark semi-transparent panel with colored border |
| `draw_button` | `(Int, Int, Int, Int, String, Bool, Bool) -> Unit` | Renders a clickable button with label, enabled/disabled state, and hover highlight |
| `draw_bar` | `(Int, Int, Int, Int, Int, Int, @raylib.Color) -> Unit` | Renders an HP/resource bar with filled portion proportional to value/max |
| `draw_dice_face` | `(Int, Int, Int, Int, @raylib.Color) -> Unit` | Renders a dice face icon (sword slash, shield square, focus circle, mend cross, venom triangle, crush X) |
| `draw_touch_help` | `() -> Unit` | Renders a semi-transparent hint bar at the bottom explaining touch controls |

#### Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `sw` | 1366 | Screen width in pixels |
| `sh` | 768 | Screen height in pixels |
| `max_dice` | 6 | Number of dice per turn |
| `max_sparks` | 180 | Spark particle pool size |

## Architecture

### Package Structure

```
raylib_dice_roguelite_arena_2026/
├── main.mbt    -- Complete game: structs, dice mechanics, combat, rewards, AI, rendering
└── moon.pkg    -- Package config (single main package, imports math + raylib)
```

This is a single-file turn-based game with all state managed as local variables and closures in the `main` function. Three closures (`begin_new_run`, `begin_player_turn`, `begin_enemy_turn`) handle state transitions. The game loop processes input, turn logic, and rendering sequentially.

### Data Flow

1. **State Machine**: Five states: 0=menu, 1=battle, 2=reward selection, 3=game over, 4=victory. Within battle, `turn` tracks whether it's the player's turn (0) or enemy animation (1).
2. **Dice Rolling**: `roll_dice` assigns random values (1-6) and weighted faces to each die. Face weights are base values modified by artifact bonuses (e.g., `strike_w = 280 + atk_bonus * 4`), normalized across all faces.
3. **Player Actions**: Clicking an unused die calls `apply_face` which computes the face-specific effect using the die's value and artifact bonuses. Energy is consumed per activation. Rerolling re-randomizes unused dice at the cost of 1 energy + 1 reroll.
4. **Enemy AI**: Each turn, `roll_enemy_intent` selects the enemy's action using kind-specific probability tables. Intent is displayed before execution, allowing counter-play. Intent values scale with floor and accumulated rage.
5. **Damage Resolution**: Both `compute_damage_to_enemy` and `compute_damage_to_player` handle shield absorption before HP reduction, returning actual HP damage for visual feedback.
6. **Rewards**: After victory, `generate_rewards` creates 3 random cards. `apply_reward` permanently modifies the player's stats or artifacts, building power over the run.
7. **Rendering**: Layered UI with gradient background, floating animated elements, player panel (left, blue), enemy panel (right, red), arena panel (center), 3x2 dice grid with face icons and values, action buttons, status bars, intent display, reward card selection, and overlay screens.

### Key Design Patterns

- **Turn-Based State Machine**: The `turn` variable separates player input phase (turn=0) from enemy animation phase (turn=1), with `enemy_anim_t` controlling the transition timing.
- **Weighted Random Faces**: Dice face probabilities are not uniform -- they're weighted sums influenced by artifact bonuses, creating a soft-selection system where upgrades make preferred faces more likely.
- **Shield Absorption**: Both player and enemy share the same damage resolution pattern where shield absorbs damage before HP, creating tactical depth around Guard timing.
- **Closure-Based Transitions**: `begin_new_run`, `begin_player_turn`, and `begin_enemy_turn` closures capture all mutable state, enabling clean state transitions without a formal state struct.
- **Object Pool Pattern**: Sparks use a pre-allocated array of 180 slots with `active` flags for visual feedback effects.
- **Intent Telegraphing**: Enemies reveal their next action each turn, enabling strategic dice assignment (e.g., prioritize Guard when enemy intends to attack).

## Improvement & Refinement Plan

1. **Use enums for enemy kind, face type, and intent**: Currently these are all integer constants (kind 0-3, face 0-5, intent 0-3) with separate name/desc/color functions switching on them. Proper enums with methods would be more type-safe and self-documenting.

2. **Extract game state into a struct**: Over 10 mutable local variables (state, turn, rerolls_left, msg, msg_t, enemy_anim_t, bg_t, combo_hits) plus the closures could be consolidated. A `Game` struct would enable extracting update and render functions.

3. **Add a combo multiplier for consecutive strikes**: The `combo_hits` counter is tracked but never used mechanically -- it's only displayed. Making combos multiply damage or grant bonus energy would reward aggressive playstyles and create interesting risk-reward decisions.

4. **Add a shop between floors**: Gold accumulates but is never spent. Adding a shop where players can buy specific upgrades (rather than relying on random reward cards) would create meaningful resource decisions and make gold acquisition more satisfying.

5. **Implement dice locking/saving**: Currently all unused dice are rerolled together. Adding the ability to lock specific dice before rerolling would give players more fine-grained control over their dice economy.

6. **Add visual dice rolling animation**: Dice appear instantly with new values. Adding a tumbling animation with briefly cycling faces before settling would make the roll feel more physical and exciting.

7. **Scale face weights with floor progression**: Face weights only change from artifact bonuses. Having later floors naturally shift face distributions (e.g., more Crush faces on later floors) would create a power curve even without upgrades.

8. **Add multi-hit enemy types**: All enemies perform a single action per turn. Adding enemies that telegraph multi-hit combos (e.g., "3x Attack 6") would force different defensive strategies and make Guard more valuable.
