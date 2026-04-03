# Text: Font SDF

This example demonstrates Signed Distance Field (SDF) font rendering compared to default bitmap font rendering. When you run it, you see the text "Signed Distance Fields" that can be scaled with the mouse wheel, toggling between a standard rasterized font and an SDF font that remains crisp at any scale.

## Build and Run

```bash
moon build --target native text_font_sdf/
./_build/native/debug/build/text_font_sdf/text_font_sdf.exe
```

## Controls

- **Mouse wheel**: Scale the text size up or down (minimum 6.0)
- **Space (hold)**: Switch from default font to SDF font rendering

## What It Demonstrates

- **SDF font generation**: `build_font_from_data` with `FontSdf` mode generates a signed distance field font atlas from raw TTF file data, where each pixel stores the distance to the nearest glyph edge rather than a simple bitmap. Uses Skyline pack method (1) with 0px padding.
- **Default font generation**: The same `build_font_from_data` with `FontDefault` mode generates a standard bitmap font for comparison, using default pack method (0) with 4px padding.
- **SDF shader**: `load_shader` loads a custom fragment shader (`resources/shaders/glsl330/sdf.fs`) that interprets distance field data to produce sharp edges at any scale. Activated with `begin_shader_mode` before drawing SDF text.
- **Raw file data loading**: `load_file_data` reads the TTF file (`anonymous_pro_bold.ttf`) into memory once, and both font types are generated from the same data.
- **Font atlas visualization**: Both font atlas textures are displayed via `get_font_texture` and `draw_texture`, showing the visual difference between a bitmap atlas and an SDF atlas.
- **Bilinear filtering for SDF**: `set_font_texture_filter` with `TextureFilterBilinear` is required for SDF fonts to interpolate distance values smoothly.

## Public API Reference

### Package `text_font_sdf`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads raw TTF font data with `load_file_data` and builds two font variants at 16px base size: a default bitmap font and an SDF font. An SDF fragment shader is loaded. In the main loop, the mouse wheel adjusts render size (clamped to minimum 6.0), and holding Space switches between the two fonts. When the SDF font is active, the shader is enabled before drawing text with `draw_text_ex`. The font atlas texture is displayed in the top-left corner. On exit, both fonts and the shader are cleaned up.

## Key Takeaways

- SDF fonts store distance-to-edge information instead of pixel coverage, allowing a single small atlas to render crisp text at virtually any size without blurring or pixelation.
- SDF rendering requires a dedicated fragment shader that converts distance values to sharp alpha edges, and bilinear texture filtering for smooth distance interpolation.
- The trade-off is that SDF generation is more expensive at load time and requires shader support, but the result is resolution-independent text that scales far better than traditional bitmap fonts.
