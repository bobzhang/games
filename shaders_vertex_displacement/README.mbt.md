# Shaders - Vertex Displacement

This example demonstrates vertex displacement using both a vertex shader and a fragment shader applied to a 3D plane mesh. A Perlin noise texture is used by the vertex shader to displace vertices along the normal, creating an animated terrain-like surface. When you run it, you see a large undulating plane with wave-like displacement that continuously animates over time, viewable with free camera controls.

## Build and Run

```bash
moon build --target native shaders_vertex_displacement/
./_build/native/debug/build/shaders_vertex_displacement/shaders_vertex_displacement.exe
```

## Controls

- **Mouse**: Look around (cursor is captured)
- **W/A/S/D**: Move camera forward/left/backward/right
- **E/Q**: Move camera up/down

## What It Demonstrates

- **Vertex displacement shader**: Loads both a vertex shader (`vertex_displacement.vs`) and a fragment shader (`vertex_displacement.fs`) that work together -- the vertex shader samples a noise texture to displace vertices, and the fragment shader applies corresponding coloring.
- **Perlin noise texture for displacement**: Generates a Perlin noise image with `gen_image_perlin_noise` and loads it as a texture to drive the vertex displacement pattern.
- **Low-level texture binding via `@rl` module**: Uses `@rl.enable_shader`, `@rl.active_texture_slot`, `@rl.enable_texture`, and `@rl.set_uniform_sampler` to manually bind the Perlin noise texture to texture slot 1 and associate it with the shader's `perlinNoiseMap` sampler.
- **High-subdivision plane mesh**: Creates a 50x50 unit plane with 50x50 subdivisions using `gen_mesh_plane`, providing enough vertices for smooth displacement.
- **Time-based animation**: Passes elapsed time to the shader's `time` uniform each frame, animating the displacement pattern.

## Public API Reference

### Package `shaders_vertex_displacement`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes a free-look camera and loads vertex and fragment displacement shaders. A 512x512 Perlin noise image is generated, converted to a texture, and bound to texture slot 1 via low-level `@rl` calls. A 50x50 plane mesh with 50x50 subdivisions is created and wrapped in a model, with the displacement shader assigned to its material. Each frame, the camera is updated from input, accumulated time is sent to the shader, and the plane model is drawn within shader mode. The vertex shader samples the noise texture offset by time to compute per-vertex displacement. On exit, the shader, model, and noise texture are unloaded.

## Key Takeaways

- Vertex displacement shaders require sufficient mesh subdivision to produce smooth results -- the 50x50 subdivision plane provides 2,500 quads for the displacement to operate on.
- Binding additional textures for vertex shader sampling requires low-level `@rl` module calls since raylib's high-level API primarily handles fragment shader textures.
- Combining procedurally generated noise textures with time-based offsets creates convincing animated terrain and water surface effects.
