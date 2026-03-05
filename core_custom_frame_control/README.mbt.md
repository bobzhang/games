# Custom Frame Control

This example demonstrates how to implement custom frame timing in raylib instead of relying on the built-in `set_target_fps`. A red circle moves across the screen at a constant 200 pixels per second, independent of the frame rate, which the user can adjust dynamically. The current and target FPS are displayed in real time.

## Build and Run

```bash
moon build --target native core_custom_frame_control/
./_build/native/debug/build/core_custom_frame_control/core_custom_frame_control.exe
```

## Controls

- **Space** -- pause/resume circle movement
- **Up arrow** -- increase target FPS by 20
- **Down arrow** -- decrease target FPS by 20

## What It Demonstrates

- `@raylib.poll_input_events()` for manual input polling when using custom frame control (SUPPORT_CUSTOM_FRAME_CONTROL)
- `@raylib.swap_screen_buffer()` for manually flipping the back buffer to the screen
- `@raylib.get_time()` for high-resolution time measurement to compute frame deltas
- `@raylib.wait_time()` for sleeping the remaining frame budget to achieve a target frame rate
- Frame-rate-independent movement using `delta_time` multiplication (200 pixels/sec regardless of FPS)
- Manual frame timing loop: measure update+draw time, compute wait time, sleep, then record the actual delta

## Public API Reference

### Package `core_custom_frame_control`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program bypasses `set_target_fps` entirely and implements its own timing loop. Each iteration: (1) polls input events, (2) updates position using delta time, (3) draws the scene, (4) swaps the screen buffer, (5) measures how long the update+draw took, (6) sleeps for the remaining time to hit the target FPS, and (7) records the actual delta time for the next frame. Vertical grid lines are drawn every 200 pixels to visualize the circle's movement.

## Key Takeaways

- Raylib supports custom frame control via `poll_input_events`, `swap_screen_buffer`, and `wait_time`, giving full control over the rendering loop timing.
- Multiplying movement speed by delta time ensures consistent behavior across any frame rate, which is the standard approach for frame-rate-independent game logic.
- The pattern of measuring elapsed time, sleeping for the remainder, then measuring actual delta is fundamental to game engine timing.
