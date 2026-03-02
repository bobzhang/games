# Easings Box Animation

This example demonstrates multiple easing functions applied to a box through a five-state animation sequence. When you run it, a black rectangle drops in from above with elastic easing, then stretches wide with bounce easing, rotates with quadratic easing, stretches tall with circular easing, and finally fades out with sinusoidal easing.

## Build and Run

```bash
moon build --target native raylib_shapes_easings_box_anim/
./_build/native/debug/build/raylib_shapes_easings_box_anim/raylib_shapes_easings_box_anim.exe
```

## Controls

- **SPACE** -- Reset and replay the animation at any time

## What It Demonstrates

- **Five easing functions** implemented in MoonBit:
  - `ease_elastic_out` -- Elastic overshoot for the drop-in motion
  - `ease_bounce_out` -- Bouncing effect for width/height stretching
  - `ease_quad_out` -- Quadratic deceleration for rotation
  - `ease_circ_out` -- Circular easing for vertical stretching
  - `ease_sine_out` -- Sinusoidal easing for alpha fade-out
- **`draw_rectangle_pro`** -- Draws a rectangle with position, size, origin offset, and rotation, enabling pivot-based transformations.
- **State machine** -- Five sequential animation states (0-4), each driving a different property (position, size, rotation, height, alpha) with a different easing curve.

## Public API Reference

### Package `raylib_shapes_easings_box_anim`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes an 800x450 window and runs a five-state animation: State 0 animates the Y position using elastic-out over 120 frames. State 1 animates both width (expanding to screen width) and height (shrinking to 10) using bounce-out over 120 frames. State 2 rotates 270 degrees using quad-out over 240 frames. State 3 stretches height to screen width using circ-out over 120 frames. State 4 fades alpha from 1 to 0 using sine-out over 160 frames. SPACE resets all parameters. The rectangle is drawn using `draw_rectangle_pro` with a centered origin for proper rotation.

## Key Takeaways

- `draw_rectangle_pro` is essential for animated rectangles because it supports an origin offset for rotation around the center rather than the top-left corner.
- Different easing curves create distinct visual personalities -- bounce for playful motion, elastic for springy effects, sine for gentle fades.
- The `sqrtf` helper wraps MoonBit's `Float.sqrt()` method, showing that MoonBit provides direct float operations alongside the core math library.
