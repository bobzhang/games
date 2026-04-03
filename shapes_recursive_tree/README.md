# Recursive Tree

This example demonstrates generating and rendering a fractal binary tree with configurable parameters. When you run it, you see a red branching tree structure growing upward from the bottom of the screen, with raygui sliders to adjust the branch angle, length, decay rate, depth, thickness, and an option to render with Bezier curves.

## Build and Run

```bash
moon build --target native shapes_recursive_tree/
./_build/native/debug/build/shapes_recursive_tree/shapes_recursive_tree.exe
```

## Controls

- **Raygui sliders** -- Adjust angle (0-180), length (12-240), decay (0.1-0.78), depth (1-10), and thickness (1-8)
- **Raygui checkbox** -- Toggle Bezier curve rendering for branches

## What It Demonstrates

- **Fractal tree generation** -- Each branch spawns two child branches at +/- theta from its direction, with length reduced by a decay factor, producing a binary tree structure up to a configurable depth.
- **`draw_line_ex`** and **`draw_line_bezier`** -- Branches are rendered as either straight thick lines or smooth Bezier curves, toggled by a checkbox.
- **Iterative tree construction** -- Rather than using recursion, branches are generated iteratively by processing an array and appending new branches, bounded by `max_branches` (2^depth).
- **`sinf` / `cosf`** -- Calculates branch endpoint positions from the parent endpoint using angle and length.
- **Raygui controls** -- Five `gui_slider_bar` widgets and one `gui_check_box` provide real-time parameter adjustment.

## Public API Reference

### Package `shapes_recursive_tree`

> Single-package example.

No public API -- self-contained main function.

## Architecture

Each frame, the tree is regenerated from scratch. Starting with a single trunk branch from the bottom center going upward, the program iterates through the branches array. For each branch with sufficient length, two child branches are computed at +theta and -theta from the parent's angle, with length multiplied by the decay factor. This continues until the array reaches `max_branches` (2^depth) or branches become too short. All branches are then drawn as either straight lines (`draw_line_ex`) or Bezier curves (`draw_line_bezier`). A raygui panel on the right provides interactive controls. The `Branch` struct stores start/end positions, angle, and length.

## Key Takeaways

- Fractal trees can be generated iteratively by appending child branches to an array rather than using explicit recursion, which avoids stack depth concerns.
- The decay factor controls tree density: values near 0.78 produce dense canopies, while values near 0.1 produce sparse, quickly-terminating trees.
- Switching between `draw_line_ex` and `draw_line_bezier` for the same geometry dramatically changes the visual character, from angular to organic.
