///|
fn draw_results(game : @types.Game) -> Unit {
  let level_idx = game.current_level - 1
  let level = @levels.get_level(level_idx)
  // Dark overlay
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(40, 30, 20, 240),
  )
  // Results panel
  let px = 240
  let py = 80
  let pw = 800
  let ph = 560
  @raylib.draw_rectangle(px, py, pw, ph, @types.color_bg)
  @raylib.draw_rectangle_lines(px, py, pw, ph, @types.color_loom_frame)
  @raylib.draw_rectangle(px, py, pw, 60, @types.color_loom_frame)
  // Title
  @draw.draw_text(
    "Level " + game.current_level.to_string() + " Complete!",
    px + 20,
    py + 12,
    36,
    @raylib.white,
  )
  // Score details
  let dy = py + 80
  let score = game.level_scores[level_idx]
  // Stars display
  @draw.draw_text("Rating:", px + 40, dy, 24, @types.color_text)
  draw_stars_large(px + 160, dy - 4, score.stars, 3)
  // Stats
  @draw.draw_text(
    "Heddle Changes: " + game.heddle_changes.to_string(),
    px + 40,
    dy + 50,
    22,
    @types.color_text,
  )
  @draw.draw_text(
    "Par: " + level.par_changes.to_string(),
    px + 40,
    dy + 80,
    22,
    @types.color_text_light,
  )
  // Star breakdown
  let sy = dy + 130
  @draw.draw_text("Star Requirements:", px + 40, sy, 20, @types.color_title)
  let s1_color = if score.stars >= 1 {
    @types.color_correct
  } else {
    @types.color_text_light
  }
  @draw.draw_text(
    "* Match the pattern",
    px + 60,
    sy + 30,
    18,
    s1_color,
  )
  let s2_color = if score.stars >= 2 {
    @types.color_correct
  } else {
    @types.color_text_light
  }
  @draw.draw_text(
    "** At or under par heddle changes (" + level.par_changes.to_string() + ")",
    px + 60,
    sy + 55,
    18,
    s2_color,
  )
  let s3_color = if score.stars >= 3 {
    @types.color_correct
  } else {
    @types.color_text_light
  }
  @draw.draw_text(
    "*** Also identify the weave type",
    px + 60,
    sy + 80,
    18,
    s3_color,
  )
  // Weave type section
  let wy = sy + 130
  @draw.draw_text("Weave Type:", px + 40, wy, 22, @types.color_text)
  @draw.draw_text(
    "Actual: " + @types.weave_type_name(level.weave_type),
    px + 40,
    wy + 35,
    20,
    @types.color_title,
  )
  if game.has_guessed_type {
    let guess_color = if game.weave_type_guess == level.weave_type {
      @types.color_correct
    } else {
      @types.color_incorrect
    }
    @draw.draw_text(
      "Your guess: " + @types.weave_type_name(game.weave_type_guess),
      px + 40,
      wy + 65,
      20,
      guess_color,
    )
  } else {
    @draw.draw_text(
      "Press T to guess the weave type for 3rd star",
      px + 40,
      wy + 65,
      18,
      @types.color_text_light,
    )
  }
  // Completed pattern miniature
  draw_result_pattern(game, px + 500, py + 90, 16)
  // Navigation
  let ny = py + ph - 60
  @draw.draw_text("ENTER: Next Level", px + 40, ny, 20, @types.color_text)
  @draw.draw_text("R: Retry", px + 280, ny, 20, @types.color_text)
  @draw.draw_text("ESC: Level Select", px + 440, ny, 20, @types.color_text)
}

///|
fn draw_stars_large(x : Int, y : Int, filled : Int, total : Int) -> Unit {
  for i in 0..<total {
    let sx = x + i * 50
    let color = if i < filled {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    draw_star_shape(sx + 16, y + 16, 16, color)
  }
}

///|
fn draw_result_pattern(
  game : @types.Game,
  x : Int,
  y : Int,
  cs : Int,
) -> Unit {
  let target = game.target
  @draw.draw_text("Your Fabric:", x, y - 25, 14, @types.color_text_light)
  // Frame
  let fw = @types.grid_cols * cs
  let fh = @types.grid_rows * cs
  @raylib.draw_rectangle(x - 2, y - 2, fw + 4, fh + 4, @types.color_loom_frame)
  let player = @types.build_player_fabric(game)
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      let cx = x + col * cs
      let cy = y + row * cs
      let cell = @types.pattern_get(player, row, col)
      let color = @types.cell_color(cell.color_index)
      @raylib.draw_rectangle(cx, cy, cs - 1, cs - 1, color)
    }
  }
  // Target below
  let ty = y + fh + 20
  @draw.draw_text("Target:", x, ty - 15, 14, @types.color_text_light)
  @raylib.draw_rectangle(x - 2, ty - 2, fw + 4, fh + 4, @types.color_loom_frame)
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      let cx = x + col * cs
      let cy = ty + row * cs
      let cell = @types.pattern_get(target, row, col)
      let color = @types.cell_color(cell.color_index)
      @raylib.draw_rectangle(cx, cy, cs - 1, cs - 1, color)
    }
  }
}
