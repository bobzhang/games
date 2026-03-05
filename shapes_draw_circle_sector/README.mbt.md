# Draw Circle Sector

This example demonstrates how to draw circle sectors (pie-slice shapes) using raylib's `draw_circle_sector` and `draw_circle_sector_lines` functions. When you run it, you see a maroon circle sector on the left half of the screen with its wireframe outline, and a control panel on the right displaying the current start angle, end angle, radius, and segment count, all adjustable via keyboard.

## Build and Run

```bash
moon build --target native shapes_draw_circle_sector/
./_build/native/debug/build/shapes_draw_circle_sector/shapes_draw_circle_sector.exe
```

## Controls

- **LEFT / RIGHT arrows** -- Adjust start angle (0 to 720 degrees)
- **UP / DOWN arrows** -- Adjust end angle (0 to 720 degrees)
- **W / S** -- Increase / decrease outer radius (0 to 200)
- **A / D** -- Decrease / increase segment count (0 to 100)

## What It Demonstrates

- **`draw_circle_sector`** -- Renders a filled circle sector given a center, radius, start/end angles, and segment count.
- **`draw_circle_sector_lines`** -- Renders the wireframe outline of the same circle sector.
- **`fade`** -- Applies alpha transparency to colors for layered visual effects.
- **Manual vs. Auto segment mode** -- When the segment count is below the minimum required for the angular sweep, raylib automatically determines the segment count (AUTO mode); otherwise the user-specified count is used (MANUAL mode).
- Demonstrates how to build a simple parameter-tweaking UI using keyboard input and `draw_text`.

## Public API Reference

### Package `shapes_draw_circle_sector`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes an 800x450 window centered on a circle sector. Each frame, keyboard input updates the mutable parameters (start angle, end angle, radius, segments). The draw phase renders the filled sector, its wireframe overlay, and text labels showing current values. The right side of the screen acts as a parameter display panel. On exit, the window is closed with `close_window`.

## Key Takeaways

- `draw_circle_sector` and `draw_circle_sector_lines` accept identical parameters, making it easy to render both filled and outlined versions of the same shape.
- Setting segments to 0 lets raylib auto-calculate an appropriate segment count based on the angular sweep, which is useful as a sensible default.
- MoonBit's mutable `let mut` bindings with manual clamping provide straightforward parameter control without needing a GUI library.
