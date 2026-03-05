# Shaders: Deferred Render

This example demonstrates a deferred rendering pipeline with a geometry buffer (G-buffer) pass and a deferred shading pass, supporting multiple colored point lights. When you run it, you see a scene with a floor plane and randomly positioned cubes illuminated by four toggleable colored lights. You can switch between viewing the final shaded result and the individual G-buffer textures (position, normal, albedo).

## Build and Run

```bash
moon build --target native shaders_deferred_render/
./_build/native/debug/build/shaders_deferred_render/shaders_deferred_render.exe
```

## Controls

- **Y Key** -- Toggle yellow light
- **R Key** -- Toggle red light
- **G Key** -- Toggle green light
- **B Key** -- Toggle blue light
- **1 Key** -- View position G-buffer texture
- **2 Key** -- View normal G-buffer texture
- **3 Key** -- View albedo G-buffer texture
- **4 Key** -- View final deferred shading result
- **Mouse** -- Orbital camera rotation and zoom

## What It Demonstrates

- **Deferred rendering pipeline**: Implements a two-pass rendering approach -- a geometry pass that writes position, normal, and albedo data into separate G-buffer textures, followed by a deferred shading pass that reads these textures and computes lighting in screen space.
- **Low-level rlgl framebuffer management**: Manually creates a framebuffer with `@rl.load_framebuffer`, attaches multiple color textures and a depth renderbuffer using `@rl.framebuffer_attach`, and activates multiple draw buffers with `@rl.active_draw_buffers(3)` for MRT (multiple render targets).
- **Floating-point textures**: Uses `PixelformatUncompressedR32g32b32` for position and normal textures (requiring float precision) and `PixelformatUncompressedR8g8b8a8` for albedo/specular.
- **Shader sampler binding**: Uses `@rl.set_uniform_sampler` to bind G-buffer textures to specific sampler slots in the deferred shader, and manually activates texture slots with `@rl.active_texture_slot` and `@rl.enable_texture`.
- **Depth buffer blitting**: Copies the depth buffer from the G-buffer framebuffer to the default framebuffer using `@rl.blit_framebuffer` so that forward-rendered objects (light spheres) correctly depth-test against the deferred scene.
- **G-buffer visualization**: Allows viewing individual G-buffer textures by creating temporary `Texture` handles from raw GPU texture IDs via `texture_from_id`.

## Public API Reference

### Package `shaders_deferred_render`

> Single-package example.

No public API -- self-contained main function. The `Light`, `GBuffer` structs, constants (`DeferredPosition`, `DeferredNormal`, `DeferredAlbedo`, `DeferredShading`, `MaxCubes`), and helper functions are package-level but not exported.

## Architecture

The program initializes a window, loads a G-buffer shader and a deferred shading shader, and constructs the G-buffer manually: a framebuffer with three color attachments (position, normal, albedo/specular) and a depth renderbuffer. Sampler uniforms in the deferred shader are bound to the corresponding texture slots. Models are assigned the G-buffer shader, lights are created against the deferred shader, and random cube positions/rotations are generated. Each frame: (1) the geometry pass draws all models into the G-buffer with color blending disabled, (2) the deferred shading pass binds the G-buffer textures and draws a fullscreen quad with the deferred shader, (3) the depth buffer is blitted to allow forward rendering, and (4) light indicator spheres are drawn in forward mode. Keys switch between viewing G-buffer textures and the final result. On exit, all framebuffers, textures, shaders, and models are unloaded.

## Key Takeaways

- Deferred rendering separates geometry processing from lighting computation, allowing efficient multi-light scenes since lighting cost is proportional to screen pixels rather than scene geometry.
- When mixing deferred and forward rendering (e.g., for light indicators), the depth buffer must be explicitly copied between framebuffers using `blit_framebuffer`.
- The rlgl API provides low-level OpenGL-like control (framebuffers, texture slots, shader enable/disable) when raylib's high-level API is insufficient for advanced rendering techniques.
