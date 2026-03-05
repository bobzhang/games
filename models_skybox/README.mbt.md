# Models: Skybox

This example demonstrates how to load and render a skybox using a cubemap texture and custom shaders in raylib. When you run it, you find yourself inside a skybox environment with a first-person camera, able to look around freely. A reference grid is drawn at the origin for spatial orientation.

## Build and Run

```bash
moon build --target native models_skybox/
./_build/native/debug/build/models_skybox/models_skybox.exe
```

## Controls

- **Mouse** -- Look around (first-person camera, cursor is captured)
- **WASD** -- Move around the scene

## What It Demonstrates

- **Skybox rendering technique**: Creates a unit cube mesh via `gen_mesh_cube`, loads it as a model, and assigns a custom skybox shader. The camera is always at the center of the cube, which is rendered with backface culling disabled so the inner faces are visible.
- **Cubemap texture loading**: Loads a panoramic skybox image with `load_image`, converts it to a cubemap texture via `load_texture_cubemap` with auto-detect layout, and assigns it to the model's cubemap material map slot.
- **Custom shader setup**: Loads separate vertex and fragment shaders (`skybox.vs`/`skybox.fs`), sets the `environmentMap` uniform to reference the cubemap slot, and configures `doGamma` and `vflipped` uniforms using `set_shader_value` with manually serialized integer bytes.
- **rlgl render state management**: Uses `@rl.disable_backface_culling()` and `@rl.disable_depth_mask()` before drawing the skybox (since the viewer is inside the cube), then re-enables them for normal geometry rendering.
- **Byte serialization helper**: The `int_to_bytes` function manually packs an integer into 4 little-endian bytes for passing to shader uniforms.

## Public API Reference

### Package `models_skybox`

> Single-package example.

No public API -- self-contained main function. The helper function `int_to_bytes` is package-level but not exported.

## Architecture

The program initializes a window, changes the working directory to access resources, and sets up a first-person camera. A cube mesh is generated and wrapped in a model, then a custom skybox shader is loaded and assigned to the model's material. Shader uniforms for the environment map type, gamma correction, and vertical flip are configured. A cubemap texture is loaded from a panoramic image and bound to the material's cubemap slot. Each frame, the camera is updated with first-person controls, and the skybox is drawn with backface culling and depth mask disabled. A grid and filename label provide reference. On exit, the shader, cubemap, and model are all unloaded before closing the window.

## Key Takeaways

- Skybox rendering requires drawing a cube from the inside, which means disabling backface culling and depth masking so the inner faces are visible and don't interfere with the depth buffer.
- Passing integer values to shaders in raylib requires manual byte serialization since `set_shader_value` expects raw `Bytes` data.
- The `change_directory` call at startup is a common pattern for raylib examples that need to load resources relative to the example's directory.
