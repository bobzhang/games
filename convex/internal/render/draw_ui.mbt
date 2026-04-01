///|
fn draw_playing_ui(game : @types.Game) -> Unit {
  let level = @geometry.hull_edge_count(game.current_hull)
  let _ = level
  // Left panel
  let px = 10
  let py = 70
  let pw = 220
  let ph = 360
  @raylib.draw_rectangle(px, py, pw, ph, @types.color_panel)
  @raylib.draw_rectangle_lines(px, py, pw, ph, @types.color_ui_dim)
  // Level name
  let lev = get_current_level_info(game)
  @draw.draw_text(lev.name, px + 10, py + 10, 18, @types.color_ui_text)
  // Tier
  let tier_c = @types.tier_color(lev.tier)
  @draw.draw_text(@types.tier_name(lev.tier), px + 10, py + 35, 14, tier_c)
  // Divider
  @raylib.draw_line(
    px + 10,
    py + 58,
    px + pw - 10,
    py + 58,
    @types.color_ui_dim,
  )
  // Points info
  let pts_text = "Points: " + game.placed_points.length().to_string()
  @draw.draw_text(pts_text, px + 10, py + 68, 16, @types.color_ui_text)
  let par_text = "Par: " + lev.par_points.to_string()
  @draw.draw_text(par_text, px + 10, py + 92, 16, @types.color_ui_dim)
  let min_text = "Min: " + lev.min_points.to_string()
  @draw.draw_text(min_text, px + 10, py + 116, 16, @types.color_ui_dim)
  // Hull info
  @raylib.draw_line(
    px + 10,
    py + 144,
    px + pw - 10,
    py + 144,
    @types.color_ui_dim,
  )
  let hull_text = "Hull vertices: " + game.current_hull.length().to_string()
  @draw.draw_text(hull_text, px + 10, py + 154, 16, @types.color_hull)
  let target_text = "Target edges: " + game.target.vertices.length().to_string()
  @draw.draw_text(target_text, px + 10, py + 178, 16, @types.color_target)
  // Match percentage
  @raylib.draw_line(
    px + 10,
    py + 206,
    px + pw - 10,
    py + 206,
    @types.color_ui_dim,
  )
  let match_text = "Match: " + format_pct(game.match_pct) + "%"
  let match_color = if game.hull_matches {
    @types.color_match
  } else if game.match_pct > 50.0 {
    @types.color_target
  } else {
    @types.color_nomatch
  }
  @draw.draw_text(match_text, px + 10, py + 216, 20, match_color)
  // Match bar
  let bar_x = px + 10
  let bar_y = py + 244
  let bar_w = pw - 20
  let bar_h = 12
  @raylib.draw_rectangle(bar_x, bar_y, bar_w, bar_h, @types.color_grid)
  let fill_w = (Float::from_int(bar_w) * game.match_pct / 100.0).to_int()
  if fill_w > 0 {
    @raylib.draw_rectangle(bar_x, bar_y, fill_w, bar_h, match_color)
  }
  // Stars preview
  if game.hull_matches {
    let pts_used = game.placed_points.length()
    let stars = if pts_used <= lev.min_points {
      3
    } else if pts_used <= lev.par_points {
      2
    } else {
      1
    }
    draw_stars(px + 10, py + 268, stars, 3)
  }
  // Controls
  @raylib.draw_line(
    px + 10,
    py + 298,
    px + pw - 10,
    py + 298,
    @types.color_ui_dim,
  )
  @draw.draw_text("Click: Place", px + 10, py + 306, 12, @types.color_ui_dim)
  @draw.draw_text(
    "Right-click: Remove",
    px + 10,
    py + 322,
    12,
    @types.color_ui_dim,
  )
  @draw.draw_text(
    "Z: Undo  R: Reset",
    px + 10,
    py + 338,
    12,
    @types.color_ui_dim,
  )
  // Top bar with level number
  @raylib.draw_rectangle(0, 0, @types.screen_width, 50, @types.color_panel)
  let level_label = "Level " +
    (game.level_index + 1).to_string() +
    " / " +
    @types.total_levels.to_string()
  @draw.draw_text(level_label, 20, 14, 22, @types.color_ui_text)
  // Status
  if game.play_state == Completed {
    let comp = "COMPLETE!"
    let cw = @draw.measure_text(comp, 24)
    @draw.draw_text(
      comp,
      @types.screen_width - cw - 20,
      14,
      24,
      @types.color_match,
    )
    let hint = "ENTER: Results"
    let hw = @draw.measure_text(hint, 16)
    @draw.draw_text(
      hint,
      @types.screen_width - hw - 20,
      690,
      16,
      @types.color_ui_dim,
    )
  }
  // Message
  if game.message.length() > 0 {
    let mw = @draw.measure_text(game.message, 28)
    let mx = (@types.screen_width - mw) / 2
    @draw.draw_text(
      game.message,
      mx,
      @types.screen_height - 60,
      28,
      @types.color_match,
    )
  }
}

///|
fn get_current_level_info(game : @types.Game) -> @types.Level {
  @geometry.hull_edge_count(game.current_hull) |> ignore
  // Return the level info from levels package
  let index = game.level_index
  // Reconstruct level info
  {
    target_polygon: game.target,
    pre_placed_points: [],
    par_points: get_level_par(index),
    min_points: get_level_min(index),
    tier: get_level_tier(index),
    name: get_level_name_str(index),
  }
}

///|
fn get_level_tier(index : Int) -> @types.Tier {
  if index < @types.tier1_count {
    Vertices
  } else if index < @types.tier1_count + @types.tier2_count {
    Edges
  } else {
    Sculpt
  }
}

///|
fn get_level_name_str(index : Int) -> String {
  // Names for each level
  let names : Array[String] = [
    "Right Triangle", "Tall Triangle", "Square", "Rectangle", "Pentagon", "Hexagon",
    "Diamond", "Octagon", "Centered Triangle", "Trapezoid", "Kite", "Arrow", "Wide Hexagon",
    "Parallelogram", "House", "Heptagon", "Flat Triangle", "Trim Square", "Prune Pentagon",
    "Clean Triangle", "Trim Hexagon", "Inner Rectangle", "Slim Diamond", "Spike Octagon",
    "Grand Decagon",
  ]
  if index >= 0 && index < names.length() {
    names[index]
  } else {
    "Level " + (index + 1).to_string()
  }
}

///|
fn get_level_par(index : Int) -> Int {
  let pars : Array[Int] = [
    4, 4, 5, 5, 6, 7, 5, 9, 4, 5, 5, 6, 7, 5, 6, 8, 4, 5, 6, 4, 7, 5, 5, 9, 11,
  ]
  if index >= 0 && index < pars.length() {
    pars[index]
  } else {
    5
  }
}

///|
fn get_level_min(index : Int) -> Int {
  let mins : Array[Int] = [
    3, 3, 4, 4, 5, 6, 4, 8, 3, 4, 4, 5, 6, 4, 5, 7, 3, 4, 5, 3, 6, 4, 4, 8, 10,
  ]
  if index >= 0 && index < mins.length() {
    mins[index]
  } else {
    3
  }
}

///|
fn draw_stars(x : Int, y : Int, filled : Int, total : Int) -> Unit {
  for i in 0..<total {
    let sx = x + i * 28
    let color = if i < filled {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    draw_star_shape(sx + 10, y + 10, 10.0, color)
  }
}

///|
fn draw_star_shape(
  cx : Int,
  cy : Int,
  radius : Float,
  color : @raylib.Color,
) -> Unit {
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy)
  let outer = radius
  let inner = radius * 0.4
  // Draw 5-pointed star as 10 triangles from center
  for i in 0..<10 {
    let angle1 = Float::from_int(i) * @types.pi / 5.0 - @types.pi / 2.0
    let angle2 = Float::from_int(i + 1) * @types.pi / 5.0 - @types.pi / 2.0
    let r1 = if i % 2 == 0 { outer } else { inner }
    let r2 = if (i + 1) % 2 == 0 { outer } else { inner }
    let x1 = fcx + r1 * @types.cosf(angle1)
    let y1 = fcy + r1 * @types.sinf(angle1)
    let x2 = fcx + r2 * @types.cosf(angle2)
    let y2 = fcy + r2 * @types.sinf(angle2)
    @raylib.draw_triangle(
      @raylib.Vector2::new(fcx, fcy),
      @raylib.Vector2::new(x1, y1),
      @raylib.Vector2::new(x2, y2),
      color,
    )
  }
}

///|
fn format_pct(v : Float) -> String {
  let whole = v.to_int()
  let frac = ((v - Float::from_int(whole)) * 10.0).to_int()
  whole.to_string() +
  "." +
  @types.absf(Float::from_int(frac)).to_int().to_string()
}
