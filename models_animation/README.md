# Models Animation

This example demonstrates how to load a 3D model in IQM format and play its skeletal animation using raylib in MoonBit. When you run it, you see a textured humanoid character on a grid that animates when you hold the spacebar, viewed through a first-person camera.

## Build and Run

```bash
moon build --target native models_animation/
./_build/native/debug/build/models_animation/models_animation.exe
```

## Controls

- **Space (hold)**: Play the model animation
- **Mouse**: Look around (first-person camera)
- **WASD**: Move the camera

## What It Demonstrates

- **IQM model loading**: Uses `@raylib.load_model` to load a mesh from an IQM file (`guy.iqm`) and `@raylib.load_texture` to load its associated texture (`guytex.png`), then binds the texture to the model's albedo material map with `@raylib.set_model_material_texture`.
- **Skeletal animation playback**: Loads animations separately via `@raylib.load_model_animations` from a dedicated animation file (`guyanim.iqm`), queries the animation count with `@raylib.model_animations_count`, and advances frames with `@raylib.update_model_animation` while the spacebar is held.
- **Model rendering with transform**: Uses `@raylib.draw_model_ex` to draw the model with custom rotation (-90 degrees around the X axis to correct orientation) and uniform scale.
- **Resource cleanup**: Properly unloads texture, animations, and model before closing the window.

## Public API Reference

### Package `models_animation`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program changes the working directory to the example folder, loads the IQM model and its texture, loads animation data from a separate IQM file, and sets up a first-person camera with cursor disabled. The main loop updates the camera, increments the animation frame counter while Space is held, calls `update_model_animation` to deform the mesh, then renders the model with `draw_model_ex` in a 3D mode block. On exit, all resources (texture, animations, model) are unloaded and the window is closed.

## Key Takeaways

- IQM is a compact skeletal animation format well-suited for raylib; model mesh and animation data can be loaded from separate files.
- `@raylib.update_model_animation` handles all bone transform calculations internally, making skeletal animation straightforward to integrate.
- Always use `@raylib.change_directory` to set the working directory before loading resources with relative paths.
