///|
/// Draw title screen
fn draw_title(game : @types.Game) -> Unit {
  // Background gradient
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height, @types.color_title_bg,
  )
  // Decorative hex pattern
  let size : Float = 60.0
  for i in 0..<8 {
    for j in 0..<5 {
      let x = Float::from_int(i) * 170.0 + 50.0
      let y = Float::from_int(j) * 160.0 + 30.0
      let offset : Float = if j % 2 == 1 { 85.0 } else { 0.0 }
      let alpha = 20 + (i + j) * 5
      draw_hex_outline(
        x + offset,
        y,
        size,
        @raylib.Color::new(120, 180, 100, @types.clampi(alpha, 0, 80)),
      )
    }
  }
  // Title
  let title = "Hex Harvest"
  let tw = @draw.measure_text(title, 64)
  let tx = (@types.screen_width - tw) / 2
  @draw.draw_text(title, tx, 180, 64, @types.color_title_text)
  // Subtitle
  let sub = "A Farming Puzzle"
  let sw = @draw.measure_text(sub, 24)
  @draw.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    260,
    24,
    @raylib.Color::new(200, 220, 180, 255),
  )
  // Menu items
  let items = ["Play", "Quit"]
  for i in 0..<items.length() {
    let y = 380 + i * 60
    let iw = @draw.measure_text(items[i], 32)
    let x = (@types.screen_width - iw) / 2
    let selected = game.menu_selection == i
    let color = if selected {
      @types.color_title_text
    } else {
      @raylib.Color::new(160, 180, 140, 200)
    }
    if selected {
      @raylib.draw_rectangle(
        x - 30,
        y - 5,
        iw + 60,
        44,
        @raylib.Color::new(80, 120, 70, 150),
      )
      @draw.draw_text(">", x - 25, y, 32, @types.color_title_text)
    }
    @draw.draw_text(items[i], x, y, 32, color)
  }
  // Instructions
  @draw.draw_text(
    "Up/Down to select, Enter to confirm",
    (
      @types.screen_width -
      @draw.measure_text("Up/Down to select, Enter to confirm", 16)
    ) /
    2,
    560,
    16,
    @raylib.Color::new(140, 160, 130, 180),
  )
}

///|
/// Draw world select screen
fn draw_world_select(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height, @types.color_bg,
  )
  // Title
  let title = "Select World"
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    40,
    40,
    @types.color_dark_text,
  )
  // World cards
  let worlds = ["Valley", "Hills", "Peaks"]
  let card_w = 300
  let card_h = 200
  let start_x = (@types.screen_width - 3 * card_w - 2 * 40) / 2
  for i in 0..<worlds.length() {
    let x = start_x + i * (card_w + 40)
    let y = 140
    let selected = game.menu_selection == i
    // Card background
    let bg = match i {
      0 => @raylib.Color::new(100, 160, 80, if selected { 240 } else { 160 })
      1 => @raylib.Color::new(140, 130, 90, if selected { 240 } else { 160 })
      _ => @raylib.Color::new(120, 110, 130, if selected { 240 } else { 160 })
    }
    @raylib.draw_rectangle(x, y, card_w, card_h, bg)
    if selected {
      @raylib.draw_rectangle_lines_ex(
        @raylib.Rectangle::new(
          Float::from_int(x),
          Float::from_int(y),
          Float::from_int(card_w),
          Float::from_int(card_h),
        ),
        3.0,
        @types.color_white,
      )
    }
    // World name
    let name_w = @draw.measure_text(worlds[i], 32)
    @draw.draw_text(
      worlds[i],
      x + (card_w - name_w) / 2,
      y + 20,
      32,
      @types.color_white,
    )
    // Stars count for this world
    let mut total_stars = 0
    for l in 0..<@types.levels_per_world {
      match game.level_scores[i][l] {
        Some(score) => total_stars += score.stars
        None => ()
      }
    }
    let stars_text = total_stars.to_string() +
      "/" +
      (@types.levels_per_world * 3).to_string() +
      " Stars"
    let stars_w = @draw.measure_text(stars_text, 18)
    @draw.draw_text(
      stars_text,
      x + (card_w - stars_w) / 2,
      y + 70,
      18,
      @types.color_star_gold,
    )
    // Description
    let desc = match i {
      0 => "Flat terrain, basic\nwater flow"
      1 => "Height variation,\nchannel puzzles"
      _ => "Complex terrain,\nall mechanics"
    }
    @draw.draw_text(
      desc,
      x + 20,
      y + 110,
      16,
      @raylib.Color::new(240, 230, 210, 200),
    )
    // Draw decorative hex
    let hex_cx = Float::from_int(x + card_w / 2)
    let hex_cy = Float::from_int(y + card_h - 25)
    draw_hex_outline(
      hex_cx,
      hex_cy,
      18.0,
      @raylib.Color::new(255, 255, 255, 80),
    )
  }
  // Back button
  @draw.draw_text(
    "Esc: Back | Left/Right: Select | Enter: Confirm",
    (
      @types.screen_width -
      @draw.measure_text("Esc: Back | Left/Right: Select | Enter: Confirm", 16)
    ) /
    2,
    400,
    16,
    @raylib.Color::new(120, 110, 90, 200),
  )
}

///|
/// Draw level select screen
fn draw_level_select(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height, @types.color_bg,
  )
  // Title
  let world = @types.world_name(game.world_index)
  let title = world + " - Select Level"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    30,
    36,
    @types.color_dark_text,
  )
  // Level grid (4x2)
  let cell_w = 200
  let cell_h = 120
  let gap = 20
  let grid_w = 4 * cell_w + 3 * gap
  let start_x = (@types.screen_width - grid_w) / 2
  let start_y = 100
  for i in 0..<@types.levels_per_world {
    let col = i % 4
    let row = i / 4
    let x = start_x + col * (cell_w + gap)
    let y = start_y + row * (cell_h + gap)
    let selected = game.menu_selection == i
    // Card background
    let bg = if selected {
      @raylib.Color::new(180, 170, 140, 240)
    } else {
      @raylib.Color::new(160, 150, 130, 180)
    }
    @raylib.draw_rectangle(x, y, cell_w, cell_h, bg)
    if selected {
      @raylib.draw_rectangle_lines(x, y, cell_w, cell_h, @types.color_white)
    }
    // Level number
    let num = (i + 1).to_string()
    @draw.draw_text(num, x + 10, y + 8, 24, @types.color_dark_text)
    // Stars
    let score_opt = game.level_scores[game.world_index][i]
    match score_opt {
      Some(score) => {
        for s in 0..<3 {
          let sx = x + 10 + s * 30
          let sy = y + 40
          let star_color = if s < score.stars {
            @types.color_star_gold
          } else {
            @types.color_star_empty
          }
          draw_star(
            Float::from_int(sx + 10),
            Float::from_int(sy + 10),
            10.0,
            star_color,
          )
        }
        // Score text
        let score_text = score.yield_collected.to_string() + " yield"
        @draw.draw_text(
          score_text,
          x + 10,
          y + cell_h - 28,
          14,
          @raylib.Color::new(100, 90, 70, 200),
        )
      }
      None =>
        // Show empty stars
        for s in 0..<3 {
          let sx = x + 10 + s * 30
          let sy = y + 40
          draw_star(
            Float::from_int(sx + 10),
            Float::from_int(sy + 10),
            10.0,
            @types.color_star_empty,
          )
        }
    }
  }
  // Navigation help
  @draw.draw_text(
    "Arrow keys: Navigate | Enter: Play | Esc: Back",
    (
      @types.screen_width -
      @draw.measure_text("Arrow keys: Navigate | Enter: Play | Esc: Back", 16)
    ) /
    2,
    380,
    16,
    @raylib.Color::new(120, 110, 90, 200),
  )
}

///|
/// Draw results screen
fn draw_results(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height, @types.color_bg,
  )
  // Overlay
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 80),
  )
  // Results panel
  let panel_w = 500
  let panel_h = 400
  let panel_x = (@types.screen_width - panel_w) / 2
  let panel_y = (@types.screen_height - panel_h) / 2
  @raylib.draw_rectangle(
    panel_x, panel_y, panel_w, panel_h, @types.color_panel_bg,
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(180, 170, 140, 255),
  )
  // Title
  let completed = game.yield_collected >= game.level.target_yield
  let title = if completed { "Level Complete!" } else { "Out of Turns!" }
  let title_color = if completed {
    @types.color_star_gold
  } else {
    @raylib.Color::new(200, 80, 80, 255)
  }
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(
    title,
    panel_x + (panel_w - tw) / 2,
    panel_y + 20,
    36,
    title_color,
  )
  // Stats
  let stat_x = panel_x + 40
  let mut stat_y = panel_y + 80
  @draw.draw_text(
    "Yield: " +
    game.yield_collected.to_string() +
    " / " +
    game.level.target_yield.to_string(),
    stat_x,
    stat_y,
    22,
    @types.color_hud_text,
  )
  stat_y += 35
  @draw.draw_text(
    "Turns: " +
    game.turn.to_string() +
    " / " +
    game.level.turn_budget.to_string(),
    stat_x,
    stat_y,
    22,
    @types.color_hud_text,
  )
  stat_y += 35
  if game.level.goals.length() > 0 {
    @draw.draw_text(
      "Goals: " +
      game.goals_collected.to_string() +
      " / " +
      game.level.goals.length().to_string(),
      stat_x,
      stat_y,
      22,
      @types.color_hud_text,
    )
    stat_y += 35
  }
  // Stars
  if completed {
    stat_y += 20
    let star_size : Float = 25.0
    let star_x_start = panel_x + (panel_w - 3 * 70) / 2
    for s in 0..<3 {
      let sx = Float::from_int(star_x_start + s * 70 + 25)
      let sy = Float::from_int(stat_y)
      let color = if s < game.score.stars {
        @types.color_star_gold
      } else {
        @types.color_star_empty
      }
      draw_star(sx, sy, star_size, color)
    }
    stat_y += 60
    // Star explanations
    let star1 = "* Reach target yield"
    let star2 = "** Finish within " +
      game.level.par_turns.to_string() +
      " turns"
    let star3 = "*** Collect all bonus goals"
    @draw.draw_text(
      star1,
      stat_x,
      stat_y,
      14,
      @raylib.Color::new(200, 190, 170, 200),
    )
    @draw.draw_text(
      star2,
      stat_x,
      stat_y + 18,
      14,
      @raylib.Color::new(200, 190, 170, 200),
    )
    @draw.draw_text(
      star3,
      stat_x,
      stat_y + 36,
      14,
      @raylib.Color::new(200, 190, 170, 200),
    )
  }
  // Navigation
  let nav_text = "Enter: Continue | R: Retry"
  let nw = @draw.measure_text(nav_text, 18)
  @draw.draw_text(
    nav_text,
    panel_x + (panel_w - nw) / 2,
    panel_y + panel_h - 40,
    18,
    @raylib.Color::new(180, 170, 150, 220),
  )
}
