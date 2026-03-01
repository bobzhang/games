# Core 3D Picking

This example demonstrates mouse-based 3D object picking using ray-box collision detection. When you run it, you see a gray cube on a grid. Clicking on the cube selects it (turning it red with a green highlight), and clicking again deselects it. The picking ray is visualized in 3D space.

## Build and Run

```bash
moon build --target native raylib_core_3d_picking/
./_build/native/debug/build/raylib_core_3d_picking/raylib_core_3d_picking.exe
```

## Controls

- **Left Click** -- Cast a ray and select/deselect the cube
- **Right Click** -- Toggle camera controls (enables/disables first-person camera mode)
- **Mouse** -- Look around (when camera controls are active)

## What It Demonstrates

- **`@raylib.get_screen_to_world_ray`** -- Converting a 2D mouse screen position into a 3D ray through the camera, which is the foundation of 3D picking.
- **`@raylib.BoundingBox::new`** -- Constructing an axis-aligned bounding box (AABB) from the cube's position and size for collision testing.
- **`@raylib.get_ray_collision_box`** -- Testing whether a ray intersects an AABB, returning a result that includes a `hit` boolean.
- **`@raylib.draw_ray`** -- Visualizing the picking ray in 3D space for debugging and demonstration purposes.
- **`@raylib.enable_cursor`** / **`@raylib.disable_cursor`** -- Toggling between free cursor (for clicking) and captured cursor (for camera look-around).
- **`@raylib.is_cursor_hidden`** -- Checking cursor state to determine whether camera updates should be applied.
- **`@raylib.update_camera(camera, CameraFirstPerson)`** -- Using first-person camera mode for look-around when cursor is captured.
- **Visual feedback** -- The cube changes color (gray to red) and gains an enlarged green wireframe when selected.

## Public API Reference

### Package `raylib_core_3d_picking`

> Single-package example.

No public API -- self-contained main function.

## Architecture

1. **Initialization** -- Window is created, a Camera3D is set up at (10, 10, 10) looking at the origin, and the cube position, size, ray, and collision state are initialized.
2. **Main loop** -- Each frame updates the camera (only when cursor is hidden), handles right-click to toggle cursor capture, and handles left-click to perform ray casting: converts mouse position to a 3D ray, constructs a bounding box from the cube, tests for intersection, and toggles the collision state. The 3D scene draws the cube (colored based on selection state), the ray, and the grid. Screen-space text shows instructions and selection status.
3. **Cleanup** -- Window is closed.

## Key Takeaways

- 3D picking in raylib follows a straightforward pipeline: convert screen position to a ray with `get_screen_to_world_ray`, define a bounding volume, and test intersection with `get_ray_collision_box`.
- The cursor toggle pattern (right-click to switch between camera control and object interaction) is a common UX approach for 3D applications that need both modes.
- Bounding box construction from a center position and size requires computing min/max corners as `position - size/2` and `position + size/2`.
