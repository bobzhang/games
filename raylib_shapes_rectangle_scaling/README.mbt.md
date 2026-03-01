# Rectangle Scaling

This example demonstrates interactive rectangle scaling by dragging its bottom-right corner. When you run it, you see a green semi-transparent rectangle that can be resized by clicking and dragging a small triangular handle at its bottom-right corner.

## Build and Run

```bash
moon build --target native raylib_shapes_rectangle_scaling/
./_build/native/debug/build/raylib_shapes_rectangle_scaling/raylib_shapes_rectangle_scaling.exe
```

## Controls

- **Left mouse button (drag bottom-right corner)** -- Scale the rectangle by dragging the resize handle

## What It Demonstrates

- **`check_collision_point_rec`** -- Detects when the mouse is hovering over the small scale handle region at the rectangle's bottom-right corner.
- **`draw_rectangle_rec`** -- Draws the main green rectangle with semi-transparency using `fade`.
- **`draw_rectangle_lines_ex`** -- Draws a red outline around the rectangle when the scale handle is active.
- **`draw_triangle`** -- Renders the triangular resize handle indicator at the bottom-right corner.
- **Resize interaction pattern** -- The scale handle is a small rectangular region; when clicked, the rectangle's width and height are set to the mouse position minus the rectangle's origin, with minimum and maximum clamping.

## Public API Reference

### Package `raylib_shapes_rectangle_scaling`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program creates a rectangle at position (100, 100) with initial size 200x80. Each frame, a scale region rectangle is computed at the bottom-right corner (sized by `mouse_scale_mark_size`). If the mouse enters this region, the visual feedback activates (red outline and triangle handle). Clicking enters scale mode, where each frame updates the rectangle width and height to `mouse.x - rec_x` and `mouse.y - rec_y` respectively, clamped to minimum (mark size) and maximum (screen bounds) values. Releasing the mouse button exits scale mode.

## Key Takeaways

- A resize handle can be implemented as a small collision rectangle at a corner, with the resize calculation being simply `mouse_position - origin_position`.
- Visual feedback (outline color change, handle indicator) is important for communicating interactive affordances to the user.
- Clamping both minimum and maximum size prevents the rectangle from becoming too small to interact with or extending beyond the screen.
