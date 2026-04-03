///|
fn draw_playing(game : @types.Game) -> Unit {
  // Header
  let level_idx = game.current_level - 1
  let level = @levels.get_level(level_idx)
  let tn = @types.tier_name(game.current_tier)
  @draw.draw_text(
    tn + " - Level " + game.current_level.to_string(),
    20,
    10,
    24,
    @types.color_title,
  )
  // Changes counter
  @draw.draw_text(
    "Changes: " +
    game.heddle_changes.to_string() +
    " (par: " +
    level.par_changes.to_string() +
    ")",
    400,
    14,
    18,
    @types.color_text,
  )
  // Draw loom frame
  draw_loom_frame()
  // Draw player's fabric grid
  draw_fabric_grid(game)
  // Draw heddle indicators (left side)
  draw_heddle_indicators(game)
  // Draw warp color bar (top of grid)
  draw_warp_colors(game)
  // Draw weft color bar (left of grid)
  draw_weft_colors(game)
  // Draw target pattern (right side)
  draw_target_pattern(game)
  // Draw comparison overlay if enabled
  if game.show_comparison {
    draw_comparison(game)
  }
  // Draw controls help
  draw_controls_help(game)
  // Draw hint if shown
  if game.show_hint {
    @draw.draw_text(
      "Hint: " + level.hint,
      20,
      @types.screen_height - 70,
      18,
      @raylib.Color::new(180, 120, 40, 255),
    )
  }
  // Completion overlay
  if game.play_state == Complete {
    draw_completion_overlay()
  }
}

///|
fn draw_loom_frame() -> Unit {
  let gx = @types.grid_offset_x
  let gy = @types.grid_offset_y
  let gw = @types.grid_cols * @types.cell_size
  let gh = @types.grid_rows * @types.cell_size
  // Outer frame
  @raylib.draw_rectangle(
    gx - 8,
    gy - 8,
    gw + 16,
    gh + 16,
    @types.color_loom_frame,
  )
  // Inner background
  @raylib.draw_rectangle(gx - 2, gy - 2, gw + 4, gh + 4, @types.color_grid_bg)
}

///|
fn draw_fabric_grid(game : @types.Game) -> Unit {
  let gx = @types.grid_offset_x
  let gy = @types.grid_offset_y
  let cs = @types.cell_size
  let player = @types.build_player_fabric(game)
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      let x = gx + col * cs
      let y = gy + row * cs
      let cell = @types.pattern_get(player, row, col)
      let color = @types.cell_color(cell.color_index)
      @raylib.draw_rectangle(x, y, cs - 1, cs - 1, color)
      // Draw warp/weft texture indicator
      if cell.state == WarpOver {
        // Vertical lines for warp-over
        @raylib.draw_line(
          x + cs / 2,
          y + 2,
          x + cs / 2,
          y + cs - 3,
          @raylib.Color::new(255, 255, 255, 60),
        )
      } else {
        // Horizontal lines for weft-over
        @raylib.draw_line(
          x + 2,
          y + cs / 2,
          x + cs - 3,
          y + cs / 2,
          @raylib.Color::new(255, 255, 255, 60),
        )
      }
    }
  }
  // Grid lines
  for row in 0..<=@types.grid_rows {
    let y = gy + row * cs
    @raylib.draw_line(
      gx,
      y,
      gx + @types.grid_cols * cs,
      y,
      @types.color_grid_line,
    )
  }
  for col in 0..<=@types.grid_cols {
    let x = gx + col * cs
    @raylib.draw_line(
      x,
      gy,
      x,
      gy + @types.grid_rows * cs,
      @types.color_grid_line,
    )
  }
  // Highlight selected row
  let sel_y = gy + game.selected_row * cs
  @raylib.draw_rectangle(
    gx - 2,
    sel_y,
    @types.grid_cols * cs + 4,
    cs,
    @types.color_selected_row,
  )
  // Row number labels
  for row in 0..<@types.grid_rows {
    let y = gy + row * cs
    let label = (row + 1).to_string()
    let label_color = if row == game.selected_row {
      @types.color_title
    } else {
      @types.color_text_light
    }
    @draw.draw_text(label, gx - 25, y + cs / 2 - 8, 14, label_color)
  }
}

///|
fn draw_heddle_indicators(game : @types.Game) -> Unit {
  let gx = @types.grid_offset_x
  let gy = @types.grid_offset_y
  let cs = @types.cell_size
  // Draw heddle status to the right of the grid
  let hx = gx + @types.grid_cols * cs + 12
  @draw.draw_text("Heddles", hx, gy - 25, 14, @types.color_text_light)
  for row in 0..<@types.grid_rows {
    let h = game.heddles[row]
    let y = gy + row * cs
    for col in 0..<@types.grid_cols {
      let x = hx + col * 10
      let color = if h.raised[col] {
        @types.color_heddle_up
      } else {
        @types.color_heddle_down
      }
      @raylib.draw_rectangle(x, y + 2, 8, cs - 4, color)
    }
  }
}

///|
fn draw_warp_colors(game : @types.Game) -> Unit {
  let gx = @types.grid_offset_x
  let gy = @types.grid_offset_y
  let cs = @types.cell_size
  // Draw warp thread colors above grid
  for col in 0..<@types.grid_cols {
    let x = gx + col * cs
    let color = @types.cell_color(game.warp_colors[col])
    @raylib.draw_rectangle(x, gy - 20, cs - 1, 14, color)
    // Column number
    @draw.draw_text(
      (col + 1).to_string(),
      x + cs / 2 - 4,
      gy - 36,
      12,
      @types.color_text_light,
    )
  }
}

///|
fn draw_weft_colors(game : @types.Game) -> Unit {
  let gx = @types.grid_offset_x
  let gy = @types.grid_offset_y
  let cs = @types.cell_size
  // Draw weft thread colors left of grid
  for row in 0..<@types.grid_rows {
    let y = gy + row * cs
    let color = @types.cell_color(game.weft_colors[row])
    @raylib.draw_rectangle(gx - 44, y, 14, cs - 1, color)
  }
}

///|
fn draw_target_pattern(game : @types.Game) -> Unit {
  let tx = @types.target_offset_x
  let ty = @types.target_offset_y
  let tcs = @types.target_cell_size
  let target = game.target
  @draw.draw_text("Target Pattern", tx, ty - 35, 20, @types.color_title)
  // Frame
  let tw = @types.grid_cols * tcs
  let th = @types.grid_rows * tcs
  @raylib.draw_rectangle(
    tx - 4,
    ty - 4,
    tw + 8,
    th + 8,
    @types.color_loom_frame,
  )
  @raylib.draw_rectangle(tx - 1, ty - 1, tw + 2, th + 2, @types.color_grid_bg)
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      let x = tx + col * tcs
      let y = ty + row * tcs
      let cell = @types.pattern_get(target, row, col)
      let color = @types.cell_color(cell.color_index)
      @raylib.draw_rectangle(x, y, tcs - 1, tcs - 1, color)
      // State indicator
      if cell.state == WarpOver {
        @raylib.draw_line(
          x + tcs / 2,
          y + 1,
          x + tcs / 2,
          y + tcs - 2,
          @raylib.Color::new(255, 255, 255, 50),
        )
      } else {
        @raylib.draw_line(
          x + 1,
          y + tcs / 2,
          x + tcs - 2,
          y + tcs / 2,
          @raylib.Color::new(255, 255, 255, 50),
        )
      }
    }
  }
  // Target grid lines
  for row in 0..<=@types.grid_rows {
    let y = ty + row * tcs
    @raylib.draw_line(
      tx,
      y,
      tx + @types.grid_cols * tcs,
      y,
      @raylib.Color::new(180, 170, 155, 100),
    )
  }
  for col in 0..<=@types.grid_cols {
    let x = tx + col * tcs
    @raylib.draw_line(
      x,
      ty,
      x,
      ty + @types.grid_rows * tcs,
      @raylib.Color::new(180, 170, 155, 100),
    )
  }
  // Warp color bar for target
  for col in 0..<@types.grid_cols {
    let x = tx + col * tcs
    let color = @types.cell_color(target.warp_colors[col])
    @raylib.draw_rectangle(x, ty - 14, tcs - 1, 10, color)
  }
  // Weft color bar for target
  for row in 0..<@types.grid_rows {
    let y = ty + row * tcs
    let color = @types.cell_color(target.weft_colors[row])
    @raylib.draw_rectangle(tx - 14, y, 10, tcs - 1, color)
  }
  // Legend below target
  let ly = ty + th + 20
  @draw.draw_text("Thread Colors:", tx, ly, 16, @types.color_text)
  for i in 0..<@types.thread_colors.length() {
    let lx = tx + i * 80
    @raylib.draw_rectangle(lx, ly + 24, 16, 16, @types.thread_colors[i])
    @draw.draw_text(
      @types.thread_color_names[i],
      lx + 22,
      ly + 26,
      14,
      @types.color_text_light,
    )
  }
}

///|
fn draw_comparison(game : @types.Game) -> Unit {
  let player = @types.build_player_fabric(game)
  let target = game.target
  let gx = @types.grid_offset_x
  let gy = @types.grid_offset_y
  let cs = @types.cell_size
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      let x = gx + col * cs
      let y = gy + row * cs
      let p_cell = @types.pattern_get(player, row, col)
      let t_cell = @types.pattern_get(target, row, col)
      if p_cell != t_cell {
        // Draw red X for mismatched cells
        @raylib.draw_line(
          x + 3,
          y + 3,
          x + cs - 4,
          y + cs - 4,
          @types.color_incorrect,
        )
        @raylib.draw_line(
          x + cs - 4,
          y + 3,
          x + 3,
          y + cs - 4,
          @types.color_incorrect,
        )
      } else {
        // Small green dot for correct cells
        @raylib.draw_circle(
          x + cs / 2,
          y + cs / 2,
          3.0,
          @raylib.Color::new(80, 200, 120, 120),
        )
      }
    }
  }
}

///|
fn draw_completion_overlay() -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 80),
  )
  let msg = "PATTERN COMPLETE!"
  let tw = @draw.measure_text(msg, 40)
  @draw.draw_text(
    msg,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 40,
    40,
    @types.color_star_gold,
  )
  let hint = "Press ENTER for results"
  let hw = @draw.measure_text(hint, 22)
  @draw.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    @types.screen_height / 2 + 20,
    22,
    @raylib.white,
  )
}

///|
fn draw_controls_help(game : @types.Game) -> Unit {
  let _ = game
  let hx = @types.target_offset_x
  let hy = @types.target_offset_y +
    @types.grid_rows * @types.target_cell_size +
    100
  @draw.draw_text("Controls:", hx, hy, 16, @types.color_text)
  let controls = [
    "Up/Down: Select row", "1-8: Toggle warp column", "Left/Right: Shift row pattern",
    "A: Apply alternating", "C: Copy from row above", "I: Invert row", "Tab: Compare view",
    "H: Show hint", "Enter: Check pattern", "ESC: Back",
  ]
  for i in 0..<controls.length() {
    let col = i / 5
    let row = i % 5
    @draw.draw_text(
      controls[i],
      hx + col * 180,
      hy + 22 + row * 18,
      14,
      @types.color_text_light,
    )
  }
}
