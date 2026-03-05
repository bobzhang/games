# Radio Station Manager 2026

A radio DJ simulation where you manage a 180-second broadcast shift, selecting songs from a rotating four-track queue to satisfy a fickle audience whose mood preferences shift over the course of the show. The game blends resource management with reactive decision-making as you balance listener retention, station rating, and advertising revenue.

Each song has a mood (Chill, Pop, Rock, or Classic) and an energy level. The audience's desired mood changes as the shift progresses -- starting with Chill, moving to Pop in the middle, then Rock toward the end. Playing songs that match the desired mood and energy range grows your listener base and rating, while mismatches drive listeners away. Ad breaks generate budget but cost listeners and rating, and have a 9-second cooldown between uses. The shift ends when the timer hits zero or all listeners tune out.

The game is implemented as a compact single-file design with the entire simulation model, input handling, and rendering contained in `main.mbt`. The listener model uses a trend accumulator that must cross a threshold before causing discrete listener changes, creating smooth audience behavior rather than jittery per-frame fluctuations.

## Build and Run

```bash
moon build --target native radio_station_manager_2026/
./_build/native/debug/build/radio_station_manager_2026/radio_station_manager_2026.exe
```

## Controls

- **1 / 2 / 3 / 4**: Immediately play the corresponding queued track
- **A**: Run an ad break (+14 budget, -5 listeners, -2 rating; 9s cooldown)
- **R**: Restart the broadcast shift

## How to Play

You begin a broadcast shift with 62 listeners, a rating of 50, a budget of 50, and 180 seconds on the clock. Four songs sit in the queue, each displaying its mood, energy level, and duration.

The audience's desired mood depends on how much time remains: during the first 60 seconds (shift_time > 120), the audience wants **Chill** (mood 0); between 60-110 seconds elapsed (shift_time 70-120), they want **Pop** (mood 1); in the final stretch (shift_time < 70), they want **Rock** (mood 2). Playing a song whose mood matches the desired mood contributes +2.2 to the trend; a mismatch contributes -1.6. The desired energy target also varies: 45 for Chill, 62 for Pop, 75 for Rock. If the current song's energy is within 14 of the target, it adds +1.5 to trend; otherwise -1.1.

The trend accumulates over time with a constant -0.8/s decay. When trend exceeds +3.0, you gain a listener and a rating point (trend resets to 1.0). When it drops below -3.0, you lose a listener and a rating point (trend resets to -1.0). Listeners are clamped to 0-120, rating to 0-100.

Songs count down in real time and auto-advance to queue slot 1 when they finish. You can manually select any of the four queued tracks at any time with the 1-4 keys; the queue shifts forward and a new random song fills the last slot. Press A to run an ad break for +14 budget at the cost of 5 listeners and 2 rating. Budget also passively grows by `listeners / 70` per frame.

The shift ends when the timer reaches zero ("Broadcast complete") or when listeners drop to zero ("No audience left"). Press R at any time to restart.

## Public API Reference

### Package `radio_station_manager_2026`

> Single-file game with all logic, rendering, and types in main.mbt.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Song` | `mood`, `len`, `energy` | A song with mood category (0-3), duration in seconds, and energy level (30-95) |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `mood_name` | `(Int) -> String` | Converts mood integer to display name ("Chill", "Pop", "Rock", "Classic") |
| `mood_color` | `(Int) -> Color` | Returns a display color for each mood category |
| `random_song` | `() -> Song` | Generates a random song with random mood, length (6-11s), and energy (30-95) |
| `take_song` | `(Array[Song], Int) -> Song` | Removes a song from the queue at the given slot, shifts remaining songs forward, fills the last slot with a new random song |

## Architecture

### Package Structure

```
radio_station_manager_2026/
├── main.mbt    -- All game logic, rendering, and types in a single file
└── moon.pkg    -- Package config with raylib import
```

This is a compact single-file game. The `main` function contains the entire game loop: initialization of the song queue and game variables, input handling, the listener/rating simulation model, and all rendering code. There are no internal packages.

### Data Flow

1. **Input**: Each frame checks for key presses: 1-4 to select a queued track (calls `take_song`), A to trigger an ad break (if cooldown allows), and R to restart.

2. **Simulation**: The current track's remaining time counts down. When it expires, the next track is auto-selected via `take_song(queue, 0)`. The listener model computes a `desired` mood based on remaining shift time, then evaluates the current song's mood and energy against that target to produce a `trend` delta. When trend crosses thresholds (+3 or -3), listeners and rating change by 1. Budget slowly accumulates based on listener count.

3. **Rendering**: The frame draws a header with stats (listeners, rating, budget, time), a "LIVE NOW" panel showing the current track's mood/energy/remaining time with a colored circle, a queue board with all four upcoming tracks, a hint line about mood progression, a status message bar, and an overlay when the shift ends.

### Key Design Patterns

- **Queue with Shift-Forward**: The `take_song` function manually shifts array elements forward when a song is picked, then fills the last slot with a fresh random song. This maintains a fixed-size 4-element queue without dynamic allocation.

- **Trend Accumulator Model**: Instead of directly changing listener count each frame, mood/energy match quality feeds into a floating-point `trend` value that must accumulate past a threshold before causing a discrete listener change. This creates smooth, non-jittery audience behavior.

- **Time-Based Desired Mood**: The audience preference is not random but deterministic based on remaining shift time, giving the player a predictable arc to plan around.

- **Delta-Time with Cap**: Frame time is capped at 0.05s to prevent simulation jumps on slow frames.

## Improvement & Refinement Plan

1. **Extract Simulation Logic into Functions**: The entire listener model (mood matching, energy matching, trend accumulation, clamp logic) is inline in the main loop. Extracting it into a dedicated `update_simulation` function would improve readability and testability.

2. **Add Visual Feedback for Mood Match**: The player has no direct visual indicator of whether the current song matches the desired mood. Adding a colored "MATCH" / "MISMATCH" indicator or a trend direction arrow on the live deck would help players make better decisions.

3. **Replace Mood Integers with an Enum**: The mood system uses raw integers (0-3) with `mood_name` and `mood_color` helper functions. A proper MoonBit enum (`Chill`, `Pop`, `Rock`, `Classic`) would be safer and more readable.

4. **Add Classic Mood to Desired Rotation**: The desired mood cycles through Chill, Pop, and Rock but never requests Classic (mood 3), making Classic songs always a mismatch. Including it in the rotation or as a bonus mood would give it gameplay purpose.

5. **Show Trend Direction**: The trend value is invisible to the player. Displaying a trend bar or arrow in the HUD would give feedback on whether the current programming is working before a listener change occurs.

6. **Add Song Variety or Names**: All songs are generic with only mood, energy, and length. Adding randomly generated station names or genre labels would enhance the radio station theme.

7. **Implement Budget Spending**: Budget accumulates but is never spent on anything. Adding purchasable upgrades (better antenna for more listener capacity, promotions for rating boosts) would create a meaningful resource loop.
