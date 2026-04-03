# Core 2D Camera Mouse Zoom

This example demonstrates two different mouse-based zoom modes for a 2D camera: scroll wheel zoom and mouse-drag zoom. When you run it, you see a grid of lines with a reference circle, and you can pan by dragging and zoom using either the mouse wheel or right-click drag, with the zoom centered on the mouse cursor position.

## Build and Run

```bash
moon build --target native core_2d_camera_mouse_zoom/
./_build/native/debug/build/core_2d_camera_mouse_zoom/core_2d_camera_mouse_zoom.exe
```

## Controls

- **1** -- Select mouse wheel zoom mode
- **2** -- Select mouse move zoom mode
- **Left Mouse Button (drag)** -- Pan the camera
- **Mouse Wheel** (mode 1) -- Zoom in/out centered on cursor
- **Right Mouse Button (press + drag)** (mode 2) -- Zoom in/out based on horizontal mouse movement

## What It Demonstrates

- **`@raylib.get_screen_to_world_2d`** -- Converting mouse screen coordinates to world coordinates, which is essential for implementing zoom-to-cursor behavior.
- **`@raylib.get_mouse_delta`** -- Getting the frame-to-frame mouse movement for smooth panning and drag-based zooming.
- **`@raylib.get_mouse_wheel_move`** -- Reading mouse wheel input for scroll-based zooming.
- **Zoom-to-cursor technique** -- When zooming, the camera offset is set to the current mouse position and the target is set to the corresponding world position. This ensures the point under the cursor stays fixed during zoom operations.
- **Two zoom modes** -- Mode 0 uses the mouse wheel with exponential scaling; mode 1 uses right-click horizontal drag with continuous scaling.
- **Grid rendering** -- A 101x101 line grid provides a visual reference for understanding camera transformations, with the center lines drawn in a darker color.

## Public API Reference

### Package `core_2d_camera_mouse_zoom`

> Single-package example.

No public API -- self-contained main function.

## Architecture

1. **Initialization** -- Window is created and a Camera2D is set up with identity transform (offset at origin, zoom 1.0).
2. **Main loop** -- Each frame processes input based on the active zoom mode. Panning always works via left-click drag (mouse delta divided by zoom). In wheel mode, zooming adjusts the scale factor based on wheel movement. In drag mode, right-click horizontal movement adjusts zoom. Both modes use the screen-to-world conversion to keep the cursor position stable during zoom. A grid, reference circle, and mouse coordinates are drawn.
3. **Cleanup** -- Window is closed.

## Key Takeaways

- Zoom-to-cursor requires updating both the camera offset (to the mouse screen position) and the camera target (to the corresponding world position) before applying the zoom factor.
- `get_screen_to_world_2d` is the key function for converting between screen and world coordinate systems, which is fundamental for interactive 2D camera controls.
- Clamping zoom values (0.125 to 64.0 in this example) prevents numerical instability and unusable zoom levels.
