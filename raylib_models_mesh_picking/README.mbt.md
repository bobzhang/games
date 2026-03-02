# Models Mesh Picking

This example demonstrates comprehensive ray casting and collision detection against multiple 3D object types using raylib in MoonBit. When you run it, you see a turret model, a triangle, a sphere, and a ground plane; moving the mouse casts a ray that highlights the closest hit object with a colored marker showing the collision point, normal, and distance.

## Build and Run

```bash
moon build --target native raylib_models_mesh_picking/
./_build/native/debug/build/raylib_models_mesh_picking/raylib_models_mesh_picking.exe
```

## Controls

- **Mouse**: Aim the ray (first-person camera when cursor is hidden)
- **Right click**: Toggle camera controls on/off (show/hide cursor)

## What It Demonstrates

- **Ray casting from screen**: Uses `@raylib.get_screen_to_world_ray` with the mouse position and camera to generate a 3D ray from the camera through the mouse cursor.
- **Multiple collision primitives**: Tests the ray against five different object types:
  - `@raylib.get_ray_collision_quad` -- ray vs ground quad (4 vertices)
  - `@raylib.get_ray_collision_triangle` -- ray vs triangle (3 vertices)
  - `@raylib.get_ray_collision_sphere` -- ray vs sphere (center + radius)
  - `@raylib.get_ray_collision_box` -- ray vs bounding box (AABB)
  - `@raylib.get_ray_collision_mesh` -- ray vs mesh triangles (precise picking)
- **Closest-hit selection**: Compares collision distances across all tests, selecting the closest hit and assigning a different cursor color per object type (green=ground, purple=triangle, orange=sphere/mesh).
- **Two-pass mesh collision**: First tests against the model's bounding box as a cheap broad-phase check, then if the box is hit, tests against actual mesh triangles for precise picking.
- **Barycentric coordinates**: Computes barycentric coordinates with `@raylib.Vector3::barycenter` when the triangle is hit, displaying them in the debug HUD.
- **Collision visualization**: Draws a colored cube at the hit point, a red line showing the surface normal direction, and the full ray with `draw_ray`.

## Public API Reference

### Package `raylib_models_mesh_picking`

> Single-package example.

The following internal helpers are defined:

- `let flt_max : Float` -- Maximum float value used as initial "no hit" distance.
- `fn format_float(v : Float) -> String` -- Formats a float to 2 decimal places for debug display.

## Architecture

The program loads a turret OBJ model with texture, defines a ground quad (4 corners), a test triangle, and a test sphere. Each frame, the camera updates in first-person mode (when cursor is hidden), a ray is cast from the mouse position, and collision tests run against all objects in sequence. Each test compares its hit distance against the current closest hit; the closest wins. For the bounding box hit, a second pass tests individual mesh triangles with `get_ray_collision_mesh`. The 3D scene draws the turret, triangle wireframe, sphere wireframe, optional bounding box highlight, hit point marker with normal line, and the full ray. Debug HUD text shows the hit object name, distance, position, normal, and barycentric coordinates.

## Key Takeaways

- Use a two-pass approach for mesh picking: first test against the bounding box (cheap), then only test mesh triangles if the box is hit (expensive but precise).
- `@raylib.RayCollision` provides hit status, distance, point, and normal -- comparing distances across multiple collision tests yields the closest visible object.
- `get_ray_collision_mesh` requires the model's transform matrix to correctly test against meshes that are not at the origin, obtained via `get_model_transform`.
