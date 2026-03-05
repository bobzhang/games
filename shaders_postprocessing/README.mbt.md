# Shaders - Postprocessing

This example demonstrates full-screen postprocessing shader effects applied to a 3D scene. It renders a simple scene with colored cubes to a render texture, then draws that texture to the screen through one of several selectable fragment shaders. When you run it, you see a 3D scene with cubes on a grid, processed through effects like grayscale, blur, or cross-hatching that you can cycle through with arrow keys.

## Build and Run

```bash
moon build --target native shaders_postprocessing/
./_build/native/debug/build/shaders_postprocessing/shaders_postprocessing.exe
```

## Controls

- **Left/Right arrow keys**: Cycle through postprocessing shaders (Grayscale, Blur, Cross-Hatching)
- Camera orbits automatically around the scene

## What It Demonstrates

- **Render-to-texture pipeline**: Uses `load_render_texture` to create an offscreen framebuffer, renders the 3D scene into it with `begin_texture_mode`/`end_texture_mode`, then draws the result to the screen.
- **Full-screen postprocessing**: Applies fragment shaders (grayscale, blur, cross-hatching) to the render texture by drawing it inside `begin_shader_mode`/`end_shader_mode`.
- **Render texture Y-flip**: Compensates for OpenGL's bottom-left origin by using a negative height in `draw_render_texture_rec` to flip the texture vertically.
- **Multiple shader management**: Loads an array of shaders and cycles through them at runtime, demonstrating how to swap postprocessing effects dynamically.
- **Orbital camera**: Uses `update_camera` with `CameraOrbital` mode for automatic scene rotation.

## Public API Reference

### Package `shaders_postprocessing`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes a window with MSAA, sets up an orbital 3D camera, loads three postprocessing fragment shaders, and creates a render texture at screen resolution. Each frame follows a two-pass rendering approach: first, the 3D scene (cubes, wireframes, grid) is rendered into the offscreen render texture; second, that render texture is drawn to the screen through the currently selected shader. Arrow keys cycle the active shader index with wrapping. On exit, all shaders and the render texture are unloaded.

## Key Takeaways

- The render-to-texture then draw-with-shader pattern is the standard approach for full-screen postprocessing in raylib, applicable to any effect (blur, bloom, color grading, etc.).
- Render textures in OpenGL have inverted Y coordinates compared to screen space, requiring a vertical flip when drawing them to the screen.
- Swapping between multiple loaded shaders at runtime is trivial -- just change which shader is active in `begin_shader_mode`.
