///|
fn draw_ui(game : @types.Game) -> Unit {
  // Right panel background
  @raylib.draw_rectangle(
    @types.palette_x - 10,
    @types.palette_y - 10,
    @types.palette_w + 20,
    @types.palette_h + 20,
    @types.color_ui_panel,
  )
  let level = @levels.get_level(game.current_level)
  // Level name
  @draw.draw_text(level.name, @types.palette_x + 10, @types.palette_y, 24, @types.color_ui_highlight)
  // Tier label
  let tier_label = "Tier " +
    (level.tier + 1).to_string() +
    ": " +
    @levels.tier_name(level.tier)
  @draw.draw_text(tier_label, @types.palette_x + 10, @types.palette_y + 30, 16, @types.color_ui_dim)
  // Play state
  let state_text = match game.play_state {
    Editing => "EDITING"
    Simulating => "SIMULATING"
    Stepping => "STEPPING"
    Complete => "COMPLETE"
    Failed => "FAILED"
  }
  @draw.draw_text(state_text, @types.palette_x + 10, @types.palette_y + 55, 18, @types.color_ui_text)
  // Object palette
  @draw.draw_text(
    "Objects:",
    @types.palette_x + 10,
    @types.palette_y + 90,
    18,
    @types.color_ui_text,
  )
  for i in 0..<level.budget.length() {
    let b = level.budget[i]
    let by = @types.palette_y + 115 + i * 50
    let is_selected = i == game.selected_slot
    // Selection highlight
    if is_selected {
      @raylib.draw_rectangle(
        @types.palette_x + 5,
        by - 3,
        @types.palette_w - 20,
        44,
        @raylib.Color::new(40, 60, 100, 180),
      )
    }
    let name = @types.placeable_kind_name(b.kind)
    let color = @types.placeable_kind_color(b.kind)
    // Slot number
    let slot_num = (i + 1).to_string() + "."
    @draw.draw_text(slot_num, @types.palette_x + 15, by + 5, 18, @types.color_ui_dim)
    // Color indicator
    @raylib.draw_circle(
      @types.palette_x + 55,
      by + 15,
      8.0,
      color,
    )
    // Name
    @draw.draw_text(name, @types.palette_x + 75, by + 5, 18, @types.color_ui_text)
    // Count
    let count_text = (b.total - b.used).to_string() + " / " + b.total.to_string()
    @draw.draw_text(count_text, @types.palette_x + 350, by + 5, 18, @types.color_ui_text)
    // Emitter phase display
    match b.kind {
      PlaceEmitter =>
        if is_selected {
          let phase_text = "Phase: " + game.emitter_phase.to_string()
          let pcol = @types.phase_color(game.emitter_phase)
          @draw.draw_text(phase_text, @types.palette_x + 75, by + 26, 14, pcol)
        }
      _ => ()
    }
  }
  // Target status panel
  let target_y_start = @types.palette_y + 120 + level.budget.length() * 50 + 20
  @draw.draw_text(
    "Targets:",
    @types.palette_x + 10,
    target_y_start,
    18,
    @types.color_ui_text,
  )
  let mut ti = 0
  for y in 0..<game.grid.height {
    for x in 0..<game.grid.width {
      let tile = @types.grid_get(game.grid, x, y)
      if tile.is_target {
        let ty_pos = target_y_start + 25 + ti * 28
        let status_col = if tile.target_satisfied {
          @types.color_target_ok
        } else {
          @types.color_target_fail
        }
        let pos_text = "(" + x.to_string() + "," + y.to_string() + ")"
        @draw.draw_text(pos_text, @types.palette_x + 15, ty_pos, 16, status_col)
        // Amplitude info
        let amp_text = "amp: " + format_float(tile.amplitude) +
          " [" + format_float(tile.target_min) +
          "-" + format_float(tile.target_max) + "]"
        @draw.draw_text(amp_text, @types.palette_x + 100, ty_pos, 14, @types.color_ui_dim)
        // Phase info
        if tile.target_phase >= 0 {
          let phase_text = "phase: " + tile.phase.to_string() +
            " (need " + tile.target_phase.to_string() + ")"
          @draw.draw_text(phase_text, @types.palette_x + 340, ty_pos, 14, @types.color_ui_dim)
        }
        ti += 1
      }
    }
  }
  // Par info
  let par_y = target_y_start + 25 + ti * 28 + 15
  let par_text = "Par: " +
    level.par_objects.to_string() +
    " objects, " +
    level.par_ticks.to_string() +
    " ticks"
  @draw.draw_text(par_text, @types.palette_x + 10, par_y, 16, @types.color_ui_dim)
  let used_text = "Used: " + game.objects_placed.to_string() + " objects"
  @draw.draw_text(used_text, @types.palette_x + 10, par_y + 22, 16, @types.color_ui_text)
}

///|
fn format_float(f : Float) -> String {
  let int_part = f.to_int()
  let dec_part = ((f - Float::from_int(int_part)) * 100.0).to_int()
  let dec_abs = if dec_part < 0 { -dec_part } else { dec_part }
  if dec_abs < 10 {
    int_part.to_string() + ".0" + dec_abs.to_string()
  } else {
    int_part.to_string() + "." + dec_abs.to_string()
  }
}
