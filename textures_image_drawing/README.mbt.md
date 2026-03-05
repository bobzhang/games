# Textures: Image Drawing

This example demonstrates raylib's CPU-side image manipulation functions, including cropping, flipping, resizing, compositing, and drawing primitives and text onto images. When you run it, you see a single texture displayed on screen that was composited entirely in CPU memory from multiple image operations before being uploaded to the GPU.

## Build and Run

```bash
moon build --target native textures_image_drawing/
./_build/native/debug/build/textures_image_drawing/textures_image_drawing.exe
```

## Controls

No interactive controls -- runs automatically.

## What It Demonstrates

- **`image_crop`**: Crops an image to a specified rectangle region.
- **`image_flip_horizontal`**: Mirrors an image horizontally.
- **`image_resize`**: Resizes an image to new dimensions.
- **`image_draw`**: Composites one image onto another with source and destination rectangles, enabling scaling (the cat image is drawn at 1.5x scale onto the parrots image).
- **`image_draw_pixel`**, **`image_draw_circle_lines`**, **`image_draw_rectangle`**: Draws basic primitives directly onto an image in CPU memory.
- **`image_draw_text_ex`**: Renders text onto an image using a custom font loaded with `load_font`.
- **`load_texture_from_image`** / **`unload_image`**: The standard pattern of converting a fully composed CPU image into a GPU texture, then freeing the CPU copy.

## Public API Reference

### Package `textures_image_drawing`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads two images (cat and parrots) into CPU memory. The cat image is cropped, flipped horizontally, and resized to 150x200. It is then drawn onto the parrots image at 1.5x scale using `image_draw`. The parrots image is further cropped, and basic primitives (pixel, circle outline, rectangle) are drawn onto it. A custom font is loaded and used to draw text onto the image via `image_draw_text_ex`. The final composed image is converted to a single GPU texture. The render loop simply draws this pre-composed texture centered on screen.

## Key Takeaways

- Raylib's `image_*` functions allow extensive image manipulation entirely in CPU memory before uploading to the GPU, which is useful for pre-compositing complex visuals.
- The `image_draw` function works like a CPU-side blit operation with source and destination rectangles, supporting scaling of the drawn image.
- Loading a custom font and using `image_draw_text_ex` lets you burn text into images before they become textures.
