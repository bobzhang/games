# Textures: Blend Modes

This example demonstrates the four texture blending modes available in raylib. When you run it, you see a background texture with a foreground texture overlaid using one of four blend modes, cycled by pressing Space.

## Build and Run

```bash
moon build --target native textures_blend_modes/
./_build/native/debug/build/textures_blend_modes/textures_blend_modes.exe
```

## Controls

- **Space**: Cycle through blend modes (Alpha, Additive, Multiplied, Add Colors)

## What It Demonstrates

- **Blend mode switching**: `begin_blend_mode` and `end_blend_mode` bracket the foreground texture draw call, applying the selected blend equation to control how source and destination pixels are combined.
- **Four blend modes**: The example cycles through `BLEND_ALPHA` (0, standard transparency), `BLEND_ADDITIVE` (1, brightening/glow effect), `BLEND_MULTIPLIED` (2, darkening/shadow effect), and `BLEND_ADD_COLORS` (3, color addition).
- **Image-to-texture workflow**: `load_image` loads images from disk, `load_texture_from_image` uploads them to GPU memory, and `unload_image` frees the CPU-side data, demonstrating proper image/texture separation.
- **Match expression for text**: A `match` expression maps the integer blend mode to a descriptive string for display, showing idiomatic MoonBit pattern matching.

## Public API Reference

### Package `textures_blend_modes`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads two cyberpunk street images (background and foreground) via `load_image`, converts them to GPU textures with `load_texture_from_image`, and frees the CPU images with `unload_image`. In the main loop, Space cycles the blend mode integer (0-3, wrapping). Each frame, the background is drawn centered, then `begin_blend_mode(blend_mode)` activates the current mode before drawing the foreground texture centered on screen. `end_blend_mode` restores the default. Status text shows the current blend mode name via a `match` expression. On exit, both textures are unloaded.

## Key Takeaways

- raylib's `begin_blend_mode`/`end_blend_mode` API provides a simple way to apply different pixel blending equations without touching OpenGL state directly.
- Additive blending creates glow/light effects, multiplied blending creates shadow/darkening effects, and alpha blending handles standard transparency.
- The image-to-texture pipeline (`load_image` then `load_texture_from_image` then `unload_image`) is the recommended pattern when you need to manipulate images before GPU upload or want to free CPU memory after upload.
