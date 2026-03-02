# Shapes - Colors Palette

This example displays all of raylib's built-in named colors as a grid of interactive color swatches. Hovering over a swatch fades it and reveals its name, while holding Space shows all color names at once. When you run it, you see a 7-column grid of 21 colored rectangles that respond to mouse hover with transparency and name labels.

## Build and Run

```bash
moon build --target native raylib_shapes_colors_palette/
./_build/native/debug/build/raylib_shapes_colors_palette/raylib_shapes_colors_palette.exe
```

## Controls

- **Mouse hover**: Highlights a color swatch (fades it and shows its name)
- **Space (hold)**: Shows all color names simultaneously

## What It Demonstrates

- **Raylib's built-in color constants**: Showcases 21 named colors from `darkgray` through `beige`, providing a visual reference for the color palette available in raylib.
- **Point-rectangle collision for hover detection**: Uses `check_collision_point_rec` with `get_mouse_position` to detect which color swatch the mouse is over.
- **Alpha fading for hover effect**: Uses `fade` to reduce a color's alpha to 0.6 when hovered, creating a visual highlight effect.
- **Dynamic grid layout**: Computes rectangle positions using modular arithmetic (`i % 7` for column, `i / 7` for row) with spacing offsets.
- **Text measurement for alignment**: Uses `measure_text` to right-align color name labels within each swatch.
- **Conditional rendering with key state**: Uses `is_key_down(KeySpace)` to reveal all labels simultaneously, providing an alternative to individual hover inspection.

## Public API Reference

### Package `raylib_shapes_colors_palette`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes arrays of 21 colors and their string names, then computes a grid of 100x100 pixel rectangles arranged in 7 columns with 10-pixel spacing. A parallel state array tracks hover status (0 = default, 1 = hovered) for each swatch. Each frame, `check_collision_point_rec` updates the hover state for all swatches. During drawing, each swatch is rendered with `draw_rectangle_rec` using faded alpha if hovered. When a swatch is hovered or Space is held, a black label bar with the color name is drawn at the bottom of the swatch, with the text right-aligned using `measure_text`. On exit, the window is closed.

## Key Takeaways

- `check_collision_point_rec` is the standard approach for detecting mouse hover over rectangular UI elements in raylib.
- `fade` provides a simple way to create transparency-based hover effects without managing separate color values.
- Grid layouts can be computed from a flat index using division and modulus, a common pattern for arranging items in rows and columns.
