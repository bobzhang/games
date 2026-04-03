# Models Loading glTF

This example demonstrates loading and displaying an animated glTF/GLB model with support for cycling through embedded animations. When you run it, you see a robot model with auto-advancing animation on a grid, viewed with an auto-orbiting camera. Click the mouse buttons to switch between animation clips.

## Build and Run

```bash
moon build --target native models_loading_gltf/
./_build/native/debug/build/models_loading_gltf/models_loading_gltf.exe
```

## Controls

- **Mouse**: Orbital camera auto-rotation
- **Left mouse button**: Previous animation
- **Right mouse button**: Next animation

## What It Demonstrates

- **glTF/GLB model loading**: Uses `@raylib.load_model` to load a GLB file (`robot.glb`) which contains both mesh and material data.
- **Animation loading and playback**: Loads animations with `@raylib.load_model_animations`, queries the count with `model_animations_count`, and updates the animation each frame with `update_model_animation` using an auto-incrementing frame counter.
- **Animation cycling**: Switches between animation clips via mouse buttons using modular arithmetic to wrap the animation index.
- **Orbital camera**: Uses `@raylib.CameraOrbital` for hands-free automatic camera rotation.
- **Animation index display**: Shows the current animation index on screen for reference.

## Public API Reference

### Package `models_loading_gltf`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads a GLB model and its embedded animations, initializes an orbital camera. Each frame, the camera auto-rotates, mouse button clicks cycle the animation index forward or backward (wrapping with modular arithmetic), the animation frame counter auto-increments, and `update_model_animation` updates the mesh deformation. The model is drawn at the origin with a grid. On exit, animations and the model are unloaded.

## Key Takeaways

- GLB (binary glTF) files can contain meshes, materials, textures, and animations in a single file, making them convenient for distribution.
- `update_model_animation` automatically handles frame wrapping internally, so the frame counter can increment continuously without manual reset.
- Orbital camera mode (`CameraOrbital`) is useful for showcasing models hands-free, letting the user focus on mouse-click interactions.
