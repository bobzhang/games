///|
/// Draw the title screen.
pub fn draw_title(game : @types.Game) -> Unit {
  match tex_title.val {
    Some(title_art) => {
      draw_cover_art(title_art, @types.screen_width, @types.screen_height)
      @raylib.draw_rectangle(
        0,
        0,
        @types.screen_width,
        @types.screen_height,
        @raylib.Color::new(7, 16, 28, 112),
      )
    }
    None =>
      @raylib.draw_rectangle(
        0, 0, @types.screen_width, @types.screen_height, @types.color_bg,
      )
  }
  let title = "AQUEDUCT"
  let tw = @draw.measure_text(title, 60)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    150,
    60,
    @types.color_title_accent,
  )
  let subtitle = "Water Routing Puzzle"
  let sw = @draw.measure_text(subtitle, 24)
  @draw.draw_text(
    subtitle,
    (@types.screen_width - sw) / 2,
    230,
    24,
    @types.color_hud_text,
  )
  // Animated water drops
  let anim = game.anim_timer
  for i in 0..<5 {
    let fi = Float::from_int(i)
    let drop_x = 300 + i * 150
    let drop_offset : Float = sinf(anim * 2.0 + fi * 1.2) * 20.0
    let drop_y = 350 + drop_offset.to_int()
    match tex_spring.val {
      Some(spring_art) =>
        draw_art_fit(
          spring_art,
          Float::from_int(drop_x),
          Float::from_int(drop_y),
          44.0,
          44.0,
          anim * 8.0 + fi * 10.0,
          @raylib.Color::new(255, 255, 255, 210),
        )
      None => @raylib.draw_circle(drop_x, drop_y, 8.0, @types.color_water)
    }
  }
  let play_text = "Press ENTER to Play"
  let pw = @draw.measure_text(play_text, 28)
  let pv : Float = 180.0 + sinf(anim * 3.0) * 75.0
  let pulse_alpha = pv.to_int()
  let pa = if pulse_alpha > 255 {
    255
  } else if pulse_alpha < 80 {
    80
  } else {
    pulse_alpha
  }
  @draw.draw_text(
    play_text,
    (@types.screen_width - pw) / 2,
    450,
    28,
    @raylib.Color::new(200, 220, 255, pa),
  )
  // Instructions
  let desc_lines = [
    "Route water from springs to fountains", "through aqueducts. Water flows downhill!",
  ]
  for i, line in desc_lines {
    let lw = @draw.measure_text(line, 18)
    @draw.draw_text(
      line,
      (@types.screen_width - lw) / 2,
      520 + i * 26,
      18,
      @types.color_hud_dim,
    )
  }
}

///|
/// Draw the tier selection screen.
pub fn draw_tier_select(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height, @types.color_bg,
  )
  let title = "Select Tier"
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    80,
    40,
    @types.color_hud_text,
  )
  let tiers : Array[(@types.Tier, String, Int)] = [
    (Tier1, "Tier 1: Downhill", 1),
    (Tier2, "Tier 2: Reservoirs", 2),
    (Tier3, "Tier 3: Mastery", 3),
  ]
  for i, entry in tiers {
    let tier = entry.0
    let name = entry.1
    let num = entry.2
    let bx = 340
    let by = 180 + i * 120
    let bw = 600
    let bh = 90
    let selected = game.current_tier == tier
    let bg = if selected {
      @raylib.Color::new(50, 70, 110, 220)
    } else {
      @raylib.Color::new(35, 50, 75, 180)
    }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    @raylib.draw_rectangle_lines(bx, by, bw, bh, @types.tier_color(tier))
    @draw.draw_text(name, bx + 20, by + 15, 26, @types.tier_color(tier))
    // Count completed / total for this tier
    let tier_lvls = @types.tier_levels(game.levels, tier)
    let mut completed = 0
    let mut total_stars = 0
    for idx in tier_lvls {
      if game.scores[idx].completed {
        completed += 1
      }
      total_stars += game.scores[idx].stars
    }
    let status = "\{completed}/\{tier_lvls.length()} complete  Stars: \{total_stars}/\{tier_lvls.length() * 3}"
    @draw.draw_text(status, bx + 20, by + 50, 18, @types.color_hud_dim)
    // Key hint
    let key_text = "[\{num}]"
    @draw.draw_text(key_text, bx + bw - 60, by + 30, 24, @types.color_hud_dim)
  }
  @draw.draw_text(
    "Press 1/2/3 or ENTER to select  |  ESC to go back", 340, 560, 18, @types.color_hud_dim,
  )
}

///|
/// Draw the level selection screen.
pub fn draw_level_select(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height, @types.color_bg,
  )
  let tier_label = @types.tier_name(game.current_tier)
  @draw.draw_text(tier_label, 80, 40, 32, @types.tier_color(game.current_tier))
  @draw.draw_text("Select Level", 80, 80, 24, @types.color_hud_text)
  let tier_lvls = @types.tier_levels(game.levels, game.current_tier)
  for i, lvl_idx in tier_lvls {
    let level = game.levels[lvl_idx]
    let score = game.scores[lvl_idx]
    let row = i / 4
    let col = i % 4
    let bx = 80 + col * 290
    let by = 140 + row * 130
    let bw = 260
    let bh = 110
    let bg = @raylib.Color::new(35, 50, 75, 200)
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    let border_color = if score.completed {
      @types.color_fountain_filled
    } else {
      @types.color_grid_line
    }
    @raylib.draw_rectangle_lines(bx, by, bw, bh, border_color)
    // Level number and name
    let num_text = "\{i + 1}. \{level.name}"
    @draw.draw_text(num_text, bx + 12, by + 10, 20, @types.color_hud_text)
    // Par info
    let par_text = "Par: \{level.par_segments} segments"
    @draw.draw_text(par_text, bx + 12, by + 38, 16, @types.color_hud_dim)
    // Stars
    draw_stars(bx + 12, by + 62, score.stars, 3)
    // Springs/fountains count
    let info = "S:\{level.springs.length()} F:\{level.fountains.length()}"
    @draw.draw_text(info, bx + 140, by + 68, 16, @types.color_hud_dim)
  }
  @draw.draw_text(
    "Click a level or press 1-7  |  ESC to go back",
    80,
    @types.screen_height - 50,
    18,
    @types.color_hud_dim,
  )
}

///|
/// Draw the results screen.
pub fn draw_results(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height, @types.color_bg,
  )
  let level = game.levels[game.current_level]
  let score = game.scores[game.current_level]
  let title = if score.completed { "Level Complete!" } else { "Try Again..." }
  let title_color = if score.completed {
    @types.color_fountain_filled
  } else {
    @raylib.Color::new(255, 100, 80, 255)
  }
  let tw = @draw.measure_text(title, 48)
  @draw.draw_text(title, (@types.screen_width - tw) / 2, 120, 48, title_color)
  @draw.draw_text(
    level.name,
    (@types.screen_width - @draw.measure_text(level.name, 28)) / 2,
    190,
    28,
    @types.color_hud_text,
  )
  // Stats
  let segments = score.segments_used
  let filled = game.fountains_filled
  let total = game.total_fountains
  let stats = [
    "Fountains: \{filled} / \{total}",
    "Segments used: \{segments}",
    "Par: \{level.par_segments}",
  ]
  for i, text in stats {
    let stw = @draw.measure_text(text, 22)
    @draw.draw_text(
      text,
      (@types.screen_width - stw) / 2,
      260 + i * 35,
      22,
      @types.color_hud_text,
    )
  }
  // Stars
  let star_x = (@types.screen_width - 90) / 2
  draw_stars(star_x, 380, score.stars, 3)
  // Actions
  let actions = ["ENTER: Next level", "R: Retry", "ESC: Level select"]
  for i, text in actions {
    let atw = @draw.measure_text(text, 20)
    @draw.draw_text(
      text,
      (@types.screen_width - atw) / 2,
      460 + i * 32,
      20,
      @types.color_hud_dim,
    )
  }
}
