# Textures: Mouse Painting

This example demonstrates a simple painting application using raylib's render texture feature. When you run it, you see a canvas where you can paint with the mouse using a 23-color palette at the top, adjust brush size with the scroll wheel, erase with right-click, clear the canvas, and save your painting to a PNG file.

## Build and Run

```bash
moon build --target native textures_mouse_painting/
./_build/native/debug/build/textures_mouse_painting/textures_mouse_painting.exe
```

## Controls

- **Left mouse button**: Paint with the selected color
- **Right mouse button**: Erase (paint with background color)
- **Mouse scroll wheel**: Increase/decrease brush size (range 2-50)
- **Left/Right arrow keys**: Cycle through the color palette
- **Click on color rectangles**: Select a color directly
- **C key**: Clear the canvas
- **S key** or **click SAVE button**: Save the painting as `my_amazing_texture_painting.png`

## What It Demonstrates

- **`load_render_texture`** / **`begin_texture_mode`** / **`end_texture_mode`**: Creates an off-screen render target (framebuffer) and draws to it instead of the screen. This is the core technique for accumulating paint strokes across frames.
- **`draw_render_texture_rec`**: Draws the render texture to the screen with a flipped Y-axis (negative height in the source rectangle) to correct OpenGL's inverted coordinate system.
- **`get_render_texture_texture`** / **`load_image_from_texture`**: Retrieves the texture from a render target and converts it back to a CPU image for saving.
- **`image_flip_vertical`**: Corrects the Y-axis flip when saving the render texture as an image.
- **`export_image`**: Saves an image to a PNG file on disk.
- **`check_collision_point_rec`**: Hit-testing the mouse position against color palette rectangles and the save button.
- **`get_mouse_wheel_move`**: Reads the scroll wheel delta for brush size adjustment.
- **`get_gesture_detected`**: Detects touch drag gestures for mobile-friendly painting support.
- **`fade`**: Creates semi-transparent colors for hover effects and the save notification overlay.
- **`draw_rectangle_lines_ex`**: Draws rectangle outlines with a specified line thickness for the selected color highlight and save button.

## Public API Reference

### Package `textures_mouse_painting`

> Single-package example.

No public API -- self-contained main function.

## Architecture

A render texture serves as the persistent canvas. Each frame, if the mouse is pressed, a circle is drawn to the render texture at the mouse position using `begin_texture_mode`/`end_texture_mode`. The main draw pass renders the canvas to the screen (Y-flipped via a negative height in the source rectangle), draws the brush cursor preview, a top panel with 23 color swatches, the selected color highlight, and the save button. Right-click temporarily switches to the background color for erasing and restores the previous color on release. Saving extracts the render texture as an image, flips it vertically, and exports it as PNG. The target framerate is set to 120 FPS for smoother brush strokes.

## Key Takeaways

- Render textures (`RenderTexture`) are raylib's mechanism for persistent off-screen drawing; paint strokes accumulate because the render texture is not cleared each frame.
- When displaying or saving render textures, the Y-axis must be flipped because OpenGL render textures have an inverted vertical origin compared to screen coordinates.
- A higher target FPS (120) produces smoother brush strokes by sampling the mouse position more frequently, reducing gaps between circles.
