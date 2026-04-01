///|
fn draw_title(game : @types.Game) -> Unit {
  // Background
  @raylib.draw_rectangle(0, 0, @types.screen_width, @types.screen_height, @types.color_title_bg)
  // Decorative field rows
  for i in 0..<8 {
    let y = 200 + i * 60
    let shade = 40 + i * 8
    @raylib.draw_rectangle(
      0,
      y,
      @types.screen_width,
      50,
      @raylib.Color::new(shade, shade + 30, shade - 10, 60),
    )
  }
  // Title
  @draw.draw_text("HARVEST", 420, 80, 64, @types.color_title_text)
  @draw.draw_text(
    "Seasonal Crop Planning Puzzle",
    380,
    160,
    24,
    @types.color_hud_text,
  )
  // Menu items
  let items = ["Play", "Quit"]
  for i in 0..<items.length() {
    let y = 320 + i * 70
    let color = if i == game.menu_selection {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(490, y, 300, 55, color)
    @raylib.draw_rectangle_lines(490, y, 300, 55, @types.color_dark_text)
    let text_x = 580
    if i == game.menu_selection {
      @draw.draw_text("> " + items[i] + " <", text_x - 20, y + 14, 28, @types.color_white)
    } else {
      @draw.draw_text(items[i], text_x + 10, y + 14, 28, @types.color_white)
    }
  }
  // Instructions
  @draw.draw_text(
    "Arrow Keys to select, Enter to confirm",
    410,
    520,
    18,
    @types.color_hud_text,
  )
  // Crop icons at bottom
  let crops = @types.all_crops()
  for i in 0..<crops.length() {
    let x = 200 + i * 120
    let y = 600
    let cc = @types.crop_color(crops[i])
    @raylib.draw_rectangle(x, y, 40, 40, cc)
    @draw.draw_text(@types.crop_name(crops[i]), x - 5, y + 45, 12, @types.color_dark_text)
  }
}

///|
fn is_level_unlocked(game : @types.Game, index : Int) -> Bool {
  if index == 0 {
    return true
  }
  match game.level_scores[index - 1] {
    Some(_) => true
    None => false
  }
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  // Header
  @raylib.draw_rectangle(0, 0, @types.screen_width, 80, @types.color_hud_bg)
  @draw.draw_text("Select Level", 520, 25, 32, @types.color_title_text)
  // Level grid: 5 columns x 4 rows
  let cols = 5
  let btn_w = 200
  let btn_h = 100
  let gap_x = 20
  let gap_y = 15
  let start_x = (@types.screen_width - cols * btn_w - (cols - 1) * gap_x) / 2
  let start_y = 100
  for i in 0..<@types.total_levels {
    let col = i % cols
    let row = i / cols
    let x = start_x + col * (btn_w + gap_x)
    let y = start_y + row * (btn_h + gap_y) - game.scroll_offset
    if y + btn_h >= 80 && y <= @types.screen_height {
      draw_level_button(game, i, x, y, btn_w, btn_h)
    }
  }
  // Back instruction
  @draw.draw_text(
    "Arrows/Click to select, Enter to play, ESC to go back",
    370,
    @types.screen_height - 30,
    16,
    @types.color_dark_text,
  )
}

///|
fn draw_level_button(
  game : @types.Game,
  i : Int,
  x : Int,
  y : Int,
  btn_w : Int,
  btn_h : Int
) -> Unit {
  let is_hover = game.menu_selection == i
  let unlocked = is_level_unlocked(game, i)
  if unlocked {
    let bg = if is_hover {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(x, y, btn_w, btn_h, bg)
    @raylib.draw_rectangle_lines(x, y, btn_w, btn_h, @types.color_dark_text)
    let num_str = (i + 1).to_string()
    @draw.draw_text(num_str, x + 10, y + 8, 28, @types.color_white)
    @draw.draw_text(
      @levels.level_name(i),
      x + 10,
      y + 40,
      14,
      @types.color_hud_text,
    )
    @draw.draw_text(
      @levels.level_tier(i),
      x + 10,
      y + 60,
      12,
      @types.color_hud_text,
    )
    // Stars
    match game.level_scores[i] {
      Some(score) => {
        let stars = @types.tier_stars(score.tier)
        for s in 0..<3 {
          let sx = x + btn_w - 70 + s * 22
          let sy = y + 8
          let sc = if s < stars {
            @types.color_star_gold
          } else {
            @types.color_star_empty
          }
          draw_star(sx, sy, 8, sc)
        }
      }
      None => ()
    }
  } else {
    @raylib.draw_rectangle(x, y, btn_w, btn_h, @types.color_locked)
    @raylib.draw_rectangle_lines(x, y, btn_w, btn_h, @types.color_dark_text)
    @draw.draw_text("Locked", x + 70, y + 38, 18, @types.color_hud_text)
  }
}

///|
fn draw_results(game : @types.Game) -> Unit {
  // Overlay
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 160),
  )
  // Panel
  let pw = 500
  let ph = 400
  let px = (@types.screen_width - pw) / 2
  let py = (@types.screen_height - ph) / 2
  @raylib.draw_rectangle(px, py, pw, ph, @types.color_panel_bg)
  @raylib.draw_rectangle_lines(px, py, pw, ph, @types.color_hud_text)
  // Title
  @draw.draw_text("Year Complete!", px + 140, py + 20, 32, @types.color_title_text)
  // Level name
  @draw.draw_text(
    @levels.level_name(game.level_index),
    px + 30,
    py + 70,
    22,
    @types.color_hud_text,
  )
  // Value
  @draw.draw_text(
    "Total Harvest Value: " + game.total_value.to_string(),
    px + 30,
    py + 110,
    24,
    @types.color_wheat,
  )
  // Target
  let goal = @levels.load_level(game.level_index)
  @draw.draw_text(
    "Target: " + goal.target_value.to_string(),
    px + 30,
    py + 150,
    20,
    @types.color_hud_text,
  )
  // Tier
  let tier = @types.tier_from_value(
    game.total_value,
    goal.bronze_threshold,
    goal.silver_threshold,
    goal.gold_threshold,
  )
  let tier_str = match tier {
    Some(t) => @types.tier_name(t) + " medal!"
    None => "Not enough... try again."
  }
  @draw.draw_text(tier_str, px + 30, py + 190, 24, @types.color_star_gold)
  // Stars
  let stars = @types.tier_stars(tier)
  for i in 0..<3 {
    let sx = px + 180 + i * 50
    let sy = py + 240
    let sc = if i < stars {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    draw_star(sx, sy, 18, sc)
  }
  // Thresholds
  @draw.draw_text(
    "Bronze: " +
    goal.bronze_threshold.to_string() +
    "  Silver: " +
    goal.silver_threshold.to_string() +
    "  Gold: " +
    goal.gold_threshold.to_string(),
    px + 30,
    py + 300,
    16,
    @types.color_hud_text,
  )
  // Actions
  @draw.draw_text(
    "Enter: Next Level   R: Retry   ESC: Level Select",
    px + 40,
    py + 350,
    16,
    @types.color_hud_text,
  )
}

///|
fn draw_star(cx : Int, cy : Int, radius : Int, color : @raylib.Color) -> Unit {
  // Draw a simple star shape using triangles
  let r = Float::from_int(radius)
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy)
  // 5-pointed star
  for i in 0..<5 {
    let angle1 = Float::from_int(i) * @types.pi * 2.0 / 5.0 - @types.pi / 2.0
    let angle2 = angle1 + @types.pi * 2.0 / 10.0
    let angle3 = angle1 + @types.pi * 2.0 / 5.0
    let x1 = fcx + r * @types.cosf(angle1)
    let y1 = fcy + r * @types.sinf(angle1)
    let x2 = fcx + r * 0.4 * @types.cosf(angle2)
    let y2 = fcy + r * 0.4 * @types.sinf(angle2)
    let x3 = fcx + r * @types.cosf(angle3)
    let y3 = fcy + r * @types.sinf(angle3)
    @raylib.draw_triangle(
      @raylib.Vector2::new(fcx, fcy),
      @raylib.Vector2::new(x1, y1),
      @raylib.Vector2::new(x2, y2),
      color,
    )
    @raylib.draw_triangle(
      @raylib.Vector2::new(fcx, fcy),
      @raylib.Vector2::new(x2, y2),
      @raylib.Vector2::new(x3, y3),
      color,
    )
  }
}
