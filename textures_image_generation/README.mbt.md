# Textures: Procedural Image Generation

This example demonstrates raylib's procedural image generation functions, showcasing nine different algorithmically generated textures. When you run it, you see one full-screen procedural texture at a time, and you can cycle through all nine types by clicking the mouse or pressing the right arrow key.

## Build and Run

```bash
moon build --target native textures_image_generation/
./_build/native/debug/build/textures_image_generation/textures_image_generation.exe
```

## Controls

- **Left mouse button** or **Right arrow key**: Cycle to the next procedural texture

## What It Demonstrates

- **`gen_image_gradient_linear`**: Generates linear gradient images at different angles (0 degrees for vertical, 90 for horizontal, 45 for diagonal).
- **`gen_image_gradient_radial`**: Generates a radial gradient from center outward.
- **`gen_image_gradient_square`**: Generates a square-shaped gradient from center outward.
- **`gen_image_checked`**: Generates a checkerboard pattern with two alternating colors.
- **`gen_image_white_noise`**: Generates random white noise with a configurable density factor.
- **`gen_image_perlin_noise`**: Generates Perlin noise with configurable offset and scale.
- **`gen_image_cellular`**: Generates a cellular/Voronoi noise pattern with a configurable tile size.
- **`load_texture_from_image`** / **`unload_image`**: Converts each generated image to a GPU texture and frees the CPU copy.

## Public API Reference

### Package `textures_image_generation`

> Single-package example.

No public API -- self-contained main function.

## Architecture

At initialization, nine procedural images are generated using different `gen_image_*` functions and converted to GPU textures stored in an array. The CPU images are immediately freed. A `current_texture` index tracks which texture to display. The render loop checks for mouse clicks or key presses to advance the index (wrapping around with modulo), draws the current texture full-screen, and displays a label indicating the current texture type using a `match` expression.

## Key Takeaways

- Raylib provides a rich set of `gen_image_*` functions for creating procedural textures without any external image files, useful for backgrounds, patterns, and placeholders.
- Linear gradients accept an angle parameter (0 = vertical, 90 = horizontal, 45 = diagonal) to control direction.
- MoonBit's `match` expression provides a clean way to handle indexed state for displaying different labels.
