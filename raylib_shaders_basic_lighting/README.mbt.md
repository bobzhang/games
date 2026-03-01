# Shaders: Basic Lighting

This example demonstrates a basic forward lighting system using custom GLSL shaders with up to four colored point lights. When you run it, you see a white plane and cube illuminated by yellow, red, green, and blue point lights that can be individually toggled. The camera orbits the scene automatically, and the lighting responds to the camera position in real time.

## Build and Run

```bash
moon build --target native raylib_shaders_basic_lighting/
./_build/native/debug/build/raylib_shaders_basic_lighting/raylib_shaders_basic_lighting.exe
```

## Controls

- **Y Key** -- Toggle yellow light
- **R Key** -- Toggle red light
- **G Key** -- Toggle green light
- **B Key** -- Toggle blue light
- **Mouse** -- Orbital camera rotation and zoom

## What It Demonstrates

- **Custom lighting shader system**: Loads vertex and fragment shaders (`lighting.vs`/`lighting.fs`) and passes light parameters (enabled, type, position, target, color) as uniform arrays indexed by light number.
- **Light management in MoonBit**: Defines a `Light` struct storing both light properties and their corresponding shader uniform locations. The `create_light` function queries all uniform locations at creation time, and `update_light_values` pushes current values to the shader.
- **Shader uniform communication**: Demonstrates passing integers (`ShaderUniformInt`), vec3 (`ShaderUniformVec3`), and vec4 (`ShaderUniformVec4`) values to shaders using manual byte serialization via `int_to_bytes`, `vec3_to_bytes`, and `vec4_to_bytes` helpers.
- **Camera view position uniform**: Updates the `viewPos` shader uniform each frame with the camera's current position, which is essential for specular lighting calculations.
- **Shader mode rendering**: Uses `begin_shader_mode`/`end_shader_mode` to draw lit geometry with the custom shader, while light source spheres are drawn outside shader mode using default rendering.

## Public API Reference

### Package `raylib_shaders_basic_lighting`

> Single-package example.

No public API -- self-contained main function. The `Light` struct and helper functions (`create_light`, `update_light_values`, `int_to_bytes`, `vec3_to_bytes`, `vec4_to_bytes`) are package-level but not exported.

## Architecture

The program enables MSAA 4x, initializes a window, and loads the lighting shader. It queries the `viewPos` and `ambient` uniform locations and sets the ambient light level. Four point lights are created at different positions with different colors, each querying its own set of indexed uniform locations (e.g., `lights[0].position`). Each frame, the camera is updated, its position is sent to the shader, light toggle keys are checked, and all light values are pushed to the shader. Geometry is drawn in shader mode (plane + cube), then light source indicators (solid spheres when enabled, wireframe when disabled) are drawn in default mode. On exit, the shader is unloaded.

## Key Takeaways

- A complete lighting system requires passing the camera/view position to the shader each frame for correct specular calculations, not just light positions and colors.
- Storing shader uniform locations alongside light data in a struct avoids repeated `get_shader_location` calls per frame, which is important for performance.
- Colors must be normalized from 0-255 to 0.0-1.0 when passing them to shaders as vec4 uniforms.
