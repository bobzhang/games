# Textures: Logo Raylib

This example demonstrates the simplest possible texture loading and drawing workflow in raylib. When you run it, you see the raylib logo centered on screen with a text label below it, using `load_texture` for the most concise image-to-screen path.

## Build and Run

```bash
moon build --target native raylib_textures_logo_raylib/
./_build/native/debug/build/raylib_textures_logo_raylib/raylib_textures_logo_raylib.exe
```

## Controls

No interactive controls -- runs automatically.

## What It Demonstrates

- **`load_texture`**: The simplest way to load a texture -- loads an image file directly into a GPU texture in a single call, without going through the intermediate `Image` type. This is a shortcut compared to the two-step `load_image` + `load_texture_from_image` pattern.
- **`draw_texture`**: Draws a texture at a specified pixel position with a color tint.
- **`unload_texture`**: Frees GPU texture memory on exit.

## Public API Reference

### Package `raylib_textures_logo_raylib`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program uses `load_texture` to load the raylib logo PNG directly into a GPU texture (bypassing CPU-side image manipulation). The render loop draws the 256x256 texture centered in the 800x450 window and displays a text label. On exit, the texture is unloaded and the window is closed.

## Key Takeaways

- `load_texture` is the most concise way to get an image file onto the screen when no CPU-side manipulation is needed.
- For simple display-only use cases, `load_texture` is preferred over the two-step `load_image` + `load_texture_from_image` pattern.
- This example serves as the minimal template for any raylib texture program: init window, load texture, draw loop, cleanup.
