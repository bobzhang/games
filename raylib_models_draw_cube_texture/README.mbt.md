# Models Draw Cube Texture

This example demonstrates how to draw textured cubes using low-level OpenGL-style vertex submission through raylib's `rl` (rlgl) module in MoonBit. When you run it, you see two textured cubes on a grid: one with the full texture applied to all faces, and one with only a sub-rectangle of the texture applied.

## Build and Run

```bash
moon build --target native raylib_models_draw_cube_texture/
./_build/native/debug/build/raylib_models_draw_cube_texture/raylib_models_draw_cube_texture.exe
```

## Controls

No interactive controls -- displays a static scene with a fixed camera.

## What It Demonstrates

- **Low-level rlgl vertex submission**: Uses `@rl.begin(@rl.Quads)`, `@rl.vertex3f`, `@rl.tex_coord2f`, `@rl.normal3f`, `@rl.color4ub`, and `@rl.end_()` to manually define textured quads for each cube face.
- **Texture binding via rlgl**: Binds and unbinds textures using `@rl.set_texture` with the texture ID obtained from `@raylib.get_texture_id`, and resets to texture 0 after drawing.
- **Full-texture cube**: The `draw_cube_texture` function maps the entire texture (UV 0,0 to 1,1) onto every face of the cube.
- **Sub-rectangle texture mapping**: The `draw_cube_texture_rec` function normalizes a source `Rectangle` against the texture dimensions (via `get_texture_width`/`get_texture_height`) to compute UV coordinates, allowing a portion of a texture atlas to be applied.
- **Manual normal specification**: Each face has its own normal vector set via `@rl.normal3f` for correct lighting calculations.

## Public API Reference

### Package `raylib_models_draw_cube_texture`

> Single-package example.

- `fn draw_cube_texture(texture : @raylib.Texture, position : @raylib.Vector3, width : Float, height : Float, length : Float, color : @raylib.Color) -> Unit` -- Draws a textured cube with the full texture mapped to each of its six faces using rlgl quads.
- `fn draw_cube_texture_rec(texture : @raylib.Texture, source : @raylib.Rectangle, position : @raylib.Vector3, width : Float, height : Float, length : Float, color : @raylib.Color) -> Unit` -- Draws a textured cube with a sub-rectangle of the texture mapped to each face, normalizing source coordinates against texture dimensions.

## Architecture

The program defines two helper functions for textured cube drawing that work at the rlgl level. Both functions bind the texture, emit 6 quads (front, back, top, bottom, right, left) with appropriate normals and UV coordinates, then unbind the texture. The main function sets up a fixed camera at (0, 10, 10), loads a texture (`cubicmap_atlas.png`), and renders one full-texture cube at (-2, 2, 0) and one sub-rectangle-textured cube at (2, 1, 0) each frame.

## Key Takeaways

- The `@rl` (rlgl) module provides OpenGL-style immediate-mode rendering when you need control beyond what raylib's high-level drawing functions offer.
- UV coordinates in rlgl are normalized (0.0 to 1.0); when using texture atlas sub-rectangles, divide pixel coordinates by texture dimensions to get normalized UVs.
- Each quad face requires 4 vertices with texture coordinates and normals specified in the correct winding order for proper rendering.
