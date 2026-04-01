///|
fn draw_playing(game : @types.Game) -> Unit {
  // Draw the main grid (player workspace)
  draw_player_grid(game)
  // Draw the target pattern
  draw_target_grid(game)
  // Draw glaze palette
  draw_palette(game)
  // Draw info panel
  draw_info_panel(game)
  // Draw message
  draw_message(game)
}

///|
fn draw_player_grid(game : @types.Game) -> Unit {
  let gx = @types.grid_offset_x
  let gy = @types.grid_offset_y
  let cs = @types.cell_size
  let gap = @types.cell_gap
  // Grid background
  let total_w = @types.grid_cols * (cs + gap) + gap
  let total_h = @types.grid_rows * (cs + gap) + gap
  @raylib.draw_rectangle(
    gx - gap,
    gy - gap,
    total_w,
    total_h,
    @types.color_grid_border,
  )
  // Label
  let label = "YOUR POTTERY"
  let lw = @draw.measure_text(label, 20)
  @draw.draw_text(
    label,
    gx + (total_w - gap - lw) / 2,
    gy - 32,
    20,
    @types.color_text,
  )
  // Draw cells
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      let cx = gx + col * (cs + gap)
      let cy = gy + row * (cs + gap)
      let cell = @types.get_cell(game.grid, row, col)
      let color = @types.glaze_to_raylib(cell.glaze)
      @raylib.draw_rectangle(cx, cy, cs, cs, color)
      // Draw a subtle inner border
      if cell.glaze is Empty {
        @raylib.draw_rectangle_lines(
          cx,
          cy,
          cs,
          cs,
          @types.color_panel_light,
        )
      }
      // Hover highlight
      if row == game.hover_row && col == game.hover_col {
        @raylib.draw_rectangle_lines(cx, cy, cs, cs, @types.color_highlight)
        @raylib.draw_rectangle_lines(
          cx + 1,
          cy + 1,
          cs - 2,
          cs - 2,
          @types.color_highlight,
        )
        // Show preview of selected glaze
        if cell.glaze is Empty {
          let preview = @types.glaze_to_raylib(game.selected_glaze)
          @raylib.draw_rectangle(
            cx + 4,
            cy + 4,
            cs - 8,
            cs - 8,
            @raylib.Color::new(preview.r.to_int(), preview.g.to_int(), preview.b.to_int(), 100),
          )
        }
      }
    }
  }
}

///|
fn draw_target_grid(game : @types.Game) -> Unit {
  let tx = @types.target_offset_x
  let ty = @types.target_offset_y
  let cs = @types.target_cell_size
  let gap = @types.target_cell_gap
  // Grid background
  let total_w = @types.grid_cols * (cs + gap) + gap
  let total_h = @types.grid_rows * (cs + gap) + gap
  @raylib.draw_rectangle(
    tx - gap,
    ty - gap,
    total_w,
    total_h,
    @types.color_grid_border,
  )
  // Label
  let label = "TARGET PATTERN"
  let lw = @draw.measure_text(label, 20)
  @draw.draw_text(
    label,
    tx + (total_w - gap - lw) / 2,
    ty - 32,
    20,
    @types.color_text,
  )
  // Draw target cells
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      let cx = tx + col * (cs + gap)
      let cy = ty + row * (cs + gap)
      let idx = @types.grid_index(row, col)
      if idx < game.target_grid.length() {
        let color = @types.fired_to_raylib(game.target_grid[idx])
        @raylib.draw_rectangle(cx, cy, cs, cs, color)
      } else {
        @raylib.draw_rectangle(
          cx,
          cy,
          cs,
          cs,
          @types.color_panel_light,
        )
      }
    }
  }
}

///|
fn draw_palette(game : @types.Game) -> Unit {
  let px = @types.target_offset_x
  let py = @types.target_offset_y + @types.grid_rows * (@types.target_cell_size + @types.target_cell_gap) +
    40
  // Label
  @draw.draw_text("GLAZES (1-6, TAB)", px, py, 18, @types.color_text_dim)
  let swatch_size = 40
  let swatch_gap = 8
  for i in 0..<game.allowed_glazes.length() {
    let glaze = game.allowed_glazes[i]
    let sx = px + i * (swatch_size + swatch_gap)
    let sy = py + 26
    let color = @types.glaze_to_raylib(glaze)
    @raylib.draw_rectangle(sx, sy, swatch_size, swatch_size, color)
    // Selection highlight
    if glaze == game.selected_glaze {
      @raylib.draw_rectangle_lines(
        sx - 2,
        sy - 2,
        swatch_size + 4,
        swatch_size + 4,
        @types.color_highlight,
      )
      @raylib.draw_rectangle_lines(
        sx - 3,
        sy - 3,
        swatch_size + 6,
        swatch_size + 6,
        @types.color_highlight,
      )
    }
    // Key label
    let key_str = "\{i + 1}"
    let kw = @draw.measure_text(key_str, 14)
    @draw.draw_text(
      key_str,
      sx + (swatch_size - kw) / 2,
      sy + swatch_size + 4,
      14,
      @types.color_text_dim,
    )
    // Name label
    let name = @types.glaze_name(glaze)
    let nw = @draw.measure_text(name, 12)
    @draw.draw_text(
      name,
      sx + (swatch_size - nw) / 2,
      sy + swatch_size + 20,
      12,
      @types.color_text_dim,
    )
  }
}

///|
fn draw_info_panel(game : @types.Game) -> Unit {
  let px = @types.target_offset_x
  let py = @types.target_offset_y + @types.grid_rows * (@types.target_cell_size + @types.target_cell_gap) +
    160
  // Level name
  guard game.current_level is Some(level) else { return }
  @draw.draw_text(level.name, px, py, 24, @types.color_text)
  // Moves info
  let moves_str = "Moves: \{game.moves_used} / \{game.max_moves}"
  let moves_color = if game.moves_used > game.max_moves {
    @types.color_fail
  } else {
    @types.color_text
  }
  @draw.draw_text(moves_str, px, py + 34, 20, moves_color)
  let par_str = "Par: \{level.par_moves}"
  @draw.draw_text(par_str, px + 200, py + 34, 20, @types.color_text_dim)
  // Controls help
  let y_base = py + 74
  @draw.draw_text("Controls:", px, y_base, 18, @types.color_text_dim)
  @draw.draw_text(
    "Left Click: Place glaze",
    px,
    y_base + 24,
    16,
    @types.color_text_dim,
  )
  @draw.draw_text(
    "Right Click: Erase",
    px,
    y_base + 44,
    16,
    @types.color_text_dim,
  )
  @draw.draw_text(
    "Z: Undo  C: Clear all",
    px,
    y_base + 64,
    16,
    @types.color_text_dim,
  )
  @draw.draw_text(
    "F / Enter: Fire kiln!",
    px,
    y_base + 84,
    16,
    @types.color_text_dim,
  )
  @draw.draw_text(
    "ESC: Back",
    px,
    y_base + 104,
    16,
    @types.color_text_dim,
  )
  // Firing rules reminder
  let ry = y_base + 140
  @draw.draw_text("Firing Rules:", px, ry, 16, @types.color_highlight)
  @draw.draw_text(
    "Same adjacent -> Deeper shade",
    px,
    ry + 20,
    14,
    @types.color_text_dim,
  )
  @draw.draw_text(
    "Red + Blue -> Purple",
    px,
    ry + 38,
    14,
    @types.color_text_dim,
  )
  @draw.draw_text(
    "Red + Green -> CRACK!",
    px,
    ry + 56,
    14,
    @types.color_fail,
  )
  @draw.draw_text(
    "Gold + Black -> CRACK!",
    px,
    ry + 74,
    14,
    @types.color_fail,
  )
}

///|
fn draw_message(game : @types.Game) -> Unit {
  if game.message == "" || game.message_timer <= 0.0 {
    return
  }
  let w = @types.screen_width
  let msg_w = @draw.measure_text(game.message, 22)
  let alpha = @types.mini(
    255,
    (game.message_timer * 255.0 / 0.5).to_int(),
  )
  @draw.draw_text(
    game.message,
    (w - msg_w) / 2,
    @types.screen_height - 50,
    22,
    @raylib.Color::new(255, 220, 80, alpha),
  )
}
