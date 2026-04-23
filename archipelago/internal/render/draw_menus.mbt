///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.03
  let has_title_art = draw_title_art()
  if has_title_art {
    @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 24, 54, 72))
  }
  if !has_title_art {
  // Animated ocean waves background
  for row in 0..<18 {
    let fy = Float::from_int(row)
    let wave_offset = @types.sinf(time + fy * 0.5) * 8.0
    let y = (fy * 40.0 + wave_offset).to_int()
    let alpha = 20 + (fy * 3.0).to_int()
    let a = if alpha > 60 { 60 } else { alpha }
    @raylib.draw_rectangle(0, y, w, 20, @raylib.Color::new(40, 100, 180, a))
  }
  // Animated islands on title
  for i in 0..<5 {
    let fi = Float::from_int(i)
    let ix_f : Float = fi * 250.0 + 80.0 + @types.sinf(time * 0.7 + fi) * 15.0
    let iy_f : Float = 400.0 + @types.cosf(time * 0.5 + fi * 1.3) * 10.0
    let ix = ix_f.to_int()
    let iy = iy_f.to_int()
    let r : Float = 18.0 + fi * 3.0
    @raylib.draw_circle(ix, iy, r + 3.0, @types.color_island_border)
    @raylib.draw_circle(ix, iy, r, @types.color_island)
  }
  // Animated bridge lines between islands
  for i in 0..<4 {
    let fi = Float::from_int(i)
    let x1_f : Float = fi * 250.0 + 80.0 + @types.sinf(time * 0.7 + fi) * 15.0
    let y1_f : Float = 400.0 + @types.cosf(time * 0.5 + fi * 1.3) * 10.0
    let x1 = x1_f.to_int()
    let y1 = y1_f.to_int()
    let fi2 = Float::from_int(i + 1)
    let x2_f : Float = fi2 * 250.0 + 80.0 + @types.sinf(time * 0.7 + fi2) * 15.0
    let y2_f : Float = 400.0 + @types.cosf(time * 0.5 + fi2 * 1.3) * 10.0
    let x2 = x2_f.to_int()
    let y2 = y2_f.to_int()
    @raylib.draw_line_ex(
      @raylib.Vector2::new(Float::from_int(x1), Float::from_int(y1)),
      @raylib.Vector2::new(Float::from_int(x2), Float::from_int(y2)),
      3.0,
      @types.color_bridge,
    )
  }
  }
  // Title text
  let title = "ARCHIPELAGO"
  let tw = @draw.measure_text(title, 64)
  let pulse = @types.sinf(time * 2.0) * 0.15 + 0.85
  let alpha = (pulse * 255.0).to_int()
  @draw.draw_text(
    title,
    (w - tw) / 2,
    h / 5,
    64,
    @raylib.Color::new(255, 200, 80, alpha),
  )
  // Subtitle
  let sub = "Island Bridge Builder"
  let sw = @draw.measure_text(sub, 24)
  @draw.draw_text(sub, (w - sw) / 2, h / 5 + 80, 24, @types.color_text)
  // Start prompt
  let start = "Click or press ENTER to begin"
  let stw = @draw.measure_text(start, 22)
  let blink = if game.frame_count % 60 < 40 { 255 } else { 120 }
  @draw.draw_text(
    start,
    (w - stw) / 2,
    h - 150,
    22,
    @raylib.Color::new(220, 230, 250, blink),
  )
  // Instructions
  let instr = "Connect islands with bridges to solve each puzzle"
  let iw = @draw.measure_text(instr, 18)
  @draw.draw_text(instr, (w - iw) / 2, h - 100, 18, @types.color_text_dim)
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  // Title
  let title = "Select Region"
  let tw = @draw.measure_text(title, 48)
  @draw.draw_text(title, (w - tw) / 2, 80, 48, @types.color_title_accent)
  let tiers : Array[@types.Tier] = [Shores, Straits, Ocean]
  let tier_desc : Array[String] = [
    "5x5 grids - Learn the basics", "7x7 grids - Tighter constraints", "9x9 grids - Master puzzler",
  ]
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  for i, tier in tiers {
    let bx = 390
    let by = 200 + i * 140
    let bw = 500
    let bh = 110
    let hover = mx >= bx && mx <= bx + bw && my >= by && my <= by + bh
    let bg = if hover { @types.color_button_hover } else { @types.color_button }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    @raylib.draw_rectangle_lines(bx, by, bw, bh, @types.color_island)
    let name = @types.tier_name(tier)
    let nw = @draw.measure_text(name, 36)
    @draw.draw_text(name, bx + (bw - nw) / 2, by + 15, 36, @types.color_text)
    let dw = @draw.measure_text(tier_desc[i], 18)
    @draw.draw_text(
      tier_desc[i],
      bx + (bw - dw) / 2,
      by + 60,
      18,
      @types.color_text_dim,
    )
    // Star count for tier
    let start = @types.tier_start_level(tier)
    let count = @types.tier_level_count(tier)
    let mut total_stars = 0
    let mut completed = 0
    for j in 0..<count {
      let sc = game.level_scores[start + j]
      total_stars = total_stars + sc.stars
      if sc.completed {
        completed = completed + 1
      }
    }
    let star_text = completed.to_string() +
      "/" +
      count.to_string() +
      " completed"
    let stw = @draw.measure_text(star_text, 16)
    @draw.draw_text(
      star_text,
      bx + (bw - stw) / 2,
      by + 85,
      16,
      @types.color_text_dim,
    )
  }
  @draw.draw_text(
    "ESC to go back",
    20,
    @types.screen_height - 40,
    16,
    @types.color_text_dim,
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let name = @types.tier_name(game.current_tier)
  let title = name + " - Select Level"
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(title, (w - tw) / 2, 80, 40, @types.color_title_accent)
  let start = @types.tier_start_level(game.current_tier)
  let count = @types.tier_level_count(game.current_tier)
  let cols = if count <= 5 { count } else { 5 }
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  for i in 0..<count {
    let col = i % cols
    let row = i / cols
    let bx = 240 + col * 170
    let by = 280 + row * 140
    let bw = 140
    let bh = 100
    let hover = mx >= bx && mx <= bx + bw && my >= by && my <= by + bh
    let sc = game.level_scores[start + i]
    let bg = if hover {
      @types.color_button_hover
    } else if sc.completed {
      @raylib.Color::new(40, 80, 50, 255)
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    @raylib.draw_rectangle_lines(bx, by, bw, bh, @types.color_island)
    let num = (i + 1).to_string()
    let nw = @draw.measure_text(num, 32)
    @draw.draw_text(num, bx + (bw - nw) / 2, by + 10, 32, @types.color_text)
    // Draw stars
    draw_stars_at(bx + bw / 2 - 30, by + 55, sc.stars, 3, 18)
  }
  // Tier description
  let grid_size = match game.current_tier {
    Shores => "5x5"
    Straits => "7x7"
    Ocean => "9x9"
  }
  let desc = "Grid size: " + grid_size
  let dw = @draw.measure_text(desc, 20)
  @draw.draw_text(desc, (w - dw) / 2, 200, 20, @types.color_text_dim)
  @draw.draw_text(
    "ESC to go back",
    20,
    @types.screen_height - 40,
    16,
    @types.color_text_dim,
  )
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let sc = game.level_scores[game.current_level]
  // Background overlay
  @raylib.draw_rectangle(
    0,
    0,
    w,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 150),
  )
  // Panel
  @raylib.draw_rectangle(290, 120, 700, 500, @types.color_panel_bg)
  @raylib.draw_rectangle_lines(290, 120, 700, 500, @types.color_island)
  // Title
  let title = "Level Complete!"
  let tw = @draw.measure_text(title, 44)
  @draw.draw_text(title, (w - tw) / 2, 150, 44, @types.color_title_accent)
  // Stars
  draw_stars_at(w / 2 - 60, 220, sc.stars, 3, 36)
  // Stats
  let segs = @types.total_bridge_segments(game.bridges)
  let bridges_text = "Bridges used: " +
    segs.to_string() +
    " (par: " +
    game.par_bridges.to_string() +
    ")"
  let btw = @draw.measure_text(bridges_text, 24)
  @draw.draw_text(bridges_text, (w - btw) / 2, 300, 24, @types.color_text)
  let removal_text = "Bridge removals: " + game.removal_count.to_string()
  let rtw = @draw.measure_text(removal_text, 24)
  @draw.draw_text(removal_text, (w - rtw) / 2, 340, 24, @types.color_text)
  // Star explanations
  let s1 = "1 star: Puzzle solved"
  let s2 = "2 stars: Within par bridges"
  let s3 = "3 stars: Par + no removals"
  @draw.draw_text(s1, 400, 400, 18, @types.color_text_dim)
  @draw.draw_text(s2, 400, 425, 18, @types.color_text_dim)
  @draw.draw_text(s3, 400, 450, 18, @types.color_text_dim)
  // Buttons
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  // Next level button
  let has_next = game.current_level + 1 < @types.total_levels
  if has_next {
    let hover = mx >= 440 && mx <= 640 && my >= 520 && my <= 580
    let bg = if hover { @types.color_button_hover } else { @types.color_button }
    @raylib.draw_rectangle(440, 520, 200, 60, bg)
    @raylib.draw_rectangle_lines(440, 520, 200, 60, @types.color_island)
    let ntx = "Next Level"
    let ntw = @draw.measure_text(ntx, 22)
    @draw.draw_text(ntx, 440 + (200 - ntw) / 2, 535, 22, @types.color_text)
  }
  // Back button
  let hover2 = mx >= 660 && mx <= 860 && my >= 520 && my <= 580
  let bg2 = if hover2 { @types.color_button_hover } else { @types.color_button }
  @raylib.draw_rectangle(660, 520, 200, 60, bg2)
  @raylib.draw_rectangle_lines(660, 520, 200, 60, @types.color_island)
  let btx = "Level Select"
  let btw2 = @draw.measure_text(btx, 22)
  @draw.draw_text(btx, 660 + (200 - btw2) / 2, 535, 22, @types.color_text)
}

///|
fn draw_stars_at(
  x : Int,
  y : Int,
  filled : Int,
  total : Int,
  size : Int,
) -> Unit {
  for i in 0..<total {
    let sx = x + i * (size + 8)
    let color = if i < filled {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    let star = "*"
    @draw.draw_text(star, sx, y, size, color)
  }
}
