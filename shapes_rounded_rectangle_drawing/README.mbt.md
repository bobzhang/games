# Rounded Rectangle Drawing

This example demonstrates drawing rounded rectangles with interactive raygui controls for all parameters. When you run it, you see a centered rounded rectangle with sliders for width, height, roundness, thickness, and segments, plus checkboxes to toggle between filled, outlined, and plain rectangle rendering modes.

## Build and Run

```bash
moon build --target native shapes_rounded_rectangle_drawing/
./_build/native/debug/build/shapes_rounded_rectangle_drawing/shapes_rounded_rectangle_drawing.exe
```

## Controls

- **Raygui sliders** -- Adjust width, height, roundness (0.0-1.0), line thickness (0-20), and segment count (0-60)
- **Raygui checkboxes** -- Toggle DrawRoundedRect (fill), DrawRoundedLines (outline), and DrawRect (plain)

## What It Demonstrates

- **`draw_rectangle_rounded`** -- Draws a filled rectangle with rounded corners, controlled by roundness and segment parameters.
- **`draw_rectangle_rounded_lines_ex`** -- Draws the outline of a rounded rectangle with configurable line thickness.
- **`draw_rectangle_rec`** -- Draws a standard filled rectangle for visual comparison.
- **Raygui slider bars** -- `gui_slider_bar` provides continuous value adjustment with labels showing current values.
- **Raygui checkboxes** -- `gui_check_box` toggles boolean states for the three draw modes.
- **`Ref[T]` pattern** -- All adjustable parameters use `Ref` wrappers to allow raygui widgets to modify them in place.
- **Manual vs. Auto segment mode** -- When segments >= 4, manual mode is active; below that, raylib auto-calculates segments.

## Public API Reference

### Package `shapes_rounded_rectangle_drawing`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program creates an 800x450 window with a drawing area on the left and a raygui control panel on the right (separated by a vertical line at x=560). Each frame, the rectangle is constructed centered in the drawing area using the current width/height values. The active draw modes (filled rounded, outlined rounded, plain) are rendered in sequence. The right panel contains five slider bars for numeric parameters and three checkboxes for mode toggles. The mode indicator shows AUTO or MANUAL based on the current segment count.

## Key Takeaways

- This example serves as a raygui-enhanced version of `shapes_draw_rectangle_rounded`, replacing keyboard controls with intuitive sliders and checkboxes.
- The `Ref[T]` wrapper type is essential for raygui integration in MoonBit, as widgets need mutable references to update values.
- Combining multiple draw modes (fill + outline + plain) on the same rectangle helps visualize how roundness and segments affect the shape at different levels.
