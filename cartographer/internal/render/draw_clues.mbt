///|
fn draw_clues_panel(game : @types.Game) -> Unit {
  let level = game.levels[game.current_level]
  let px = @types.clue_panel_x
  let py = @types.clue_panel_y
  let pw = @types.clue_panel_width
  let clue_count = level.clues.length()
  let panel_height = 40 + clue_count * 32 + 20
  // Panel background
  @raylib.draw_rectangle(px, py, pw, panel_height, @types.color_parchment)
  @raylib.draw_rectangle_lines(px, py, pw, panel_height, @types.color_mountain)
  // Title
  @draw.draw_text("Clues", px + 10, py + 10, 22, @types.color_text)
  // Draw each clue
  for i in 0..<clue_count {
    let clue = level.clues[i]
    let cy = py + 40 + i * 32
    // Status indicator
    let status_color = match clue.status {
      Satisfied => @types.color_clue_satisfied
      Violated => @types.color_clue_violated
      Pending => @types.color_clue_pending
    }
    let status_symbol = match clue.status {
      Satisfied => "+"
      Violated => "X"
      Pending => "?"
    }
    // Draw status circle
    @raylib.draw_circle(px + 20, cy + 8, 8.0, status_color)
    @draw.draw_text(status_symbol, px + 16, cy + 1, 14, @types.color_white)
    // Draw clue text
    let text_color = match clue.status {
      Violated => @types.color_clue_violated
      _ => @types.color_text
    }
    let display_text = if clue.text.length() > 55 {
      clue.text[:55].to_string()
    } else {
      clue.text
    }
    @draw.draw_text(display_text, px + 36, cy, 16, text_color)
  }
  // Satisfaction summary
  let mut satisfied = 0
  let mut total = 0
  for i in 0..<clue_count {
    total += 1
    if level.clues[i].status == Satisfied {
      satisfied += 1
    }
  }
  let summary_y = py + 40 + clue_count * 32
  @draw.draw_text(
    "\{satisfied}/\{total} clues satisfied",
    px + 10,
    summary_y,
    16,
    if satisfied == total { @types.color_clue_satisfied } else {
      @types.color_text_light
    },
  )
}
