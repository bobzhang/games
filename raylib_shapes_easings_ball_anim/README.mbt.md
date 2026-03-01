# Easings Ball Animation

This example demonstrates easing functions applied to a ball animation through a multi-state sequence. When you run it, a red ball slides in from the left using elastic easing, then expands with elastic-in easing, then fades out with cubic easing as a green background appears, and finally waits for ENTER to replay.

## Build and Run

```bash
moon build --target native raylib_shapes_easings_ball_anim/
./_build/native/debug/build/raylib_shapes_easings_ball_anim/raylib_shapes_easings_ball_anim.exe
```

## Controls

- **ENTER** -- Replay the animation (after it completes)
- **R** -- Reset the frame counter (restart current animation phase)

## What It Demonstrates

- **Easing functions** -- Three different easing functions are implemented in MoonBit:
  - `ease_elastic_out` -- Elastic overshoot easing for the ball's horizontal slide-in
  - `ease_elastic_in` -- Elastic easing for the ball's radius expansion
  - `ease_cubic_out` -- Smooth cubic easing for the alpha fade-out
- **State machine animation** -- Four states (slide in, expand, fade, wait) driven by a frame counter, demonstrating sequential animation phases.
- **`draw_circle`** and **`fade`** -- Used to render the ball with dynamic radius and transparency.
- **`powf` helper** -- A custom power function bridging MoonBit's `Float` to `@math.pow` via double conversion.

## Public API Reference

### Package `raylib_shapes_easings_ball_anim`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes an 800x450 window and enters a state machine with four phases: State 0 slides the ball from x=-100 to screen center using elastic-out easing over 120 frames. State 1 expands the ball radius from 20 to 520 using elastic-in easing over 200 frames. State 2 fades the ball alpha from 0 to 1 (revealing the green background) using cubic-out easing over 200 frames. State 3 waits for ENTER to reset all values and restart. The easing functions follow the standard signature `(t, b, c, d)` where t=current time, b=start value, c=change, d=duration.

## Key Takeaways

- Easing functions transform linear time progression into natural-feeling motion curves, and they all share a common `(t, b, c, d)` interface that makes them interchangeable.
- A simple integer state machine combined with a frame counter is an effective pattern for sequencing multi-phase animations in a game loop.
- The `powf` and `sinf` helpers show how to bridge MoonBit's Float type with the core math library's Double-based functions.
