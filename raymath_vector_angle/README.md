# Raymath: Vector Angle

This example demonstrates vector angle calculation using two different modes: the angle between two vectors (using `atan2` for the cross/dot product formulation) and the line angle from a starting point to the mouse position. When you run it, you see vectors drawn from the screen center with a green arc sector showing the measured angle, along with a numeric readout.

## Build and Run

```bash
moon build --target native raymath_vector_angle/
./_build/native/debug/build/raymath_vector_angle/raymath_vector_angle.exe
```

## Controls

- **Spacebar** -- Toggle between Mode 0 (angle between two vectors) and Mode 1 (line angle)
- **Right Mouse Button** -- Move the reference vector V1 (Mode 0 only)
- **Mouse Position** -- Controls V2 in both modes

## What It Demonstrates

- **Vector angle calculation with atan2**: The `vec2_angle` function computes the signed angle between two normalized vectors using `atan2(v1.x * v2.y - v1.y * v2.x, v1.x * v2.x + v1.y * v2.y)`, which gives the cross product and dot product formulation.
- **Line angle calculation**: The `vec2_line_angle` function computes the angle of a line segment relative to the horizontal axis using `-atan2(dy, dx)`.
- **2D vector math utilities**: Implements `vec2_add`, `vec2_sub`, and `vec2_normalize` as standalone helper functions, demonstrating basic 2D vector operations in MoonBit.
- **Visual angle representation**: Uses `draw_circle_sector` to render a filled arc showing the measured angle, with the start angle derived from the reference vector's orientation and the sweep matching the computed angle.

## Public API Reference

### Package `raymath_vector_angle`

> Single-package example.

No public API -- self-contained main function. Helper functions `vec2_add`, `vec2_sub`, `vec2_normalize`, `vec2_angle`, and `vec2_line_angle` are package-level but not exported.

## Architecture

The program initializes a window and defines a center point `v0` at the screen center. In Mode 0, a reference vector `v1` extends from `v0` (repositionable with right-click) and V2 follows the mouse; the angle between their normalized directions is computed and displayed as a green sector. In Mode 1, the angle of the line from `v0` to the mouse position relative to the horizontal axis is shown. Each frame, the angle is calculated, formatted with 2 decimal places using integer/fractional decomposition, and displayed as text alongside the visual arc. The spacebar toggles between modes.

## Key Takeaways

- The `atan2(cross, dot)` formulation gives a signed angle between two 2D vectors, correctly handling all four quadrants without special-case logic.
- MoonBit does not yet have a built-in float formatting function with decimal precision, so manual integer/fractional decomposition (multiplying by 100 and truncating) is a practical workaround.
- `draw_circle_sector` is a versatile raylib function for visualizing angular quantities, taking start and end angles in degrees.
