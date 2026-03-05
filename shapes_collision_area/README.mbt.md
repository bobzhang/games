# Shapes - Collision Area

This example demonstrates rectangle collision detection and collision area calculation. It features two rectangles -- one moving automatically and one following the mouse -- with visual feedback showing their intersection area. When you run it, you see a gold rectangle bouncing horizontally and a blue rectangle following your mouse, with the collision area highlighted in lime green and its size displayed when they overlap.

## Build and Run

```bash
moon build --target native shapes_collision_area/
./_build/native/debug/build/shapes_collision_area/shapes_collision_area.exe
```

## Controls

- **Mouse**: Move the blue rectangle (Box B)
- **Space**: Toggle pause/resume of the gold rectangle's (Box A) horizontal movement

## What It Demonstrates

- **Rectangle collision detection**: Uses `check_collision_recs` to test whether two `Rectangle` values overlap, returning a boolean result.
- **Collision rectangle computation**: Uses `get_collision_rec` to obtain the intersection `Rectangle` of two overlapping rectangles, providing the exact overlap area.
- **Mouse-following rectangle**: Positions Box B centered on the mouse cursor using `get_mouse_x` and `get_mouse_y`, clamped to screen bounds with an upper limit for the menu bar.
- **Automatic bouncing movement**: Box A moves horizontally at a fixed speed and reverses direction when hitting either screen edge.
- **Visual collision feedback**: The top bar changes from black to red on collision, the intersection area is drawn in lime green, and the collision area (in pixels) is displayed as text.
- **Rectangle immutability pattern**: Since `Rectangle` is immutable in MoonBit, new rectangles are created each frame for position updates rather than modifying fields in place.

## Public API Reference

### Package `shapes_collision_area`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program creates two rectangles: Box A (200x100, auto-moving) and Box B (60x60, mouse-controlled). Each frame, Box A's position advances horizontally with edge bouncing; Box B's position is set to the mouse cursor (clamped to screen bounds and a top menu area). `check_collision_recs` tests for overlap, and if true, `get_collision_rec` computes the intersection rectangle. The scene draws both boxes, the collision area (if any), a status bar that changes color on collision, the "COLLISION!" text, and the computed collision area in pixels. Space toggles Box A's movement. On exit, the window is closed.

## Key Takeaways

- `check_collision_recs` and `get_collision_rec` provide a complete rectangle collision workflow -- detection followed by precise intersection computation.
- Clamping mouse-controlled objects to screen bounds prevents them from moving offscreen, improving usability.
- Displaying collision metrics (area size, visual highlight) is a useful debugging technique applicable to any 2D game with rectangular colliders.
