# Textures: Image Loading

This example demonstrates the basic workflow of loading an image file from disk, converting it to a GPU texture, and displaying it on screen. When you run it, you see the raylib logo centered in the window with a descriptive text label below it.

## Build and Run

```bash
moon build --target native textures_image_loading/
./_build/native/debug/build/textures_image_loading/textures_image_loading.exe
```

## Controls

No interactive controls -- runs automatically.

## What It Demonstrates

- **`load_image`**: Loads an image file (PNG) from disk into CPU memory (RAM).
- **`load_texture_from_image`**: Converts a CPU-side image into a GPU texture (uploaded to VRAM), ready for rendering.
- **`unload_image`**: Frees the CPU-side image data after it has been converted to a texture, since it is no longer needed.
- **`draw_texture`**: Draws a texture at a specified screen position with a color tint.
- **`unload_texture`**: Cleans up the GPU texture when the program exits.

## Public API Reference

### Package `textures_image_loading`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program follows raylib's standard image-to-texture pipeline: `load_image` reads the PNG into CPU memory, `load_texture_from_image` uploads it to the GPU, and `unload_image` frees the CPU copy. The render loop draws the 256x256 texture centered on the 800x450 window. On exit, the texture is unloaded and the window is closed.

## Key Takeaways

- The two-step pattern of `load_image` then `load_texture_from_image` gives you a chance to manipulate the image in CPU memory before uploading to the GPU; this example skips manipulation but establishes the pattern.
- Always unload the CPU image after converting to a texture to avoid holding duplicate data in RAM.
- Textures must be loaded after window initialization because they require an OpenGL context.
