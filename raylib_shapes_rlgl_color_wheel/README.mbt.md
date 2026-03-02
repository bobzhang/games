# RLGL Color Wheel

This example demonstrates building an interactive HSV color wheel using low-level rlgl triangle rendering. When you run it, you see a circular color wheel where you can click to select a color, scroll to adjust triangle resolution, use arrow keys to scale the wheel, and adjust the value (brightness) with a slider.

## Build and Run

```bash
moon build --target native raylib_shapes_rlgl_color_wheel/
./_build/native/debug/build/raylib_shapes_rlgl_color_wheel/raylib_shapes_rlgl_color_wheel.exe
```

## Controls

- **Left mouse click (on wheel)** -- Select a color based on hue (angle) and saturation (distance from center)
- **Mouse scroll wheel** -- Increase/decrease triangle count (3 to 256) for wheel resolution
- **UP / DOWN arrows** -- Scale the color wheel larger or smaller
- **SPACE (hold)** -- Switch to wireframe rendering mode
- **Ctrl+C** -- Copy the selected color as hex to clipboard
- **Raygui slider** -- Adjust the HSV value (brightness) component

## What It Demonstrates

- **Low-level rlgl rendering** -- Uses `@rl.begin`, `@rl.vertex2f`, `@rl.color4ub`, and `@rl.end_()` to manually construct the color wheel from triangle primitives.
- **`color_from_hsv`** -- Converts HSV values to RGB colors, mapping the angular position to hue and radial distance to saturation.
- **`color_lerp`** -- Interpolates between a gray value (based on the brightness slider) and the HSV color to produce the final selected color.
- **Wireframe mode** -- Toggling between `@rl.Triangles` and `@rl.Lines` render modes shows the underlying geometry.
- **`set_clipboard_text`** -- Copies the hex color string to the system clipboard.
- **Vector math helpers** -- `vector2_angle` and `vector2_distance` compute polar coordinates for color selection, and `hex2` formats byte values as hexadecimal strings.

## Public API Reference

### Package `raylib_shapes_rlgl_color_wheel`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The color wheel is rendered as N triangles arranged in a fan around the screen center. Each triangle has its outer two vertices colored by their HSV hue (based on angle) and the center vertex colored by the current brightness value. When the user clicks on the wheel, the program converts the mouse position to polar coordinates: the angle determines hue (0-360) and the normalized distance determines saturation (0-1). The selected color is computed by interpolating between a gray (brightness-based) center color and the full HSV color at the edge. The program supports dynamic triangle count via mouse wheel, scaling via arrow keys (with handle position adjustment), and clipboard export. A raygui slider controls the value (V) component of HSV.

## Key Takeaways

- An HSV color wheel maps naturally to polar coordinates: angle equals hue, distance from center equals saturation, and an external slider controls value/brightness.
- Low-level rlgl triangle fans with per-vertex coloring enable smooth gradient interpolation that would be difficult to achieve with raylib's high-level drawing functions alone.
- Dynamic triangle count (adjustable at runtime) demonstrates how geometric resolution affects visual quality -- fewer triangles show visible facets, more triangles appear smooth.
