# Core 3D Camera Split Screen

This example demonstrates split-screen 3D rendering with two players, each having their own camera and render texture. When you run it, the screen is divided vertically into two halves showing a world of cube trees on a plane. Player 1 moves along the Z axis with W/S, and Player 2 moves along the X axis with Up/Down arrows. Both player cubes are visible in both viewports.

## Build and Run

```bash
moon build --target native core_3d_camera_split_screen/
./_build/native/debug/build/core_3d_camera_split_screen/core_3d_camera_split_screen.exe
```

## Controls

- **W/S** -- Move Player 1 forward/backward (left viewport)
- **Up/Down Arrow Keys** -- Move Player 2 forward/backward (right viewport)

## What It Demonstrates

- **`@raylib.load_render_texture`** -- Creating off-screen 3D render targets for each half of the split screen.
- **`@raylib.begin_texture_mode`** / **`@raylib.end_texture_mode`** -- Rendering a complete 3D scene to an off-screen texture.
- **`@raylib.draw_render_texture_rec`** -- Compositing both viewport textures side by side on the main framebuffer.
- **Independent Camera3D instances** -- Each player has their own `Camera3D` with separate position and target, moving independently along different axes.
- **Flipped rectangle technique** -- Negative height in the source rectangle corrects OpenGL's inverted Y-axis in render textures.
- **`@raylib.get_frame_time`** -- Frame-time-based movement to ensure consistent speed regardless of frame rate.
- **3D world rendering** -- A grid of cube "trees" (green tops on brown trunks) on a beige plane, drawn identically for both viewports.
- **Camera position as player position** -- Each player's position is represented by their camera's position, with colored cubes drawn at those positions visible in both views.

## Public API Reference

### Package `core_3d_camera_split_screen`

> Single-package example.

No public API -- self-contained main function.

## Architecture

1. **Initialization** -- Window is created, two Camera3D instances are configured (Player 1 looking along Z, Player 2 looking along X), and two half-width render textures are allocated.
2. **Main loop** -- Each frame moves cameras based on input (W/S for Player 1 along Z, Up/Down for Player 2 along X) using frame-time scaling. The full 3D scene (plane, tree grid, player cubes) is rendered twice -- once to each render texture. Both textures are then drawn side by side with a dividing line.
3. **Cleanup** -- Both render textures are unloaded and the window is closed.

## Key Takeaways

- Split-screen 3D works the same way as 2D split-screen: render each viewport to a separate texture, then composite them onto the screen.
- Moving a Camera3D (both position and target together) along an axis creates the effect of a player moving through the world.
- Frame-time-based movement (`get_frame_time`) ensures consistent movement speed even if the frame rate varies.
