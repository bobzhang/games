///|
fn draw_playing(game : @types.Game) -> Unit {
  match game.current_level {
    None => ()
    Some(level) => {
      draw_grid(game, level)
      draw_number_palette(game, level)
      draw_constraint_panel(game, level)
      draw_game_hud(game, level)
      if game.message_timer > 0.0 {
        draw_message(game)
      }
    }
  }
}

///|
fn draw_grid(game : @types.Game, level : @types.Level) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  let gs = @types.grid_size
  // Grid background
  @raylib.draw_rectangle(
    ox - 4,
    oy - 4,
    gs * cs + 8,
    gs * cs + 8,
    @types.color_grid_bg,
  )
  // Draw cells
  for row in 0..<gs {
    for col in 0..<gs {
      let x = ox + col * cs
      let y = oy + row * cs
      let value = @types.grid_get(level.grid, row, col)
      let locked = @types.grid_is_locked(level.grid, row, col)
      // Cell background
      let bg = if game.selected_row == row && game.selected_col == col {
        @types.color_cell_selected
      } else if locked {
        @types.color_cell_locked
      } else {
        @types.color_cell_empty
      }
      @raylib.draw_rectangle(x + 2, y + 2, cs - 4, cs - 4, bg)
      // Cell border
      @raylib.draw_rectangle_lines_ex(
        @raylib.Rectangle::new(
          Float::from_int(x + 2),
          Float::from_int(y + 2),
          Float::from_int(cs - 4),
          Float::from_int(cs - 4),
        ),
        1.0,
        @types.color_grid_line,
      )
      // Number
      if value > 0 {
        let text = value.to_string()
        let font_size = 36
        let tw = @draw.measure_text(text, font_size)
        let tx = x + (cs - tw) / 2
        let ty = y + (cs - font_size) / 2
        let color = if locked {
          @types.color_number_locked
        } else if @types.is_prime(value) {
          @types.color_number_prime
        } else {
          @types.color_number_editable
        }
        @draw.draw_text(text, tx, ty, font_size, color)
      }
    }
  }
  // Draw candidate numbers for selected empty cell
  if game.play_state == Editing &&
    game.selected_row >= 0 &&
    game.selected_col >= 0 {
    let sel_val = @types.grid_get(
      level.grid,
      game.selected_row,
      game.selected_col,
    )
    if sel_val == 0 {
      draw_candidates(game, level)
    }
  }
  // Highlight row/col of selected cell
  if game.selected_row >= 0 && game.selected_col >= 0 {
    // Highlight row
    for c in 0..<gs {
      if c != game.selected_col {
        let hx = ox + c * cs
        let hy = oy + game.selected_row * cs
        @raylib.draw_rectangle(
          hx + 2,
          hy + 2,
          cs - 4,
          cs - 4,
          @types.color_cell_highlight,
        )
      }
    }
    // Highlight column
    for r in 0..<gs {
      if r != game.selected_row {
        let hx = ox + game.selected_col * cs
        let hy = oy + r * cs
        @raylib.draw_rectangle(
          hx + 2,
          hy + 2,
          cs - 4,
          cs - 4,
          @types.color_cell_highlight,
        )
      }
    }
  }
  // Highlight errors after checking
  if game.play_state == Failed {
    draw_error_highlights(game, level)
  }
  // Highlight solved
  if game.play_state == Solved {
    @raylib.draw_rectangle(
      ox - 4,
      oy - 4,
      gs * cs + 8,
      gs * cs + 8,
      @types.color_cell_correct,
    )
  }
}

///|
fn draw_candidates(game : @types.Game, level : @types.Level) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  let row = game.selected_row
  let col = game.selected_col
  let candidates = @types.cell_candidates(
    level.grid,
    row,
    col,
    level.constraints,
  )
  let x = ox + col * cs
  let y = oy + row * cs
  // Draw small candidate numbers in a 3x3 sub-grid within the cell
  for n in 1..=9 {
    let sub_col = (n - 1) % 3
    let sub_row = (n - 1) / 3
    let cx = x + 6 + sub_col * 24
    let cy = y + 4 + sub_row * 22
    let text = n.to_string()
    if candidates[n] {
      @draw.draw_text(text, cx, cy, 16, @types.color_candidate_text)
    } else {
      @draw.draw_text(
        text,
        cx,
        cy,
        16,
        @raylib.Color::new(80, 50, 50, 100),
      )
    }
  }
}

///|
fn draw_error_highlights(_game : @types.Game, level : @types.Level) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  // Highlight rows/cols from unsatisfied constraints
  for i in 0..<level.constraints.length() {
    let c = level.constraints[i]
    if !c.satisfied {
      match c.kind {
        RowSum => {
          let row = c.params[0]
          @raylib.draw_rectangle(
            ox,
            oy + row * cs,
            @types.grid_size * cs,
            cs,
            @types.color_cell_error,
          )
        }
        ColProduct => {
          let col = c.params[0]
          @raylib.draw_rectangle(
            ox + col * cs,
            oy,
            cs,
            @types.grid_size * cs,
            @types.color_cell_error,
          )
        }
        Adjacent => {
          @raylib.draw_rectangle(
            ox + c.params[1] * cs,
            oy + c.params[0] * cs,
            cs,
            cs,
            @types.color_cell_error,
          )
          @raylib.draw_rectangle(
            ox + c.params[3] * cs,
            oy + c.params[2] * cs,
            cs,
            cs,
            @types.color_cell_error,
          )
        }
        NoPrimePair => {
          let row = c.params[0]
          @raylib.draw_rectangle(
            ox,
            oy + row * cs,
            @types.grid_size * cs,
            cs,
            @types.color_cell_error,
          )
        }
        Divisible => {
          @raylib.draw_rectangle(
            ox + c.params[1] * cs,
            oy + c.params[0] * cs,
            cs,
            cs,
            @types.color_cell_error,
          )
          @raylib.draw_rectangle(
            ox + c.params[3] * cs,
            oy + c.params[2] * cs,
            cs,
            cs,
            @types.color_cell_error,
          )
        }
        Unique => {
          let is_row = c.params[0] == 0
          let index = c.params[1]
          if is_row {
            @raylib.draw_rectangle(
              ox,
              oy + index * cs,
              @types.grid_size * cs,
              cs,
              @types.color_cell_error,
            )
          } else {
            @raylib.draw_rectangle(
              ox + index * cs,
              oy,
              cs,
              @types.grid_size * cs,
              @types.color_cell_error,
            )
          }
        }
      }
    }
  }
}

///|
fn draw_number_palette(game : @types.Game, level : @types.Level) -> Unit {
  let px = @types.palette_x
  let py = @types.palette_y
  let pc = @types.palette_cell
  // Compute candidates if a cell is selected and empty
  let has_candidates = game.selected_row >= 0 &&
    game.selected_col >= 0 &&
    @types.grid_get(level.grid, game.selected_row, game.selected_col) == 0
  let candidates : Array[Bool] = if has_candidates {
    @types.cell_candidates(
      level.grid,
      game.selected_row,
      game.selected_col,
      level.constraints,
    )
  } else {
    Array::make(10, true)
  }
  // Label
  @draw.draw_text("Numbers:", px, py - 30, 20, @types.color_subtitle)
  // Numbers 1-9
  for i in 0..<9 {
    let num = i + 1
    let x = px + i * (pc + 4)
    let y = py
    let is_valid = candidates[num]
    // Background: tint green for valid, dim for invalid when candidates active
    let bg = if has_candidates {
      if is_valid {
        @raylib.Color::new(35, 55, 45, 255)
      } else {
        @raylib.Color::new(40, 30, 30, 255)
      }
    } else {
      @types.color_palette_bg
    }
    @raylib.draw_rectangle(x, y, pc, pc, bg)
    // Border: highlight valid candidates
    let border = if has_candidates && is_valid {
      @types.color_candidate_valid
    } else {
      @types.color_grid_line
    }
    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(
        Float::from_int(x),
        Float::from_int(y),
        Float::from_int(pc),
        Float::from_int(pc),
      ),
      if has_candidates && is_valid { 2.0 } else { 1.0 },
      border,
    )
    // Number
    let text = num.to_string()
    let tw = @draw.measure_text(text, 28)
    let tx = x + (pc - tw) / 2
    let ty = y + (pc - 28) / 2
    let color = if has_candidates && !is_valid {
      @raylib.Color::new(100, 70, 70, 150)
    } else if @types.is_prime(num) {
      @types.color_number_prime
    } else {
      @types.color_number_editable
    }
    @draw.draw_text(text, tx, ty, 28, color)
  }
  // Clear button (0)
  let cx = px + 9 * (pc + 4)
  @raylib.draw_rectangle(cx, py, pc, pc, @types.color_palette_bg)
  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(cx),
      Float::from_int(py),
      Float::from_int(pc),
      Float::from_int(pc),
    ),
    1.0,
    @types.color_grid_line,
  )
  let ct = "X"
  let ctw = @draw.measure_text(ct, 28)
  @draw.draw_text(
    ct,
    cx + (pc - ctw) / 2,
    py + (pc - 28) / 2,
    28,
    @raylib.Color::new(255, 100, 100, 255),
  )
  // Controls help
  let help_y = py + pc + 15
  @draw.draw_text(
    "Click cell + number key (1-9) | 0/Del: clear | Z: undo | R: restart | Enter: check",
    px,
    help_y,
    14,
    @raylib.Color::new(120, 125, 150, 255),
  )
  // Back instruction
  @draw.draw_text(
    "Esc: back to level select",
    px,
    help_y + 20,
    14,
    @raylib.Color::new(120, 125, 150, 255),
  )
}

///|
fn draw_constraint_panel(game : @types.Game, level : @types.Level) -> Unit {
  let px = @types.constraint_panel_x
  let py = @types.constraint_panel_y
  let panel_w = @types.screen_width - px - 20
  // Panel background
  @raylib.draw_rectangle(
    px - 10,
    py - 10,
    panel_w,
    420,
    @raylib.Color::new(25, 28, 42, 255),
  )
  // Title
  @draw.draw_text("Constraints:", px, py, 22, @types.color_title)
  // Summary bar: satisfied / total
  let show_status = game.play_state == Checking ||
    game.play_state == Solved ||
    game.play_state == Failed
  if show_status {
    let total = level.constraints.length()
    let mut sat_count = 0
    for c in level.constraints {
      if c.satisfied {
        sat_count += 1
      }
    }
    let bar_x = px
    let bar_y = py + 28
    let bar_w = panel_w - 20
    let bar_h = 6
    @raylib.draw_rectangle(
      bar_x,
      bar_y,
      bar_w,
      bar_h,
      @types.color_constraint_bar_bg,
    )
    if total > 0 {
      let fill_w = bar_w * sat_count / total
      let fill_color = if sat_count == total {
        @types.color_constraint_icon_sat
      } else {
        @raylib.Color::new(200, 180, 60, 255)
      }
      @raylib.draw_rectangle(bar_x, bar_y, fill_w, bar_h, fill_color)
    }
  }
  // Constraints list
  let mut y = py + 42
  for i in 0..<level.constraints.length() {
    let c = level.constraints[i]
    let desc = constraint_description(c)
    if show_status {
      // Color-coded icon
      let icon_color = if c.satisfied {
        @types.color_constraint_icon_sat
      } else {
        @types.color_constraint_icon_unsat
      }
      // Draw filled/hollow circle as status indicator
      let icon_cx = px + 10
      let icon_cy = y + 9
      if c.satisfied {
        @raylib.draw_circle(icon_cx, icon_cy, 6.0, icon_color)
      } else {
        @raylib.draw_circle_lines(icon_cx, icon_cy, 6.0, icon_color)
      }
      // Constraint text colored by satisfaction
      let text_color = if c.satisfied {
        @types.color_constraint_sat
      } else {
        @types.color_constraint_unsat
      }
      @draw.draw_text(desc, px + 24, y, 17, text_color)
    } else {
      // Pending state: neutral icon
      @raylib.draw_circle_lines(
        px + 10,
        y + 9,
        6.0,
        @types.color_constraint_icon_pending,
      )
      @draw.draw_text(desc, px + 24, y, 17, @types.color_constraint_text)
    }
    y += 26
    ignore(i)
  }
}

///|
fn constraint_description(c : @types.Constraint) -> String {
  match c.kind {
    RowSum => "Row " + (c.params[0] + 1).to_string() + " sums to " + c.params[1].to_string()
    ColProduct =>
      "Col " + (c.params[0] + 1).to_string() + " product = " + c.params[1].to_string()
    Adjacent =>
      "(" +
      (c.params[0] + 1).to_string() +
      "," +
      (c.params[1] + 1).to_string() +
      ")-(" +
      (c.params[2] + 1).to_string() +
      "," +
      (c.params[3] + 1).to_string() +
      ") differ by 1"
    NoPrimePair => "Row " + (c.params[0] + 1).to_string() + ": no adjacent primes"
    Divisible =>
      "(" +
      (c.params[0] + 1).to_string() +
      "," +
      (c.params[1] + 1).to_string() +
      ") divisible by (" +
      (c.params[2] + 1).to_string() +
      "," +
      (c.params[3] + 1).to_string() +
      ")"
    Unique => {
      let which = if c.params[0] == 0 { "Row" } else { "Col" }
      which + " " + (c.params[1] + 1).to_string() + ": all unique"
    }
  }
}

///|
fn draw_game_hud(game : @types.Game, level : @types.Level) -> Unit {
  // Level info
  let tier_text = @types.tier_name(level.tier)
  let level_num = level.level_index + 1
  let header = tier_text + " - Level " + level_num.to_string()
  @draw.draw_text(header, 80, 20, 28, @types.tier_color(level.tier))
  // Timer
  let minutes = (game.timer / 60.0).to_int()
  let seconds = (game.timer % 60.0).to_int()
  let sec_str = if seconds < 10 {
    "0" + seconds.to_string()
  } else {
    seconds.to_string()
  }
  let time_text = minutes.to_string() + ":" + sec_str
  let tw = @draw.measure_text(time_text, 28)
  @draw.draw_text(
    time_text,
    @types.screen_width - tw - 30,
    20,
    28,
    @types.color_timer,
  )
  // Par time
  let par_min = (level.par_time / 60.0).to_int()
  let par_sec = (level.par_time % 60.0).to_int()
  let par_sec_str = if par_sec < 10 {
    "0" + par_sec.to_string()
  } else {
    par_sec.to_string()
  }
  let par_text = "Par: " + par_min.to_string() + ":" + par_sec_str
  let pw = @draw.measure_text(par_text, 18)
  @draw.draw_text(
    par_text,
    @types.screen_width - pw - 30,
    55,
    18,
    @types.color_subtitle,
  )
  // Play state
  match game.play_state {
    Solved =>
      @draw.draw_text(
        "SOLVED! Press Enter for results",
        @types.grid_offset_x,
        65,
        20,
        @types.color_constraint_sat,
      )
    Failed =>
      @draw.draw_text(
        "Some constraints failed. Keep trying!",
        @types.grid_offset_x,
        65,
        20,
        @types.color_constraint_unsat,
      )
    _ => ()
  }
}

///|
fn draw_message(game : @types.Game) -> Unit {
  let alpha = if game.message_timer < 0.5 {
    (game.message_timer * 510.0).to_int()
  } else {
    255
  }
  let tw = @draw.measure_text(game.message, 24)
  @draw.draw_text(
    game.message,
    (@types.screen_width - tw) / 2,
    @types.screen_height - 80,
    24,
    @raylib.Color::new(255, 255, 255, alpha),
  )
}
