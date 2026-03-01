# Draw Ring

This example demonstrates how to draw ring shapes (annular sectors) using raylib's `draw_ring`, `draw_ring_lines`, and `draw_circle_sector_lines` functions. When you run it, you see a maroon ring shape on the left side of the screen with adjustable inner/outer radius, start/end angles, and segment count, all controlled by keyboard.

## Build and Run

```bash
moon build --target native raylib_shapes_draw_ring/
./_build/native/debug/build/raylib_shapes_draw_ring/raylib_shapes_draw_ring.exe
```

## Controls

- **LEFT / RIGHT arrows** -- Adjust start angle (-450 to 450 degrees)
- **UP / DOWN arrows** -- Adjust end angle (-450 to 450 degrees)
- **W / S** -- Increase / decrease inner radius (0 to 100)
- **A / D** -- Decrease / increase outer radius (0 to 200)
- **Q / E** -- Decrease / increase segment count (0 to 100)
- **1** -- Toggle filled ring drawing
- **2** -- Toggle ring outline drawing
- **3** -- Toggle circle sector lines drawing

## What It Demonstrates

- **`draw_ring`** -- Renders a filled ring (donut shape) defined by inner and outer radii, start and end angles, and a segment count.
- **`draw_ring_lines`** -- Renders the wireframe outline of the same ring shape.
- **`draw_circle_sector_lines`** -- Draws circle sector lines using only the outer radius for comparison.
- **Manual vs. Auto segment mode** -- Similar to other shape examples, segment count below the calculated minimum triggers automatic mode.
- Shows the relationship between ring drawing (two radii) and circle sector drawing (one radius).

## Public API Reference

### Package `raylib_shapes_draw_ring`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program creates an 800x450 window with a ring centered in the left viewport area. Each frame reads keyboard state to update inner radius, outer radius, start/end angles, segments, and three draw-mode toggles. The draw phase renders whichever modes are active, then displays parameter values as text on the right panel. The minimum segment count is calculated from the angular sweep to determine AUTO vs. MANUAL mode display.

## Key Takeaways

- `draw_ring` creates hollow circular shapes by specifying both inner and outer radii, which is useful for UI elements like progress rings or radar displays.
- Negative angles are supported, allowing rings to be drawn in either clockwise or counter-clockwise direction.
- The three toggleable draw modes let you visually compare filled rings, ring outlines, and simple sector lines side by side.
