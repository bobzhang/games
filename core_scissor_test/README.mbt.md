# Scissor Test

This example demonstrates raylib's scissor mode rendering, where only pixels inside a defined rectangular region are drawn. A 300x300 scissor area follows the mouse cursor, revealing a red background and hidden text underneath. The scissor test can be toggled on and off.

## Build and Run

```bash
moon build --target native core_scissor_test/
./_build/native/debug/build/core_scissor_test/core_scissor_test.exe
```

## Controls

- **Mouse movement** -- move the scissor rectangle around the screen
- **S** -- toggle scissor mode on/off

## What It Demonstrates

- `@raylib.begin_scissor_mode()` / `@raylib.end_scissor_mode()` to restrict rendering to a rectangular area defined by position and size
- `@raylib.get_mouse_x()` and `@raylib.get_mouse_y()` to center the scissor area on the cursor
- `@raylib.is_key_pressed(@raylib.KeyS)` to toggle a boolean flag
- `@raylib.draw_rectangle_lines_ex()` to draw the scissor area outline regardless of scissor mode
- The concept that draw calls between `begin_scissor_mode` and `end_scissor_mode` are clipped to the scissor rectangle

## Public API Reference

### Package `core_scissor_test`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program tracks a boolean `scissor_mode` flag and computes the scissor rectangle centered on the mouse each frame. If scissor mode is enabled, `begin_scissor_mode` is called before drawing a full-screen red rectangle and text. Only the portion inside the 300x300 scissor area is visible. The scissor outline is always drawn outside the scissor region so it remains visible even when scissor mode is active.

## Key Takeaways

- Scissor mode is a GPU-level clipping feature that discards pixels outside the defined rectangle, useful for UI clipping, reveal effects, and performance optimization.
- The scissor area can be updated every frame to follow the mouse or any other dynamic position.
- Drawing the scissor outline outside the `begin/end_scissor_mode` block ensures it is always visible, demonstrating that scissor mode only affects draw calls within its scope.
