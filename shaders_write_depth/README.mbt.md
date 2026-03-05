# Shaders - Write Depth Buffer

This example demonstrates writing custom values to the depth buffer using a fragment shader. The shader inverts the depth buffer by writing `1 - gl_FragCoord.z` to `gl_FragDepth`, which reverses the normal depth ordering of objects. When you run it, you see two cubes (one purple, one yellow) rendered with inverted depth -- objects that would normally be behind appear in front, creating a visually counterintuitive depth effect.

## Build and Run

```bash
moon build --target native shaders_write_depth/
./_build/native/debug/build/shaders_write_depth/shaders_write_depth.exe
```

## Controls

- Camera orbits automatically around the scene (`CameraOrbital` mode)

## What It Demonstrates

- **Custom depth buffer writing**: Uses a `write_depth.fs` shader that writes inverted depth values (`gl_FragDepth = 1 - gl_FragCoord.z`), reversing the default near-to-far depth ordering.
- **Writable depth render texture**: Uses `load_render_texture_depth_tex` (and its corresponding `unload_render_texture_depth_tex`) to create a framebuffer with a writable depth texture attachment, as opposed to the standard render texture.
- **Render-to-texture with custom depth**: Renders the 3D scene into the custom render texture with the depth-writing shader active, then draws the result to screen.
- **Render texture Y-flip**: Uses negative height in `draw_render_texture_rec` to flip the OpenGL-origin render texture for correct screen display.

## Public API Reference

### Package `shaders_write_depth`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads a depth-writing fragment shader and creates a custom render texture with a writable depth texture attachment. An orbital camera is configured. Each frame, the scene (two cubes with wireframes, plus a grid) is rendered into the custom render texture with the shader active -- the shader inverts the depth values during this pass. The render texture is then drawn to the screen as a full-screen quad with the standard Y-flip. On exit, the render texture (with depth), shader, and window are cleaned up using the specialized unload function.

## Key Takeaways

- Writing to `gl_FragDepth` in a fragment shader overrides the default depth test behavior, enabling effects like inverted depth, depth peeling, and custom depth-based compositing.
- The specialized `load_render_texture_depth_tex`/`unload_render_texture_depth_tex` functions are required when the depth buffer needs to be writable or readable as a texture.
- Depth buffer manipulation is a fundamental technique for advanced rendering effects including shadow mapping, order-independent transparency, and depth-based post-processing.
