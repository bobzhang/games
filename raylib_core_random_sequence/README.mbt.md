# Random Sequence

This example demonstrates raylib's `load_random_sequence` function for generating shuffled integer sequences. The sequence is visualized as a colorful bar chart of rectangles with varying heights. The user can shuffle the bars, or add and remove rectangles to change the sequence size.

## Build and Run

```bash
moon build --target native raylib_core_random_sequence/
./_build/native/debug/build/raylib_core_random_sequence/raylib_core_random_sequence.exe
```

## Controls

- **Space** -- shuffle the current sequence (rearrange bars)
- **Up arrow** -- add a rectangle and regenerate the sequence
- **Down arrow** -- remove a rectangle and regenerate the sequence (minimum 4)

## What It Demonstrates

- `@raylib.load_random_sequence()` to generate a shuffled permutation of integers from 0 to N-1
- `@raylib.get_random_value()` to generate random color components for each bar
- `@raylib.measure_text()` to compute text width for right-aligned display
- `@raylib.draw_rectangle_rec()` to draw filled rectangles from `Rectangle` structs
- Mapping integer sequence values to rectangle heights for bar chart visualization
- A custom `draw_text_center_key_help` helper that renders styled key hints with colored underlining

## Public API Reference

### Package `raylib_core_random_sequence`

> Single-package example.

No public API -- self-contained main function. Helper functions `generate_sequence`, `shuffle_sequence`, and `draw_text_center_key_help` are package-private.

## Architecture

The program generates an initial sequence of 20 shuffled integers and maps each value to a rectangle height and a random color. Pressing Space triggers a shuffle that swaps bar positions according to a new random permutation. Pressing Up/Down adjusts the rectangle count and regenerates the entire sequence. The bars are drawn as colored rectangles anchored to the bottom of the display area. Key help text is rendered at the bottom using a custom helper that highlights key names in red.

## Key Takeaways

- `load_random_sequence` provides a ready-made shuffled permutation, useful for randomized orderings without writing a custom shuffle algorithm.
- Mapping sequential integer values to visual properties (height, position) is a common technique for visualizing sorting and permutation algorithms.
- Separating generation and shuffling into distinct functions keeps the code modular and allows easy regeneration when parameters change.
