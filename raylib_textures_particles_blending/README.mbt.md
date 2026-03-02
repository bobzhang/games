# Textures: Particles Blending

This example demonstrates a texture-based particle system that follows the mouse cursor, with switchable blending modes. When you run it, you see colorful flame-like particles spawning at the mouse position, falling with gravity, fading out over time, and you can toggle between alpha and additive blending with the space bar.

## Build and Run

```bash
moon build --target native raylib_textures_particles_blending/
./_build/native/debug/build/raylib_textures_particles_blending/raylib_textures_particles_blending.exe
```

## Controls

- **Mouse movement**: Controls where new particles are emitted
- **Space**: Toggle between alpha blending and additive blending

## What It Demonstrates

- **Particle pool pattern**: A fixed-size array of 200 `Particle` structs is pre-allocated and reused. Each frame, one inactive particle is activated at the mouse position, and active particles are updated (gravity, alpha fade, rotation).
- **`draw_texture_pro`**: Draws each particle as a rotated, scaled texture sprite with source/destination rectangles and an origin point for centered rotation.
- **`begin_blend_mode`** / **`end_blend_mode`**: Wraps particle drawing in a blend mode block. `BlendAlpha` produces standard transparency, while `BlendAdditive` makes overlapping particles glow brighter.
- **`fade`**: Applies per-particle alpha transparency that decreases over time, creating a smooth fade-out effect.
- **`get_random_value`**: Generates random colors, sizes, and rotation angles for particle variety.
- **MoonBit struct with mutable fields**: The `Particle` struct uses `mut` fields for position, alpha, rotation, and active state, allowing in-place updates each frame.

## Public API Reference

### Package `raylib_textures_particles_blending`

> Single-package example.

No public API -- self-contained main function. The `Particle` struct is defined privately:

```
struct Particle {
  mut position : @raylib.Vector2
  color : @raylib.Color
  mut alpha : Float
  size : Float
  mut rotation : Float
  mut active : Bool
}
```

## Architecture

At initialization, 200 particles are created with random colors, sizes, and rotations but marked inactive. The smoke flame texture is loaded. Each frame, the first inactive particle is activated at the current mouse position. Active particles fall with gravity, fade their alpha by 0.005 per frame, and rotate. When alpha reaches zero, the particle is deactivated for reuse. All active particles are drawn within a `begin_blend_mode`/`end_blend_mode` block using `draw_texture_pro` with per-particle scaling, rotation, and color fading.

## Key Takeaways

- Object pooling (pre-allocating and reusing particles) avoids per-frame allocation, which is critical for real-time particle systems.
- Additive blending makes overlapping semi-transparent particles appear to glow, producing fire and light effects, while alpha blending produces smoky, opaque trails.
- `draw_texture_pro` with an origin point set to the center of the scaled texture enables smooth rotation around the particle's position.
