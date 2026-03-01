# Window Scale Letterbox

This example demonstrates resolution-independent rendering with letterboxing. The game renders at a fixed 640x480 resolution onto a render texture, which is then scaled to fit any window size while preserving the aspect ratio. Black letterbox bars fill the remaining space. The window is resizable so the effect can be observed in real time.

## Build and Run

```bash
moon build --target native raylib_core_window_letterbox/
./_build/native/debug/build/raylib_core_window_letterbox/raylib_core_window_letterbox.exe
```

## Controls

- **Resize the window** -- drag window edges to see letterbox scaling in action
- **Space** -- randomize the color bars

## What It Demonstrates

- `@raylib.set_config_flags(@raylib.FlagWindowResizable | @raylib.FlagVsyncHint)` to enable window resizing and VSync before creation
- `@raylib.set_window_min_size()` to enforce a minimum window size (320x240)
- `@raylib.load_render_texture()` to create a fixed-resolution (640x480) off-screen render target
- `@raylib.set_render_texture_filter()` with `TextureFilterBilinear` for smooth upscaling
- `@raylib.begin_texture_mode()` / `@raylib.end_texture_mode()` for rendering to the texture
- `@raylib.draw_render_texture_pro()` to blit the render texture to the screen with computed scaling and centering
- Virtual mouse coordinate mapping: transforming screen-space mouse coordinates to game-space coordinates by accounting for scale and offset
- `@raylib.Vector2::clamp()` to constrain the virtual mouse within game bounds
- Scale factor computation as `min(window_width / game_width, window_height / game_height)` for uniform aspect-ratio-preserving scaling

## Public API Reference

### Package `raylib_core_window_letterbox`

> Single-package example.

No public API -- self-contained main function. The helper function `min_f` returns the minimum of two floats.

## Architecture

The program creates a resizable window and a 640x480 render texture with bilinear filtering. Each frame, it computes the scale factor as the minimum of horizontal and vertical ratios. The game scene (10 colored horizontal bars with mouse coordinate text) is rendered into the render texture. The texture is then drawn to the screen centered within the window, scaled uniformly. Black letterbox bars appear automatically because the screen is cleared to black before the scaled texture is drawn. The virtual mouse is computed by reversing the scale and offset transformation.

## Key Takeaways

- Rendering to a fixed-size texture and scaling it to the window with `min(w_ratio, h_ratio)` is the standard approach for resolution-independent games with letterboxing.
- Virtual mouse coordinate mapping is essential when using render-to-texture scaling; the raw mouse position must be transformed to match the game's coordinate space.
- Setting `TextureFilterBilinear` on the render texture smooths the upscaling, while `TextureFilterPoint` would preserve hard pixel edges for pixel art styles.
