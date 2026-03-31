///|
pub fn draw_ui(game : @types.Game) -> Unit {
  let px = @types.palette_x
  let py = @types.palette_y
  let ih = @types.palette_item_h
  // Panel background
  @raylib.draw_rectangle(px - 10, py - 40, 260, 520, @types.color_hud_bg)
  // Level info
  let level = @levels.get_level(game.current_level)
  @draw.draw_text(level.name, px, py - 35, 22, @types.color_hud_text)
  let tier_text = @types.tier_name(level.tier)
  @draw.draw_text(
    tier_text,
    px + 180,
    py - 35,
    16,
    @types.tier_color(level.tier),
  )
  // Source palette
  @draw.draw_text("Sources:", px, py, 18, @types.color_hud_text)
  for i in 0..<game.available_sources.length() {
    let (kind, count) = game.available_sources[i]
    let iy = py + 28 + i * ih
    let selected = i == game.selected_source && game.play_state == Placing
    let bg_col = if selected {
      @raylib.Color::new(80, 80, 96, 200)
    } else {
      @raylib.Color::new(40, 40, 50, 150)
    }
    @raylib.draw_rectangle(px, iy, 240, ih - 4, bg_col)
    if selected {
      @raylib.draw_rectangle_lines(px, iy, 240, ih - 4, @types.color_selected)
    }
    // Source icon/color swatch
    let sc = @types.source_color(kind)
    @raylib.draw_rectangle(px + 4, iy + 4, 16, 16, sc)
    // Name and count
    let name = @types.source_name(kind)
    @draw.draw_text(name, px + 26, iy + 4, 18, sc)
    let count_text = "x" + count.to_string()
    @draw.draw_text(count_text, px + 100, iy + 4, 18, @types.color_hud_text)
    // Keybind hint
    let key_hint = (i + 1).to_string()
    @draw.draw_text(
      key_hint,
      px + 210,
      iy + 4,
      16,
      @raylib.Color::new(150, 150, 160, 200),
    )
    // Wind direction for wind sources
    if kind == Wind {
      let dir_text = wind_dir_text(game.wind_dir)
      @draw.draw_text(
        dir_text,
        px + 26,
        iy + 28,
        14,
        @raylib.Color::new(180, 200, 230, 200),
      )
      @draw.draw_text(
        "[Q/E]",
        px + 120,
        iy + 28,
        12,
        @raylib.Color::new(120, 120, 130, 200),
      )
    }
  }
  // Turn counter and play state
  let turn_y = py + 28 + game.available_sources.length() * ih + 20
  @draw.draw_text("Turn:", px, turn_y, 18, @types.color_hud_text)
  @draw.draw_text(
    game.turn_count.to_string(),
    px + 60,
    turn_y,
    18,
    @types.color_hud_text,
  )
  // Par info
  let dim_col = @raylib.Color::new(150, 150, 160, 200)
  @draw.draw_text("Par turns:", px, turn_y + 28, 14, dim_col)
  @draw.draw_text(level.par_turns.to_string(), px + 100, turn_y + 28, 14, dim_col)
  @draw.draw_text("Par sources:", px, turn_y + 48, 14, dim_col)
  @draw.draw_text(level.par_sources.to_string(), px + 110, turn_y + 48, 14, dim_col)
  // Target progress
  let (met, total) = @weather.count_targets_met(game.grid)
  let target_y = turn_y + 80
  @draw.draw_text("Targets:", px, target_y, 18, @types.color_hud_text)
  let progress = met.to_string() + "/" + total.to_string()
  let pcol = if met == total {
    @raylib.Color::new(0, 255, 0, 255)
  } else {
    @types.color_hud_text
  }
  @draw.draw_text(progress, px + 90, target_y, 18, pcol)
  // Play state indicator
  let state_y = target_y + 40
  let state_text = match game.play_state {
    Placing => "PLACING - Click to place"
    Simulating => "SIMULATING"
    Won => "LEVEL COMPLETE!"
    Failed => "NOT ALL TARGETS MET"
  }
  let state_col = match game.play_state {
    Placing => @types.color_hud_text
    Simulating => @types.color_sunny
    Won => @raylib.Color::new(0, 255, 0, 255)
    Failed => @raylib.Color::new(255, 100, 100, 255)
  }
  @draw.draw_text(state_text, px, state_y, 16, state_col)
  // Controls help
  let help_y = state_y + 40
  let help_col = @raylib.Color::new(120, 120, 130, 200)
  @draw.draw_text("Space: Simulate turn", px, help_y, 13, help_col)
  @draw.draw_text("Z: Undo last source", px, help_y + 18, 13, help_col)
  @draw.draw_text("R: Restart level", px, help_y + 36, 13, help_col)
  @draw.draw_text("Arrows/Click: Move cursor", px, help_y + 54, 13, help_col)
  @draw.draw_text("1-3: Select source", px, help_y + 72, 13, help_col)
  @draw.draw_text("ESC: Back to menu", px, help_y + 90, 13, help_col)
}

///|
fn wind_dir_text(d : @types.WindDir) -> String {
  match d {
    North => "Dir: North ^"
    East => "Dir: East >"
    South => "Dir: South v"
    West => "Dir: West <"
  }
}
