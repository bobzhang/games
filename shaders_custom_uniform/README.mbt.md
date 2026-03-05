# Shaders: Custom Uniform

This example demonstrates post-processing with a custom shader uniform by applying a swirl distortion effect to a 3D scene. When you run it, you see a scene with colored cubes on a grid, distorted by a swirl effect that follows the mouse cursor position. The scene is first rendered to a render texture, then the render texture is drawn to the screen with the swirl shader applied.

## Build and Run

```bash
moon build --target native shaders_custom_uniform/
./_build/native/debug/build/shaders_custom_uniform/shaders_custom_uniform.exe
```

## Controls

- **Mouse Position** -- Move the swirl center
- **Mouse** -- Orbital camera rotation and zoom (for the 3D scene)

## What It Demonstrates

- **Render-to-texture pipeline**: Uses `load_render_texture` to create an offscreen framebuffer, draws the 3D scene into it with `begin_texture_mode`/`end_texture_mode`, then draws the result to the screen with a shader applied.
- **Custom shader uniform updates per frame**: Gets the `center` uniform location with `get_shader_location`, then updates it every frame with the mouse position via `set_shader_value`, passing a `Vector2` serialized to bytes.
- **Post-processing shader application**: Applies the swirl fragment shader to the entire rendered scene by drawing the render texture within `begin_shader_mode`/`end_shader_mode`, keeping the shader effect separate from the 3D rendering.
- **Render texture coordinate handling**: When drawing the render texture, the height is negated in the source rectangle (`-tex_height`) to flip the Y axis, which is necessary because render textures have an inverted Y coordinate system compared to the screen.

## Public API Reference

### Package `shaders_custom_uniform`

> Single-package example.

No public API -- self-contained main function. The `vec2_to_bytes` helper is package-level but not exported.

## Architecture

The program enables MSAA 4x, initializes a window, sets up an orbital camera, and loads the swirl fragment shader. A render texture matching the screen dimensions is created. The swirl center uniform location is cached and initialized to the screen center. Each frame, the camera is updated, the mouse position is sent to the shader as the swirl center (with Y flipped for texture coordinates), and the 3D scene (cubes + grid + text) is drawn into the render texture. Then the render texture is drawn to the screen within shader mode, applying the swirl distortion. Help text and FPS are drawn on top. On exit, the shader and render texture are unloaded.

## Key Takeaways

- The render-to-texture pattern (draw scene to FBO, then draw FBO to screen with shader) is the standard approach for full-screen post-processing effects in raylib.
- Render textures in OpenGL have an inverted Y axis compared to screen coordinates, requiring a negative height in the source rectangle when drawing them.
- Updating a shader uniform every frame (like the mouse position) is lightweight and enables interactive shader effects without any performance concern.
