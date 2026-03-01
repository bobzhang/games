# Logo Raylib

This example demonstrates drawing the raylib logo using only basic shape primitives. When you run it, you see the raylib logo (a black-bordered white square with the text "raylib") rendered entirely with rectangles and text, with a note confirming it is not a texture.

## Build and Run

```bash
moon build --target native raylib_shapes_logo_raylib/
./_build/native/debug/build/raylib_shapes_logo_raylib/raylib_shapes_logo_raylib.exe
```

## Controls

No interactive controls -- runs automatically.

## What It Demonstrates

- **`draw_rectangle`** -- Used to create the logo's black outer border (256x256) and white inner area (224x224), centered on screen.
- **`draw_text`** -- Renders the "raylib" text centered within the logo and a small note below it.
- **Shape-based rendering** -- Shows that complex visual elements like logos can be composed from simple geometric primitives without loading external image assets.

## Public API Reference

### Package `raylib_shapes_logo_raylib`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program creates an 800x450 window and enters a simple render loop with no update logic. Each frame draws a black 256x256 rectangle centered on screen, overlays a white 224x224 rectangle (creating a 16-pixel border), renders "raylib" text positioned inside, and adds a small informational note. The loop continues until the window is closed.

## Key Takeaways

- Overlapping rectangles of different sizes and colors is a simple technique for creating bordered shapes without dedicated border-drawing functions.
- Simple static visuals require minimal code -- this entire example is under 45 lines, demonstrating the low overhead of a basic raylib MoonBit program.
- Centering elements on screen uses the pattern `screen_dimension / 2 - element_dimension / 2`.
