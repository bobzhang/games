# Models Heightmap

This example demonstrates how to generate and render a 3D terrain mesh from a grayscale heightmap image using raylib in MoonBit. When you run it, you see a textured terrain landscape generated from a PNG heightmap, viewed with an auto-orbiting camera.

## Build and Run

```bash
moon build --target native models_heightmap/
./_build/native/debug/build/models_heightmap/models_heightmap.exe
```

## Controls

- **Mouse**: Orbital camera auto-rotates; mouse can influence orbit

## What It Demonstrates

- **Heightmap mesh generation**: Uses `@raylib.gen_mesh_heightmap` to convert a grayscale image into a 3D terrain mesh, where pixel brightness determines vertex height. The size parameter `Vector3(16, 8, 16)` defines the terrain's world dimensions (width, max height, depth).
- **Image-to-model pipeline**: Loads a heightmap image with `load_image`, generates both a texture (used as the terrain's diffuse material) and a mesh from the same image, then converts the mesh to a model with `load_model_from_mesh`.
- **Material texture assignment**: Applies the heightmap image as the albedo texture using `set_model_material_texture`, creating a self-textured terrain.
- **Orbital camera**: Uses `@raylib.CameraOrbital` for automatic camera rotation around the terrain.
- **Memory management**: Unloads the source image from RAM after mesh generation since it is no longer needed.

## Public API Reference

### Package `models_heightmap`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program changes to the example directory, loads a grayscale heightmap image, creates a texture from it, generates a heightmap mesh with world dimensions 16x8x16, and converts it to a model. The heightmap texture is applied as the model's albedo material. The source image is freed from RAM. Each frame, the orbital camera auto-rotates and the terrain model is drawn at an offset position (-8, 0, -8) to center it. On exit, the texture and model are unloaded.

## Key Takeaways

- `gen_mesh_heightmap` generates terrain geometry from any grayscale image, where brighter pixels create higher vertices, making it easy to create landscapes from painted images.
- The same image used for heightmap generation can double as the terrain's diffuse texture, providing a quick visual result without additional art assets.
- The size vector passed to `gen_mesh_heightmap` controls the terrain's world-space dimensions independently of the source image resolution.
