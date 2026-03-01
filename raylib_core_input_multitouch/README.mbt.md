# Input Multitouch

This example demonstrates multitouch input handling in raylib. When touching the screen at multiple locations simultaneously, orange circles appear at each touch point, labeled with their index number. Up to 10 simultaneous touch points are supported.

## Build and Run

```bash
moon build --target native raylib_core_input_multitouch/
./_build/native/debug/build/raylib_core_input_multitouch/raylib_core_input_multitouch.exe
```

## Controls

- **Touch screen** -- touch at multiple points simultaneously to see numbered circles appear at each location

## What It Demonstrates

- `@raylib.get_touch_point_count()` to detect how many touch points are currently active
- `@raylib.get_touch_position()` to read the position of each individual touch point by index
- Filtering out zero-coordinate touch points (0, 0) which indicate inactive touch slots
- `@raylib.draw_circle_v()` to draw circles at `Vector2` touch positions
- Pre-allocated array pattern for fixed-capacity touch point tracking

## Public API Reference

### Package `raylib_core_input_multitouch`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program pre-allocates an array of 10 `Vector2` positions (the maximum supported touch points). Each frame, it reads the active touch count via `get_touch_point_count` (clamped to 10) and updates each position with `get_touch_position`. During drawing, only touch points with non-zero coordinates are rendered as orange circles with their index displayed above.

## Key Takeaways

- Raylib's touch API uses indexed touch points, where `get_touch_position(i)` returns the position for the i-th finger, making multitouch handling straightforward.
- A zero-position check filters out inactive touch slots, since (0, 0) is the default for touch points with no active contact.
- This pattern of pre-allocated fixed-size arrays for touch points is common in touch-based applications to avoid per-frame allocations.
