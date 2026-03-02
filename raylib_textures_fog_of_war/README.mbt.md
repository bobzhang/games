# Textures: Fog of War

This example demonstrates a fog-of-war effect using render textures, where a grid map is progressively revealed as a player moves through it. When you run it, you see a blue tile grid mostly hidden by black fog, with a small area around the red player square visible and previously visited areas shown through a semi-transparent haze.

## Build and Run

```bash
moon build --target native raylib_textures_fog_of_war/
./_build/native/debug/build/raylib_textures_fog_of_war/raylib_textures_fog_of_war.exe
```

## Controls

- **Arrow keys**: Move the player around the tile map

## What It Demonstrates

- **Render texture as fog overlay**: A small render texture (25x15 pixels, one pixel per tile) is drawn with black pixels for unexplored areas and 80%-opacity black for previously visited areas, then scaled up to cover the full map using `draw_render_texture_pro`.
- **Three-state fog system**: Each tile tracks a fog state in the `tile_fog` array: 0 (unexplored, fully black), 1 (currently visible, clear), or 2 (previously visited, semi-transparent black via `fade(@raylib.black, 0.8)`). Each frame, state 1 tiles are demoted to state 2 before the new visible area is computed.
- **Tile-based visibility**: Visibility is determined by the player's tile position plus a radius of 2 tiles (`player_tile_visibility = 2`), revealing a square area around the player.
- **Bilinear filtering on render texture**: `set_render_texture_filter` with `TextureFilterBilinear` smooths the edges of the fog overlay when scaled from tile resolution (25x15) to screen resolution (800x480).
- **Tile grid rendering**: The 25x15 map is drawn as colored rectangles (two shades of blue based on random `tile_ids`) with dark blue grid lines.

## Public API Reference

### Package `raylib_textures_fog_of_war`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes a 25x15 tile grid with random tile types and a fog state array (all 0 = unexplored). A 25x15 render texture is created for the fog overlay with bilinear filtering. Each frame: the player moves with arrow keys (clamped to map bounds), previously visible tiles (state 1) are demoted to visited (state 2), tiles within the player's 2-tile visibility radius are set to visible (state 1), and the fog render texture is updated via `begin_texture_mode`/`end_texture_mode`. The scene is drawn as: tile grid, player rectangle, then the scaled-up fog overlay via `draw_render_texture_pro`. Current tile position is displayed as text.

## Key Takeaways

- A render texture at tile resolution (one pixel per tile) scaled up with bilinear filtering creates a smooth fog-of-war effect with minimal rendering cost.
- The three-state fog model (unexplored/visible/visited) provides a classic strategy game fog effect where explored areas remain partially visible after the player moves away.
- `draw_render_texture_pro` with appropriate source/destination rectangles efficiently scales a low-resolution overlay to cover the full screen.
