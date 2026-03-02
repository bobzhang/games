# Models GPU Skinning

This example demonstrates GPU-based skeletal animation (skinning) by loading a glTF model with custom vertex and fragment shaders that perform bone transformations on the GPU rather than the CPU. When you run it, you see an animated green humanoid character that you can cycle through animations, viewed with a third-person camera.

## Build and Run

```bash
moon build --target native raylib_models_gpu_skinning/
./_build/native/debug/build/raylib_models_gpu_skinning/raylib_models_gpu_skinning.exe
```

## Controls

- **Mouse**: Rotate the third-person camera
- **T**: Next animation
- **G**: Previous animation

## What It Demonstrates

- **GPU skinning pipeline**: Loads custom vertex and fragment shaders (`skinning.vs`/`skinning.fs`) via `@raylib.load_shader` and assigns them to the model's material using `@raylib.set_model_material_shader`.
- **Bone-only animation update**: Uses `@raylib.update_model_animation_bones` instead of `update_model_animation` to update only the bone transform data without performing CPU-side mesh deformation, leaving the vertex transformation to the GPU shader.
- **Direct mesh drawing**: Uses `@raylib.get_model_mesh`, `@raylib.get_model_material`, `@raylib.get_model_transform`, and `@raylib.draw_mesh` to draw the mesh with its material and transform, giving the shader access to the bone data.
- **Model transform management**: Sets the model's transform matrix with `@raylib.set_model_transform` using `@raylib.Matrix::translate` for positioning.
- **Animation cycling**: Cycles through multiple animations embedded in the glTF file using `get_model_animation_frame_count` and modular arithmetic.

## Public API Reference

### Package `raylib_models_gpu_skinning`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads a glTF model (`greenman.glb`) and custom skinning shaders, assigning the shader to the model's material. Animation data is loaded from the same glTF file. Each frame, the camera is updated for third-person movement, T/G keys cycle the animation index, the model transform is set, `update_model_animation_bones` uploads bone data without CPU mesh deformation, and the mesh is drawn with `draw_mesh` using the model's material (which references the skinning shader) and transform. On exit, animations, model, and shader are unloaded.

## Key Takeaways

- GPU skinning offloads bone transform calculations from the CPU to vertex shaders, which can improve performance for complex animated models.
- `update_model_animation_bones` updates only bone data, while `update_model_animation` does both bone updates and CPU-side mesh deformation -- use the former when shaders handle vertex transformation.
- Custom shaders are assigned to specific material slots on a model using `set_model_material_shader`, allowing per-material shader control.
