# Shapes: Top-Down Lights

This example demonstrates a top-down 2D lighting system with dynamic shadow casting using raylib's shapes, render textures, and custom OpenGL blend modes. When you run it, you see a checkerboard floor with rectangular obstacles, a draggable yellow light that casts realistic shadows behind the boxes, and the ability to place additional lights with right-click.

## Build and Run

```bash
moon build --target native raylib_shapes_top_down_lights/
./_build/native/debug/build/raylib_shapes_top_down_lights/raylib_shapes_top_down_lights.exe
```

## Controls

- **Left mouse button (hold and drag)**: Move the primary light (light #0)
- **Right mouse button**: Place a new light at the cursor position (up to 16 total)
- **F1**: Toggle shadow volume debug visualization

## What It Demonstrates

- **Shadow volume computation**: For each box edge facing away from a light, a shadow quad is projected outward by extending the edge vertices along the light-to-vertex direction using `Vector2::normalize` and `Vector2::scale`, creating trapezoidal shadow volumes via `compute_shadow_volume_for_edge`.
- **Custom OpenGL blend modes**: Uses `@rl.set_blend_factors` with `GL_SRC_ALPHA` and `GL_MIN`/`GL_MAX` blend equations to composite alpha masks. The light gradient is drawn with `BlendCustom` using `MIN` blending, and shadows are cut out using `MAX` blending.
- **Per-light render textures**: Each light has its own `RenderTexture` mask where the light gradient (`draw_circle_gradient`) and shadow geometry (`draw_triangle_fan`) are rendered. These masks are merged into a global `light_mask` that overlays the scene.
- **Collision detection for optimization**: `check_collision_point_rec` determines if a light is inside a box (invalid), and `check_collision_recs` skips boxes outside a light's bounds.
- **Procedural texture generation**: `gen_image_checked` creates a checkerboard pattern loaded as the ground texture via `load_texture_from_image`.

## Public API Reference

### Package `raylib_shapes_top_down_lights`

> Single-package example.

- `ShadowGeometry` -- Struct holding a `FixedArray` of 4 `Vector2` vertices forming a shadow quad.
- `ShadowGeometry::new() -> ShadowGeometry` -- Creates a zero-initialized shadow geometry.
- `LightInfo` -- Struct representing a light source with position, radius, active/dirty/valid flags, a render texture mask, and an array of shadow geometries.
- `LightInfo::new() -> LightInfo` -- Creates a default-initialized light info.
- `lights : FixedArray[LightInfo]` -- Global array of up to 16 lights.
- `move_light(slot : Int, x : Float, y : Float) -> Unit` -- Repositions a light and marks it dirty.
- `compute_shadow_volume_for_edge(slot : Int, sp : Vector2, ep : Vector2) -> Unit` -- Computes and stores a shadow quad for a given edge relative to a light.
- `draw_light_mask(slot : Int) -> Unit` -- Renders the light gradient and shadow cutouts into the light's render texture mask.
- `setup_light(slot : Int, x : Float, y : Float, radius : Float) -> Unit` -- Initializes a light at a given position with a given radius.
- `update_light(slot : Int, boxes : Array[Rectangle], count : Int) -> Bool` -- Recomputes shadows for a dirty light against all boxes; returns true if updated.
- `setup_boxes(boxes : Array[Rectangle]) -> Int` -- Populates the box array with 5 fixed and 15 random rectangles; returns the count.

## Architecture

The program initializes a window, generates a checkerboard background texture, creates a global light mask render texture, and sets up one initial light. In the main loop, mouse input moves light #0 or creates new lights. Each frame, dirty lights recompute their shadow volumes by iterating over box edges and projecting shadow quads. Each light's mask is rendered (gradient plus shadow cutouts) using custom blend modes, then all masks are merged into the global light mask. The scene is drawn as: background texture, then light mask overlay, then light position indicators and optional debug info. On exit, all textures and render textures are unloaded.

## Key Takeaways

- Custom OpenGL blend factors (`GL_MIN`, `GL_MAX`) enable advanced compositing effects like alpha-mask-based shadow systems that go beyond raylib's built-in blend modes.
- Per-light render textures allow each light's shadow mask to be computed independently and merged, making the system scalable to multiple light sources.
- Shadow volumes in 2D are computed by projecting box edges away from the light source, a technique that is both simple to implement and visually effective for top-down games.
