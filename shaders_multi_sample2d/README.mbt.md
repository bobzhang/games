# Shaders - Multiple Sample2D

This example demonstrates how to use multiple `sampler2D` texture units in a single fragment shader to blend two textures together. It creates a red and a blue texture, then uses a custom shader to mix them based on a controllable divider value. When you run it, you see a screen that transitions from red to blue (or vice versa) as you press the arrow keys.

## Build and Run

```bash
moon build --target native shaders_multi_sample2d/
./_build/native/debug/build/shaders_multi_sample2d/shaders_multi_sample2d.exe
```

## Controls

- **Left/Right arrow keys**: Adjust the texture mixing divider (0.0 = fully texture0, 1.0 = fully texture1)

## What It Demonstrates

- **Multiple sampler2D textures in a shader**: Uses `set_shader_value_texture` to bind a second texture (`texture1`) to the shader alongside the default `texture0`, enabling multi-texture blending in the fragment shader.
- **Shader uniform for mix control**: Uses `get_shader_location` to find the `divider` uniform and `set_shader_value` with `ShaderUniformFloat` to control the blend ratio each frame.
- **Procedural texture generation**: Creates solid-color textures at runtime using `gen_image_color` and `load_texture_from_image`, then frees the CPU-side image data with `unload_image`.
- **Float-to-bytes serialization**: Implements `float_to_bytes` using `reinterpret_as_int` for bit-level conversion to little-endian bytes, required by the raylib shader uniform API.

## Public API Reference

### Package `shaders_multi_sample2d`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program creates two full-screen textures (red and blue) from generated images. It loads a `color_mix.fs` fragment shader and locates two uniforms: `texture1` (the second sampler) and `divider` (the blend ratio). Each frame, arrow key input adjusts the divider value (clamped to 0.0-1.0), which is sent to the shader. The red texture is drawn as the primary texture (`texture0`), while the blue texture is bound to the `texture1` sampler via `set_shader_value_texture`. The fragment shader mixes both based on the divider. On exit, the shader and both textures are unloaded.

## Key Takeaways

- Raylib supports multiple texture units in shaders via `set_shader_value_texture`, which binds additional textures beyond the default `texture0`.
- The divider/mix pattern is a common technique for shader-based transitions, crossfades, and texture blending effects.
- Procedural texture creation with `gen_image_color` and `load_texture_from_image` is useful for testing shader behavior without external assets.
