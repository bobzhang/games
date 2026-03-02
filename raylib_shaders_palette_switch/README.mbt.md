# Shaders - Palette Switch

This example demonstrates GPU-based color palette switching using a fragment shader. It draws horizontal color bands and uses a shader to remap pixel colors through different palettes. When you run it, you see eight horizontal color strips whose colors change between three predefined palettes (3-bit RGB, AMMO-8 GameBoy-like, and RKBV 2-strip film) as you press the arrow keys.

## Build and Run

```bash
moon build --target native raylib_shaders_palette_switch/
./_build/native/debug/build/raylib_shaders_palette_switch/raylib_shaders_palette_switch.exe
```

## Controls

- **Left/Right arrow keys**: Cycle through the three available color palettes

## What It Demonstrates

- **Palette-based color remapping via shader**: Uses a fragment shader (`palette_switch.fs`) that receives an array of `ivec3` palette colors and remaps drawn pixel indices to those colors.
- **Shader array uniforms with `set_shader_value_v`**: Sends an array of 8 `ivec3` values to the shader in a single call, demonstrating how to pass array uniforms with a count parameter.
- **Integer vector byte serialization**: Implements `ivec3_array_to_bytes` to convert an array of integers into little-endian `Bytes`, packing RGB triplets for the `ShaderUniformIvec3` type.
- **Index encoding in color channels**: Encodes the palette index directly in the RGB components of drawn rectangles (`Color::new(i, i, i, 255)`), which the shader then uses to look up the actual color from the palette array.

## Public API Reference

### Package `raylib_shaders_palette_switch`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program defines three color palettes, each containing 8 RGB triplets stored as flat integer arrays. On initialization, a palette switch fragment shader is loaded and the `palette` uniform location is retrieved. Each frame, arrow key input cycles through palettes (with wrapping). The current palette data is sent to the shader as an array of `ivec3` values via `set_shader_value_v`. Eight horizontal rectangles are drawn with index-encoded colors inside a shader mode block; the shader remaps each pixel's color channel value to the corresponding palette entry. On exit, the shader is unloaded.

## Key Takeaways

- Palette switching via shaders is an efficient technique for applying different color schemes without regenerating textures, useful for retro-style games and dynamic theming.
- Array uniforms in raylib require `set_shader_value_v` with the element count, and the data must be serialized as contiguous bytes matching the GLSL uniform type.
- Encoding metadata (like palette indices) in pixel color channels is a practical trick for communicating per-pixel data to fragment shaders.
