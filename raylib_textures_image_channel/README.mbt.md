# Textures: Image Channel Extraction

This example demonstrates how to extract individual color channels (red, green, blue, alpha) from an image using raylib's `image_from_channel` function. When you run it, you see the original image (fudesumi.png) displayed on the left over a checkered background, with the four extracted channel images (red, green, blue, alpha) shown as smaller thumbnails on the right, each tinted with its corresponding color.

## Build and Run

```bash
moon build --target native raylib_textures_image_channel/
./_build/native/debug/build/raylib_textures_image_channel/raylib_textures_image_channel.exe
```

## Controls

No interactive controls -- runs automatically.

## What It Demonstrates

- **`image_from_channel`**: Extracts a single color channel (0=red, 1=green, 2=blue, 3=alpha) from an image, producing a grayscale image representing that channel's intensity.
- **`image_alpha_mask`**: Applies an alpha mask to an image so that the extracted channels preserve the original image's transparency.
- **`gen_image_checked`**: Generates a procedural checkered background image to visualize transparency.
- **`load_texture_from_image`** / **`unload_image`**: Converts CPU-side images to GPU textures, then frees the CPU copies.
- **`draw_texture_pro`**: Draws textures with source and destination rectangles, enabling scaling. The channel thumbnails are drawn at half the size of the original using scaled destination rectangles.

## Public API Reference

### Package `raylib_textures_image_channel`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads the fudesumi image from disk and immediately extracts four channel images using `image_from_channel` for indices 0-3 (R, G, B, A). Each channel image receives the original's alpha mask via `image_alpha_mask` so transparency is preserved. A checkered background is generated with `gen_image_checked`. All six images are converted to GPU textures, and the CPU images are freed. The render loop draws the checkered background, the original image at 80% scale, and the four channel textures at 40% scale in a 2x2 grid layout, each tinted with its respective color (red, green, blue, white for alpha).

## Key Takeaways

- `image_from_channel` is useful for visualizing or manipulating individual RGBA channels of an image before uploading to the GPU.
- Always apply alpha masks to extracted channels if you want to preserve the original image's transparency in the channel visualization.
- `draw_texture_pro` with source/destination rectangles is the standard way to scale textures when drawing.
