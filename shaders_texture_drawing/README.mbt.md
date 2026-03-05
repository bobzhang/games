# Shaders - Texture Drawing

This example demonstrates using a fragment shader to generate an animated procedural texture. Instead of loading an image, it creates a blank texture and uses a shader to paint an animated pattern of panning cubes directly on the GPU. When you run it, you see a full-screen animated pattern of 3D-looking cubes that continuously scroll across the screen.

## Build and Run

```bash
moon build --target native shaders_texture_drawing/
./_build/native/debug/build/shaders_texture_drawing/shaders_texture_drawing.exe
```

## Controls

No interactive controls -- the animation runs automatically.

## What It Demonstrates

- **Procedural texture generation via shader**: Creates a blank (transparent) 1024x1024 texture and uses a `cubes_panning.fs` fragment shader to generate the entire visual content procedurally on the GPU.
- **Time-based shader animation**: Passes the current time (via `get_time`) to the shader's `uTime` uniform each frame, driving the panning animation.
- **Blank image as shader canvas**: Uses `gen_image_color` with `@raylib.blank` (fully transparent) to create a texture that serves purely as a drawing surface for the shader.
- **Float uniform serialization**: Implements `float_to_bytes` using `reinterpret_as_int` for IEEE 754 bit-level conversion to bytes.

## Public API Reference

### Package `shaders_texture_drawing`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program generates a blank 1024x1024 image, converts it to a GPU texture, and immediately frees the CPU-side image. A panning cubes fragment shader is loaded and its `uTime` uniform location is resolved. Each frame, the current elapsed time is retrieved via `get_time`, converted to float, serialized to bytes, and sent to the shader. The blank texture is drawn at position (0,0) inside shader mode, where the fragment shader computes each pixel's color based on UV coordinates and time. On exit, the shader and texture are unloaded.

## Key Takeaways

- A blank texture combined with a procedural fragment shader is an effective technique for GPU-generated animated backgrounds without any texture assets.
- The `get_time` function provides a high-precision elapsed time value suitable for driving smooth shader animations.
- This pattern of "draw a quad with a shader" is the foundation for many visual effects including noise, fractals, and procedural patterns.
