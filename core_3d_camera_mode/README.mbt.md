# Core 3D Camera Mode

This is the simplest 3D example -- it sets up a static perspective camera and renders a cube with wireframe and a grid. When you run it, you see a red cube viewed from above at an angle with no interactive camera controls, just an FPS counter and a welcome message.

## Build and Run

```bash
moon build --target native core_3d_camera_mode/
./_build/native/debug/build/core_3d_camera_mode/core_3d_camera_mode.exe
```

## Controls

No interactive controls -- the camera is static.

## What It Demonstrates

- **`@raylib.Camera3D::new`** -- Minimal setup of a 3D perspective camera with position (0, 10, 10), target at origin, up vector (0, 1, 0), 45-degree FOV, and perspective projection.
- **`@raylib.begin_mode_3d`** and **`@raylib.end_mode_3d`** -- The essential bracket for drawing 3D content with a camera. Everything between these calls is rendered in 3D perspective.
- **`@raylib.draw_cube`** and **`@raylib.draw_cube_wires`** -- Drawing a solid cube with a wireframe overlay, which is the most basic 3D primitive rendering.
- **`@raylib.draw_grid`** -- Drawing a reference grid (10 divisions, 1.0 spacing) on the XZ plane.
- **`@raylib.draw_fps`** -- Displaying the current frame rate in the top-left corner.

## Public API Reference

### Package `core_3d_camera_mode`

> Single-package example.

No public API -- self-contained main function.

## Architecture

1. **Initialization** -- Window is created with a static Camera3D and a cube position at the origin. FPS is set to 60.
2. **Main loop** -- Each frame simply draws the 3D scene (cube, wireframe, grid) and screen-space text (welcome message, FPS). No update logic is needed since nothing moves.
3. **Cleanup** -- Window is closed.

## Key Takeaways

- A minimal 3D scene in raylib requires only a `Camera3D` and the `begin_mode_3d`/`end_mode_3d` bracket -- there is no complex setup needed.
- The `draw_cube` + `draw_cube_wires` combination is a common pattern that makes 3D shapes more visually distinct by adding edge definition.
- This example serves as the "hello world" of 3D rendering in MoonBit with raylib.
