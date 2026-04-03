# Models Loading

This example demonstrates loading and displaying 3D models from file, with support for runtime drag-and-drop of new models and textures, plus ray-based model selection. When you run it, you see a textured castle model that you can orbit around, click to select (showing a bounding box), or replace by dragging in new model/texture files.

## Build and Run

```bash
moon build --target native models_loading/
./_build/native/debug/build/models_loading/models_loading.exe
```

## Controls

- **Mouse**: First-person camera look
- **WASD**: Move the camera
- **Left click**: Select/deselect model (ray-cast hit test against bounding box)
- **Drag and drop**: Load new model files (.obj, .gltf, .glb, .vox, .iqm, .m3d) or textures (.png)

## What It Demonstrates

- **Model and texture loading**: Uses `@raylib.load_model` to load an OBJ file and `@raylib.load_texture` to load a diffuse texture, binding them via `set_model_material_texture`.
- **File drag-and-drop**: Detects dropped files with `@raylib.is_file_dropped`, retrieves them via `load_dropped_files` and `file_path_list_get`, checks extensions with `is_file_extension`, and loads new models or textures accordingly. Resources are properly unloaded before replacement.
- **Ray-based selection**: Casts a ray from the mouse position using `@raylib.get_screen_to_world_ray`, tests it against the model's bounding box with `get_ray_collision_box`, and toggles selection state on hit.
- **Bounding box visualization**: Computes the model's bounding box with `@raylib.get_model_bounding_box` and draws it with `draw_bounding_box` when selected.
- **Multiple format support**: Supports loading OBJ, glTF/GLB, VOX, IQM, and M3D model formats via drag-and-drop.

## Public API Reference

### Package `models_loading`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads an initial OBJ model and PNG texture, computes the model's bounding box, and sets up a first-person camera. Each frame, it updates the camera, checks for dropped files (loading new models or textures as appropriate and unloading old ones), performs ray-based selection on left click, then renders the model in 3D with an optional bounding box highlight. The dropped files list is always unloaded after processing.

## Key Takeaways

- `@raylib.is_file_dropped` and `load_dropped_files` enable runtime asset hot-swapping, useful for tools and level editors.
- Always unload old resources before loading replacements to prevent memory leaks, and call `unload_dropped_files` after processing the file list.
- `get_ray_collision_box` is a lightweight first-pass selection test; for more precise picking, follow it with `get_ray_collision_mesh` as shown in the mesh_picking example.
