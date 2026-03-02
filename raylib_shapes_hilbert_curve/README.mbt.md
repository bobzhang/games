# Hilbert Curve

This example demonstrates generating and rendering a Hilbert space-filling curve with configurable order, size, and thickness. When you run it, you see a rainbow-colored Hilbert curve that can optionally animate its drawing stroke by stroke, with raygui controls for adjusting parameters.

## Build and Run

```bash
moon build --target native raylib_shapes_hilbert_curve/
./_build/native/debug/build/raylib_shapes_hilbert_curve/raylib_shapes_hilbert_curve.exe
```

## Controls

- **Raygui spinner** -- Adjust Hilbert curve order (2 to 8)
- **Raygui sliders** -- Adjust line thickness (1 to 10) and total drawing size (10 to 675)
- **Raygui checkbox** -- Toggle animated generation on parameter change

## What It Demonstrates

- **Hilbert curve generation** -- The `compute_hilbert_step` function computes (x, y) coordinates for each index in a Hilbert curve of a given order using an iterative bit-manipulation algorithm.
- **`draw_line_ex`** -- Draws thick line segments between consecutive Hilbert path points.
- **`color_from_hsv`** -- Maps each line segment's index to a hue value (0-360) creating a rainbow gradient along the curve path.
- **Raygui integration** -- Uses `gui_check_box`, `gui_spinner`, and `gui_slider` for interactive parameter adjustment.
- **Progressive animation** -- When animation is enabled, the curve draws one segment per frame, creating a satisfying reveal effect.

## Public API Reference

### Package `raylib_shapes_hilbert_curve`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program pre-computes the full Hilbert path as an array of `Vector2` points using `load_hilbert_path`, which calls `compute_hilbert_step` for each index. The step function uses an iterative approach with bit shifting (`>> 2`) to decompose the index into base-4 digits, applying rotation and translation transformations at each level. Each frame, if the counter is below the total stroke count, one more segment is drawn (animation mode) or all segments are drawn at once (complete mode). When order or size parameters change, the path is regenerated. The HSV color mapping creates a smooth rainbow gradient proportional to position along the curve.

## Key Takeaways

- Hilbert curves are generated iteratively by decomposing an index into base-4 digits and applying geometric transformations (rotation, reflection, translation) at each recursion level.
- `color_from_hsv` with a linearly mapped hue is an effective way to visualize progression along a path or sequence.
- Using `Ref[T]` types for raygui control values allows the GUI widgets to modify values in place, which is the expected pattern for raygui integration in MoonBit.
