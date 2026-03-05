# Portal Billiards 2026

A billiards game with a twist -- four moving portals on the table teleport balls that pass through them. Clear all target balls using limited shots across three increasingly difficult levels.

## Build and Run

```bash
cd examples && moon build --target native portal_billiards_2026/
cd examples && ./_build/native/debug/build/portal_billiards_2026/portal_billiards_2026.exe
```

## Controls

- **Mouse**: Aim the cue ball (move cursor over the table)
- **W/S or Up/Down Arrow Keys**: Adjust shot power
- **Space / J**: Shoot the cue ball
- **R**: Restart from level 1
- **Mouse / Touch**: On-screen POW+/POW- buttons and SHOOT button

## How to Play

Aim and shoot the white cue ball to pocket the colored target balls into the six corner and side pockets. Two pairs of portals drift across the table -- balls entering one portal exit from its partner with slightly increased speed. Each level gives you a limited number of shots; pocketing the cue ball (scratch) costs one shot and respawns it. Clear all targets to advance. Unused shots carry bonus points. Complete all three levels to become the Table Master.

## Public API Reference

### Package `portal_billiards_2026`

> Main entry point.

The `main` function initializes the window, creates the ball pool, and runs the frame loop calling physics update, portal teleportation, collision resolution, pocket detection, and drawing functions.

#### Types

| Type | Description |
|------|-------------|
| `Ball` | A billiard ball with mutable `x`, `y`, velocity `vx`/`vy`, `active` flag, identity `id`, and `portal_cd` cooldown preventing immediate re-teleportation. |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `absf` | `(Float) -> Float` | Returns the absolute value of a float. |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float to the inclusive `[lo, hi]` range. |
| `inside_rect` | `(Float, Float, Int, Int, Int, Int) -> Bool` | Returns true if a point lies within an axis-aligned rectangle. |
| `sinf` | `(Float) -> Float` | Computes `sin(x)` as Float via the math module. |
| `cosf` | `(Float) -> Float` | Computes `cos(x)` as Float via the math module. |
| `set_ball` | `(Array[Ball], Int, Float, Float, Bool, Int) -> Unit` | Writes a ball entry at index `i` with given position and id; velocities reset to zero. |
| `clear_balls` | `(Array[Ball]) -> Unit` | Deactivates all balls in the pool. |
| `cue_spawn_x` | `() -> Float` | Returns the X coordinate where the cue ball spawns. |
| `cue_spawn_y` | `() -> Float` | Returns the Y coordinate where the cue ball spawns. |
| `reset_level` | `(Int, Array[Ball]) -> Int` | Places cue ball and a triangle rack of target balls for the given level; returns shot allowance. |
| `all_targets_cleared` | `(Array[Ball]) -> Bool` | Returns true when all non-cue balls have been pocketed. |
| `moving_any` | `(Array[Ball]) -> Bool` | Returns true if any active ball has speed² above 64. |
| `pocket_x` | `(Int) -> Float` | Returns the X pixel coordinate of one of the six pockets. |
| `pocket_y` | `(Int) -> Float` | Returns the Y pixel coordinate of one of the six pockets. |
| `ball_in_pocket` | `(Float, Float) -> Bool` | Returns true if a position overlaps any pocket within its 24-pixel capture radius. |
| `goal_top` | `() -> Float` | Returns the top Y of the left-wall goal opening. |
| `goal_bottom` | `() -> Float` | Returns the bottom Y of the left-wall goal opening. |
| `goal_opening` | `(Float) -> Bool` | Returns true if Y falls within the left-wall opening (ball passes through). |
| `portal_pair` | `(Int) -> Int` | Returns the partner portal index (0↔1 and 2↔3). |
| `portal_pos` | `(Float, Int) -> (Float, Float)` | Returns the current pixel position of portal `idx` using sinusoidal drift. |
| `nearest_portal_idx` | `(Float, Float, Float) -> Int` | Returns the index of the portal containing point `(x, y)`, or -1. |
| `color_for_id` | `(Int) -> @raylib.Color` | Returns the render color for a ball by id (0=white cue, 1–5 cycling colors). |
| `main` | `() -> Unit` | Entry point: initializes window, creates game state, runs frame loop. |

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sw` | `Int` | `1280` | Screen width in pixels. |
| `sh` | `Int` | `820` | Screen height in pixels. |
| `table_x` | `Int` | `90` | Left edge of the billiard table. |
| `table_y` | `Int` | `120` | Top edge of the billiard table. |
| `table_w` | `Int` | `1100` | Width of the billiard table. |
| `table_h` | `Int` | `620` | Height of the billiard table. |
| `ball_r` | `Float` | `15.0` | Ball radius in pixels. |
| `portal_r` | `Float` | `30.0` | Portal capture radius in pixels. |
| `max_balls` | `Int` | `12` | Maximum balls in the simulation pool. |

## Architecture

All game logic is in `main.mbt`. Key design patterns:

- **Physics model**: Each ball stores float `(x, y)` position and `(vx, vy)` velocity. Per frame, position is integrated, friction is applied as a multiplicative factor (`1 - dt * 0.84`), and velocities below 6.0 are zeroed to stop drifting. Wall bounces reflect the appropriate velocity component with 94% elasticity.
- **Portal teleportation**: Four portals drift on sinusoidal paths driven by a global `portal_t` timer. When a ball's center enters a portal's radius and its `portal_cd` is zero, it is ejected from the paired portal in its current direction of travel with a 5% speed boost, and `portal_cd` is set to 0.45 s to prevent immediate re-entry.
- **Elastic ball collisions**: Balls are checked pairwise each frame. Overlapping balls are separated by half the penetration depth each, and the relative normal velocity component is exchanged with 98% restitution.
- **Goal opening**: A 220-pixel-tall gap in the left wall allows balls to escape or pass through without bouncing.
- **State machine**: Three boolean flags (`over`, `won`) plus `shots_left` and `level` drive level progression. The game advances through levels 1–3 when all targets are cleared, awarding bonus points for unused shots, then sets `over = true` and `won = true` on completion.
- **Delta-time updates**: All physics, portal drift, and power adjustments are scaled by `dt` (capped at 0.05 s) for frame-rate independence.

## Improvement & Refinement Plan

1. **Diagonal aiming line**: Extend the cue aim line to show where the cue ball will first contact a target or cushion using a simple ray-march against ball and wall geometry.
2. **Audio feedback**: Add sound effects for ball-pocket entry, ball-ball collisions, and portal teleportation using `@raylib.play_sound`.
3. **Portal visual entry flash**: When a ball teleports, emit a brief ring flash at both the entry and exit portals to make the transition easier to follow.
4. **Persistent high score**: Save the best score across sessions using a file-based approach so the player can track their personal record.
5. **Ghost ball for aim**: Show a semi-transparent ghost of the cue ball at the predicted first contact point to help players plan bank shots.
6. **Variable portal sizes per level**: Make portal radii grow slightly each level to increase the frequency and excitement of teleportation events.
7. **Scratch penalty feedback**: Display a brief animation or color flash on the cue ball when it is pocketed (scratch) to make the penalty visually clear.
