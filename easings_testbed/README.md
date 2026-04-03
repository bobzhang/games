# Easings Testbed

This example implements a visual testbed for 28 different easing functions (plus "None"), allowing you to independently select easing curves for the X and Y axes of a moving ball. When you run it, you see a maroon ball that can be animated along configurable easing paths, with on-screen text showing the current easing names, time, and duration values.

## Build and Run

```bash
moon build --target native easings_testbed/
./_build/native/debug/build/easings_testbed/easings_testbed.exe
```

## Controls

- **Left/Right arrows**: Cycle through easing functions for the X axis
- **Up/Down arrows**: Cycle through easing functions for the Y axis
- **Enter**: Play/pause the animation
- **Space**: Reset the animation
- **T**: Toggle bounded/unbounded time mode
- **Q/W**: Decrease/increase duration (coarse, step of 20)
- **A/S (hold)**: Decrease/increase duration (fine, step of 2)

## What It Demonstrates

- **Easing function implementations**: Provides MoonBit implementations of 28 standard easing functions covering Linear, Sine, Circ, Cubic, Quad, Expo, Back, Bounce, and Elastic families, each with In, Out, and InOut variants.
- **Parametric animation**: Each easing function takes the classic `(t, b, c, d)` parameters (time, begin, change, duration) and returns an interpolated value.
- **Pattern matching dispatch**: Uses a `match` expression in `apply_easing` to dispatch to the correct easing function by index, demonstrating idiomatic MoonBit control flow.
- **Math interop**: Uses `@math.sinf`, `@math.cosf`, and a custom `powf` helper that bridges MoonBit's `Float` and `Double` types via `@math.pow`.
- **Independent X/Y easing**: Allows selecting different easing curves for horizontal and vertical movement simultaneously.

## Public API Reference

### Package `easings_testbed`

> Single-package example.

No public API -- self-contained main function. The following internal helpers are defined:

- `fn powf(base : Float, exp : Float) -> Float` -- Float exponentiation via `@math.pow`.
- `fn sqrtf(x : Float) -> Float` -- Float square root wrapper.
- `let pi : Float` -- Pi constant.
- 28 easing functions following `fn ease_*(t, b, c, d) -> Float` signature: Linear (None/In/Out/InOut), Sine, Circ, Cubic, Quad, Expo, Back, Bounce, and Elastic families.
- `fn apply_easing(index, t, b, c, d) -> Float` -- Dispatches to the selected easing function by index.
- `let easing_names : FixedArray[String]` -- Display names for all 29 easing options.

## Architecture

The program initializes the window and sets up state variables for ball position, time counter, duration, pause state, and selected easing indices for X and Y. Each frame processes keyboard input to change easing selections, adjust duration, toggle pause, or reset. When unpaused, `apply_easing` computes the ball's X and Y positions from the current time and selected easing functions. The ball is drawn as a circle, with HUD text showing current settings and controls.

## Key Takeaways

- Easing functions follow the standard `(t, b, c, d)` signature, making them interchangeable and easy to compose for animation systems.
- MoonBit's `match` expression provides a clean way to dispatch to different easing implementations by index without needing function pointer arrays.
- Bridging between `Float` and `Double` via `to_double()`/`from_double()` is necessary when using `@math.pow` from MoonBit's core library, since the math module operates on `Double`.
