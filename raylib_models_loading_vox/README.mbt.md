# Models Loading VOX

This example demonstrates loading and rendering MagicaVoxel (.vox) models with a custom voxel lighting shader system in raylib using MoonBit. When you run it, you see a lit voxel model (cycling through knight, sword, monument, and fez models) with four point lights illuminating the scene.

## Build and Run

```bash
moon build --target native raylib_models_loading_vox/
./_build/native/debug/build/raylib_models_loading_vox/raylib_models_loading_vox.exe
```

## Controls

- **Left click**: Cycle to the next VOX model
- **Middle mouse button (drag)**: Rotate/zoom the camera
- **WASD / Arrow keys**: Move the camera
- **Mouse wheel**: Zoom in/out

## What It Demonstrates

- **MagicaVoxel loading**: Loads multiple `.vox` files using `@raylib.load_model`, measures loading time with `get_time`, and centers each model using bounding box calculations with `get_model_bounding_box` and `Matrix::translate`.
- **Custom lighting system**: Implements a complete point light system with a `Light` struct containing enabled state, type, position, target, color, and shader uniform locations. The `create_light` function looks up shader uniform locations and `update_light_values` pushes light data to the shader.
- **Shader uniform management**: Demonstrates setting various shader uniform types: `ShaderUniformInt` for light enabled/type, `ShaderUniformVec3` for positions, and `ShaderUniformVec4` for colors. Uses custom `int_to_bytes`, `vec3_to_bytes`, and `vec4_to_bytes` helpers for data marshaling.
- **Custom voxel shaders**: Loads and applies vertex/fragment shaders (`voxel_lighting.vs`/`voxel_lighting.fs`) to all materials of all models using `set_model_material_shader`.
- **Camera view position update**: Passes the camera position to the shader each frame via `set_shader_value` for correct specular calculations.
- **Manual camera control**: Uses `@raylib.update_camera_pro` for fine-grained camera control with mouse rotation and keyboard movement.

## Public API Reference

### Package `raylib_models_loading_vox`

> Single-package example.

The following internal types and functions are defined:

- `const LightPoint : Int` -- Light type constant for point lights.
- `const MaxLights : Int` -- Maximum number of lights (4).
- `struct Light` -- Holds light properties (enabled, type, position, target, color) and shader uniform locations.
- `fn int_to_bytes(v : Int) -> Bytes` -- Converts an integer to little-endian bytes for shader uniforms.
- `fn vec3_to_bytes(v : @raylib.Vector3) -> Bytes` -- Converts a Vector3 to bytes for shader uniforms.
- `fn vec4_to_bytes(v : @raylib.Vector4) -> Bytes` -- Converts a Vector4 to bytes for shader uniforms.
- `fn create_light(...) -> Light` -- Creates a light with shader uniform binding.
- `fn update_light_values(shader, light) -> Unit` -- Pushes light data to shader uniforms.

## Architecture

The program loads four VOX models, centering each by computing bounding boxes and applying translation transforms. A custom voxel lighting shader is loaded and assigned to all materials of all models. Four point lights are created at symmetric positions, each bound to shader uniform arrays (`lights[0..3].enabled/type/position/target/color`). The main loop updates camera position via `update_camera_pro` with mouse delta and keyboard input, cycles the displayed model on left click, updates the camera position uniform for the shader, updates light values, and renders the current model with light indicator spheres. On exit, all models and the shader are unloaded.

## Key Takeaways

- MagicaVoxel `.vox` files can be loaded directly with `load_model`, making voxel art integration straightforward.
- Implementing a custom lighting system requires looking up shader uniform locations by name, then pushing data each frame via `set_shader_value` with the correct uniform type.
- Centering models using bounding box calculations (`get_model_bounding_box` plus `Matrix::translate`) ensures they display correctly at the origin regardless of their original coordinate space.
