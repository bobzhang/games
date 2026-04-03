# Card Duel 2026

A turn-based card combat game where you play cards from a random hand to attack, defend, and heal against an AI enemy that fights back each turn.

## Build and Run

```bash
moon build --target native card_duel_2026/
./_build/native/debug/build/card_duel_2026/card_duel_2026.exe
```

## Controls

- **1 / 2 / 3**: Play the corresponding card from your hand
- **Enter**: End your turn
- **R**: Restart

## How to Play

Each turn you receive 3 random cards and energy to spend. Cards include Strike (6 damage), Guard (7 block), Burst (12 damage), Sap (break block + 4 damage), and Repair (heal 6). Play cards strategically -- block absorbs incoming damage before it hits HP. After you end your turn, the enemy takes two actions (slash, guard, or drain). Reduce the enemy's HP to zero to win. The enemy scales in strength over time.

## Public API Reference

### Package `tonyfettes/raylib-examples/card_duel_2026`
> Monolithic single-file entry point. Contains all game logic, rendering, and the main loop. No public symbols are exported; all functions are package-private.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `card_name` | `fn card_name(card : Int) -> String` | Returns the display name for a card index (0-4). |
| `card_cost` | `fn card_cost(card : Int) -> Int` | Returns the energy cost for a card index (0-4). |
| `card_desc` | `fn card_desc(card : Int) -> String` | Returns the short effect description for a card index. |
| `deal_damage` | `fn deal_damage(hp : Int, block : Int, dmg : Int) -> (Int, Int)` | Applies damage to a target with block absorption; returns updated `(hp, block)`. |
| `roll_hand` | `fn roll_hand(hand : Array[Int]) -> Unit` | Clears and refills the hand array with 3 random card indices. |
| `enemy_turn` | `fn enemy_turn(p_hp : Int, p_block : Int, e_hp : Int, e_block : Int, turn_no : Int) -> (Int, Int, Int, Int, String)` | Executes 2 enemy actions (slash, guard, or drain) and returns updated `(p_hp, p_block, e_hp, e_block, log)`. |
| `main` | `fn main -> Unit` | Initializes the raylib window, allocates mutable state variables, and runs the game loop until the window closes. |

#### Card Table

| Index | Name | Cost | Effect |
|-------|------|------|--------|
| 0 | Strike | 1 | Deal 6 damage to enemy |
| 1 | Guard | 1 | Gain 7 block |
| 2 | Burst | 2 | Deal 12 damage to enemy |
| 3 | Sap | 2 | Break enemy block, deal 4 damage |
| 4 | Repair | 2 | Heal player 6 HP |

#### Enemy Actions

| Roll (0-99) | Action | Effect |
|-------------|--------|--------|
| 0-54 | Slash | Deal `6 + turn_no / 4` damage to player |
| 55-79 | Guard | Gain 7 block |
| 80-99 | Drain | Deal 4 damage to player, heal enemy 3 HP |

## Architecture

### Package Structure

```
card_duel_2026/
├── README.mbt.md
├── main.mbt          # All game code: state, logic, rendering, and main loop
├── moon.pkg
└── pkg.generated.mbti
```

### Data Flow

Card Duel 2026 uses a monolithic single-file architecture with no package boundaries. All game state is held in plain `mut` variables declared inside `main`: `p_hp`, `p_block`, `e_hp`, `e_block`, `energy`, `turn`, `hand`, `log`, and a `state` string (`"play"`, `"win"`, `"lose"`).

Each frame the main loop reads raylib keyboard input and, depending on current state, either processes a card play (keys 1/2/3), ends the player turn (Enter), or restarts (R). When the player ends their turn, `enemy_turn` is called to resolve two enemy actions at once and the results are folded back into the shared mutable variables. Rendering is fully inline: card slots, HP bars, block indicators, the combat log, and end-game overlays are all drawn directly inside the loop body using raylib draw primitives.

### Key Design Patterns

- **Flat mutable state**: No structs for player or enemy; all fields are separate `mut` variables, keeping the code accessible and eliminating indirection.
- **Functional card helpers**: `card_name`, `card_cost`, `card_desc`, and `deal_damage` are pure functions with no side effects, making card definitions easy to read and modify.
- **Integer-indexed cards**: Cards are represented as plain integers (0-4), avoiding enum dispatch overhead and keeping the hand as a simple `Array[Int]`.
- **Two-action enemy resolution**: The entire enemy turn (up to 2 actions) is computed in a single function call with a weighted random roll per action, then the results are committed atomically.
- **Block decay**: Each turn, block values decay by 2 if positive, creating a soft attrition mechanic without additional data structures.
- **Single-pass rendering**: All draw calls happen in one sequential pass per frame with no intermediate render targets, appropriate for a small 980x700 window.

## Improvement & Refinement Plan

1. **Extract a `Player` struct**: Grouping `hp`, `block`, and `energy` into a struct would reduce function arity and make it straightforward to add future fields such as status effects (poison, burn) without changing every call site.

2. **Introduce a card definition table**: Replace the three match-on-integer functions (`card_name`, `card_cost`, `card_desc`) with an array of records or a struct table indexed by card ID. This eliminates the risk of the three functions drifting out of sync when a new card is added.

3. **Add a deck and discard system**: Currently each hand is drawn entirely at random from all 5 card types with replacement. A real deck-building loop (shuffle, draw, discard) would give the player more agency and make strategic planning possible across multiple turns.

4. **Animate card play and enemy actions**: All state changes are instant. Inserting short tween timers for damage flash, block pop-in, and enemy action text would make the feedback loop clearer without requiring structural changes.

5. **Persist best-score / win streak**: The game has no persistent state. Adding a simple file write for a win/loss record (using MoonBit's file API) would give players a reason to continue past a single session.

6. **Separate rendering from logic**: Moving all `@raylib.draw_*` calls into a dedicated `draw` function that receives the current state as arguments would allow the logic and presentation to evolve independently and make unit-testing the combat math straightforward.

7. **Difficulty curve tuning**: The enemy scales Slash damage by `turn_no / 4`, which grows slowly and plateaus. Adding stage-based action weight shifts (e.g., higher Drain frequency in later turns) would create a more dynamic difficulty arc.
