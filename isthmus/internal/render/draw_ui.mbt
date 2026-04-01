///|
fn draw_ui(game : @types.Game) -> Unit {
  let panel_x = 680
  let panel_w = 580
  // Right panel background
  @raylib.draw_rectangle(
    panel_x,
    10,
    panel_w,
    700,
    @raylib.Color::new(20, 25, 40, 220),
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    10,
    panel_w,
    700,
    @raylib.Color::new(60, 80, 120, 200),
  )
  // Level name
  let level = @levels.get_level(game.selected_level)
  let name_str = "Level " +
    (game.selected_level + 1).to_string() +
    ": " +
    level.name
  @draw.draw_text(name_str, panel_x + 20, 25, 24, @types.color_ui_text)
  // Sea level meter
  draw_sea_level_meter(game, panel_x + 20, 65)
  // Sand budget
  draw_sand_budget(game, panel_x + 20, 200)
  // Turn counter
  let turn_str = "Turn: " + game.turn.to_string()
  @draw.draw_text(turn_str, panel_x + 20, 300, 22, @types.color_ui_text)
  // Play state
  let state_str = match game.play_state {
    Placing => "PLACING SAND (click grid)"
    Rising => "SEA RISING..."
    Won => "VICTORY!"
    Lost => "GAME OVER"
  }
  let state_color = match game.play_state {
    Placing => @raylib.Color::new(100, 255, 150, 255)
    Rising => @raylib.Color::new(100, 180, 255, 255)
    Won => @types.color_star_gold
    Lost => @raylib.Color::new(255, 80, 80, 255)
  }
  @draw.draw_text(state_str, panel_x + 20, 340, 22, state_color)
  // Connectivity status
  draw_connectivity_status(game, panel_x + 20, 390)
  // Controls
  draw_controls(panel_x + 20, 490)
  // Flood preview toggle
  let preview_str = if game.show_flood_preview {
    "[F] Flood preview: ON"
  } else {
    "[F] Flood preview: OFF"
  }
  @draw.draw_text(
    preview_str,
    panel_x + 20,
    660,
    16,
    @raylib.Color::new(150, 160, 180, 255),
  )
}

///|
fn draw_sea_level_meter(game : @types.Game, x : Int, y : Int) -> Unit {
  @draw.draw_text("Sea Level", x, y, 20, @types.color_ui_text)
  let bar_x = x
  let bar_y = y + 30
  let bar_w = 250
  let bar_h = 24
  let max_sl = game.max_sea_level
  // Background
  @raylib.draw_rectangle(
    bar_x,
    bar_y,
    bar_w,
    bar_h,
    @raylib.Color::new(30, 40, 60, 255),
  )
  // Fill
  let fill_pct = if max_sl > 0 {
    @types.clampf(
      Float::from_int(game.sea_level) / Float::from_int(max_sl),
      0.0,
      1.0,
    )
  } else {
    0.0
  }
  let fill_w = (Float::from_int(bar_w) * fill_pct).to_int()
  let fill_color = @types.lerp_color(
    @types.color_water_shallow, @types.color_water_deep, fill_pct,
  )
  @raylib.draw_rectangle(bar_x, bar_y, fill_w, bar_h, fill_color)
  @raylib.draw_rectangle_lines(
    bar_x,
    bar_y,
    bar_w,
    bar_h,
    @raylib.Color::new(80, 100, 140, 255),
  )
  // Text
  let sl_str = game.sea_level.to_string() + " / " + max_sl.to_string()
  @draw.draw_text(sl_str, bar_x + bar_w / 2 - 20, bar_y + 3, 18, @raylib.white)
  // Tick marks for each level
  for i in 1..<max_sl {
    let tx = bar_x +
      (Float::from_int(bar_w) * Float::from_int(i) / Float::from_int(max_sl)).to_int()
    @raylib.draw_line(
      tx,
      bar_y,
      tx,
      bar_y + bar_h,
      @raylib.Color::new(100, 120, 160, 150),
    )
  }
}

///|
fn draw_sand_budget(game : @types.Game, x : Int, y : Int) -> Unit {
  @draw.draw_text("Sand Budget", x, y, 20, @types.color_ui_text)
  let level = @levels.get_level(game.selected_level)
  let total = level.sand_budget
  let remaining = game.sand_remaining
  let bar_y = y + 30
  let bar_w = 250
  let bar_h = 24
  // Background
  @raylib.draw_rectangle(
    x,
    bar_y,
    bar_w,
    bar_h,
    @raylib.Color::new(30, 40, 60, 255),
  )
  // Fill
  let fill_pct = if total > 0 {
    @types.clampf(Float::from_int(remaining) / Float::from_int(total), 0.0, 1.0)
  } else {
    0.0
  }
  let fill_w = (Float::from_int(bar_w) * fill_pct).to_int()
  @raylib.draw_rectangle(x, bar_y, fill_w, bar_h, @types.color_sand)
  @raylib.draw_rectangle_lines(
    x,
    bar_y,
    bar_w,
    bar_h,
    @raylib.Color::new(80, 100, 140, 255),
  )
  // Text
  let sand_str = remaining.to_string() + " / " + total.to_string()
  @draw.draw_text(sand_str, x + bar_w / 2 - 20, bar_y + 3, 18, @types.color_bg)
  // Par indicator
  let par_str = "Par: " + level.par_sand.to_string() + " remaining"
  @draw.draw_text(
    par_str,
    x,
    bar_y + 30,
    16,
    @raylib.Color::new(150, 160, 180, 255),
  )
}

///|
fn draw_connectivity_status(game : @types.Game, x : Int, y : Int) -> Unit {
  let (connected, total) = @terrain.count_connected_settlements(
    game.grid,
    game.sea_level,
  )
  let all_connected = connected == total
  @draw.draw_text("Settlements", x, y, 20, @types.color_ui_text)
  let status_str = connected.to_string() +
    " / " +
    total.to_string() +
    " connected"
  let status_color = if all_connected {
    @types.color_connected
  } else {
    @types.color_disconnected
  }
  @draw.draw_text(status_str, x, y + 28, 20, status_color)
  // Never disconnected indicator (for 3-star tracking)
  if game.never_disconnected {
    @draw.draw_text(
      "Perfect chain maintained",
      x,
      y + 56,
      16,
      @types.color_star_gold,
    )
  } else {
    @draw.draw_text(
      "Chain was broken",
      x,
      y + 56,
      16,
      @raylib.Color::new(150, 100, 100, 255),
    )
  }
}

///|
fn draw_controls(x : Int, y : Int) -> Unit {
  let color = @raylib.Color::new(150, 160, 180, 255)
  @draw.draw_text("Controls:", x, y, 20, @types.color_ui_text)
  @draw.draw_text("Click  - Place sand", x, y + 28, 16, color)
  @draw.draw_text("Space  - End turn (raise sea)", x, y + 48, 16, color)
  @draw.draw_text("Z      - Undo last action", x, y + 68, 16, color)
  @draw.draw_text("R      - Restart level", x, y + 88, 16, color)
  @draw.draw_text("Escape - Back to menu", x, y + 108, 16, color)
  @draw.draw_text("F      - Toggle flood preview", x, y + 128, 16, color)
}
