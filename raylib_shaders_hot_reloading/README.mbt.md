# Shaders: Hot Reloading

This example demonstrates hot-reloading of fragment shaders at runtime by monitoring file modification times. When you run it, a fullscreen shader effect is rendered, and you can edit the shader source file externally; the changes are picked up either automatically or on mouse click, and the shader is reloaded without restarting the application.

## Build and Run

```bash
moon build --target native raylib_shaders_hot_reloading/
./_build/native/debug/build/raylib_shaders_hot_reloading/raylib_shaders_hot_reloading.exe
```

## Controls

- **A Key** -- Toggle between automatic and manual shader reloading
- **Left Mouse Button** -- Manually trigger shader reload check (in manual mode)

## What It Demonstrates

- **Shader hot reloading**: Uses `get_file_mod_time` to monitor the fragment shader file's modification timestamp. When the timestamp changes, the shader is reloaded with `load_shader`, validated with `is_shader_valid`, and the old shader is unloaded -- all without restarting the application.
- **Time and mouse uniforms**: Passes `time` (accumulated frame time), `mouse` (cursor position), and `resolution` (screen dimensions) as uniforms to the shader, enabling animated and interactive shader effects.
- **Auto vs manual reload modes**: Supports both continuous monitoring (checking every frame) and manual trigger (checking only on mouse click), toggled with the A key.
- **Shader uniform re-acquisition**: After reloading a shader, all uniform locations must be re-queried with `get_shader_location` since the new shader program may have different location assignments.
- **Fullscreen shader canvas**: Draws a fullscreen rectangle in shader mode to execute the fragment shader across every pixel.

## Public API Reference

### Package `raylib_shaders_hot_reloading`

> Single-package example.

No public API -- self-contained main function. The `float_to_bytes` and `vec2_to_bytes` helpers are package-level but not exported.

## Architecture

The program initializes a window, loads the fragment shader from a file, and caches the modification time and uniform locations for `resolution`, `mouse`, and `time`. Each frame, accumulated time and mouse position are pushed to the shader. In auto mode (or on mouse click in manual mode), the file's modification time is checked; if it has changed, a new shader is loaded and validated before replacing the old one, with all uniform locations re-queried. A fullscreen rectangle is drawn in shader mode to display the effect. Status text shows the current reload mode and last modification timestamp. On exit, the shader is unloaded.

## Key Takeaways

- Shader hot reloading dramatically speeds up visual development by allowing real-time iteration on shader code without recompiling or restarting the host application.
- After reloading a shader, all uniform locations must be re-acquired since `get_shader_location` returns indices specific to the compiled shader program.
- Validating the newly loaded shader with `is_shader_valid` before replacing the old one prevents crashes from syntax errors in the edited shader file.
