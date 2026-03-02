# Input Mouse Wheel

This example demonstrates mouse wheel input in raylib. A maroon box is displayed at the center of the screen, and scrolling the mouse wheel moves it up and down. The current Y position is displayed as text.

## Build and Run

```bash
moon build --target native raylib_core_input_mouse_wheel/
./_build/native/debug/build/raylib_core_input_mouse_wheel/raylib_core_input_mouse_wheel.exe
```

## Controls

- **Mouse wheel scroll** -- move the box up (scroll up) or down (scroll down)

## What It Demonstrates

- `@raylib.get_mouse_wheel_move()` to read the mouse wheel scroll delta as a float value (positive for up, negative for down)
- Multiplying the wheel delta by a scroll speed constant to control sensitivity
- `@raylib.draw_rectangle()` to render a simple box at a computed position
- MoonBit string interpolation (`"\{box_position_y}"`) for displaying numeric values as text

## Public API Reference

### Package `raylib_core_input_mouse_wheel`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes a box at the vertical center of the screen. Each frame, the wheel delta is read with `get_mouse_wheel_move`, multiplied by a scroll speed of 4, and subtracted from the box's Y position (subtracting because positive wheel values should move the box up, which decreases Y in screen coordinates). The box and position text are drawn each frame.

## Key Takeaways

- `get_mouse_wheel_move` returns a float representing the wheel delta for the current frame, where positive values typically mean scroll-up and negative means scroll-down.
- The scroll speed multiplier provides a simple way to tune sensitivity without modifying the input reading logic.
- This is the minimal example for integrating mouse wheel input into any scrollable UI or game mechanic.
