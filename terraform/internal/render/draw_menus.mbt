///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.02
  // Animated starfield
  for i in 0..<80 {
    let fi = Float::from_int(i)
    let sx = ((fi * 137.5 + time * 15.0) % Float::from_int(w)).to_int()
    let sy = ((fi * 91.3 + time * 8.0 * (fi % 3.0 + 1.0)) % Float::from_int(h)).to_int()
    let brightness = 60 + (fi * 17.0 % 140.0).to_int()
    @raylib.draw_circle(
      sx,
      sy,
      1.0 + fi % 2.0,
      @raylib.Color::new(brightness, brightness, brightness + 30, 200),
    )
  }
  // Rotating planet visualization
  let planet_cx = Float::from_int(w) / 2.0
  let planet_cy = Float::from_int(h) / 2.0 - 30.0
  let planet_r : Float = 120.0
  // Planet body
  @raylib.draw_circle(
    planet_cx.to_int(),
    planet_cy.to_int(),
    planet_r,
    @raylib.Color::new(40, 60, 90, 255),
  )
  // Biome bands on planet
  for i in 0..<12 {
    let fi = Float::from_int(i)
    let angle = time * 0.5 + fi * @types.pi / 6.0
    let bx = planet_cx + planet_r * 0.7 * @types.cosf(angle)
    let by = planet_cy + planet_r * 0.4 * @types.sinf(angle * 0.8)
    let dx = bx - planet_cx
    let dy = by - planet_cy
    let dist = @types.sqrtf(dx * dx + dy * dy)
    if dist < planet_r * 0.9 {
      let c = match i % 4 {
        0 => @types.color_forest
        1 => @types.color_ocean
        2 => @types.color_desert
        _ => @types.color_barren
      }
      @raylib.draw_circle(
        bx.to_int(),
        by.to_int(),
        15.0 + fi % 5.0,
        @raylib.Color::new(c.r.to_int(), c.g.to_int(), c.b.to_int(), 150),
      )
    }
  }
  // Planet outline glow
  @raylib.draw_circle_lines(
    planet_cx.to_int(),
    planet_cy.to_int(),
    planet_r + 2.0,
    @types.color_accent,
  )
  // Title text
  let title = "TERRAFORM"
  let title_w = @draw.measure_text(title, 64)
  let pulse = @types.sinf(time * 2.0) * 0.1 + 0.9
  let alpha = (pulse * 255.0).to_int()
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    h / 2 + 110,
    64,
    @raylib.Color::new(80, 200, 255, alpha),
  )
  // Subtitle
  let sub = "A Planet Biome Painting Puzzle"
  let sub_w = @draw.measure_text(sub, 22)
  @draw.draw_text(sub, (w - sub_w) / 2, h / 2 + 180, 22, @types.color_text_dim)
  // Start prompt
  let start = "Press ENTER or SPACE to begin"
  let start_w = @draw.measure_text(start, 24)
  let blink = if game.frame_count % 90 < 60 { 255 } else { 100 }
  @draw.draw_text(
    start,
    (w - start_w) / 2,
    h / 2 + 230,
    24,
    @raylib.Color::new(255, 255, 255, blink),
  )
  // Orbiting moons
  draw_title_orbits(game)
  // Version info
  @draw.draw_text("v1.0", w - 50, h - 25, 14, @types.color_text_dim)
}

///|
fn draw_title_orbits(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.02
  let planet_cx = Float::from_int(w) / 2.0
  let planet_cy = Float::from_int(h) / 2.0 - 30.0
  let planet_r : Float = 120.0
  // Inner orbit - small moon
  let orbit1_r = planet_r + 40.0
  let m1_angle = time * 0.8
  let m1x = planet_cx + orbit1_r * @types.cosf(m1_angle)
  let m1y = planet_cy + orbit1_r * 0.3 * @types.sinf(m1_angle)
  // Only draw if in front of planet (simple z-ordering)
  if @types.sinf(m1_angle) > -0.3 {
    @raylib.draw_circle(
      m1x.to_int(),
      m1y.to_int(),
      6.0,
      @raylib.Color::new(180, 180, 200, 200),
    )
    @raylib.draw_circle(
      m1x.to_int(),
      m1y.to_int(),
      4.0,
      @raylib.Color::new(220, 220, 240, 255),
    )
  }
  // Outer orbit - larger moon
  let orbit2_r = planet_r + 80.0
  let m2_angle = time * 0.4 + @types.pi
  let m2x = planet_cx + orbit2_r * @types.cosf(m2_angle)
  let m2y = planet_cy + orbit2_r * 0.25 * @types.sinf(m2_angle)
  if @types.sinf(m2_angle) > -0.3 {
    @raylib.draw_circle(
      m2x.to_int(),
      m2y.to_int(),
      10.0,
      @raylib.Color::new(160, 150, 140, 200),
    )
    @raylib.draw_circle(
      m2x.to_int(),
      m2y.to_int(),
      7.0,
      @raylib.Color::new(200, 190, 180, 255),
    )
  }
  // Orbit trails (dashed ellipses)
  draw_orbit_trail(planet_cx, planet_cy, orbit1_r, orbit1_r * 0.3, time, 40)
  draw_orbit_trail(planet_cx, planet_cy, orbit2_r, orbit2_r * 0.25, time, 50)
}

///|
fn draw_orbit_trail(
  cx : Float,
  cy : Float,
  rx : Float,
  ry : Float,
  _time : Float,
  segments : Int,
) -> Unit {
  for i in 0..<segments {
    let a = Float::from_int(i) * @types.pi * 2.0 / Float::from_int(segments)
    let x = cx + rx * @types.cosf(a)
    let y = cy + ry * @types.sinf(a)
    if i % 3 == 0 {
      @raylib.draw_pixel(
        x.to_int(),
        y.to_int(),
        @raylib.Color::new(80, 80, 100, 60),
      )
    }
  }
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  // Title
  let title = "Select Tier"
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(title, (w - tw) / 2, 40, 40, @types.color_accent)
  // Three tier cards
  let card_w = 300
  let card_h = 350
  let card_gap = 40
  let total_w = card_w * 3 + card_gap * 2
  let start_x = (w - total_w) / 2
  let card_y = 140
  // Compute tier progress
  let seeds_stars = count_tier_stars(game, Seeds)
  let balance_stars = count_tier_stars(game, Balance)
  let harmony_stars = count_tier_stars(game, Harmony)
  let seeds_completed = count_tier_completed(game, Seeds)
  let balance_completed = count_tier_completed(game, Balance)
  let harmony_completed = count_tier_completed(game, Harmony)
  // Seeds
  draw_tier_card(
    start_x, card_y, card_w, card_h, "Seeds", "Learn the basics of\nbiome interaction.\n8 levels.",
    @types.color_tier_seeds, 1, seeds_stars, seeds_completed, 8,
  )
  // Balance
  draw_tier_card(
    start_x + card_w + card_gap,
    card_y,
    card_w,
    card_h,
    "Balance",
    "Tighter targets and\nlimited resources.\n9 levels.",
    @types.color_tier_balance,
    2,
    balance_stars,
    balance_completed,
    9,
  )
  // Harmony
  draw_tier_card(
    start_x + (card_w + card_gap) * 2,
    card_y,
    card_w,
    card_h,
    "Harmony",
    "Master all mechanics.\nPrecise ratios.\n8 levels.",
    @types.color_tier_harmony,
    3,
    harmony_stars,
    harmony_completed,
    8,
  )
  let hint = "[1] Seeds   [2] Balance   [3] Harmony   [Esc] Back"
  let hw = @draw.measure_text(hint, 18)
  @draw.draw_text(
    hint,
    (w - hw) / 2,
    card_y + card_h + 40,
    18,
    @types.color_text_dim,
  )
}

///|
fn draw_tier_card(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  name : String,
  desc : String,
  color : @raylib.Color,
  num : Int,
  stars : Int,
  completed : Int,
  total : Int,
) -> Unit {
  // Card background
  @raylib.draw_rectangle(x, y, w, h, @types.color_panel)
  @raylib.draw_rectangle_lines(x, y, w, h, color)
  // Number
  let num_str = num.to_string()
  let nw = @draw.measure_text(num_str, 80)
  @draw.draw_text(
    num_str,
    x + (w - nw) / 2,
    y + 20,
    80,
    @raylib.Color::new(color.r.to_int(), color.g.to_int(), color.b.to_int(), 60),
  )
  // Name
  let nw2 = @draw.measure_text(name, 32)
  @draw.draw_text(name, x + (w - nw2) / 2, y + 120, 32, color)
  // Description lines
  let lines = split_lines(desc)
  for i in 0..<lines.length() {
    let lw = @draw.measure_text(lines[i], 18)
    @draw.draw_text(
      lines[i],
      x + (w - lw) / 2,
      y + 180 + i * 26,
      18,
      @types.color_text,
    )
  }
  // Progress bar
  let bar_x = x + 30
  let bar_y = y + h - 60
  let bar_w = w - 60
  let bar_h = 8
  @raylib.draw_rectangle(bar_x, bar_y, bar_w, bar_h, @types.color_bar_bg)
  if total > 0 {
    let fill = bar_w * completed / total
    @raylib.draw_rectangle(bar_x, bar_y, fill, bar_h, color)
  }
  @raylib.draw_rectangle_lines(
    bar_x, bar_y, bar_w, bar_h, @types.color_text_dim,
  )
  // Completion text
  let progress_text = completed.to_string() +
    "/" +
    total.to_string() +
    " complete"
  let ptw = @draw.measure_text(progress_text, 14)
  @draw.draw_text(
    progress_text,
    x + (w - ptw) / 2,
    bar_y + 14,
    14,
    @types.color_text_dim,
  )
  // Star count
  let star_text = stars.to_string() + "/" + (total * 3).to_string() + " stars"
  let stw = @draw.measure_text(star_text, 14)
  @draw.draw_text(
    star_text,
    x + (w - stw) / 2,
    bar_y + 30,
    14,
    @types.color_star_gold,
  )
}

///|
fn count_tier_stars(game : @types.Game, tier : @types.Tier) -> Int {
  let (start, end) = @types.tier_level_range(tier)
  let mut total = 0
  for i in start..<end {
    total += game.level_scores[i].stars
  }
  total
}

///|
fn count_tier_completed(game : @types.Game, tier : @types.Tier) -> Int {
  let (start, end) = @types.tier_level_range(tier)
  let mut total = 0
  for i in start..<end {
    if game.level_scores[i].completed {
      total += 1
    }
  }
  total
}

///|
fn split_lines(s : String) -> Array[String] {
  let result : Array[String] = []
  let mut current = ""
  for i in 0..<s.length() {
    let ch = s[i]
    if ch == '\n' {
      result.push(current)
      current = ""
    } else {
      current = current + ch.to_string()
    }
  }
  if current.length() > 0 {
    result.push(current)
  }
  result
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let tier = game.current_tier
  let tier_text = @types.tier_name(tier)
  let color = @types.tier_color(tier)
  // Title
  let title = tier_text + " - Select Level"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(title, (w - tw) / 2, 30, 36, color)
  // Level grid
  let (start_idx, end_idx) = @types.tier_level_range(tier)
  let count = end_idx - start_idx
  let cols = @types.mini(5, count)
  let rows = (count + cols - 1) / cols
  let cell_w = 160
  let cell_h = 120
  let gap = 20
  let total_grid_w = cols * cell_w + (cols - 1) * gap
  let base_x = (w - total_grid_w) / 2
  let base_y = 100
  for i in 0..<count {
    let level_idx = start_idx + i
    let col = i % cols
    let row = i / cols
    let x = base_x + col * (cell_w + gap)
    let y = base_y + row * (cell_h + gap)
    let score = game.level_scores[level_idx]
    draw_level_card(x, y, cell_w, cell_h, level_idx + 1, score, color)
  }
  // Navigation hints
  let hint_y = base_y + rows * (cell_h + gap) + 20
  let hint = "Press 1-" + count.to_string() + " to select   [Esc] Back"
  let hw = @draw.measure_text(hint, 18)
  @draw.draw_text(hint, (w - hw) / 2, hint_y, 18, @types.color_text_dim)
}

///|
fn draw_level_card(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  num : Int,
  score : @types.LevelScore,
  tier_color : @raylib.Color,
) -> Unit {
  // Background
  let bg = if score.completed {
    @raylib.Color::new(25, 35, 25, 220)
  } else {
    @types.color_panel
  }
  @raylib.draw_rectangle(x, y, w, h, bg)
  @raylib.draw_rectangle_lines(x, y, w, h, tier_color)
  // Level number
  let num_str = num.to_string()
  let nw = @draw.measure_text(num_str, 30)
  @draw.draw_text(num_str, x + (w - nw) / 2, y + 8, 30, @types.color_text)
  // Level name
  let name = @types.level_name(num - 1)
  let name_w = @draw.measure_text(name, 12)
  @draw.draw_text(name, x + (w - name_w) / 2, y + 42, 12, @types.color_text_dim)
  // Stars
  let star_y = y + 62
  let star_size = 16
  let total_star_w = star_size * 3 + 8
  let star_x = x + (w - total_star_w) / 2
  for s in 0..<3 {
    let sx = star_x + s * (star_size + 4)
    let c = if s < score.stars {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    draw_star(sx, star_y, star_size, c)
  }
  // Best turns if completed
  if score.completed {
    let best_text = "Best: " + score.best_turns.to_string() + " turns"
    let btw = @draw.measure_text(best_text, 12)
    @draw.draw_text(
      best_text,
      x + (w - btw) / 2,
      y + h - 22,
      12,
      @types.color_text_dim,
    )
    // Completion checkmark
    @draw.draw_text("OK", x + w - 24, y + 4, 12, @types.color_success)
  }
}

///|
fn draw_star(x : Int, y : Int, size : Int, color : @raylib.Color) -> Unit {
  let cx = Float::from_int(x) + Float::from_int(size) / 2.0
  let cy = Float::from_int(y) + Float::from_int(size) / 2.0
  let outer = Float::from_int(size) / 2.0
  let inner = outer * 0.4
  for i in 0..<5 {
    let a1 = Float::from_int(i) * @types.pi * 2.0 / 5.0 - @types.pi / 2.0
    let a2 = a1 + @types.pi / 5.0
    let a3 = a1 + @types.pi * 2.0 / 5.0
    let ox = cx + outer * @types.cosf(a1)
    let oy = cy + outer * @types.sinf(a1)
    let ix = cx + inner * @types.cosf(a2)
    let iy = cy + inner * @types.sinf(a2)
    let ox2 = cx + outer * @types.cosf(a3)
    let oy2 = cy + outer * @types.sinf(a3)
    @raylib.draw_triangle(
      @raylib.Vector2::new(cx, cy),
      @raylib.Vector2::new(ox, oy),
      @raylib.Vector2::new(ix, iy),
      color,
    )
    @raylib.draw_triangle(
      @raylib.Vector2::new(cx, cy),
      @raylib.Vector2::new(ix, iy),
      @raylib.Vector2::new(ox2, oy2),
      color,
    )
  }
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let is_win = game.play_state == Complete
  let time = Float::from_int(game.frame_count) * 0.02
  // Dim background
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 0, 0, 120))
  // Background panel
  let panel_w = 520
  let panel_h = 460
  let px = (w - panel_w) / 2
  let py = (h - panel_h) / 2
  @raylib.draw_rectangle(px, py, panel_w, panel_h, @types.color_panel)
  let border_color = if is_win {
    @types.color_success
  } else {
    @types.color_fail
  }
  @raylib.draw_rectangle_lines(px, py, panel_w, panel_h, border_color)
  // Decorative corner accents
  let corner_size = 15
  // Top-left
  @raylib.draw_line_ex(
    @raylib.Vector2::new(Float::from_int(px), Float::from_int(py)),
    @raylib.Vector2::new(Float::from_int(px + corner_size), Float::from_int(py)),
    2.0,
    border_color,
  )
  @raylib.draw_line_ex(
    @raylib.Vector2::new(Float::from_int(px), Float::from_int(py)),
    @raylib.Vector2::new(Float::from_int(px), Float::from_int(py + corner_size)),
    2.0,
    border_color,
  )
  // Bottom-right
  @raylib.draw_line_ex(
    @raylib.Vector2::new(
      Float::from_int(px + panel_w),
      Float::from_int(py + panel_h),
    ),
    @raylib.Vector2::new(
      Float::from_int(px + panel_w - corner_size),
      Float::from_int(py + panel_h),
    ),
    2.0,
    border_color,
  )
  @raylib.draw_line_ex(
    @raylib.Vector2::new(
      Float::from_int(px + panel_w),
      Float::from_int(py + panel_h),
    ),
    @raylib.Vector2::new(
      Float::from_int(px + panel_w),
      Float::from_int(py + panel_h - corner_size),
    ),
    2.0,
    border_color,
  )
  // Level name
  let level_name = @types.level_name(game.current_level)
  let lnw = @draw.measure_text(level_name, 18)
  @draw.draw_text(level_name, (w - lnw) / 2, py + 12, 18, @types.color_text_dim)
  // Title
  let title = if is_win { "Level Complete!" } else { "Level Failed" }
  let title_color = if is_win {
    @types.color_success
  } else {
    @types.color_fail
  }
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(title, (w - tw) / 2, py + 35, 40, title_color)
  if is_win {
    let level_idx = game.current_level
    let score = game.level_scores[level_idx]
    // Stars with animation
    let star_size = 40
    let total_star_w = star_size * 3 + 20
    let star_x = (w - total_star_w) / 2
    let star_y = py + 100
    for s in 0..<3 {
      let sx = star_x + s * (star_size + 10)
      let c = if s < score.stars {
        @types.color_star_gold
      } else {
        @types.color_star_empty
      }
      // Slight scale pulse for earned stars
      let extra = if s < score.stars {
        (@types.sinf(time * 3.0 + Float::from_int(s)) * 2.0).to_int()
      } else {
        0
      }
      draw_star(sx - extra / 2, star_y - extra / 2, star_size + extra, c)
    }
    // Star description
    let star_desc = match score.stars {
      1 => "Targets achieved"
      2 => "Within par turns!"
      3 => "Perfect - paints to spare!"
      _ => ""
    }
    let sdw = @draw.measure_text(star_desc, 16)
    @draw.draw_text(
      star_desc,
      (w - sdw) / 2,
      star_y + star_size + 10,
      16,
      @types.color_star_gold,
    )
    // Stats
    let turns_color = if game.current_turn <= game.par_turns {
      @types.color_success
    } else {
      @types.color_text
    }
    @draw.draw_text(
      "Turns: " +
      game.current_turn.to_string() +
      " / Par: " +
      game.par_turns.to_string(),
      px + 50,
      py + 190,
      22,
      turns_color,
    )
    let budget_left = @types.total_budget(game.budget)
    let budget_color = if budget_left > 0 {
      @types.color_success
    } else {
      @types.color_text
    }
    @draw.draw_text(
      "Paints remaining: " + budget_left.to_string(),
      px + 50,
      py + 220,
      22,
      budget_color,
    )
    // Ratio results
    draw_result_ratio(
      px + 50,
      py + 260,
      "Forest",
      @types.biome_ratio(game.grid, Forest),
      game.targets.forest_min,
      game.targets.forest_max,
      @types.color_forest,
    )
    draw_result_ratio(
      px + 50,
      py + 290,
      "Ocean",
      @types.biome_ratio(game.grid, Ocean),
      game.targets.ocean_min,
      game.targets.ocean_max,
      @types.color_ocean,
    )
    draw_result_ratio(
      px + 50,
      py + 320,
      "Desert",
      @types.biome_ratio(game.grid, Desert),
      game.targets.desert_min,
      game.targets.desert_max,
      @types.color_desert,
    )
    // Mini planet on results
    draw_mini_planet(px + panel_w - 55, py + 200, game.grid)
  } else {
    // Failure screen
    @draw.draw_text(
      "The ecosystem could not reach",
      px + 50,
      py + 120,
      22,
      @types.color_text,
    )
    @draw.draw_text(
      "the target biome ratios.",
      px + 50,
      py + 150,
      22,
      @types.color_text,
    )
    // Show what was wrong
    let (fs, os, ds) = @biome.ratio_status(game.grid, game.targets)
    let mut fail_y = py + 200
    if fs != 0 {
      let dir = if fs < 0 { "too low" } else { "too high" }
      @draw.draw_text(
        "Forest: " + dir,
        px + 70,
        fail_y,
        20,
        @types.color_forest,
      )
      fail_y += 28
    }
    if os != 0 {
      let dir = if os < 0 { "too low" } else { "too high" }
      @draw.draw_text("Ocean: " + dir, px + 70, fail_y, 20, @types.color_ocean)
      fail_y += 28
    }
    if ds != 0 {
      let dir = if ds < 0 { "too low" } else { "too high" }
      @draw.draw_text(
        "Desert: " + dir,
        px + 70,
        fail_y,
        20,
        @types.color_desert,
      )
    }
    ignore(fail_y)
  }
  // Continue prompt
  let prompt = if is_win {
    "[Enter/N] Next   [R] Retry   [Esc] Menu"
  } else {
    "[R/Enter] Retry   [Esc] Menu"
  }
  let pw = @draw.measure_text(prompt, 18)
  @draw.draw_text(
    prompt,
    (w - pw) / 2,
    py + panel_h - 40,
    18,
    @types.color_text_dim,
  )
}

///|
fn draw_result_ratio(
  x : Int,
  y : Int,
  label : String,
  current : Float,
  min : Float,
  max : Float,
  color : @raylib.Color,
) -> Unit {
  let pct = (current * 100.0).to_int()
  let min_pct = (min * 100.0).to_int()
  let max_pct = (max * 100.0).to_int()
  let in_range = current >= min && current <= max
  let status = if in_range { " OK" } else { " X" }
  let status_color = if in_range {
    @types.color_success
  } else {
    @types.color_fail
  }
  let text = label +
    ": " +
    pct.to_string() +
    "% [" +
    min_pct.to_string() +
    "-" +
    max_pct.to_string() +
    "%]"
  @draw.draw_text(text, x, y, 18, color)
  @draw.draw_text(
    status,
    x + @draw.measure_text(text, 18) + 5,
    y,
    18,
    status_color,
  )
}
