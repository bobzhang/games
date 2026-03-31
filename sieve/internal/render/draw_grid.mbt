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
fn draw_number_palette(game : @types.Game, _level : @types.Level) -> Unit {
  let px = @types.palette_x
  let py = @types.palette_y
  let pc = @types.palette_cell
  // Label
  @draw.draw_text("Numbers:", px, py - 30, 20, @types.color_subtitle)
  // Numbers 1-9
  for i in 0..<9 {
    let num = i + 1
    let x = px + i * (pc + 4)
    let y = py
    // Background
    @raylib.draw_rectangle(x, y, pc, pc, @types.color_palette_bg)
    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(
        Float::from_int(x),
        Float::from_int(y),
        Float::from_int(pc),
        Float::from_int(pc),
      ),
      1.0,
      @types.color_grid_line,
    )
    // Number
    let text = num.to_string()
    let tw = @draw.measure_text(text, 28)
    let tx = x + (pc - tw) / 2
    let ty = y + (pc - 28) / 2
    let color = if @types.is_prime(num) {
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
  ignore(game)
}

///|
fn draw_constraint_panel(game : @types.Game, level : @types.Level) -> Unit {
  let px = @types.constraint_panel_x
  let py = @types.constraint_panel_y
  // Panel background
  @raylib.draw_rectangle(
    px - 10,
    py - 10,
    @types.screen_width - px - 20,
    400,
    @raylib.Color::new(25, 28, 42, 255),
  )
  // Title
  @draw.draw_text("Constraints:", px, py, 22, @types.color_title)
  // Constraints list
  let mut y = py + 35
  for i in 0..<level.constraints.length() {
    let c = level.constraints[i]
    let desc = constraint_description(c)
    let status_color = if c.satisfied {
      @types.color_constraint_sat
    } else {
      @types.color_constraint_unsat
    }
    let status_text = if c.satisfied { "[OK]" } else { "[  ]" }
    // Only show status after checking
    let show_status = game.play_state == Checking ||
      game.play_state == Solved ||
      game.play_state == Failed
    if show_status {
      @draw.draw_text(status_text, px, y, 18, status_color)
      @draw.draw_text(desc, px + 50, y, 18, @types.color_constraint_text)
    } else {
      @draw.draw_text("[ ? ]", px, y, 18, @types.color_subtitle)
      @draw.draw_text(desc, px + 50, y, 18, @types.color_constraint_text)
    }
    y += 28
  }
  ignore(game)
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
