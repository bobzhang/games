# Shapes - Basic Shapes Drawing

This example demonstrates the various 2D shape drawing functions available in raylib. It renders circles, rectangles, triangles, and polygons in different styles (filled, gradient, lines, wireframe) arranged in columns. When you run it, you see a showcase of basic shapes with a rotating hexagon polygon on the right side.

## Build and Run

```bash
moon build --target native raylib_shapes_basic_shapes/
./_build/native/debug/build/raylib_shapes_basic_shapes/raylib_shapes_basic_shapes.exe
```

## Controls

No interactive controls -- the polygon rotates automatically.

## What It Demonstrates

- **Circle drawing variants**: Uses `draw_circle` (filled), `draw_circle_gradient` (two-color radial gradient), and `draw_circle_lines` (outline only) to show the different circle rendering styles.
- **Rectangle drawing variants**: Uses `draw_rectangle` (filled), `draw_rectangle_gradient_h` (horizontal gradient between two colors), and `draw_rectangle_lines` (outline only).
- **Triangle drawing**: Uses `draw_triangle` (filled, specified by three Vector2 vertices) and `draw_triangle_lines` (outline only). Note that vertices must be provided in counter-clockwise order for filled triangles.
- **Polygon drawing with rotation**: Uses `draw_poly` (filled rotating hexagon), `draw_poly_lines` (outline), and `draw_poly_lines_ex` (thick outline with custom line width) centered at the same point with incrementing rotation.
- **Line drawing**: Uses `draw_line` for a simple horizontal separator line.
- **Continuous rotation animation**: Increments a rotation variable by 0.2 each frame to animate the polygon.

## Public API Reference

### Package `raylib_shapes_basic_shapes`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes an 800x450 window and a rotation counter. Each frame, the rotation increments and the shapes are drawn in a grid layout: circles in the left column, rectangles in the center, and triangles with polygons on the right. The polygon uses three overlapping draw calls (filled, outline, thick outline) at the same center point with the current rotation angle. A horizontal line separates the title from the shapes. On exit, the window is closed.

## Key Takeaways

- Raylib provides filled, gradient, and outline variants for most 2D shape types, covering common rendering needs without custom shaders.
- Polygon drawing supports arbitrary side counts and rotation angles, making it useful for UI elements, indicators, and simple geometric effects.
- Layering multiple draw calls at the same position (filled + outline + thick outline) is a simple technique for creating bordered or highlighted shapes.
