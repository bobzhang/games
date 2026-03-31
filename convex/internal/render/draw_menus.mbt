///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.03
  // Animated background - rotating hull
  draw_animated_hull_bg(w, h, time)
  // Title
  let title = "CONVEX"
  let tw = @draw.measure_text(title, 72)
  let pulse = @types.sinf(time * 1.5) * 0.12 + 0.88
  let alpha = (pulse * 255.0).to_int()
  @draw.draw_text(
    title,
    (w - tw) / 2,
    h / 4 - 20,
    72,
    @raylib.Color::new(0, 220, 255, alpha),
  )
  // Subtitle
  let sub = "CONVEX HULL GEOMETRY PUZZLE"
  let sw = @draw.measure_text(sub, 18)
  @draw.draw_text(sub, (w - sw) / 2, h / 4 + 65, 18, @types.color_ui_dim)
  // Start prompt
  let blink = @types.sinf(time * 3.0)
  if blink > 0.0 {
    let start = "CLICK OR PRESS ENTER TO START"
    let stw = @draw.measure_text(start, 20)
    @draw.draw_text(
      start,
      (w - stw) / 2,
      h * 3 / 4,
      20,
      @types.color_ui_text,
    )
  }
}

///|
fn draw_animated_hull_bg(w : Int, h : Int, time : Float) -> Unit {
  // Draw a slowly morphing convex hull in the background
  let cx = Float::from_int(w) / 2.0
  let cy = Float::from_int(h) / 2.0 + 30.0
  let n = 6
  let base_r : Float = 180.0
  for i in 0..<n {
    let fi = Float::from_int(i)
    let fn_ = Float::from_int(n)
    let angle = fi * 2.0 * @types.pi / fn_ + time * 0.3
    let r = base_r + @types.sinf(time * 0.7 + fi * 1.5) * 40.0
    let x1 = cx + r * @types.cosf(angle)
    let y1 = cy + r * @types.sinf(angle)
    let next_angle = (fi + 1.0) * 2.0 * @types.pi / fn_ + time * 0.3
    let next_r = base_r +
      @types.sinf(time * 0.7 + (fi + 1.0) * 1.5) * 40.0
    let x2 = cx + next_r * @types.cosf(next_angle)
    let y2 = cy + next_r * @types.sinf(next_angle)
    @raylib.draw_line_ex(
      @raylib.Vector2::new(x1, y1),
      @raylib.Vector2::new(x2, y2),
      1.5,
      @raylib.Color::new(40, 60, 100, 60),
    )
    // Vertex dot
    @raylib.draw_circle(x1.to_int(), y1.to_int(), 3.0, @raylib.Color::new(
      60, 100, 160, 80,
    ))
  }
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let _ = game.frame_count
  // Title
  let title = "SELECT TIER"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(title, (w - tw) / 2, 80, 36, @types.color_ui_text)
  // Three tier boxes
  let box_w = 300
  let box_h = 120
  let gap = 40
  let total_w = box_w * 3 + gap * 2
  let start_x = (w - total_w) / 2
  let by = @types.screen_height / 2 - box_h / 2
  let tiers : Array[@types.Tier] = [Vertices, Edges, Sculpt]
  let descs : Array[String] = [
    "Simple shapes - place points at corners",
    "Tricky edges with interior distractors",
    "Remove excess points to sculpt the hull",
  ]
  let counts : Array[Int] = [
    @types.tier1_count,
    @types.tier2_count,
    @types.tier3_count,
  ]
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  for i in 0..<3 {
    let bx = start_x + i * (box_w + gap)
    let hovered = mx >= bx && mx <= bx + box_w && my >= by && my <= by + box_h
    let bg = if hovered {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(bx, by, box_w, box_h, bg)
    let tc = @types.tier_color(tiers[i])
    @raylib.draw_rectangle_lines(bx, by, box_w, box_h, tc)
    // Tier name
    let name = @types.tier_name(tiers[i])
    let nw = @draw.measure_text(name, 24)
    @draw.draw_text(name, bx + (box_w - nw) / 2, by + 15, 24, tc)
    // Count
    let count_text = counts[i].to_string() + " levels"
    let cw = @draw.measure_text(count_text, 14)
    @draw.draw_text(
      count_text,
      bx + (box_w - cw) / 2,
      by + 48,
      14,
      @types.color_ui_dim,
    )
    // Description
    let dw = @draw.measure_text(descs[i], 11)
    @draw.draw_text(
      descs[i],
      bx + (box_w - dw) / 2,
      by + 72,
      11,
      @types.color_ui_dim,
    )
    // Stars earned
    let tier_start = @types.tier_start_index(tiers[i])
    let tier_count = @types.tier_level_count(tiers[i])
    let mut total_stars = 0
    let mut completed = 0
    for j in 0..<tier_count {
      let s = game.scores[tier_start + j]
      if s.completed {
        completed += 1
        total_stars += s.stars
      }
    }
    let star_text = total_stars.to_string() +
      "/" +
      (tier_count * 3).to_string() +
      " stars"
    let stw = @draw.measure_text(star_text, 12)
    @draw.draw_text(
      star_text,
      bx + (box_w - stw) / 2,
      by + 95,
      12,
      @types.color_star_gold,
    )
    let _ = completed
  }
  // ESC hint
  @draw.draw_text("ESC: Back", 20, 680, 14, @types.color_ui_dim)
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let tc = @types.tier_color(game.selected_tier)
  // Title
  let title = @types.tier_name(game.selected_tier) + " - SELECT LEVEL"
  let tw = @draw.measure_text(title, 30)
  @draw.draw_text(title, (w - tw) / 2, 80, 30, tc)
  let tier_start = @types.tier_start_index(game.selected_tier)
  let tier_count = @types.tier_level_count(game.selected_tier)
  let cols = 4
  let cell_w = 180
  let cell_h = 80
  let gap = 20
  let total_w = cols * cell_w + (cols - 1) * gap
  let start_x = (w - total_w) / 2
  let start_y = 200
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  for i in 0..<tier_count {
    let col = i % cols
    let row = i / cols
    let cx = start_x + col * (cell_w + gap)
    let cy = start_y + row * (cell_h + gap)
    let hovered = mx >= cx && mx <= cx + cell_w && my >= cy && my <= cy + cell_h
    let bg = if hovered {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(cx, cy, cell_w, cell_h, bg)
    @raylib.draw_rectangle_lines(cx, cy, cell_w, cell_h, tc)
    // Level number
    let num = (tier_start + i + 1).to_string()
    @draw.draw_text(num, cx + 10, cy + 8, 20, @types.color_ui_text)
    // Level name
    let name = get_level_name_str(tier_start + i)
    @draw.draw_text(name, cx + 10, cy + 34, 12, @types.color_ui_dim)
    // Stars
    let score = game.scores[tier_start + i]
    if score.completed {
      draw_stars(cx + 10, cy + 54, score.stars, 3)
    }
  }
  // Back button
  let back_hovered = mx >= 40 && mx <= 160 && my >= 640 && my <= 680
  let back_bg = if back_hovered {
    @types.color_button_hover
  } else {
    @types.color_button
  }
  @raylib.draw_rectangle(40, 640, 120, 40, back_bg)
  @raylib.draw_rectangle_lines(40, 640, 120, 40, @types.color_ui_dim)
  @draw.draw_text("BACK", 70, 650, 18, @types.color_ui_text)
  @draw.draw_text("ESC: Back", 20, 700, 14, @types.color_ui_dim)
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let cx = w / 2
  // Panel
  let pw = 500
  let ph = 440
  let px = cx - pw / 2
  let py = h / 2 - ph / 2
  @raylib.draw_rectangle(px, py, pw, ph, @types.color_panel)
  @raylib.draw_rectangle_lines(px, py, pw, ph, @types.color_match)
  // Title
  let title = "LEVEL COMPLETE!"
  let tw = @draw.measure_text(title, 32)
  @draw.draw_text(title, cx - tw / 2, py + 20, 32, @types.color_match)
  // Level name
  let name = get_level_name_str(game.level_index)
  let nw = @draw.measure_text(name, 20)
  @draw.draw_text(name, cx - nw / 2, py + 65, 20, @types.color_ui_text)
  // Stars
  let score = game.scores[game.level_index]
  let star_x = cx - 42
  draw_stars(star_x, py + 105, score.stars, 3)
  // Stats
  let pts_text = "Points used: " + score.points_used.to_string()
  let pw2 = @draw.measure_text(pts_text, 18)
  @draw.draw_text(pts_text, cx - pw2 / 2, py + 155, 18, @types.color_ui_text)
  let par = get_level_par(game.level_index)
  let min = get_level_min(game.level_index)
  let par_text = "Par: " + par.to_string() + "  Min: " + min.to_string()
  let prw = @draw.measure_text(par_text, 16)
  @draw.draw_text(par_text, cx - prw / 2, py + 185, 16, @types.color_ui_dim)
  // Rating text
  let rating = if score.stars == 3 {
    "PERFECT! Minimum points used!"
  } else if score.stars == 2 {
    "Great! Within par."
  } else {
    "Completed! Try with fewer points."
  }
  let rw = @draw.measure_text(rating, 16)
  let rc = if score.stars == 3 {
    @types.color_star_gold
  } else if score.stars == 2 {
    @types.color_match
  } else {
    @types.color_ui_dim
  }
  @draw.draw_text(rating, cx - rw / 2, py + 220, 16, rc)
  // Buttons
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let btn_w = 200
  let btn_h = 40
  let btn_x = cx - btn_w / 2
  // Next level
  let next = game.level_index + 1
  if next < @types.total_levels {
    let ny = py + 260
    let nh = mx >= btn_x && mx <= btn_x + btn_w && my >= ny && my <= ny + btn_h
    let bg = if nh { @types.color_button_hover } else { @types.color_button }
    @raylib.draw_rectangle(btn_x, ny, btn_w, btn_h, bg)
    @raylib.draw_rectangle_lines(btn_x, ny, btn_w, btn_h, @types.color_match)
    let nt = "NEXT LEVEL"
    let ntw = @draw.measure_text(nt, 18)
    @draw.draw_text(nt, cx - ntw / 2, ny + 10, 18, @types.color_match)
  }
  // Retry
  let ry = py + 310
  let rh = mx >= btn_x && mx <= btn_x + btn_w && my >= ry && my <= ry + btn_h
  let rbg = if rh { @types.color_button_hover } else { @types.color_button }
  @raylib.draw_rectangle(btn_x, ry, btn_w, btn_h, rbg)
  @raylib.draw_rectangle_lines(btn_x, ry, btn_w, btn_h, @types.color_ui_dim)
  let rt = "RETRY"
  let rtw = @draw.measure_text(rt, 18)
  @draw.draw_text(rt, cx - rtw / 2, ry + 10, 18, @types.color_ui_text)
  // Menu
  let mny = py + 360
  let mh = mx >= btn_x && mx <= btn_x + btn_w && my >= mny && my <= mny + btn_h
  let mbg = if mh { @types.color_button_hover } else { @types.color_button }
  @raylib.draw_rectangle(btn_x, mny, btn_w, btn_h, mbg)
  @raylib.draw_rectangle_lines(btn_x, mny, btn_w, btn_h, @types.color_ui_dim)
  let mt = "MENU"
  let mtw = @draw.measure_text(mt, 18)
  @draw.draw_text(mt, cx - mtw / 2, mny + 10, 18, @types.color_ui_text)
}
