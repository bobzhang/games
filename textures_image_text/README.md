# Textures: Image Text Drawing

This example demonstrates two approaches to drawing text with custom fonts: drawing text directly onto a CPU-side image before uploading it as a texture, and drawing text at runtime using the font during rendering. When you run it, you see the parrots image with text baked into the texture at the top, and the same text drawn live below the image using the sprite font.

## Build and Run

```bash
moon build --target native textures_image_text/
./_build/native/debug/build/textures_image_text/textures_image_text.exe
```

## Controls

No interactive controls -- runs automatically.

## What It Demonstrates

- **`load_font_ex`**: Loads a TrueType font (TTF) with a specified base size (64) for high-quality text rendering.
- **`image_draw_text_ex`**: Draws text onto a CPU-side image using a custom font, with configurable position, size, spacing, and color. The text becomes a permanent part of the image data.
- **`draw_text_ex`**: Draws text at runtime during the render loop using the same custom font, demonstrating live text rendering for comparison.
- **`draw_texture_v`**: Draws a texture at a `Vector2` position.
- **`load_texture_from_image`** / **`unload_image`**: Standard image-to-texture conversion and cleanup.

## Public API Reference

### Package `textures_image_text`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads the parrots image and a TTF font at size 64. Text is drawn onto the image using `image_draw_text_ex`, then the image is converted to a texture and the CPU image is freed. The render loop draws the texture centered on screen and also draws the same text below the image using `draw_text_ex` for visual comparison. Both the texture and font are unloaded on exit.

## Key Takeaways

- `image_draw_text_ex` bakes text permanently into an image before it becomes a texture, which is useful for creating labeled textures or UI elements that do not change.
- `draw_text_ex` renders text every frame and is suitable for dynamic text that changes at runtime.
- `load_font_ex` with a TTF file provides much higher quality text than the default bitmap font, especially at larger sizes.
