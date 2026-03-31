///|
fn draw_paint_palette(game : @types.Game) -> Unit {
  let px = 950
  let py = 340
  @draw.draw_text("Paint Palette", px, py, 22, @types.color_accent)
  // Forest
  draw_palette_entry(
    px, py + 35, Forest, game.budget.forest, game.selected_biome == Forest,
  )
  // Ocean
  draw_palette_entry(
    px, py + 80, Ocean, game.budget.ocean, game.selected_biome == Ocean,
  )
  // Desert
  draw_palette_entry(
    px, py + 125, Desert, game.budget.desert, game.selected_biome == Desert,
  )
  // Total remaining
  let total = @types.total_budget(game.budget)
  let total_text = "Total paints: " + total.to_string()
  let total_color = if total > 0 {
    @types.color_text
  } else {
    @types.color_text_dim
  }
  @draw.draw_text(total_text, px, py + 170, 16, total_color)
  // Controls hint
  @draw.draw_text(
    "[1] Forest  [2] Ocean  [3] Desert",
    px, py + 195, 14, @types.color_text_dim,
  )
}

///|
fn draw_palette_entry(
  x : Int,
  y : Int,
  biome : @types.BiomeKind,
  remaining : Int,
  selected : Bool
) -> Unit {
  let color = @types.biome_color(biome)
  let name = @types.biome_name(biome)
  // Selection indicator
  if selected {
    @raylib.draw_rectangle(
      x - 5, y - 3, 250, 36,
      @raylib.Color::new(255, 255, 255, 20),
    )
    @raylib.draw_rectangle_lines(x - 5, y - 3, 250, 36, @types.color_accent)
    // Small arrow
    @draw.draw_text(">", x - 18, y, 20, @types.color_accent)
  }
  // Color swatch with hex shape preview
  @raylib.draw_rectangle(x, y, 24, 24, color)
  @raylib.draw_rectangle_lines(x, y, 24, 24, @types.color_text_dim)
  // Name and count
  let label = name + ": " + remaining.to_string()
  let text_color = if remaining > 0 {
    @types.color_text
  } else {
    @types.color_text_dim
  }
  @draw.draw_text(label, x + 32, y + 2, 20, text_color)
  // Paint dots to show remaining
  let dot_y = y + 28
  for d in 0..<remaining {
    if d < 10 {
      @raylib.draw_circle(
        x + 32 + d * 14, dot_y, 4.0, color,
      )
    }
  }
}

///|
fn draw_turn_info(game : @types.Game) -> Unit {
  let tx = 950
  let ty = 555
  // Turn counter with progress bar
  @draw.draw_text(
    "Turn: " + game.current_turn.to_string() + " / Par: " +
    game.par_turns.to_string(),
    tx, ty, 20, @types.color_text,
  )
  // Turn progress bar
  let bar_w = 200
  let progress = if game.par_turns > 0 {
    @types.clampf(
      Float::from_int(game.current_turn) / Float::from_int(game.par_turns),
      0.0,
      1.0,
    )
  } else {
    0.0
  }
  let fill_w = (Float::from_int(bar_w) * progress).to_int()
  let bar_color = if progress < 0.7 {
    @types.color_success
  } else if progress < 1.0 {
    @types.color_tier_balance
  } else {
    @types.color_fail
  }
  @raylib.draw_rectangle(tx, ty + 26, bar_w, 6, @types.color_bar_bg)
  @raylib.draw_rectangle(tx, ty + 26, fill_w, 6, bar_color)
  // State indicator
  let state_text = match game.play_state {
    Painting => "Click a tile to paint"
    Resolving => "Resolving..."
    Complete => "Level Complete!"
    Failed => "No moves left"
  }
  let state_color = match game.play_state {
    Painting => @types.color_text_dim
    Resolving => @types.color_accent
    Complete => @types.color_success
    Failed => @types.color_fail
  }
  @draw.draw_text(state_text, tx, ty + 42, 18, state_color)
  // Controls
  @draw.draw_text(
    "[R] Restart  [U] Undo",
    tx, ty + 68, 14, @types.color_text_dim,
  )
  @draw.draw_text(
    "[Esc] Back to levels",
    tx, ty + 86, 14, @types.color_text_dim,
  )
}

///|
fn draw_biome_rules_panel(game : @types.Game) -> Unit {
  let px = 950
  let py = 660
  // Compact rules reference
  @draw.draw_text("Rules:", px, py, 14, @types.color_accent)
  @draw.draw_text(
    "Forest: spreads near water, dies near 3+ desert",
    px, py + 18, 12, @types.color_text_dim,
  )
  @draw.draw_text(
    "Desert: spreads without water, retreats near 2+ ocean",
    px, py + 32, 12, @types.color_text_dim,
  )
  @draw.draw_text(
    "Ocean: stable, placed by you",
    px, py + 46, 12, @types.color_text_dim,
  )
}

///|
fn draw_level_hint(game : @types.Game) -> Unit {
  let hint = @levels.get_level_hint(game.current_level)
  if hint.length() > 0 {
    // Show hint at bottom of screen, fading out over time
    let alpha = if game.anim_timer < 5.0 {
      @types.minf(1.0, (5.0 - game.anim_timer) / 2.0)
    } else {
      0.0
    }
    if alpha > 0.01 {
      let a = (alpha * 180.0).to_int()
      let hw = @draw.measure_text(hint, 16)
      @draw.draw_text(
        hint,
        (@types.screen_width - hw) / 2,
        @types.screen_height - 25,
        16,
        @raylib.Color::new(180, 200, 220, a),
      )
    }
  }
}

///|
fn draw_level_name(game : @types.Game) -> Unit {
  let name = @types.level_name(game.current_level)
  @draw.draw_text(name, 20, 48, 18, @types.tier_color(game.current_tier))
}

///|
fn draw_undo_stack_indicator(game : @types.Game) -> Unit {
  let count = game.undo_stack.length()
  if count > 0 {
    let text = "Undo: " + count.to_string() + " action" + (if count > 1 {
      "s"
    } else {
      ""
    })
    @draw.draw_text(text, 20, @types.screen_height - 30, 14, @types.color_text_dim)
  }
}

///|
fn draw_grid_coords(game : @types.Game) -> Unit {
  // Show hovered tile coordinates
  if game.hover_col >= 0 && game.hover_row >= 0 {
    let text = "(" + game.hover_col.to_string() + "," + game.hover_row.to_string() +
      ")"
    @draw.draw_text(text, 20, @types.screen_height - 50, 14, @types.color_text_dim)
    // Show tile info
    if game.hover_col < game.grid.width && game.hover_row < game.grid.height {
      let tile = @types.get_tile(game.grid, game.hover_col, game.hover_row)
      let biome_text = @types.biome_name(tile.biome)
      let lock_text = if tile.locked { " [locked]" } else { "" }
      @draw.draw_text(
        biome_text + lock_text,
        20, @types.screen_height - 68, 14, @types.biome_color(tile.biome),
      )
      // Show neighbor counts
      let forest_n = @types.count_neighbor_biome(
        game.grid, game.hover_col, game.hover_row, Forest,
      )
      let ocean_n = @types.count_neighbor_biome(
        game.grid, game.hover_col, game.hover_row, Ocean,
      )
      let desert_n = @types.count_neighbor_biome(
        game.grid, game.hover_col, game.hover_row, Desert,
      )
      let info = "Neighbors: F:" + forest_n.to_string() + " O:" +
        ocean_n.to_string() + " D:" + desert_n.to_string()
      @draw.draw_text(
        info, 20, @types.screen_height - 86, 12, @types.color_text_dim,
      )
    }
  }
}

///|
fn draw_planet_border(game : @types.Game) -> Unit {
  let time = Float::from_int(game.frame_count) * 0.01
  // Atmospheric glow around grid area
  let grid = game.grid
  let hex_w = @types.hex_size * @types.sqrtf(3.0)
  let total_w = Float::from_int(grid.width) * hex_w + hex_w
  let total_h = Float::from_int(grid.height) * @types.hex_size * 1.5 +
    @types.hex_size
  let left = @types.grid_offset_x - 10.0
  let top = @types.grid_offset_y - 10.0
  // Pulsing border
  let pulse = @types.sinf(time * 1.5) * 0.15 + 0.85
  let alpha = (pulse * 80.0).to_int()
  let border_color = @raylib.Color::new(80, 200, 255, alpha)
  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(left, top, total_w + 20.0, total_h + 20.0),
    2.0,
    border_color,
  )
  // Pole labels
  @draw.draw_text(
    "North Pole",
    (@types.grid_offset_x + total_w / 2.0).to_int() - 35,
    (@types.grid_offset_y - 25.0).to_int(),
    14,
    @types.color_text_dim,
  )
  @draw.draw_text(
    "South Pole",
    (@types.grid_offset_x + total_w / 2.0).to_int() - 35,
    (@types.grid_offset_y + total_h + 8.0).to_int(),
    14,
    @types.color_text_dim,
  )
  // Wrap arrows on left and right
  let mid_y = (@types.grid_offset_y + total_h / 2.0).to_int()
  @draw.draw_text(
    "<<", (left - 20.0).to_int(), mid_y, 16, @types.color_text_dim,
  )
  @draw.draw_text(
    ">>", (left + total_w + 25.0).to_int(), mid_y, 16, @types.color_text_dim,
  )
}

///|
fn draw_starfield_bg(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.005
  // Background stars for space theme
  for i in 0..<40 {
    let fi = Float::from_int(i)
    let sx = ((fi * 173.7 + time * 5.0) % Float::from_int(w)).to_int()
    let sy = ((fi * 67.9 + time * 3.0 * (fi % 2.0 + 0.5)) % Float::from_int(
        h,
      )).to_int()
    let brightness = 30 + (fi * 11.0 % 50.0).to_int()
    @raylib.draw_pixel(
      sx, sy,
      @raylib.Color::new(brightness, brightness, brightness + 20, 150),
    )
  }
}

///|
fn draw_playing(game : @types.Game) -> Unit {
  // Background stars
  draw_starfield_bg(game)
  // Level title
  let level_num = game.current_level + 1
  @draw.draw_text(
    "Level " + level_num.to_string(),
    20, 15, 28, @types.color_accent,
  )
  draw_level_name(game)
  // Planet border effect
  draw_planet_border(game)
  // Draw hex grid
  draw_grid(game)
  // Draw UI panels
  draw_ratio_bars(game)
  draw_ecosystem_forecast(game)
  draw_paint_palette(game)
  draw_turn_info(game)
  draw_biome_rules_panel(game)
  draw_grid_coords(game)
  draw_undo_stack_indicator(game)
  draw_resolve_overlay(game)
  draw_completion_sparkles(game)
  draw_level_hint(game)
  // Mini planet view
  draw_mini_planet(1230, 50, game.grid)
}
