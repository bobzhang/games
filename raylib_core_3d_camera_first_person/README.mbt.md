# Core 3D Camera First Person

This example demonstrates raylib's 3D camera system with multiple camera modes and switchable projection types. When you run it, you are placed in a 3D arena with colored columns, walls, and a ground plane. You can switch between free, first-person, third-person, and orbital camera modes, and toggle between perspective and orthographic projection.

## Build and Run

```bash
moon build --target native raylib_core_3d_camera_first_person/
./_build/native/debug/build/raylib_core_3d_camera_first_person/raylib_core_3d_camera_first_person.exe
```

## Controls

- **W/A/S/D/Space/Left-Ctrl** -- Move the camera
- **Arrow Keys or Mouse** -- Look around
- **1** -- Free camera mode
- **2** -- First-person camera mode
- **3** -- Third-person camera mode
- **4** -- Orbital camera mode
- **P** -- Toggle perspective/orthographic projection
- **Num +/- or Mouse Scroll** -- Zoom

## What It Demonstrates

- **`@raylib.Camera3D::new`** -- Creating a 3D camera with position, target, up vector, field-of-view, and projection type.
- **`@raylib.update_camera`** -- Using raylib's built-in camera update function with different camera modes (`CameraFree`, `CameraFirstPerson`, `CameraThirdPerson`, `CameraOrbital`).
- **`@raylib.CameraPerspective`** and **`@raylib.CameraOrthographic`** -- Switching between projection types at runtime, with appropriate FOV/position adjustments.
- **`@raylib.disable_cursor`** -- Capturing the mouse cursor for relative movement, essential for first-person camera control.
- **`@raylib.begin_mode_3d`** and **`@raylib.end_mode_3d`** -- Bracketing 3D drawing calls with the camera transform.
- **3D primitives** -- `draw_plane`, `draw_cube`, `draw_cube_wires` for ground, walls, columns, and the player cube (visible in third-person mode).
- **Procedural column generation** -- 20 columns with random heights, positions, and colors placed in the arena.
- **HUD overlay** -- Camera controls and status information (mode, projection, position, target, up vector) drawn in screen space after `end_mode_3d`.

## Public API Reference

### Package `raylib_core_3d_camera_first_person`

> Single-package example.

No public API -- self-contained main function.

## Architecture

1. **Initialization** -- Window is created, a Camera3D is configured in first-person mode, 20 random columns are generated, and the cursor is disabled for mouse-look.
2. **Main loop** -- Each frame handles camera mode switching (keys 1-4), projection toggling (P), updates the camera via `update_camera`, then draws the 3D scene (ground, walls, columns, optional player cube) and screen-space HUD with camera status.
3. **Cleanup** -- Window is closed.

## Key Takeaways

- Raylib's `update_camera` function provides built-in implementations of common 3D camera behaviors (free, first-person, third-person, orbital) that handle movement, rotation, and zoom automatically.
- Switching between perspective and orthographic projection at runtime requires adjusting the camera position and FOV to maintain a reasonable view.
- In third-person mode, `camera.target` represents the player position, so a player cube can be drawn at that location.
