# Shaders - Raymarching

This example demonstrates a full-screen raymarching renderer implemented entirely in a fragment shader. The CPU side only draws a white rectangle while the fragment shader generates a procedural 3D scene using signed distance functions. When you run it, you see a raymarched scene with geometric shapes that you can navigate using first-person camera controls, with the window being resizable.

## Build and Run

```bash
moon build --target native raylib_shaders_raymarching/
./_build/native/debug/build/raylib_shaders_raymarching/raylib_shaders_raymarching.exe
```

## Controls

- **Mouse**: Look around (cursor is captured)
- **W/A/S/D**: Move camera forward/left/backward/right
- **E/Q**: Move camera up/down

## What It Demonstrates

- **Raymarching via fragment shader**: The entire 3D scene is rendered by a single fragment shader (`raymarching.fs`) that performs ray marching on signed distance functions -- no traditional geometry is used.
- **Shader uniforms for camera state**: Passes `viewEye` (camera position), `viewCenter` (camera target), `runTime` (elapsed time), and `resolution` (window size) to the shader each frame.
- **Resizable window support**: Uses `FlagWindowResizable` and checks `is_window_resized` each frame to update the resolution uniform, ensuring the shader output matches the current window dimensions.
- **First-person camera navigation**: Uses `update_camera` with `CameraFirstPerson` mode and `disable_cursor` to provide free exploration of the raymarched scene.
- **Byte serialization helpers**: Implements `float_to_bytes`, `vec2_to_uniform_bytes`, and `vec3_to_uniform_bytes` for converting scalar and vector values to the byte format required by `set_shader_value`.

## Public API Reference

### Package `raylib_shaders_raymarching`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes a resizable window, sets up a first-person camera, and loads the raymarching fragment shader. Shader uniform locations for view parameters, elapsed time, and resolution are resolved at startup. Each frame, the camera is updated from input, elapsed time accumulates, and all uniforms are pushed to the shader. If the window is resized, the resolution uniform is updated. A full-screen white rectangle is drawn inside shader mode, and the fragment shader computes the entire scene pixel by pixel. On exit, the shader is unloaded.

## Key Takeaways

- Raymarching shaders shift all rendering work to the GPU fragment shader -- the CPU side only needs to provide camera parameters and draw a full-screen quad.
- Supporting window resize for shader-based rendering requires detecting size changes and updating the resolution uniform accordingly.
- First-person camera integration works naturally with raymarching by passing camera position and target as shader uniforms rather than using traditional view/projection matrices.
