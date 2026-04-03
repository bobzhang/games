# Textures: Sprite Button

This example demonstrates creating an interactive button from a sprite sheet with three visual states (normal, hover, pressed) and a sound effect on click. When you run it, you see a button centered on screen that changes appearance as you hover over and click it, playing a sound when released.

## Build and Run

```bash
moon build --target native textures_sprite_button/
./_build/native/debug/build/textures_sprite_button/textures_sprite_button.exe
```

## Controls

- **Mouse hover**: Changes button to the hover state
- **Left mouse button (held)**: Changes button to the pressed state
- **Left mouse button (released while hovering)**: Triggers the button action and plays a sound effect

## What It Demonstrates

- **Sprite-based UI buttons**: A single texture containing three vertically stacked frames (normal, hover, pressed) is used to render different button states by adjusting the source rectangle's Y offset.
- **`check_collision_point_rec`**: Tests whether the mouse position is within the button's bounding rectangle for hover detection.
- **`draw_texture_rec`**: Draws the appropriate button frame by selecting the source rectangle based on `btn_state` (0=normal, 1=hover, 2=pressed).
- **`init_audio_device`** / **`load_sound`** / **`play_sound`**: Initializes audio, loads a WAV sound effect, and plays it on button release.
- **`is_mouse_button_down`** / **`is_mouse_button_released`**: Distinguishes between holding and releasing the mouse for pressed vs. click-action states.

## Public API Reference

### Package `textures_sprite_button`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The button texture (224x318, 3 frames of 106 pixels each) is loaded along with a button click WAV sound. Each frame, the mouse position is checked against the button bounds using `check_collision_point_rec`. If hovering, `btn_state` is set to 1 (hover) or 2 (pressed) depending on mouse button state. When the mouse is released while hovering, `btn_action` triggers and the sound plays. The source rectangle's Y offset is computed as `btn_state * frame_height` to select the correct visual frame. On exit, the texture, sound, and audio device are properly cleaned up.

## Key Takeaways

- A vertically stacked sprite sheet with one frame per button state is a common pattern for implementing UI buttons without a GUI framework.
- Separating button state detection (hover/press) from button action (release) provides proper click behavior where the action fires only on release.
- Combining `check_collision_point_rec` with mouse state queries is the standard raylib approach for interactive UI elements.
