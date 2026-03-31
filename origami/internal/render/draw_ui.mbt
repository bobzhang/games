///|
fn draw_playing(game : @types.Game) -> Unit {
  let ox = paper_origin_x()
  let oy = paper_origin_y()
  let tx = target_origin_x()
  let ty = target_origin_y()
  // Draw labels
  @draw.draw_text("Your Paper", ox, oy - 30, 20, @types.color_title)
  @draw.draw_text("Target", tx, ty - 30, 20, @types.color_title)
  // Draw current paper with layer numbers
  draw_paper_grid(game.current_paper, ox, oy, true)
  // Draw fold line preview if selecting
  if game.play_state == Selecting {
    draw_fold_line_preview(game, ox, oy)
  }
  // Draw layer check markers on current paper
  draw_layer_checks(game, ox, oy)
  // Draw target paper
  draw_paper_grid(game.target.target_silhouette, tx, ty, false)
  draw_target_layer_checks(game, tx, ty)
  // If show_target is on, draw ghost overlay on current paper
  if game.show_target {
    draw_target_ghost(game.target.target_silhouette, ox, oy)
  }
  // Draw UI panel
  draw_controls_panel(game)
  // Draw message
  if game.message_timer > 0.0 {
    let mw = @draw.measure_text(game.message, 24)
    @draw.draw_text(
      game.message,
      (@types.screen_width - mw) / 2,
      @types.screen_height - 60,
      24,
      @types.color_accent,
    )
  }
}

///|
fn draw_controls_panel(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let panel_x = w / 2 - 120
  let panel_y = 10
  let panel_w = 240
  let panel_h = 110
  // Background
  @raylib.draw_rectangle(panel_x, panel_y, panel_w, panel_h, @types.color_hud_bg)
  @raylib.draw_rectangle_lines(
    panel_x, panel_y, panel_w, panel_h, @types.color_grid_line,
  )
  // Level name and fold count
  let level_name = game.target.name
  let name_w = @draw.measure_text(level_name, 18)
  @draw.draw_text(
    level_name, panel_x + (panel_w - name_w) / 2, panel_y + 5, 18, @types.color_title,
  )
  let fold_txt =
    "Folds: " +
    game.fold_history.length().to_string() +
    " / Par: " +
    game.target.par_folds.to_string()
  let ft_w = @draw.measure_text(fold_txt, 16)
  @draw.draw_text(
    fold_txt, panel_x + (panel_w - ft_w) / 2, panel_y + 28, 16, @types.color_subtitle,
  )
  // Direction buttons row
  let btn_y = panel_y + 50
  let btn_size = 40
  let btn_gap = 8
  let total_btn_w = 4 * btn_size + 3 * btn_gap
  let btn_start_x = panel_x + (panel_w - total_btn_w) / 2
  let dirs : Array[@types.FoldDir] = [Left, Up, Down, Right]
  let labels : Array[String] = ["<", "^", "v", ">"]
  for i in 0..<4 {
    let bx = btn_start_x + i * (btn_size + btn_gap)
    let is_selected = game.fold_dir == dirs[i]
    let col = if is_selected { @types.color_accent } else { @types.color_btn }
    @raylib.draw_rectangle(bx, btn_y, btn_size, btn_size, col)
    @raylib.draw_rectangle_lines(
      bx, btn_y, btn_size, btn_size, @types.color_white,
    )
    let lw = @draw.measure_text(labels[i], 20)
    @draw.draw_text(
      labels[i],
      bx + (btn_size - lw) / 2,
      btn_y + (btn_size - 20) / 2,
      20,
      @types.color_btn_text,
    )
  }
  // Fold line position display
  let line_txt = "Line: " + game.fold_line.to_string()
  let lt_w = @draw.measure_text(line_txt, 16)
  @draw.draw_text(
    line_txt,
    panel_x + (panel_w - lt_w) / 2,
    panel_y + 95,
    16,
    @types.color_subtitle,
  )
  // Hotkey hints at bottom
  let hints_y = @types.screen_height - 30
  @draw.draw_text(
    "Arrows/Click: dir+line  Enter: fold  Z: undo  R: restart  T: toggle target  Esc: back",
    20,
    hints_y,
    14,
    @raylib.Color::new(140, 140, 160, 200),
  )
}

///|
fn draw_star(x : Int, y : Int, size : Int, filled : Bool) -> Unit {
  let col = if filled { @types.color_star_on } else { @types.color_star_off }
  // Simple star as a filled circle with text
  let txt = "*"
  let tw = @draw.measure_text(txt, size)
  @draw.draw_text(txt, x - tw / 2, y - size / 2, size, col)
}

///|
fn draw_stars_row(
  x : Int,
  y : Int,
  rating : @types.StarRating,
  size : Int
) -> Unit {
  let gap = size + 4
  let star_count = match rating {
    Zero => 0
    One => 1
    Two => 2
    Three => 3
  }
  for i in 0..<3 {
    draw_star(x + i * gap, y, size, i < star_count)
  }
}
