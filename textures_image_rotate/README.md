# Textures: Image Rotation

This example demonstrates raylib's CPU-side image rotation function. When you run it, you see the raylib logo rotated by different angles (45, 90, and -90 degrees), and you can cycle between the three rotated versions by clicking the mouse or pressing the right arrow key.

## Build and Run

```bash
moon build --target native textures_image_rotate/
./_build/native/debug/build/textures_image_rotate/textures_image_rotate.exe
```

## Controls

- **Left mouse button** or **Right arrow key**: Cycle to the next rotated image

## What It Demonstrates

- **`image_rotate`**: Rotates an image by an arbitrary angle in degrees. Positive values rotate clockwise. The output image dimensions may change (e.g., a 256x256 image rotated 45 degrees produces approximately a 362x362 image).
- **`load_image`**: Loads the same source image three times to produce independent copies for different rotations.
- **`load_texture_from_image`**: Converts each rotated image to a GPU texture.
- **Hardcoded dimensions**: Since the `Texture` type is opaque in this MoonBit binding (width/height are not directly accessible), the rotated image dimensions are hardcoded based on known input sizes.

## Public API Reference

### Package `textures_image_rotate`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads the raylib logo image three times and applies `image_rotate` with angles of 45, 90, and -90 degrees. Each rotated image is converted to a texture and stored in an array. A `current_texture` index tracks which rotation to display. The render loop checks for mouse clicks or right arrow key presses to advance the index (wrapping with modulo), then draws the current texture centered on screen using precomputed width/height arrays for each rotation.

## Key Takeaways

- `image_rotate` operates on CPU-side images before texture upload, meaning rotation is performed once at load time rather than every frame.
- Non-orthogonal rotations (like 45 degrees) produce larger output images because the rotated bounding box expands to contain the full image without clipping.
- When texture dimensions cannot be queried at runtime, hardcoding known sizes based on the input image is a practical workaround.
