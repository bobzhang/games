# Core 2D Camera Platformer

This example demonstrates five different 2D camera follow strategies in the context of a simple platformer. When you run it, a red player rectangle can move and jump across platforms while the camera follows using a selectable algorithm. You can cycle through the camera modes to compare their behaviors.

## Build and Run

```bash
moon build --target native core_2d_camera_platformer/
./_build/native/debug/build/core_2d_camera_platformer/core_2d_camera_platformer.exe
```

## Controls

- **Left/Right Arrow Keys** -- Move player horizontally
- **Space** -- Jump (when on a platform)
- **Mouse Wheel** -- Zoom in/out (clamped 0.25 to 3.0)
- **C** -- Cycle through the five camera modes
- **R** -- Reset player position and zoom

## What It Demonstrates

- **Five camera follow algorithms**:
  1. **Center** -- Camera target always equals the player position (simplest).
  2. **Center inside map** -- Same as center, but the camera offset is clamped so the view never scrolls past the map boundaries using `get_world_to_screen_2d`.
  3. **Smooth follow** -- Camera target smoothly interpolates toward the player using a speed proportional to distance, with a minimum speed threshold.
  4. **Even out on landing** -- Camera follows horizontally but only updates vertically with a smooth transition when the player lands on a platform.
  5. **Player bounds push** -- Camera only moves when the player approaches the edges of a bounding box region on screen, using `get_screen_to_world_2d` to define the push boundaries.
- **`@raylib.get_world_to_screen_2d`** and **`@raylib.get_screen_to_world_2d`** -- Coordinate conversions used for map boundary clamping and bounding box calculations.
- **Simple platformer physics** -- Gravity, jump speed, horizontal movement, and collision detection against blocking rectangles.
- **MoonBit struct: `EnvItem`** -- A custom struct with `rect`, `blocking`, and `color` fields to define environment platforms.
- **Functional camera updaters** -- Each camera mode is implemented as a pure function that takes the current camera state and player position and returns a new `Camera2D`.

## Public API Reference

### Package `core_2d_camera_platformer`

> Single-package example.

The following are defined at module level but are not marked `pub`:

- `let gravity : Float` -- Gravity constant (400.0).
- `let player_jump_spd : Float` -- Jump speed (350.0).
- `let player_hor_spd : Float` -- Horizontal movement speed (200.0).
- `struct EnvItem` -- Platform definition with `rect`, `blocking`, and `color`.
- `fn update_player(...)` -- Updates player position and physics.
- `fn update_camera_center(...)` -- Simple center-follow camera.
- `fn update_camera_center_inside_map(...)` -- Center-follow with map boundary clamping.
- `fn update_camera_center_smooth_follow(...)` -- Smooth interpolation follow.
- `fn update_camera_even_out_on_landing(...)` -- Horizontal follow with vertical landing smoothing.
- `fn update_camera_player_bounds_push(...)` -- Camera moves only when player pushes screen edges.

## Architecture

1. **Initialization** -- Window is created, player state and 5 environment items (background, ground, 3 platforms) are defined, camera is set up centered on the player.
2. **Main loop** -- Each frame updates player physics (movement, gravity, platform collision), adjusts zoom, handles mode switching (C key) and reset (R key), calls the selected camera updater function, then draws the environment items, player, and HUD text showing controls and the current camera mode description.
3. **Cleanup** -- Window is closed.

## Key Takeaways

- Different camera follow strategies produce dramatically different player experiences; center-follow is simplest but can feel rigid, while smooth-follow and bounds-push create more polished gameplay feel.
- Implementing camera modes as pure functions that return new `Camera2D` values is a clean functional pattern in MoonBit, avoiding mutable camera state.
- The `get_screen_to_world_2d` and `get_world_to_screen_2d` functions are essential tools for camera algorithms that need to reason about screen-space boundaries in world coordinates.
