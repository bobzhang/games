# Core 2D Camera Split Screen

This example demonstrates split-screen rendering with two independent 2D cameras using render textures. When you run it, the screen is divided vertically into two halves, each showing a different player's viewpoint. Player 1 (red) is controlled with WASD and Player 2 (blue) with arrow keys, and both players are visible in both viewports on a labeled grid.

## Build and Run

```bash
moon build --target native core_2d_camera_split_screen/
./_build/native/debug/build/core_2d_camera_split_screen/core_2d_camera_split_screen.exe
```

## Controls

- **W/S/A/D** -- Move Player 1 (red, shown in left viewport)
- **Up/Down/Left/Right Arrow Keys** -- Move Player 2 (blue, shown in right viewport)

## What It Demonstrates

- **`@raylib.load_render_texture`** -- Creating off-screen render targets for each half of the split screen.
- **`@raylib.begin_texture_mode`** and **`@raylib.end_texture_mode`** -- Rendering to an off-screen texture rather than directly to the screen.
- **`@raylib.draw_render_texture_rec`** -- Drawing the completed render textures side by side on the main framebuffer.
- **Flipped rectangle technique** -- The source rectangle uses a negative height (`-screen_height`) to correct the vertical flip inherent in OpenGL render textures.
- **Independent Camera2D instances** -- Each player has their own `Camera2D` with a target tracking their position, demonstrating how multiple cameras can coexist.
- **Grid with cell labels** -- A grid of lines with `[x,y]` coordinate labels provides spatial reference for both players.

## Public API Reference

### Package `core_2d_camera_split_screen`

> Single-package example.

No public API -- self-contained main function.

## Architecture

1. **Initialization** -- Window is created, two player rectangles and two Camera2D instances are set up, and two render textures (each half the screen width) are allocated. A flipped source rectangle is prepared for texture drawing.
2. **Main loop** -- Each frame updates player positions from input, updates each camera's target to follow its player, then renders the full scene (grid, labels, both players) twice: once to each render texture using `begin_texture_mode`. Finally, both textures are drawn side by side on the main screen with a dividing line.
3. **Cleanup** -- Both render textures are unloaded and the window is closed.

## Key Takeaways

- Render textures (`load_render_texture`) are the standard technique for split-screen rendering -- each viewport gets its own off-screen target that is composited onto the final frame.
- OpenGL render textures are vertically flipped compared to screen coordinates, so using a negative height in the source rectangle corrects the orientation when drawing them.
- The same scene is drawn independently for each camera, allowing each viewport to show different parts of the world simultaneously.
