# Random Values

This example demonstrates raylib's `get_random_value` function for generating random integers within a specified range. Every two seconds, a new random number between -8 and 5 is generated and displayed in large text on screen.

## Build and Run

```bash
moon build --target native raylib_core_random_values/
./_build/native/debug/build/raylib_core_random_values/raylib_core_random_values.exe
```

## Controls

No interactive controls -- runs automatically, generating a new value every 2 seconds.

## What It Demonstrates

- `@raylib.get_random_value(min, max)` to generate a random integer within an inclusive range (including negative values)
- Frame counter pattern for time-based events: counting to 120 frames at 60 FPS equals 2 seconds
- `@raylib.draw_text()` with different font sizes for descriptive text and the large random value display
- MoonBit string interpolation (`"\{rand_value}"`) for converting integers to display strings

## Public API Reference

### Package `raylib_core_random_values`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program maintains a frame counter and a random value. Each frame, the counter increments. When the counter reaches 120 (2 seconds at 60 FPS), a new random value is generated with `get_random_value(-8, 5)` and the counter resets. The draw phase displays the current value in large light gray text with an explanatory message above it.

## Key Takeaways

- `get_random_value` accepts negative ranges, returning any integer in `[min, max]` inclusive.
- The frame counter approach is the simplest way to implement periodic events in a fixed-FPS game loop, though delta-time-based timing is more robust for variable frame rates.
- This is the minimal example for using raylib's built-in random number generation.
