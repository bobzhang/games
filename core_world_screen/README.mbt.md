# Core World to Screen Coordinates

This example demonstrates how to convert 3D world-space coordinates to 2D screen-space coordinates using raylib's `get_world_to_screen` function. When you run it, you see a red cube in a 3D scene with a third-person camera, and a "Enemy: 100 / 100" text label that always floats above the cube regardless of the camera angle.

## Build and Run

```bash
moon build --target native core_world_screen/
./_build/native/debug/build/core_world_screen/core_world_screen.exe
```

## Controls

- **Mouse**: Rotate the third-person camera around the cube
- **Mouse wheel**: Zoom in/out

## What It Demonstrates

- **World-to-screen projection**: Uses `@raylib.get_world_to_screen` to project a 3D position (offset slightly above the cube) into 2D screen coordinates, enabling HUD-style labels that track 3D objects.
- **3D camera system**: Sets up a `Camera3D` in perspective mode with `@raylib.CameraThirdPerson` and updates it each frame via `@raylib.update_camera`.
- **Mixed 2D/3D rendering**: Draws 3D content (cube, wireframe, grid) inside `begin_mode_3d`/`end_mode_3d`, then draws 2D text overlays using the projected screen coordinates outside the 3D mode block.
- **Text measurement**: Uses `@raylib.measure_text` to center the label text horizontally above the cube.

## Public API Reference

### Package `core_world_screen`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes a window and a perspective camera looking at the origin. Each frame, the camera is updated for third-person orbital movement, then `get_world_to_screen` converts the cube's position (with a Y offset of 2.5) to screen coordinates. The 3D scene (cube, wireframe, grid) is rendered inside a 3D mode block, followed by 2D text drawn at the projected screen position. The window is closed on exit.

## Key Takeaways

- `@raylib.get_world_to_screen` is essential for creating floating labels, health bars, or name tags that follow 3D objects in screen space.
- Always draw 2D overlays outside the `begin_mode_3d`/`end_mode_3d` block to ensure they render in screen space rather than world space.
- `@raylib.measure_text` helps center text labels precisely over projected positions.
