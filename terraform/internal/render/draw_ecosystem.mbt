///|
fn draw_ratio_bars(game : @types.Game) -> Unit {
  let grid = game.grid
  let targets = game.targets
  let bar_x = 950
  let bar_y = 100
  let bar_w = 280
  let bar_h = 28
  let spacing = 55
  // Title
  @draw.draw_text("Biome Ratios", bar_x, bar_y - 40, 22, @types.color_accent)
  // Divider
  @raylib.draw_line_ex(
    @raylib.Vector2::new(Float::from_int(bar_x), Float::from_int(bar_y - 20)),
    @raylib.Vector2::new(
      Float::from_int(bar_x + bar_w), Float::from_int(bar_y - 20),
    ),
    1.0,
    @types.color_text_dim,
  )
  // Forest bar
  draw_single_ratio_bar(
    bar_x, bar_y, bar_w, bar_h, "Forest",
    @types.biome_ratio(grid, Forest),
    targets.forest_min, targets.forest_max,
    @types.color_forest, game,
  )
  // Ocean bar
  draw_single_ratio_bar(
    bar_x, bar_y + spacing, bar_w, bar_h, "Ocean",
    @types.biome_ratio(grid, Ocean),
    targets.ocean_min, targets.ocean_max,
    @types.color_ocean, game,
  )
  // Desert bar
  draw_single_ratio_bar(
    bar_x, bar_y + spacing * 2, bar_w, bar_h, "Desert",
    @types.biome_ratio(grid, Desert),
    targets.desert_min, targets.desert_max,
    @types.color_desert, game,
  )
  // Barren info
  let barren_r = @types.biome_ratio(grid, Barren)
  let barren_pct = (barren_r * 100.0).to_int()
  @draw.draw_text(
    "Barren: " + barren_pct.to_string() + "%",
    bar_x, bar_y + spacing * 3, 18, @types.color_text_dim,
  )
  // Total tile count
  let total = grid.width * grid.height
  let forest_c = @types.count_biome(grid, Forest)
  let ocean_c = @types.count_biome(grid, Ocean)
  let desert_c = @types.count_biome(grid, Desert)
  let barren_c = @types.count_biome(grid, Barren)
  let counts_text = "F:" + forest_c.to_string() + " O:" + ocean_c.to_string() +
    " D:" + desert_c.to_string() + " B:" + barren_c.to_string() + " /" +
    total.to_string()
  @draw.draw_text(
    counts_text,
    bar_x, bar_y + spacing * 3 + 22, 14, @types.color_text_dim,
  )
}

///|
fn draw_single_ratio_bar(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  label : String,
  current : Float,
  target_min : Float,
  target_max : Float,
  color : @raylib.Color,
  game : @types.Game
) -> Unit {
  let time = Float::from_int(game.frame_count) * 0.03
  // Label
  @draw.draw_text(label, x, y - 18, 16, @types.color_text)
  // Background
  @raylib.draw_rectangle(x, y, w, h, @types.color_bar_bg)
  // Target range band
  let range_x = x + (Float::from_int(w) * target_min).to_int()
  let range_w = (Float::from_int(w) * (target_max - target_min)).to_int()
  @raylib.draw_rectangle(range_x, y, range_w, h, @types.color_tolerance)
  // Current value fill with slight gradient effect
  let fill_w = (Float::from_int(w) * @types.clampf(current, 0.0, 1.0)).to_int()
  @raylib.draw_rectangle(x, y, fill_w, h, color)
  // Shimmer effect on fill
  if fill_w > 4 {
    let shimmer_x = x + ((time * 60.0).to_int() % fill_w)
    if shimmer_x < x + fill_w - 2 {
      @raylib.draw_rectangle(
        shimmer_x, y, 3, h,
        @raylib.Color::new(255, 255, 255, 30),
      )
    }
  }
  // Target range boundary lines
  let min_x = x + (Float::from_int(w) * target_min).to_int()
  let max_x = x + (Float::from_int(w) * target_max).to_int()
  @raylib.draw_line_ex(
    @raylib.Vector2::new(Float::from_int(min_x), Float::from_int(y - 2)),
    @raylib.Vector2::new(Float::from_int(min_x), Float::from_int(y + h + 2)),
    2.0,
    @raylib.white,
  )
  @raylib.draw_line_ex(
    @raylib.Vector2::new(Float::from_int(max_x), Float::from_int(y - 2)),
    @raylib.Vector2::new(Float::from_int(max_x), Float::from_int(y + h + 2)),
    2.0,
    @raylib.white,
  )
  // Small triangles at target boundaries
  draw_tiny_triangle(min_x, y - 4, true)
  draw_tiny_triangle(max_x, y - 4, true)
  draw_tiny_triangle(min_x, y + h + 1, false)
  draw_tiny_triangle(max_x, y + h + 1, false)
  // Percentage text
  let pct = (current * 100.0).to_int()
  let in_range = current >= target_min && current <= target_max
  let pct_color = if in_range {
    @types.color_success
  } else {
    @types.color_fail
  }
  let pct_str = pct.to_string() + "%"
  @draw.draw_text(pct_str, x + w + 8, y + 4, 18, pct_color)
  // Status icon
  let icon = if in_range { "OK" } else { "--" }
  @draw.draw_text(icon, x + w + 50, y + 4, 18, pct_color)
  // Border
  @raylib.draw_rectangle_lines(x, y, w, h, @types.color_text_dim)
}

///|
fn draw_tiny_triangle(x : Int, y : Int, pointing_down : Bool) -> Unit {
  let fx = Float::from_int(x)
  let fy = Float::from_int(y)
  if pointing_down {
    @raylib.draw_triangle(
      @raylib.Vector2::new(fx - 3.0, fy),
      @raylib.Vector2::new(fx + 3.0, fy),
      @raylib.Vector2::new(fx, fy + 4.0),
      @raylib.white,
    )
  } else {
    @raylib.draw_triangle(
      @raylib.Vector2::new(fx, fy),
      @raylib.Vector2::new(fx + 3.0, fy + 4.0),
      @raylib.Vector2::new(fx - 3.0, fy + 4.0),
      @raylib.white,
    )
  }
}

///|
fn draw_resolve_overlay(game : @types.Game) -> Unit {
  if game.play_state == Resolving {
    let time = Float::from_int(game.frame_count) * 0.05
    // Pulsing overlay text
    let alpha_f = @types.sinf(time * 4.0) * 0.3 + 0.7
    let alpha = (alpha_f * 255.0).to_int()
    let text = "Ecosystem Resolving..."
    let tw = @draw.measure_text(text, 24)
    @draw.draw_text(
      text,
      (@types.screen_width - tw) / 2,
      @types.screen_height - 90,
      24,
      @raylib.Color::new(80, 200, 255, alpha),
    )
    // Step indicator
    let step_text = "Step " + game.resolve_step.to_string() + "/" +
      @types.resolve_steps.to_string()
    let stw = @draw.measure_text(step_text, 18)
    @draw.draw_text(
      step_text,
      (@types.screen_width - stw) / 2,
      @types.screen_height - 60,
      18,
      @types.color_text_dim,
    )
    // Progress dots
    let dot_cx = @types.screen_width / 2
    let dot_y = @types.screen_height - 40
    for s in 0..<@types.resolve_steps {
      let dx = dot_cx + (s - @types.resolve_steps / 2) * 20
      let c = if s < game.resolve_step {
        @types.color_accent
      } else {
        @types.color_text_dim
      }
      @raylib.draw_circle(dx, dot_y, 5.0, c)
    }
  }
}

///|
fn draw_ecosystem_forecast(game : @types.Game) -> Unit {
  if game.play_state != Painting {
    return
  }
  // Show a preview of what the ecosystem will do next
  let (gf, lf, gd, ld) = @biome.preview_next_step(game.grid)
  let px = 950
  let py = 280
  if gf > 0 || lf > 0 || gd > 0 || ld > 0 {
    @draw.draw_text("Next resolve:", px, py, 14, @types.color_text_dim)
    let mut offset_y = py + 18
    if gf > 0 {
      @draw.draw_text(
        "+" + gf.to_string() + " Forest",
        px + 10, offset_y, 12, @types.color_forest,
      )
      offset_y += 16
    }
    if lf > 0 {
      @draw.draw_text(
        "-" + lf.to_string() + " Forest",
        px + 10, offset_y, 12, @types.color_fail,
      )
      offset_y += 16
    }
    if gd > 0 {
      @draw.draw_text(
        "+" + gd.to_string() + " Desert",
        px + 10, offset_y, 12, @types.color_desert,
      )
      offset_y += 16
    }
    if ld > 0 {
      @draw.draw_text(
        "-" + ld.to_string() + " Desert",
        px + 10, offset_y, 12, @types.color_success,
      )
      offset_y += 16
    }
    ignore(offset_y)
  } else {
    @draw.draw_text("Ecosystem stable", px, py, 14, @types.color_text_dim)
  }
}

///|
fn draw_completion_sparkles(game : @types.Game) -> Unit {
  if game.play_state == Complete {
    let time = Float::from_int(game.frame_count) * 0.03
    let w = Float::from_int(@types.screen_width)
    let h = Float::from_int(@types.screen_height)
    for i in 0..<20 {
      let fi = Float::from_int(i)
      let sx = ((fi * 97.3 + time * 40.0) % w).to_int()
      let sy = ((fi * 53.7 + time * 25.0 * (fi % 3.0 + 1.0)) % h).to_int()
      let size : Float = 2.0 + @types.sinf(time * 3.0 + fi) * 1.5
      let alpha = ((@types.sinf(time * 2.0 + fi * 0.5) * 0.5 + 0.5) * 200.0).to_int()
      @raylib.draw_circle(
        sx, sy, size,
        @raylib.Color::new(255, 215, 0, alpha),
      )
    }
  }
}
