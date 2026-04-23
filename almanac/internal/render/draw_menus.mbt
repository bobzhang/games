///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.02
  match tex_title.val {
    Some(title_art) => {
      draw_cover_art(title_art, w, h)
      @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(7, 11, 20, 92))
    }
    None => ()
  }
  // Animated weather background
  for i in 0..<40 {
    let fi = Float::from_int(i)
    let px = ((fi * 97.3 + time * 30.0) % Float::from_int(w)).to_int()
    let py = ((fi * 63.7 + time * 15.0 * (fi % 3.0 + 1.0)) % Float::from_int(h)).to_int()
    let kind = i % 4
    if kind == 0 {
      @raylib.draw_circle(px, py, 3.0, @raylib.Color::new(255, 220, 60, 80))
    } else if kind == 1 {
      @raylib.draw_line(
        px,
        py,
        px,
        py + 6,
        @raylib.Color::new(70, 130, 230, 80),
      )
    } else if kind == 2 {
      @raylib.draw_circle(px, py, 5.0, @raylib.Color::new(160, 160, 170, 48))
    } else {
      @raylib.draw_line(
        px,
        py,
        px + 12,
        py,
        @raylib.Color::new(220, 240, 255, 64),
      )
    }
  }
  // Title text
  let title = "ALMANAC"
  let title_w = @draw.measure_text(title, 72)
  let pulse = @types.sinf(time * 2.0) * 0.1 + 0.9
  let alpha = (pulse * 255.0).to_int()
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    h / 4 - 20,
    72,
    @raylib.Color::new(220, 240, 255, alpha),
  )
  // Subtitle
  let sub = "Weather Cascade Puzzle"
  let sub_w = @draw.measure_text(sub, 22)
  @draw.draw_text(
    sub,
    (w - sub_w) / 2,
    h / 4 + 60,
    22,
    @raylib.Color::new(180, 200, 220, 200),
  )
  // Weather icons row
  let icon_y = h / 2 - 20
  let icons : Array[@types.WeatherState] = [Sunny, Rainy, Cloudy, Windy, Stormy]
  for i in 0..<icons.length() {
    let fi = Float::from_int(i)
    let ix = w / 2 - 120 + (fi * 60.0).to_int()
    let bob = @types.sinf(time * 2.0 + fi * 0.8) * 5.0
    let weather = icons[i]
    let color = @types.weather_color(weather)
    match weather_art(weather) {
      Some(texture) =>
        draw_art_fit(
          texture,
          Float::from_int(ix),
          Float::from_int(icon_y) + bob,
          42.0,
          42.0,
          if weather == Sunny {
            time * 8.0
          } else {
            0.0
          },
          @raylib.white,
        )
      None => @raylib.draw_circle(ix, icon_y + bob.to_int(), 12.0, color)
    }
    let label = @types.weather_name(weather)
    let iw = @draw.measure_text(label, 12)
    @draw.draw_text(label, ix - iw / 2, icon_y + 24, 12, color)
  }
  // Start prompt
  let start_text = "PRESS ENTER TO START"
  let start_w = @draw.measure_text(start_text, 24)
  let blink = if game.frame_count % 60 < 40 { 255 } else { 100 }
  @draw.draw_text(
    start_text,
    (w - start_w) / 2,
    h * 3 / 4,
    24,
    @raylib.Color::new(220, 240, 255, blink),
  )
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  // Title
  let title = "SELECT SEASON"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(title, (w - tw) / 2, 60, 36, @types.color_hud_text)
  // Three tier boxes
  let tiers : Array[@types.Tier] = [Spring, Summer, Monsoon]
  let descs = [
    "Sun & Rain basics", "Wind, Clouds & Hills", "Storms & Complex terrain",
  ]
  for i in 0..<tiers.length() {
    let tier = tiers[i]
    let bx = w / 2 - 150
    let by = 140 + i * 160
    let bw = 300
    let bh = 130
    let selected = game.current_tier == tier
    let col = @types.tier_color(tier)
    let bg = if selected {
      @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 50)
    } else {
      @raylib.Color::new(30, 35, 50, 200)
    }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    @raylib.draw_rectangle_lines(bx, by, bw, bh, col)
    if selected {
      @raylib.draw_rectangle_lines(bx - 2, by - 2, bw + 4, bh + 4, col)
    }
    // Tier name
    let name = @types.tier_name(tier)
    let nw = @draw.measure_text(name, 28)
    @draw.draw_text(name, bx + (bw - nw) / 2, by + 15, 28, col)
    // Level count
    let count = @types.tier_level_count(tier)
    let count_text = count.to_string() + " levels"
    let cw = @draw.measure_text(count_text, 16)
    @draw.draw_text(
      count_text,
      bx + (bw - cw) / 2,
      by + 52,
      16,
      @types.color_hud_text,
    )
    // Description
    let desc = descs[i]
    let dw = @draw.measure_text(desc, 14)
    @draw.draw_text(
      desc,
      bx + (bw - dw) / 2,
      by + 78,
      14,
      @raylib.Color::new(150, 150, 160, 200),
    )
    // Completion stars
    let (start, end) = @levels.tier_levels(tier)
    let mut total_stars = 0
    for li in start..<end {
      if li < game.level_scores.length() {
        total_stars += game.level_scores[li].stars
      }
    }
    let star_text = total_stars.to_string() +
      "/" +
      ((end - start) * 3).to_string() +
      " stars"
    let sw = @draw.measure_text(star_text, 14)
    @draw.draw_text(
      star_text,
      bx + (bw - sw) / 2,
      by + 100,
      14,
      @types.color_star_on,
    )
    // Key hint
    let key = (i + 1).to_string()
    @draw.draw_text(
      key,
      bx + bw - 24,
      by + 8,
      18,
      @raylib.Color::new(120, 120, 130, 200),
    )
  }
  // Navigation hint
  let hint = "Up/Down + Enter  or  1/2/3  |  ESC: Back"
  let hw = @draw.measure_text(hint, 16)
  @draw.draw_text(
    hint,
    (w - hw) / 2,
    h - 50,
    16,
    @raylib.Color::new(120, 120, 130, 200),
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let (start, end) = @levels.tier_levels(game.current_tier)
  let tier_col = @types.tier_color(game.current_tier)
  // Title
  let title = @types.tier_name(game.current_tier) + " Levels"
  let tw = @draw.measure_text(title, 32)
  @draw.draw_text(title, (w - tw) / 2, 40, 32, tier_col)
  // Level grid
  let cols = 4
  let cell_w = 180
  let cell_h = 100
  let gap = 20
  let total_w = cols * cell_w + (cols - 1) * gap
  let base_x = (w - total_w) / 2
  let base_y = 100
  for li in start..<end {
    let idx = li - start
    let col_pos = idx % cols
    let row_pos = idx / cols
    let bx = base_x + col_pos * (cell_w + gap)
    let by = base_y + row_pos * (cell_h + gap)
    let selected = game.current_level == li
    let level = @levels.get_level(li)
    let score = game.level_scores[li]
    let bg = if selected {
      @raylib.Color::new(
        tier_col.r.to_int(),
        tier_col.g.to_int(),
        tier_col.b.to_int(),
        50,
      )
    } else {
      @raylib.Color::new(30, 35, 50, 200)
    }
    @raylib.draw_rectangle(bx, by, cell_w, cell_h, bg)
    @raylib.draw_rectangle_lines(bx, by, cell_w, cell_h, tier_col)
    if selected {
      @raylib.draw_rectangle_lines(
        bx - 2,
        by - 2,
        cell_w + 4,
        cell_h + 4,
        tier_col,
      )
    }
    // Level number
    let num = (idx + 1).to_string()
    @draw.draw_text(num, bx + 8, by + 6, 20, tier_col)
    // Level name
    @draw.draw_text(level.name, bx + 8, by + 32, 14, @types.color_hud_text)
    // Stars
    for s in 0..<3 {
      let sx = bx + 8 + s * 22
      let sy = by + 54
      let star_col = if s < score.stars {
        @types.color_star_on
      } else {
        @types.color_star_off
      }
      draw_star(sx + 8, sy + 8, 8, star_col)
    }
    // Completed check
    if score.completed {
      @draw.draw_text(
        "OK",
        bx + cell_w - 30,
        by + 6,
        14,
        @raylib.Color::new(0, 255, 0, 200),
      )
    }
  }
  // Navigation hint
  let hint = "Arrows + Enter  |  ESC: Back"
  let hw = @draw.measure_text(hint, 16)
  @draw.draw_text(
    hint,
    (w - hw) / 2,
    680,
    16,
    @raylib.Color::new(120, 120, 130, 200),
  )
}

///|
fn draw_playing(game : @types.Game) -> Unit {
  draw_grid(game)
  draw_ui(game)
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let level = @levels.get_level(game.current_level)
  let score = game.level_scores[game.current_level]
  // Background overlay
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 0, 0, 150))
  // Results panel
  let pw = 400
  let ph = 350
  let ppx = (w - pw) / 2
  let ppy = (h - ph) / 2
  @raylib.draw_rectangle(ppx, ppy, pw, ph, @types.color_hud_bg)
  @raylib.draw_rectangle_lines(ppx, ppy, pw, ph, @types.tier_color(level.tier))
  // Title
  let completed = score.completed
  let title = if completed { "LEVEL COMPLETE!" } else { "LEVEL FAILED" }
  let tcol = if completed {
    @raylib.Color::new(0, 255, 0, 255)
  } else {
    @raylib.Color::new(255, 100, 100, 255)
  }
  let tw = @draw.measure_text(title, 30)
  @draw.draw_text(title, ppx + (pw - tw) / 2, ppy + 20, 30, tcol)
  // Level name
  let nw = @draw.measure_text(level.name, 20)
  @draw.draw_text(
    level.name,
    ppx + (pw - nw) / 2,
    ppy + 60,
    20,
    @types.color_hud_text,
  )
  // Stars
  let star_y = ppy + 100
  for i in 0..<3 {
    let sx = ppx + pw / 2 - 60 + i * 40
    let col = if i < score.stars {
      @types.color_star_on
    } else {
      @types.color_star_off
    }
    draw_star(sx + 16, star_y + 16, 16, col)
  }
  // Stats
  let stat_y = star_y + 50
  @draw.draw_text(
    "Sources used: " + score.sources_used.to_string(),
    ppx + 40,
    stat_y,
    18,
    @types.color_hud_text,
  )
  @draw.draw_text(
    "Par: " + level.par_sources.to_string(),
    ppx + 260,
    stat_y,
    18,
    @raylib.Color::new(150, 150, 160, 200),
  )
  @draw.draw_text(
    "Turns taken: " + score.turns_taken.to_string(),
    ppx + 40,
    stat_y + 30,
    18,
    @types.color_hud_text,
  )
  @draw.draw_text(
    "Par: " + level.par_turns.to_string(),
    ppx + 260,
    stat_y + 30,
    18,
    @raylib.Color::new(150, 150, 160, 200),
  )
  // Actions
  let act_y = stat_y + 90
  @draw.draw_text(
    "R - Retry     Enter - Next Level     ESC - Menu",
    ppx + 20,
    act_y,
    14,
    @raylib.Color::new(150, 150, 160, 200),
  )
}

///|
fn draw_star(cx : Int, cy : Int, size : Int, color : @raylib.Color) -> Unit {
  let s = Float::from_int(size)
  let outer = s
  let inner = s * 0.4
  @raylib.draw_circle(cx, cy, inner, color)
  for i in 0..<5 {
    let angle = Float::from_int(i) * 1.2566 - 1.5708
    let ox = @types.cosf(angle) * outer
    let oy = @types.sinf(angle) * outer
    @raylib.draw_line(cx, cy, cx + ox.to_int(), cy + oy.to_int(), color)
  }
}
