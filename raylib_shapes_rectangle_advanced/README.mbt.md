# Rectangle Advanced

This example demonstrates drawing rounded rectangles with horizontal color gradients using low-level rlgl triangle rendering. When you run it, you see five stacked rounded rectangles, each with different roundness values on left and right sides and different color gradients (e.g., blue-to-red, red-to-pink, blue-to-black).

## Build and Run

```bash
moon build --target native raylib_shapes_rectangle_advanced/
./_build/native/debug/build/raylib_shapes_rectangle_advanced/raylib_shapes_rectangle_advanced.exe
```

## Controls

No interactive controls -- runs automatically.

## What It Demonstrates

- **Low-level rlgl rendering** -- Uses `@rl.begin(@rl.Triangles)`, `@rl.vertex2f`, `@rl.color4ub`, and `@rl.end_()` to manually construct triangle primitives for custom shape rendering.
- **`draw_rectangle_rounded_gradient_h`** -- A custom function that draws a rounded rectangle with independent left and right roundness values and a horizontal gradient between two colors.
- **Per-vertex coloring** -- Each triangle vertex is assigned a color via `@rl.color4ub`, enabling smooth gradient interpolation across the rectangle surface.
- **9-patch decomposition** -- The rounded rectangle is decomposed into 9 regions: 4 corner arcs (rendered as triangle fans), 4 side rectangles, and 1 center rectangle, each composed of individual triangles.
- **Trigonometric corner arcs** -- Corner arcs use `cosf`/`sinf` to compute vertex positions at equal angular steps.

## Public API Reference

### Package `raylib_shapes_rectangle_advanced`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The core of this example is the `draw_rectangle_rounded_gradient_h` function, which takes a rectangle, independent left/right roundness values, segment count, and left/right gradient colors. It computes 12 key points defining the rounded rectangle boundary, then renders 9 regions using raw rlgl triangles. The 4 corner arcs iterate over segments, emitting triangles from the corner center with vertices placed along the arc using trigonometry. The 4 side rectangles and center rectangle each emit 2 triangles (6 vertices) with appropriate left or right colors. The main function draws 5 rectangles stacked vertically with varying roundness and color combinations.

## Key Takeaways

- When raylib's built-in drawing functions do not support a specific effect (like independent corner roundness with gradients), you can drop down to rlgl for direct triangle-level control.
- Rounded rectangles decompose naturally into a 9-region grid: 4 arc corners, 4 side rectangles, and 1 center rectangle.
- Per-vertex color assignment with `@rl.color4ub` before each `@rl.vertex2f` enables hardware-interpolated gradients across triangle surfaces.
