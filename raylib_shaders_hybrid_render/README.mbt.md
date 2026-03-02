# Shaders: Hybrid Render

This example demonstrates hybrid rendering that combines raymarched geometry (computed in a fragment shader) with traditional rasterized geometry, both writing to the same depth buffer so they occlude each other correctly. When you run it, you see raymarched spheres coexisting with rasterized cubes, with correct depth intersection between the two rendering methods.

## Build and Run

```bash
moon build --target native raylib_shaders_hybrid_render/
./_build/native/debug/build/raylib_shaders_hybrid_render/raylib_shaders_hybrid_render.exe
```

## Controls

- **Mouse** -- Orbital camera rotation and zoom

## What It Demonstrates

- **Raymarching in a fragment shader**: The `hybrid_raymarch.fs` shader uses signed distance functions (SDFs) to render implicit geometry (spheres) entirely in the fragment shader, computing both color and depth per pixel.
- **Depth buffer sharing between rendering methods**: Both the raymarch shader and the raster shader write to the same depth buffer, enabling correct occlusion between raymarched and rasterized geometry. The key requirement is that all shaders must write depth when any one of them does.
- **Writable depth render texture**: Uses `load_render_texture_depth_tex` to create a render texture with an explicitly writable depth texture (rather than a renderbuffer), which is necessary for the hybrid approach.
- **Camera FOV pre-calculation**: Computes `cam_dist = 1.0 / tan(fovy * 0.5 * deg2rad)` as a ray direction scale factor, passed to the raymarch shader so it can reconstruct correct view rays matching the rasterizer's projection.
- **Dual shader pipeline**: The raymarch shader runs first as a fullscreen quad (drawing the implicit geometry), then rasterized geometry is drawn on top with the raster shader, both sharing the same depth buffer within the render texture.

## Public API Reference

### Package `raylib_shaders_hybrid_render`

> Single-package example.

No public API -- self-contained main function. The `tanf`, `vec2_to_bytes`, and `vec3_to_bytes` helpers are package-level but not exported.

## Architecture

The program initializes a window, loads the raymarch and raster fragment shaders, and creates a render texture with a writable depth buffer. The camera's FOV is pre-calculated as a distance factor. Each frame, the camera is updated and its position and direction (scaled by `cam_dist`) are sent to the raymarch shader. Drawing proceeds into the render texture: first, depth testing is enabled and the raymarch shader draws a fullscreen quad computing the SDF scene; then, the raster shader draws traditional cubes and a grid in 3D mode. The completed render texture is drawn to the screen. On exit, the render texture and both shaders are unloaded.

## Key Takeaways

- Hybrid rendering (raymarching + rasterization) requires all shaders to write depth values so the GPU's depth test can correctly resolve occlusion between the two techniques.
- The camera's field of view must be communicated to the raymarch shader as a ray direction scale factor so that ray directions match the rasterizer's perspective projection.
- `load_render_texture_depth_tex` provides a render texture with a writable depth texture instead of a renderbuffer, which is essential when shaders need to both read and write depth.
