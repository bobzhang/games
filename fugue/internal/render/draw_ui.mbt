///|
fn draw_play_ui(game : @types.Game) -> Unit {
  let level = game.current_level
  let panel_x = 20
  let panel_y = @types.grid_offset_y
  // Note budget
  let budget_used = @types.count_notes_in_grid(game.grid)
  let budget_total = level.note_budget
  let budget_col = if budget_used >= budget_total {
    @types.color_dissonant
  } else {
    @types.color_text
  }
  @draw.draw_text("Notes", panel_x, panel_y, 18, @types.color_text_dim)
  @draw.draw_text(
    budget_used.to_string() + "/" + budget_total.to_string(),
    panel_x,
    panel_y + 22,
    22,
    budget_col,
  )
  // Harmony score
  let harmony = @harmony.compute_total_harmony(game.grid)
  let harm_y = panel_y + 65
  @draw.draw_text("Harmony", panel_x, harm_y, 18, @types.color_text_dim)
  let harm_col = if harmony > 0 {
    @types.color_consonant
  } else if harmony < 0 {
    @types.color_dissonant
  } else {
    @types.color_text
  }
  let harm_str = if harmony >= 0 {
    "+" + harmony.to_string()
  } else {
    harmony.to_string()
  }
  @draw.draw_text(harm_str, panel_x, harm_y + 22, 26, harm_col)
  // Harmony bar (visual)
  if level.tier != Melody {
    let bar_y = harm_y + 55
    let bar_w = 150
    let bar_h = 12
    @raylib.draw_rectangle(
      panel_x,
      bar_y,
      bar_w,
      bar_h,
      @raylib.Color::new(40, 40, 60, 255),
    )
    // Thresholds
    let max_val = if level.harmony_threshold_3star > 0 {
      level.harmony_threshold_3star + 4
    } else {
      20
    }
    if harmony > 0 {
      let fill_w = harmony * bar_w / max_val
      let clamped_w = if fill_w > bar_w { bar_w } else { fill_w }
      @raylib.draw_rectangle(
        panel_x, bar_y, clamped_w, bar_h, @types.color_consonant,
      )
    }
    // 2-star threshold line
    if level.harmony_threshold_2star > 0 {
      let t2x = panel_x + level.harmony_threshold_2star * bar_w / max_val
      @raylib.draw_line(
        t2x,
        bar_y - 2,
        t2x,
        bar_y + bar_h + 2,
        @types.color_star_on,
      )
      @draw.draw_text(
        "2*",
        t2x - 6,
        bar_y + bar_h + 4,
        12,
        @types.color_star_on,
      )
    }
    // 3-star threshold line
    if level.harmony_threshold_3star > 0 {
      let t3x = panel_x + level.harmony_threshold_3star * bar_w / max_val
      @raylib.draw_line(
        t3x,
        bar_y - 2,
        t3x,
        bar_y + bar_h + 2,
        @types.color_star_on,
      )
      @draw.draw_text(
        "3*",
        t3x - 6,
        bar_y + bar_h + 4,
        12,
        @types.color_star_on,
      )
    }
  }
  // Targets matched
  let targ_y = panel_y + 145
  let matched = @harmony.count_matched(game.grid, level.targets)
  let total = level.targets.length()
  @draw.draw_text("Targets", panel_x, targ_y, 18, @types.color_text_dim)
  let targ_col = if matched == total {
    @types.color_consonant
  } else {
    @types.color_text
  }
  @draw.draw_text(
    matched.to_string() + "/" + total.to_string(),
    panel_x,
    targ_y + 22,
    22,
    targ_col,
  )
  // Controls help
  let help_y = @types.screen_height - 160
  @draw.draw_text("Controls", panel_x, help_y, 18, @types.color_text_dim)
  @draw.draw_text(
    "Click: Toggle note",
    panel_x,
    help_y + 24,
    14,
    @types.color_text_dim,
  )
  @draw.draw_text(
    "Space: Play/Stop",
    panel_x,
    help_y + 42,
    14,
    @types.color_text_dim,
  )
  @draw.draw_text(
    "R: Restart level",
    panel_x,
    help_y + 60,
    14,
    @types.color_text_dim,
  )
  @draw.draw_text("Z: Undo", panel_x, help_y + 78, 14, @types.color_text_dim)
  @draw.draw_text(
    "Enter: Submit",
    panel_x,
    help_y + 96,
    14,
    @types.color_text_dim,
  )
  @draw.draw_text("Esc: Back", panel_x, help_y + 114, 14, @types.color_text_dim)
  // Playback state
  let state_y = @types.grid_offset_y +
    @types.cell_height * @types.grid_rows +
    20
  let state_str = match game.play_state {
    Idle => "Ready"
    Playing => "Playing col " + (game.playback_col + 1).to_string()
    Finished => "Done"
  }
  let state_col = match game.play_state {
    Idle => @types.color_text_dim
    Playing => @types.color_melody_tier
    Finished => @types.color_consonant
  }
  @draw.draw_text(state_str, @types.grid_offset_x, state_y, 20, state_col)
  // Playback progress bar
  if game.play_state == Playing {
    let bar_x = @types.grid_offset_x
    let bar_y2 = state_y + 28
    let bar_w = @types.cell_width * @types.grid_cols
    let bar_h = 6
    @raylib.draw_rectangle(
      bar_x,
      bar_y2,
      bar_w,
      bar_h,
      @raylib.Color::new(40, 40, 60, 255),
    )
    let prog = (game.playback_col + 1) * bar_w / @types.grid_cols
    @raylib.draw_rectangle(bar_x, bar_y2, prog, bar_h, @types.color_melody_tier)
  }
}
