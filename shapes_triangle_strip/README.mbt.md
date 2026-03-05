# Shapes: Triangle Strip

This example demonstrates how to build and render a triangle strip polygon using raylib's low-level triangle drawing functions combined with raygui slider and checkbox controls. When you run it, you see a colorful star-like shape made of alternating inner and outer vertices, with a GUI panel on the right to adjust the number of segments and toggle outline rendering.

## Build and Run

```bash
moon build --target native shapes_triangle_strip/
./_build/native/debug/build/shapes_triangle_strip/shapes_triangle_strip.exe
```

## Controls

- **Segments slider** (right panel): Adjust the number of polygon segments (6 to 60)
- **Outline checkbox** (right panel): Toggle black outline rendering on/off

## What It Demonstrates

- **Triangle strip construction**: Vertices are computed by alternating between an inner radius (100px) and an outer radius (150px) at evenly spaced angles around a center point, creating a star/gear shape. Each pair of adjacent vertices forms triangles with the next pair.
- **`draw_triangle` and `draw_triangle_lines`**: Individual triangles are drawn explicitly using three-vertex calls, giving full control over coloring and winding order.
- **HSV color mapping**: Each triangle is colored using `color_from_hsv` based on its angle, producing a smooth rainbow gradient around the shape.
- **raygui integration**: `gui_slider_bar` controls the segment count and `gui_check_box` toggles outline rendering, demonstrating how to use raygui immediate-mode GUI widgets alongside raylib drawing.
- **Trigonometric vertex generation**: Uses `@math.cosf` and `@math.sinf` to compute vertex positions on concentric circles with angle-based stepping.

## Public API Reference

### Package `shapes_triangle_strip`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes a window and sets up parameters for the polygon (center, inner/outer radius, segment count). Each frame, it recomputes vertex positions based on the current segment count by alternating between inner and outer radii at angular intervals. It then draws each pair of triangles (two per segment) with HSV-based colors, optionally with outlines. The right panel displays raygui controls that update the segment count and outline toggle in real time. The window closes cleanly on exit.

## Key Takeaways

- Triangle strips can be manually constructed by computing alternating inner/outer vertices and drawing explicit triangle pairs, giving precise control over geometry and per-triangle coloring.
- raygui provides simple immediate-mode widgets (`gui_slider_bar`, `gui_check_box`) that integrate seamlessly with raylib's drawing loop for interactive parameter tuning.
- HSV color space via `color_from_hsv` is an effective way to generate visually pleasing color gradients mapped to angular or spatial position.
