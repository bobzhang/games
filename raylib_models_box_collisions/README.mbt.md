# Models Box Collisions

This example demonstrates 3D collision detection between axis-aligned bounding boxes (AABB) and between a box and a sphere using raylib in MoonBit. When you run it, you see a green player cube that turns red when colliding with either a gray enemy box or a gray enemy sphere, viewed from a fixed overhead camera.

## Build and Run

```bash
moon build --target native raylib_models_box_collisions/
./_build/native/debug/build/raylib_models_box_collisions/raylib_models_box_collisions.exe
```

## Controls

- **Arrow keys**: Move the player cube (Left/Right on X axis, Up/Down on Z axis)

## What It Demonstrates

- **AABB-AABB collision**: Constructs `BoundingBox` objects from position and size, then tests for overlap using `@raylib.check_collision_boxes`.
- **AABB-Sphere collision**: Tests the player's bounding box against a sphere (center point + radius) using `@raylib.check_collision_box_sphere`.
- **BoundingBox construction**: Manually builds `@raylib.BoundingBox` by computing min/max corners from a center position and half-extents.
- **Visual collision feedback**: Changes the player cube's color from green to red when any collision is detected.
- **3D shape rendering**: Uses `draw_cube`, `draw_cube_wires`, `draw_cube_v`, `draw_sphere`, and `draw_sphere_wires` to render the scene objects with both solid and wireframe representations.

## Public API Reference

### Package `raylib_models_box_collisions`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes a fixed perspective camera at position (0, 10, 10) looking at the origin. A player cube, enemy box, and enemy sphere are defined with positions and sizes. Each frame, arrow key input moves the player position by 0.2 units, a `BoundingBox` is constructed for both the player and enemy box from their center positions and half-extents, collisions are tested (box-box and box-sphere), and the player color is set to red or green accordingly. The 3D scene renders all objects with solid fills and wireframe outlines on a grid.

## Key Takeaways

- `@raylib.check_collision_boxes` and `@raylib.check_collision_box_sphere` provide simple, efficient collision detection for 3D axis-aligned volumes.
- `BoundingBox` is constructed from min and max corner points, which must be computed from center position and half-extents when working with centered objects.
- Changing object color based on collision state is a straightforward way to provide visual feedback for debugging or gameplay.
