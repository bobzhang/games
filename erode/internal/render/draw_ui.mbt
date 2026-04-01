///|
fn draw_force_palette(game : @types.Game) -> Unit {
  let palette_x = 80
  let palette_y = 640
  @draw.draw_text("FORCES:", palette_x, palette_y - 25, 20, @types.color_text)
  // Determine which forces are available for this tier
  let forces : Array[@types.ForceKind] = available_forces(game.current_tier)
  for i, force in forces {
    let bx = palette_x + i * 180
    let by = palette_y
    let bw = 160
    let bh = 50
    let remaining = @types.force_budget_remaining(game.budget, force)
    let is_selected = game.selected_force == force
    let is_available = remaining > 0
    // Button background
    let bg_color = if is_selected {
      @types.color_selected
    } else if is_available {
      @types.color_button
    } else {
      @raylib.Color::new(40, 40, 50, 255)
    }
    @raylib.draw_rectangle(bx, by, bw, bh, bg_color)
    // Border
    let border_color = @types.force_color(force)
    @raylib.draw_rectangle_lines(bx, by, bw, bh, border_color)
    // Force name
    let name = @types.force_name(force)
    let text_color = if is_selected {
      @raylib.Color::new(30, 30, 40, 255)
    } else if is_available {
      @types.color_text
    } else {
      @types.color_text_dim
    }
    @draw.draw_text(name, bx + 8, by + 5, 18, text_color)
    // Budget count
    let count_text = "x\{remaining}"
    @draw.draw_text(count_text, bx + 8, by + 28, 16, text_color)
    // Key hint
    let key_text = "\{i + 1}"
    @draw.draw_text(key_text, bx + bw - 24, by + 5, 16, @types.color_text_dim)
  }
}

///|
fn available_forces(tier : @types.Tier) -> Array[@types.ForceKind] {
  match tier {
    Clay => [Water, WindLeft, WindRight]
    Stone => [Water, WindLeft, WindRight, Frost]
    Crystal => [Water, WindLeft, WindRight, Frost, Heat]
  }
}

///|
fn draw_match_info(game : @types.Game) -> Unit {
  let info_x = 700
  let info_y = 640
  // Match percentage
  let pct = @erosion.match_percentage(game.grid, game.target)
  let pct_text = "Match: \{pct}%"
  let pct_color = if pct == 100 {
    @types.color_target_match
  } else if pct >= 80 {
    @types.color_text_highlight
  } else {
    @types.color_text
  }
  @draw.draw_text(pct_text, info_x, info_y, 24, pct_color)
  // Forces used vs par
  let forces_text = "Forces: \{game.forces_used}/\{game.par_forces}"
  let forces_color = if game.forces_used <= game.par_forces {
    @types.color_target_match
  } else {
    @types.color_heat
  }
  @draw.draw_text(forces_text, info_x, info_y + 30, 20, forces_color)
  // Play state indicator
  let state_text = match game.play_state {
    Selecting => "Select a force"
    Previewing(kind) => "Apply \{@types.force_name(kind)}? [SPACE]"
    Animating => "Eroding..."
    Won => "Level Complete!"
    Lost => "Out of forces!"
  }
  let state_color = match game.play_state {
    Won => @types.color_target_match
    Lost => @types.color_heat
    _ => @types.color_text_dim
  }
  @draw.draw_text(state_text, info_x, info_y + 56, 18, state_color)
}

///|
fn draw_controls_help(game : @types.Game) -> Unit {
  let _ = game
  let hx = 1050
  let hy = 640
  @draw.draw_text("[1-5] Force", hx, hy, 14, @types.color_text_dim)
  @draw.draw_text("[SPACE] Apply", hx, hy + 18, 14, @types.color_text_dim)
  @draw.draw_text("[Z] Undo", hx, hy + 36, 14, @types.color_text_dim)
  @draw.draw_text("[R] Restart", hx, hy + 54, 14, @types.color_text_dim)
  @draw.draw_text("[ESC] Back", hx, hy + 72, 14, @types.color_text_dim)
}

///|
fn draw_stars(x : Int, y : Int, count : Int, max : Int) -> Unit {
  for i in 0..<max {
    let sx = x + i * 30
    let color = if i < count {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    @draw.draw_text("*", sx, y, 28, color)
  }
}
