///|
fn draw_ui_panel(game : @types.Game, level : @types.Level) -> Unit {
  let px = @types.ui_panel_x
  let py = 80
  let pw = 580
  let ph = 630
  // Panel background
  @raylib.draw_rectangle(px, py, pw, ph, @types.color_hud_bg)
  @raylib.draw_rectangle_lines(px, py, pw, ph, @types.color_grid_line)
  // Level name
  @draw.draw_text(level.name, px + 15, py + 10, 24, @types.color_hud_text)
  // Tier info
  let tier_str = @types.tier_name(level.tier)
  @draw.draw_text(
    "Tier: " + tier_str,
    px + 15,
    py + 40,
    18,
    @types.color_grid_line,
  )
  // Play state indicator
  let state_str = match game.play_state {
    Placing => "MODE: PLACING SENSORS"
    Guessing => "MODE: GUESSING EPICENTER"
    Complete => "LEVEL COMPLETE!"
    Failed => "EPICENTER MISSED"
  }
  let state_color = match game.play_state {
    Placing => @types.color_sensor_broad
    Guessing => @types.color_guess
    Complete => @raylib.Color::new(50, 255, 50, 255)
    Failed => @types.color_epicenter
  }
  @draw.draw_text(state_str, px + 15, py + 68, 20, state_color)
  // Budget
  let budget_remaining = level.sensor_budget - game.budget_used
  let budget_str = "Budget: " +
    budget_remaining.to_string() +
    " / " +
    level.sensor_budget.to_string()
  let budget_color = if budget_remaining > 0 {
    @types.color_hud_text
  } else {
    @types.color_epicenter
  }
  @draw.draw_text(budget_str, px + 15, py + 100, 20, budget_color)
  // Sensors placed
  @draw.draw_text(
    "Sensors placed: " + game.sensor_place_count.to_string(),
    px + 15,
    py + 128,
    18,
    @types.color_hud_text,
  )
  // Par info
  @draw.draw_text(
    "Par budget: " + level.par_budget.to_string(),
    px + 300,
    py + 100,
    18,
    @types.color_grid_line,
  )
  @draw.draw_text(
    "Par guesses: " + level.par_guesses.to_string(),
    px + 300,
    py + 128,
    18,
    @types.color_grid_line,
  )
  // Epicenter count
  let mut found_count = 0
  for i in 0..<level.epicenters.length() {
    if level.epicenters[i].found {
      found_count += 1
    }
  }
  @draw.draw_text(
    "Epicenters: " +
    found_count.to_string() +
    " / " +
    level.epicenters.length().to_string(),
    px + 15,
    py + 156,
    20,
    @types.color_title_accent,
  )
  // Sensor selection palette
  draw_sensor_palette(game, px + 15, py + 195)
  // Direction indicator for directional
  if game.selected_sensor == Directional {
    let dir_str = match game.selected_direction {
      North => "Direction: NORTH (^)"
      East => "Direction: EAST (>)"
      South => "Direction: SOUTH (v)"
      West => "Direction: WEST (<)"
    }
    @draw.draw_text(dir_str, px + 15, py + 340, 18, @types.color_sensor_dir)
    @draw.draw_text(
      "Arrow keys to change direction",
      px + 15,
      py + 365,
      16,
      @types.color_grid_line,
    )
  }
  // Controls help
  let ctrl_y = py + 400
  @draw.draw_text("--- Controls ---", px + 15, ctrl_y, 18, @types.color_hud_text)
  @draw.draw_text(
    "Click grid: place sensor / guess",
    px + 15,
    ctrl_y + 28,
    16,
    @types.color_grid_line,
  )
  @draw.draw_text(
    "Tab: toggle place/guess mode",
    px + 15,
    ctrl_y + 50,
    16,
    @types.color_grid_line,
  )
  @draw.draw_text(
    "1/2/3: select sensor type",
    px + 15,
    ctrl_y + 72,
    16,
    @types.color_grid_line,
  )
  @draw.draw_text(
    "Z: undo last sensor",
    px + 15,
    ctrl_y + 94,
    16,
    @types.color_grid_line,
  )
  @draw.draw_text(
    "O: toggle overlap display",
    px + 15,
    ctrl_y + 116,
    16,
    @types.color_grid_line,
  )
  @draw.draw_text(
    "R: restart level",
    px + 15,
    ctrl_y + 138,
    16,
    @types.color_grid_line,
  )
  @draw.draw_text(
    "Esc: back to level select",
    px + 15,
    ctrl_y + 160,
    16,
    @types.color_grid_line,
  )
  // Guesses count
  if game.guess_count > 0 {
    @draw.draw_text(
      "Guesses made: " + game.guess_count.to_string(),
      px + 15,
      ctrl_y + 192,
      18,
      @types.color_guess,
    )
  }
}

///|
fn draw_sensor_palette(
  game : @types.Game,
  x : Int,
  y : Int
) -> Unit {
  let sensors : Array[@types.SensorKind] = [Broad, Precise, Directional]
  let names : Array[String] = ["1: Broad", "2: Precise", "3: Directional"]
  let costs : Array[String] = ["Cost: 1", "Cost: 2", "Cost: 3"]
  let descs : Array[String] = [
    "Range 8, +/-2 ring", "Range 5, +/-1 ring", "Range 6, 90deg wedge",
  ]
  for i in 0..<sensors.length() {
    let sx = x + i * 180
    let kind = sensors[i]
    let color = @types.sensor_color(kind)
    let is_selected = game.selected_sensor == kind
    // Selection background
    if is_selected {
      @raylib.draw_rectangle(sx - 4, y - 4, 170, 130, @raylib.Color::new(
          40, 50, 80, 200,
        ))
      @raylib.draw_rectangle_lines(sx - 4, y - 4, 170, 130, @types.color_selected)
    }
    // Sensor icon
    let icon_x = Float::from_int(sx + 20)
    let icon_y = Float::from_int(y + 20)
    match kind {
      Broad =>
        @raylib.draw_circle(icon_x.to_int(), icon_y.to_int(), 10.0, color)
      Precise => {
        @raylib.draw_triangle(
          @raylib.Vector2::new(icon_x, icon_y - 10.0),
          @raylib.Vector2::new(icon_x - 10.0, icon_y),
          @raylib.Vector2::new(icon_x + 10.0, icon_y),
          color,
        )
        @raylib.draw_triangle(
          @raylib.Vector2::new(icon_x - 10.0, icon_y),
          @raylib.Vector2::new(icon_x, icon_y + 10.0),
          @raylib.Vector2::new(icon_x + 10.0, icon_y),
          color,
        )
      }
      Directional =>
        @raylib.draw_triangle(
          @raylib.Vector2::new(icon_x, icon_y),
          @raylib.Vector2::new(icon_x + 14.0, icon_y - 10.0),
          @raylib.Vector2::new(icon_x + 14.0, icon_y + 10.0),
          color,
        )
    }
    // Name and info
    @draw.draw_text(names[i], sx + 40, y + 10, 18, color)
    @draw.draw_text(costs[i], sx + 8, y + 45, 16, @types.color_hud_text)
    @draw.draw_text(descs[i], sx + 8, y + 68, 14, @types.color_grid_line)
    // Budget check
    let tier = match game.level {
      Some(l) => l.tier
      None => Detection
    }
    let available = match kind {
      Broad => true
      Precise => tier != Detection
      Directional => tier != Detection
    }
    if !available {
      @draw.draw_text("LOCKED", sx + 8, y + 90, 16, @types.color_epicenter)
    }
  }
}

///|
fn draw_message(game : @types.Game) -> Unit {
  if game.message_timer > 0.0 && game.message.length() > 0 {
    let alpha = @types.minf(game.message_timer * 2.0, 1.0)
    let a = (alpha * 255.0).to_int()
    let color = @raylib.Color::new(255, 255, 255, a)
    let text_w = @draw.measure_text(game.message, 28)
    let cx = @types.grid_offset_x +
      @types.grid_cols * @types.cell_size / 2 -
      text_w / 2
    @draw.draw_text(game.message, cx, 50, 28, color)
  }
}
