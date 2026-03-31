///|
fn draw_title(game : @types.Game) -> Unit {
  // Animated background waves
  let frame_f : Float = Float::from_int(game.frame_count)
  for i in 0..<8 {
    let fi : Float = Float::from_int(i)
    let y_base : Float = 200.0 + fi * 80.0
    let alpha : Int = 30 - i * 3
    let col = @raylib.Color::new(
      0,
      180,
      255,
      if alpha > 0 { alpha } else { 5 },
    )
    for x in 0..<128 {
      let xf : Float = Float::from_int(x) * 10.0
      let wave_y = y_base + @types.sinf(xf * 0.02 + frame_f * 0.03 + fi) * 30.0
      @raylib.draw_rectangle(xf.to_int(), wave_y.to_int(), 10, 3, col)
    }
  }
  // Title
  let title = "TIDAL"
  let tw = @draw.measure_text(title, 80)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    180,
    80,
    @types.color_title_accent,
  )
  // Subtitle
  let sub = "Wave Propagation Puzzles"
  let sw = @draw.measure_text(sub, 24)
  @draw.draw_text(sub, (@types.screen_width - sw) / 2, 270, 24, @types.color_ui_text)
  // Prompt
  let prompt = "Press ENTER to start"
  let pulse : Float = @types.absf(@types.sinf(frame_f * 0.05))
  let base_alpha : Float = 120.0
  let alpha_val : Int = (base_alpha + pulse * 135.0).to_int()
  let prompt_col = @raylib.Color::new(200, 220, 255, alpha_val)
  let pw = @draw.measure_text(prompt, 22)
  @draw.draw_text(prompt, (@types.screen_width - pw) / 2, 400, 22, prompt_col)
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let _ = game
  let title = "Select Tier"
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(title, (@types.screen_width - tw) / 2, 80, 40, @types.color_ui_highlight)
  let tier_names = ["1: Propagation", "2: Reflection", "3: Phase"]
  let tier_descs = [
    "Emitters + Walls", "Reflectors + Absorbers", "Phase Shifters + Interference",
  ]
  let tier_colors : Array[@raylib.Color] = [
    @types.color_emitter_p0,
    @types.color_reflector,
    @types.color_phase_shifter,
  ]
  for t in 0..<3 {
    let bx = 200 + t * 320
    let by = 280
    let bw = 260
    let bh = 180
    // Box
    @raylib.draw_rectangle(bx, by, bw, bh, @types.color_ui_panel)
    @raylib.draw_rectangle_lines(bx, by, bw, bh, tier_colors[t])
    // Tier name
    @draw.draw_text(tier_names[t], bx + 20, by + 20, 24, tier_colors[t])
    // Description
    @draw.draw_text(tier_descs[t], bx + 20, by + 60, 16, @types.color_ui_dim)
    // Level count hint
    @draw.draw_text("10 levels", bx + 20, by + 140, 16, @types.color_ui_text)
  }
  @draw.draw_text("ESC: back", 20, @types.screen_height - 40, 16, @types.color_ui_dim)
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let tier_label = "Tier " +
    (game.current_tier + 1).to_string() +
    ": " +
    @levels.tier_name(game.current_tier)
  let tlw = @draw.measure_text(tier_label, 36)
  @draw.draw_text(tier_label, (@types.screen_width - tlw) / 2, 60, 36, @types.color_ui_highlight)
  let tier_offset = game.current_tier * @types.levels_per_tier
  let levels = @levels.get_all_levels()
  for i in 0..<10 {
    let level_idx = tier_offset + i
    let level = levels[level_idx]
    let col = i % 5
    let row = i / 5
    let bx = 140 + col * 200
    let by = 220 + row * 200
    let bw = 160
    let bh = 160
    let score = game.scores[level_idx]
    // Box
    let box_col = if score.completed {
      @raylib.Color::new(20, 40, 30, 220)
    } else {
      @types.color_ui_panel
    }
    @raylib.draw_rectangle(bx, by, bw, bh, box_col)
    let border_col = if score.completed {
      @types.color_target_ok
    } else {
      @types.color_grid_line
    }
    @raylib.draw_rectangle_lines(bx, by, bw, bh, border_col)
    // Level number
    let num_str = (i + 1).to_string()
    @draw.draw_text(num_str, bx + 10, by + 10, 28, @types.color_ui_text)
    // Level name
    @draw.draw_text(level.name, bx + 10, by + 45, 16, @types.color_ui_dim)
    // Stars
    draw_stars(bx + 10, by + 75, score.stars)
    // Par info
    let par = "Par: " + level.par_objects.to_string() + " obj / " + level.par_ticks.to_string() + " ticks"
    @draw.draw_text(par, bx + 10, by + 110, 12, @types.color_ui_dim)
    if score.completed {
      let done = score.objects_used.to_string() +
        " obj, " +
        score.ticks_used.to_string() +
        " ticks"
      @draw.draw_text(done, bx + 10, by + 130, 12, @types.color_target_ok)
    }
  }
  @draw.draw_text("Click level or press 1-0  |  ESC: back", 20, @types.screen_height - 40, 16, @types.color_ui_dim)
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let level = @levels.get_level(game.current_level)
  let score = game.scores[game.current_level]
  // Title
  let title = "Results: " + level.name
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(title, (@types.screen_width - tw) / 2, 120, 36, @types.color_ui_highlight)
  // Stars
  draw_stars((@types.screen_width - 100) / 2, 200, score.stars)
  // Stats
  let stat_x = (@types.screen_width - 300) / 2
  @draw.draw_text(
    "Objects used: " + score.objects_used.to_string() +
    " (par: " + level.par_objects.to_string() + ")",
    stat_x,
    270,
    22,
    @types.color_ui_text,
  )
  @draw.draw_text(
    "Ticks used: " + score.ticks_used.to_string() +
    " (par: " + level.par_ticks.to_string() + ")",
    stat_x,
    305,
    22,
    @types.color_ui_text,
  )
  // Star explanations
  @draw.draw_text("1 star: Complete level", stat_x, 370, 16, @types.color_ui_dim)
  @draw.draw_text(
    "2 stars: Within par objects",
    stat_x,
    395,
    16,
    @types.color_ui_dim,
  )
  @draw.draw_text(
    "3 stars: Within par objects and ticks",
    stat_x,
    420,
    16,
    @types.color_ui_dim,
  )
  // Navigation
  @draw.draw_text(
    "ENTER/N: next level  R: retry  ESC: level select",
    stat_x,
    500,
    18,
    @types.color_ui_dim,
  )
}

///|
fn draw_stars(x : Int, y : Int, count : Int) -> Unit {
  for i in 0..<3 {
    let col = if i < count {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    let sx = x + i * 35
    // Simple star as circle with text
    @raylib.draw_circle(sx + 12, y + 12, 12.0, col)
    @draw.draw_text("*", sx + 6, y + 2, 22, @types.color_bg)
  }
}
