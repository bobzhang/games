# Shaders: Basic PBR

This example demonstrates physically-based rendering (PBR) using custom GLSL shaders with albedo, normal, metalness/roughness/AO (MRA), and emissive texture maps. When you run it, you see an old car model on a textured road surface, illuminated by four colored point lights with varying intensities. The materials exhibit realistic metallic and rough surface characteristics with emissive headlights.

## Build and Run

```bash
moon build --target native raylib_shaders_basic_pbr/
./_build/native/debug/build/raylib_shaders_basic_pbr/raylib_shaders_basic_pbr.exe
```

## Controls

- **1 Key** -- Toggle red light
- **2 Key** -- Toggle green light
- **3 Key** -- Toggle blue light
- **4 Key** -- Toggle yellow light
- **Mouse** -- Orbital camera rotation and zoom

## What It Demonstrates

- **PBR material pipeline**: Loads and configures a full PBR material setup with albedo, normal, MRA (metalness/roughness/AO packed into one texture), and emissive maps. Uses `set_shader_locs` to bind shader locations for `ShaderLocMapAlbedo`, `ShaderLocMapMetalness`, `ShaderLocMapNormal`, and `ShaderLocMapEmission`.
- **PBR light system with intensity**: Extends the basic light struct with an `intensity` field and `intensity_loc` shader uniform, allowing per-light brightness control in addition to color.
- **Per-object shader parameters**: Demonstrates changing shader uniforms between draw calls -- setting different texture tiling, emissive color, and emissive intensity for the floor versus the car model before each `draw_model` call.
- **Packed texture maps**: Shows the convention of packing metalness, roughness, and AO into a single MRA texture (bound to `SHADER_LOC_MAP_METALNESS`) and height/emission into an emissive map (bound to `SHADER_LOC_MAP_EMISSION`), with the shader responsible for unpacking.
- **GLB model loading**: Loads 3D models in glTF binary format (`.glb`) via `load_model`.

## Public API Reference

### Package `raylib_shaders_basic_pbr`

> Single-package example.

No public API -- self-contained main function. The `PbrLight` struct and helper functions (`create_pbr_light`, `update_pbr_light`, `int_to_bytes`, `float_to_bytes`, `vec2_to_bytes`, `vec3_to_bytes`, `vec4_to_bytes`, `color4_to_bytes`) are package-level but not exported.

## Architecture

The program enables MSAA 4x, initializes a window, and loads the PBR shader with all required uniform and attribute locations. Ambient lighting parameters are set globally. A car model and floor model are loaded from `.glb` files, both assigned the PBR shader. Each model's material is configured with appropriate textures (albedo, MRA, normal, emissive) and default map values (metalness, roughness, occlusion). Four PBR lights with different positions, colors, and intensities are created. Texture usage flags are set in the shader. Each frame, the camera and light states are updated, then per-object shader uniforms (texture tiling, emissive color/intensity) are set before drawing each model. Light indicators are drawn as colored spheres. On exit, models, shader, and textures are cleaned up.

## Key Takeaways

- PBR workflows pack multiple material properties into fewer textures (e.g., MRA combining metalness, roughness, and AO) to reduce texture sampler usage and simplify material setup.
- When multiple objects share the same shader but need different parameters, you must update the relevant uniforms (like texture tiling or emissive intensity) between draw calls.
- The `set_shader_locs` function connects raylib's built-in shader location slots to custom uniform names, enabling raylib's material system to automatically bind textures to the correct shader samplers.
