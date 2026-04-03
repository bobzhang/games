///|
pub fn draw_title(game : @types.Game) -> Unit {
  let phase = game.anim_timer
  @raylib.clear_background(bg_color)
  // Title
  let title = "LEYLINE"
  let tw = @draw.measure_text(title, 60)
  @draw.draw_text(title, (@types.screen_width - tw) / 2, 180, 60, source_color)
  // Subtitle
  let sub = "Magical Energy Network Puzzle"
  let sw = @draw.measure_text(sub, 24)
  @draw.draw_text(sub, (@types.screen_width - sw) / 2, 260, 24, text_color)
  // Decorative pulsing circle
  let pulse = @types.sinf(phase * 2.0) * 0.3 + 0.7
  let cx = Float::from_int(@types.screen_width / 2)
  @raylib.draw_circle_v(
    @raylib.Vector2::new(cx, 400.0),
    30.0 * pulse,
    @raylib.fade(source_color, 0.4),
  )
  @raylib.draw_ring(
    @raylib.Vector2::new(cx, 400.0),
    35.0,
    40.0,
    0.0,
    360.0,
    36,
    @raylib.fade(line_color, 0.3 * pulse),
  )
  // Blinking prompt
  let blink = @types.sinf(phase * 4.0) > 0.0
  if blink {
    let prompt = "Press ENTER or CLICK to start"
    let pw = @draw.measure_text(prompt, 20)
    @draw.draw_text(
      prompt,
      (@types.screen_width - pw) / 2,
      500,
      20,
      text_dim_color,
    )
  }
  @fps.draw()
}

///|
pub fn draw_level_select(game : @types.Game) -> Unit {
  @raylib.clear_background(bg_color)
  @draw.draw_text("Select Level", 50, 30, 36, text_color)
  @draw.draw_text("[ESC] Back", 700, 40, 16, text_dim_color)
  let start_y = 80
  let row_height = 50
  for i in 0..<@types.total_levels {
    let visible_idx = i - game.scroll_offset
    if visible_idx < 0 || visible_idx > 11 {
      continue
    }
    let y = start_y + visible_idx * row_height
    let unlocked = @types.level_unlocked(game.progress, i)
    let tier = @types.tier_for_level(i)
    let prog = game.progress[i]
    let bg = if unlocked {
      @raylib.Color::new(35, 30, 55, 200)
    } else {
      @raylib.Color::new(20, 18, 35, 200)
    }
    @raylib.draw_rectangle(50, y, 800, row_height - 4, bg)
    // Hover highlight
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    if mx >= 50 && mx <= 850 && my >= y && my < y + row_height && unlocked {
      @raylib.draw_rectangle(
        50,
        y,
        800,
        row_height - 4,
        @raylib.Color::new(80, 255, 180, 20),
      )
    }
    // Tier label
    let tier_label = "T\{tier}"
    let tier_color = match tier {
      1 => @raylib.Color::new(100, 200, 100, 255)
      2 => @raylib.Color::new(200, 200, 100, 255)
      _ => @raylib.Color::new(255, 100, 100, 255)
    }
    @draw.draw_text(tier_label, 60, y + 8, 14, tier_color)
    // Level name
    let name = match @levels.get_level(i) {
      Some(def) => def.name
      None => "???"
    }
    let label = "\{i + 1}. \{name}"
    let label_color = if unlocked { text_color } else { locked_color }
    @draw.draw_text(label, 100, y + 6, 22, label_color)
    if !unlocked {
      @draw.draw_text("[LOCKED]", 100, y + 28, 12, locked_color)
    }
    // Stars
    if prog.completed {
      draw_star_rating(prog.stars, 650, y + 8)
      let energy_str = "Best: \{prog.best_energy.to_int()}"
      @draw.draw_text(energy_str, 750, y + 10, 14, energy_text_color)
    }
  }
  // Scroll hint
  if @types.total_levels > 12 {
    @draw.draw_text(
      "[UP/DOWN] Scroll",
      (@types.screen_width - 120) / 2,
      @types.screen_height - 30,
      14,
      text_dim_color,
    )
  }
  @fps.draw()
}

///|
fn draw_star_rating(rating : @types.StarRating, x : Int, y : Int) -> Unit {
  let (count, color) = match rating {
    None => (0, text_dim_color)
    Bronze => (1, bronze_color)
    Silver => (2, silver_color)
    Gold => (3, gold_color)
  }
  for i in 0..<3 {
    let c = if i < count { color } else { @raylib.Color::new(50, 45, 70, 255) }
    @draw.draw_text("*", x + i * 20, y, 24, c)
  }
}

///|
pub fn draw_playing(game : @types.Game) -> Unit {
  @raylib.clear_background(bg_color)
  guard game.level_state is Some(state) else { return }
  draw_grid_background()
  draw_connections(state, game.energy_phase)
  draw_cells(state, game.energy_phase)
  draw_energy_labels(state)
  draw_cursor(state, game.tool)
  draw_draw_line_preview(state)
  draw_toolbar(game)
  draw_hud(game, state)
  @fps.draw()
}

///|
pub fn draw_level_complete(game : @types.Game) -> Unit {
  @raylib.clear_background(bg_color)
  guard game.level_state is Some(state) else { return }
  // Draw game behind overlay
  draw_grid_background()
  draw_connections(state, game.energy_phase)
  draw_cells(state, game.energy_phase)
  draw_energy_labels(state)
  // Dark overlay
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 150),
  )
  let cx = @types.screen_width / 2
  // Victory text
  let title = "Level Complete!"
  let title_w = @draw.measure_text(title, 48)
  @draw.draw_text(title, cx - title_w / 2, 200, 48, temple_powered_color)
  // Stars
  let prog = game.progress[game.current_level]
  draw_star_rating(prog.stars, cx - 30, 280)
  let star_label = match prog.stars {
    None => ""
    Bronze => "Bronze"
    Silver => "Silver"
    Gold => "Gold!"
  }
  let slw = @draw.measure_text(star_label, 24)
  let star_c = match prog.stars {
    None => text_dim_color
    Bronze => bronze_color
    Silver => silver_color
    Gold => gold_color
  }
  @draw.draw_text(star_label, cx - slw / 2, 320, 24, star_c)
  // Stats
  let ws_text = "Waystones Used: \{state.waystones_placed}"
  let en_text = "Energy Delivered: \{state.total_energy_delivered.to_int()}"
  let wsw = @draw.measure_text(ws_text, 20)
  let enw = @draw.measure_text(en_text, 20)
  @draw.draw_text(ws_text, cx - wsw / 2, 380, 20, text_color)
  @draw.draw_text(en_text, cx - enw / 2, 410, 20, energy_text_color)
  // Prompt
  let prompt = if game.current_level + 1 < @types.total_levels {
    "[ENTER] Next Level   [ESC] Level Select"
  } else {
    "All Levels Complete!  [ESC] Level Select"
  }
  let pw = @draw.measure_text(prompt, 18)
  @draw.draw_text(prompt, cx - pw / 2, 480, 18, text_dim_color)
  @fps.draw()
}

///|
pub fn draw_level_failed(_game : @types.Game) -> Unit {
  @raylib.clear_background(bg_color)
  // Overlay
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 180),
  )
  let cx = @types.screen_width / 2
  let title = "Not Enough Energy!"
  let title_w = @draw.measure_text(title, 40)
  @draw.draw_text(
    title,
    cx - title_w / 2,
    280,
    40,
    @raylib.Color::new(255, 100, 80, 255),
  )
  let prompt = "[R] Retry   [ESC] Level Select"
  let pw = @draw.measure_text(prompt, 20)
  @draw.draw_text(prompt, cx - pw / 2, 400, 20, text_dim_color)
  @fps.draw()
}
