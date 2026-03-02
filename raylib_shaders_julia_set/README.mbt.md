# Shaders: Julia Set

This example demonstrates real-time rendering and interactive exploration of Julia set fractals using a fragment shader. When you run it, you see a colorful fractal pattern that can be zoomed, panned, and animated by changing the complex constant parameter. Six preset points of interest are provided for interesting Julia set variations.

## Build and Run

```bash
moon build --target native raylib_shaders_julia_set/
./_build/native/debug/build/raylib_shaders_julia_set/raylib_shaders_julia_set.exe
```

## Controls

- **1-6 Keys** -- Select different Julia set points of interest
- **Left Mouse Button (hold)** -- Zoom in toward cursor position
- **Right Mouse Button (hold)** -- Zoom out from cursor position
- **Left/Right Arrows** -- Increase/decrease animation speed of the c parameter
- **Spacebar** -- Stop c parameter animation
- **R Key** -- Reset zoom and offset to defaults
- **F1 Key** -- Toggle control hints display

## What It Demonstrates

- **Julia set fragment shader**: Loads `julia_set.fs` which computes the Julia set iteration `z = z^2 + c` for each pixel, coloring based on escape iteration count. The complex constant `c`, zoom level, and viewport offset are all controlled by shader uniforms.
- **Interactive fractal exploration**: Implements zoom (multiplicative scaling each frame while mouse is held), pan (velocity-based offset driven by mouse position relative to screen center), and preset selection for the `c` parameter.
- **Animated fractal parameter**: Automatically increments both `c.x` and `c.y` at a configurable speed (adjustable with arrow keys), causing the fractal pattern to morph continuously.
- **Render-to-texture with shader**: Renders to a render texture first, then draws it to the screen with the Julia set shader applied, following the standard post-processing pattern.
- **Multiple shader uniform types**: Demonstrates passing `Vec2` (c parameter, offset) and `Float` (zoom) uniforms to the shader, updated every frame.

## Public API Reference

### Package `raylib_shaders_julia_set`

> Single-package example.

No public API -- self-contained main function. The `float_to_bytes` and `vec2_to_bytes` helpers are package-level but not exported.

## Architecture

The program initializes a window, loads the Julia set shader and a render texture, and sets initial values for the `c` parameter, zoom, and offset uniforms. Six preset `Vector2` values define interesting Julia set constants. Each frame, input is processed: number keys switch presets, mouse buttons control zoom with velocity-based panning, arrow keys adjust animation speed, and R resets the view. The `c` parameter is animated by adding a small increment each frame based on the speed setting. A black rectangle is drawn into the render texture, then the render texture is drawn to the screen within shader mode. Optional control hints are overlaid as text. On exit, the shader and render texture are unloaded.

## Key Takeaways

- Julia sets are ideal for GPU computation because each pixel can be evaluated independently, making the fragment shader approach both natural and highly parallel.
- Combining multiplicative zoom with velocity-based panning (where velocity depends on cursor distance from center) creates an intuitive fractal navigation experience.
- Pre-defined points of interest help users quickly find visually striking regions of the Julia set parameter space, which is vast and mostly empty.
