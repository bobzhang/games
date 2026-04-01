///|
fn draw_ops_panel(game : @types.Game, level : @types.Level) -> Unit {
  let py = @types.ops_panel_y
  let px = @types.ops_panel_x
  let w = @types.screen_width
  // Panel background
  @raylib.draw_rectangle(px - 10, py - 10, w - 60, 130, @types.color_panel)
  @raylib.draw_rectangle_lines(
    px - 10,
    py - 10,
    w - 60,
    130,
    @types.color_panel_border,
  )
  @draw.draw_text("OPERATIONS:", px, py, 16, @types.color_text_dim)
  let mut ox = px
  let ops = level.available_ops
  for i in 0..<ops.length() {
    let op = ops[i]
    let selected = game.selected_op == op
    let color = @types.op_color(op)
    let name = @types.op_name(op)
    let key = @types.op_key(op)
    let box_w = 120
    let box_h = 50
    let by = py + 25
    // Background
    let bg = if selected {
      @raylib.Color::new(
        color.r.to_int(),
        color.g.to_int(),
        color.b.to_int(),
        60,
      )
    } else {
      @raylib.Color::new(30, 30, 40, 200)
    }
    @raylib.draw_rectangle(ox, by, box_w, box_h, bg)
    let border = if selected { color } else { @types.color_panel_border }
    @raylib.draw_rectangle_lines(ox, by, box_w, box_h, border)
    // Key label
    @draw.draw_text("[" + key + "]", ox + 5, by + 5, 14, @types.color_text_dim)
    // Operation name
    @draw.draw_text(
      name,
      ox + 30,
      by + 5,
      18,
      if selected {
        color
      } else {
        @types.color_text
      },
    )
    // Description
    let desc = op_description(op)
    @draw.draw_text(desc, ox + 5, by + 30, 11, @types.color_text_dim)
    ox += box_w + 10
  }
  // Insert base selector (when insert selected)
  if game.selected_op == Insert {
    let ibx = ox + 20
    let iby = py + 25
    @draw.draw_text("Base [Tab]:", ibx, iby, 14, @types.color_text_dim)
    let bases : Array[@types.Base] = [A, T, G, C]
    for j in 0..<4 {
      let b = bases[j]
      let bx = ibx + j * 35
      let by2 = iby + 20
      let sel = game.insert_base == b
      let bc = @types.base_color(b)
      if sel {
        @raylib.draw_rectangle(
          bx,
          by2,
          30,
          25,
          @raylib.Color::new(bc.r.to_int(), bc.g.to_int(), bc.b.to_int(), 80),
        )
      }
      @raylib.draw_rectangle_lines(
        bx,
        by2,
        30,
        25,
        if sel {
          bc
        } else {
          @types.color_panel_border
        },
      )
      @draw.draw_text(@types.base_char(b), bx + 8, by2 + 3, 18, bc)
    }
  }
  // Undo info
  let undo_text = "Undo [Z]: " + game.ops_history.length().to_string() + " ops"
  @draw.draw_text(undo_text, w - 200, py + 85, 14, @types.color_text_dim)
  // Verify button hint
  let verify_text = "[V] VERIFY SEQUENCE"
  let verify_color = @types.color_highlight
  @draw.draw_text(verify_text, px, py + 85, 16, verify_color)
}

///|
fn op_description(op : @types.OpKind) -> String {
  match op {
    Cut => "Remove at cursor"
    Insert => "Add base at cursor"
    Duplicate => "Copy selection"
    Invert => "Reverse selection"
    Delete => "Remove selection"
  }
}

///|
fn draw_help_overlay() -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  // Semi-transparent background
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 0, 0, 200))
  let px = w / 2 - 250
  let py = 80
  let pw = 500
  let ph = 560
  @raylib.draw_rectangle(px, py, pw, ph, @types.color_panel)
  @raylib.draw_rectangle_lines(px, py, pw, ph, @types.color_highlight)
  @draw.draw_text("HELP", px + 220, py + 15, 28, @types.color_highlight)
  let mut y = py + 60
  let x = px + 30
  let gap = 28
  @draw.draw_text("NAVIGATION", x, y, 18, @types.color_highlight)
  y += gap
  @draw.draw_text("Left/Right  Move cursor", x, y, 15, @types.color_text)
  y += gap - 4
  @draw.draw_text("Shift+Arrow  Select range", x, y, 15, @types.color_text)
  y += gap - 4
  @draw.draw_text("Home/End  Jump to start/end", x, y, 15, @types.color_text)
  y += gap + 6
  @draw.draw_text("OPERATIONS", x, y, 18, @types.color_highlight)
  y += gap
  @draw.draw_text(
    "[1] Cut     Remove base at cursor", x, y, 15, @types.color_op_cut,
  )
  y += gap - 4
  @draw.draw_text(
    "[2] Insert  Add base at cursor (Tab to cycle)", x, y, 15, @types.color_op_insert,
  )
  y += gap - 4
  @draw.draw_text(
    "[3] Dup     Copy selected range after itself", x, y, 15, @types.color_op_duplicate,
  )
  y += gap - 4
  @draw.draw_text(
    "[4] Invert  Reverse selected range", x, y, 15, @types.color_op_invert,
  )
  y += gap - 4
  @draw.draw_text(
    "[5] Delete  Remove selected range", x, y, 15, @types.color_op_delete,
  )
  y += gap + 6
  @draw.draw_text("ACTIONS", x, y, 18, @types.color_highlight)
  y += gap
  @draw.draw_text(
    "Enter  Apply selected operation", x, y, 15, @types.color_text,
  )
  y += gap - 4
  @draw.draw_text(
    "V      Verify sequence against target", x, y, 15, @types.color_text,
  )
  y += gap - 4
  @draw.draw_text("Z      Undo last operation", x, y, 15, @types.color_text)
  y += gap - 4
  @draw.draw_text("R      Restart level", x, y, 15, @types.color_text)
  y += gap - 4
  @draw.draw_text(
    "Tab    Cycle insert base (A>T>G>C)", x, y, 15, @types.color_text,
  )
  y += gap + 6
  @draw.draw_text("GOAL", x, y, 18, @types.color_highlight)
  y += gap
  @draw.draw_text(
    "Edit the sequence so codons (3-base groups)", x, y, 15, @types.color_text,
  )
  y += gap - 4
  @draw.draw_text(
    "produce the target trait list. ATG=Start, TGA=Stop.", x, y, 15, @types.color_text,
  )
  y += gap + 6
  @draw.draw_text(
    "Press H to close",
    px + 190,
    py + ph - 35,
    16,
    @types.color_text_dim,
  )
}
