# Models: Orthographic Projection

This example demonstrates how to switch between perspective and orthographic camera projections in raylib. When you run it, you see a 3D scene containing cubes, spheres, and cylinders of various sizes and colors rendered on a grid. Pressing the spacebar toggles between perspective (with depth foreshortening) and orthographic (parallel projection with no foreshortening) views, with a label indicating the current mode.

## Build and Run

```bash
moon build --target native models_orthographic_projection/
./_build/native/debug/build/models_orthographic_projection/models_orthographic_projection.exe
```

## Controls

- **Spacebar** -- Toggle between perspective and orthographic camera projection

## What It Demonstrates

- **Camera projection switching**: Uses `@raylib.Camera3D::new` with either `@raylib.CameraPerspective` or `@raylib.CameraOrthographic` to dynamically change the camera projection type at runtime. The `fovy` field serves as field-of-view in perspective mode and as the viewable width in orthographic mode.
- **3D primitive drawing**: Calls `draw_cube`, `draw_cube_wires`, `draw_sphere`, `draw_sphere_wires`, `draw_cylinder`, and `draw_cylinder_wires` to render a variety of geometric shapes with different colors, positions, and sizes.
- **Scene composition**: Uses `begin_mode_3d`/`end_mode_3d` to set up the 3D rendering context, `draw_grid` for a reference grid, and 2D overlay text via `draw_text` for the current projection label and key hint.

## Public API Reference

### Package `models_orthographic_projection`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes an 800x450 window and creates a `Camera3D` starting in perspective mode. Each frame, it checks for a spacebar press and reconstructs the camera with the alternate projection type, swapping between `fovy_perspective` (45.0) and `width_orthographic` (10.0). The draw phase renders several 3D primitives in `begin_mode_3d`/`end_mode_3d`, draws a grid, then overlays 2D text showing the current projection mode. On exit, `close_window` cleans up resources.

## Key Takeaways

- In raylib, switching between perspective and orthographic projection is as simple as changing the camera's `projection` field and adjusting the `fovy` parameter, which has different semantics in each mode.
- MoonBit's immutable-by-default struct design means the camera must be reassigned (via `let mut camera`) each time projection parameters change.
- Combining solid and wireframe primitive draws (e.g., `draw_cube` + `draw_cube_wires`) is an effective way to visualize 3D shapes with visible edges.
