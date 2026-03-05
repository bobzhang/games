# Core Basic Window

This is the minimal raylib example -- the "hello world" of MoonBit game development with raylib. When you run it, a window opens displaying the text "Congrats! You created your first window!" on a white background. It demonstrates the absolute minimum code needed to create a window and render text.

## Build and Run

```bash
moon build --target native core_basic_window/
./_build/native/debug/build/core_basic_window/core_basic_window.exe
```

## Controls

No interactive controls -- the window simply displays a message.

## What It Demonstrates

- **`@raylib.init_window`** -- Creating a window with specified width, height, and title.
- **`@raylib.close_window`** -- Properly closing the window and releasing OpenGL resources.
- **`@raylib.set_target_fps`** -- Setting the target frame rate (60 FPS).
- **`@raylib.window_should_close`** -- The main loop exit condition, which returns `true` when the user closes the window or presses Escape.
- **`@raylib.begin_drawing`** and **`@raylib.end_drawing`** -- The required bracket for all drawing operations in a frame.
- **`@raylib.clear_background`** -- Clearing the framebuffer to a solid color (`raywhite`) at the start of each frame.
- **`@raylib.draw_text`** -- Basic text rendering with position, size, and color parameters.

## Public API Reference

### Package `core_basic_window`

> Single-package example.

No public API -- self-contained main function.

## Architecture

1. **Initialization** -- `init_window` creates the window, `set_target_fps` sets the frame rate.
2. **Main loop** -- `window_should_close` controls the loop. Each frame calls `begin_drawing`, `clear_background`, `draw_text`, and `end_drawing`.
3. **Cleanup** -- `close_window` releases all resources.

## Key Takeaways

- Every raylib application follows the same structure: `init_window` -> main loop with `begin_drawing`/`end_drawing` -> `close_window`.
- The `window_should_close` function handles both the window close button and the Escape key by default.
- This is the starting template for any raylib application in MoonBit -- all other examples build on this foundation.
