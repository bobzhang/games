# Smooth Pixel-Perfect Camera

This example demonstrates smooth pixel-perfect camera movement by rendering to a low-resolution render texture (160x90) and upscaling it to the window (800x450). It uses a dual-camera technique where a world-space camera handles integer pixel positions and a screen-space camera handles the fractional sub-pixel offset, eliminating pixel jitter while maintaining smooth motion.

## Build and Run

```bash
moon build --target native core_smooth_pixelperfect/
./_build/native/debug/build/core_smooth_pixelperfect/core_smooth_pixelperfect.exe
```

## Controls

No interactive controls -- the camera orbits automatically using sine and cosine functions to demonstrate smooth motion.

## What It Demonstrates

- `@raylib.load_render_texture()` to create a low-resolution (160x90) off-screen render target
- `@raylib.begin_texture_mode()` / `@raylib.end_texture_mode()` to render the scene into the texture
- `@raylib.Camera2D::new()` for creating two separate 2D cameras with different roles
- `@raylib.begin_mode_2d()` / `@raylib.end_mode_2d()` for camera-transformed rendering
- `@raylib.draw_render_texture_pro()` to blit the render texture to the screen with scaling
- `@raylib.draw_rectangle_pro()` to draw rotated rectangles
- Negative height in the source `Rectangle` to flip the OpenGL-inverted render texture vertically
- `@math.sinf()` / `@math.cosf()` for smooth orbital camera movement
- The `truncf` helper to separate integer and fractional parts of camera coordinates

## Public API Reference

### Package `core_smooth_pixelperfect`

> Single-package example.

No public API -- self-contained main function. The helper function `truncf` truncates a float to its integer part.

## Architecture

The program creates a 160x90 render texture and two `Camera2D` instances. Each frame, the camera target is computed using sine/cosine for orbital motion. The target coordinates are split: integer parts go to the world-space camera (for pixel-aligned rendering), and fractional parts (scaled by the virtual ratio) go to the screen-space camera (for sub-pixel smoothing). The scene (three rotating rectangles) is drawn into the render texture using the world-space camera. The texture is then drawn to the screen using the screen-space camera, scaled up with padding to cover the full window.

## Key Takeaways

- The dual-camera technique separates integer pixel positioning from fractional sub-pixel offsets, achieving smooth camera movement without the jitter common in low-resolution pixel art games.
- Rendering to a small texture and upscaling preserves the pixel art aesthetic while the screen-space camera offset provides smooth interpolation between pixel positions.
- The negative height in the source rectangle is required because OpenGL render textures are vertically flipped compared to screen coordinates.
