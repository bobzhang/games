///|
fn draw_palette(game : @types.Game) -> Unit {
  let px = @types.palette_x
  let py = @types.palette_y
  let item_h = @types.palette_item_h
  let panel_w = 280
  let panel_h = 50 + game.palette.length() * item_h + 20
  @raylib.draw_rectangle(
    px - 10,
    py - 40,
    panel_w + 20,
    panel_h,
    @types.color_palette_bg,
  )
  @raylib.draw_rectangle_lines(
    px - 10,
    py - 40,
    panel_w + 20,
    panel_h,
    @types.color_cell_border,
  )
  @draw.draw_text("COMPONENTS", px, py - 32, 18, @types.color_text)
  for i in 0..<game.palette.length() {
    let item = game.palette[i]
    let iy = py + i * item_h
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
    // Name with qualifier
    let name = build_component_label(
      item.kind,
      item.filter_color,
      item.crystal_face,
    )
    let name_color = if item.count > 0 {
      @types.color_text
    } else {
      @types.color_text_dim
    }
    @draw.draw_text(name, px + 8, iy + 6, 15, name_color)
    // Count
    let count_text = "x" + item.count.to_string()
    let count_color = if item.count > 0 {
      @types.color_accent
    } else {
      @types.color_failure
    }
    @draw.draw_text(count_text, px + panel_w - 50, iy + 6, 15, count_color)
    // Hotkey
    let key = (i + 1).to_string()
    @draw.draw_text(key, px + panel_w - 16, iy + 6, 13, @types.color_text_dim)
  }
}

///|
fn build_component_label(
  kind : @types.ComponentKind,
  fc : @types.FilterColor?,
  cf : @types.CrystalFace?,
) -> String {
  let base = @types.component_kind_name(kind)
  let qualifier = match (fc, cf) {
    (Some(f), _) => @types.filter_color_name(f)
    (_, Some(c)) => @types.crystal_face_name(c)
    _ => ""
  }
  if qualifier.length() > 0 {
    qualifier + " " + base
  } else {
    base
  }
}

///|
fn draw_playing_ui(game : @types.Game) -> Unit {
  let w = @types.screen_width
  // Level name
  @draw.draw_text(game.level_name, 20, 10, 24, @types.color_text)
  // Play state
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
  @draw.draw_text(state_text, 20, 42, 16, state_color)
  // Par info
  let placed = @types.count_placed_components(game.grid)
  let par_text = "Components: " +
    placed.to_string() +
    " / " +
    game.par_count.to_string() +
    " par"
  @draw.draw_text(par_text, 200, 42, 14, @types.color_text_dim)
  // Controls
  let controls = "CLICK: Place/Remove  R: Rotate  SPACE: Simulate  ESC: Back"
  @draw.draw_text(controls, 20, 690, 14, @types.color_text_dim)
  // Hover coordinate display
  if game.hover_valid {
    let coord_text = "(" +
      game.hover_q.to_string() +
      "," +
      game.hover_r.to_string() +
      ")"
    @draw.draw_text(coord_text, 20, 670, 12, @types.color_text_dim)
  }
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
  let panel_w = 420
  let panel_h = 360
  let px = (w - panel_w) / 2
  let py = (h - panel_h) / 2
  @raylib.draw_rectangle(
    px,
    py,
    panel_w,
    panel_h,
    @raylib.Color::new(8, 6, 18, 240),
  )
  @raylib.draw_rectangle_lines(px, py, panel_w, panel_h, @types.color_accent)
  @draw.draw_text("HOW TO PLAY", px + 20, py + 15, 24, @types.color_accent)
  let lines = [
    "Route light beams through a hex crystal grid.", "", "Source: Emits white light in one direction",
    "Crystal: Refracts beam 60 degrees (L or R)", "Filter: Passes only one color (R/G/B)",
    "Mirror: Reflects beam across its axis", "Target: Must receive the exact color shown",
    "", "Click empty hex to place selected component", "Click placed component to remove it",
    "R to rotate   SPACE to simulate beams", "1-6 keys to select from palette", "All targets satisfied = level complete!",
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
