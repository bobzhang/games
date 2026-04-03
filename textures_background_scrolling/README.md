# Textures: Background Scrolling

This example demonstrates a parallax scrolling background effect using multiple texture layers moving at different speeds. When you run it, you see a cyberpunk street scene with three layers (background, midground, foreground) scrolling continuously from right to left at increasing speeds, creating a depth illusion.

## Build and Run

```bash
moon build --target native textures_background_scrolling/
./_build/native/debug/build/textures_background_scrolling/textures_background_scrolling.exe
```

## Controls

No interactive controls -- runs automatically.

## What It Demonstrates

- **Parallax scrolling**: Three texture layers move at different speeds (0.1, 0.5, 1.0 pixels per frame) to create an illusion of depth, with the background moving slowest and the foreground fastest.
- **Seamless texture looping**: Each layer is drawn twice side by side using `draw_texture_ex`. When the first copy scrolls completely off-screen (offset reaches negative double-width), the scroll offset resets to zero, creating an infinite seamless loop.
- **Texture scaling**: `draw_texture_ex` renders each texture at 2x scale, so the original texture dimensions (512px background/midground, 704px foreground) are doubled on screen.
- **Custom background color**: `get_color(0x052c46ff)` converts a hex color value to create a dark blue-teal background that matches the cyberpunk scene.

## Public API Reference

### Package `textures_background_scrolling`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads three PNG textures (`cyberpunk_street_background.png`, `cyberpunk_street_midground.png`, `cyberpunk_street_foreground.png`) representing different depth layers. Each frame, three scroll offset variables are decremented at different rates (0.1, 0.5, 1.0). When any offset exceeds the negative double-width threshold, it resets to zero. Each layer is drawn twice (at `scrolling_offset` and `texture_width * 2 + scrolling_offset`) using `draw_texture_ex` with 2x scale, ensuring continuous coverage. On exit, all three textures are unloaded.

## Key Takeaways

- Parallax scrolling is achieved by moving multiple background layers at different speeds, with slower layers appearing farther away.
- Drawing each texture twice with an offset and resetting the offset at the wrap-around point creates a seamless infinite scroll effect.
- `draw_texture_ex` with a scale factor is a convenient way to upscale textures for pixel-art style games while maintaining simple parallax math.
