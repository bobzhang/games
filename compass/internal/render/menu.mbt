///|
fn draw_menu(game : @types.GameState, frame : Int) -> Unit {
  @raylib.clear_background(menu_bg)
  let cx = @types.screen_width / 2
  // Title with wave effect
  let wave = @math.sinf(Float::from_int(frame) * 0.05) * 3.0
  let ty = 80 + wave.to_int()
  @draw.draw_text("COMPASS", cx - 100, ty, 48, text_bright)
  @draw.draw_text(
    "Blind Navigation Puzzle",
    cx - 115,
    ty + 55,
    20,
    text_dim,
  )
  // Instructions
  let iy = 200
  @draw.draw_text("Navigate your ship through fog", cx - 145, iy, 18, text_dim)
  @draw.draw_text(
    "using only your compass bearing.",
    cx - 150,
    iy + 25,
    18,
    text_dim,
  )
  @draw.draw_text(
    "Find the lighthouse to complete each level.",
    cx - 195,
    iy + 55,
    18,
    text_dim,
  )
  // Buttons
  let by = 340
  draw_menu_button(cx - 100, by, 200, 45, "PLAY", frame)
  draw_menu_button(cx - 100, by + 60, 200, 45, "LEVEL SELECT", frame)
  // Star count
  let total_stars = compute_total_stars(game)
  let max_stars = @types.total_levels * 3
  let star_str = "Stars: \{total_stars}/\{max_stars}"
  @draw.draw_text(star_str, cx - 50, by + 130, 18, star_gold)
  // Hints
  @draw.draw_text(
    "ENTER to start  |  L for level select",
    cx - 165,
    @types.screen_height - 50,
    16,
    text_dim,
  )
}

///|
fn draw_menu_button(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  text : String,
  _frame : Int
) -> Unit {
  @raylib.draw_rectangle(x, y, w, h, button_color)
  @raylib.draw_rectangle_lines(x, y, w, h, panel_border)
  let tw = @draw.measure_text(text, 20)
  @draw.draw_text(text, x + (w - tw) / 2, y + (h - 20) / 2, 20, text_bright)
}

///|
fn draw_level_select(game : @types.GameState, frame : Int) -> Unit {
  @raylib.clear_background(menu_bg)
  let cx = @types.screen_width / 2
  @draw.draw_text("SELECT LEVEL", cx - 90, 30, 32, text_bright)
  // Draw tier sections
  let tier_starts = [0, 7, 14]
  let tier_counts = [7, 7, 6]
  let tier_names = ["Calm Seas (1-7)", "Rough Waters (8-14)", "Treacherous Depths (15-20)"]
  for tier_idx in 0..<3 {
    let ty = 90 + tier_idx * 210
    @draw.draw_text(tier_names[tier_idx], 40, ty, 18, text_dim)
    let start = tier_starts[tier_idx]
    let count = tier_counts[tier_idx]
    for i in 0..<count {
      let level = start + i
      let bx = 40 + i * 125
      let by = ty + 30
      draw_level_button(bx, by, level, game.stars[level], frame)
    }
  }
  @draw.draw_text(
    "ESC - Back to Menu",
    cx - 75,
    @types.screen_height - 40,
    16,
    text_dim,
  )
}

///|
fn draw_level_button(
  x : Int,
  y : Int,
  level : Int,
  star : @types.StarRating,
  _frame : Int
) -> Unit {
  let w = 110
  let h = 140
  let bg = if @types.star_rating_value(star) > 0 {
    @raylib.Color::new(30, 50, 80, 255)
  } else {
    button_color
  }
  @raylib.draw_rectangle(x, y, w, h, bg)
  @raylib.draw_rectangle_lines(x, y, w, h, panel_border)
  // Level number
  let num_str = "\{level + 1}"
  let tw = @draw.measure_text(num_str, 28)
  @draw.draw_text(num_str, x + (w - tw) / 2, y + 15, 28, text_bright)
  // Tier indicator
  let tier = if level < 7 {
    1
  } else if level < 14 {
    2
  } else {
    3
  }
  let tier_str = "Tier \{tier}"
  @draw.draw_text(tier_str, x + 30, y + 55, 14, text_dim)
  // Stars
  let count = @types.star_rating_value(star)
  for s in 0..<3 {
    let sx = x + 15 + s * 30
    let color = if s < count { star_gold } else { star_empty }
    @draw.draw_text("*", sx, y + 85, 24, color)
  }
  // Keyboard hint
  let key_str = if level < 9 {
    "\{level + 1}"
  } else {
    ""
  }
  if key_str.length() > 0 {
    @draw.draw_text(key_str, x + w / 2 - 4, y + h - 25, 14, text_dim)
  }
}

///|
fn compute_total_stars(game : @types.GameState) -> Int {
  let mut total = 0
  for star in game.stars {
    total += @types.star_rating_value(star)
  }
  total
}
