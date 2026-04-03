# Models Cubicmap

This example demonstrates how to generate a 3D cubic map mesh from a 2D image using raylib in MoonBit. When you run it, you see a textured 3D level generated from a small pixel image, where each non-black pixel becomes a cube in the map, viewed with an auto-orbiting camera.

## Build and Run

```bash
moon build --target native models_cubicmap/
./_build/native/debug/build/models_cubicmap/models_cubicmap.exe
```

## Controls

- **P**: Pause/unpause camera orbital rotation

## What It Demonstrates

- **Cubicmap mesh generation**: Uses `@raylib.gen_mesh_cubicmap` to convert a small image into a 3D mesh where each pixel maps to a cube, with the image's color values determining wall placement.
- **Image-to-model pipeline**: Loads an image with `load_image`, generates a mesh from it with `gen_mesh_cubicmap`, converts the mesh to a model with `load_model_from_mesh`, and applies a texture atlas via `set_model_material_texture`.
- **Texture atlas mapping**: The generated cubicmap mesh uses UV coordinates that map to a texture atlas (`cubicmap_atlas.png`), allowing different faces to have different textures.
- **Orbital camera with pause**: Uses `@raylib.CameraOrbital` for automatic camera rotation, with a toggle to pause/resume via the P key.

## Public API Reference

### Package `models_cubicmap`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads a small cubicmap image (`cubicmap.png`) and generates both a texture (for reference) and a 3D mesh from it using `gen_mesh_cubicmap` with a 1x1x1 cube size. The mesh is converted to a model and assigned a texture atlas (`cubicmap_atlas.png`) for its albedo material. The source image is unloaded from RAM after mesh generation. In the main loop, the orbital camera auto-rotates (unless paused with P), and the model is drawn at an offset position (-16, 0, -8). On exit, both textures and the model are properly unloaded.

## Key Takeaways

- `gen_mesh_cubicmap` is a powerful tool for creating 3D environments from simple pixel art images, where each pixel's color determines whether a cube is placed.
- The cubicmap approach pairs naturally with a texture atlas, where different UV regions on the atlas correspond to different cube faces (walls, floor, ceiling).
- Unloading the source image after mesh generation is good practice since the pixel data is no longer needed once the mesh is in VRAM.
