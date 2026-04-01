///|
fn draw_ui(game : @types.Game) -> Unit {
  match game.play_state {
    Editing => draw_edit_ui(game)
    Running | Stepping => draw_run_ui(game)
    Complete => draw_complete_ui(game)
    Failed => draw_failed_ui(game)
  }
}

///|
fn draw_edit_ui(game : @types.Game) -> Unit {
  // Top bar: level name
  match game.current_level {
    None => ()
    Some(level) => {
      @raylib.draw_rectangle(0, 0, @types.screen_width, 44, @types.color_ui_bg)
      let tier_c = @types.tier_color(level.tier)
      @draw.draw_text(
        @types.tier_name(level.tier) + " - " + level.name,
        10,
        10,
        24,
        tier_c,
      )
      // Par info
      let par_text = "Par: " +
        level.par_count.to_string() +
        " dominoes / " +
        level.par_ticks.to_string() +
        " ticks"
      @draw.draw_text(par_text, 600, 10, 18, @types.color_ui_text)
    }
  }
  // Right panel: domino palette
  let panel_x = @types.screen_width - 160
  @raylib.draw_rectangle(panel_x - 10, 50, 170, 400, @types.color_ui_bg)
  @draw.draw_text("DOMINOES", panel_x, 58, 18, @types.color_ui_highlight)
  let kinds : Array[@types.DominoKind] = [Normal, Heavy, Splitter, Delay]
  let keys = ["1", "2", "3", "4"]
  for i in 0..<kinds.length() {
    let kind = kinds[i]
    let by = 90 + i * 70
    let is_selected = game.selected_kind == kind
    // Background highlight for selected
    if is_selected {
      @raylib.draw_rectangle(
        panel_x - 5,
        by - 5,
        155,
        60,
        @raylib.Color::new(64, 96, 160, 96),
      )
    }
    // Color swatch
    let c = @types.kind_color(kind)
    @raylib.draw_rectangle(panel_x, by, 20, 20, c)
    // Name and key
    let label = "[" + keys[i] + "] " + @types.kind_name(kind)
    @draw.draw_text(label, panel_x + 28, by, 16, @types.color_ui_text)
    // Budget remaining
    match game.current_level {
      None => ()
      Some(level) => {
        let remaining = @types.budget_remaining(
          level.budget,
          game.dominoes,
          kind,
        )
        let budget_text = "x" + remaining.to_string()
        let bc = if remaining > 0 {
          @types.color_ui_text
        } else {
          @types.color_fail
        }
        @draw.draw_text(budget_text, panel_x + 28, by + 22, 16, bc)
      }
    }
  }
  // Orientation display
  let orient_y = 380
  @draw.draw_text("Orientation:", panel_x, orient_y, 16, @types.color_ui_text)
  @draw.draw_text(
    game.hover_orientation.to_string(),
    panel_x + 5,
    orient_y + 22,
    20,
    @types.color_ui_highlight,
  )
  @draw.draw_text(
    "[R]/[Q] rotate",
    panel_x,
    orient_y + 48,
    14,
    @types.color_grid_dot,
  )
  // Bottom bar: controls
  @raylib.draw_rectangle(
    0,
    @types.screen_height - 40,
    @types.screen_width,
    40,
    @types.color_ui_bg,
  )
  @draw.draw_text(
    "Space: Run   Tab: Step   Esc: Back   Click: Place   Right-click: Remove",
    10,
    @types.screen_height - 32,
    16,
    @types.color_grid_dot,
  )
}

///|
fn draw_run_ui(game : @types.Game) -> Unit {
  // Top bar
  @raylib.draw_rectangle(0, 0, @types.screen_width, 44, @types.color_ui_bg)
  match game.current_level {
    None => ()
    Some(level) =>
      @draw.draw_text(level.name, 10, 10, 24, @types.tier_color(level.tier))
  }
  // Tick counter
  let tick_text = "Tick: " +
    game.current_tick.to_string() +
    " / " +
    game.max_tick.to_string()
  @draw.draw_text(tick_text, 400, 10, 20, @types.color_ui_text)
  // Speed indicator
  let speed_text = "Speed: " + game.tick_speed.to_string() + "x"
  @draw.draw_text(speed_text, 650, 10, 20, @types.color_ui_highlight)
  // Target progress
  let total = @types.count_targets(game.dominoes)
  let fallen = @types.count_fallen_targets(game.dominoes)
  let progress_text = "Targets: " +
    fallen.to_string() +
    " / " +
    total.to_string()
  @draw.draw_text(progress_text, 850, 10, 20, @types.color_target_glow)
  // Chain progress bar
  if game.max_tick > 0 {
    let bar_x = 10
    let bar_y = @types.screen_height - 30
    let bar_w = @types.screen_width - 20
    let bar_h = 12
    @raylib.draw_rectangle(bar_x, bar_y, bar_w, bar_h, @types.color_ui_bg)
    let progress = Float::from_int(game.current_tick) /
      Float::from_int(game.max_tick)
    let fill_w = (Float::from_int(bar_w) * progress).to_int()
    @raylib.draw_rectangle(
      bar_x, bar_y, fill_w, bar_h, @types.color_ui_highlight,
    )
  }
  // Bottom controls
  let step_text = if game.play_state == Stepping {
    "Space/Tab: Next Tick   Esc: Reset"
  } else {
    "F1-F4: Speed   Esc: Reset"
  }
  @draw.draw_text(
    step_text,
    10,
    @types.screen_height - 50,
    16,
    @types.color_grid_dot,
  )
}

///|
fn draw_complete_ui(game : @types.Game) -> Unit {
  // Semi-transparent overlay
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 128),
  )
  // Success banner
  let banner_y = 180
  @raylib.draw_rectangle(
    200,
    banner_y,
    @types.screen_width - 400,
    360,
    @types.color_ui_bg,
  )
  @raylib.draw_rectangle_lines(
    200,
    banner_y,
    @types.screen_width - 400,
    360,
    @types.color_success,
  )
  @draw.draw_text(
    "CASCADE COMPLETE!",
    380,
    banner_y + 20,
    36,
    @types.color_success,
  )
  // Stars
  match game.current_level {
    None => ()
    Some(level) => {
      let placed = game.events.length()
      let stars_val = if level.id < game.scores.length() {
        game.scores[level.id].stars
      } else {
        0
      }
      draw_stars(stars_val, 540, banner_y + 80, 40)
      // Stats
      @draw.draw_text(
        "Ticks: " + game.max_tick.to_string(),
        350,
        banner_y + 140,
        22,
        @types.color_ui_text,
      )
      @draw.draw_text(
        "Events: " + placed.to_string(),
        350,
        banner_y + 170,
        22,
        @types.color_ui_text,
      )
      @draw.draw_text(
        "Par ticks: " + level.par_ticks.to_string(),
        600,
        banner_y + 140,
        22,
        @types.color_ui_text,
      )
      @draw.draw_text(
        "Par count: " + level.par_count.to_string(),
        600,
        banner_y + 170,
        22,
        @types.color_ui_text,
      )
    }
  }
  // Controls
  @draw.draw_text(
    "[R] Slow-mo replay   [Enter] Results   [Esc] Reset",
    310,
    banner_y + 220,
    18,
    @types.color_grid_dot,
  )
  // Replay indicator
  if game.replay_mode {
    @draw.draw_text(
      "SLOW-MO REPLAY - Tick " + game.replay_tick.to_string(),
      310,
      banner_y + 260,
      20,
      @types.color_ui_highlight,
    )
  }
}

///|
fn draw_failed_ui(game : @types.Game) -> Unit {
  // Semi-transparent overlay
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 128),
  )
  let banner_y = 250
  @raylib.draw_rectangle(
    300,
    banner_y,
    @types.screen_width - 600,
    200,
    @types.color_ui_bg,
  )
  @raylib.draw_rectangle_lines(
    300,
    banner_y,
    @types.screen_width - 600,
    200,
    @types.color_fail,
  )
  @draw.draw_text("CHAIN FAILED!", 460, banner_y + 30, 36, @types.color_fail)
  // Show targets remaining
  let total = @types.count_targets(game.dominoes)
  let fallen = @types.count_fallen_targets(game.dominoes)
  let remaining = total - fallen
  @draw.draw_text(
    remaining.to_string() + " target(s) still standing",
    430,
    banner_y + 90,
    22,
    @types.color_ui_text,
  )
  @draw.draw_text(
    "[Space] Try Again   [Esc] Reset",
    400,
    banner_y + 140,
    18,
    @types.color_grid_dot,
  )
}

///|
fn draw_stars(count : Int, x : Int, y : Int, size : Int) -> Unit {
  for i in 0..<3 {
    let star_x = x + i * (size + 10)
    let c = if i < count {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    let sz = Float::from_int(size) / 2.0
    @raylib.draw_circle(star_x + size / 2, y + size / 2, sz, c)
    @draw.draw_text(
      "*",
      star_x + size / 4,
      y,
      size,
      @raylib.Color::new(0, 0, 0, 192),
    )
  }
}
