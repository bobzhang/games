///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.03
  // Animated background - paper texture feel
  for i in 0..<20 {
    let fi = Float::from_int(i)
    let bx = ((fi * 97.3 + time * 8.0) % Float::from_int(w)).to_int()
    let by = ((fi * 63.7 + time * 5.0) % Float::from_int(h)).to_int()
    let size = 20 + (fi * 13.0 % 30.0).to_int()
    let alpha = 15 + (fi * 7.0 % 25.0).to_int()
    @raylib.draw_rectangle(
      bx,
      by,
      size,
      size,
      @raylib.Color::new(245, 240, 230, alpha),
    )
  }
  // Title
  let title = "ORIGAMI"
  let title_size = 72
  let tw = @draw.measure_text(title, title_size)
  let pulse = sinf(time * 1.5) * 10.0
  @draw.draw_text(
    title,
    (w - tw) / 2,
    h / 4 + pulse.to_int(),
    title_size,
    @types.color_paper_base,
  )
  // Subtitle
  let sub = "Paper Folding Puzzle"
  let sw = @draw.measure_text(sub, 24)
  @draw.draw_text(sub, (w - sw) / 2, h / 4 + 80, 24, @types.color_subtitle)
  // Animated folding paper illustration
  let cx = w / 2
  let cy = h / 2 + 20
  let fold_phase = (time * 0.5 % 4.0).to_int()
  let paper_size = 60
  // Base paper
  @raylib.draw_rectangle(
    cx - paper_size,
    cy - paper_size / 2,
    paper_size * 2,
    paper_size,
    @raylib.Color::new(245, 240, 230, 200),
  )
  // Folded portion - animates
  let fold_w = match fold_phase {
    0 => paper_size
    1 => paper_size / 2
    2 => paper_size / 4
    _ => paper_size * 3 / 4
  }
  @raylib.draw_rectangle(
    cx - paper_size,
    cy - paper_size / 2,
    fold_w,
    paper_size,
    @raylib.Color::new(220, 210, 195, 220),
  )
  @raylib.draw_rectangle_lines(
    cx - paper_size,
    cy - paper_size / 2,
    paper_size * 2,
    paper_size,
    @types.color_grid_line,
  )
  // Start prompt
  let start = "Press ENTER to begin"
  let stw = @draw.measure_text(start, 22)
  let blink = if game.frame_count % 60 < 40 { 255 } else { 120 }
  @draw.draw_text(
    start,
    (w - stw) / 2,
    h * 3 / 4,
    22,
    @raylib.Color::new(245, 240, 230, blink),
  )
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let title = "Select Tier"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(title, (w - tw) / 2, 40, 36, @types.color_title)
  let tiers : Array[@types.Tier] = [Folds, Layers, Craft]
  let tier_w = 280
  let tier_h = 180
  let gap = 40
  let total_w = 3 * tier_w + 2 * gap
  let start_x = (w - total_w) / 2
  let tier_y = (h - tier_h) / 2
  for i in 0..<3 {
    let tier = tiers[i]
    let bx = start_x + i * (tier_w + gap)
    let col = @types.tier_color(tier)
    let is_hover = game.hover_button == i
    let bg = if is_hover { @types.color_btn_hover } else { @types.color_btn }
    @raylib.draw_rectangle(bx, tier_y, tier_w, tier_h, bg)
    @raylib.draw_rectangle_lines(bx, tier_y, tier_w, tier_h, col)
    // Tier name
    let name = @types.tier_name(tier)
    let nw = @draw.measure_text(name, 28)
    @draw.draw_text(name, bx + (tier_w - nw) / 2, tier_y + 20, 28, col)
    // Level count and stars
    let count_txt = @types.tier_level_count(tier).to_string() + " Levels"
    let cw = @draw.measure_text(count_txt, 18)
    @draw.draw_text(
      count_txt,
      bx + (tier_w - cw) / 2,
      tier_y + 60,
      18,
      @types.color_subtitle,
    )
    // Completed count
    let start_idx = @types.tier_start_index(tier)
    let count = @types.tier_level_count(tier)
    let mut completed = 0
    for j in start_idx..<(start_idx + count) {
      if game.scores[j].completed {
        completed += 1
      }
    }
    let comp_txt = completed.to_string() + " / " + count.to_string() + " done"
    let cpw = @draw.measure_text(comp_txt, 16)
    @draw.draw_text(
      comp_txt,
      bx + (tier_w - cpw) / 2,
      tier_y + 90,
      16,
      @types.color_subtitle,
    )
    // Total stars
    let mut total_stars = 0
    for j in start_idx..<(start_idx + count) {
      total_stars += star_value(game.scores[j].stars)
    }
    let star_txt = total_stars.to_string() +
      " / " +
      (count * 3).to_string() +
      " stars"
    let stw = @draw.measure_text(star_txt, 16)
    @draw.draw_text(
      star_txt,
      bx + (tier_w - stw) / 2,
      tier_y + 115,
      16,
      @types.color_star_on,
    )
    // Tier number
    let num_txt = "Tier " + (i + 1).to_string()
    let ntw = @draw.measure_text(num_txt, 14)
    @draw.draw_text(
      num_txt,
      bx + (tier_w - ntw) / 2,
      tier_y + tier_h - 30,
      14,
      @raylib.Color::new(140, 140, 160, 180),
    )
  }
  // Navigation hint
  @draw.draw_text(
    "Click a tier or press 1/2/3  |  Esc: back to title",
    w / 2 - 220,
    h - 50,
    16,
    @raylib.Color::new(140, 140, 160, 200),
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let tier = game.current_tier
  let col = @types.tier_color(tier)
  let title = @types.tier_name(tier) + " - Select Level"
  let tw = @draw.measure_text(title, 32)
  @draw.draw_text(title, (w - tw) / 2, 30, 32, col)
  let start_idx = @types.tier_start_index(tier)
  let count = @types.tier_level_count(tier)
  // Grid of level buttons
  let cols = 5
  let btn_w = 160
  let btn_h = 100
  let gap = 20
  let rows = (count + cols - 1) / cols
  let total_grid_w = cols * btn_w + (cols - 1) * gap
  let total_grid_h = rows * btn_h + (rows - 1) * gap
  let grid_x = (w - total_grid_w) / 2
  let grid_y = (@types.screen_height - total_grid_h) / 2 + 10
  for i in 0..<count {
    let row = i / cols
    let col_idx = i % cols
    let bx = grid_x + col_idx * (btn_w + gap)
    let by = grid_y + row * (btn_h + gap)
    let lvl_idx = start_idx + i
    let score = game.scores[lvl_idx]
    let level = @levels.get_level(lvl_idx)
    let is_hover = game.hover_button == i
    let bg = if is_hover { @types.color_btn_hover } else { @types.color_btn }
    @raylib.draw_rectangle(bx, by, btn_w, btn_h, bg)
    if score.completed {
      @raylib.draw_rectangle_lines(bx, by, btn_w, btn_h, @types.color_check_ok)
    } else {
      @raylib.draw_rectangle_lines(bx, by, btn_w, btn_h, col)
    }
    // Level number
    let num_txt = (i + 1).to_string()
    let nw = @draw.measure_text(num_txt, 24)
    @draw.draw_text(num_txt, bx + (btn_w - nw) / 2, by + 8, 24, col)
    // Level name
    let name = level.name
    let name_w = @draw.measure_text(name, 14)
    @draw.draw_text(
      name,
      bx + (btn_w - name_w) / 2,
      by + 36,
      14,
      @types.color_subtitle,
    )
    // Stars
    draw_stars_row(bx + btn_w / 2 - 30, by + 62, score.stars, 20)
    // Par info
    let par_txt = "Par: " + level.par_folds.to_string()
    let pw = @draw.measure_text(par_txt, 12)
    @draw.draw_text(
      par_txt,
      bx + (btn_w - pw) / 2,
      by + btn_h - 20,
      12,
      @raylib.Color::new(140, 140, 160, 160),
    )
  }
  @draw.draw_text(
    "Click a level or press 1-9  |  Esc: back to tiers",
    w / 2 - 220,
    @types.screen_height - 40,
    16,
    @raylib.Color::new(140, 140, 160, 200),
  )
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  // Dark overlay
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 0, 0, 160))
  let panel_w = 400
  let panel_h = 350
  let px = (w - panel_w) / 2
  let py = (h - panel_h) / 2
  @raylib.draw_rectangle(px, py, panel_w, panel_h, @types.color_hud_bg)
  @raylib.draw_rectangle_lines(px, py, panel_w, panel_h, @types.color_accent)
  // Title
  let result = @fold.check_completion(game.current_paper, game.target)
  let title = if result.silhouette_match {
    "Level Complete!"
  } else {
    "Not Quite..."
  }
  let title_col = if result.silhouette_match {
    @types.color_check_ok
  } else {
    @types.color_check_fail
  }
  let tw = @draw.measure_text(title, 32)
  @draw.draw_text(title, px + (panel_w - tw) / 2, py + 20, 32, title_col)
  // Level name
  let name = game.target.name
  let nw = @draw.measure_text(name, 20)
  @draw.draw_text(
    name,
    px + (panel_w - nw) / 2,
    py + 60,
    20,
    @types.color_subtitle,
  )
  // Folds used
  let folds = game.fold_history.length()
  let fold_txt = "Folds used: " +
    folds.to_string() +
    " (par: " +
    game.target.par_folds.to_string() +
    ")"
  let fw = @draw.measure_text(fold_txt, 18)
  @draw.draw_text(
    fold_txt,
    px + (panel_w - fw) / 2,
    py + 100,
    18,
    @types.color_subtitle,
  )
  // Silhouette check
  let sil_txt = if result.silhouette_match {
    "Silhouette: MATCH"
  } else {
    "Silhouette: MISMATCH"
  }
  let sil_col = if result.silhouette_match {
    @types.color_check_ok
  } else {
    @types.color_check_fail
  }
  let slw = @draw.measure_text(sil_txt, 18)
  @draw.draw_text(sil_txt, px + (panel_w - slw) / 2, py + 130, 18, sil_col)
  // Layer checks
  if game.target.layer_checks.length() > 0 {
    let lay_txt = if result.layers_match {
      "Layer Checks: ALL PASS"
    } else {
      "Layer Checks: SOME FAIL"
    }
    let lay_col = if result.layers_match {
      @types.color_check_ok
    } else {
      @types.color_check_fail
    }
    let lw = @draw.measure_text(lay_txt, 18)
    @draw.draw_text(lay_txt, px + (panel_w - lw) / 2, py + 158, 18, lay_col)
  }
  // Stars
  let stars = @fold.compute_stars(result, folds, game.target.par_folds)
  draw_stars_row(px + panel_w / 2 - 40, py + 200, stars, 36)
  // Star explanation
  let star_desc = match stars {
    Zero => "Match the target silhouette"
    One => "1 Star - Silhouette matched!"
    Two => "2 Stars - All checks passed!"
    Three => "3 Stars - Perfect! Under par!"
  }
  let sdw = @draw.measure_text(star_desc, 14)
  @draw.draw_text(
    star_desc,
    px + (panel_w - sdw) / 2,
    py + 240,
    14,
    @types.color_subtitle,
  )
  // Buttons
  @draw.draw_text(
    "R: Retry  |  Enter: Next Level  |  Esc: Level Select",
    px + 30,
    py + panel_h - 50,
    14,
    @raylib.Color::new(180, 180, 200, 220),
  )
}

///|
fn star_value(s : @types.StarRating) -> Int {
  match s {
    Zero => 0
    One => 1
    Two => 2
    Three => 3
  }
}
