# Martial Arts School Manager 2026

A real-time management simulation where you run a martial arts dojo with six named students. Each week runs on a countdown timer, and you must continuously assign students to four rooms -- Rest, Train, Spar, and Defense -- to balance skill growth, fatigue recovery, income generation, and defense readiness against periodic incidents that threaten your school.

The core loop is a survival-style resource management game. Funds drain from training costs and weekly upkeep (which escalates each week), while reputation erodes passively and from incidents. Sparring generates income and reputation but exhausts students. Training builds skill (which amplifies sparring returns) but costs money. Defense mitigates incident damage but provides only a small stipend. Rest recovers fatigue but produces nothing. A speed burst mechanic lets you accelerate time temporarily when you need resources faster, but it also speeds up incident timers and fatigue accumulation.

The game features detailed economic simulation with over 30 tuning constants governing costs, income rates, fatigue dynamics, and incident severity scaling. Students have individual names, starting skills, and fatigue levels, creating asymmetric management decisions.

## Build and Run

```bash
moon build --target native raylib_martial_arts_school_manager_2026/
./_build/native/debug/build/raylib_martial_arts_school_manager_2026/raylib_martial_arts_school_manager_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Move cursor across the student-room grid
- **J**: Assign selected student to the room under the cursor
- **K**: Force selected student back to Rest (with immediate 4.5 fatigue reduction)
- **Space**: Activate speed burst (3.5x time acceleration for 2.2s, 9s cooldown)
- **P**: Pause / unpause
- **R**: Restart (begins a new run)
- **Enter**: Start game (from title) / restart (from game over)
- **F11**: Toggle borderless windowed mode

## How to Play

You manage six students: Aiko, Bo, Chun, Daichi, Eri, and Feng, each with different starting skill levels (34-52). Your goal is to survive as many weeks as possible before running out of funds or reputation.

**Rooms:**
- **Rest**: Recovers fatigue at 9.5/s. Produces nothing.
- **Train**: Builds skill at 2.9/s (scaled by fatigue), but costs 8/s and adds 6.8 fatigue/s. Skill caps at 130.
- **Spar**: Earns income (13/s) and reputation (0.46/s), both scaled by student form and skill. Adds 4.2 fatigue/s.
- **Defense**: Provides a small stipend (2.6/s + 0.24/s per week). When incidents occur, defense power (sum of skill * freshness for defenders) blocks a portion of the damage.

**Economics:**
- Operating costs drain funds continuously (5.2/s + 1.6/s per week past week 1)
- Reputation drains passively (0.05/s + 0.006/s per week)
- Weekly upkeep of 220 + 38 per week, plus 52 salary per student, is deducted at week end
- Average fatigue above 74 drains reputation; above 96 drains funds; burnout (99+) ends the game

**Incidents** occur at random intervals (12.5s base, decreasing by 0.52s per week, minimum 4.8s). Each causes fund loss, reputation loss, and fatigue increase, mitigated by defense power. Defense can block up to 86% of damage.

**Week progression**: Each week has a countdown timer (36s base, decreasing by 1.35s per week, minimum 18s). When it expires, weekly upkeep is deducted, a performance evaluation adjusts reputation, all students recover some fatigue, and the next week begins with higher pressure.

## Public API Reference

### Package `raylib_martial_arts_school_manager_2026`

> Main entry point.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Initializes window with MSAA, creates Game, runs main loop |

### Package `raylib_martial_arts_school_manager_2026/internal/types`

> Core type definitions, constants, and utility functions.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `GameState` | `Title`, `Playing`, `Paused`, `GameOver` | Game state machine states |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Student` | `name`, `skill`, `fatigue`, `room` | A dojo student with name, skill level, fatigue, and current room assignment |
| `Input` | `move_x`, `move_y`, `confirm_pressed`, `cancel_pressed`, `burst_pressed`, `pause_pressed`, `restart_pressed`, `start_pressed` | Per-frame input state container |
| `Game` | `input`, `students`, `state`, `week`, `funds`, `reputation`, `week_duration`, `week_time_left`, `cursor_row`, `cursor_col`, `speed_burst_t`, `speed_burst_cd`, `incident_timer`, `incident_count_week`, `total_incidents`, etc. | Main game state with students, economy, timing, and UI state |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_w` | `Int` | `1600` | Screen width |
| `screen_h` | `Int` | `960` | Screen height |
| `target_fps` | `Int` | `120` | Target frame rate |
| `room_rest` | `Int` | `0` | Rest room ID |
| `room_train` | `Int` | `1` | Training room ID |
| `room_sparring` | `Int` | `2` | Sparring room ID |
| `room_defense` | `Int` | `3` | Defense room ID |
| `room_count` | `Int` | `4` | Total number of rooms |
| `student_count` | `Int` | `6` | Total number of students |
| `start_funds` | `Float` | `1650.0` | Starting funds |
| `start_reputation` | `Float` | `62.0` | Starting reputation |
| `week_duration_base` | `Float` | `36.0` | Base week duration in seconds |
| `week_duration_drop` | `Float` | `1.35` | Week duration decrease per week |
| `week_duration_min` | `Float` | `18.0` | Minimum week duration |
| `week_upkeep_base` | `Float` | `220.0` | Base weekly upkeep cost |
| `week_upkeep_growth` | `Float` | `38.0` | Upkeep increase per week |
| `student_salary_weekly` | `Float` | `52.0` | Weekly salary per student |
| `operation_cost_per_sec` | `Float` | `5.2` | Continuous operating cost per second |
| `operation_cost_week_scale` | `Float` | `1.6` | Additional operating cost per week |
| `train_cost_per_sec` | `Float` | `8.0` | Training cost per second |
| `train_skill_gain_per_sec` | `Float` | `2.9` | Skill gain per second from training |
| `train_fatigue_gain_per_sec` | `Float` | `6.8` | Fatigue gain per second from training |
| `spar_income_per_sec` | `Float` | `13.0` | Income per second from sparring |
| `spar_rep_gain_per_sec` | `Float` | `0.46` | Reputation gain per second from sparring |
| `spar_fatigue_gain_per_sec` | `Float` | `4.2` | Fatigue gain per second from sparring |
| `defense_stipend_per_sec` | `Float` | `2.6` | Base stipend per second for defense |
| `rest_fatigue_recover_per_sec` | `Float` | `9.5` | Fatigue recovery per second while resting |
| `fatigue_max` | `Float` | `100.0` | Maximum fatigue value |
| `fatigue_penalty_start` | `Float` | `74.0` | Fatigue threshold for reputation penalty |
| `burnout_threshold` | `Float` | `99.0` | Average fatigue threshold triggering game over |
| `burst_duration` | `Float` | `2.2` | Speed burst active duration in seconds |
| `burst_cooldown` | `Float` | `9.0` | Speed burst cooldown in seconds |
| `burst_time_multiplier` | `Float` | `3.5` | Time multiplier during speed burst |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Student::new` | `(String, Float) -> Student` | Creates a student with name, skill, default fatigue 12.0, and room set to Rest |
| `Input::new` | `() -> Input` | Creates a zeroed input state |
| `Game::new` | `() -> Game` | Creates a new game with 6 students, default economy, and Title state |
| `student_name` | `(Int) -> String` | Returns the canonical name for student slot 0-5 |
| `starting_skill` | `(Int) -> Float` | Returns the starting skill for student slot 0-5 |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between bounds |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between bounds |
| `minf` | `(Float, Float) -> Float` | Returns minimum of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns maximum of two floats |
| `sinf` | `(Float) -> Float` | Computes sine of a float |
| `week_duration_for` | `(Int) -> Float` | Computes week duration for a given week number |
| `upkeep_for` | `(Int) -> Float` | Computes weekly upkeep cost for a given week |
| `incident_gap_for` | `(Int) -> Float` | Computes base incident interval for a given week |
| `incident_severity_for` | `(Int) -> Float` | Computes incident severity multiplier for a given week |
| `room_name` | `(Int) -> String` | Returns the display name for a room ID |

### Package `raylib_martial_arts_school_manager_2026/internal/game`

> Game logic, input handling, and state updates.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main update: samples input, updates timers, dispatches to state-specific update functions |
| `init_title_scene_pub` | `(Game) -> Unit` | Public wrapper to initialize the title scene state |

### Package `raylib_martial_arts_school_manager_2026/internal/render`

> Rendering and drawing routines.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_frame` | `(Game) -> Unit` | Main rendering entry point: draws background, HUD, student table, footer, banners, messages, and state overlays |

## Architecture

### Package Structure

```
raylib_martial_arts_school_manager_2026/
├── main.mbt                      — Entry point: window init with MSAA, game loop
├── moon.pkg                      — Root package config
└── internal/
    ├── types/
    │   ├── types.mbt             — GameState enum, Student/Input/Game structs, constructors
    │   ├── constants.mbt         — 30+ economic and gameplay tuning constants
    │   └── utils.mbt             — Math helpers, week/upkeep/incident formula functions, room names
    ├── game/
    │   ├── input.mbt             — Keyboard input sampling into Input struct
    │   └── logic.mbt             — Room simulation, fatigue pressure, incidents, week advancement, state machine
    └── render/
        └── render.mbt            — Background, HUD, student grid, overlays, meters, messages
```

### Data Flow

1. **Initialization**: `main` creates a `Game` via `Game::new()` and calls `init_title_scene_pub` to set initial state.
2. **Input**: `sample_input` clears and repopulates the `Input` struct each frame from keyboard state.
3. **Update**: `update_game` dispatches by `GameState`. During `Playing`, it processes cursor movement, room assignment, burst activation, then runs the continuous simulation: `apply_room_simulation` updates funds/reputation/skill/fatigue per student based on room, `apply_fatigue_pressure` penalizes high average fatigue, incident timer fires `trigger_incident` which calculates damage mitigated by defense power, and `advance_week` handles end-of-week upkeep/evaluation.
4. **Rendering**: `draw_frame` renders the HUD (week, funds, reputation, fatigue, week progress bar, burst status), the student-room grid table with assignment indicators and cursor highlight, footer help text, week banners, messages, and state-specific overlays (title, paused, game over).

### Key Design Patterns

- **Continuous real-time simulation**: Unlike turn-based management games, all room effects accumulate per second via `sim_dt`, creating urgency and requiring active management.
- **Speed burst mechanic**: The `burst_time_multiplier` (3.5x) accelerates `sim_dt` for the simulation while `dt` remains normal for UI, letting players fast-forward but at the risk of missing incidents.
- **Escalating difficulty**: Nearly every parameter worsens with week number -- shorter weeks, higher upkeep, faster incidents, greater severity, higher operating costs, and faster reputation drain.
- **Defense power calculation**: `defense_power` sums `skill * freshness` for all defenders, where freshness decreases with fatigue, creating a trade-off between keeping students sharp and putting them on defense.
- **State machine with explicit transitions**: `GameState` enum drives logic branches. Transitions are explicit in `advance_week` (Playing), `set_game_over` (GameOver), and `update_paused_state` (Paused).
- **Structured input pipeline**: The `Input` struct decouples input sampling from logic, allowing clean state-based input handling.

## Improvement & Refinement Plan

1. **Add touch/mouse input support**: Currently only keyboard input is sampled in `sample_input`. Adding mouse click detection on the student-room grid cells would make the game accessible on touch devices and with mouse.

2. **Display individual room effects in UI**: The student table shows skill and fatigue meters but not the per-second rates for the current room assignment. Adding "+2.9 skill/s" or "-9.5 fatigue/s" labels next to each student would help players make informed decisions.

3. **Add student specialization**: All students respond identically to rooms (same fatigue rates, skill gains). Adding traits like "fast learner" (higher `train_skill_gain_per_sec`) or "tough" (lower fatigue rates) via per-student multipliers would create more strategic depth.

4. **Balance early-game economy**: Starting funds of 1650 with operation costs of 5.2/s and training at 8/s means aggressive training can bankrupt the school in under a minute. Adding a brief grace period or lower costs in week 1 would improve the new player experience.

5. **Add visual feedback for room assignments**: When a student is assigned via `assign_selected_room`, only a text message appears. Adding a brief animation (color flash, position shift) on the grid cell would provide better feedback.

6. **Implement student morale system**: Fatigue serves as the only negative state. Adding a morale value affected by consecutive weeks in the same room, victories in sparring, and incidents would add another management dimension.

7. **Replace magic numbers in render code**: Hard-coded pixel positions in `draw_student_table` (e.g., `panel_x + 422`, `row_h = 84`) could be computed from screen dimensions and student count for resolution independence.
