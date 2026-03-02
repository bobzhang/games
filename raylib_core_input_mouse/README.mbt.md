# Input Mouse

This example demonstrates mouse input handling in raylib. A colored circle follows the mouse cursor, and clicking different mouse buttons changes the circle's color. The example supports left, middle, right, side, extra, forward, and back mouse buttons.

## Build and Run

```bash
moon build --target native raylib_core_input_mouse/
./_build/native/debug/build/raylib_core_input_mouse/raylib_core_input_mouse.exe
```

## Controls

- **Mouse movement** -- the ball follows the cursor
- **Left click** -- change ball color to maroon
- **Middle click** -- change ball color to lime
- **Right click** -- change ball color to dark blue
- **Side button** -- change ball color to purple
- **Extra button** -- change ball color to yellow
- **Forward button** -- change ball color to orange
- **Back button** -- change ball color to beige

## What It Demonstrates

- `@raylib.get_mouse_position()` to retrieve the current mouse cursor position as a `Vector2`
- `@raylib.is_mouse_button_pressed()` to detect single-frame mouse button press events
- Mouse button constants: `MouseButtonLeft`, `MouseButtonMiddle`, `MouseButtonRight`, `MouseButtonSide`, `MouseButtonExtra`, `MouseButtonForward`, `MouseButtonBack`
- `@raylib.draw_circle_v()` to draw a circle at a vector position

## Public API Reference

### Package `raylib_core_input_mouse`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program tracks the ball position and color as mutable state. Each frame, the ball position is set to the current mouse position via `get_mouse_position`. A chain of if-else checks tests each mouse button with `is_mouse_button_pressed`, updating the color when a press is detected. The ball is drawn as a circle with radius 40 in the current color.

## Key Takeaways

- `get_mouse_position` returns a `Vector2` that can be used directly with drawing functions like `draw_circle_v`, enabling cursor-following behavior with minimal code.
- Raylib supports seven distinct mouse buttons, covering standard, side, and navigation buttons found on modern mice.
- `is_mouse_button_pressed` fires only on the frame the button transitions from released to pressed, preventing repeated triggers from holding.
