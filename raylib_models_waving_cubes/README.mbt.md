# Models: Waving Cubes

This example demonstrates a visually striking animated 3D scene where a grid of colored cubes waves and pulses using time-based sinusoidal functions. When you run it, you see a 15x15x15 grid of cubes that continuously change size, position, and spacing in a wave-like pattern, with rainbow HSV coloring based on each cube's grid position. The camera automatically orbits the scene.

## Build and Run

```bash
moon build --target native raylib_models_waving_cubes/
./_build/native/debug/build/raylib_models_waving_cubes/raylib_models_waving_cubes.exe
```

## Controls

No interactive controls -- runs automatically. The camera orbits the scene using a time-driven circular path.

## What It Demonstrates

- **Time-based animation**: Uses `@raylib.get_time()` to drive all animation, computing a global scale factor with `sin(time)` and per-cube scatter offsets with `sinf(block_scale * 20 + time * 4)` to create a fluid wave effect.
- **Procedural color generation**: Each cube's color is determined by `color_from_hsv` with the hue derived from the sum of its grid indices `(x + y + z) * 18 % 360`, producing a smooth rainbow gradient across the 3D grid.
- **Camera animation without input**: Instead of using raylib's built-in camera modes, the camera position is computed directly from time using `cos(camera_time)` and `sin(camera_time)` to orbit at a fixed height, demonstrating manual camera path control.
- **Triple-nested loop rendering**: A 15x15x15 grid (3,375 cubes) is drawn each frame using nested `for` loops, with each cube's position, size, and color computed procedurally from its indices and the current time.

## Public API Reference

### Package `raylib_models_waving_cubes`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes an 800x450 window with a camera positioned to view the full cube grid. Each frame, the global time drives two calculations: a scale factor that controls overall cube spacing and size, and per-cube scatter offsets that create the wave effect. The camera position is updated by computing new x/z coordinates on a circle. The draw phase iterates through all 15x15x15 grid positions, computing each cube's world position (including scatter), HSV color, and size before calling `draw_cube`. The FPS counter is drawn as a 2D overlay. On exit, `close_window` cleans up.

## Key Takeaways

- Combining global time-based scaling with per-element phase offsets (based on grid position) creates compelling wave and ripple effects across large groups of objects.
- HSV color space is ideal for procedural rainbow coloring -- by varying only the hue component based on position, you get smooth color transitions without manual RGB interpolation.
- Even without user input, time-driven camera animation can create engaging visual demonstrations by computing camera position from trigonometric functions.
