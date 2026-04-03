# Textures: Sprite Explosion

This example demonstrates a click-triggered explosion animation using a 5x5 grid sprite sheet with an accompanying sound effect. When you run it, you see an empty screen; clicking the left mouse button triggers an explosion animation at the cursor position with a boom sound, playing through all 25 frames before becoming available for the next click.

## Build and Run

```bash
moon build --target native textures_sprite_explosion/
./_build/native/debug/build/textures_sprite_explosion/textures_sprite_explosion.exe
```

## Controls

- **Left mouse button**: Trigger an explosion at the cursor position (only when no explosion is currently playing)

## What It Demonstrates

- **Grid-based sprite sheet animation**: The explosion texture (1024x1024) is divided into a 5x5 grid of 25 frames. The source rectangle is computed using `current_frame` (column) and `current_line` (row) to select the correct cell.
- **One-shot animation with state tracking**: An `active` boolean prevents new explosions from being triggered while one is already playing. The animation automatically deactivates after cycling through all 25 frames.
- **`draw_texture_rec`**: Draws the current explosion frame from the sprite sheet at the click position.
- **`is_mouse_button_pressed`**: Detects the initial click to start the explosion (not continuous holding).
- **`init_audio_device`** / **`load_sound`** / **`play_sound`**: Plays the boom sound effect when the explosion starts.
- **Frame timing with counter**: A `frames_counter` delays frame advancement (advancing every 3 render frames) to control animation speed.

## Public API Reference

### Package `textures_sprite_explosion`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The explosion texture and boom sound are loaded at startup. When the user clicks and no explosion is active, the click position is recorded (offset by half the frame size for centering), the `active` flag is set, and the sound plays. While active, a frame counter increments each render frame; every 3 frames, `current_frame` advances. When `current_frame` exceeds 4, it wraps to 0 and `current_line` advances. When `current_line` exceeds 4, the animation completes and `active` is set to false. The source rectangle for `draw_texture_rec` is computed from the current frame and line indices.

## Key Takeaways

- Grid-based sprite sheets use two indices (column and row) to select frames, computed as `frame_width * current_frame` for X and `frame_height * current_line` for Y in the source rectangle.
- One-shot animations need an active/inactive state to prevent re-triggering during playback and to know when the animation has completed.
- Controlling animation speed by counting render frames before advancing sprite frames decouples animation timing from the render framerate.
