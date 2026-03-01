# MoonBit Raylib Demo

This example is a comprehensive 2D shapes and input demonstration that showcases a variety of raylib drawing primitives and input handling in MoonBit. When you run it, you see a movable maroon ball, a mouse crosshair connected to the ball by a line, a gradient rectangle, a filled triangle, a rounded rectangle, a hexagonal polygon, and an FPS counter -- all in a resizable window.

## Build and Run

```bash
moon build --target native raylib_demo/
./_build/native/debug/build/raylib_demo/raylib_demo.exe
```

## Controls

- **Arrow keys / WASD**: Move the ball around the screen
- **Mouse**: Crosshair follows the cursor; a line connects the ball to the mouse

## What It Demonstrates

- **Window configuration**: Uses `@raylib.set_config_flags(@raylib.FlagWindowResizable)` to create a resizable window before initialization.
- **Frame-rate-independent movement**: Reads `@raylib.get_frame_time()` (delta time) to move the ball at a consistent speed regardless of frame rate.
- **Input handling**: Demonstrates both keyboard input (`is_key_down` for continuous movement) and mouse input (`get_mouse_position` for crosshair tracking).
- **Boundary clamping**: Keeps the ball within screen bounds using `@raylib.get_screen_width()` and `@raylib.get_screen_height()`, which correctly handle window resizing.
- **2D drawing primitives**: Showcases `draw_circle_v`, `draw_circle_lines_v`, `draw_line_ex`, `draw_line_v`, `draw_rectangle`, `draw_rectangle_gradient_h`, `draw_rectangle_lines`, `draw_rectangle_rounded`, `draw_rectangle_rounded_lines`, `draw_triangle`, `draw_triangle_lines`, `draw_poly`, `draw_poly_lines`, and `draw_fps`.
- **Color utilities**: Uses `@raylib.fade` to apply alpha transparency to colors.

## Public API Reference

### Package `raylib_demo`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program sets the resizable window flag, initializes an 800x600 window at 60 FPS, and enters the main loop. Each frame reads delta time and keyboard state to update the ball position, clamps it to the screen boundaries, reads the mouse position, then draws a rich set of 2D shapes including the ball, crosshair, connecting line, gradient rectangle, triangle, rounded rectangle, and polygon. Cleanup calls `close_window`.

## Key Takeaways

- Using `get_frame_time()` for delta-time-based movement ensures consistent behavior across different hardware and frame rates.
- Setting `FlagWindowResizable` before `init_window` and using `get_screen_width`/`get_screen_height` dynamically makes the application responsive to window resizing.
- Raylib provides a rich set of 2D drawing primitives that are straightforward to use from MoonBit, including filled shapes, outlines, gradients, and rounded rectangles.
