///|
fn draw_tray(game : @types.Game) -> Unit {
  let tx = @types.tray_x
  let ty = @types.tray_y
  if game.tray.length() == 0 {
    return
  }
  // Tray header
  @draw.draw_text("Available Layers", tx, ty - 25, 16, @types.color_text_dim)
  // Draw tray rocks
  let rock_w = 120
  let rock_h = 45
  let gap = 10
  for i in 0..<game.tray.length() {
    let rx = tx + i * (rock_w + gap)
    let ry = ty
    let rock = game.tray[i]
    let rc = @types.rock_color(rock)
    let is_selected = game.selected_tray == i
    // Background
    @raylib.draw_rectangle(rx, ry, rock_w, rock_h, rc)
    draw_rock_texture(rx, ry, rock_w, rock_h, rock)
    // Rock name
    let rname = @types.rock_name(rock)
    let text_col = rock_text_color(rock)
    let rw = @draw.measure_text(rname, 15)
    @draw.draw_text(
      rname,
      rx + (rock_w - rw) / 2,
      ry + (rock_h - 16) / 2,
      15,
      text_col,
    )
    // Selection highlight
    if is_selected {
      @raylib.draw_rectangle_lines(
        rx - 2,
        ry - 2,
        rock_w + 4,
        rock_h + 4,
        @types.color_highlight,
      )
    }
    // Border
    @raylib.draw_rectangle_lines(
      rx, ry, rock_w, rock_h, @types.color_slot_border,
    )
    // Key hint
    let key = (i + 1).to_string()
    @draw.draw_text(key, rx + 4, ry + 2, 12, @types.color_text_dim)
  }
}

///|
fn draw_hud(game : @types.Game, level : @types.Level) -> Unit {
  let w = @types.screen_width
  // Level info top-right
  let tier_name = @types.tier_name(@types.tier_from_level(game.current_level))
  let level_text = tier_name +
    " - Level " +
    (game.current_level + 1).to_string() +
    ": " +
    level.name
  @draw.draw_text(level_text, w - 500, 15, 18, @types.color_accent)
  // Move counter
  let moves_text = "Moves: " +
    game.moves.to_string() +
    " / Par: " +
    level.par_moves.to_string()
  @draw.draw_text(moves_text, w - 250, 45, 16, @types.color_text)
  // State indicator
  let state_text = match game.play_state {
    Arranging => "Place layers in the cross-section"
    Checking => "Checking..."
    Solved => "Solved!"
    Failed => "Some clues not satisfied"
  }
  let state_color = match game.play_state {
    Arranging => @types.color_text_dim
    Checking => @types.color_accent
    Solved => @types.color_correct
    Failed => @types.color_incorrect
  }
  @draw.draw_text(state_text, w - 500, 680, 16, state_color)
  // Controls
  @draw.draw_text(
    "R-Reset  Z-Undo  ENTER-Check  ESC-Back", 20, 15, 14, @types.color_text_dim,
  )
  // Filled count
  let filled = @types.count_filled_slots(game.slots)
  let total = game.slots.length()
  let filled_text = "Placed: " + filled.to_string() + "/" + total.to_string()
  @draw.draw_text(filled_text, w - 250, 65, 16, @types.color_text_dim)
}
