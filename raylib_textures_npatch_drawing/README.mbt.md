# Textures: N-Patch Drawing

This example demonstrates N-patch (nine-patch) texture drawing, which allows textures to scale without distorting their border regions. When you run it, you see four scalable UI elements -- two 9-patch buttons, a horizontal 3-patch, and a vertical 3-patch -- that resize interactively as you move the mouse.

## Build and Run

```bash
moon build --target native raylib_textures_npatch_drawing/
./_build/native/debug/build/raylib_textures_npatch_drawing/raylib_textures_npatch_drawing.exe
```

## Controls

- **Mouse movement**: Stretches or shrinks the N-patch rectangles based on cursor position

## What It Demonstrates

- **`NPatchInfo::new`**: Defines N-patch metadata including the source rectangle within the texture, border sizes (left, top, right, bottom), and the patch layout type.
- **`draw_texture_npatch`**: Draws a texture using N-patch scaling rules, where border regions maintain their size while interior regions stretch to fill the destination rectangle.
- **`NpatchNinePatch`**: A 9-patch layout that scales in both axes, preserving all four corners and stretching the center and edges.
- **`NpatchThreePatchHorizontal`**: A horizontal 3-patch that only scales along the X axis, keeping left and right ends fixed.
- **`NpatchThreePatchVertical`**: A vertical 3-patch that only scales along the Y axis, keeping top and bottom ends fixed.
- The source texture contains four 64x64 button graphics stacked vertically (at y-offsets 0, 64, 128, 192), each used by a different N-patch configuration.

## Public API Reference

### Package `raylib_textures_npatch_drawing`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads a single texture containing four button sprites. Four `NPatchInfo` structures are created: two 9-patches with different border sizes, one horizontal 3-patch, and one vertical 3-patch. Each frame, the mouse position determines the width and/or height of each destination rectangle (with minimum clamping to prevent negative sizes). The render loop draws each N-patch using `draw_texture_npatch`, plus the source texture and a label. The source texture is displayed in the lower-left for reference.

## Key Takeaways

- N-patch drawing is essential for scalable UI elements like buttons and panels that need to resize without distorting their borders or corners.
- The three N-patch modes (9-patch, horizontal 3-patch, vertical 3-patch) cover different scaling needs: 2D scaling, horizontal-only, and vertical-only.
- Border sizes in `NPatchInfo` define how many pixels from each edge are preserved during scaling; the interior region stretches to fill the remaining space.
