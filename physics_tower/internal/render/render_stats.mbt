///|
/// Draws the statistics dashboard screen.
pub fn draw_stats_screen(game : @types.Game) -> Unit {
  @draw.draw_text(
    "STATISTICS",
    @types.screen_w / 2 - 100,
    40,
    40,
    @raylib.Color::new(240, 200, 60, 255),
  )
  let stats = game.statistics
  // Left column: general stats
  let lx = 120
  let mut ly = 120
  @draw.draw_text(
    "GENERAL",
    lx,
    ly,
    24,
    @raylib.Color::new(180, 200, 240, 255),
  )
  ly = ly + 40
  draw_stat_line(lx, ly, "Pieces Placed", stats.total_pieces_placed.to_string())
  ly = ly + 30
  draw_stat_line(lx, ly, "Tests Run", stats.total_tests_run.to_string())
  ly = ly + 30
  draw_stat_line(lx, ly, "Total Builds", stats.total_builds.to_string())
  ly = ly + 30
  draw_stat_line(lx, ly, "Total Breaks", stats.total_breaks.to_string())
  ly = ly + 30
  draw_stat_line(
    lx,
    ly,
    "Levels Completed",
    stats.levels_completed.to_string(),
  )
  ly = ly + 30
  draw_stat_line(lx, ly, "Stars Earned", stats.stars_earned.to_string())
  ly = ly + 30
  draw_stat_line(
    lx,
    ly,
    "Challenges Completed",
    stats.challenges_completed.to_string(),
  )
  ly = ly + 30
  let pct = @game.completion_percentage(game)
  draw_stat_line(lx, ly, "Completion", pct.to_string() + "%")
  // Draw completion progress bar
  ly = ly + 30
  draw_progress_bar(lx, ly, 300, 20, pct)
  // Right column: material usage bar chart
  let rx = 600
  let mut ry = 120
  @draw.draw_text(
    "MATERIAL USAGE",
    rx,
    ry,
    24,
    @raylib.Color::new(180, 200, 240, 255),
  )
  ry = ry + 40
  let (wood, stone, steel) = @game.material_usage(game)
  let max_mat = max3(wood, stone, steel)
  let bar_max_w = 400
  draw_material_bar(rx, ry, "Wood", wood, max_mat, bar_max_w, 160, 120, 60)
  ry = ry + 50
  draw_material_bar(rx, ry, "Stone", stone, max_mat, bar_max_w, 140, 140, 150)
  ry = ry + 50
  draw_material_bar(rx, ry, "Steel", steel, max_mat, bar_max_w, 100, 140, 200)
  // Star progress per world
  ry = ry + 60
  @draw.draw_text(
    "WORLD PROGRESS",
    rx,
    ry,
    24,
    @raylib.Color::new(180, 200, 240, 255),
  )
  ry = ry + 40
  let worlds = @content.get_worlds()
  for i in 0..<worlds.length() {
    let w = worlds[i]
    let earned = @game.world_stars(game, i)
    let max_s = @game.world_max_stars(i)
    let star_pct = if max_s > 0 { earned * 100 / max_s } else { 0 }
    let unlocked = @content.is_world_unlocked(i, stats.stars_earned)
    let name = w.name
    let status = if unlocked {
      name +
      ": " +
      earned.to_string() +
      "/" +
      max_s.to_string() +
      " stars"
    } else {
      name + ": LOCKED (need " + w.stars_required.to_string() + " stars)"
    }
    let color = if unlocked {
      @raylib.Color::new(200, 220, 240, 255)
    } else {
      @raylib.Color::new(120, 120, 140, 180)
    }
    @draw.draw_text(status, rx, ry, 18, color)
    ry = ry + 24
    if unlocked {
      draw_progress_bar(rx, ry, 300, 14, star_pct)
    }
    ry = ry + 28
  }
  // Best heights per level (bottom section)
  let bx = 120
  let mut by = 480
  @draw.draw_text(
    "BEST HEIGHTS",
    bx,
    by,
    24,
    @raylib.Color::new(180, 200, 240, 255),
  )
  by = by + 36
  let levels = @content.get_levels()
  let cols = 4
  for i in 0..<levels.length() {
    let col = i % cols
    let row = i / cols
    let cx = bx + col * 260
    let cy = by + row * 50
    let ht = (stats.best_heights[i] + 0.5).to_int()
    let star_count = stats.level_stars[i]
    let star_str = if star_count > 0 {
      " [" + star_count.to_string() + " star]"
    } else {
      ""
    }
    let color = if star_count >= 3 {
      @raylib.Color::new(255, 220, 60, 255)
    } else if star_count > 0 {
      @raylib.Color::new(180, 200, 220, 220)
    } else {
      @raylib.Color::new(120, 130, 150, 180)
    }
    let text = (i + 1).to_string() +
      ". " +
      ht.to_string() +
      "px" +
      star_str
    @draw.draw_text(text, cx, cy, 16, color)
  }
  // Footer
  @draw.draw_text(
    "[Esc] Back to Level Select",
    @types.screen_w / 2 - 160,
    @types.screen_h - 40,
    18,
    @raylib.Color::new(140, 150, 170, 160),
  )
}

///|
/// Draws a single statistic line with label and value.
fn draw_stat_line(x : Int, y : Int, label : String, value : String) -> Unit {
  @draw.draw_text(
    label + ": ",
    x,
    y,
    18,
    @raylib.Color::new(160, 170, 190, 220),
  )
  @draw.draw_text(
    value,
    x + 220,
    y,
    18,
    @raylib.Color::new(220, 230, 245, 255),
  )
}

///|
/// Draws a horizontal progress bar.
fn draw_progress_bar(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  percent : Int
) -> Unit {
  let pct = percent.clamp(min=0, max=100)
  // Background
  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(30, 36, 52, 200))
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(80, 100, 140, 180),
  )
  // Fill
  let fill_w = w * pct / 100
  if fill_w > 0 {
    let green = 100 + pct
    @raylib.draw_rectangle(
      x + 1,
      y + 1,
      fill_w - 2,
      h - 2,
      @raylib.Color::new(60, green.clamp(min=0, max=220), 80, 200),
    )
  }
}

///|
/// Draws a material usage bar with label.
fn draw_material_bar(
  x : Int,
  y : Int,
  name : String,
  count : Int,
  max_count : Int,
  max_w : Int,
  r : Int,
  g : Int,
  b : Int
) -> Unit {
  @draw.draw_text(
    name,
    x,
    y,
    18,
    @raylib.Color::new(200, 210, 230, 255),
  )
  let bar_x = x + 80
  let bar_y = y + 2
  let bar_h = 18
  // Background
  @raylib.draw_rectangle(
    bar_x,
    bar_y,
    max_w,
    bar_h,
    @raylib.Color::new(30, 36, 52, 200),
  )
  // Fill
  let fill_w = if max_count > 0 { count * max_w / max_count } else { 0 }
  if fill_w > 0 {
    @raylib.draw_rectangle(
      bar_x,
      bar_y,
      fill_w,
      bar_h,
      @raylib.Color::new(r, g, b, 200),
    )
  }
  // Count label
  @draw.draw_text(
    count.to_string(),
    bar_x + max_w + 10,
    y,
    18,
    @raylib.Color::new(180, 190, 210, 220),
  )
}

///|
/// Draws combo indicators on bodies that have active synergies.
pub fn draw_combo_indicators(game : @types.Game) -> Unit {
  for combo in game.active_combos {
    let (cr, cg, cb) = @game.combo_color(combo.kind)
    // Draw outline on body A
    let body_a = @physics.find_body(game.world, combo.body_a_id)
    match body_a {
      Some(a) =>
        if a.active && !(a.broken) {
          draw_combo_outline(a, cr, cg, cb)
        }
      None => ()
    }
    // Draw outline on body B
    let body_b = @physics.find_body(game.world, combo.body_b_id)
    match body_b {
      Some(b) =>
        if b.active && !(b.broken) {
          draw_combo_outline(b, cr, cg, cb)
        }
      None => ()
    }
  }
}

///|
/// Draws a colored outline around a body to indicate a combo.
fn draw_combo_outline(
  body : @types.Body,
  r : Int,
  g : Int,
  b : Int
) -> Unit {
  let cx = body.x.to_int()
  let cy = body.y.to_int()
  let hw = (body.width * 0.5).to_int() + 3
  let hh = (body.height * 0.5).to_int() + 3
  if @types.absf(body.angle) < 0.01 {
    @raylib.draw_rectangle_lines(
      cx - hw,
      cy - hh,
      hw * 2,
      hh * 2,
      @raylib.Color::new(r, g, b, 160),
    )
    // Second outline for glow effect
    @raylib.draw_rectangle_lines(
      cx - hw - 1,
      cy - hh - 1,
      hw * 2 + 2,
      hh * 2 + 2,
      @raylib.Color::new(r, g, b, 80),
    )
  } else {
    @raylib.draw_rectangle_pro(
      @raylib.Rectangle::new(
        body.x,
        body.y,
        body.width + 6.0,
        body.height + 6.0,
      ),
      @raylib.Vector2::new(
        (body.width + 6.0) * 0.5,
        (body.height + 6.0) * 0.5,
      ),
      body.angle * 57.2957795,
      @raylib.Color::new(r, g, b, 60),
    )
  }
}

///|
/// Draws the combo summary HUD showing active combos.
pub fn draw_combo_hud(game : @types.Game, y_offset : Int) -> Unit {
  if game.active_combos.length() == 0 {
    return
  }
  let (flex, mono, rein, light) = @game.count_combos(game.active_combos)
  let mut cy = y_offset
  if flex > 0 {
    @draw.draw_text(
      "Flex x" + flex.to_string(),
      20,
      cy,
      14,
      @raylib.Color::new(100, 255, 180, 200),
    )
    cy = cy + 18
  }
  if mono > 0 {
    @draw.draw_text(
      "Monolith x" + mono.to_string(),
      20,
      cy,
      14,
      @raylib.Color::new(200, 200, 255, 200),
    )
    cy = cy + 18
  }
  if rein > 0 {
    @draw.draw_text(
      "Reinforced x" + rein.to_string(),
      20,
      cy,
      14,
      @raylib.Color::new(100, 180, 255, 200),
    )
    cy = cy + 18
  }
  if light > 0 {
    @draw.draw_text(
      "Lightweight x" + light.to_string(),
      20,
      cy,
      14,
      @raylib.Color::new(255, 220, 100, 200),
    )
    ignore(cy)
  }
}

///|
/// Draws the tutorial overlay during build phase.
pub fn draw_tutorial_overlay(game : @types.Game) -> Unit {
  if !(@game.should_show_tutorial(game)) {
    return
  }
  let msg = @game.tutorial_message(game)
  if msg == "" {
    return
  }
  // Draw semi-transparent background at top
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    80,
    @raylib.Color::new(0, 0, 0, 160),
  )
  // Step indicator
  let step_num = @game.tutorial_step_number(game)
  let total = @game.tutorial_total()
  let step_text = "Step " +
    step_num.to_string() +
    "/" +
    total.to_string()
  @draw.draw_text(
    step_text,
    @types.screen_w / 2 - 40,
    10,
    18,
    @raylib.Color::new(240, 200, 60, 255),
  )
  // Tutorial message
  let tw = @draw.measure_text(msg, 22)
  @draw.draw_text(
    msg,
    (@types.screen_w - tw) / 2,
    42,
    22,
    @raylib.Color::new(255, 255, 255, 240),
  )
  // Draw highlight rectangle (blinking)
  if @game.tutorial_highlight_visible(game) {
    let (hx, hy, hw, hh) = @game.tutorial_highlight_rect(game)
    @raylib.draw_rectangle_lines(
      hx - 2,
      hy - 2,
      hw + 4,
      hh + 4,
      @raylib.Color::new(255, 220, 60, 200),
    )
    @raylib.draw_rectangle_lines(
      hx - 4,
      hy - 4,
      hw + 8,
      hh + 8,
      @raylib.Color::new(255, 220, 60, 100),
    )
  }
  // Draw arrow
  let (ax, ay, show_arrow) = @game.tutorial_arrow_pos(game)
  if show_arrow {
    // Simple arrow pointing right
    @raylib.draw_triangle(
      @raylib.Vector2::new(
        Float::from_int(ax),
        Float::from_int(ay - 8),
      ),
      @raylib.Vector2::new(
        Float::from_int(ax),
        Float::from_int(ay + 8),
      ),
      @raylib.Vector2::new(
        Float::from_int(ax + 16),
        Float::from_int(ay),
      ),
      @raylib.Color::new(255, 220, 60, 200),
    )
  }
}

///|
/// Draws the ghost tower overlay (transparent best solution).
pub fn draw_ghost_tower(game : @types.Game) -> Unit {
  if !(@game.ghost_visible(game)) {
    return
  }
  let pieces = @game.ghost_pieces(game)
  for piece in pieces {
    let (kind, _material, x, y, angle) = piece
    let (w, h) = @types.piece_dimensions(kind)
    let cx = x.to_int()
    let cy = y.to_int()
    let hw = (w * 0.5).to_int()
    let hh = (h * 0.5).to_int()
    if @types.absf(angle) < 0.01 {
      @raylib.draw_rectangle(
        cx - hw,
        cy - hh,
        hw * 2,
        hh * 2,
        @raylib.Color::new(100, 200, 255, 30),
      )
      @raylib.draw_rectangle_lines(
        cx - hw,
        cy - hh,
        hw * 2,
        hh * 2,
        @raylib.Color::new(100, 200, 255, 60),
      )
    } else {
      @raylib.draw_rectangle_pro(
        @raylib.Rectangle::new(x, y, w, h),
        @raylib.Vector2::new(w * 0.5, h * 0.5),
        angle * 57.2957795,
        @raylib.Color::new(100, 200, 255, 30),
      )
    }
  }
  // Label
  @draw.draw_text(
    "GHOST",
    @types.build_area_right.to_int() - 60,
    @types.build_area_top.to_int() + 10,
    14,
    @raylib.Color::new(100, 200, 255, 120),
  )
}

///|
/// Draws the replay playback screen.
pub fn draw_replay_screen(game : @types.Game) -> Unit {
  draw_world_internal(game)
  // Overlay
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    70,
    @raylib.Color::new(0, 0, 0, 180),
  )
  @draw.draw_text(
    "REPLAY PLAYBACK",
    @types.screen_w / 2 - 100,
    10,
    28,
    @raylib.Color::new(255, 200, 60, 255),
  )
  let progress = @game.playback_progress(game)
  @draw.draw_text(
    "Progress: " + progress.to_string() + "%",
    @types.screen_w / 2 - 60,
    42,
    18,
    @raylib.Color::new(200, 200, 220, 220),
  )
  // Speed indicator
  let speed_str = if game.replay.playback_speed > 1.5 {
    "FAST"
  } else if game.replay.playback_speed < 0.75 {
    "SLOW"
  } else {
    "NORMAL"
  }
  @draw.draw_text(
    "Speed: " + speed_str,
    20,
    10,
    18,
    @raylib.Color::new(180, 200, 220, 200),
  )
  // Progress bar
  let bar_x = @types.screen_w / 2 - 200
  let bar_y = @types.screen_h - 50
  let bar_w = 400
  let bar_h = 12
  @raylib.draw_rectangle(
    bar_x,
    bar_y,
    bar_w,
    bar_h,
    @raylib.Color::new(30, 36, 52, 200),
  )
  let fill = bar_w * progress / 100
  if fill > 0 {
    @raylib.draw_rectangle(
      bar_x,
      bar_y,
      fill,
      bar_h,
      @raylib.Color::new(100, 200, 255, 200),
    )
  }
  @raylib.draw_rectangle_lines(
    bar_x,
    bar_y,
    bar_w,
    bar_h,
    @raylib.Color::new(80, 100, 140, 180),
  )
  // Footer
  @draw.draw_text(
    "[Up/Down] Speed  [Esc] Stop",
    @types.screen_w / 2 - 160,
    @types.screen_h - 30,
    16,
    @raylib.Color::new(140, 150, 170, 160),
  )
}

///|
/// Helper to draw the world (used by replay screen).
fn draw_world_internal(game : @types.Game) -> Unit {
  let world = game.world
  // Draw ground
  @raylib.draw_rectangle(
    0,
    world.ground_y.to_int(),
    @types.screen_w,
    @types.screen_h - world.ground_y.to_int(),
    @raylib.Color::new(60, 70, 50, 255),
  )
  @raylib.draw_line(
    0,
    world.ground_y.to_int(),
    @types.screen_w,
    world.ground_y.to_int(),
    @raylib.Color::new(100, 130, 80, 255),
  )
  // Draw bodies
  for body in world.bodies {
    if !(body.active) {
      continue
    }
    let cx = body.x.to_int()
    let cy = body.y.to_int()
    let hw = (body.width * 0.5).to_int()
    let hh = (body.height * 0.5).to_int()
    let (r, g, b) = replay_body_color(body.material)
    let color = @raylib.Color::new(r, g, b, 220)
    if @types.absf(body.angle) < 0.01 {
      @raylib.draw_rectangle(cx - hw, cy - hh, hw * 2, hh * 2, color)
    } else {
      @raylib.draw_rectangle_pro(
        @raylib.Rectangle::new(body.x, body.y, body.width, body.height),
        @raylib.Vector2::new(body.width * 0.5, body.height * 0.5),
        body.angle * 57.2957795,
        color,
      )
    }
  }
}

///|
/// Returns color for a body during replay.
fn replay_body_color(mat : @types.Material) -> (Int, Int, Int) {
  match mat {
    Wood => (160, 120, 60)
    Stone => (140, 140, 150)
    Steel => (100, 140, 200)
  }
}

///|
fn max3(a : Int, b : Int, c : Int) -> Int {
  let m = if a > b { a } else { b }
  if m > c {
    m
  } else {
    c
  }
}
