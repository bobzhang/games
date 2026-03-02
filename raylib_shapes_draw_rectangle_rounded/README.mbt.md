# Draw Rectangle Rounded

This example demonstrates how to draw rounded rectangles using raylib's `draw_rectangle_rounded` and `draw_rectangle_rounded_lines_ex` functions. When you run it, you see a centered rounded rectangle that can be toggled between filled, outlined, and plain rectangular modes, with all parameters adjustable via keyboard.

## Build and Run

```bash
moon build --target native raylib_shapes_draw_rectangle_rounded/
./_build/native/debug/build/raylib_shapes_draw_rectangle_rounded/raylib_shapes_draw_rectangle_rounded.exe
```

## Controls

- **LEFT / RIGHT arrows** -- Adjust rectangle width
- **UP / DOWN arrows** -- Adjust rectangle height
- **W / S** -- Increase / decrease corner roundness (0.0 to 1.0)
- **A / D** -- Decrease / increase segment count (0 to 60)
- **Q / E** -- Decrease / increase outline line thickness (0 to 20)
- **1** -- Toggle rounded rectangle fill
- **2** -- Toggle rounded rectangle outline
- **3** -- Toggle plain rectangle fill

## What It Demonstrates

- **`draw_rectangle_rounded`** -- Draws a filled rectangle with rounded corners, controlled by a roundness factor (0.0 = sharp, 1.0 = fully rounded) and segment count.
- **`draw_rectangle_rounded_lines_ex`** -- Draws only the outline of a rounded rectangle with configurable line thickness.
- **`draw_rectangle_rec`** -- Draws a standard filled rectangle for visual comparison.
- **Manual vs. Auto segment mode** -- When segments >= 4, the user-specified count is used (MANUAL); otherwise raylib auto-selects segments (AUTO).
- Demonstrates layering multiple draw modes (fill, outline, plain) to visualize how rounded rectangle parameters interact.

## Public API Reference

### Package `raylib_shapes_draw_rectangle_rounded`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes an 800x450 window. Each frame, keyboard input adjusts six parameters: width, height, roundness, segments, line thickness, and three boolean draw-mode toggles. The rectangle is constructed centered on the left portion of the screen. Drawing renders the active modes in order (plain fill, rounded fill, rounded outline) followed by a text parameter panel on the right side. Cleanup calls `close_window`.

## Key Takeaways

- The roundness parameter in `draw_rectangle_rounded` is a normalized value (0.0 to 1.0) that controls how much of the shorter dimension is used as the corner radius.
- Combining `draw_rectangle_rounded` and `draw_rectangle_rounded_lines_ex` lets you create visually rich UI elements with both fill and stroke.
- Setting segments to 0 provides automatic segment calculation, which is a good default for most use cases.
