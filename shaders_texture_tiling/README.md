# Shaders - Texture Tiling

This example demonstrates using a fragment shader to tile a texture across a 3D model. It loads a cube model with a texture and applies a tiling shader that repeats the texture coordinates, making the texture appear multiple times across each face. When you run it, you see a cube with a tiled texture pattern on a grid that you can orbit around using free camera controls.

## Build and Run

```bash
moon build --target native shaders_texture_tiling/
./_build/native/debug/build/shaders_texture_tiling/shaders_texture_tiling.exe
```

## Controls

- **Mouse**: Look around (cursor is captured)
- **W/A/S/D**: Move camera forward/left/backward/right
- **E/Q**: Move camera up/down
- **Z**: Reset camera target to center

## What It Demonstrates

- **Texture tiling via fragment shader**: Uses a `tiling.fs` shader with a `tiling` vec2 uniform set to (3.0, 3.0), causing the texture to repeat 3 times in each direction across the model's UV space.
- **Shader applied to 3D model materials**: Assigns the tiling shader to the model's material using `set_model_material_shader`, affecting how the texture is sampled during model rendering.
- **Model from generated mesh**: Creates a cube model from a generated mesh using `gen_mesh_cube` and `load_model_from_mesh`.
- **Texture binding to model material**: Uses `set_model_material_texture` to assign a loaded texture to the model's albedo map slot.
- **Free camera with target reset**: Implements camera target reset on Z key press by reconstructing the `Camera3D` struct with a new target value.

## Public API Reference

### Package `shaders_texture_tiling`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program sets up a free-look camera, generates a cube mesh and converts it to a model, loads a cubicmap atlas texture and assigns it to the model's albedo material slot, and loads a tiling fragment shader with a vec2 tiling factor of (3, 3). The shader is assigned to the model's material. Each frame, the camera is updated from input, the model is drawn at scale 2.0 within shader mode, and a reference grid is rendered. Pressing Z resets the camera target. On exit, the model, shader, and texture are unloaded.

## Key Takeaways

- Texture tiling can be controlled via a shader uniform rather than modifying UV coordinates, providing runtime-adjustable repetition without regenerating mesh data.
- The combination of `gen_mesh_cube`, `load_model_from_mesh`, and `set_model_material_shader` demonstrates the full pipeline from procedural mesh to shader-enhanced model.
- Camera target reset is a useful UX pattern for 3D viewers, easily implemented by reconstructing the camera struct with updated fields.
