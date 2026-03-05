# Shaders - Mesh Instancing

This example demonstrates GPU-based mesh instancing using raylib shaders. It renders 10,000 randomly positioned and rotated cube instances in a single draw call using an instancing shader with per-instance lighting. When you run it, you see a cloud of red lit cubes orbiting around the camera, with two blue reference cubes drawn using the default material.

## Build and Run

```bash
moon build --target native shaders_mesh_instancing/
./_build/native/debug/build/shaders_mesh_instancing/shaders_mesh_instancing.exe
```

## Controls

- The camera orbits automatically around the scene (`CameraOrbital` mode).

## What It Demonstrates

- **Mesh instancing with `draw_mesh_instanced`**: Renders 10,000 cube meshes in a single draw call by providing an array of transformation matrices, drastically reducing draw call overhead.
- **Custom lighting system (ported from rlights.h)**: Implements a `Light` struct with shader uniform locations for enabled state, type, position, target, and color. The `create_light` and `update_light_values` functions set these uniforms using `set_shader_value`.
- **Shader location management**: Uses `get_shader_location` and `get_shader_location_attrib` to bind MVP matrix, view position, instance transform attribute, and ambient light uniforms.
- **Matrix operations**: Builds per-instance transforms by composing random rotation and translation matrices with `Matrix::rotate` and `Matrix::translate`, then combining them with `Matrix::multiply`.
- **Material configuration**: Creates separate materials for instanced (red, with lighting shader) and non-instanced (blue, default) rendering using `load_material_default`, `set_material_shader`, and `set_material_map_color`.
- **Byte-level uniform passing**: Converts integers to little-endian `Bytes` for shader uniform transport, a common MoonBit pattern when interfacing with C-level APIs.

## Public API Reference

### Package `shaders_mesh_instancing`

> Single-package example.

No public API -- self-contained main function. The helper types and functions (`Light`, `create_light`, `update_light_values`, `int_to_bytes`) are all package-private.

## Architecture

The program initializes a window with MSAA, sets up a perspective camera in orbital mode, and generates a unit cube mesh. It pre-computes 10,000 random transformation matrices (rotation + translation) stored in an array. A lighting/instancing shader is loaded with vertex shader `lighting_instancing.vs` and fragment shader `lighting.fs`. A single directional light is created and its uniforms are pushed to the shader. Each frame, the camera orbits, the view position uniform is updated, and `draw_mesh_instanced` renders all 10,000 cubes in one call. Two additional cubes are drawn with the default material for contrast. On exit, the shader is unloaded and the window is closed.

## Key Takeaways

- GPU instancing via `draw_mesh_instanced` enables rendering thousands of meshes efficiently by uploading per-instance transform matrices rather than issuing individual draw calls.
- Shader uniform management in MoonBit requires manual byte serialization of values (int, float, vec3, vec4) using `FixedArray` and `reinterpret_as_bytes`.
- Separating material configurations (shader vs. default) allows mixing instanced and non-instanced rendering within the same scene.
