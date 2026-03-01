# Textures: Source and Destination Rectangles

This example demonstrates the use of source and destination rectangles with `draw_texture_pro` to extract a portion of a texture, scale it, and continuously rotate it around a custom origin point. When you run it, you see the first frame of the scarfy sprite sheet scaled to 2x size, spinning at the center of the screen with crosshair lines marking the rotation pivot.

## Build and Run

```bash
moon build --target native raylib_textures_srcrec_dstrec/
./_build/native/debug/build/raylib_textures_srcrec_dstrec/raylib_textures_srcrec_dstrec.exe
```

## Controls

No interactive controls -- the sprite rotates automatically.

## What It Demonstrates

- **`draw_texture_pro`**: The most versatile texture drawing function, accepting:
  - **Source rectangle**: Selects which 128x128 portion of the 768x128 sprite sheet to draw (the first frame).
  - **Destination rectangle**: Defines where on screen and at what size (256x256, i.e., 2x scale) the sprite appears, positioned at the screen center.
  - **Origin**: Sets the rotation/scale pivot point relative to the destination rectangle. Set to (128, 128) -- the center of the destination rectangle -- so the sprite rotates around its center.
  - **Rotation**: An incrementing angle (1 degree per frame) for continuous spinning.
- **`draw_line`**: Draws horizontal and vertical crosshair lines through the destination rectangle's position to visualize the rotation pivot point.

## Public API Reference

### Package `raylib_textures_srcrec_dstrec`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The scarfy sprite sheet (768x128, 6 frames) is loaded. A source rectangle selects the first 128x128 frame. The destination rectangle is positioned at the screen center with 2x scaling (256x256). The origin is set to the center of the destination size (128, 128). Each frame, the rotation angle increments by 1 degree. The render loop calls `draw_texture_pro` with these parameters and draws crosshair lines through the pivot point for visualization.

## Key Takeaways

- `draw_texture_pro` is the go-to function for any texture drawing that involves scaling, rotation, or sub-region selection -- it combines all three in a single call.
- The origin parameter is relative to the destination rectangle, not the source. Setting it to the center of the destination rectangle makes the texture rotate around its visual center.
- Source and destination rectangles decouple the texture region from the screen region, enabling sprite sheet extraction and arbitrary scaling in one operation.
