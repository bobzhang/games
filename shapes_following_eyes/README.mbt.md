# Following Eyes

This example demonstrates mouse-tracking eye animation using trigonometry and collision detection. When you run it, two large eyes are displayed on screen with irises that follow the mouse cursor, constrained to stay within their respective sclera boundaries.

## Build and Run

```bash
moon build --target native shapes_following_eyes/
./_build/native/debug/build/shapes_following_eyes/shapes_following_eyes.exe
```

## Controls

- **Mouse movement** -- The eye irises follow the mouse cursor position

## What It Demonstrates

- **`check_collision_point_circle`** -- Tests whether the mouse position is inside the sclera boundary (minus iris radius) to determine if the iris needs to be clamped.
- **`atan2f` / `cosf` / `sinf`** -- Calculates the angle from the eye center to the mouse, then computes the clamped iris position on the sclera boundary circle.
- **`draw_circle_v`** -- Draws circles (sclera, iris, pupil) at Vector2 positions with different radii and colors.
- **`get_mouse_position`** -- Retrieves the current mouse coordinates each frame for real-time tracking.
- **Layered circle rendering** -- Each eye is composed of three overlapping circles: a large light gray sclera, a medium colored iris (brown for left, dark green for right), and a small black pupil.

## Public API Reference

### Package `shapes_following_eyes`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program places two eye centers 200 pixels apart horizontally, centered on screen. Each frame, the mouse position is read. For each eye, if the mouse is outside the sclera boundary (adjusted by iris radius), the iris position is clamped to the boundary using `atan2f` to find the angle and `cosf`/`sinf` to project onto the circle edge. If the mouse is inside, the iris directly follows the mouse. Drawing renders three circles per eye in back-to-front order: sclera, iris, pupil.

## Key Takeaways

- Constraining a follower point to a circular boundary is a common game pattern: compute the angle with `atan2f`, then project at the maximum allowed distance using `cosf`/`sinf`.
- Layered circle drawing (large background circle, medium foreground, small detail) is a simple but effective technique for creating expressive animated elements.
- `check_collision_point_circle` provides a clean way to test point-in-circle containment before applying clamping logic.
