# Textures: Raw Data

This example demonstrates loading a texture from raw binary image data (no file header) and combining it with a procedurally generated checked texture. When you run it, you see a semi-transparent checkerboard pattern overlaid with the fudesumi character sprite loaded from raw RGBA pixel data.

## Build and Run

```bash
moon build --target native textures_raw_data/
./_build/native/debug/build/textures_raw_data/textures_raw_data.exe
```

## Controls

No interactive controls -- runs automatically.

## What It Demonstrates

- **`load_image_raw`**: Loads raw pixel data from a binary file with no image header. You must specify the dimensions (384x512), pixel format (`PixelformatUncompressedR8g8b8a8`), and header size (0) manually.
- **`gen_image_checked`**: Generates a procedural checkerboard image with specified tile sizes and colors (orange and gold).
- **`load_texture_from_image`** / **`unload_image`**: Standard image-to-texture conversion.
- **`fade`**: Draws the checkerboard texture at 50% opacity so the text behind it remains partially visible.
- **`draw_texture`**: Draws both textures at specific positions to create a layered composition.

## Public API Reference

### Package `textures_raw_data`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads the fudesumi character from a raw binary file (384x512, RGBA8888, no header) and converts it to a texture. A 960x480 checkerboard image is generated with `gen_image_checked` and also converted to a texture. Both CPU images are freed. The render loop draws the checkerboard at 50% opacity centered on screen, the fudesumi sprite at position (430, -30), and descriptive text labels.

## Key Takeaways

- `load_image_raw` is essential for loading pixel data from custom binary formats or raw dumps where there is no standard image header (PNG, BMP, etc.).
- You must know the exact dimensions, pixel format, and header offset of the raw data file to load it correctly.
- Combining `fade` with `draw_texture` provides a simple way to layer semi-transparent textures without custom shaders.
