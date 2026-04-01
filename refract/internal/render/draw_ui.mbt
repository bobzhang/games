///|
fn draw_palette(game : @types.Game) -> Unit {
  let px = @types.palette_x
  let py = @types.palette_y
  let item_h = @types.palette_item_h
  let panel_w = 240
  // Panel background
  @raylib.draw_rectangle(
    px - 10,
    py - 40,
    panel_w + 20,
    50 + game.palette.length() * item_h + 20,
    @types.color_palette_bg,
  )
  @raylib.draw_rectangle_lines(
    px - 10,
    py - 40,
    panel_w + 20,
    50 + game.palette.length() * item_h + 20,
    @types.color_cell_border,
  )
  // Title
  @draw.draw_text("COMPONENTS", px, py - 32, 18, @types.color_text)
  for i in 0..<game.palette.length() {
    let item = game.palette[i]
    let iy = py + i * item_h
    // Selection highlight
    let selected = i == game.selected_palette
    if selected {
      @raylib.draw_rectangle(
        px - 4,
        iy,
        panel_w + 8,
        item_h - 4,
        @types.color_palette_sel,
      )
    }
    // Component name with filter color if applicable
    let name = match item.filter_color {
      Some(fc) =>
        @types.filter_color_name(fc) +
        " " +
        @types.component_kind_name(item.kind)
      None => @types.component_kind_name(item.kind)
    }
    let name_color = if item.count > 0 {
      @types.color_text
    } else {
      @types.color_text_dim
    }
    @draw.draw_text(name, px + 8, iy + 6, 16, name_color)
    // Count
    let count_text = "x" + item.count.to_string()
    let count_color = if item.count > 0 {
      @types.color_accent
    } else {
      @types.color_failure
    }
    @draw.draw_text(count_text, px + panel_w - 40, iy + 6, 16, count_color)
    // Hotkey
    let key = (i + 1).to_string()
    @draw.draw_text(key, px + panel_w - 10, iy + 6, 14, @types.color_text_dim)
  }
}

///|
fn draw_playing_ui(game : @types.Game) -> Unit {
  let w = @types.screen_width
  // Level name at top
  @draw.draw_text(game.level_name, 80, 10, 24, @types.color_text)
  // Play state indicator
  let state_text = match game.play_state {
    Placing => "PLACING"
    Simulating => "SIMULATING"
    Solved => "SOLVED!"
  }
  let state_color = match game.play_state {
    Placing => @types.color_accent
    Simulating => @types.color_beam_yellow
    Solved => @types.color_success
  }
  @draw.draw_text(state_text, 80, 42, 16, state_color)
  // Par info
  let placed = @types.count_placed_components(game.grid)
  let par_text = "Components: " +
    placed.to_string() +
    " / " +
    game.par_count.to_string() +
    " par"
  @draw.draw_text(par_text, 300, 42, 14, @types.color_text_dim)
  // Controls at bottom
  let controls = "CLICK: Place/Remove  R: Rotate  SPACE: Simulate  ESC: Back"
  @draw.draw_text(controls, 80, 580, 14, @types.color_text_dim)
  // Help toggle
  @draw.draw_text("H: Help", w - 100, 10, 14, @types.color_text_dim)
  if game.show_help {
    draw_help_overlay()
  }
}

///|
fn draw_help_overlay() -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let panel_w = 400
  let panel_h = 340
  let px = (w - panel_w) / 2
  let py = (h - panel_h) / 2
  @raylib.draw_rectangle(
    px,
    py,
    panel_w,
    panel_h,
    @raylib.Color::new(10, 10, 20, 240),
  )
  @raylib.draw_rectangle_lines(px, py, panel_w, panel_h, @types.color_accent)
  @draw.draw_text("HOW TO PLAY", px + 20, py + 15, 24, @types.color_accent)
  let lines = [
    "Source: Emits light in a direction", "Mirror: Reflects beam 90 degrees (R to rotate)",
    "  N/S = / slash, E/W = \\ backslash", "Prism: Splits beam into color channels",
    "Filter: Removes one color channel", "Combiner: Merges beams into one output",
    "Receiver: Must get the exact target color", "", "Click empty socket to place component",
    "Click placed component to remove it", "SPACE to simulate beams", "All receivers satisfied = level complete!",
  ]
  for i in 0..<lines.length() {
    @draw.draw_text(lines[i], px + 20, py + 50 + i * 22, 14, @types.color_text)
  }
  @draw.draw_text(
    "Press H to close",
    px + 20,
    py + panel_h - 30,
    14,
    @types.color_text_dim,
  )
}
