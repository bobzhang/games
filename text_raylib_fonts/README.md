# Text: Raylib Fonts

This example showcases the eight free bitmap fonts bundled with raylib, each displayed with its name and designer credit in a unique color. When you run it, you see all eight fonts rendered and stacked vertically, centered on screen.

## Build and Run

```bash
moon build --target native text_fonts/
./_build/native/debug/build/text_fonts/text_fonts.exe
```

## Controls

No interactive controls -- runs automatically.

## What It Demonstrates

- **Loading multiple bitmap fonts**: `load_font` loads eight different PNG sprite fonts from the resources directory: Alagard, Pixelplay, Mecha, Setback, Romulus, Pixantiqua, Alpha Beta, and Jupiter Crash.
- **Text measurement for centering**: `measure_text_ex` computes the rendered width of each message string at double the base font size with per-font spacing, enabling precise horizontal centering.
- **Per-font spacing configuration**: Each font has a custom spacing value stored in a `FixedArray[Float]` (ranging from 1.0 to 8.0) tuned to its glyph design.
- **Batch font rendering**: All eight fonts are drawn in a single `for` loop using `draw_text_ex` with per-font parameters (font, position, size, spacing, color).
- **Font base size scaling**: Each font's base size (from the `base_sizes` array) is doubled for display rendering.

## Public API Reference

### Package `text_fonts`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads eight sprite fonts from PNG files and precomputes centered positions for each font's message using `measure_text_ex` at doubled base size with per-font spacing. Small Y-position corrections are applied to some fonts for visual alignment. The main loop draws a header ("free fonts included with raylib"), a separator line, and all eight font samples in a loop. On exit, all fonts are unloaded in a loop.

## Key Takeaways

- raylib ships with a variety of free bitmap fonts suitable for prototyping and game development, each with a distinct visual aesthetic.
- Precomputing text positions with `measure_text_ex` before the main loop avoids per-frame measurement overhead and ensures consistent layout.
- Different fonts benefit from different character spacing values; tuning spacing per font is important for readability and visual quality.
