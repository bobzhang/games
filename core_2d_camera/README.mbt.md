# Core 2D Camera

This example demonstrates raylib's 2D camera system with a scrolling cityscape. When you run it, you see a red player rectangle moving among randomly generated buildings with a ground plane. The camera follows the player and supports rotation, zoom, and reset.

## Build and Run

```bash
moon build --target native core_2d_camera/
./_build/native/debug/build/core_2d_camera/core_2d_camera.exe
```

## Controls

- **Right/Left Arrow Keys** -- Move the player horizontally
- **Mouse Wheel** -- Zoom in/out (clamped 0.1 to 3.0)
- **A / S** -- Rotate camera left/right (clamped -40 to 40 degrees)
- **R** -- Reset zoom and rotation to defaults

## What It Demonstrates

- **`@raylib.Camera2D::new`** -- Creating a 2D camera with offset (screen center), target (player position), rotation, and zoom.
- **`@raylib.begin_mode_2d`** and **`@raylib.end_mode_2d`** -- Bracketing world-space drawing with the camera transform. Everything drawn between these calls is transformed by the camera.
- **Camera target tracking** -- The camera target follows the player position each frame, keeping the player centered on screen.
- **Camera rotation and zoom** -- Rotation is adjusted with A/S keys and clamped to a range; zoom is adjusted with the mouse wheel and clamped to prevent extreme values.
- **Procedural building generation** -- 100 buildings are generated at startup with random widths, heights, and colors, placed along a horizontal strip starting at x=-6000.
- **Screen-space vs. world-space drawing** -- The info panel, screen border, and labels are drawn after `end_mode_2d`, so they remain fixed on screen regardless of camera movement.
- **Crosshair visualization** -- Green crosshair lines are drawn at the camera target position in world space.

## Public API Reference

### Package `core_2d_camera`

> Single-package example.

No public API -- self-contained main function.

## Architecture

1. **Initialization** -- Window is created, 100 buildings are procedurally generated with random dimensions and colors along a horizontal strip. The camera is set up with its offset at screen center and target at the player position.
2. **Main loop** -- Each frame processes player movement (Left/Right keys), updates camera target, rotation (A/S), and zoom (mouse wheel), then draws the scene in two phases: world-space content (ground, buildings, player, crosshair) within `begin_mode_2d`/`end_mode_2d`, and screen-space UI (labels, borders, info box) drawn after.
3. **Cleanup** -- Window is closed.

## Key Takeaways

- The `Camera2D` offset defines where the camera's target point appears on screen (typically screen center), while target defines which world-space point the camera is looking at.
- Content drawn between `begin_mode_2d` and `end_mode_2d` is in world coordinates transformed by the camera; content drawn outside is in screen coordinates, which is the standard pattern for HUD/UI elements.
- Since `Camera2D` is immutable in MoonBit, camera updates require reconstructing the struct with `Camera2D::new` each frame.
