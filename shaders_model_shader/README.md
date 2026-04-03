# Shaders - Model Shader

This example demonstrates how to apply a custom fragment shader to a 3D model loaded from an OBJ file. It loads a watermill model, applies a grayscale post-processing shader to it, and renders the result in a free-camera 3D scene. When you run it, you see a grayscale watermill model on a grid that you can fly around freely.

## Build and Run

```bash
moon build --target native shaders_model_shader/
./_build/native/debug/build/shaders_model_shader/shaders_model_shader.exe
```

## Controls

- **Mouse**: Look around (cursor is captured)
- **W/A/S/D**: Move camera forward/left/backward/right
- **E/Q**: Move camera up/down

## What It Demonstrates

- **Loading OBJ models**: Uses `load_model` to import a 3D model from a `.obj` file.
- **Loading and applying textures to models**: Uses `load_texture` and `set_model_material_texture` to bind a diffuse texture to the model's first material slot via `MaterialMapAlbedo`.
- **Applying custom shaders to models**: Uses `load_shader` with an empty vertex shader path (uses default) and a custom `grayscale.fs` fragment shader, then assigns it via `set_model_material_shader`.
- **Free camera control**: Uses `update_camera` with `CameraFree` mode and `disable_cursor` for first-person-style navigation.
- **Proper resource cleanup**: Unloads shader, texture, and model separately on exit.

## Public API Reference

### Package `shaders_model_shader`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes an 800x450 window with MSAA, sets up a perspective camera in free mode, and disables the cursor for mouse-look. It loads the watermill OBJ model, its diffuse texture, and a grayscale fragment shader. The shader is assigned to the model's material, and the texture is bound to the albedo map slot. Each frame, the camera is updated based on input, the model is drawn at the origin with scale 0.2, and a reference grid is rendered. On exit, all resources (shader, texture, model) are unloaded and the window is closed.

## Key Takeaways

- Applying a shader to a 3D model in raylib is done by assigning it to the model's material with `set_model_material_shader`, which affects all subsequent draw calls for that model.
- The shader pipeline is transparent to the model drawing code -- `draw_model` works the same regardless of whether a custom or default shader is active.
- Free camera mode with `disable_cursor` provides a straightforward first-person navigation experience.
