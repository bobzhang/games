# Lines Bezier

This example demonstrates drawing cubic Bezier curves with draggable endpoints. When you run it, you see a blue cubic Bezier line connecting two points that can be repositioned by clicking and dragging with the mouse.

## Build and Run

```bash
moon build --target native raylib_shapes_lines_bezier/
./_build/native/debug/build/raylib_shapes_lines_bezier/raylib_shapes_lines_bezier.exe
```

## Controls

- **Left mouse button (drag)** -- Click and drag either endpoint circle to reposition it

## What It Demonstrates

- **`draw_line_bezier`** -- Draws a cubic Bezier curve between two points with a specified thickness and color. The control points are automatically calculated to create a smooth S-curve.
- **`check_collision_point_circle`** -- Tests whether the mouse is hovering over either endpoint for selection.
- **`draw_circle_v`** -- Renders the draggable endpoint handles with visual feedback: larger radius on hover, red color when actively dragging.
- **`set_config_flags(FlagMsaa4xHint)`** -- Enables 4x multi-sample anti-aliasing for smoother line rendering.
- **Drag interaction pattern** -- Demonstrates a standard click-to-select, drag-to-move, release-to-drop interaction model using `is_mouse_button_down` and `is_mouse_button_released`.

## Public API Reference

### Package `raylib_shapes_lines_bezier`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes with MSAA 4x enabled for smooth lines and places two points at opposite corners of the screen (30 pixels from edges). Each frame, it checks if the mouse collides with either endpoint circle. If the user clicks on a point, that point enters drag mode and follows the mouse until the button is released. The Bezier curve is drawn between the two points using `draw_line_bezier`. Each endpoint circle shows hover feedback (14px vs 8px radius) and drag feedback (red vs blue color).

## Key Takeaways

- `draw_line_bezier` provides a simple way to draw smooth curves between two points without manually specifying control points.
- The hover/drag interaction pattern (collision test, state flag, position update, release detection) is a reusable building block for interactive graphics applications.
- Enabling MSAA before window creation significantly improves the visual quality of curved and diagonal lines.
