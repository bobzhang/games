# Text: Font Spritefont

This example demonstrates loading and displaying multiple sprite fonts from PNG image files. When you run it, you see three different custom bitmap fonts, each rendering a descriptive message in its own style, centered on screen.

## Build and Run

```bash
moon build --target native text_font_spritefont/
./_build/native/debug/build/text_font_spritefont/text_font_spritefont.exe
```

## Controls

No interactive controls -- runs automatically.

## What It Demonstrates

- **Sprite font loading from images**: `load_font` with PNG files (`custom_mecha.png`, `custom_alagard.png`, `custom_jupiter_crash.png`) loads bitmap sprite fonts where raylib auto-detects character boundaries based on magenta separator pixels in the source image.
- **Multiple font rendering**: Three distinct sprite fonts are loaded and rendered simultaneously with `draw_text_ex`, each with different visual styles.
- **Text measurement and centering**: `measure_text_ex` computes the pixel dimensions of text rendered with a specific font, size, and spacing, enabling horizontal centering on screen.
- **Custom character spacing**: Each font uses a different spacing value (-3.0, -2.0, and 2.0), showing how negative spacing tightens and positive spacing loosens glyph placement.
- **Font base size retrieval**: `get_font_base_size` retrieves the native size of each loaded font, which is used directly as the render size for pixel-perfect display.

## Public API Reference

### Package `text_font_spritefont`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads three PNG sprite fonts and precomputes centered positions for each message using `measure_text_ex` with each font's base size and custom spacing. The main loop simply draws all three text strings at their precomputed positions using `draw_text_ex`. On exit, all three fonts are unloaded.

## Key Takeaways

- Sprite fonts loaded from PNG images are a simple way to use custom pixel-art or decorative fonts without TTF files -- raylib automatically extracts glyphs from the image using magenta separators.
- `measure_text_ex` is essential for precise text positioning when using custom fonts, as each font has different glyph widths and spacing characteristics.
- Negative character spacing values can be used to tighten the visual appearance of fonts that have built-in padding in their glyph images.
