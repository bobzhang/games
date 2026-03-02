# Models Mesh Generation

This example showcases all of raylib's built-in procedural mesh generators: plane, cube, sphere, hemisphere, cylinder, torus, knot, and polygon. When you run it, you see a textured 3D shape on a grid that you can cycle through by clicking or pressing arrow keys, with the current shape name displayed in the UI.

## Build and Run

```bash
moon build --target native raylib_models_mesh_generation/
./_build/native/debug/build/raylib_models_mesh_generation/raylib_models_mesh_generation.exe
```

## Controls

- **Mouse**: Orbital camera auto-rotation
- **Left click**: Cycle to the next mesh type
- **Left/Right arrows**: Cycle through mesh types

## What It Demonstrates

- **Procedural mesh generation**: Demonstrates all 8 built-in mesh generators:
  - `@raylib.gen_mesh_plane(2, 2, 4, 3)` -- flat subdivided plane
  - `@raylib.gen_mesh_cube(2, 1, 2)` -- rectangular cuboid
  - `@raylib.gen_mesh_sphere(2, 32, 32)` -- UV sphere
  - `@raylib.gen_mesh_hemisphere(2, 16, 16)` -- half sphere
  - `@raylib.gen_mesh_cylinder(1, 2, 16)` -- cylinder
  - `@raylib.gen_mesh_torus(0.25, 4, 16, 32)` -- torus (donut)
  - `@raylib.gen_mesh_knot(1, 2, 16, 128)` -- trefoil knot
  - `@raylib.gen_mesh_poly(5, 2)` -- regular polygon (pentagon)
- **Mesh-to-model conversion**: Each generated mesh is converted to a model via `@raylib.load_model_from_mesh`.
- **Procedural texturing**: Creates a small 2x2 checkerboard image with `gen_image_checked` and applies it as the albedo texture to all models.
- **Model cycling UI**: Displays the current shape name from an array and cycles through models with mouse clicks or arrow keys.

## Public API Reference

### Package `raylib_models_mesh_generation`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program generates a checked texture, creates 8 meshes using different `gen_mesh_*` functions, converts each to a model with `load_model_from_mesh`, and applies the texture to all of them. An orbital camera is set up. Each frame, the camera auto-rotates, left clicks or arrow keys cycle the current model index, and the selected model is drawn at the origin. The current model name is shown on screen. On exit, the texture and all 8 models are unloaded.

## Key Takeaways

- Raylib provides a comprehensive set of procedural mesh generators that produce ready-to-use meshes without external modeling tools.
- `load_model_from_mesh` converts any generated mesh into a full model with default materials, making it easy to apply textures and render.
- Procedural meshes are useful for prototyping, debug visualization, and simple game objects where custom 3D art is not needed.
