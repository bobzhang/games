# Shaders: Color Correction

This example demonstrates real-time color correction using a custom fragment shader with adjustable contrast, saturation, and brightness parameters. When you run it, you see one of four selectable test images rendered through a color correction shader, with GUI slider bars on the right panel to adjust the three parameters interactively.

## Build and Run

```bash
moon build --target native shaders_color_correction/
./_build/native/debug/build/shaders_color_correction/shaders_color_correction.exe
```

## Controls

- **1/2/3/4 Keys** -- Switch between four test images (parrots, cat, mandrill, fudesumi)
- **R Key** -- Reset all color correction values to zero
- **GUI Sliders** -- Adjust contrast, saturation, and brightness (-100 to 100)
- **Reset Button** -- Reset values via the on-screen button

## What It Demonstrates

- **Fragment shader for color correction**: Loads a custom `color_correction.fs` shader with three float uniforms (`contrast`, `saturation`, `brightness`) that modify the image output in real time.
- **raygui integration**: Uses `@raygui.gui_toggle_group` for image selection, `@raygui.gui_slider_bar` for parameter adjustment, and `@raygui.gui_button` for a reset action, demonstrating how to combine immediate-mode GUI with shader-based rendering.
- **Shader mode rendering**: Wraps the `draw_texture` call in `begin_shader_mode`/`end_shader_mode` to apply the color correction shader only to the image, not the GUI elements.
- **Image loading pipeline**: Loads images first (to query dimensions via `image_width`/`image_height`), converts them to textures with `load_texture_from_image`, then unloads the images since only the GPU textures are needed at runtime.
- **Ref-based mutable state for GUI**: Uses `Ref[Float]` and `Ref[Int]` wrappers to pass mutable values to raygui slider and toggle functions, which require reference parameters.

## Public API Reference

### Package `shaders_color_correction`

> Single-package example.

No public API -- self-contained main function. The `float_to_bytes` helper is package-level but not exported.

## Architecture

The program initializes a window, loads four test images as textures (retaining their dimensions for centering), and loads the color correction fragment shader. Three `Ref[Float]` values track contrast, saturation, and brightness, with their shader uniform locations cached. Each frame, input is checked for image switching and reset actions, slider values are read from the GUI, and all three parameters are pushed to the shader. The selected image is drawn centered in the left panel under shader mode, while the right panel contains the GUI controls drawn outside shader mode. On exit, all four textures and the shader are unloaded.

## Key Takeaways

- Post-processing shaders applied per-texture (rather than full-screen) can be achieved by wrapping individual draw calls in `begin_shader_mode`/`end_shader_mode`, giving fine-grained control over which elements are affected.
- raygui's immediate-mode paradigm works well with MoonBit's `Ref` type for mutable slider values, bridging the gap between functional and imperative GUI patterns.
- Loading images first to query metadata (width, height) before converting to GPU textures is necessary when the texture API is opaque and doesn't expose dimension accessors directly.
