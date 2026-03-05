# Easings Rectangle Array

This example demonstrates easing functions applied to a grid of rectangles that simultaneously shrink and rotate. When you run it, a 16x9 grid of red rectangles smoothly collapses to nothing while spinning 360 degrees, then waits for SPACE to replay.

## Build and Run

```bash
moon build --target native shapes_easings_rectangle_array/
./_build/native/debug/build/shapes_easings_rectangle_array/shapes_easings_rectangle_array.exe
```

## Controls

- **SPACE** -- Replay the animation (after it completes)

## What It Demonstrates

- **`ease_circ_out`** -- Circular easing applied uniformly to both width and height of all 144 rectangles, creating a smooth shrinking effect.
- **`ease_linear_in`** -- Linear interpolation for rotation, providing constant angular velocity while the rectangles shrink.
- **`draw_rectangle_pro`** -- Draws each rectangle with rotation around its center origin point.
- **`FixedArray` for parallel arrays** -- Uses four `FixedArray[Float]` arrays (x, y, width, height) to store the state of all rectangles, demonstrating efficient fixed-size array usage in MoonBit.
- **Grid layout computation** -- Positions are pre-calculated using nested loops for a uniform grid.

## Public API Reference

### Package `shapes_easings_rectangle_array`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program creates a 16x9 grid of 50x50 rectangles filling the 800x450 window. During state 0, each frame increments a counter and applies `ease_circ_out` to shrink all rectangle widths and heights from 50 to 0 over 240 frames, while `ease_linear_in` rotates them 360 degrees. When all rectangles reach zero size, the program transitions to state 1 and waits for SPACE to reset. Each rectangle is drawn with `draw_rectangle_pro` using its center as the origin for centered rotation.

## Key Takeaways

- Applying the same easing function to many objects simultaneously creates visually coordinated animations without per-object timing logic.
- `FixedArray` is appropriate when the number of elements is known at initialization and does not change, providing predictable memory usage.
- Combining two different easing curves (circular for size, linear for rotation) on the same objects produces interesting compound motion effects.
