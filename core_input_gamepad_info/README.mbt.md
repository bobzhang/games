# Input Gamepad Info

This example demonstrates how to query detailed gamepad information using raylib. It scans up to four gamepads and displays each one's name, axis count, individual axis values, and the state of all 32 possible buttons as a raw data dump on screen.

## Build and Run

```bash
moon build --target native core_input_gamepad_info/
./_build/native/debug/build/core_input_gamepad_info/core_input_gamepad_info.exe
```

## Controls

No interactive controls -- connect a gamepad to see its data displayed automatically.

## What It Demonstrates

- `@raylib.is_gamepad_available()` to check each of the four possible gamepad slots (0 through 3)
- `@raylib.get_gamepad_name()` to retrieve the name string for each connected gamepad
- `@raylib.get_gamepad_axis_count()` to query the number of reported axes
- `@raylib.get_gamepad_axis_movement()` to read the current value of each axis by index
- `@raylib.is_gamepad_button_down()` to poll all 32 button slots and display their binary on/off state
- `@raylib.set_config_flags(@raylib.FlagMsaa4xHint)` to enable anti-aliasing before window creation
- `@raylib.draw_fps()` to show the current frame rate

## Public API Reference

### Package `core_input_gamepad_info`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes an 800x450 window with MSAA enabled and runs at 60 FPS. Each frame, it iterates over gamepad indices 0 through 3. For each available gamepad, it prints the name, axis count, all axis values, and all 32 button states as lines of text. The vertical position is tracked with a running `y` counter to stack all information sequentially.

## Key Takeaways

- Raylib supports up to four simultaneous gamepads, each queryable by index for name, axes, and buttons.
- Iterating over all axis and button indices provides a raw diagnostic view useful for understanding gamepad mappings and debugging input issues.
- This diagnostic-style example is a useful starting point for building gamepad configuration or remapping tools.
