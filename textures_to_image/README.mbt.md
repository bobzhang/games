# Textures: Texture to Image

This example demonstrates the round-trip conversion between images (CPU/RAM) and textures (GPU/VRAM). When you run it, you see the raylib logo centered on screen -- but behind the scenes, the image data has traveled from disk to RAM, then to VRAM, back to RAM, and finally to VRAM again, proving that `load_image_from_texture` can retrieve pixel data from the GPU.

## Build and Run

```bash
moon build --target native textures_to_image/
./_build/native/debug/build/textures_to_image/textures_to_image.exe
```

## Controls

No interactive controls -- runs automatically.

## What It Demonstrates

- **`load_image`**: Loads an image file into CPU memory (RAM).
- **`load_texture_from_image`**: Uploads image data from CPU to GPU memory (RAM to VRAM).
- **`load_image_from_texture`**: Reads texture data back from GPU to CPU memory (VRAM to RAM). This is the key function demonstrated, enabling GPU-to-CPU pixel readback.
- **`unload_texture`** / **`unload_image`**: Proper cleanup at each stage to prevent memory leaks.
- **Full data lifecycle**: The example traces the complete path: disk to RAM (`load_image`) to VRAM (`load_texture_from_image`) to RAM (`load_image_from_texture`) to VRAM again (`load_texture_from_image`), with cleanup at each intermediate step.

## Public API Reference

### Package `textures_to_image`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads the raylib logo from disk into a CPU image, converts it to a GPU texture, and frees the CPU image. It then reads the texture back to a new CPU image using `load_image_from_texture`, frees the first texture, converts the retrieved image to a new texture, and frees the retrieved image. The render loop draws the final texture centered on screen. This round-trip proves that the GPU texture data can be faithfully recovered to CPU memory.

## Key Takeaways

- `load_image_from_texture` enables reading pixel data back from the GPU, which is useful for screenshots, post-processing on the CPU, or saving modified render targets.
- Each conversion between RAM and VRAM should be paired with proper cleanup of the source data to avoid holding duplicate copies.
- The round-trip pattern (RAM to VRAM to RAM to VRAM) demonstrates that image/texture conversions are lossless for uncompressed pixel formats.
