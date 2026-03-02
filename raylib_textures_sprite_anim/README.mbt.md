# Textures: Sprite Animation

This example demonstrates sprite sheet animation by cycling through frames of a horizontal strip texture at an adjustable speed. When you run it, you see the full scarfy sprite sheet at the top with a red rectangle highlighting the current frame, and the animated character below, with a speed indicator and controls to adjust the frame rate.

## Build and Run

```bash
moon build --target native raylib_textures_sprite_anim/
./_build/native/debug/build/raylib_textures_sprite_anim/raylib_textures_sprite_anim.exe
```

## Controls

- **Right arrow key**: Increase animation speed (up to 15 FPS)
- **Left arrow key**: Decrease animation speed (down to 1 FPS)

## What It Demonstrates

- **`draw_texture_rec`**: Draws a rectangular sub-region of a texture, which is the core technique for sprite sheet animation. The source rectangle slides across the sprite sheet to select the current frame.
- **Frame-based animation timing**: A `frames_counter` increments each frame and resets when it reaches `60 / frames_speed`, advancing to the next animation frame. This creates a configurable animation rate independent of the 60 FPS render rate.
- **`draw_texture`**: Draws the full sprite sheet at the top of the screen as a reference.
- **`draw_rectangle_lines`**: Highlights the current frame on the sprite sheet with a red outline, and draws speed indicator boxes.
- **Visual speed indicator**: A row of rectangles shows the current `frames_speed` setting, with filled red rectangles indicating the active speed level.

## Public API Reference

### Package `raylib_textures_sprite_anim`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The scarfy sprite sheet (768x128, 6 frames of 128x128 each) is loaded as a single texture. Each frame, a counter increments and triggers a frame advance when it reaches the threshold `60 / frames_speed`. The current frame index wraps from 0-5. A source rectangle's X position is computed as `current_frame * frame_width` to select the active frame. The render loop draws the full sprite sheet with a highlight rectangle, the animated sprite using `draw_texture_rec`, speed controls text, and a visual speed bar.

## Key Takeaways

- Sprite sheet animation relies on `draw_texture_rec` with a sliding source rectangle to select individual frames from a single texture.
- Decoupling animation speed from render speed using a frame counter threshold (`60 / frames_speed`) allows flexible animation timing.
- Displaying the full sprite sheet with a frame highlight is a useful debugging and visualization technique during development.
