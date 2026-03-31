///|
pub fn draw_game_ui(game : @types.Game, level : @types.Level) -> Unit {
  // Top bar
  @raylib.draw_rectangle(0, 0, @types.screen_width, 45, @types.color_panel_bg)
  @raylib.draw_line(0, 45, @types.screen_width, 45, @types.color_grid_line)
  // Level name
  let level_text = "Level " +
    (game.current_level + 1).to_string() +
    ": " +
    level.name
  @draw.draw_text(level_text, 10, 4, 20, @types.color_title)
  // Tier info
  let tier_text = @types.tier_name(game.current_tier)
  let tier_col = @types.tier_color(game.current_tier)
  @draw.draw_text(tier_text, 10, 26, 14, tier_col)
  // Move counter with par comparison
  let filled = @voxel.count_filled(game.grid)
  let move_text = "Moves: " + game.moves.to_string()
  let move_col = if game.moves <= level.par_moves {
    @types.color_matched
  } else {
    @types.color_text
  }
  @draw.draw_text(move_text, 500, 4, 18, move_col)
  let par_text = "/ " + level.par_moves.to_string() + " par"
  @draw.draw_text(par_text, 620, 6, 14, @raylib.Color::new(130, 140, 160, 255))
  // Voxel count
  let voxel_text = "Voxels: " + filled.to_string()
  let voxel_color = if level.voxel_budget > 0 && filled > level.voxel_budget {
    @types.color_unmatched
  } else if filled <= level.par_voxels {
    @types.color_matched
  } else {
    @types.color_text
  }
  @draw.draw_text(voxel_text, 500, 24, 16, voxel_color)
  // Budget bar or par info
  if level.voxel_budget > 0 {
    draw_voxel_budget_bar(620, 27, filled, level.voxel_budget)
  } else {
    let vpar = "/ " + level.par_voxels.to_string() + " par"
    @draw.draw_text(vpar, 620, 26, 14, @raylib.Color::new(130, 140, 160, 255))
  }
  // Connectivity indicator
  if level.requires_connected {
    let conn_filled = @voxel.count_filled(game.grid)
    let connected = conn_filled <= 1 || @voxel.check_connected(game.grid)
    let conn_icon = if connected { "[OK]" } else { "[!!]" }
    let conn_text = conn_icon + " Connected"
    let conn_color = if connected {
      @types.color_matched
    } else {
      @types.color_unmatched
    }
    @draw.draw_text(conn_text, 850, 14, 16, conn_color)
  }
  // Undo count
  let undo_text = "Undo: " + game.undo_stack.length().to_string()
  @draw.draw_text(
    undo_text,
    1050,
    4,
    14,
    @raylib.Color::new(130, 140, 160, 255),
  )
  // Silhouette match summary
  let top_match = @voxel.silhouettes_match(
    @voxel.compute_silhouette(game.grid, Top),
    level.targets.top,
  )
  let front_match = @voxel.silhouettes_match(
    @voxel.compute_silhouette(game.grid, Front),
    level.targets.front,
  )
  let side_match = @voxel.silhouettes_match(
    @voxel.compute_silhouette(game.grid, Side),
    level.targets.side,
  )
  let match_count = (if top_match { 1 } else { 0 }) +
    (if front_match { 1 } else { 0 }) +
    (if side_match { 1 } else { 0 })
  let match_text = "Views: " + match_count.to_string() + "/3"
  let match_col = if match_count == 3 {
    @types.color_complete
  } else if match_count > 0 {
    @types.color_star_gold
  } else {
    @types.color_text
  }
  @draw.draw_text(match_text, 1050, 24, 14, match_col)
  // Bottom bar with controls
  @raylib.draw_rectangle(
    0,
    @types.screen_height - 30,
    @types.screen_width,
    30,
    @types.color_panel_bg,
  )
  @raylib.draw_line(
    0,
    @types.screen_height - 30,
    @types.screen_width,
    @types.screen_height - 30,
    @types.color_grid_line,
  )
  @draw.draw_text(
    "R: Reset",
    10,
    @types.screen_height - 24,
    14,
    @raylib.Color::new(120, 120, 150, 255),
  )
  @draw.draw_text(
    "U: Undo",
    120,
    @types.screen_height - 24,
    14,
    @raylib.Color::new(120, 120, 150, 255),
  )
  @draw.draw_text(
    "ESC: Back",
    230,
    @types.screen_height - 24,
    14,
    @raylib.Color::new(120, 120, 150, 255),
  )
  @draw.draw_text(
    "Click view panels to toggle voxels",
    500,
    @types.screen_height - 24,
    14,
    @raylib.Color::new(100, 110, 140, 255),
  )
  // Completion status
  if game.play_state == Complete {
    draw_completion_banner(game)
  }
  // Message display
  if game.message_timer > 0.0 {
    let alpha = @types.minf(game.message_timer * 2.0, 1.0)
    let a = (alpha * 255.0).to_int()
    let msg_color = @raylib.Color::new(255, 255, 255, a)
    let tw = @draw.measure_text(game.message, 24)
    @draw.draw_text(
      game.message,
      (@types.screen_width - tw) / 2,
      @types.screen_height / 2 - 50,
      24,
      msg_color,
    )
  }
}

///|
fn draw_completion_banner(game : @types.Game) -> Unit {
  let _ = game
  // Semi-transparent overlay
  @raylib.draw_rectangle(
    0,
    @types.screen_height / 2 - 60,
    @types.screen_width,
    120,
    @raylib.Color::new(0, 0, 0, 180),
  )
  let text = "PUZZLE COMPLETE!"
  let tw = @draw.measure_text(text, 36)
  @draw.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 45,
    36,
    @types.color_complete,
  )
  let sub = "Press ENTER for results"
  let sw = @draw.measure_text(sub, 20)
  @draw.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    @types.screen_height / 2 + 10,
    20,
    @types.color_text,
  )
}

///|
pub fn draw_stars(x : Int, y : Int, count : Int, max_stars : Int, size : Int) -> Unit {
  for i in 0..<max_stars {
    let sx = x + i * (size + 4)
    let color = if i < count {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    draw_star_shape(sx, y, size, color)
  }
}

///|
fn draw_star_shape(x : Int, y : Int, size : Int, color : @raylib.Color) -> Unit {
  let cx = Float::from_int(x + size / 2)
  let cy = Float::from_int(y + size / 2)
  let outer = Float::from_int(size) / 2.0
  let inner = outer * 0.4
  // Draw a 5-pointed star
  let pi : Float = 3.14159265
  for i in 0..<5 {
    let angle1 : Float = Float::from_int(i) * pi * 2.0 / 5.0 - pi / 2.0
    let angle2 : Float = Float::from_int(i) * pi * 2.0 / 5.0 +
      pi / 5.0 -
      pi / 2.0
    let angle3 : Float = Float::from_int(i + 1) * pi * 2.0 / 5.0 - pi / 2.0
    let ox1 = cx +
      outer * Float::from_double(@math.cos(angle1.to_double()))
    let oy1 = cy +
      outer * Float::from_double(@math.sin(angle1.to_double()))
    let ix1 = cx +
      inner * Float::from_double(@math.cos(angle2.to_double()))
    let iy1 = cy +
      inner * Float::from_double(@math.sin(angle2.to_double()))
    let ox2 = cx +
      outer * Float::from_double(@math.cos(angle3.to_double()))
    let oy2 = cy +
      outer * Float::from_double(@math.sin(angle3.to_double()))
    let v0 = @raylib.Vector2::new(cx, cy)
    let v1 = @raylib.Vector2::new(ox1, oy1)
    let v2 = @raylib.Vector2::new(ix1, iy1)
    let v3 = @raylib.Vector2::new(ox2, oy2)
    @raylib.draw_triangle(v0, v2, v1, color)
    @raylib.draw_triangle(v0, v3, v2, color)
  }
}
