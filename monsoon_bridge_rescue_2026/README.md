# Monsoon Bridge Rescue 2026

A flood rescue action game where you pilot a rescue boat through monsoon-swollen waters, dodging debris and lightning strikes while rescuing survivors stranded on rafts and keeping collapsing bridge spans from failing. Set in a turbulent river environment with dynamic currents, escalating storm intensity, and a 460-second countdown timer.

The core gameplay loop revolves around three simultaneous objectives: rescue at least 160 survivors by loading them from floating rafts and delivering them to the evacuation camp, maintain all five bridge span integrity levels above the 84% collapse threshold by spending repair kits, and keep the number of lost survivors below 190. The player manages hull integrity, fuel, rescue kits, and passenger capacity while navigating a 4x3 current grid that applies directional flow forces to everything in the water. A siren ability calms nearby raft panic, and floating supply crates provide emergency fuel and kit refills.

The game features a rich simulation layer with 12 current cells that create realistic water flow patterns, a storm intensity system that ramps up over time affecting spawn rates, debris speed, and lightning frequency, plus a full particle system for boat wakes, debris collisions, and rain. Touch controls with an on-screen D-pad and action buttons provide mobile support.

## Build and Run

```bash
moon build --target native monsoon_bridge_rescue_2026/
./_build/native/debug/build/monsoon_bridge_rescue_2026/monsoon_bridge_rescue_2026.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Steer the rescue boat
- **Space or J**: Boost engine (increases speed, drains extra fuel, builds heat)
- **L or U**: Action -- rescue survivors from nearest raft, or repair nearest bridge span (uses kits)
- **K or H**: Activate siren pulse (calms raft panic in 220px radius for 3.6s, costs 6 fuel, 8.8s cooldown)
- **Enter**: Start game / restart after end
- **R**: Restart after game end
- **F11**: Toggle borderless windowed mode
- **Touch D-pad (on-screen)**: Directional movement
- **BOOST button (on-screen)**: Engine boost
- **ACT button (on-screen)**: Rescue/repair action
- **PING button (on-screen)**: Siren pulse

## How to Play

Start from the title screen by pressing Enter or tapping the start button. You begin at the Supply Dock in the lower-left corner of the river with full fuel, 8 repair kits, and an empty passenger hold (capacity 20).

**Rescue survivors**: Approach floating rafts (orange circles with survivor counts) and press the Action key (L/U) to load up to 5 survivors per action. Deliver them to the Evac Camp in the upper-right corner -- passengers automatically unload while docked. Rafts drift with water currents and build panic over time; if panic reaches 1.36 or they drift off-screen, their survivors are lost.

**Maintain bridges**: Five bridge spans run vertically through the center of the map. Their integrity decays constantly (accelerated by storm intensity and lightning strikes). Approach a span and press Action with kits available to repair 8-14% integrity. Spans below 44% show warning indicators. If any span hits 0%, the mission fails.

**Manage resources**: The Supply Dock refuels your boat passively while docked and restocks kits on Action press. Floating supply crates marked "K" (kits) and "F" (fuel) can be collected by touching them. Boost drains fuel faster and builds heat; running out of fuel reduces acceleration to 210 (from 340 normal / 540 boost).

**Survive hazards**: Floating debris damages hull on contact. Lightning strikes telegraph with a blinking circle, then damage everything in radius -- both your boat and nearby bridge spans. The storm intensifies as the timer counts down, spawning more debris, faster lightning, and stronger currents.

**Win condition**: Rescue 160+ survivors AND maintain all bridge spans above 84% integrity within 460 seconds. **Loss conditions**: Hull reaches 0, any bridge span reaches 0% integrity, 190+ survivors lost, or timer expires without meeting objectives.

## Public API Reference

### Package `monsoon_bridge_rescue_2026`

> Complete single-file game with all structs, logic, rendering, and entry point.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `RescueBoat` | `x`, `y`, `vx`, `vy`, `hull`, `fuel`, `kits`, `passengers`, `capacity`, `boost_heat`, `siren_t` | Player-controlled rescue boat with physics, resources, and ability cooldowns |
| `SupplyDock` | `x`, `y`, `w`, `h` | Stationary dock zone where fuel is refilled and kits restocked |
| `EvacCamp` | `x`, `y`, `w`, `h` | Stationary zone where passengers are unloaded for rescue credit |
| `BridgeSpan` | `x`, `y`, `w`, `h`, `integrity`, `stress`, `alarm_t`, `id` | Bridge segment with decaying integrity, stress from lightning, and alarm indicator |
| `CurrentCell` | `x`, `y`, `w`, `h`, `vx`, `vy`, `pulse` | One cell of the 4x3 water current grid with directional flow velocity |
| `FlowSample` | `vx`, `vy`, `turbulence` | Sampled water flow at a specific point including turbulence factor |
| `RaftGroup` | `active`, `x`, `y`, `vx`, `vy`, `survivors`, `panic`, `flare_t` | Group of survivors on a raft that drifts with current and accumulates panic |
| `Debris` | `active`, `x`, `y`, `vx`, `vy`, `size`, `hard`, `spin` | Floating debris that damages hull on collision |
| `LightningStrike` | `active`, `x`, `y`, `radius`, `telegraph`, `life`, `power`, `pulse` | Lightning strike with telegraph warning phase then damaging flash phase |
| `SupplyCrate` | `active`, `x`, `y`, `vx`, `vy`, `kind`, `amount`, `blink` | Floating supply (kind 0=kits, 1=fuel) that can be collected on contact |
| `RainDrop` | `active`, `x`, `y`, `vy`, `len`, `life`, `alpha` | Visual rain particle for atmosphere |
| `WakeParticle` | `active`, `x`, `y`, `vx`, `vy`, `life`, `size`, `kind` | Wake/splash particle from boat movement or collisions |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to [lo, hi] range |
| `minf` | `(Float, Float) -> Float` | Returns the minimum of two floats |
| `maxf` | `(Float, Float) -> Float` | Returns the maximum of two floats |
| `mini` | `(Int, Int) -> Int` | Returns the minimum of two integers |
| `maxi` | `(Int, Int) -> Int` | Returns the maximum of two integers |
| `absf` | `(Float) -> Float` | Returns the absolute value of a float |
| `sinf` | `(Float) -> Float` | Computes sine of a float via `@math.sin` |
| `randf` | `(Float, Float) -> Float` | Returns a random float in [lo, hi] range |
| `randi` | `(Int, Int) -> Int` | Returns a random integer in [lo, hi] range |
| `dist2` | `(Float, Float, Float, Float) -> Float` | Returns the squared distance between two 2D points |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Tests if a point is inside an integer-coordinate rectangle |
| `inside_rectf` | `(Float, Float, Float, Float, Float, Float) -> Bool` | Tests if a point is inside a float-coordinate rectangle |
| `point_in_circle` | `(Float, Float, Float, Float, Float) -> Bool` | Tests if a point is inside a circle |
| `pointer_on_rect` | `(Float, Float, Bool, Int, Int, Int, Int, Int) -> Bool` | Tests if mouse/touch pointer is pressing inside a rectangle |
| `pointer_on_circle` | `(Float, Float, Bool, Int, Float, Float, Float) -> Bool` | Tests if mouse/touch pointer is pressing inside a circle |
| `clear_rafts` | `(Array[RaftGroup]) -> Unit` | Deactivates and zeroes all raft group entries |
| `clear_debris` | `(Array[Debris]) -> Unit` | Deactivates and zeroes all debris entries |
| `clear_lightning` | `(Array[LightningStrike]) -> Unit` | Deactivates and zeroes all lightning strike entries |
| `clear_supplies` | `(Array[SupplyCrate]) -> Unit` | Deactivates and zeroes all supply crate entries |
| `clear_rain` | `(Array[RainDrop]) -> Unit` | Deactivates and zeroes all rain drop entries |
| `clear_wakes` | `(Array[WakeParticle]) -> Unit` | Deactivates and zeroes all wake particle entries |
| `init_currents` | `(Array[CurrentCell], Int, Int, Int, Int) -> Unit` | Initializes the 4x3 current grid with positions and flow velocities |
| `init_bridge` | `(Array[BridgeSpan], Int, Int, Int, Int) -> Unit` | Positions 5 bridge spans vertically across the map center with random initial integrity |
| `refill_rain` | `(Array[RainDrop], Float, Float, Float, Float) -> Unit` | Activates all rain drops with randomized positions and velocities |
| `find_flow` | `(Array[CurrentCell], Float, Float, Float) -> FlowSample` | Samples water flow at a given (x,y) position, modulated by storm intensity |
| `spawn_raft` | `(Array[RaftGroup], Float, Float, Float, Float, Int) -> Bool` | Activates one inactive raft with random lane placement and survivor count |
| `spawn_debris` | `(Array[Debris], Float, Float, Float, Float, Float) -> Bool` | Activates one inactive debris piece entering from the right |
| `spawn_lightning` | `(Array[LightningStrike], Float, Float, Float, Float, Float) -> Bool` | Activates one inactive lightning strike with telegraph timer |
| `spawn_supply` | `(Array[SupplyCrate], Float, Float, Float, Float) -> Bool` | Activates one inactive supply crate (randomly kits or fuel) |
| `spawn_wake` | `(Array[WakeParticle], Float, Float, Float, Float, Float, Int) -> Unit` | Emits a single wake particle at a position |
| `update_wakes` | `(Array[WakeParticle], Float) -> Unit` | Updates wake particle positions, applies drag, removes expired |
| `update_rain` | `(Array[RainDrop], Float, Float, Float, Float, Float, Float) -> Unit` | Updates rain drop positions, respawns expired drops at top |
| `calm_rafts` | `(Array[RaftGroup], Float, Float, Float, Float) -> Unit` | Reduces panic on rafts within siren radius |
| `nearest_span_index` | `(Array[BridgeSpan], Float, Float, Float) -> Int` | Finds the closest bridge span within a given radius, returns index or -1 |
| `min_bridge_integrity` | `(Array[BridgeSpan]) -> Float` | Returns the minimum integrity value across all bridge spans |
| `draw_river` | `(Int, Int, Int, Int, Float, Float) -> Unit` | Draws animated river background with wave stripes |
| `draw_current_grid` | `(Array[CurrentCell], Float) -> Unit` | Draws current cell outlines with flow direction arrows |
| `draw_spans` | `(Array[BridgeSpan], Float) -> Unit` | Draws bridge spans with health bars and warning indicators |
| `draw_rafts` | `(Array[RaftGroup], Float) -> Unit` | Draws active rafts with survivor counts and flare blinks |
| `draw_debris_field` | `(Array[Debris]) -> Unit` | Draws active debris as brown rectangles |
| `draw_strikes` | `(Array[LightningStrike], Float) -> Unit` | Draws lightning strikes (telegraph circles or flash effects) |
| `draw_supplies` | `(Array[SupplyCrate], Float) -> Unit` | Draws supply crates with type labels ("K" or "F") and glow |
| `draw_rain` | `(Array[RainDrop], Float) -> Unit` | Draws rain streaks with wind offset |
| `draw_wakes` | `(Array[WakeParticle]) -> Unit` | Draws active wake particles with alpha fade |
| `draw_boat` | `(RescueBoat, Float) -> Unit` | Draws the rescue boat with bobbing animation and boost glow |
| `draw_world_panels` | `(SupplyDock, EvacCamp, Float) -> Unit` | Draws dock and camp zones with labels and pulse indicators |
| `draw_hud_meter` | `(String, Float, Float, Int, Int, Int, Int, @raylib.Color) -> Unit` | Draws a labeled HUD bar with fill percentage |
| `draw_touch_controls` | `(Int, Int, Float, Float, Bool, Int) -> Unit` | Draws on-screen D-pad and circular action buttons |
| `draw_panel` | `(Int, Int, Int, Int, RescueBoat, Int, Int, Int, Int, Float, Float, Float, Int, String) -> Unit` | Draws the right-side info panel with all HUD meters, stats, and controls |
| `draw_menu` | `(Int, Int, Float) -> Unit` | Draws the title screen with animated background and start button |
| `draw_end_screen` | `(Int, Int, Bool, Int, Int, Float, Float, Int, Float) -> Unit` | Draws the end-game overlay with mission results |
| `main` | `() -> Unit` | Entry point: initializes window (1700x960), allocates all object pools, runs game loop |

## Architecture

### Package Structure

```
monsoon_bridge_rescue_2026/
├── main.mbt              — Complete game: structs, logic, rendering, entry point (~2577 lines)
└── moon.pkg              — Package config with raylib and math imports
```

This is a single-file game with a rich simulation. All 12 struct types, utility functions, spawn/update logic, and rendering routines reside in `main.mbt`. Game state is managed through local variables in the `main` function with a nested `reset_run` closure.

### Data Flow

1. **Input**: Mouse position, click/hold state, and touch count are read each frame. Keyboard input (WASD/arrows for movement, Space/J for boost, L/U for action, K/H for siren) is combined with touch D-pad and button hit testing via `pointer_on_rect`/`pointer_on_circle`.
2. **Physics**: The boat receives steering acceleration, current flow forces from `find_flow`, and drag. Velocity is clamped to max speed (280 normal, 400 boosted). Rafts, debris, and supplies also receive current forces and drift accordingly.
3. **Spawning**: Timers (`raft_spawn_cd`, `debris_spawn_cd`, `lightning_cd`, `supply_cd`) decrement each frame; when expired, the corresponding `spawn_*` function activates an object from its pre-allocated pool. Spawn rates tighten as storm intensity increases.
4. **Interactions**: Distance checks (squared distance via `dist2`) handle debris-boat collisions, raft pickup range, bridge repair range, supply collection, and lightning damage zones. The Action key triggers the first matching interaction: raft rescue, then bridge repair.
5. **Win/Loss**: Each frame checks hull <= 0, any bridge integrity <= 0, lost >= 190, or timer expired. Early completion is possible when rescue target and bridge goal are both met.
6. **Rendering**: Layered drawing order: river -> current grid -> dock/camp panels -> bridge spans -> supplies -> debris -> rafts -> wakes -> lightning -> boat -> rain -> siren ring -> HUD panel -> touch controls -> end overlay.

### Key Design Patterns

- **Object pools**: All entity types (36 rafts, 170 debris, 28 lightning, 26 supplies, 760 rain, 980 wakes) are pre-allocated arrays with `active` flags, avoiding runtime allocation.
- **Current grid simulation**: A 4x3 grid of `CurrentCell` objects provides spatially-varying water flow that affects all floating objects, creating a realistic river simulation.
- **Storm escalation**: Storm intensity ramps from 0.0 to 1.0 based on remaining time, modulating spawn rates, flow turbulence, debris speed, lightning power, and visual effects.
- **Telegraph mechanic**: Lightning strikes have a visible warning phase (`telegraph` timer) before the damaging flash, giving players time to react.
- **Nested reset closure**: `reset_run` captures all mutable state variables via closure, allowing clean game restart without re-initialization of the pool arrays.
- **Touch/keyboard dual input**: All actions check both keyboard state and on-screen button hit testing, merging results with logical OR for seamless input switching.

## Improvement & Refinement Plan

1. **Extract game state into a struct**: The `main` function uses 15+ mutable local variables (`state`, `timer`, `rescued_total`, etc.) captured by the `reset_run` closure. Grouping these into a `Game` struct would improve readability and make the reset function a method.
2. **Reduce `draw_panel` parameter count**: The function takes 14 parameters. Passing a reference to a `Game` struct or a dedicated `HudData` struct would simplify the signature significantly.
3. **Add bridge repair visual feedback**: When a bridge span is repaired, there is no particle effect -- only a text message. Adding a burst of green wake particles at the repair site would provide satisfying visual feedback.
4. **Balance raft panic decay near boat**: Currently the siren calms panic at 0.3/s bonus and proximity reduces at 0.13/s. Without any ability, panic grows faster than proximity calms, making the siren essentially mandatory. Increasing base proximity calming would improve balance.
5. **Use enum for game state and supply kind**: `state` uses raw integers (0=menu, 1=play, 2=win, 3=lose) and `SupplyCrate.kind` uses 0/1. Replacing these with enums would improve type safety and readability.
6. **Add minimap**: The play area is large (1220x912 pixels) and rafts spawn at the edges. A small minimap showing raft positions, bridge spans, and the boat would help with situational awareness.
7. **Implement fuel warning**: There is no visual or text warning when fuel is critically low. Adding a flashing HUD indicator when fuel drops below 15% would help players avoid the reduced-acceleration penalty.
