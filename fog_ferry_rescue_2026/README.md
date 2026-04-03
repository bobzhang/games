# fog_ferry_rescue_2026

A nautical rescue game set in dense fog. Navigate a ferry through fog-covered waters, locate stranded groups using sonar pings, pick up survivors, deliver them to docks, and avoid floating debris.

## Build and Run

```bash
moon build --target native fog_ferry_rescue_2026/
./_build/native/debug/build/fog_ferry_rescue_2026/fog_ferry_rescue_2026.exe
```

## Controls

- **WASD / Arrow keys**: Steer and accelerate the ferry
- **Space/J**: Rescue nearby survivors / dock to deliver passengers
- **K/L**: Sonar ping (reveals hidden survivors through fog)
- **R**: Restart

## How to Play

- Navigate through fog that obscures visibility; use sonar pings to locate survivor groups
- Approach survivors to rescue them onto the ferry (limited passenger capacity)
- Deliver passengers to docks to score and refuel
- Avoid floating debris that damages hull
- Manage fuel (depletes while moving) and hull integrity
- Docks decay over time and may become inactive
- Rescue as many groups as possible before fuel or hull runs out

## Public API Reference

### Package `tonyfettes/raylib-examples/fog_ferry_rescue_2026`

#### Types and Structs

- **`struct Player`** — The ferry controlled by the player. Fields: `x, y, vx, vy, heading : Float` (position, velocity, facing angle), `hull, hull_max, fuel, fuel_max : Float` (resource bars; both start at 100.0), `passengers : Int` (currently aboard), `capacity : Int` (max 38), `rescue_cd : Float` (cooldown between rescues), `ping_cd, ping_t, ping_x, ping_y : Float` (sonar ping state), `wake_t : Float` (visual wake timer).
- **`struct Dock`** — A delivery point on the map. Fields: `active : Bool`, `x, y : Float`, `queue : Float` (pending passenger count), `decay : Float`, `id : Int`.
- **`struct Group`** — A stranded group of survivors. Fields: `active : Bool`, `x, y : Float`, `count : Int` (number of people), `panic : Float` (0–100; group is lost at 100), `drift_x, drift_y : Float` (slow random drift velocity), `flare_t : Float` (flare flash timer), `id : Int`.
- **`struct FogCell`** — A single animated fog patch. Fields: `active : Bool`, `x, y, vx, vy : Float`, `radius : Float` (74–148 px), `density : Float` (0.45–1.15 + tier bonus), `life : Float` (20–42 s), `phase : Float` (oscillation accumulator).
- **`struct Debris`** — A floating hazard that damages the hull. Fields: `active : Bool`, `x, y, vx, vy : Float`, `size : Float` (8–22 px radius), `hard : Float` (24–100; damage coefficient), `spin : Float` (rotation accumulator).
- **`struct Particle`** — Short-lived visual effect. Fields: `active : Bool`, `x, y, vx, vy : Float`, `life, size : Float`, `kind : Int` (0 = wake/splash, 1 = impact sparks, 2 = rescue burst).

#### Functions

- **`fn clampf(Float, Float, Float) -> Float`** — Clamps a float to `[lo, hi]`.
- **`fn minf(Float, Float) -> Float`** — Returns the smaller of two floats.
- **`fn maxf(Float, Float) -> Float`** — Returns the larger of two floats.
- **`fn absf(Float) -> Float`** — Returns the absolute value of a float.
- **`fn mini(Int, Int) -> Int`** — Returns the smaller of two integers.
- **`fn randf(Float, Float) -> Float`** — Returns a pseudo-random float in `[lo, hi]`.
- **`fn dist2(Float, Float, Float, Float) -> Float`** — Returns the squared Euclidean distance between two points.
- **`fn inside_rect(Float, Float, Int, Int, Int, Int) -> Bool`** — Returns true when point `(px, py)` is within the given rectangle.
- **`fn clear_docks(Array[Dock]) -> Unit`** — Deactivates all dock slots and resets their fields.
- **`fn clear_groups(Array[Group]) -> Unit`** — Deactivates all group slots and resets their fields.
- **`fn clear_fogs(Array[FogCell]) -> Unit`** — Deactivates all fog cell slots and resets their fields.
- **`fn clear_debris(Array[Debris]) -> Unit`** — Deactivates all debris slots and resets their fields.
- **`fn add_particle(Array[Particle], Float, Float, Int) -> Unit`** — Activates the first idle particle slot at `(x, y)` with randomised velocity and lifetime.
- **`fn burst(Array[Particle], Float, Float, Int, Int) -> Unit`** — Calls `add_particle` `n` times to emit a multi-particle burst.
- **`fn update_parts(Array[Particle], Float) -> Unit`** — Advances all active particles by `dt`: integrates position, applies per-kind drag and gravity.
- **`fn init_docks(Array[Dock], Int, Int, Int, Int) -> Unit`** — Places 7 active docks at fixed world-relative positions with initial queue values (16–28).
- **`fn init_debris(Array[Debris], Array[Dock], ...) -> Unit`** — Fills the debris pool (up to `pool.length() - 12` pieces) at random positions that avoid the harbor zone and dock vicinities.
- **`fn spawn_group(Array[Group], ..., Int, Int) -> Bool`** — Activates a free group slot, spawning it from a random world edge with drift velocity; group size is `4 + rand(0, 8 + tier * 2)`.
- **`fn spawn_fog(Array[FogCell], ..., Int) -> Bool`** — Activates a free fog cell entering from a random world edge.
- **`fn active_groups(Array[Group]) -> Int`** — Counts currently active groups.
- **`fn active_fogs(Array[FogCell]) -> Int`** — Counts currently active fog cells.
- **`fn active_panic(Array[Group]) -> Int`** — Counts groups whose panic is 70 or above.
- **`fn peak_group_panic(Array[Group]) -> Float`** — Returns the highest panic value among all active groups.
- **`fn update_fogs(Array[FogCell], Float, ...) -> Unit`** — Moves each fog cell, applies pulse modulation, and bounces cells off world boundaries.
- **`fn update_debris(Array[Debris], Float, ...) -> Unit`** — Drifts debris with sinusoidal speed variation, bounces off boundaries, and slowly reduces `hard`.
- **`fn update_groups(Array[Group], Array[FogCell], Float, ...) -> (Int, Float)`** — Drifts all groups, accumulates panic from time, distance from harbor, and fog overlap; deactivates groups that reach panic 100. Returns `(lost_count, panic_sum)`.
- **`fn rescue_groups(Player, Array[Group], Array[Particle]) -> (Int, Int)`** — Transfers up to 8 survivors per nearby group (within 82 px) onto the ferry, reduces group panic by `taken * 2.8`, and emits a rescue burst. Returns `(total_rescued, groups_touched)`.
- **`fn nearest_urgent_group(Array[Group], Float, Float) -> (Bool, Float, Float, Float)`** — Finds the closest group with panic >= 30 to the given point. Returns `(found, x, y, panic)`.
- **`fn main`** — Entry point. Opens a 1680 x 940 window at 120 fps, runs the full monolithic game loop including input, simulation, rendering, and state management.

## Architecture

### Package Structure

```
fog_ferry_rescue_2026/
└── main.mbt          # All structs, helper functions, and the monolithic game loop (2403 lines)
```

### Data Flow

All state is declared as local `let` and `let mut` bindings inside `fn main`. On each frame the loop reads keyboard and touch state into local booleans, processes movement and action inputs, then calls the simulation helpers sequentially: `update_fogs`, `update_debris`, `update_groups`, debris-collision damage, dock queue updates, `rescue_groups` when the rescue key is pressed, sonar ping when the ping key is pressed, and group spawning governed by `spawn_cd`. The results of `update_groups` are accumulated into `lost_people` and checked against `lost_limit` (150).

Rendering follows immediately after the update pass within the same frame. Draw calls are direct: `draw_water`, `draw_harbor`, `draw_debris`, `draw_docks`, `draw_groups`, `draw_fogs`, `draw_player`, particle overlay, the side panel with bars, and optional state overlays for menu (state 0), win (state 2), and loss (state 3). The sonar ping ring is rendered inline rather than in a dedicated function.

Resource management is interlinked: the ferry refuels and repairs at the harbor at 24 px/s and 5.4 px/s respectively; fog cells add `fog_fuel_mul` drag to fuel consumption; debris collisions apply continuous hull damage proportional to `debris.hard * 0.018 * dt`. Tier increases every 110 rescued survivors (capped at 9), which raises fog density, group spawn rate, and the harbor queue fill rate simultaneously.

Game-over conditions (state 3) are checked after all updates: `timer <= 0` (420 s game clock), `lost_people >= lost_limit` (150), `player.hull <= 0`, or `harbor_queue >= harbor_queue_max - 2` (harbor capacity 260). The win condition (state 2) is `rescued_total >= target_rescued` (620 survivors).

### Key Design Patterns

- **Monolithic single-file design** — All 2403 lines live in `main.mbt`. This avoids package-boundary overhead and keeps the entire simulation visible in one scroll, which suits the prototype-style complexity of a large game with many interacting systems.
- **Fixed object pools** — All pools are allocated once with `Array::makei`: 26 groups, 24 fog cells, 210 debris pieces, 7 docks, 900 particles. Each element has an `active` flag; helpers scan linearly for free slots, eliminating heap allocation during gameplay.
- **Panic accumulation as a resource drain** — Group panic increases from three independent sources (time, distance from harbor, and fog overlap proximity ratio). The additive formula `dt * density * (0.8 + ratio * 1.6)` makes fog a non-linear hazard: dense fog near a group escalates panic faster than sparse fog.
- **Tiered difficulty without discrete levels** — `tier` is recomputed each frame as `1 + rescued_total / 110`, so fog density, group size ceilings, and harbor queue fill rate scale continuously with player progress rather than snapping at fixed thresholds.
- **Fog as a multi-system modifier** — Fog cells independently affect player drag (`fog_drag`), fuel burn rate (`fog_fuel_mul`), group panic gain, and dock queue load, so a single fog cell entering the play area cascades pressure across multiple game systems.
- **Harbor as the strategic anchor** — Refuelling, hull repair, and passenger unloading all require proximity to the harbor zone. This concentrates safe-zone logic in a single `inside_rect` check and creates a natural risk/reward loop: venturing farther into fog earns more rescues but increases the time away from resupply.

## Improvement & Refinement Plan

1. **Fog visibility masking** — Currently fog cells impose drag and panic pressure but do not occlude the screen; the player can see all groups even through dense fog. Rendering an alpha-blended fog overlay using the `FogCell` position and density would match the game's stated premise and force genuine use of the sonar ping.
2. **Sonar ping cooldown indicator** — The `ping_cd` field resets to 2.0 after a successful ping but there is no HUD bar showing its remaining cooldown. Adding a small cooldown arc or progress bar next to the controls panel would eliminate guesswork about when the ping is available.
3. **Per-dock capacity bar** — Docks have a `queue` field but it is not displayed. Showing each dock's queue as a small bar near its icon would help players prioritise which dock to deliver to, especially at high tier when queues grow quickly.
4. **Rescue radius feedback** — The rescue range of 82 px is invisible. Drawing a faint circle around the player that brightens when a rescuable group is within range would communicate the mechanic without requiring players to learn the exact pixel radius.
5. **Debris hardness decay visualisation** — `debris.hard` decreases over time from a starting value up to 100 down toward 8, meaning older debris deals less damage. Tinting softer debris lighter or smaller would give players a visual cue about which pieces are the most dangerous.
6. **Graduated unloading speed** — Unloading is capped at 3 passengers per 0.12 s tick. At full capacity (38 passengers) this creates a noticeable delay at the harbor. Scaling the unload batch size with the number of passengers aboard (e.g. `mini(passengers, 3 + passengers / 12)`) would reduce harbor dwell time at high passenger counts.
7. **Dynamic group flare visibility** — The `flare_t` timer drives a blinking signal for groups, but the flash is the same brightness regardless of panic level. Making the flare brighter and faster as panic approaches 100 would create an urgent visual signal and help players triage rescue priority.
