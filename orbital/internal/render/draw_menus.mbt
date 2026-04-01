///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  // Starfield
  draw_starfield(game)
  // Title
  let title = "ORBITAL"
  let title_w = @draw.measure_text(title, 64)
  let time = Float::from_int(game.frame_count) * 0.02
  let pulse = @types.sinf(time * 2.0) * 0.1 + 0.9
  let alpha = (pulse * 255.0).to_int()
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    h / 5,
    64,
    @raylib.Color::new(80, 220, 255, alpha),
  )
  // Subtitle
  let sub = "GRAVITY ASSIST TRAJECTORY PUZZLE"
  let sub_w = @draw.measure_text(sub, 18)
  @draw.draw_text(
    sub,
    (w - sub_w) / 2,
    h / 5 + 75,
    18,
    @raylib.Color::new(150, 170, 200, 200),
  )
  // Decorative orbiting dot
  let orbit_r : Float = 50.0
  let cx = Float::from_int(w) / 2.0
  let cy = Float::from_int(h / 5) + 30.0
  let dot_x = cx + @types.cosf(time * 1.5) * orbit_r
  let dot_y = cy + @types.sinf(time * 1.5) * orbit_r * 0.4
  @raylib.draw_circle(dot_x.to_int(), dot_y.to_int(), 3.0, @types.color_probe)
  // Controls info
  let ctrl1 = "Left/Right - Aim    Space - Launch    R - Restart"
  let c1w = @draw.measure_text(ctrl1, 14)
  @draw.draw_text(
    ctrl1,
    (w - c1w) / 2,
    h / 2 + 40,
    14,
    @raylib.Color::new(130, 140, 160, 180),
  )
  let ctrl2 = "ESC - Back    Enter - Select"
  let c2w = @draw.measure_text(ctrl2, 14)
  @draw.draw_text(
    ctrl2,
    (w - c2w) / 2,
    h / 2 + 65,
    14,
    @raylib.Color::new(130, 140, 160, 180),
  )
  // Start prompt
  let start_text = "PRESS ENTER TO START"
  let start_w = @draw.measure_text(start_text, 24)
  let blink = if game.frame_count % 60 < 40 { 255 } else { 100 }
  @draw.draw_text(
    start_text,
    (w - start_w) / 2,
    h * 3 / 4,
    24,
    @raylib.Color::new(80, 220, 255, blink),
  )
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  draw_starfield(game)
  // Title
  let title = "SELECT TIER"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(title, (w - tw) / 2, 40, 36, @types.color_title)
  // Tiers
  let tiers : Array[@types.Tier] = [Launch, Slingshot, Navigation]
  let tier_y_start = 150
  let tier_h = 140
  for i in 0..<tiers.length() {
    let tier = tiers[i]
    let y = tier_y_start + i * tier_h
    let unlocked = @types.tier_unlocked(tier, game.scores)
    let name = @types.tier_name(tier)
    let color = if unlocked {
      @types.tier_color(tier)
    } else {
      @types.color_locked
    }
    // Box
    let box_x = w / 2 - 200
    let box_w = 400
    let box_h = 110
    @raylib.draw_rectangle(
      box_x,
      y,
      box_w,
      box_h,
      @raylib.Color::new(15, 15, 30, 200),
    )
    @raylib.draw_rectangle_lines(box_x, y, box_w, box_h, color)
    // Tier name
    let nw = @draw.measure_text(name, 28)
    @draw.draw_text(name, (w - nw) / 2, y + 10, 28, color)
    // Description
    let desc = match tier {
      Launch => "8 Levels - Single planet, learn the basics"
      Slingshot => "9 Levels - Two planets, gravity assists"
      Navigation => "8 Levels - Three+ planets, complex paths"
    }
    let dw = @draw.measure_text(desc, 14)
    @draw.draw_text(
      desc,
      (w - dw) / 2,
      y + 45,
      14,
      @raylib.Color::new(180, 180, 200, 200),
    )
    // Progress
    let start = @types.tier_start_index(tier)
    let count = @types.tier_level_count(tier)
    let mut completed = 0
    let mut total_stars = 0
    for j in start..<(start + count) {
      if game.scores[j].completed {
        completed += 1
      }
      total_stars += game.scores[j].stars
    }
    let prog_str = completed.to_string() +
      "/" +
      count.to_string() +
      " completed  Stars: " +
      total_stars.to_string() +
      "/" +
      (count * 3).to_string()
    let pw = @draw.measure_text(prog_str, 14)
    @draw.draw_text(
      prog_str,
      (w - pw) / 2,
      y + 70,
      14,
      if unlocked {
        @raylib.Color::new(200, 200, 220, 200)
      } else {
        @types.color_locked
      },
    )
    // Lock indicator
    if !unlocked {
      let lock_str = "LOCKED"
      let lw = @draw.measure_text(lock_str, 18)
      @draw.draw_text(
        lock_str,
        (w - lw) / 2,
        y + box_h / 2 - 9,
        18,
        @raylib.Color::new(255, 80, 80, 200),
      )
    }
  }
  // Navigation hint
  let nav = "1/2/3 - Select Tier    ESC - Back"
  let nav_w = @draw.measure_text(nav, 14)
  @draw.draw_text(
    nav,
    (w - nav_w) / 2,
    h - 40,
    14,
    @raylib.Color::new(130, 140, 160, 180),
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  draw_starfield(game)
  let tier = game.current_tier
  let tier_name = @types.tier_name(tier)
  let tier_color = @types.tier_color(tier)
  // Title
  let title = tier_name + " - SELECT LEVEL"
  let tw = @draw.measure_text(title, 30)
  @draw.draw_text(title, (w - tw) / 2, 30, 30, tier_color)
  // Level grid
  let start = @types.tier_start_index(tier)
  let count = @types.tier_level_count(tier)
  let cols = 4
  let cell_w = 200
  let cell_h = 100
  let gap = 20
  let grid_w = cols * cell_w + (cols - 1) * gap
  let grid_x = (w - grid_w) / 2
  let grid_y = 90
  for i in 0..<count {
    let col = i % cols
    let row = i / cols
    let x = grid_x + col * (cell_w + gap)
    let y = grid_y + row * (cell_h + gap)
    let level_idx = start + i
    let level = @levels.get_level(level_idx)
    let score = game.scores[level_idx]
    // Cell background
    let bg_color = if score.completed {
      @raylib.Color::new(20, 30, 20, 200)
    } else {
      @raylib.Color::new(15, 15, 30, 200)
    }
    @raylib.draw_rectangle(x, y, cell_w, cell_h, bg_color)
    // Border
    let border_color = if score.completed {
      @types.color_station
    } else {
      @raylib.Color::new(60, 70, 90, 180)
    }
    @raylib.draw_rectangle_lines(x, y, cell_w, cell_h, border_color)
    // Level number
    let num_str = (i + 1).to_string()
    @draw.draw_text(num_str, x + 10, y + 8, 20, tier_color)
    // Level name
    @draw.draw_text(
      level.name,
      x + 10,
      y + 32,
      14,
      @raylib.Color::new(200, 210, 230, 220),
    )
    // Stars
    for s in 0..<3 {
      let star_x = x + 10 + s * 22
      let star_y = y + cell_h - 28
      let star_color = if s < score.stars {
        @types.color_star_gold
      } else {
        @types.color_star_empty
      }
      @draw.draw_text("*", star_x, star_y, 18, star_color)
    }
    // Best ticks
    if score.completed {
      let best = "Best: " + score.best_ticks.to_string()
      @draw.draw_text(
        best,
        x + cell_w - @draw.measure_text(best, 12) - 8,
        y + cell_h - 22,
        12,
        @raylib.Color::new(150, 160, 180, 180),
      )
    }
    // Planet count indicator
    let planet_str = level.planets.length().to_string() + "P"
    @draw.draw_text(
      planet_str,
      x + cell_w - @draw.measure_text(planet_str, 12) - 8,
      y + 10,
      12,
      @types.color_planet,
    )
  }
  // Navigation hint
  let nav = "1-" + count.to_string() + " - Select Level    ESC - Back"
  let nav_w = @draw.measure_text(nav, 14)
  @draw.draw_text(
    nav,
    (w - nav_w) / 2,
    h - 40,
    14,
    @raylib.Color::new(130, 140, 160, 180),
  )
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  draw_starfield(game)
  let level = @levels.get_level(game.current_level)
  let score = game.scores[game.current_level]
  // Title
  let title = "LEVEL COMPLETE!"
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(title, (w - tw) / 2, h / 6, 40, @types.color_station)
  // Level name
  let name_w = @draw.measure_text(level.name, 24)
  @draw.draw_text(
    level.name,
    (w - name_w) / 2,
    h / 6 + 55,
    24,
    @types.tier_color(level.tier),
  )
  // Stats box
  let box_x = w / 2 - 180
  let box_y = h / 3
  let box_w = 360
  let box_h = 200
  @raylib.draw_rectangle(
    box_x,
    box_y,
    box_w,
    box_h,
    @raylib.Color::new(10, 10, 25, 220),
  )
  @raylib.draw_rectangle_lines(box_x, box_y, box_w, box_h, @types.color_title)
  // Ticks used
  let ticks_str = "Ticks: " + game.tick_count.to_string()
  @draw.draw_text(ticks_str, box_x + 20, box_y + 20, 20, @types.color_hud)
  // Par
  let par_str = "Par: " + level.par_ticks.to_string()
  @draw.draw_text(
    par_str,
    box_x + 20,
    box_y + 50,
    18,
    @raylib.Color::new(160, 170, 190, 200),
  )
  // Under par?
  if game.tick_count <= level.par_ticks {
    let fast_str = "UNDER PAR!"
    @draw.draw_text(
      fast_str,
      box_x + 20 + @draw.measure_text(par_str, 18) + 20,
      box_y + 50,
      18,
      @types.color_star_gold,
    )
  }
  // Waypoints
  let mut wp_got = 0
  for i in 0..<level.waypoints.length() {
    if level.waypoints[i].collected {
      wp_got += 1
    }
  }
  let wp_str = "Waypoints: " +
    wp_got.to_string() +
    "/" +
    level.waypoints.length().to_string()
  @draw.draw_text(wp_str, box_x + 20, box_y + 80, 18, @types.color_waypoint)
  // Stars
  let star_str = "Stars Earned:"
  @draw.draw_text(star_str, box_x + 20, box_y + 120, 18, @types.color_hud)
  for s in 0..<3 {
    let sx = box_x + 20 + @draw.measure_text(star_str, 18) + 15 + s * 30
    let star_color = if s < score.stars {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    @draw.draw_text("*", sx, box_y + 118, 22, star_color)
  }
  // Best ticks
  let best_str = "Best: " + score.best_ticks.to_string() + " ticks"
  @draw.draw_text(
    best_str,
    box_x + 20,
    box_y + 155,
    16,
    @raylib.Color::new(150, 160, 180, 180),
  )
  // Navigation
  let nav1 = "ENTER - Next Level    R - Replay    ESC - Level Select"
  let n1w = @draw.measure_text(nav1, 14)
  @draw.draw_text(
    nav1,
    (w - n1w) / 2,
    h - 50,
    14,
    @raylib.Color::new(130, 140, 160, 180),
  )
}
