# Input Keys

This example demonstrates basic keyboard input handling in raylib. A maroon circle is drawn at the center of the screen and can be moved in any direction using the arrow keys.

## Build and Run

```bash
moon build --target native raylib_core_input_keys/
./_build/native/debug/build/raylib_core_input_keys/raylib_core_input_keys.exe
```

## Controls

- **Arrow keys (Up/Down/Left/Right)** -- move the ball by 2 pixels per frame in the corresponding direction

## What It Demonstrates

- `@raylib.is_key_down()` to check if a specific key is currently held down (continuous input, not single-press events)
- Key constants: `KeyRight`, `KeyLeft`, `KeyUp`, `KeyDown`
- `@raylib.Vector2::new()` to create position vectors
- `@raylib.draw_circle_v()` to draw a circle at a `Vector2` position
- Simple per-frame position updates for smooth, continuous movement

## Public API Reference

### Package `raylib_core_input_keys`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes a ball position at the screen center. Each frame, it checks four arrow key states with `is_key_down` and adjusts the position by 2 pixels in the pressed direction. The ball is then drawn as a maroon circle with radius 50. Since `is_key_down` reports held state (not just press events), holding a key produces smooth continuous movement.

## Key Takeaways

- `is_key_down` returns true every frame a key is held, making it ideal for continuous movement, while `is_key_pressed` fires only once per press.
- MoonBit's immutable `Vector2` values are replaced each frame rather than mutated, reflecting functional-style state updates.
- This is the simplest possible keyboard input example and serves as a good starting point for understanding raylib input in MoonBit.
