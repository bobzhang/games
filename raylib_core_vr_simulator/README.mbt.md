# VR Simulator

This example demonstrates VR stereo rendering with lens distortion correction using raylib. It configures a virtual VR headset device, renders a 3D scene (a red cube on a grid) in stereo mode to a render texture, and applies a distortion fragment shader to simulate a VR headset display with lens distortion and chromatic aberration correction.

## Build and Run

```bash
moon build --target native raylib_core_vr_simulator/
./_build/native/debug/build/raylib_core_vr_simulator/raylib_core_vr_simulator.exe
```

## Controls

- **Mouse** -- look around (first-person camera)
- **WASD** -- move through the 3D scene

## What It Demonstrates

- `@raylib.VrDeviceInfo::new()` to configure VR headset parameters including resolution, screen size, eye-to-screen distance, lens separation, interpupillary distance, lens distortion values, and chromatic aberration correction
- `@raylib.load_vr_stereo_config()` to generate stereo rendering configuration from device parameters
- `@raylib.begin_vr_stereo_mode()` / `@raylib.end_vr_stereo_mode()` to render the scene twice (one per eye) with appropriate projection and view matrices
- `@raylib.load_shader()` to load a distortion fragment shader from file
- `@raylib.get_shader_location()` and `@raylib.set_shader_value()` to pass VR lens parameters to the shader as uniforms
- `@raylib.begin_shader_mode()` / `@raylib.end_shader_mode()` to apply the distortion shader when drawing the final output
- `@raylib.load_render_texture()` for off-screen rendering at the device's native resolution
- `@raylib.Camera3D::new()` and `@raylib.update_camera()` with `CameraFirstPerson` mode
- `@raylib.draw_cube()`, `@raylib.draw_cube_wires()`, and `@raylib.draw_grid()` for the 3D scene
- `@raylib.change_directory()` to set the working directory for resource loading
- A `float_array_to_bytes` helper to serialize float arrays into bytes for shader uniform passing

## Public API Reference

### Package `raylib_core_vr_simulator`

> Single-package example.

No public API -- self-contained main function. The helper function `float_array_to_bytes` converts a `FixedArray[Float]` to `Bytes` for passing to `set_shader_value`.

## Architecture

The program initializes VR device parameters, loads a stereo config, and loads a distortion shader with all necessary uniform parameters (lens centers, screen centers, scale, distortion, and chromatic aberration). Each frame: (1) the camera is updated with first-person controls, (2) the 3D scene is rendered in stereo mode to a render texture, (3) the render texture is drawn to the screen through the distortion shader. On exit, the stereo config, render texture, and shader are all properly unloaded.

## Key Takeaways

- Raylib provides a complete VR rendering pipeline: device configuration, stereo rendering, and post-process distortion correction, all accessible through high-level API calls.
- The render-to-texture then post-process-shader pattern is the standard approach for VR: render both eye views, then apply lens distortion correction.
- Shader uniforms for VR parameters must be set up correctly using `get_shader_location` and `set_shader_value`, requiring byte-level data serialization in MoonBit.
