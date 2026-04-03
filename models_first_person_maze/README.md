# Models First Person Maze

This example demonstrates first-person navigation through a 3D maze generated from a cubicmap image, complete with wall collision detection and a minimap overlay. When you run it, you find yourself inside a textured maze that you can walk through using WASD and the mouse, with a minimap in the corner showing your position.

## Build and Run

```bash
moon build --target native models_first_person_maze/
./_build/native/debug/build/models_first_person_maze/models_first_person_maze.exe
```

## Controls

- **Mouse**: Look around (first-person camera)
- **WASD**: Move through the maze

## What It Demonstrates

- **Cubicmap-based level generation**: Loads a small image (`cubicmap.png`) and generates a 3D mesh using `@raylib.gen_mesh_cubicmap`, then applies a texture atlas to create a complete level.
- **First-person camera**: Uses `@raylib.CameraFirstPerson` mode with `disable_cursor` for immersive FPS-style navigation.
- **2D collision detection for 3D walls**: Simplifies wall collision to 2D by checking the player's XZ position against wall cells using `@raylib.check_collision_circle_rec`. When a collision is detected, the camera position is reverted to the previous frame's position.
- **Image pixel sampling**: Uses `@raylib.get_image_color` to read pixel colors from the cubicmap image at runtime, identifying walls (white pixels where `pixel.r == 0xFF`) for collision checks.
- **Minimap rendering**: Draws the cubicmap texture scaled up at the screen corner, with a red rectangle showing the player's current cell position using `@raylib.draw_texture_ex` and `draw_rectangle`.
- **Neighbor cell scanning**: Checks a 3x3 grid of cells around the player for wall collisions, with bounds checking to avoid out-of-range access.

## Public API Reference

### Package `models_first_person_maze`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads a cubicmap image and generates both a texture (for the minimap) and a 3D mesh. The mesh is converted to a model with a texture atlas applied. Each frame, the old camera position is saved, the camera is updated for first-person movement, then the player's grid cell is computed from the camera XZ position relative to the map origin. A 3x3 neighborhood of cells is scanned: for each white pixel (wall), a rectangle is constructed and tested against the player's position as a circle with radius 0.1. If any collision is found, the camera position reverts to the saved position. The 3D scene renders the maze model, followed by a 2D minimap overlay with the player indicator.

## Key Takeaways

- Simplifying 3D wall collision to 2D (circle-vs-rectangle on the XZ plane) is an effective and efficient approach for axis-aligned grid-based levels.
- The cubicmap image serves double duty: defining the 3D mesh geometry and providing collision data via pixel color sampling with `get_image_color`.
- Reverting camera position on collision (rather than resolving the collision) is a simple technique that prevents the player from walking through walls.
