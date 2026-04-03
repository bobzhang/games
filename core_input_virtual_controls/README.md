# Input Virtual Controls

This example demonstrates how to implement on-screen virtual D-pad controls for touch devices using raylib. Four circular buttons are drawn in a D-pad arrangement, and touching or clicking near them moves a player rectangle in the corresponding direction. The controls work with both touch input and mouse input.

## Build and Run

```bash
moon build --target native core_input_virtual_controls/
./_build/native/debug/build/core_input_virtual_controls/core_input_virtual_controls.exe
```

## Controls

- **Touch/click** the on-screen D-pad circles to move the player:
  - **X** (top) -- move up
  - **Y** (left) -- move left
  - **B** (right) -- move right
  - **A** (bottom) -- move down

## What It Demonstrates

- `@raylib.get_touch_point_count()` to detect whether touch input is available and choose between touch and mouse input
- `@raylib.get_touch_x()` / `@raylib.get_touch_y()` to read touch coordinates
- `@raylib.get_mouse_x()` / `@raylib.get_mouse_y()` as fallback input when no touch is active
- `@raylib.get_frame_time()` for frame-rate-independent movement (50 pixels/second)
- Manhattan distance hit testing for circular button colliders
- MoonBit `match` expression for clean directional input handling

## Public API Reference

### Package `core_input_virtual_controls`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program defines four circle colliders arranged in a D-pad pattern (up, left, right, down) around a center point. Each frame, it reads the input position (touch if available, otherwise mouse) and tests Manhattan distance against each collider. If a collider is hit, the corresponding direction index is set. A `match` expression maps the direction index to player position updates, multiplied by `get_frame_time()` for smooth movement. The D-pad circles and player rectangle are drawn each frame.

## Key Takeaways

- Virtual on-screen controls can be implemented by placing invisible colliders and testing input proximity, without requiring any UI framework.
- Using `get_touch_point_count` to choose between touch and mouse input makes the same code work on both mobile and desktop platforms.
- Manhattan distance (`|dx| + |dy|`) is a fast approximation for circular hit testing that works well for D-pad-sized buttons.
