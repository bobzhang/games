///|
pub fn draw_program_panel(game : @types.Game) -> Unit {
  let px = @types.program_panel_x
  let py = @types.program_panel_y
  let pw = @types.program_panel_width
  // Panel background
  @raylib.draw_rectangle(px, py, pw, 640, @types.color_panel_bg)
  @raylib.draw_rectangle_lines(px, py, pw, 640, @types.color_grid_line)
  // Title
  @draw.draw_text("PROGRAM", px + 10, py + 6, 18, @types.color_text_bright)
  // Instruction count
  let count_text = game.program.commands.length().to_string() +
    "/" +
    game.program.max_slots.to_string()
  @draw.draw_text(count_text, px + pw - 80, py + 6, 16, @types.color_text_dim)
  // Draw command slots
  let slot_start_y = py + 32
  let slot_h = @types.program_slot_height
  let max_visible = 15
  for i in 0..<max_visible {
    let sy = slot_start_y + i * (slot_h + 2)
    if i < game.program.commands.length() {
      draw_command_slot(game, i, px + 8, sy, pw - 16, slot_h)
    } else if i == game.program.commands.length() && i < game.program.max_slots {
      // Empty slot indicator
      let is_cursor = i == game.editor.cursor && game.run_state == Editing
      let bg = if is_cursor {
        @types.color_slot_active
      } else {
        @types.color_slot_bg
      }
      @raylib.draw_rectangle(px + 8, sy, pw - 16, slot_h, bg)
      @raylib.draw_rectangle_lines(
        px + 8,
        sy,
        pw - 16,
        slot_h,
        @types.color_grid_line,
      )
      @draw.draw_text(
        "+ (Space to add)",
        px + 14,
        sy + 7,
        14,
        @types.color_text_dim,
      )
    } else {
      // Empty unused slot
      @raylib.draw_rectangle(px + 8, sy, pw - 16, slot_h, @types.color_bg_dark)
    }
  }
  // Draw palette if open
  if game.editor.palette_open && game.run_state == Editing {
    draw_palette(game)
  }
  // Draw execution info
  draw_execution_info(game, px, slot_start_y + (max_visible + 1) * (slot_h + 2))
}

///|
fn draw_command_slot(
  game : @types.Game,
  index : Int,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Unit {
  let cmd = game.program.commands[index]
  let is_cursor = index == game.editor.cursor && game.run_state == Editing
  let is_executing = is_step_executing(game, index)
  // Background
  let bg = if is_executing {
    @types.color_exec_highlight
  } else if is_cursor {
    @types.color_slot_active
  } else {
    @types.color_slot_bg
  }
  @raylib.draw_rectangle(x, y, w, h, bg)
  // Command color bar
  let cmd_col = @commands.command_color(cmd.kind)
  @raylib.draw_rectangle(x, y, 4, h, cmd_col)
  // Index number
  let idx_str = (index + 1).to_string()
  @draw.draw_text(idx_str, x + 8, y + 7, 13, @types.color_text_dim)
  // Command name
  let name = @commands.command_name(cmd.kind)
  @draw.draw_text(name, x + 30, y + 7, 14, cmd_col)
  // Description
  let desc = @commands.command_description(cmd.kind)
  @draw.draw_text(desc, x + 140, y + 7, 12, @types.color_text_dim)
  // Border
  if is_cursor {
    @raylib.draw_rectangle_lines(x, y, w, h, @types.color_robot)
  } else {
    @raylib.draw_rectangle_lines(x, y, w, h, @types.color_grid_line)
  }
}

///|
fn is_step_executing(game : @types.Game, cmd_index : Int) -> Bool {
  match game.trace {
    Some(trace) =>
      if game.trace_step >= 0 && game.trace_step < trace.states.length() {
        let state = trace.states[game.trace_step]
        state.cmd_index == cmd_index
      } else {
        false
      }
    None => false
  }
}

///|
fn draw_palette(game : @types.Game) -> Unit {
  let px = @types.palette_x
  let py = @types.palette_y
  let pw = @types.program_panel_width
  let cmds = game.editor.palette_commands
  let total_h = cmds.length() * 28 + 40
  // Background
  @raylib.draw_rectangle(
    px,
    py,
    pw,
    total_h,
    @raylib.Color::new(20, 20, 35, 240),
  )
  @raylib.draw_rectangle_lines(px, py, pw, total_h, @types.color_robot)
  @draw.draw_text(
    "SELECT COMMAND",
    px + 10,
    py + 6,
    16,
    @types.color_text_bright,
  )
  for i in 0..<cmds.length() {
    let iy = py + 28 + i * 28
    let is_sel = i == game.editor.palette_cursor
    if is_sel {
      @raylib.draw_rectangle(px + 4, iy, pw - 8, 26, @types.color_slot_active)
    }
    let col = @commands.command_color(cmds[i])
    @raylib.draw_rectangle(px + 8, iy + 2, 4, 22, col)
    let name = @commands.command_name(cmds[i])
    @draw.draw_text(name, px + 18, iy + 5, 14, col)
    let desc = @commands.command_description(cmds[i])
    @draw.draw_text(desc, px + 140, iy + 5, 12, @types.color_text_dim)
    if is_sel {
      @raylib.draw_rectangle_lines(px + 4, iy, pw - 8, 26, @types.color_robot)
    }
  }
}

///|
fn draw_execution_info(game : @types.Game, x : Int, y : Int) -> Unit {
  match game.run_state {
    Editing => {
      @draw.draw_text(
        "[Space] Add  [Bksp] Del  [Enter] Run",
        x + 10,
        y,
        13,
        @types.color_text_dim,
      )
      @draw.draw_text(
        "[W/S] Move cmd  [R] Reset  [C] Clear",
        x + 10,
        y + 18,
        13,
        @types.color_text_dim,
      )
      @draw.draw_text(
        "[Esc] Back  [1-9] Quick add",
        x + 10,
        y + 36,
        13,
        @types.color_text_dim,
      )
    }
    Running => {
      let step_text = "Step: " + game.trace_step.to_string()
      @draw.draw_text(step_text, x + 10, y, 14, @types.color_robot)
      let speed_text = "Speed: " + game.run_speed.to_string() + "x"
      @draw.draw_text(speed_text, x + 150, y, 14, @types.color_text_dim)
      @draw.draw_text(
        "[1-4] Speed  [Space] Pause  [R] Reset",
        x + 10,
        y + 18,
        13,
        @types.color_text_dim,
      )
    }
    Stepping => {
      let step_text = "Step: " + game.trace_step.to_string()
      @draw.draw_text(step_text, x + 10, y, 14, @types.color_cmd_jump)
      @draw.draw_text(
        "[Space] Next  [Enter] Run  [R] Reset",
        x + 10,
        y + 18,
        13,
        @types.color_text_dim,
      )
    }
    Complete =>
      @draw.draw_text("LEVEL COMPLETE!", x + 10, y, 18, @types.color_success)
    Failed(reason) => {
      @draw.draw_text("FAILED!", x + 10, y, 18, @types.color_fail)
      @draw.draw_text(reason, x + 10, y + 22, 13, @types.color_fail)
      @draw.draw_text(
        "[R] Reset  [Esc] Back",
        x + 10,
        y + 40,
        13,
        @types.color_text_dim,
      )
    }
  }
}
