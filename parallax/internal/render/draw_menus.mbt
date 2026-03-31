///|
pub fn draw_title(game : @types.Game) -> Unit {
  // Animated grid background
  draw_grid_background(game.frame_count)
  // Title with glow effect
  let title = "PARALLAX"
  let tw = @draw.measure_text(title, 60)
  let title_x = (@types.screen_width - tw) / 2
  // Glow behind title
  let t : Float = Float::from_int(game.frame_count) * 0.03
  let glow_alpha = (Float::from_double(@math.sin(t.to_double())) * 30.0 + 50.0).to_int()
  let glow_color = @raylib.Color::new(0, 180, 220, glow_alpha)
  @raylib.draw_rectangle(title_x - 20, 170, tw + 40, 70, glow_color)
  @draw.draw_text(title, title_x, 180, 60, @types.color_title)
  // Subtitle
  let sub = "A Perspective Shift Puzzle"
  let sw = @draw.measure_text(sub, 24)
  @draw.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    260,
    24,
    @types.color_text,
  )
  // Description
  let desc = "Toggle voxels to match 3 silhouettes simultaneously"
  let dw = @draw.measure_text(desc, 18)
  @draw.draw_text(
    desc,
    (@types.screen_width - dw) / 2,
    310,
    18,
    @raylib.Color::new(150, 160, 180, 255),
  )
  // How to play hints
  let hints = [
    "Click cells in TOP, FRONT, or SIDE views to toggle voxels",
    "Match all 3 target silhouettes to complete each puzzle",
    "30 levels across 3 tiers of increasing difficulty",
  ]
  for i in 0..<hints.length() {
    let hint = hints[i]
    let hw = @draw.measure_text(hint, 14)
    @draw.draw_text(
      hint,
      (@types.screen_width - hw) / 2,
      350 + i * 22,
      14,
      @raylib.Color::new(120, 130, 160, 255),
    )
  }
  // Start button with pulse
  let btn_x = (@types.screen_width - 200) / 2
  let btn_y = 440
  draw_button(btn_x, btn_y, 200, 50, "START", 24, @types.color_title)
  draw_pulse_border(btn_x, btn_y, 200, 50, game.frame_count, @types.color_title)
  // Animated decorative voxels
  let pulse = Float::from_double(@math.sin(t.to_double())) * 0.3 + 0.7
  let alpha : Float = pulse * 255.0
  let deco_color = @raylib.Color::new(0, 200, 220, alpha.to_int())
  // Scattered cubes with movement
  for i in 0..<8 {
    let fi : Float = Float::from_int(i)
    let angle : Float = fi * 0.8 + t
    let base_x : Float = 640.0 +
      Float::from_double(@math.cos(angle.to_double())) * (200.0 + fi * 30.0)
    let base_y : Float = 560.0 +
      Float::from_double(@math.sin((angle * 0.7).to_double())) * 40.0
    let sz = 10 + i % 3 * 5
    @raylib.draw_rectangle(base_x.to_int(), base_y.to_int(), sz, sz, deco_color)
  }
  // Version info
  @draw.draw_text(
    "v1.0",
    @types.screen_width - 50,
    @types.screen_height - 25,
    14,
    @raylib.Color::new(80, 80, 100, 255),
  )
}

///|
pub fn draw_tier_select(game : @types.Game) -> Unit {
  draw_grid_background(game.frame_count / 2)
  // Header
  let header = "SELECT TIER"
  let hw = @draw.measure_text(header, 36)
  @draw.draw_text(
    header,
    (@types.screen_width - hw) / 2,
    40,
    36,
    @types.color_title,
  )
  // Three tier cards
  let card_w = 340
  let card_h = 380
  let gap = 30
  let total_w = card_w * 3 + gap * 2
  let start_x = (@types.screen_width - total_w) / 2
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  for tier in 0..<3 {
    let cx = start_x + tier * (card_w + gap)
    let cy = 100
    let tier_col = @types.tier_color(tier)
    let name = @types.tier_name(tier)
    // Card background
    let hovered = mx >= cx && mx < cx + card_w && my >= cy && my < cy + card_h
    let bg = if hovered { @types.color_button_hover } else { @types.color_button }
    @raylib.draw_rectangle(cx, cy, card_w, card_h, bg)
    @raylib.draw_rectangle_lines(cx, cy, card_w, card_h, tier_col)
    if hovered {
      draw_pulse_border(cx, cy, card_w, card_h, game.frame_count, tier_col)
    }
    // Tier number badge
    let badge_text = "TIER " + (tier + 1).to_string()
    @draw.draw_text(badge_text, cx + 15, cy + 12, 14, @raylib.Color::new(150, 150, 180, 255))
    // Tier name
    let nw = @draw.measure_text(name, 28)
    @draw.draw_text(name, cx + (card_w - nw) / 2, cy + 35, 28, tier_col)
    // Grid size info
    let grid_info = match tier {
      0 => "3x3x3 grids"
      1 => "4x4x4 grids"
      _ => "4x4 & 5x5 grids"
    }
    let gw = @draw.measure_text(grid_info, 16)
    @draw.draw_text(
      grid_info,
      cx + (card_w - gw) / 2,
      cy + 72,
      16,
      @raylib.Color::new(180, 180, 200, 255),
    )
    // Tier description lines
    let desc1 = match tier {
      0 => "Learn the basics of"
      1 => "Larger grids with"
      _ => "Complex shapes requiring"
    }
    let desc2 = match tier {
      0 => "perspective matching"
      1 => "voxel budget limits"
      _ => "connected voxels"
    }
    @draw.draw_text(
      desc1,
      cx + 20,
      cy + 110,
      15,
      @raylib.Color::new(160, 160, 180, 255),
    )
    @draw.draw_text(
      desc2,
      cx + 20,
      cy + 130,
      15,
      @raylib.Color::new(160, 160, 180, 255),
    )
    // Constraint icons
    if tier >= 1 {
      @draw.draw_text("Budget limit", cx + 20, cy + 165, 14, @raylib.Color::new(255, 200, 80, 255))
    }
    if tier >= 2 {
      @draw.draw_text("Connected required", cx + 20, cy + 185, 14, @raylib.Color::new(200, 100, 255, 255))
    }
    // Star count for tier
    let mut total_stars = 0
    let mut completed = 0
    for i in 0..<@types.levels_per_tier {
      let idx = @types.level_index(tier, i)
      total_stars += game.scores[idx].stars
      if game.scores[idx].completed {
        completed += 1
      }
    }
    // Progress bar
    let progress_f : Float = Float::from_int(completed) / Float::from_int(@types.levels_per_tier)
    draw_progress_bar(
      cx + 20,
      cy + 220,
      card_w - 40,
      10,
      progress_f,
      tier_col,
      @raylib.Color::new(30, 30, 50, 255),
    )
    let progress = completed.to_string() +
      "/" +
      @types.levels_per_tier.to_string() +
      " complete"
    @draw.draw_text(progress, cx + 20, cy + 240, 16, @types.color_text)
    let star_text = total_stars.to_string() +
      "/" +
      (@types.levels_per_tier * 3).to_string() +
      " stars"
    @draw.draw_text(star_text, cx + 20, cy + 265, 16, @types.color_star_gold)
    draw_stars(cx + 20, cy + 295, total_stars, 10, 18)
    // Difficulty range
    let diff_label = match tier {
      0 => "Difficulty:"
      1 => "Difficulty:"
      _ => "Difficulty:"
    }
    @draw.draw_text(
      diff_label,
      cx + 20,
      cy + 335,
      14,
      @raylib.Color::new(150, 150, 170, 255),
    )
    let min_diff = match tier {
      0 => 1
      1 => 2
      _ => 3
    }
    draw_difficulty(cx + 110, cy + 335, min_diff)
  }
  // Back hint
  @draw.draw_text(
    "ESC: Back to Title",
    10,
    @types.screen_height - 30,
    16,
    @raylib.Color::new(120, 120, 150, 255),
  )
}

///|
pub fn draw_level_select(game : @types.Game) -> Unit {
  draw_grid_background(game.frame_count / 3)
  let tier = game.current_tier
  let tier_col = @types.tier_color(tier)
  let tier_name_str = @types.tier_name(tier)
  // Header
  let header = "TIER " + (tier + 1).to_string() + ": " + tier_name_str
  let hw = @draw.measure_text(header, 32)
  @draw.draw_text(
    header,
    (@types.screen_width - hw) / 2,
    30,
    32,
    tier_col,
  )
  // Tier total progress
  let mut tier_stars = 0
  let mut tier_complete = 0
  for i in 0..<@types.levels_per_tier {
    let idx = @types.level_index(tier, i)
    tier_stars += game.scores[idx].stars
    if game.scores[idx].completed {
      tier_complete += 1
    }
  }
  let prog_text = tier_complete.to_string() +
    "/10 completed  |  " +
    tier_stars.to_string() +
    "/30 stars"
  let pw = @draw.measure_text(prog_text, 16)
  @draw.draw_text(
    prog_text,
    (@types.screen_width - pw) / 2,
    68,
    16,
    @raylib.Color::new(160, 170, 190, 255),
  )
  // Level grid: 5 columns x 2 rows
  let btn_w = 220
  let btn_h = 120
  let gap_x = 16
  let gap_y = 20
  let cols = 5
  let total_w = cols * btn_w + (cols - 1) * gap_x
  let start_x = (@types.screen_width - total_w) / 2
  let start_y = 100
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let levels = @levels.get_all_levels()
  let mut hovered_idx = -1
  for i in 0..<@types.levels_per_tier {
    let col = i % cols
    let row = i / cols
    let bx = start_x + col * (btn_w + gap_x)
    let by = start_y + row * (btn_h + gap_y)
    let idx = @types.level_index(tier, i)
    let score = game.scores[idx]
    let level = levels[idx]
    // Check if hovering
    let hovered = mx >= bx && mx < bx + btn_w && my >= by && my < by + btn_h
    if hovered {
      hovered_idx = idx
    }
    let bg = if hovered { @types.color_button_hover } else { @types.color_button }
    @raylib.draw_rectangle(bx, by, btn_w, btn_h, bg)
    // Border color based on completion
    let border_col = if score.completed {
      @types.color_matched
    } else {
      @types.color_grid_line
    }
    @raylib.draw_rectangle_lines(bx, by, btn_w, btn_h, border_col)
    if score.completed {
      // Checkmark in corner
      @draw.draw_text(
        "OK",
        bx + btn_w - 30,
        by + 5,
        12,
        @types.color_matched,
      )
    }
    // Level number
    let num_text = (i + 1).to_string()
    @draw.draw_text(num_text, bx + 10, by + 8, 22, @types.color_text)
    // Level name
    @draw.draw_text(level.name, bx + 10, by + 36, 15, tier_col)
    // Grid size and constraints
    let size_text = level.size.to_string() +
      "x" +
      level.size.to_string() +
      "x" +
      level.size.to_string()
    @draw.draw_text(
      size_text,
      bx + btn_w - 60,
      by + 36,
      13,
      @raylib.Color::new(130, 130, 160, 255),
    )
    // Constraint icons
    let mut cy = by + 58
    if level.voxel_budget > 0 {
      let budget_text = "Budget: " + level.voxel_budget.to_string()
      @draw.draw_text(budget_text, bx + 10, cy, 12, @raylib.Color::new(255, 200, 80, 200))
      cy += 16
    }
    if level.requires_connected {
      @draw.draw_text(
        "Connected",
        bx + 10,
        cy,
        12,
        @raylib.Color::new(200, 100, 255, 200),
      )
    }
    // Stars
    draw_stars(bx + 10, by + btn_h - 28, score.stars, 3, 18)
    // Best moves if completed
    if score.completed {
      let best = "Best: " + score.best_moves.to_string() + " moves"
      @draw.draw_text(
        best,
        bx + btn_w - 110,
        by + btn_h - 22,
        11,
        @raylib.Color::new(140, 150, 170, 255),
      )
    }
    // Difficulty dots
    let diff = @levels.get_difficulty(idx)
    draw_difficulty(bx + btn_w - 70, by + 10, diff)
  }
  // Hovered level description
  let info_y = start_y + 2 * (btn_h + gap_y) + 15
  if hovered_idx >= 0 {
    let desc = @levels.get_level_description(hovered_idx)
    let level = levels[hovered_idx]
    let info_text = level.name + ": " + desc
    let iw = @draw.measure_text(info_text, 18)
    @draw.draw_text(
      info_text,
      (@types.screen_width - iw) / 2,
      info_y,
      18,
      @types.color_text,
    )
    // Par info
    let par_info = "Par: " +
      level.par_moves.to_string() +
      " moves, " +
      level.par_voxels.to_string() +
      " voxels"
    let piw = @draw.measure_text(par_info, 16)
    @draw.draw_text(
      par_info,
      (@types.screen_width - piw) / 2,
      info_y + 25,
      16,
      @raylib.Color::new(160, 170, 190, 255),
    )
  } else {
    let hint = "Click a level to play. Earn stars by solving efficiently."
    let hiw = @draw.measure_text(hint, 16)
    @draw.draw_text(
      hint,
      (@types.screen_width - hiw) / 2,
      info_y,
      16,
      @raylib.Color::new(130, 140, 160, 255),
    )
  }
  // Back hint
  @draw.draw_text(
    "ESC: Back to Tiers",
    10,
    @types.screen_height - 30,
    16,
    @raylib.Color::new(120, 120, 150, 255),
  )
}

///|
pub fn draw_results(game : @types.Game) -> Unit {
  let idx = game.current_level
  let level = @levels.get_level(idx)
  // Background overlay
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(10, 10, 20, 240),
  )
  // Celebration particles for 3 stars
  if game.result_stars >= 3 {
    draw_completion_particles(
      @types.screen_width / 2,
      @types.screen_height / 2 - 80,
      game.frame_count,
    )
  }
  // Results card
  let card_w = 520
  let card_h = 480
  let card_x = (@types.screen_width - card_w) / 2
  let card_y = (@types.screen_height - card_h) / 2
  @raylib.draw_rectangle(card_x, card_y, card_w, card_h, @types.color_panel_bg)
  let border_col = match game.result_stars {
    3 => @types.color_star_gold
    2 => @types.color_matched
    _ => @types.color_title
  }
  @raylib.draw_rectangle_lines(card_x, card_y, card_w, card_h, border_col)
  @raylib.draw_rectangle_lines(
    card_x - 1,
    card_y - 1,
    card_w + 2,
    card_h + 2,
    border_col,
  )
  // Title
  let title = "LEVEL COMPLETE!"
  let tw = @draw.measure_text(title, 32)
  @draw.draw_text(
    title,
    card_x + (card_w - tw) / 2,
    card_y + 20,
    32,
    @types.color_complete,
  )
  // Level name
  let name_text = "Level " +
    (idx + 1).to_string() +
    ": " +
    level.name
  let nw = @draw.measure_text(name_text, 22)
  @draw.draw_text(
    name_text,
    card_x + (card_w - nw) / 2,
    card_y + 60,
    22,
    @types.color_text,
  )
  // Stars with animation
  let star_size = 40
  let stars_w = 3 * star_size + 2 * 8
  draw_stars(
    card_x + (card_w - stars_w) / 2,
    card_y + 100,
    game.result_stars,
    3,
    star_size,
  )
  // Rating text
  let rating_text = match game.result_stars {
    3 => "PERFECT!"
    2 => "Great job!"
    _ => "Completed!"
  }
  let rating_col = match game.result_stars {
    3 => @types.color_star_gold
    2 => @types.color_matched
    _ => @types.color_text
  }
  let rw = @draw.measure_text(rating_text, 18)
  @draw.draw_text(
    rating_text,
    card_x + (card_w - rw) / 2,
    card_y + 150,
    18,
    rating_col,
  )
  // Stats
  let stats_x = card_x + 60
  let mut sy = card_y + 185
  // Moves comparison
  let move_label = "Moves:"
  @draw.draw_text(move_label, stats_x, sy, 18, @raylib.Color::new(150, 160, 180, 255))
  let move_val = game.moves.to_string()
  let move_col = if game.moves <= level.par_moves {
    @types.color_matched
  } else {
    @types.color_text
  }
  @draw.draw_text(move_val, stats_x + 100, sy, 20, move_col)
  let par_text = "(par: " + level.par_moves.to_string() + ")"
  @draw.draw_text(par_text, stats_x + 150, sy, 16, @raylib.Color::new(130, 140, 160, 255))
  sy += 30
  // Voxels comparison
  let filled = @voxel.count_filled(game.grid)
  @draw.draw_text("Voxels:", stats_x, sy, 18, @raylib.Color::new(150, 160, 180, 255))
  let vox_col = if filled <= level.par_voxels {
    @types.color_matched
  } else {
    @types.color_text
  }
  @draw.draw_text(filled.to_string(), stats_x + 100, sy, 20, vox_col)
  let pvox_text = "(par: " + level.par_voxels.to_string() + ")"
  @draw.draw_text(pvox_text, stats_x + 150, sy, 16, @raylib.Color::new(130, 140, 160, 255))
  sy += 30
  // Budget if applicable
  if level.voxel_budget > 0 {
    @draw.draw_text("Budget:", stats_x, sy, 18, @raylib.Color::new(150, 160, 180, 255))
    draw_voxel_budget_bar(stats_x + 100, sy + 3, filled, level.voxel_budget)
    sy += 30
  }
  // Separator
  sy += 5
  @raylib.draw_line(
    stats_x,
    sy,
    card_x + card_w - 60,
    sy,
    @types.color_grid_line,
  )
  sy += 15
  // Star criteria checklist
  @draw.draw_text("Star Criteria:", stats_x, sy, 16, @types.color_title)
  sy += 24
  let check1 = if true { "[X]" } else { "[ ]" }
  let s1 = check1 + " Complete the puzzle"
  @draw.draw_text(s1, stats_x + 10, sy, 15, @types.color_matched)
  sy += 22
  let got_s2 = game.moves <= level.par_moves
  let check2 = if got_s2 { "[X]" } else { "[ ]" }
  let s2 = check2 +
    " Within " +
    level.par_moves.to_string() +
    " moves"
  let s2_col = if got_s2 { @types.color_matched } else { @types.color_unmatched }
  @draw.draw_text(s2, stats_x + 10, sy, 15, s2_col)
  sy += 22
  let got_s3 = got_s2 && filled <= level.par_voxels
  let check3 = if got_s3 { "[X]" } else { "[ ]" }
  let s3 = check3 +
    " Use <= " +
    level.par_voxels.to_string() +
    " voxels"
  let s3_col = if got_s3 { @types.color_matched } else { @types.color_unmatched }
  @draw.draw_text(s3, stats_x + 10, sy, 15, s3_col)
  // Buttons
  let btn_y = card_y + card_h - 60
  let is_last = idx >= @types.total_levels - 1
  let next_label = if is_last { "ALL DONE!" } else { "NEXT LEVEL" }
  let next_col = if is_last {
    @types.color_star_gold
  } else {
    @types.color_title
  }
  draw_button(card_x + 30, btn_y, 200, 40, next_label, 18, next_col)
  draw_button(
    card_x + card_w - 230,
    btn_y,
    200,
    40,
    "LEVEL SELECT",
    18,
    @types.color_text,
  )
  // Keyboard hint
  @draw.draw_text(
    "ENTER: Next  |  ESC: Back",
    card_x + card_w / 2 - 100,
    card_y + card_h - 18,
    12,
    @raylib.Color::new(100, 100, 130, 255),
  )
}

///|
fn draw_button(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  text : String,
  size : Int,
  color : @raylib.Color
) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let hovered = mx >= x && mx < x + w && my >= y && my < y + h
  let bg = if hovered { @types.color_button_hover } else { @types.color_button }
  @raylib.draw_rectangle(x, y, w, h, bg)
  @raylib.draw_rectangle_lines(x, y, w, h, color)
  let tw = @draw.measure_text(text, size)
  @draw.draw_text(text, x + (w - tw) / 2, y + (h - size) / 2, size, color)
}

///|
pub fn draw_playing(game : @types.Game) -> Unit {
  let level = @levels.get_level(game.current_level)
  // Draw subtle grid background
  draw_grid_background(game.frame_count / 4)
  draw_all_views(game, level)
  draw_isometric_view(game, level)
  draw_game_ui(game, level)
  // Completion celebration
  if game.play_state == Complete {
    draw_completion_particles(
      @types.screen_width / 2,
      @types.screen_height / 2,
      game.frame_count,
    )
  }
}
