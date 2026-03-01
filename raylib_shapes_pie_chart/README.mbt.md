# Pie Chart

This example demonstrates an interactive pie chart with a full raygui control panel. When you run it, you see a colorful pie chart on the left that responds to mouse hover (slices pop out), with a scrollable settings panel on the right for adjusting slice count, values, labels, display options, and an optional donut mode.

## Build and Run

```bash
moon build --target native raylib_shapes_pie_chart/
./_build/native/debug/build/raylib_shapes_pie_chart/raylib_shapes_pie_chart.exe
```

## Controls

- **Mouse hover** -- Hover over a pie slice to make it pop out by 20 pixels
- **Raygui spinner** -- Adjust slice count (1 to 10)
- **Raygui checkboxes** -- Toggle value display, percentage display, and donut mode
- **Raygui slider** -- Adjust donut inner radius
- **Raygui text boxes** -- Edit slice labels (click to toggle edit mode)
- **Raygui sliders (scrollable)** -- Adjust individual slice values (0 to 1000)

## What It Demonstrates

- **`draw_circle_sector`** -- Draws each pie slice as a filled circle sector with calculated start/end angles based on value proportions.
- **`color_from_hsv`** -- Generates distinct colors for each slice by distributing hue evenly across the 360-degree color space.
- **`check_collision_point_rec`** and **`atan2f` / `hypotf`** -- Combined for pie slice hover detection: first checks if mouse is in the chart canvas, then calculates angle and distance to identify which slice is under the cursor.
- **Raygui scroll panel** -- `gui_scroll_panel` with `begin_scissor_mode` / `end_scissor_mode` creates a scrollable area for per-slice editors when there are many slices.
- **Raygui widgets** -- Demonstrates `gui_spinner`, `gui_check_box`, `gui_slider_bar`, `gui_text_box`, `gui_line`, and `gui_scroll_panel` working together as a complete control panel.
- **`measure_text_ex`** -- Measures text dimensions for centered label placement within pie slices.

## Public API Reference

### Package `raylib_shapes_pie_chart`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program divides the screen into a chart canvas (left) and a control panel (right). Each frame, it sums all slice values, then iterates to draw each sector with `draw_circle_sector` using cumulative angles. Hover detection converts mouse position to polar coordinates relative to the chart center, then walks the angle ranges to find the hovered slice. The popped-out slice gets a 20-pixel radius increase. Donut mode overlays a white circle at the center. The control panel uses raygui for all inputs, with a scrollable region containing per-slice color indicators, editable labels, and value sliders. Individual `Ref` wrappers are used for each value to enable raygui widget binding.

## Key Takeaways

- Pie charts are built by drawing consecutive circle sectors where each slice's angular sweep is proportional to its value divided by the total.
- `gui_scroll_panel` combined with `begin_scissor_mode` enables scrollable UI regions, which is essential when the number of controls exceeds the available screen space.
- Using `Ref[T]` for each GUI-bound value is the idiomatic way to give raygui widgets mutable access to state in MoonBit.
