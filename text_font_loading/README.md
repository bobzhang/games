# Text: Font Loading

This example demonstrates loading fonts from two different formats -- BMFont (AngelCode .fnt) and TTF -- and rendering the same character set with each. When you run it, you see the full printable ASCII character set displayed in maroon using the BMFont by default, switching to lime-colored TTF rendering while Space is held.

## Build and Run

```bash
moon build --target native text_font_loading/
./_build/native/debug/build/text_font_loading/text_font_loading.exe
```

## Controls

- **Space (hold)**: Switch from BMFont display to TTF font display

## What It Demonstrates

- **BMFont loading**: `load_font` loads an AngelCode BMFont (`pixantiqua.fnt`), which consists of pre-rendered glyph images and metadata describing character positions and metrics.
- **TTF font loading**: `load_font_ex` loads a TrueType font (`pixantiqua.ttf`) at a specified base size (32px), generating the glyph atlas dynamically at load time.
- **Font comparison**: The same ASCII character set is rendered with both font types, allowing direct visual comparison of BMFont (pre-rendered sprites) vs TTF (dynamically rasterized) output.
- **Text line spacing**: `set_text_line_spacing` configures the vertical spacing (16px) for multi-line text rendered with `draw_text_ex`.
- **Custom font rendering**: `draw_text_ex` renders the multi-line character set at a fixed position with per-font character spacing (2.0).

## Public API Reference

### Package `text_font_loading`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads two versions of the same font (pixantiqua) from different formats: a BMFont .fnt file via `load_font` and a TTF file at 32px via `load_font_ex`. The main loop checks whether Space is held to select which font to use for rendering the full printable ASCII character set via `draw_text_ex`. A status message at the bottom indicates which font format is currently active. Both fonts are unloaded on exit.

## Key Takeaways

- raylib supports both pre-rendered BMFont sprite fonts (loaded with `load_font`) and dynamically rasterized TTF fonts (loaded with `load_font_ex`), each with different trade-offs in quality and flexibility.
- BMFonts offer pixel-perfect rendering at their designed size but cannot scale well, while TTF fonts can be rasterized at any base size for more flexibility.
- `draw_text_ex` provides a unified API for rendering text regardless of the underlying font format.
