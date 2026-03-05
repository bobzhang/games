# Splines Drawing

This example demonstrates four types of spline curves with interactive point editing. When you run it, you see a red spline curve passing through draggable control points, with the ability to switch between Linear, B-Spline, Catmull-Rom, and Bezier spline types, and to add new points by right-clicking.

## Build and Run

```bash
moon build --target native shapes_splines_drawing/
./_build/native/debug/build/shapes_splines_drawing/shapes_splines_drawing.exe
```

## Controls

- **Left mouse button (drag)** -- Drag spline points or Bezier control points
- **Right mouse button** -- Add a new spline point at the mouse position (up to 32 points)
- **1** -- Switch to Linear spline
- **2** -- Switch to B-Spline
- **3** -- Switch to Catmull-Rom spline
- **4** -- Switch to Bezier spline (with editable control points)

## What It Demonstrates

- **`draw_spline_linear`** -- Draws straight line segments connecting all points.
- **`draw_spline_basis`** -- Draws a smooth B-Spline curve that approximates (does not interpolate) the control points.
- **`draw_spline_catmull_rom`** -- Draws a Catmull-Rom spline that passes through all control points.
- **`draw_spline_bezier_cubic`** -- Draws a cubic Bezier spline using interleaved point and control-point data (point, control-start, control-end, point, ...).
- **`check_collision_point_circle`** -- Used for both spline point and Bezier control point hit testing.
- **`draw_circle_lines_v`** -- Renders point handles with hover feedback (larger radius when focused).
- **`set_config_flags(FlagMsaa4xHint)`** -- Enables anti-aliasing for smooth curve rendering.
- **Bezier control point management** -- Each segment between two spline points has two control handles (start and end), drawn as gold circles with connecting lines to their anchor points.

## Public API Reference

### Package `shapes_splines_drawing`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program starts with 5 pre-placed spline points and pre-computed Bezier control points. Each frame processes three interaction layers: (1) right-click adds new points with corresponding control points, (2) left-click-drag moves spline points (checked first) or Bezier control points (checked second), and (3) number keys switch spline types. Drawing dispatches to the appropriate spline function based on `spline_type_active`. For Bezier mode, an interleaved array is built by inserting control-start and control-end points between each pair of spline points. Point handles are drawn with hover/selection visual feedback, and in non-linear/non-Bezier modes, connecting lines between adjacent points are shown for reference.

## Key Takeaways

- raylib provides four spline types with a consistent API: Linear (straight segments), B-Spline (smooth approximation), Catmull-Rom (smooth interpolation), and cubic Bezier (explicit control points).
- The Bezier spline's interleaved data format (point, control-start, control-end, point, ...) requires careful array construction but provides the most control over curve shape.
- Separating point selection from control point selection (checking spline points first, then control points only if no spline point was focused) prevents interaction conflicts in complex editors.
