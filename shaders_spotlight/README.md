# Shaders - Spotlight

This example demonstrates a spotlight rendering effect using a fragment shader with multiple dynamic light spots. It simulates a star field with bouncing texture sprites, all obscured by darkness except where spotlights illuminate. When you run it, you see a dark scene with animated stars and raylib mascot sprites, revealed by three circular spotlights -- one following the mouse and two bouncing autonomously.

## Build and Run

```bash
moon build --target native shaders_spotlight/
./_build/native/debug/build/shaders_spotlight/shaders_spotlight.exe
```

## Controls

- **Mouse movement**: Controls the position of the first spotlight

## What It Demonstrates

- **Multi-spotlight shader**: A fragment shader (`spotlight.fs`) accepts an array of spot light definitions (position, inner radius, outer radius) and composites their illumination, creating smooth circular light cones over a dark overlay.
- **Shader array uniforms**: Uses indexed uniform names (`spots[0].pos`, `spots[0].inner`, etc.) with `get_shader_location` and `set_shader_value` to pass per-spot parameters to the shader.
- **Particle-like star system**: Implements `Star` structs with velocity and position, resetting when they leave the screen, creating a streaming star field effect from the screen center.
- **Mouse-driven interactivity**: The first spotlight tracks the mouse position (with Y-axis inversion for shader coordinate space), while the others bounce off screen edges.
- **Struct-based data modeling**: Uses `Spot` and `Star` structs with mutable fields for position and velocity, updated each frame.

## Public API Reference

### Package `shaders_spotlight`

> Single-package example.

No public API -- self-contained main function. The `Spot` and `Star` structs and helper functions (`reset_star`, `update_star`, `abs_float`) are package-private.

## Architecture

Initialization creates 400 stars with random velocities emanating from the screen center, pre-advancing them to spread them across the screen. Three spot lights are configured with random positions, velocities, and increasing radii. The spotlight shader receives screen width and per-spot parameters (position, inner/outer radius).

Each frame: stars are updated (moving and wrapping); spot positions are updated (mouse for spot 0, bouncing for others); spot positions are pushed to the shader as vec2 uniforms. The scene is drawn in layers: first stars as small rectangles, then animated raylib mascot sprites using trigonometric positioning, and finally a full-screen rectangle through the spotlight shader that darkens everything outside the spotlight cones. On exit, textures and shader are unloaded.

## Key Takeaways

- Spotlight effects can be achieved with a full-screen shader overlay that selectively reveals underlying content based on distance from light positions.
- Indexed shader uniform names (`spots[N].property`) allow passing array-of-struct data to GLSL shaders from the application side.
- Combining simple particle systems (stars) with shader-based lighting creates visually rich scenes with minimal geometry.
