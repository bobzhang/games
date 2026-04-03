# Models Billboard

This example demonstrates billboard rendering in raylib using MoonBit -- the technique of drawing 2D textures in 3D space so they always face the camera. When you run it, you see two billboards on a grid: a static one that always faces the camera, and a rotating one that spins while staying locked to the Y axis. The camera orbits automatically.

## Build and Run

```bash
moon build --target native models_billboard/
./_build/native/debug/build/models_billboard/models_billboard.exe
```

## Controls

No interactive controls -- the camera orbits automatically and the rotating billboard spins continuously.

## What It Demonstrates

- **Basic billboard rendering**: Uses `@raylib.draw_billboard` to draw a texture that automatically faces the camera at a given 3D position with a specified size.
- **Advanced billboard rendering**: Uses `@raylib.draw_billboard_pro` for fine-grained control over the billboard, including source rectangle, up vector (Y-axis lock), size, origin point, and rotation angle.
- **Procedural texture generation**: Creates a checked pattern texture at runtime using `@raylib.gen_image_checked` and `@raylib.load_texture_from_image`, avoiding the need for external image files.
- **Depth-sorted draw order**: Computes squared distances from the camera to each billboard and draws the farther one first to ensure correct transparency/overlap behavior.
- **Orbital camera**: Uses `@raylib.CameraOrbital` mode for automatic camera rotation around the scene.

## Public API Reference

### Package `models_billboard`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes a window and sets up a perspective camera with orbital auto-rotation. A checked texture is generated procedurally from a 64x64 image. Two billboard positions are defined: one static at the origin and one offset for rotation. Each frame, the camera is updated, the rotation angle increments by 0.4 degrees, and squared distances from the camera to each billboard are computed to determine draw order. The scene renders in 3D mode with the grid and both billboards drawn back-to-front. The texture is unloaded on exit.

## Key Takeaways

- `draw_billboard` is the simplest way to render camera-facing quads in 3D, while `draw_billboard_pro` provides full control over rotation, source rectangle, and axis locking.
- Drawing billboards in back-to-front order (sorted by distance from camera) is essential for correct visual overlap when billboards may intersect.
- Procedural texture generation with `gen_image_checked` is a convenient way to create test textures without requiring external asset files.
