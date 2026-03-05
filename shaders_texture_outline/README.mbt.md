# Shaders - Texture Outline

This example demonstrates using a fragment shader to add a colored outline around a texture's opaque regions. It loads a character sprite and applies an outline shader that detects edges by sampling neighboring pixels. When you run it, you see a character sprite with a red outline whose thickness can be adjusted with the mouse wheel.

## Build and Run

```bash
moon build --target native shaders_texture_outline/
./_build/native/debug/build/shaders_texture_outline/shaders_texture_outline.exe
```

## Controls

- **Mouse wheel**: Increase or decrease the outline thickness (minimum 1 pixel)

## What It Demonstrates

- **Edge detection outline shader**: Uses an `outline.fs` fragment shader that samples neighboring texels to detect transparency boundaries, drawing a colored outline around opaque regions of the texture.
- **Multiple shader uniform types**: Sets `outlineSize` (float), `outlineColor` (vec4, normalized RGBA), and `textureSize` (vec2, pixel dimensions) as shader uniforms, demonstrating different uniform data types.
- **Dynamic uniform updates**: Updates the `outlineSize` uniform each frame based on mouse wheel input, allowing real-time outline thickness adjustment.
- **Byte serialization helpers**: Implements `float_to_bytes`, `vec2_to_bytes`, and `vec4_to_bytes` for converting different value types to the byte format required by `set_shader_value`.
- **Texture dimension queries**: Uses `get_texture_width` and `get_texture_height` to retrieve texture dimensions for the shader's `textureSize` uniform.

## Public API Reference

### Package `shaders_texture_outline`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads a character texture (`fudesumi.png`) and an outline fragment shader. Three uniforms are configured at startup: outline size (initially 2.0), outline color (normalized red), and texture dimensions in pixels. Each frame, the mouse wheel adjusts the outline size (clamped to a minimum of 1.0), and the updated value is sent to the shader. The texture is drawn centered on screen within shader mode, where the fragment shader adds an outline by checking if any neighboring pixel within the outline distance is transparent while the current pixel is opaque (or vice versa). On exit, the texture and shader are unloaded.

## Key Takeaways

- Outline effects are achieved by sampling neighboring pixels in the fragment shader to detect alpha boundaries, making the outline size controllable at runtime.
- Passing the texture size as a uniform is necessary for the shader to calculate correct texel offsets for neighbor sampling.
- Mouse wheel input via `get_mouse_wheel_move` provides an intuitive control for continuously adjustable shader parameters.
