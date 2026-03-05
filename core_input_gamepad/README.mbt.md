# Input Gamepad

This example demonstrates raylib's gamepad input API by rendering a visual gamepad representation on screen. When a gamepad is connected, buttons light up when pressed, analog sticks move their visual indicators, and trigger values fill progress bars. Detected axis values and button presses are shown as text.

## Build and Run

```bash
moon build --target native core_input_gamepad/
./_build/native/debug/build/core_input_gamepad/core_input_gamepad.exe
```

## Controls

- **Left/Right arrow keys** -- switch between gamepads (gamepad index 0, 1, 2, ...)
- **Gamepad buttons/sticks/triggers** -- interact to see visual feedback on screen

## What It Demonstrates

- `@raylib.set_config_flags(@raylib.FlagMsaa4xHint)` to enable 4x multi-sample anti-aliasing before window creation
- `@raylib.is_gamepad_available()` to check if a specific gamepad index is connected
- `@raylib.get_gamepad_name()` to retrieve the gamepad's human-readable name
- `@raylib.get_gamepad_axis_movement()` to read analog values for each axis (left stick X/Y, right stick X/Y, left/right triggers)
- `@raylib.get_gamepad_axis_count()` to query how many axes the gamepad reports
- `@raylib.is_gamepad_button_down()` to test individual button states (face buttons, d-pad, shoulders, thumbsticks, middle buttons)
- `@raylib.get_gamepad_button_pressed()` to detect which button was just pressed this frame
- Visual feedback with `draw_circle`, `draw_rectangle`, and `draw_rectangle_rounded` to render a gamepad diagram

## Public API Reference

### Package `core_input_gamepad`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program creates an 800x450 window with MSAA enabled. Each frame, it reads the selected gamepad's state: axis values for both sticks and triggers, and button states for all standard gamepad buttons. A stylized gamepad is drawn using basic shapes (rounded rectangles for the body, circles for buttons and sticks, rectangles for d-pad and triggers). Active buttons are highlighted in color, and stick positions are offset based on axis values.

## Key Takeaways

- Raylib provides a unified gamepad API that works across platforms, with support for multiple simultaneous gamepads selected by index.
- Gamepad axes return floating-point values (typically -1.0 to 1.0 for sticks, -1.0 to 1.0 for triggers), which can be mapped directly to visual positions.
- Building a visual gamepad diagram with basic shape primitives is an effective way to debug and verify input handling.
