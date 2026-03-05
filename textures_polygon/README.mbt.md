# Textures: Textured Polygon

This example demonstrates drawing a texture mapped onto an irregular polygon using low-level rlgl calls. When you run it, you see the cat texture mapped onto a 10-sided polygon that continuously rotates at the center of the screen.

## Build and Run

```bash
moon build --target native textures_polygon/
./_build/native/debug/build/textures_polygon/textures_polygon.exe
```

## Controls

No interactive controls -- the polygon rotates automatically.

## What It Demonstrates

- **Low-level rlgl rendering**: Uses `@rl.set_texture`, `@rl.begin(@rl.Quads)`, `@rl.tex_coord2f`, `@rl.vertex2f`, `@rl.color4ub`, and `@rl.end_()` to manually submit textured quads, bypassing raylib's higher-level drawing functions.
- **Custom texture mapping**: Manually defined UV coordinates (`texcoords`) map texture regions to polygon vertices.
- **Polygon triangulation via fan**: The polygon is drawn as a triangle fan from the center, with each quad consisting of the center point and two adjacent vertices.
- **`Vector2::rotate`**: Rotates each polygon vertex by an incrementing angle each frame to produce continuous rotation.
- **Importing `tonyfettes/raylib/rl`**: This example imports the low-level rlgl bindings in addition to the main raylib bindings, enabling direct OpenGL-like draw calls.

## Public API Reference

### Package `textures_polygon`

> Single-package example.

No public API -- self-contained main function. The following helper function and constants are defined privately:

- `draw_texture_poly(texture, center, points, texcoords, point_count, tint)` -- Draws a textured polygon using rlgl quad primitives with a triangle fan approach.
- `MaxPoints : Int = 11` -- Number of polygon vertices (10 sides plus closing vertex).
- `deg2rad : Float` -- Conversion factor from degrees to radians.

## Architecture

The program defines 11 UV coordinates (10 polygon vertices plus a closing point) and derives polygon vertex positions by scaling UVs from the center. The cat texture is loaded. Each frame, all vertex positions are rotated by an incrementing angle using `Vector2::rotate`. The `draw_texture_poly` function binds the texture via `@rl.set_texture`, begins a `Quads` draw mode, and iterates through adjacent vertex pairs to emit triangle fan quads from the polygon center, with corresponding UV coordinates for texture mapping.

## Key Takeaways

- When raylib's built-in drawing functions are insufficient (e.g., for arbitrary textured polygons), the rlgl layer provides direct access to OpenGL-like vertex submission.
- Triangle fan rendering from a center point works for convex polygons where all vertices are visible from the center without crossing the perimeter.
- UV coordinates define how the texture maps onto the polygon; they range from 0.0 to 1.0 and are independent of the polygon's world-space size.
