# Shaders: Fog

This example demonstrates a fog effect applied to 3D models using a custom fragment shader that combines basic lighting with distance-based fog. When you run it, you see a torus, cube, and sphere on a gray background with configurable fog density. Additional torus models extend into the distance, gradually disappearing into the fog.

## Build and Run

```bash
moon build --target native raylib_shaders_fog/
./_build/native/debug/build/raylib_shaders_fog/raylib_shaders_fog.exe
```

## Controls

- **Up Arrow** -- Increase fog density
- **Down Arrow** -- Decrease fog density
- **Mouse** -- Orbital camera rotation and zoom

## What It Demonstrates

- **Custom fog shader**: Loads a fog fragment shader (`fog.fs`) paired with the lighting vertex shader (`lighting.vs`), adding a `fogDensity` uniform that controls exponential distance-based fog blending.
- **Shader location configuration**: Uses `set_shader_locs` to set `ShaderLocMatrixModel` and `ShaderLocVectorView` locations, which raylib uses internally to pass the model matrix and view position to the shader automatically.
- **Shared shader across multiple models**: Assigns the same fog/lighting shader to three different models (torus, cube, sphere) via `set_model_material_shader`, with a shared checker texture applied to all.
- **Dynamic uniform updates**: Updates the `fogDensity` uniform every frame in response to key input, clamped to the 0.0-1.0 range.
- **Light system integration**: Reuses the rlights-style light creation system (single white point light) in combination with the fog shader, showing how lighting and fog effects can coexist.
- **Model transform animation**: Rotates the torus model each frame by multiplying its current transform with incremental rotation matrices via `Matrix::multiply` and `Matrix::rotate_x`/`Matrix::rotate_z`.

## Public API Reference

### Package `raylib_shaders_fog`

> Single-package example.

No public API -- self-contained main function. The `Light` struct and helper functions (`create_light`, `update_light_values`, `int_to_bytes`, `float_to_bytes`, `format_float`, `vec3_to_bytes`, `vec4_to_bytes`) are package-level but not exported.

## Architecture

The program enables MSAA 4x, initializes a window, and loads three generated mesh models (torus, cube, sphere) with a shared checker texture. The fog/lighting shader is loaded and configured with model matrix and view position locations. Ambient light and initial fog density are set as uniforms, and a single white point light is created. Each frame, fog density is adjusted by key input and pushed to the shader, the torus model's transform is rotated, and the camera view position is updated in the shader. All three models are drawn (plus a row of torus copies extending into the distance), demonstrating how fog naturally attenuates distant objects. A text overlay displays the current fog density. On exit, all models, textures, and the shader are unloaded.

## Key Takeaways

- Fog is typically implemented as exponential blending between the fragment color and a fog color based on the distance from the camera, controlled by a single density parameter.
- Setting `ShaderLocMatrixModel` and `ShaderLocVectorView` via `set_shader_locs` allows raylib to automatically pass the per-model transformation matrix and camera position to your custom shader.
- Accumulating rotation by multiplying the current transform matrix with incremental rotation matrices each frame creates smooth continuous rotation without tracking angle state.
