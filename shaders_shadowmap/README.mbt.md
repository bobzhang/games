# Shaders - Shadow Mapping

This example demonstrates real-time shadow mapping using a two-pass rendering technique. It renders a scene from the light's perspective to generate a depth-based shadow map, then uses that shadow map during the main render pass to determine which areas are in shadow. When you run it, you see an animated robot and cubes on a blue ground plane with dynamic directional shadows that you can rotate using arrow keys.

## Build and Run

```bash
moon build --target native shaders_shadowmap/
./_build/native/debug/build/shaders_shadowmap/shaders_shadowmap.exe
```

## Controls

- **Arrow keys (Left/Right/Up/Down)**: Rotate the directional light direction
- **F**: Take a screenshot
- Camera orbits automatically around the scene

## What It Demonstrates

- **Two-pass shadow mapping**: First pass renders the scene from the light's viewpoint into a depth-only shadow map render texture; second pass renders from the camera's viewpoint using the shadow map to compute shadows.
- **Shadow map render texture**: Uses `load_shadowmap_render_texture` and `unload_shadowmap_render_texture` for a depth-only framebuffer at 1024x1024 resolution.
- **Light-view-projection matrix**: Captures the light camera's modelview and projection matrices using `@rl.get_matrix_modelview` and `@rl.get_matrix_projection`, multiplies them, and sends the result to the shadow shader via `set_shader_value_matrix`.
- **Low-level OpenGL via `@rl` module**: Uses `enable_shader`, `active_texture_slot`, `enable_texture`, and `set_uniform` to manually bind the shadow map depth texture to a specific texture slot (slot 10).
- **Animated 3D model**: Loads a robot GLB model with animations, updates animation frames each tick with `update_model_animation`.
- **Dynamic light direction**: Arrow keys adjust the light direction vector, which updates both the light camera position and the shader uniform.
- **Shared scene rendering**: A `draw_scene` helper function draws the same geometry in both the shadow pass and the main pass, ensuring consistency.

## Public API Reference

### Package `shaders_shadowmap`

> Single-package example.

No public API -- self-contained main function. The helper functions (`draw_scene`, `int_to_bytes`) and the constant `ShadowmapResolution` are package-private.

## Architecture

Initialization sets up an orbital camera, loads the shadow mapping shader with vertex and fragment components, and configures light direction, color, ambient, and shadow map uniforms. A cube model (from generated mesh) and an animated robot model (from GLB) both have their materials assigned to the shadow shader. A shadow map render texture is created at 1024x1024.

Each frame follows two passes:
1. **Shadow pass**: Renders the scene into the shadow map from the light camera's orthographic perspective, capturing the modelview and projection matrices.
2. **Main pass**: Binds the shadow map depth texture to texture slot 10, sends the light view-projection matrix to the shader, and renders the scene from the main camera. The shader samples the shadow map to determine shadowed fragments.

On exit, the shader, models, animations, and shadow map are all properly unloaded.

## Key Takeaways

- Shadow mapping requires rendering the scene twice: once from the light to build a depth map, and once from the camera using that depth map for shadow testing.
- The `@rl` module provides low-level OpenGL access needed for advanced techniques like manually binding depth textures to specific texture slots.
- Using an orthographic light camera produces consistent directional shadows without perspective distortion.
