# Text: Draw 3D

This example demonstrates how to render 2D text as textured quads in a 3D world using low-level rlgl calls. When you run it, you see editable text floating above a colored cube in 3D space with a wave animation effect, an orbital camera, and various interactive controls for font size, spacing, layers, and multicolor modes.

## Build and Run

```bash
moon build --target native raylib_text_draw_3d/
./_build/native/debug/build/raylib_text_draw_3d/raylib_text_draw_3d.exe
```

## Controls

- **Mouse**: Orbital camera rotation (or free camera when spin is off)
- **Left/Right arrow keys**: Adjust font size
- **Up/Down arrow keys**: Adjust font spacing
- **Page Up/Page Down**: Adjust line spacing
- **Home/End**: Remove/add text layers (up to 32)
- **Insert/Delete (hold)**: Decrease/increase layer distance
- **Tab**: Toggle multicolor mode
- **F1**: Toggle letter boundary wireframes
- **F2**: Toggle text bounding box wireframe
- **F3**: Toggle between orbital and free camera
- **Left mouse click on cube**: Randomize text color
- **Backspace**: Delete last character
- **Enter**: Add newline to text
- **Type characters**: Append to the displayed text
- **`~~` in text**: Toggle wave animation for enclosed text segments

## What It Demonstrates

- **Low-level rlgl text rendering in 3D**: Uses `@rl.begin(Quads)`, `@rl.vertex3f`, `@rl.tex_coord2f`, and `@rl.normal3f` to manually construct textured quads for each glyph, placing them as flat surfaces in 3D space.
- **Glyph atlas sampling**: Retrieves per-glyph texture coordinates from the font atlas using `get_glyph_info` and `get_glyph_atlas_rec`, and maps them onto 3D quads with `@rl.set_texture`.
- **Wave text animation**: A `WaveTextConfig` struct parameterizes sinusoidal displacement along X, Y, and Z axes via `@math.sinf`, creating a wave effect on individual characters. The `~~` delimiter toggles wave mode within a string.
- **Alpha discard shader**: An embedded GLSL 330 fragment shader discards fully transparent pixels (`if (texelColor.a == 0.0) discard`), solving depth buffer issues with transparent font textures in 3D.
- **Multi-layer text**: The same text can be rendered multiple times at slightly different Y positions to create a stacked/extruded appearance.
- **3D camera modes**: Switches between `CameraOrbital` (auto-spin) and `CameraFree` (WASD + mouse) via `update_camera`.
- **Ray-box collision**: `get_screen_to_world_ray` and `get_ray_collision_box` detect clicks on the 3D cube.

## Public API Reference

### Package `raylib_text_draw_3d`

> Single-package example.

- `letter_boundry_size : Float` -- Height of the letter boundary wireframe boxes (0.25).
- `TextMaxLayers : Int` -- Maximum number of text layers (32).
- `WaveTextConfig` -- Struct holding wave animation parameters: `wave_range_x/y/z`, `wave_speed_x/y/z`, `wave_offset_x/y/z`.
- `alpha_discard_fs : String` -- Embedded GLSL 330 fragment shader source for alpha discard.
- `draw_text_codepoint_3d(font, codepoint, position, font_size, backface, tint, show_letter_boundry) -> Unit` -- Draws a single glyph as a textured quad in 3D space using rlgl.
- `draw_text_3d(font, text, position, font_size, font_spacing, line_spacing, backface, tint, show_letter_boundry) -> Unit` -- Draws a full text string in 3D, handling line breaks and character advancement.
- `measure_text_3d(font, text, font_size, font_spacing, line_spacing) -> Vector3` -- Measures the 3D bounding box of a text string.
- `draw_text_wave_3d(font, text, position, font_size, font_spacing, line_spacing, backface, config, time, tint, show_letter_boundry) -> Unit` -- Draws text in 3D with per-character sinusoidal wave displacement. Supports `~~` toggle markers.
- `measure_text_wave_3d(font, text, font_size, font_spacing, line_spacing) -> Vector3` -- Measures the 3D bounding box of wave-animated text.
- `generate_random_color(s : Float, v : Float) -> Color` -- Generates a random color using the golden ratio for hue distribution.

## Architecture

The program initializes a 3D scene with an orbital camera, a colored cube, and the default raylib font. It loads an embedded alpha-discard shader via `load_shader_from_memory`. Each frame, the camera is updated, input is processed (text editing, parameter changes, camera toggling), and the 3D scene is drawn: cube, grid, then the wave-animated text rendered as textured quads via rlgl wrapped in `begin_shader_mode(alpha_discard)`. Options and help text are also rendered as 3D text on the ground plane. 2D overlay text shows layer count, camera mode, and quad statistics.

## Key Takeaways

- rlgl's low-level quad API (`begin`, `vertex3f`, `tex_coord2f`, `end_`) enables rendering font glyph textures as flat surfaces positioned anywhere in 3D space.
- An alpha-discard fragment shader is essential when rendering transparent textures in 3D to prevent depth buffer artifacts from transparent pixels occluding geometry behind them.
- Wave text animation is achieved by applying per-character sinusoidal offsets with configurable range, speed, and phase parameters.
