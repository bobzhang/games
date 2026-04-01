///|
fn draw_ui(game : @types.Game) -> Unit {
  let panel_x = 580
  let panel_y = 80
  let panel_w = 660
  let panel_h = 560
  // Panel background
  @raylib.draw_rectangle(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(20, 22, 35, 200),
  )
  @raylib.draw_rectangle_lines(
    panel_x, panel_y, panel_w, panel_h, @types.color_grid_line,
  )
  // Level info
  let level_idx = game.current_level_idx
  let tier_start = @types.tier_start_index(game.current_tier)
  let local_idx = level_idx - tier_start + 1
  let level_name = @types.tier_name(game.current_tier) +
    " " +
    local_idx.to_string()
  @draw.draw_text(
    level_name,
    panel_x + 20,
    panel_y + 15,
    24,
    @types.color_accent,
  )
  // Cost display
  let cost_str = "Cost: " + game.total_cost.to_string()
  @draw.draw_text(cost_str, panel_x + 20, panel_y + 55, 20, @types.color_text)
  // Par display
  let levels = @types.get_level_par_and_min(level_idx)
  let par_str = "Par: " +
    levels.0.to_string() +
    "  Min: " +
    levels.1.to_string()
  @draw.draw_text(
    par_str,
    panel_x + 200,
    panel_y + 55,
    16,
    @types.color_text_dim,
  )
  // Match percentage
  let match_pct = calc_match_pct(game)
  let match_str = "Match: " + match_pct.to_string() + "%"
  let match_color = if match_pct == 100 {
    @types.color_gold
  } else if match_pct >= 70 {
    @types.color_target
  } else {
    @types.color_text
  }
  @draw.draw_text(match_str, panel_x + 420, panel_y + 55, 18, match_color)
  // Operations palette
  draw_operations(game, panel_x + 20, panel_y + 100)
  // Direction selector (if applicable)
  match game.play_state {
    SelectingDirection => draw_direction_selector(panel_x + 20, panel_y + 340)
    SelectingFlipAxis => draw_flip_selector(panel_x + 20, panel_y + 340)
    _ => ()
  }
  // History
  draw_history(game, panel_x + 20, panel_y + 400)
  // Controls
  draw_controls(panel_x + 20, panel_y + panel_h - 50)
  // Message
  if game.message_timer > 0.0 {
    let msg_w = @draw.measure_text(game.message, 20)
    @draw.draw_text(
      game.message,
      (@types.screen_width - msg_w) / 2,
      @types.screen_height - 50,
      20,
      @types.color_gold,
    )
  }
  // Won state overlay
  if game.play_state == Won {
    let won_str = "TARGET MATCHED!"
    let won_w = @draw.measure_text(won_str, 32)
    @draw.draw_text(
      won_str,
      (@types.screen_width - won_w) / 2,
      30,
      32,
      @types.color_gold,
    )
    let cont_str = "ENTER - Continue"
    let cont_w = @draw.measure_text(cont_str, 20)
    @draw.draw_text(
      cont_str,
      (@types.screen_width - cont_w) / 2,
      @types.screen_height - 30,
      20,
      @types.color_accent,
    )
  }
}

///|
fn calc_match_pct(game : @types.Game) -> Int {
  let current = game.current_shape
  let target = game.target_shape
  if target.cells.length() == 0 && current.cells.length() == 0 {
    return 100
  }
  // Count cells in common
  let matching = @types.shape_match_count(current, target)
  // Total unique cells across both shapes
  let total_target = target.cells.length()
  let mut extra_current = 0
  for i in 0..<current.cells.length() {
    if !@types.shape_contains(target, current.cells[i]) {
      extra_current = extra_current + 1
    }
  }
  let total = total_target + extra_current
  if total == 0 {
    return 100
  }
  matching * 100 / total
}

///|
fn draw_operations(game : @types.Game, base_x : Int, base_y : Int) -> Unit {
  @draw.draw_text("OPERATIONS", base_x, base_y, 18, @types.color_text)
  let ops : Array[@types.OpKind] = [Shift, Rotate, Flip, Grow, Shrink]
  let level_idx = game.current_level_idx
  let available = @types.get_level_available_ops(level_idx)
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  for i in 0..<ops.length() {
    let op = ops[i]
    let bx = base_x + i * 120
    let by = base_y + 30
    let bw = 110
    let bh = 60
    let is_available = op_is_available(op, available)
    let is_selected = match game.selected_op {
      Some(sel) => sel == op
      None => false
    }
    let hovered = mx >= bx && mx < bx + bw && my >= by && my < by + bh
    let bg = if !is_available {
      @types.color_op_disabled
    } else if is_selected {
      @types.color_op_selected
    } else if hovered {
      @types.color_button_hover
    } else {
      @types.color_op_bg
    }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    if is_available {
      @raylib.draw_rectangle_lines(bx, by, bw, bh, @types.color_accent)
    }
    // Op name
    let name = @types.op_name(op)
    let name_w = @draw.measure_text(name, 16)
    let name_color = if is_available {
      @types.color_text
    } else {
      @types.color_text_dim
    }
    @draw.draw_text(name, bx + (bw - name_w) / 2, by + 8, 16, name_color)
    // Cost
    let cost = @types.op_cost(op)
    let cost_str = "Cost: " + cost.to_string()
    let cost_w = @draw.measure_text(cost_str, 12)
    @draw.draw_text(
      cost_str,
      bx + (bw - cost_w) / 2,
      by + 35,
      12,
      @types.color_text_dim,
    )
    // Keyboard shortcut
    let key_str = (i + 1).to_string()
    @draw.draw_text(key_str, bx + 4, by + 4, 10, @types.color_text_dim)
  }
  // State-specific instruction
  let inst = match game.play_state {
    SelectingDirection => "Click direction or WASD"
    SelectingFlipAxis => "H - Horizontal  V - Vertical"
    SelectingGrowCell => "Click cell to add"
    SelectingShrinkCell => "Click cell to remove"
    Won => "Target matched!"
    _ => ""
  }
  if inst != "" {
    @draw.draw_text(inst, base_x, base_y + 100, 16, @types.color_accent)
  }
}

///|
fn op_is_available(
  op : @types.OpKind,
  available : Array[@types.OpKind],
) -> Bool {
  for i in 0..<available.length() {
    if available[i] == op {
      return true
    }
  }
  false
}

///|
fn draw_direction_selector(base_x : Int, base_y : Int) -> Unit {
  @draw.draw_text("DIRECTION", base_x, base_y, 16, @types.color_text)
  let dirs = ["N (W)", "E (D)", "S (S)", "W (A)"]
  for i in 0..<dirs.length() {
    let bx = base_x + i * 100
    let by = base_y + 25
    @raylib.draw_rectangle(bx, by, 90, 30, @types.color_op_bg)
    @raylib.draw_rectangle_lines(bx, by, 90, 30, @types.color_accent)
    let dw = @draw.measure_text(dirs[i], 14)
    @draw.draw_text(dirs[i], bx + (90 - dw) / 2, by + 8, 14, @types.color_text)
  }
}

///|
fn draw_flip_selector(base_x : Int, base_y : Int) -> Unit {
  @draw.draw_text("FLIP AXIS", base_x, base_y, 16, @types.color_text)
  let axes = ["H - Horizontal", "V - Vertical"]
  for i in 0..<axes.length() {
    let bx = base_x + i * 200
    let by = base_y + 25
    @raylib.draw_rectangle(bx, by, 180, 30, @types.color_op_bg)
    @raylib.draw_rectangle_lines(bx, by, 180, 30, @types.color_accent)
    let aw = @draw.measure_text(axes[i], 14)
    @draw.draw_text(axes[i], bx + (180 - aw) / 2, by + 8, 14, @types.color_text)
  }
}

///|
fn draw_history(game : @types.Game, base_x : Int, base_y : Int) -> Unit {
  @draw.draw_text("HISTORY", base_x, base_y, 16, @types.color_text)
  let history = game.ops_history
  let max_show = @types.mini(history.length(), 8)
  let start_idx = if history.length() > 8 { history.length() - 8 } else { 0 }
  for i in 0..<max_show {
    let op = history[start_idx + i]
    let hx = base_x + i * 75
    let hy = base_y + 25
    let name = @types.op_name(op.kind)
    @draw.draw_text(name, hx, hy, 12, @types.color_text_dim)
    let cost_str = "(" + op.cost.to_string() + ")"
    @draw.draw_text(cost_str, hx, hy + 16, 10, @types.color_text_dim)
  }
  if history.length() == 0 {
    @draw.draw_text(
      "No operations yet",
      base_x,
      base_y + 25,
      12,
      @types.color_text_dim,
    )
  }
}

///|
fn draw_controls(base_x : Int, base_y : Int) -> Unit {
  @draw.draw_text(
    "Z - Undo    R - Restart    ESC - Back", base_x, base_y, 14, @types.color_text_dim,
  )
}
