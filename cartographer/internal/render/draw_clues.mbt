///|
fn draw_clues_panel(game : @types.Game) -> Unit {
  let level = game.levels[game.current_level]
  let px = @types.clue_panel_x
  let py = @types.clue_panel_y
  let pw = @types.clue_panel_width
  let clue_count = level.clues.length()
  let panel_height = 40 + clue_count * 32 + 20
  // Panel background with parchment styling
  @raylib.draw_rectangle(px, py, pw, panel_height, @types.color_parchment)
  @raylib.draw_rectangle_lines(
    px, py, pw, panel_height, @types.color_compass_ring,
  )
  @raylib.draw_rectangle_lines(
    px + 2,
    py + 2,
    pw - 4,
    panel_height - 4,
    @types.color_parchment_border,
  )
  // Title with decorative line
  @draw.draw_text("Clues", px + 10, py + 10, 22, @types.color_text)
  @raylib.draw_line(
    px + 10,
    py + 35,
    px + pw - 10,
    py + 35,
    @types.color_parchment_border,
  )
  // Draw each clue
  for i in 0..<clue_count {
    let clue = level.clues[i]
    let cy = py + 40 + i * 32
    // Check if this clue is hovered
    let is_hovered = game.hover_clue_index == i
    // Check if this clue is highlighted (from feature hover)
    let mut is_feature_highlighted = false
    for j in 0..<game.highlighted_clue_indices.length() {
      if game.highlighted_clue_indices[j] == i {
        is_feature_highlighted = true
        break
      }
    }
    // Check if this clue has a satisfaction animation
    let mut is_animating = false
    for j in 0..<game.clue_anim_indices.length() {
      if game.clue_anim_indices[j] == i {
        is_animating = true
        break
      }
    }
    // Highlight background for hovered or feature-linked clues
    if is_hovered {
      @raylib.draw_rectangle(
        px + 4,
        cy - 2,
        pw - 8,
        30,
        @types.color_clue_highlight,
      )
    } else if is_feature_highlighted {
      @raylib.draw_rectangle(
        px + 4,
        cy - 2,
        pw - 8,
        30,
        @types.color_feature_highlight,
      )
    }
    // Satisfaction animation: flash glow effect
    if is_animating && game.clue_anim_timer > 0.0 {
      let anim_alpha_f = game.clue_anim_timer / 0.6 * 100.0
      let anim_alpha = anim_alpha_f.to_int()
      let glow = @raylib.Color::new(34, 200, 34, anim_alpha)
      @raylib.draw_rectangle(px + 4, cy - 2, pw - 8, 30, glow)
    }
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
    // Draw status circle with ring
    @raylib.draw_circle(px + 20, cy + 8, 9.0, @types.color_compass_ring)
    @raylib.draw_circle(px + 20, cy + 8, 8.0, status_color)
    @draw.draw_text(status_symbol, px + 16, cy + 1, 14, @types.color_white)
    // Draw clue text
    let text_color = match clue.status {
      Violated => @types.color_clue_violated
      Satisfied =>
        if is_animating {
          @types.color_clue_satisfied
        } else {
          @types.color_text
        }
      _ => @types.color_text
    }
    let display_text = if clue.text.length() > 55 {
      clue.text[:55].to_owned()
    } else {
      clue.text
    }
    @draw.draw_text(display_text, px + 36, cy, 16, text_color)
  }
  // Satisfaction summary with progress bar
  let mut satisfied = 0
  let mut total = 0
  for i in 0..<clue_count {
    total += 1
    if level.clues[i].status == Satisfied {
      satisfied += 1
    }
  }
  let summary_y = py + 40 + clue_count * 32
  // Progress bar
  let bar_w = pw - 20
  let bar_h = 6
  @raylib.draw_rectangle(
    px + 10,
    summary_y,
    bar_w,
    bar_h,
    @types.color_parchment_dark,
  )
  if total > 0 {
    let fill_w = bar_w * satisfied / total
    let bar_color = if satisfied == total {
      @types.color_clue_satisfied
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(px + 10, summary_y, fill_w, bar_h, bar_color)
  }
  @draw.draw_text(
    "\{satisfied}/\{total} clues satisfied",
    px + 10,
    summary_y + 10,
    16,
    if satisfied == total {
      @types.color_clue_satisfied
    } else {
      @types.color_text_light
    },
  )
}
