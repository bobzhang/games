# Shaders - Simple Mask

This example demonstrates using a fragment shader to apply a texture mask to another texture, with an animated frame counter driving the effect. It draws a plasma texture through a mask shader at multiple positions, creating a masked reveal effect. When you run it, you see three copies of a plasma texture on a dark blue background, each masked by a secondary texture, with the effect animated over time.

## Build and Run

```bash
moon build --target native raylib_shaders_simple_mask/
./_build/native/debug/build/raylib_shaders_simple_mask/raylib_shaders_simple_mask.exe
```

## Controls

No interactive controls -- the mask animation runs automatically.

## What It Demonstrates

- **Texture masking via shader**: Uses a `mask.fs` fragment shader that takes two textures -- a diffuse texture (`texture0`, the default sampler) and a mask texture (bound to a custom `mask` sampler) -- to selectively reveal or hide pixels.
- **Multi-texture shader binding**: Uses `set_shader_value_texture` to bind the mask texture to the shader's `mask` sampler uniform, alongside the automatically-bound primary texture.
- **Animated shader uniform**: Sends an incrementing `frame` integer uniform to the shader each frame via `set_shader_value` with `ShaderUniformInt`, allowing the shader to animate the masking effect over time.
- **Multiple draw calls under one shader**: Draws the same diffuse texture at three different screen positions, all within a single `begin_shader_mode`/`end_shader_mode` block, showing that shader state persists across draw calls.

## Public API Reference

### Package `raylib_shaders_simple_mask`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads two textures (a plasma diffuse texture and a mask texture) and a mask fragment shader. Shader locations for `mask` (texture sampler) and `frame` (animation counter) are resolved at startup. Each frame, the counter increments and is sent to the shader as an integer uniform. The mask texture is bound to the shader's secondary sampler, and the diffuse texture is drawn at three horizontal positions within shader mode. The shader uses the mask and frame values to determine pixel visibility. On exit, both textures and the shader are unloaded.

## Key Takeaways

- Texture masking via shaders is achieved by binding a mask texture as a secondary sampler and using it in the fragment shader to modulate the primary texture's alpha or visibility.
- Integer uniforms sent to shaders can drive animation effects, providing a simple mechanism for time-varying shader behavior without floating-point time values.
- Multiple draw calls within a single shader mode block share the same shader state, making it efficient to render many masked objects.
