# Rhythm Street Beats 2026

A four-lane rhythm game with a procedurally generated note chart of 430+ notes that scroll downward toward a yellow judgment line. Players tap lane keys in time with the music, hold long notes until they complete, build combo chains for score multipliers, and trigger a Fever mode for a temporary massive score boost. The game features a grading system from C to SS based on accuracy, a life bar that drains on misses, and neon-styled visual feedback with particles and camera shake.

The note chart is generated algorithmically by `build_chart`, which produces a mix of single tap notes and hold notes across four lanes with varying tempo phases. The chart cycles through four speed phases (0.28s, 0.24s, 0.20s, 0.17s between notes) to create sections of varying density, and occasionally spawns simultaneous notes on two lanes. Hold notes require the player to keep the lane key pressed; releasing early breaks the hold and counts as a miss. Timing windows are tight: Perfect (within 0.05s), Great (within 0.10s), and Good (within 0.18s), with notes beyond 0.18s auto-counted as misses.

The game is built as a compact single-file design with all structs, chart generation, input handling, game logic, and rendering in `main.mbt`. Heavy use of closures (`reset_game`, `mark_miss`, `mark_hit`) encapsulates state mutation patterns cleanly.

## Build and Run

```bash
moon build --target native rhythm_street_beats_2026/
./_build/native/debug/build/rhythm_street_beats_2026/rhythm_street_beats_2026.exe
```

## Controls

- **D / Left Arrow**: Hit notes in lane 1
- **F / Up Arrow**: Hit notes in lane 2
- **J / Down Arrow**: Hit notes in lane 3
- **K / Right Arrow**: Hit notes in lane 4
- **Space**: Activate Fever mode (when fever meter is full and in play state)
- **Enter**: Start game from title screen; return to title from results screen
- **R**: Replay immediately from results screen
- **F11**: Toggle fullscreen
- **Mouse/Touch**: Click or tap lane pads at the bottom of the screen; click fever button to activate fever

## How to Play

From the title screen, press Enter or click to start. A 3-second countdown begins before notes start scrolling.

Notes scroll down four colored lanes toward a yellow judgment line at Y=588. Press the matching lane key (D/F/J/K or arrow keys) when a note crosses the line. The closer your timing, the higher the judgment:

- **Perfect** (within 0.05s): 1050 base score, +5.2 fever meter
- **Great** (within 0.10s): 760 base score, +3.8 fever meter
- **Good** (within 0.18s): 480 base score, +2.6 fever meter
- **Miss** (beyond 0.18s or wrong key): 0 score, combo reset, -8.5 life

**Hold Notes**: Some notes have tails extending downward. Press the lane key when the head arrives, then keep it held until the tail passes. Releasing early triggers a "HOLD BREAK" miss. Completed holds are graded by hold ratio: 90%+ = Perfect (1320), 75%+ = Great (980), 58%+ = Good (620), below 58% = Hold Miss.

**Combo System**: Each successful hit increases your combo counter. The score multiplier is `1.0 + floor(combo / 22) * 0.12`, capping at 2.9x. Fever mode adds an additional 1.1x on top. Each hit also restores 1.8 life.

**Fever Mode**: The fever meter fills from successful hits. When it reaches 100%, press Space or tap the FEVER button to activate an 8.2-second Fever mode that adds +1.1 to your score multiplier. The meter resets to 0 on activation.

**Life Bar**: Life starts at 100 and drains 8.5 on every miss. If life reaches 0, the track fails early. The track also ends naturally when all notes have been judged.

**Final Grade**: Based on weighted accuracy (Perfect=1.0, Great=0.82, Good=0.55, Miss=0.0): SS (97%+), S (93%+), A (87%+), B (80%+), C (below 80%).

## Public API Reference

### Package `rhythm_street_beats_2026`

> Single-file game with all types, logic, and rendering in main.mbt.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Note` | `active`, `lane`, `time`, `kind`, `end_time`, `state`, `hold_ratio`, `pop_t` | A chart note with lane assignment, timing, type (0=tap, 1=hold), judgment state (0=pending, 1=holding, 2=hit, 3=miss), hold completion ratio, and pop animation timer |
| `Particle` | `active`, `x`, `y`, `vx`, `vy`, `size`, `t`, `life`, `kind` | A visual particle effect element |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width |
| `sh` | `Int` | `760` | Screen height |
| `lane_count` | `Int` | `4` | Number of note lanes |
| `lane_w` | `Int` | `170` | Width of each lane in pixels |
| `track_x` | `Int` | `(sw - lane_w * lane_count) / 2` | Left edge of the note track |
| `track_y` | `Int` | `88` | Top edge of the note track |
| `track_h` | `Int` | `610` | Height of the note track |
| `hit_y` | `Float` | `588.0` | Y position of the judgment line |
| `scroll_speed` | `Float` | `390.0` | Note scroll speed in pixels per second |
| `max_notes` | `Int` | `920` | Note pool capacity |
| `max_particles` | `Int` | `680` | Particle pool capacity |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between lo and hi |
| `absf` | `(Float) -> Float` | Absolute value of a float |
| `minf` | `(Float, Float) -> Float` | Returns the smaller of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns the larger of two floats |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside a rectangle |
| `lane_x` | `(Int) -> Int` | Returns the left pixel X of a given lane |
| `lane_center` | `(Int) -> Float` | Returns the center X of a given lane as float |
| `note_y` | `(Float, Float) -> Float` | Converts a note's chart time to screen Y given current song time |
| `clear_notes` | `(Array[Note]) -> Unit` | Deactivates and resets all notes in the pool |
| `clear_particles` | `(Array[Particle]) -> Unit` | Deactivates and resets all particles in the pool |
| `spawn_particle` | `(Array[Particle], Float, Float, Float, Int) -> Unit` | Activates a single particle with position, speed multiplier, and kind |
| `burst` | `(Array[Particle], Float, Float, Int, Float, Int) -> Unit` | Spawns multiple particles in a burst |
| `build_chart` | `(Array[Note]) -> (Int, Float)` | Procedurally generates the note chart; returns (note_count, song_end_time) |

## Architecture

### Package Structure

```
rhythm_street_beats_2026/
├── main.mbt    -- All structs, chart generation, game logic, input, and rendering
└── moon.pkg    -- Package config with math and raylib imports
```

This is a single-file game. The `main` function allocates note and particle pools, creates per-lane input tracking arrays, and defines closures for state management (`reset_game`, `mark_miss`, `mark_hit`). The game state machine uses integer states: 0=title, 1=play, 2=results.

### Data Flow

1. **Chart Generation**: `build_chart` runs once per game start, filling the note array with 430+ notes across four lanes. Each note has a precise time value; the chart alternates through four tempo phases to create varying density.

2. **Input**: Each frame, per-lane key states are checked (D/F/J/K or arrows for lanes 0-3). Touch input detects mouse clicks within lane pad regions. Edge detection (`lane_press` vs `lane_down`) distinguishes taps from holds, crucial for hold note gameplay. Fever activation is checked via Space key or fever button click.

3. **Judgment**: When a lane is pressed, the game scans all active notes in that lane for the closest pending note within 0.18s. If found, tap notes are immediately judged by timing distance. Hold notes enter state 1 (holding) and accumulate `hold_ratio` each frame while the key remains held. If the key is released early, the hold breaks (miss). When `song_t` passes the note's `end_time`, the hold is graded by completion ratio. Pending notes that pass 0.18s beyond their time auto-miss.

4. **Scoring**: The `mark_hit` closure calculates score as `base * multiplier`, where multiplier = `1.0 + floor(combo/22) * 0.12 + (1.1 if fever active)`, capped at 2.9x base. It also increments the appropriate judgment counter (perfect/great/good), adds fever meter, restores life, and spawns particles. The `mark_miss` closure resets combo, decrements life by 8.5, and spawns red particles.

5. **Rendering**: The frame draws scrolling background lines, four colored lanes, the yellow judgment line, all visible notes (with hold tails for hold notes), particles, the HUD (score, combo, best combo, accuracy, life bar, fever bar), lane pad buttons, and state overlays (title, countdown, results with grade).

### Key Design Patterns

- **Closure-Based State Mutation**: `reset_game`, `mark_miss`, and `mark_hit` are closures that capture all mutable game variables. This provides clean encapsulation of complex state changes without needing to pass dozens of parameters.

- **Procedural Chart Generation**: `build_chart` creates the entire note chart algorithmically using deterministic math on the loop index to vary lane assignment, tempo, and hold note placement. This eliminates the need for external chart files.

- **Four-State Note Lifecycle**: Each note transitions through states: 0 (pending) -> 1 (holding, for hold notes) -> 2 (hit) or 3 (miss). The `pop_t` timer controls hit/miss animation duration before the note visually disappears.

- **Weighted Accuracy Grading**: Final accuracy is computed as `(perfect + great*0.82 + good*0.55) / total_judged * 100`, mapping to letter grades SS/S/A/B/C. This rewards Perfect judgments heavily while still giving partial credit for Great and Good.

- **Camera Shake Accumulator**: The `camera_shake` variable accumulates on misses (adding 0.12 per miss) and decays at 1.8/s, creating proportionally stronger shake during bad streaks.

- **Delta-Time with Cap**: Frame time is capped at 0.033s to prevent judgment window issues on slow frames.

## Improvement & Refinement Plan

1. **Extract into Multi-Package Architecture**: The entire game is in a single 1220+ line file. Splitting into `internal/types` (Note, Particle, constants), `internal/chart` (chart generation), `internal/game` (judgment logic, scoring), and `internal/render` (all drawing) would greatly improve maintainability.

2. **Add Audio Sync**: The game generates a visual note chart but plays no audio. Adding a backing track with beat-synced note generation would transform this from a visual reaction test into a true rhythm game.

3. **Replace Raw Integer States with Enums**: Note states (0-3), game states (0-2), and judgment kinds (0-3) are all raw integers. MoonBit enums would provide compile-time safety and readability.

4. **Add Chart Variety**: The current chart generation is deterministic with a single difficulty curve. Adding multiple difficulty presets (Easy, Normal, Hard) with different note densities and hold note frequencies would broaden appeal.

5. **Improve Hold Note Visual Feedback**: During a hold, the fill bar grows inside the tail, but there is no rhythmic feedback (like pulsing or sparks). Adding periodic particle bursts timed to the hold duration would make holds feel more engaging.

6. **Add Miss Recovery Mechanics**: A single miss costs 8.5 life with no way to recover beyond the 1.8 life per hit. Adding a "second chance" system where near-misses reduce life loss, or a combo shield that absorbs one miss at high combo, would reduce frustration.

7. **Implement Score Persistence**: The game tracks `best_combo` within a session but does not persist scores or grades. File-based persistence for high scores and best grades would add replay motivation.

8. **Add Touch-Specific Lane Highlighting**: When touching a lane pad, only the `lane_down` state is tracked visually. Adding a bright glow or ripple effect on the judgment line where the tap occurred would provide better feedback for touch players.
