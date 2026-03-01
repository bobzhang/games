# Text: Font Filters

This example demonstrates how different texture filtering modes affect font rendering quality at various sizes. When you run it, you see a large text string rendered with a TTF font that can be scaled using the mouse wheel, with three selectable texture filters: point (nearest-neighbor), bilinear, and trilinear.

## Build and Run

```bash
moon build --target native raylib_text_font_filters/
./_build/native/debug/build/raylib_text_font_filters/raylib_text_font_filters.exe
```

## Controls

- **Mouse wheel**: Scale the font size up or down
- **Left/Right arrow keys**: Move the text horizontally
- **1**: Set texture filter to Point (nearest-neighbor)
- **2**: Set texture filter to Bilinear
- **3**: Set texture filter to Trilinear

## What It Demonstrates

- **TTF font loading with custom size**: `load_font_ex` loads a TTF font (`KAISG.ttf`) at a specific base size (96 pixels), which determines the resolution of the generated glyph atlas.
- **Mipmap generation for fonts**: `gen_font_texture_mipmaps` generates mipmap levels for the font texture, enabling trilinear filtering to produce smoother results when scaling down.
- **Texture filter modes**: `set_font_texture_filter` switches between `TEXTURE_FILTER_POINT` (0, pixelated), `TEXTURE_FILTER_BILINEAR` (1, smooth), and `TEXTURE_FILTER_TRILINEAR` (2, smooth with mipmaps) to show the visual difference each filter makes.
- **Dynamic font sizing**: The mouse wheel adjusts `font_size` by 4 units per notch, and `measure_text_ex` measures the text dimensions at the current size, displayed in the status bar.
- **Text rendering with custom fonts**: `draw_text_ex` renders text using the loaded font at an arbitrary position and size.

## Public API Reference

### Package `raylib_text_font_filters`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads a TTF font at 96px base size and generates mipmaps for it. The initial filter is set to Point. In the main loop, the mouse wheel adjusts font size, keys 1-3 switch texture filters, and arrow keys move the text horizontally. Each frame draws the scaled text with `draw_text_ex` and displays current font size, measured text dimensions, and the active filter mode name in a status bar at the bottom.

## Key Takeaways

- Font texture filtering has a dramatic impact on rendering quality: point filtering gives a crisp/pixelated look, bilinear smooths at the cost of slight blurriness, and trilinear with mipmaps provides the best quality when scaling down.
- Generating mipmaps with `gen_font_texture_mipmaps` is essential for trilinear filtering to work properly and is only noticeable when rendering at sizes smaller than the base font size.
- Loading TTF fonts at a high base size (e.g., 96px) provides more detail in the glyph atlas, allowing better quality when scaling to various display sizes.
