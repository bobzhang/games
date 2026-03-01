# Shaders - Shapes and Textures

This example demonstrates applying a custom fragment shader selectively to 2D shapes. It draws various shapes (circles, rectangles, triangles, polygons) both with and without a grayscale shader active, showing how `begin_shader_mode`/`end_shader_mode` can be toggled to affect only specific draw calls. When you run it, you see three columns of shapes: the left and right columns in normal colors, and the center column rendered in grayscale.

## Build and Run

```bash
moon build --target native raylib_shaders_shapes_textures/
./_build/native/debug/build/raylib_shaders_shapes_textures/raylib_shaders_shapes_textures.exe
```

## Controls

No interactive controls -- runs automatically.

## What It Demonstrates

- **Selective shader application to 2D shapes**: Shows that `begin_shader_mode`/`end_shader_mode` only affects draw calls between them, allowing a mix of shader-processed and default-rendered shapes in the same frame.
- **Variety of 2D shape drawing functions**: Uses `draw_circle`, `draw_circle_gradient`, `draw_circle_lines`, `draw_rectangle`, `draw_rectangle_gradient_h`, `draw_rectangle_lines`, `draw_triangle`, `draw_triangle_lines`, and `draw_poly` to showcase raylib's 2D shape primitives.
- **Grayscale fragment shader**: Loads a simple `grayscale.fs` shader that converts colored pixels to grayscale, applied to shapes just like it would be to textures.

## Public API Reference

### Package `raylib_shaders_shapes_textures`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes an 800x450 window and loads a grayscale fragment shader. Each frame, it draws shapes in three groups: first without the shader (circles on the left), then with the shader active (rectangles in the center), then without again (triangles and a polygon on the right), and finally with the shader once more (a large blue rectangle on the far right). This demonstrates that shader mode can be toggled multiple times per frame. On exit, the shader is unloaded.

## Key Takeaways

- Fragment shaders in raylib work with 2D shape drawing, not just textures -- any geometry rendered between `begin_shader_mode` and `end_shader_mode` is processed by the shader.
- Shader mode can be toggled on and off multiple times within a single frame to selectively apply effects to specific draw calls.
- The same grayscale shader used for textures and models works identically with procedural shapes.
