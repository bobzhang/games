# Kaleidoscope

This example demonstrates a kaleidoscope drawing tool that creates symmetrical patterns by reflecting mouse strokes across multiple axes. When you run it, you can draw with the mouse and see your strokes reflected with 6-fold symmetry around the screen center, creating mandala-like patterns.

## Build and Run

```bash
moon build --target native shapes_kaleidoscope/
./_build/native/debug/build/shapes_kaleidoscope/shapes_kaleidoscope.exe
```

## Controls

- **Left mouse button (drag)** -- Draw lines that are reflected with 6-fold symmetry
- **Reset button (top-right)** -- Clear all drawn lines
- **< button (bottom-right)** -- Undo one line step
- **> button (bottom-right)** -- Redo one line step

## What It Demonstrates

- **Rotational symmetry** -- Each mouse stroke is rotated by 60-degree increments (360/6) and also reflected vertically, producing 12 line copies per stroke using `vec2_rotate` and `vec2_multiply`.
- **`Camera2D` with `begin_mode_2d`** -- Centers the coordinate system at the screen middle, simplifying the symmetry calculations.
- **`draw_line_ex`** -- Draws thick lines for each stored stroke segment.
- **Raygui buttons** -- `gui_button` provides Reset, Back (<), and Forward (>) controls with `gui_disable`/`gui_enable` for conditional button states.
- **Line storage** -- Up to 8192 lines are stored in a pre-allocated array, with separate counters for current display position and total recorded lines enabling undo/redo.

## Public API Reference

### Package `shapes_kaleidoscope`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program stores lines in a fixed-capacity array of `Line` structs (start/end Vector2 pairs). On each frame with mouse button held, the current mouse movement is converted to a line segment relative to screen center. This line is rotated by the symmetry angle (60 degrees) for each of the 6 symmetry axes, and each rotated line is also vertically reflected, producing pairs stored consecutively. The Camera2D offset centers all drawing at the screen midpoint. Raygui buttons control reset (clear all), back (decrease display counter), and forward (increase display counter) operations. Lines are drawn in pairs to account for both the rotated and reflected versions.

## Key Takeaways

- Rotational symmetry is achieved by repeatedly applying `vec2_rotate` with equal angular increments, combined with `vec2_multiply` by (1, -1) for reflection across the horizontal axis.
- Using `Camera2D` with an offset equal to the screen center simplifies symmetric drawing by making (0, 0) the center of symmetry.
- Pre-allocating a large fixed-size line buffer with separate current/total counters is a simple and effective pattern for implementing undo/redo in a drawing application.
