///|
fn draw_ui_panel(game : @types.Game, level : @types.Level) -> Unit {
  // Right panel background
  @raylib.draw_rectangle(750, 0, 530, @types.screen_height, @types.color_panel)
  // Level name
  @draw.draw_text(level.name, 770, 20, 28, @types.color_highlight)
  @draw.draw_text(@types.tier_name(level.tier), 770, 52, 16, @types.color_text_dim)
  // Hint text
  @draw.draw_text(level.hint, 770, 78, 14, @types.color_text_dim)
  // Gear palette
  @draw.draw_text("GEARS", 770, 110, 18, @types.color_text)
  draw_gear_palette(game, level)
  // Budget display
  let used = @types.count_placed_gears(game.placed_gears)
  let budget_text = "Budget: " +
    used.to_string() +
    " / " +
    level.gear_budget.to_string()
  let budget_color = if used > level.gear_budget {
    @types.color_output_fail
  } else if used == level.gear_budget {
    @types.color_highlight
  } else {
    @types.color_text
  }
  @draw.draw_text(budget_text, 770, 320, 18, budget_color)
  let par_text = "Par: " + level.par_gears.to_string() + " gears"
  @draw.draw_text(par_text, 770, 345, 14, @types.color_text_dim)
  // Output status
  @draw.draw_text("OUTPUTS", 770, 385, 18, @types.color_text)
  draw_output_status(level)
  // Controls help
  draw_controls_help(game)
}

///|
fn draw_gear_palette(game : @types.Game, level : @types.Level) -> Unit {
  let mut slot_y = 140
  for i in 0..<level.available_gears.length() {
    let kind = level.available_gears[i]
    let is_selected = game.selected_gear_kind == kind
    let slot_x = 770
    let slot_w = 200
    let slot_h = 32
    if is_selected {
      @raylib.draw_rectangle(
        slot_x - 4,
        slot_y - 2,
        slot_w + 8,
        slot_h + 4,
        @types.color_highlight,
      )
    }
    let color = @types.gear_color(kind)
    @raylib.draw_rectangle(slot_x, slot_y, slot_w, slot_h, color)
    let name = gear_kind_name(kind)
    let size_label = match kind {
      Small => " (r=1, fast)"
      Medium => " (r=2, standard)"
      Large => " (r=3, slow)"
      Belt => " (connects distant)"
      Ratchet => " (one-way)"
    }
    @draw.draw_text(name + size_label, slot_x + 8, slot_y + 8, 14, @raylib.black)
    // Keybind hint
    let key_hint = (i + 1).to_string()
    @draw.draw_text(
      key_hint,
      slot_x + slot_w - 20,
      slot_y + 8,
      14,
      @raylib.black,
    )
    slot_y += 36
  }
}

///|
fn draw_output_status(level : @types.Level) -> Unit {
  let mut y = 410
  for i in 0..<level.outputs.length() {
    let output = level.outputs[i]
    let status_color = if output.satisfied {
      @types.color_output_ok
    } else {
      @types.color_output_fail
    }
    let dir_str : String = match output.target_dir {
      CW => "CW"
      CCW => "CCW"
    }
    let status_str = if output.satisfied { "DONE" } else { "NEED" }
    let text = "Output " +
      (i + 1).to_string() +
      ": " +
      output.target_rpm.to_int().to_string() +
      " RPM " +
      dir_str +
      " [" +
      status_str +
      "]"
    @draw.draw_text(text, 770, y, 16, status_color)
    y += 28
  }
}

///|
fn draw_controls_help(game : @types.Game) -> Unit {
  let y0 = 540
  @draw.draw_text("CONTROLS", 770, y0, 16, @types.color_text)
  @draw.draw_text(
    "Left-click: Place gear",
    770,
    y0 + 22,
    13,
    @types.color_text_dim,
  )
  @draw.draw_text(
    "Right-click: Remove gear",
    770,
    y0 + 38,
    13,
    @types.color_text_dim,
  )
  @draw.draw_text(
    "1-5: Select gear type",
    770,
    y0 + 54,
    13,
    @types.color_text_dim,
  )
  @draw.draw_text("R: Restart level", 770, y0 + 70, 13, @types.color_text_dim)
  @draw.draw_text("Esc: Back to menu", 770, y0 + 86, 13, @types.color_text_dim)
  if game.play_state == Solved {
    @draw.draw_text("Enter: See results", 770, y0 + 102, 13, @types.color_highlight)
  }
  // State indicator
  let state_text = match game.play_state {
    Placing => "PLACING"
    Simulating => "SIMULATING"
    Solved => "SOLVED!"
  }
  let state_color = match game.play_state {
    Placing => @types.color_text
    Simulating => @types.color_highlight
    Solved => @types.color_output_ok
  }
  @draw.draw_text(state_text, 770, @types.screen_height - 40, 22, state_color)
}

///|
fn gear_kind_name(kind : @types.GearKind) -> String {
  match kind {
    Small => "Small"
    Medium => "Medium"
    Large => "Large"
    Belt => "Belt"
    Ratchet => "Ratchet"
  }
}
