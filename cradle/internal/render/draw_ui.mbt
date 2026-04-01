///|
fn draw_playing_ui(game : @types.Game) -> Unit {
  let level = game.level_data[game.current_level]
  // Right panel background
  @raylib.draw_rectangle(
    800, 0, 480, @types.screen_height, @types.color_panel_bg,
  )
  @raylib.draw_line_ex(
    @raylib.Vector2::new(800.0, 0.0),
    @raylib.Vector2::new(800.0, 720.0),
    2.0,
    @types.color_frame,
  )
  // Level name and tier
  let tier_c = @types.tier_color(level.tier)
  @draw.draw_text(@types.tier_name(level.tier), 830, 30, 16, tier_c)
  @draw.draw_text(level.name, 830, 55, 28, @types.color_hud_text)
  let level_num = "Level " + (game.current_level + 1).to_string()
  @draw.draw_text(level_num, 830, 90, 16, @types.color_dim_text)
  // Strings counter
  draw_separator(125)
  @draw.draw_text("STRINGS", 830, 140, 18, @types.color_hud_text)
  let used = game.strings.length().to_string()
  let max_str = @types.max_strings.to_string()
  let par_str = level.par_strings.to_string()
  @draw.draw_text(
    used + " / " + max_str,
    830,
    165,
    24,
    if game.strings.length() <= level.par_strings {
      @types.color_target_hit
    } else {
      @types.color_string
    },
  )
  @draw.draw_text("Par: " + par_str, 1000, 170, 16, @types.color_dim_text)
  // Target progress
  draw_separator(205)
  @draw.draw_text("TARGETS", 830, 220, 18, @types.color_hud_text)
  let mut hit_count = 0
  for i in 0..<game.targets.length() {
    if game.targets[i].hit {
      hit_count = hit_count + 1
    }
  }
  let total_targets = game.targets.length().to_string()
  let hit_str = hit_count.to_string()
  @draw.draw_text(
    hit_str + " / " + total_targets,
    830,
    245,
    24,
    if hit_count == game.targets.length() {
      @types.color_target_hit
    } else {
      @types.color_target
    },
  )
  // Intersections info
  draw_separator(285)
  @draw.draw_text("INTERSECTIONS", 830, 300, 18, @types.color_hud_text)
  let ix_count = game.intersections.length().to_string()
  @draw.draw_text(ix_count, 830, 325, 24, @types.color_intersection)
  // Star preview
  draw_separator(365)
  @draw.draw_text("RATING", 830, 380, 18, @types.color_hud_text)
  let stars = @types.count_stars(
    game,
    game.current_level,
    game.strings.length(),
  )
  draw_star_display(830, 405, stars, 24)
  // Controls
  draw_separator(460)
  @draw.draw_text("CONTROLS", 830, 475, 18, @types.color_hud_text)
  @draw.draw_text(
    "Click peg to select/connect", 830, 500, 14, @types.color_dim_text,
  )
  @draw.draw_text(
    "Right-click: undo last string", 830, 520, 14, @types.color_dim_text,
  )
  @draw.draw_text("R: restart level", 830, 540, 14, @types.color_dim_text)
  @draw.draw_text("ESC: back to menu", 830, 560, 14, @types.color_dim_text)
  // Completion state
  if game.play_state == Complete {
    let msg = "LEVEL COMPLETE!"
    let tw = @draw.measure_text(msg, 32)
    @draw.draw_text(msg, 830 + (430 - tw) / 2, 620, 32, @types.color_target_hit)
    @draw.draw_text(
      "Press ENTER for results", 870, 660, 16, @types.color_dim_text,
    )
  }
}

///|
fn draw_separator(y : Int) -> Unit {
  @raylib.draw_line_ex(
    @raylib.Vector2::new(820.0, Float::from_int(y)),
    @raylib.Vector2::new(1260.0, Float::from_int(y)),
    1.0,
    @types.color_dim_text,
  )
}

///|
fn draw_star_display(x : Int, y : Int, stars : Int, size : Int) -> Unit {
  for i in 0..<3 {
    let sx = x + i * (size + 8)
    let color = if i < stars {
      @types.color_gold_star
    } else {
      @types.color_empty_star
    }
    @draw.draw_text("*", sx, y, size, color)
  }
}
