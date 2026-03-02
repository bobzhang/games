# Core 3D Camera Free

This example demonstrates the free-mode 3D camera with mouse-driven orbit, pan, and zoom controls. When you run it, you see a red cube with wireframe and a grid, viewed from an elevated angle. The mouse controls camera movement, and pressing Z resets the camera target to the origin.

## Build and Run

```bash
moon build --target native raylib_core_3d_camera_free/
./_build/native/debug/build/raylib_core_3d_camera_free/raylib_core_3d_camera_free.exe
```

## Controls

- **Mouse Movement** -- Orbit around the target
- **Mouse Wheel** -- Zoom in/out
- **Mouse Wheel Press (Middle Button)** -- Pan the camera
- **Z** -- Reset camera target to origin (0, 0, 0)

## What It Demonstrates

- **`@raylib.Camera3D::new`** -- Setting up a perspective camera positioned at (10, 10, 10) looking at the origin.
- **`@raylib.update_camera(camera, CameraFree)`** -- Using raylib's built-in free camera mode, which provides orbit, pan, and zoom controls via mouse input.
- **`@raylib.disable_cursor`** -- Capturing the mouse for relative movement, enabling smooth camera control without cursor constraints.
- **`@raylib.begin_mode_3d`** and **`@raylib.end_mode_3d`** -- Bracketing 3D rendering with the camera transform.
- **3D primitives** -- `draw_cube` for a solid red cube, `draw_cube_wires` for a maroon wireframe overlay, and `draw_grid` for a reference grid on the ground plane.
- **Camera target reset** -- Pressing Z resets only the target (look-at point) while preserving the camera position, up vector, FOV, and projection.

## Public API Reference

### Package `raylib_core_3d_camera_free`

> Single-package example.

No public API -- self-contained main function.

## Architecture

1. **Initialization** -- Window is created, a Camera3D is set at (10, 10, 10) looking at the origin with 45-degree FOV and perspective projection. The cursor is disabled.
2. **Main loop** -- Each frame updates the camera with `update_camera` in free mode, checks for Z key to reset the target, then draws the 3D scene (cube, wireframe, grid) and a screen-space help panel.
3. **Cleanup** -- Window is closed.

## Key Takeaways

- The free camera mode in raylib provides a complete orbit/pan/zoom camera with minimal code -- just call `update_camera` with `CameraFree` each frame.
- `disable_cursor` is important for free camera mode to allow continuous mouse movement without hitting screen edges.
- Resetting the camera target while keeping the position unchanged is useful for quickly re-centering the view on a specific point.
