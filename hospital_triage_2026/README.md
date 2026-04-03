# Hospital Triage 2026

A time-management game where you play as a nurse triaging patients across four hospital wards. Prioritize critical cases before they worsen and leave untreated.

## Build and Run

```bash
cd examples && moon build --target native hospital_triage_2026/
cd examples && ./_build/native/debug/build/hospital_triage_2026/hospital_triage_2026.exe
```

## Controls

- **A/D or Left/Right**: Move between wards
- **Space or Enter**: Admit the closest patient in the current ward
- **R**: Restart shift

## How to Play

Patients arrive continuously in 4 wards with varying severity levels: Mild (green), Medium (orange), and Critical (red). Move the nurse between wards and admit patients to the treatment bed. Each treatment takes time based on severity -- critical patients take longest but award the most points.

Patients who wait too long or walk off-screen are lost, costing lives (critical patients cost 2 lives). Successfully treating patients adds bonus time. Survive until the 150-second shift timer runs out, or lose when lives hit zero.

## Public API Reference

### Package `hospital_triage_2026`

> Main entry point.

The `main` function initialises a 1120x740 window, allocates a 140-slot `Patient` array, and runs the frame loop that handles nurse movement, patient spawning, treatment, patient loss, and rendering.

#### Types

| Type | Description |
|------|-------------|
| `Patient` | A hospital patient; tracks liveness, assigned ward, screen position, severity (0=mild, 1=medium, 2=critical), and elapsed wait time. |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `ward_x` | `(Int) -> Float` | Returns the screen x-coordinate for the centre of the given ward column. |
| `reset_patients` | `(Array[Patient]) -> Unit` | Marks all patient slots as inactive. |
| `spawn_patient` | `(Array[Patient]) -> Unit` | Finds the first inactive slot and spawns a patient in a random ward with probability-weighted severity. |
| `treat_time` | `(Int) -> Float` | Returns the treatment duration in seconds for the given severity level (2.2s mild, 3.4s medium, 4.8s critical). |
| `treat_score` | `(Int) -> Int` | Returns the score awarded for successfully treating a patient of the given severity (28/48/92). |
| `severity_color` | `(Int) -> @raylib.Color` | Maps severity index to a display colour (lime/orange/red). |
| `severity_name` | `(Int) -> String` | Maps severity index to a short label string ("MILD"/"MED"/"CRIT"). |
| `main` | `() -> Unit` | Entry point: initialises Raylib, runs the triage game loop, and closes the window on exit. |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1120` | Screen width in pixels. |
| `sh` | `Int` | `740` | Screen height in pixels. |
| `ward_count` | `Int` | `4` | Number of hospital wards. |

## Architecture

All game logic resides in `main.mbt`. Key design patterns:
- A single `Patient` array with 140 pre-allocated slots; `spawn_patient` scans for the first inactive slot to avoid heap allocation each spawn.
- Ward positions are computed by `ward_x(ward)` returning a formula-driven x-coordinate, so adding more wards only requires changing `ward_count`.
- Patients scroll downward at a speed proportional to severity, creating urgency; they are lost either when the wait-time panic threshold is exceeded or when they scroll off the bottom.
- A single treatment bed is modelled with boolean `treating` and a timer `tr_time_left`; only one patient can be treated at a time, forcing prioritisation decisions.
- Successful treatment adds 2.6 seconds to the shift timer (capped at 170 s), incentivising throughput.
- Delta-time updates capped at 50 ms ensure consistent behaviour at low frame rates.
- Integer-encoded game state uses a single `over` boolean; no separate title screen — the game starts immediately.

## Improvement & Refinement Plan

1. Add a title or instruction screen instead of starting immediately, so players can read the rules before the first patient appears.
2. Introduce an upgrade system between rounds (faster movement, extra treatment bed, slower patient decay) to add long-term progression.
3. Display a per-ward queue count overlay so nurses can assess workload at a glance without counting individual patient circles.
4. Replace the fixed 0.48-second spawn tick with a wave-based escalation curve tied to elapsed time, creating tension spikes rather than uniform pressure.
5. Add distinct patient animations or icons for each severity level to improve readability in busy ward columns.
6. Implement a high-score leaderboard using Raylib's storage API so scores persist across sessions.
7. Add sound effects for patient admission, treatment completion, and patient loss using Raylib's audio API to improve feedback clarity.
