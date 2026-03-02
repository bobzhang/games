# Textures: Image Processing

This example demonstrates various CPU-side image processing operations available in raylib, including grayscale conversion, color tinting, inversion, contrast adjustment, brightness adjustment, Gaussian blur, and image flipping. When you run it, you see a menu of nine processing options on the left and the processed parrots image on the right, updating in real time as you select different operations.

## Build and Run

```bash
moon build --target native raylib_textures_image_processing/
./_build/native/debug/build/raylib_textures_image_processing/raylib_textures_image_processing.exe
```

## Controls

- **Up/Down arrow keys**: Cycle through the processing options
- **Mouse click** on a menu item: Select that processing option directly

## What It Demonstrates

- **`image_color_grayscale`**: Converts an image to grayscale.
- **`image_color_tint`**: Applies a color tint (green in this example) to an image.
- **`image_color_invert`**: Inverts all colors in an image.
- **`image_color_contrast`**: Adjusts the contrast level of an image (uses -40.0 to reduce contrast).
- **`image_color_brightness`**: Adjusts brightness (uses -80 to darken the image).
- **`image_blur_gaussian`**: Applies a Gaussian blur with a specified radius (10 in this example).
- **`image_flip_vertical`** / **`image_flip_horizontal`**: Flips the image along the vertical or horizontal axis.
- **`image_copy`**: Creates a fresh copy of the original image before each processing operation to enable non-destructive switching.
- **`load_image_colors`** / **`update_texture`**: Extracts pixel color data from a processed image and uploads it to an existing GPU texture without recreating the texture object.
- **`image_format`**: Sets the image pixel format to `PixelformatUncompressedR8g8b8a8` for consistent processing.
- **`check_collision_point_rec`**: Detects mouse hover over menu item rectangles for interactive selection.

## Public API Reference

### Package `raylib_textures_image_processing`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads the parrots image and sets its format to RGBA8888. A texture is created from the original. When the user selects a new processing option (via keyboard or mouse), the program copies the original image with `image_copy`, applies the selected processing function via a `match` expression, extracts pixel colors with `load_image_colors`, and updates the existing texture with `update_texture`. The render loop draws a column of labeled toggle rectangles on the left (highlighting the current selection and mouse hover state) and the processed texture on the right.

## Key Takeaways

- The `image_copy` + process + `update_texture` pattern avoids recreating textures from scratch, which is more efficient for interactive image processing previews.
- `load_image_colors` and `update_texture` together allow you to modify pixel data on the CPU and push changes to an existing GPU texture.
- `check_collision_point_rec` combined with mouse state tracking is a simple way to implement clickable UI elements without a GUI library.
