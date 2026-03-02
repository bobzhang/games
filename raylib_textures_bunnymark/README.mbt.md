# Textures: Bunnymark

This example is a classic rendering performance benchmark that spawns thousands of bouncing bunny sprites to stress-test raylib's rendering pipeline. When you run it, you see bunnies spawning from the mouse cursor, bouncing off screen edges, with real-time counters for bunny count, batched draw calls, and FPS.

## Build and Run

```bash
moon build --target native raylib_textures_bunnymark/
./_build/native/debug/build/raylib_textures_bunnymark/raylib_textures_bunnymark.exe
```

## Controls

- **Left mouse button (hold)**: Spawn 100 bunnies per frame at the cursor position

## What It Demonstrates

- **Mass sprite rendering**: Up to 50,000 bunny sprites are drawn per frame using `draw_texture`, each with a unique position and color tint, testing GPU draw throughput.
- **Batched rendering**: raylib internally batches `draw_texture` calls. The example calculates and displays the number of batched draw calls as `1 + bunnies_count / max_batch_elements` where `max_batch_elements = 8192`.
- **Simple physics simulation**: Each `Bunny` struct has `position` and `speed` vectors. Positions are updated by adding speed each frame, and speed components are negated upon hitting screen edges (bounce).
- **Dynamic entity spawning**: Holding the mouse button spawns 100 bunnies per frame at `get_mouse_position()` with randomized speeds (range -250 to 250, divided by 60) and random RGB colors (50-240, 80-240, 100-240).
- **MoonBit string interpolation for HUD**: The status bar uses `\{bunnies_count}` and `\{1 + bunnies_count / max_batch_elements}` for live statistics.

## Public API Reference

### Package `raylib_textures_bunnymark`

> Single-package example.

- `Bunny` -- Struct with `mut position : Vector2`, `mut speed : Vector2`, and `color : Color` fields for each bunny sprite.

## Architecture

The program loads a small bunny texture (`wabbit_alpha.png`, 32x32) and allocates an array of 50,000 `Bunny` structs. Each frame, holding the left mouse button adds up to 100 new bunnies with random velocities and colors. All active bunnies have their positions updated (position += speed) with edge-bounce collision (negate speed on boundary hit). The draw phase renders all bunnies with `draw_texture` in a loop and overlays a black header bar with bunny count, batch count, and FPS via `draw_fps`.

## Key Takeaways

- Bunnymark is a classic rendering benchmark; MoonBit with raylib can handle tens of thousands of textured sprites at interactive frame rates thanks to automatic draw batching.
- raylib's internal batch system groups multiple `draw_texture` calls into fewer GPU draw calls, and the batch element limit (8192) determines how many sprites fit per batch.
- Simple per-entity physics (position += velocity with edge bounce) demonstrates the basic game object update pattern used in particle systems and real games.
