# Textures: GIF Player

This example demonstrates loading and playing an animated GIF file by extracting individual frames and updating a GPU texture each frame. When you run it, you see a running character animation (Scarfy) with adjustable playback speed and a visual delay indicator.

## Build and Run

```bash
moon build --target native raylib_textures_gif_player/
./_build/native/debug/build/raylib_textures_gif_player/raylib_textures_gif_player.exe
```

## Controls

- **Right arrow key**: Increase frame delay (slower animation)
- **Left arrow key**: Decrease frame delay (faster animation)

## What It Demonstrates

- **Animated GIF loading**: `load_image_anim` loads all frames of an animated GIF (`scarfy_run.gif`) into a single `Image` with frames stacked in memory. `image_frame_count` returns the total number of animation frames.
- **Per-frame texture updates**: `update_texture_from_image_frame` uploads a specific frame from the multi-frame image to an existing GPU texture by index, avoiding the need to create separate textures for each frame.
- **Frame delay control**: A configurable frame delay (range 1 to 20 frames) controls how many render frames pass before advancing to the next animation frame, providing variable-speed playback via `is_key_pressed`.
- **Frame counter animation**: A `frame_counter` tracks elapsed render frames; when it reaches `frame_delay`, the animation advances to the next frame (wrapping with modulo) and the counter resets to 0.
- **Visual speed indicator**: Red rectangles in a horizontal bar of 20 slots show the current frame delay setting, providing intuitive visual feedback for the animation speed. Empty slots are drawn as outlined rectangles.

## Public API Reference

### Package `raylib_textures_gif_player`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads an animated GIF into a multi-frame image with `load_image_anim` and creates a single GPU texture from it with `load_texture_from_image`. In the main loop, a frame counter controls animation timing: when it reaches the configured delay, `current_anim_frame` advances (wrapping to 0 at the end) and `update_texture_from_image_frame` uploads the new frame data to the GPU. Arrow keys adjust the delay between 1 and 20. The texture is drawn centered on screen with `draw_texture`, and text displays total frames, current frame index, delay value, and a visual bar indicator. On exit, both the texture and the multi-frame image are unloaded.

## Key Takeaways

- `load_image_anim` loads all GIF frames into a single image, and `update_texture_from_image_frame` efficiently swaps frame data on an existing texture without reallocating GPU resources.
- For production sprite animation, spritesheets with source rectangle changes are preferred over GIF frame swapping, but GIF playback is useful for previewing pre-made animations.
- Frame-delay-based animation timing provides simple speed control where lower delay values produce faster animation and higher values produce slower animation.
