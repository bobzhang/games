# Shaders - Texture Waves

This example demonstrates a wave distortion effect applied to 2D graphics using a fragment shader. The shader displaces pixels in a sinusoidal pattern controlled by frequency, amplitude, and speed parameters. When you run it, you see a blue grid background with a labeled rectangle, all undulating with a continuous wave animation.

## Build and Run

```bash
moon build --target native shaders_texture_waves/
./_build/native/debug/build/shaders_texture_waves/shaders_texture_waves.exe
```

## Controls

No interactive controls -- the wave animation runs automatically.

## What It Demonstrates

- **Wave distortion fragment shader**: Uses a `wave.fs` shader that displaces UV coordinates sinusoidally based on configurable frequency, amplitude, and speed parameters for both X and Y axes.
- **Multiple float uniforms**: Sets seven shader uniforms (`seconds`, `freqX`, `freqY`, `ampX`, `ampY`, `speedX`, `speedY`) plus a vec2 `size` uniform, demonstrating comprehensive shader parameterization.
- **Time-driven animation**: Accumulates elapsed time via `get_frame_time` and sends it to the shader's `seconds` uniform each frame to drive the wave motion.
- **Procedural 2D content under shader**: Draws rectangles, lines (forming a grid), and text all within shader mode, showing that the wave effect applies uniformly to any 2D drawing.

## Public API Reference

### Package `shaders_texture_waves`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads a wave fragment shader and resolves locations for all seven animation parameters plus screen size. Frequency (25.0), amplitude (5.0), and speed (8.0) values are set once at initialization. Each frame, the accumulated time is updated and sent to the shader. All drawing (a blue background rectangle, a grid of vertical and horizontal lines, a sky-blue inner rectangle, and centered text) occurs within shader mode. The wave shader displaces all pixels according to the sine-based formula, creating a uniform undulation across the entire screen. On exit, the shader is unloaded.

## Key Takeaways

- Wave distortion shaders operate by modifying UV coordinates with sine functions, and their behavior is fully controllable through frequency, amplitude, and speed parameters.
- Applying a shader to 2D drawing (rectangles, lines, text) works the same as applying it to textures -- everything within `begin_shader_mode`/`end_shader_mode` is affected.
- Separating shader parameters into individual uniforms provides fine-grained control and makes it easy to animate specific aspects independently.
