# Models: Point Rendering

This example demonstrates point cloud rendering in raylib, comparing two approaches: GPU-accelerated `draw_model_points` and the CPU-driven per-point `draw_point_3d` method. When you run it, you see a spherical point cloud with HSV-based rainbow coloring orbiting around a wireframe reference sphere. You can increase or decrease the number of points (from 1,000 up to 10 million) and toggle between the two rendering methods to observe the performance difference.

## Build and Run

```bash
moon build --target native models_point_rendering/
./_build/native/debug/build/models_point_rendering/models_point_rendering.exe
```

## Controls

- **Up Arrow** -- Increase point count by 10x (max 10,000,000)
- **Down Arrow** -- Decrease point count by 10x (min 1,000)
- **Spacebar** -- Toggle between `DrawModelPoints()` and `DrawPoint3D()` rendering modes
- **Mouse** -- Orbital camera rotation (automatic via `CameraOrbital`)

## What It Demonstrates

- **Point cloud generation using spherical coordinates**: The `gen_point_cloud` function generates random points within a sphere using spherical coordinates (theta, phi, r), converting to Cartesian (x, y, z). Colors are assigned via `color_from_hsv` based on radius for a rainbow gradient effect.
- **Low-level mesh construction**: Builds vertex and color byte arrays manually by reinterpreting floats as little-endian bytes, then calls `gen_mesh_from_points` to create a GPU mesh and `load_model_from_mesh` to wrap it in a drawable model.
- **GPU vs CPU point rendering comparison**: `draw_model_points` uploads points once to the GPU for efficient rendering, while `draw_point_3d` draws each point individually per frame -- demonstrating why batched GPU rendering is critical for large datasets.
- **Dynamic mesh reloading**: When the point count changes, the old model is unloaded via `unload_model` and a new point cloud is generated and uploaded.

## Public API Reference

### Package `models_point_rendering`

> Single-package example.

No public API -- self-contained main function. The helper function `gen_point_cloud` and constants `MaxPoints`, `MinPoints`, and `pi` are package-level but not exported.

## Architecture

Initialization creates a window, an orbital camera, and an initial point cloud of 1,000 points. The `gen_point_cloud` function generates random spherical positions, computes HSV colors, packs vertex/color data into byte arrays, and produces a mesh via `gen_mesh_from_points`. Each frame, the update phase checks for point count changes (regenerating the cloud if needed) and rendering mode toggles. The draw phase either calls `draw_model_points` for the GPU path or iterates through all points calling `draw_point_3d` for the CPU path. A wireframe sphere and UI text overlay provide visual context. Cleanup unloads the model and closes the window.

## Key Takeaways

- For large point clouds, uploading geometry to the GPU once via mesh/model APIs vastly outperforms per-frame CPU-side point drawing.
- MoonBit's `FixedArray::unsafe_reinterpret_as_bytes` provides a way to construct raw byte buffers for GPU upload, similar to C-style memory reinterpretation.
- Spherical coordinate generation combined with HSV coloring is an elegant approach for creating visually appealing point cloud distributions.
