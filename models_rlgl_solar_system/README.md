# Models: rlgl Solar System

This example demonstrates the use of the low-level rlgl API for hierarchical matrix transformations, rendering a simplified solar system with a sun, earth, and moon. When you run it, you see a gold sun at the center, a blue earth orbiting around it, and a gray moon orbiting the earth, all with independent rotation speeds. The camera orbits automatically using the orbital camera mode.

## Build and Run

```bash
moon build --target native models_rlgl_solar_system/
./_build/native/debug/build/models_rlgl_solar_system/models_rlgl_solar_system.exe
```

## Controls

- **Mouse** -- Orbital camera rotation and zoom (automatic via `CameraOrbital`)

## What It Demonstrates

- **rlgl push/pop matrix stack**: Uses `@rl.push_matrix()` and `@rl.pop_matrix()` to create a hierarchical transformation chain where the moon's orbit is relative to the earth, which in turn orbits the sun. This mirrors how OpenGL's legacy matrix stack works.
- **rlgl transformation functions**: Calls `@rl.scalef`, `@rl.rotatef`, and `@rl.translatef` to apply scale, rotation, and translation to the current matrix, demonstrating how transformation order matters (rotate orbit first, then translate to orbital radius, then rotate/scale for the body itself).
- **Custom sphere rendering with rlgl**: The `draw_sphere_basic` function manually constructs a sphere using `@rl.begin(@rl.Triangles)`, computing vertex positions with spherical coordinate trigonometry and submitting them via `@rl.vertex3f`.
- **Render batch management**: Calls `@rl.check_render_batch_limit` before submitting a large number of vertices to ensure the internal render batch buffer has enough space.

## Public API Reference

### Package `models_rlgl_solar_system`

> Single-package example.

No public API -- self-contained main function. The helper function `draw_sphere_basic` and constant `deg2rad` are package-level but not exported.

## Architecture

The program initializes a window and an orbital camera. Four mutable rotation angles track the earth's self-rotation, earth's orbital rotation, moon's self-rotation, and moon's orbital rotation. Each frame, these angles are incremented at different rates. The draw phase uses nested `push_matrix`/`pop_matrix` calls to build the transformation hierarchy: the sun is scaled at the origin, the earth is rotated around the sun and then translated outward before being scaled, and the moon is further rotated and translated relative to the earth. A red circle drawn with `draw_circle_3d` shows the earth's orbital path. On exit, `close_window` cleans up.

## Key Takeaways

- The rlgl push/pop matrix stack enables hierarchical transformations where child objects automatically inherit parent transformations, which is ideal for solar system or skeletal animation scenarios.
- Transformation order is critical: for orbital motion, you must rotate first (to set the orbit angle), then translate (to move to the orbital radius), before applying the body's own rotation and scale.
- Building geometry manually with `@rl.begin`/`@rl.vertex3f`/`@rl.end_` gives full control over mesh construction when raylib's built-in shapes are insufficient.
