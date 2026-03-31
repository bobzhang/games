///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.03
  // Animated decorative string art in background
  let cx = Float::from_int(w / 2)
  let cy = Float::from_int(h / 2)
  let rad : Float = 200.0
  for i in 0..<12 {
    let fi = Float::from_int(i)
    let angle1 : Float = fi * 2.0 * @types.pi / 12.0 + time * 0.3
    let angle2 : Float = (fi + 5.0) * 2.0 * @types.pi / 12.0 + time * 0.3
    let x1 = cx + rad * @types.cosf(angle1)
    let y1 = cy + rad * @types.sinf(angle1)
    let x2 = cx + rad * @types.cosf(angle2)
    let y2 = cy + rad * @types.sinf(angle2)
    let alpha_f : Float = 30.0 + @types.sinf(time + fi * 0.5) * 20.0
    let alpha = alpha_f.to_int()
    @raylib.draw_line_ex(
      @raylib.Vector2::new(x1, y1),
      @raylib.Vector2::new(x2, y2),
      1.0,
      @raylib.Color::new(0, 180, 220, alpha),
    )
  }
  // Decorative dots around center
  for i in 0..<24 {
    let fi = Float::from_int(i)
    let angle : Float = fi * 2.0 * @types.pi / 24.0
    let x = cx + 160.0 * @types.cosf(angle)
    let y = cy + 160.0 * @types.sinf(angle)
    let pulse : Float = @types.sinf(time * 2.0 + fi * 0.3) * 0.5 + 0.5
    let alpha_f : Float = 60.0 + pulse * 80.0
    let alpha = alpha_f.to_int()
    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      3.0,
      @raylib.Color::new(255, 215, 0, alpha),
    )
  }
  // Title text
  let title = "CRADLE"
  let title_w = @draw.measure_text(title, 72)
  let pulse : Float = @types.sinf(time * 1.5) * 0.1 + 0.9
  let alpha = (pulse * 255.0).to_int()
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    h / 4 - 20,
    72,
    @raylib.Color::new(0, 220, 255, alpha),
  )
  // Subtitle
  let sub = "STRING ART GEOMETRY PUZZLE"
  let sub_w = @draw.measure_text(sub, 18)
  @draw.draw_text(sub, (w - sub_w) / 2, h / 4 + 60, 18, @types.color_dim_text)
  // Instructions
  let inst = "Stretch strings between pegs. Create intersections on the targets."
  let inst_w = @draw.measure_text(inst, 16)
  @draw.draw_text(inst, (w - inst_w) / 2, h / 2 + 60, 16, @types.color_dim_text)
  // Start prompt
  let start_text = "PRESS ENTER TO START"
  let start_w = @draw.measure_text(start_text, 26)
  let blink = if game.frame_count % 60 < 40 { 255 } else { 100 }
  @draw.draw_text(
    start_text,
    (w - start_w) / 2,
    h * 3 / 4,
    26,
    @raylib.Color::new(255, 255, 255, blink),
  )
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  // Header
  let header = "SELECT TIER"
  let hw = @draw.measure_text(header, 36)
  @draw.draw_text(header, (w - hw) / 2, 40, 36, @types.color_hud_text)
  // Three tier cards
  let tiers : Array[@types.Tier] = [Lines, Weave, Art]
  let tier_names = ["LINES", "WEAVE", "ART"]
  let tier_descs = ["Simple crossings", "Multiple weaves", "Precise placement"]
  let tier_range = ["Levels 1-8", "Levels 9-17", "Levels 18-25"]
  let card_w = 320
  let card_h = 400
  let gap = 40
  let start_x = (w - card_w * 3 - gap * 2) / 2
  let card_y = 130
  let mouse_x = @raylib.get_mouse_x()
  let mouse_y = @raylib.get_mouse_y()
  for i in 0..<3 {
    let cx = start_x + i * (card_w + gap)
    let tier = tiers[i]
    let tc = @types.tier_color(tier)
    let hovered = mouse_x >= cx &&
      mouse_x <= cx + card_w &&
      mouse_y >= card_y &&
      mouse_y <= card_y + card_h
    // Card background
    let bg = if hovered {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(cx, card_y, card_w, card_h, bg)
    @raylib.draw_rectangle_lines(cx, card_y, card_w, card_h, tc)
    // Selected indicator
    if tier == game.selected_tier {
      @raylib.draw_rectangle_lines(
        cx - 2,
        card_y - 2,
        card_w + 4,
        card_h + 4,
        tc,
      )
    }
    // Tier name
    let tnw = @draw.measure_text(tier_names[i], 32)
    @draw.draw_text(
      tier_names[i],
      cx + (card_w - tnw) / 2,
      card_y + 30,
      32,
      tc,
    )
    // Description
    let dw = @draw.measure_text(tier_descs[i], 16)
    @draw.draw_text(
      tier_descs[i],
      cx + (card_w - dw) / 2,
      card_y + 75,
      16,
      @types.color_dim_text,
    )
    // Range
    let rw = @draw.measure_text(tier_range[i], 16)
    @draw.draw_text(
      tier_range[i],
      cx + (card_w - rw) / 2,
      card_y + 100,
      16,
      @types.color_dim_text,
    )
    // Stars earned in this tier
    let tier_start = @types.tier_start_level(tier)
    let tier_count = @types.tier_level_count(tier)
    let mut total_stars = 0
    let max_stars = tier_count * 3
    for j in tier_start..<(tier_start + tier_count) {
      total_stars = total_stars + game.scores[j].stars
    }
    let star_text = total_stars.to_string() +
      " / " +
      max_stars.to_string() +
      " stars"
    let sw = @draw.measure_text(star_text, 18)
    @draw.draw_text(
      star_text,
      cx + (card_w - sw) / 2,
      card_y + 150,
      18,
      @types.color_gold_star,
    )
    // Decorative mini circle art
    let dcx = Float::from_int(cx + card_w / 2)
    let dcy = Float::from_int(card_y + 280)
    let dr : Float = 60.0
    let line_count = if i == 0 { 3 } else if i == 1 { 5 } else { 8 }
    @raylib.draw_circle_lines(
      dcx.to_int(),
      dcy.to_int(),
      dr,
      @raylib.Color::new(
        tc.r.to_int(),
        tc.g.to_int(),
        tc.b.to_int(),
        60,
      ),
    )
    for k in 0..<line_count {
      let fk = Float::from_int(k)
      let fcount = Float::from_int(line_count)
      let a1 : Float = fk * @types.pi * 2.0 / fcount
      let a2 : Float = a1 + @types.pi * 2.0 / fcount * 2.0
      let x1 = dcx + dr * @types.cosf(a1)
      let y1 = dcy + dr * @types.sinf(a1)
      let x2 = dcx + dr * @types.cosf(a2)
      let y2 = dcy + dr * @types.sinf(a2)
      @raylib.draw_line_ex(
        @raylib.Vector2::new(x1, y1),
        @raylib.Vector2::new(x2, y2),
        1.0,
        @raylib.Color::new(
          tc.r.to_int(),
          tc.g.to_int(),
          tc.b.to_int(),
          80,
        ),
      )
    }
    // Click handler indicator
    if hovered {
      let click_text = "Click to enter"
      let cw = @draw.measure_text(click_text, 14)
      @draw.draw_text(
        click_text,
        cx + (card_w - cw) / 2,
        card_y + card_h - 35,
        14,
        @raylib.Color::new(255, 255, 255, 200),
      )
    }
  }
  // Back hint
  @draw.draw_text(
    "ESC: back to title",
    20,
    @types.screen_height - 30,
    14,
    @types.color_dim_text,
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let tier = game.selected_tier
  let tc = @types.tier_color(tier)
  let tier_start = @types.tier_start_level(tier)
  let tier_count = @types.tier_level_count(tier)
  // Header
  let header = @types.tier_name(tier) + " - SELECT LEVEL"
  let hw = @draw.measure_text(header, 32)
  @draw.draw_text(header, (w - hw) / 2, 40, 32, tc)
  // Level grid
  let cols = 5
  let cell_w = 180
  let cell_h = 100
  let gap = 20
  let total_w = cols * cell_w + (cols - 1) * gap
  let start_x = (w - total_w) / 2
  let start_y = 120
  let mouse_x = @raylib.get_mouse_x()
  let mouse_y = @raylib.get_mouse_y()
  for i in 0..<tier_count {
    let level_idx = tier_start + i
    let col = i % cols
    let row = i / cols
    let cx = start_x + col * (cell_w + gap)
    let cy = start_y + row * (cell_h + gap)
    let hovered = mouse_x >= cx &&
      mouse_x <= cx + cell_w &&
      mouse_y >= cy &&
      mouse_y <= cy + cell_h
    let bg = if hovered {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(cx, cy, cell_w, cell_h, bg)
    let border_c = if game.scores[level_idx].completed {
      @types.color_target_hit
    } else {
      tc
    }
    @raylib.draw_rectangle_lines(cx, cy, cell_w, cell_h, border_c)
    // Level number
    let num_str = (level_idx + 1).to_string()
    @draw.draw_text(num_str, cx + 10, cy + 8, 24, @types.color_hud_text)
    // Level name
    let name = game.level_data[level_idx].name
    @draw.draw_text(name, cx + 10, cy + 38, 14, @types.color_dim_text)
    // Stars
    let stars = game.scores[level_idx].stars
    draw_star_display(cx + 10, cy + 62, stars, 20)
    // Par info
    let par = game.level_data[level_idx].par_strings.to_string()
    @draw.draw_text(
      "par:" + par,
      cx + cell_w - 50,
      cy + 68,
      14,
      @types.color_dim_text,
    )
    // Target count
    let tgt = game.level_data[level_idx].targets.length().to_string()
    @draw.draw_text(
      tgt + " tgt",
      cx + cell_w - 50,
      cy + 10,
      14,
      @types.color_dim_text,
    )
  }
  // Back hint
  @draw.draw_text(
    "ESC: back to tiers",
    20,
    @types.screen_height - 30,
    14,
    @types.color_dim_text,
  )
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let level = game.level_data[game.current_level]
  let score = game.scores[game.current_level]
  let tc = @types.tier_color(level.tier)
  // Background dim
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 0, 0, 180))
  // Panel
  let pw = 500
  let ph = 400
  let px = (w - pw) / 2
  let py = (h - ph) / 2
  @raylib.draw_rectangle(px, py, pw, ph, @types.color_panel_bg)
  @raylib.draw_rectangle_lines(px, py, pw, ph, tc)
  // Header
  let header = "LEVEL COMPLETE!"
  let hw = @draw.measure_text(header, 36)
  @draw.draw_text(
    header,
    px + (pw - hw) / 2,
    py + 20,
    36,
    @types.color_target_hit,
  )
  // Level name
  let name = level.name
  let nw = @draw.measure_text(name, 22)
  @draw.draw_text(name, px + (pw - nw) / 2, py + 65, 22, tc)
  // Stars display (large)
  let star_x = px + (pw - 3 * 48) / 2
  draw_star_display(star_x, py + 110, score.stars, 40)
  // Stats
  let strings_text = "Strings used: " + score.strings_used.to_string()
  let par_text = "Par: " + level.par_strings.to_string()
  let targets_text = "Targets: " +
    level.targets.length().to_string() +
    " / " +
    level.targets.length().to_string()
  @draw.draw_text(strings_text, px + 60, py + 180, 20, @types.color_hud_text)
  @draw.draw_text(par_text, px + 60, py + 210, 20, @types.color_dim_text)
  @draw.draw_text(targets_text, px + 60, py + 240, 20, @types.color_hud_text)
  // Star explanations
  @draw.draw_text(
    "1 star: all targets hit",
    px + 60,
    py + 280,
    14,
    if score.stars >= 1 {
      @types.color_gold_star
    } else {
      @types.color_empty_star
    },
  )
  @draw.draw_text(
    "2 stars: within par strings",
    px + 60,
    py + 300,
    14,
    if score.stars >= 2 {
      @types.color_gold_star
    } else {
      @types.color_empty_star
    },
  )
  @draw.draw_text(
    "3 stars: par + tight tolerance",
    px + 60,
    py + 320,
    14,
    if score.stars >= 3 {
      @types.color_gold_star
    } else {
      @types.color_empty_star
    },
  )
  // Navigation
  @draw.draw_text(
    "ENTER: next level    ESC: level select    R: retry",
    px + 40,
    py + ph - 40,
    14,
    @types.color_dim_text,
  )
}
