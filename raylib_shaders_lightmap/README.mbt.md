# Shaders: Lightmap

This example demonstrates lightmap-based lighting using a custom shader that combines a base albedo texture with a pre-baked lightmap texture. When you run it, you see a textured plane illuminated by red, blue, and green light splashes baked into a tiny 10x10 pixel lightmap, which is displayed as a preview in the corner of the screen.

## Build and Run

```bash
moon build --target native raylib_shaders_lightmap/
./_build/native/debug/build/raylib_shaders_lightmap/raylib_shaders_lightmap.exe
```

## Controls

- **Mouse** -- Orbital camera rotation and zoom

## What It Demonstrates

- **Lightmap shader technique**: Loads a custom `lightmap.vs`/`lightmap.fs` shader pair that samples two textures -- the base albedo from texcoords and the lightmap from texcoords2 -- and multiplies them together for the final color.
- **Secondary UV coordinates (texcoords2)**: Since `gen_mesh_plane` does not generate a second UV channel, the example manually uploads texcoords2 data using `mesh_setup_texcoords2`, providing the UVs that map the lightmap across the plane.
- **Lightmap baking to render texture**: Creates a small 10x10 render texture as the lightmap, draws colored light sprites into it using additive blending (`BlendAdditive`), then uses the result as a texture in the material. This simulates baked lighting.
- **Material and texture setup**: Uses `load_material_default` to create a material from scratch, assigns the lightmap shader, binds the albedo texture to `MaterialMapAlbedo`, and binds the lightmap render texture to `MaterialMapMetalness` (repurposed as the second texture slot for the shader).
- **Low-level mesh drawing**: Uses `draw_mesh` with a `Matrix::identity()` transform to draw the mesh with the custom material directly, rather than going through the model API.
- **Texture filtering**: Applies trilinear filtering to both the albedo texture (via `gen_texture_mipmaps` + `set_texture_filter`) and the lightmap render texture (via `set_render_texture_filter`) for smooth sampling.

## Public API Reference

### Package `raylib_shaders_lightmap`

> Single-package example.

No public API -- self-contained main function. The `floats_to_bytes` helper and `MapSize` constant are package-level but not exported.

## Architecture

The program initializes a window with MSAA 4x and sets up an orbital camera. A plane mesh is generated and augmented with manually specified texcoords2 data. The lightmap shader, base texture, and light sprite texture are loaded. A 10x10 render texture serves as the lightmap: three light sprites are drawn into it at different positions using additive blending, simulating overlapping colored lights. A default material is created, assigned the shader, and given the base texture and lightmap texture. Each frame, the camera is updated, the mesh is drawn with the custom material, and the lightmap is displayed as a scaled preview in the corner. On exit, the mesh, shader, and textures are unloaded.

## Key Takeaways

- Lightmaps provide efficient static lighting by pre-computing illumination into a texture, avoiding per-frame lighting calculations entirely -- the GPU just multiplies two texture samples.
- Secondary UV coordinates (texcoords2) allow the lightmap to have its own independent UV mapping, separate from the tiling albedo texture UVs.
- Additive blending when rendering into the lightmap causes overlapping lights to naturally combine their colors, mimicking real light accumulation.
