# Textures: Draw Tiled

This example demonstrates tiling a selected region of a texture atlas across a destination area with configurable scale, rotation, and color tinting. When you run it, you see a pattern texture tiled to fill the main display area, with a left panel for selecting patterns, colors, adjusting scale, and rotation.

## Build and Run

```bash
moon build --target native textures_draw_tiled/
./_build/native/debug/build/textures_draw_tiled/textures_draw_tiled.exe
```

## Controls

- **Left mouse click on pattern**: Select a tile pattern from the source texture atlas (6 available)
- **Left mouse click on color swatch**: Select a tint color (10 available)
- **Up/Down arrow keys**: Increase/decrease tile scale (0.25 steps, range 0.25 to 10.0)
- **Left/Right arrow keys**: Rotate tiles (25-degree steps)
- **Space**: Reset scale to 1.0 and rotation to 0.0

## What It Demonstrates

- **Custom tiled texture rendering**: The `draw_texture_tiled` function tiles a source rectangle across a destination area, handling four cases: destination smaller than one tile, single-column tiling, single-row tiling, and full 2D tiling with proper partial tiles at edges.
- **`draw_texture_pro` for sub-texture rendering**: The core tiling uses `draw_texture_pro` to draw specific source rectangles from a texture atlas to arbitrary destination rectangles with rotation and origin control.
- **Partial tile handling**: When the destination area is not evenly divisible by the tile size, source rectangles are proportionally cropped (e.g., `(dest.width - fi(dx)) / tw * source.width`) to fill remaining space correctly.
- **MoonBit `for`/`nobreak` pattern**: The tiling loops use `for`/`nobreak` blocks to handle remainder tiles at the edges after the main loop completes -- a pattern unique to MoonBit.
- **Resizable window**: `FlagWindowResizable` allows the window to be resized, and the tiled area automatically adjusts to fill the available space minus the option panel.
- **Trilinear texture filtering**: `set_texture_filter` with `TextureFilterTrilinear` ensures smooth tile rendering when scaled.

## Public API Reference

### Package `textures_draw_tiled`

> Single-package example.

- `opt_width : Int` -- Width of the options panel (220 pixels).
- `margin_size : Int` -- Margin size for layout (8 pixels).
- `color_size : Int` -- Size of color swatch squares (16 pixels).
- `fi(x : Int) -> Float` -- Convenience function to convert `Int` to `Float`.
- `draw_texture_tiled(texture, source, dest, origin, rotation, scale, tint) -> Unit` -- Tiles a source rectangle from a texture across a destination rectangle, handling partial tiles at edges with correct source rectangle cropping.

## Architecture

The program loads a texture atlas (`patterns.png`) containing multiple tile patterns and defines six source rectangles for each pattern. A left-side option panel shows the atlas with clickable patterns, ten color swatches, and scale/rotation information. Each frame, mouse clicks select patterns and colors, arrow keys adjust scale and rotation (with Space to reset). The main area is filled by `draw_texture_tiled`, which computes how many whole tiles fit, draws them with `draw_texture_pro`, then fills partial tiles using cropped source rectangles. On exit, the texture is unloaded.

## Key Takeaways

- Tiling a texture sub-region requires careful handling of partial tiles at edges, where the source rectangle must be proportionally cropped to match the remaining destination space.
- `draw_texture_pro` is the most versatile texture drawing function, supporting source/destination rectangles, origin points, rotation, and tinting in a single call.
- MoonBit's `for`/`nobreak` construct provides a clean way to express post-loop cleanup logic, such as drawing remainder tiles after the main tiling loop.
