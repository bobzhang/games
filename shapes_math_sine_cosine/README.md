# Math Sine Cosine

This example provides an interactive visualization of trigonometric functions on a unit circle. When you run it, you see a circle with a rotating radius arm, color-coded projections for sine (red), cosine (blue), tangent (purple), and cotangent (orange), along with complementary/supplementary/explementary angle arcs, a small wave graph, and GUI controls for pausing and adjusting the angle.

## Build and Run

```bash
moon build --target native shapes_math_sine_cosine/
./_build/native/debug/build/shapes_math_sine_cosine/shapes_math_sine_cosine.exe
```

## Controls

- **Raygui toggle** -- Pause/resume the angle rotation
- **Raygui slider** -- Manually set the current angle (0 to 360 degrees)

## What It Demonstrates

- **Trigonometric visualization** -- Sine is shown as a vertical line from center to the point's Y coordinate (red), cosine as a horizontal line (blue), tangent as a vertical line at the circle's right edge (purple), and cotangent as a horizontal line at the top edge (orange).
- **`draw_circle_sector_lines`** -- Draws arc indicators for complementary (beige), supplementary (dark blue), explementary (pink), and current (lime) angles at different radii.
- **`draw_spline_linear`** -- Renders pre-computed sine and cosine wave graphs in a small panel.
- **`draw_line_ex`** -- Draws the various trigonometric projections with different thicknesses.
- **Raygui controls** -- `gui_toggle` for pause, `gui_slider_bar` for angle, and `gui_group_box` for the values panel, with `gui_set_style` for custom label colors.
- **Helper functions** -- `clamp` and `wrap` utilities handle value bounds for tangent clamping and angle wrapping.

## Public API Reference

### Package `shapes_math_sine_cosine`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program computes all trigonometric values each frame from the current angle: sin, cos, tan, cot, and the complementary/supplementary/explementary angles. The main visualization area shows a circle with the rotating radius, color-coded projection lines, and dashed reference lines. A small wave graph in the bottom-left plots pre-computed sine and cosine waves with moving dots indicating the current values. The right panel displays numeric values and raygui controls. The angle auto-increments by 1 degree per frame unless paused, wrapping at 360 degrees.

## Key Takeaways

- Visualizing trigonometric functions on a unit circle with color-coded projections makes abstract math concepts tangible -- sine is the vertical component, cosine the horizontal, tangent the projection to the circle's edge.
- `gui_set_style` allows per-widget color customization in raygui, useful for color-coding labels to match their visual representations.
- The `clamp` function is essential for tangent/cotangent display since these functions approach infinity near 90/270 degrees.
