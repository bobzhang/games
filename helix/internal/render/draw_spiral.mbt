///|
fn draw_spiral_view(game : @types.Game) -> Unit {
  let level = match game.current_level {
    None => return
    Some(l) => l
  }
  let cx : Float = @types.center_x
  let cy : Float = @types.center_y
  let cw_cells = level.cw_spiral.cells
  let ccw_cells = level.ccw_spiral.cells
  let cw_len = cw_cells.length()
  let ccw_len = ccw_cells.length()
  // Draw connecting lines for CW spiral (outer)
  draw_spiral_path(cw_len, true, cx, cy, @types.color_cw_trail)
  // Draw connecting lines for CCW spiral (inner)
  draw_spiral_path(ccw_len, false, cx, cy, @types.color_ccw_trail)
  // Draw CW cells
  for i in 0..<cw_len {
    let (x, y) = @types.cell_pos_on_spiral(i, cw_len, true, cx, cy)
    draw_cell(cw_cells[i], x, y)
  }
  // Draw CCW cells
  for i in 0..<ccw_len {
    let (x, y) = @types.cell_pos_on_spiral(i, ccw_len, false, cx, cy)
    draw_cell(ccw_cells[i], x, y)
  }
  // Draw CW token
  let (cw_x, cw_y) = @types.cell_pos_on_spiral(
    game.cw_pos,
    cw_len,
    true,
    cx,
    cy,
  )
  draw_token(cw_x, cw_y, @types.color_cw_token, game.anim_timer, true)
  // Draw CCW token
  let (ccw_x, ccw_y) = @types.cell_pos_on_spiral(
    game.ccw_pos,
    ccw_len,
    false,
    cx,
    cy,
  )
  draw_token(ccw_x, ccw_y, @types.color_ccw_token, game.anim_timer, false)
  // Draw center target
  draw_center_target(cx, cy, game.anim_timer)
  // Draw blocked/won overlay
  match game.play_state {
    Blocked => {
      let msg = "BLOCKED! Press Z to Undo or R to Restart"
      let mw = @draw.measure_text(msg, 24)
      @raylib.draw_rectangle(
        640 - mw / 2 - 10,
        660,
        mw + 20,
        36,
        @raylib.Color::new(0, 0, 0, 200),
      )
      @draw.draw_text(msg, 640 - mw / 2, 664, 24, @types.color_gate_closed)
    }
    Won => {
      let msg = "SOLVED! Press Enter for Results"
      let mw = @draw.measure_text(msg, 28)
      @raylib.draw_rectangle(
        640 - mw / 2 - 10,
        660,
        mw + 20,
        40,
        @raylib.Color::new(0, 0, 0, 200),
      )
      @draw.draw_text(msg, 640 - mw / 2, 664, 28, @types.color_star_gold)
    }
    Moving => ()
  }
}

///|
fn draw_spiral_path(
  total : Int,
  is_cw : Bool,
  cx : Float,
  cy : Float,
  color : @raylib.Color
) -> Unit {
  for i in 0..<(total - 1) {
    let (x1, y1) = @types.cell_pos_on_spiral(i, total, is_cw, cx, cy)
    let (x2, y2) = @types.cell_pos_on_spiral(i + 1, total, is_cw, cx, cy)
    @raylib.draw_line_ex(
      @raylib.Vector2::new(x1, y1),
      @raylib.Vector2::new(x2, y2),
      1.5,
      color,
    )
  }
}

///|
fn draw_cell(cell : @types.Cell, x : Float, y : Float) -> Unit {
  let r = @types.cell_radius
  match cell.kind {
    Path => {
      if cell.has_pickup {
        @raylib.draw_circle_v(
          @raylib.Vector2::new(x, y),
          r * 0.7,
          @types.color_path_cell,
        )
        draw_diamond(x, y, r * 0.5, @types.color_pickup)
      } else if cell.arrow_offset != 0 {
        @raylib.draw_circle_v(
          @raylib.Vector2::new(x, y),
          r * 0.7,
          @types.color_path_cell,
        )
        let arrow_col = if cell.arrow_offset > 0 {
          @raylib.Color::new(100, 255, 100, 255)
        } else {
          @raylib.Color::new(255, 100, 100, 255)
        }
        let txt = if cell.arrow_offset > 0 { ">>" } else { "<<" }
        @draw.draw_text(txt, x.to_int() - 8, y.to_int() - 6, 12, arrow_col)
      } else {
        @raylib.draw_circle_v(
          @raylib.Vector2::new(x, y),
          r * 0.6,
          @types.color_path_cell,
        )
      }
    }
    Switch =>
      // Diamond shape for switch
      draw_diamond(x, y, r, @types.color_switch)
    Gate => {
      let col = if cell.gate_open {
        @types.color_gate_open
      } else {
        @types.color_gate_closed
      }
      let half = r * 0.8
      @raylib.draw_rectangle_lines_ex(
        @raylib.Rectangle::new(x - half, y - half, half * 2.0, half * 2.0),
        2.0,
        col,
      )
      if !cell.gate_open {
        @raylib.draw_line_ex(
          @raylib.Vector2::new(x - half, y - half),
          @raylib.Vector2::new(x + half, y + half),
          1.5,
          col,
        )
        @raylib.draw_line_ex(
          @raylib.Vector2::new(x + half, y - half),
          @raylib.Vector2::new(x - half, y + half),
          1.5,
          col,
        )
      } else {
        @raylib.draw_rectangle(
          (x - half + 2.0).to_int(),
          (y - half + 2.0).to_int(),
          (half * 2.0 - 4.0).to_int(),
          (half * 2.0 - 4.0).to_int(),
          @raylib.Color::new(
            col.r.to_int(),
            col.g.to_int(),
            col.b.to_int(),
            60,
          ),
        )
      }
    }
    SyncPoint => {
      @raylib.draw_circle_lines_v(
        @raylib.Vector2::new(x, y),
        r,
        @types.color_sync,
      )
      @raylib.draw_circle_lines_v(
        @raylib.Vector2::new(x, y),
        r * 0.5,
        @types.color_sync,
      )
    }
    OneShotSwitch => {
      draw_diamond(x, y, r, @types.color_oneshot)
      @raylib.draw_circle_v(
        @raylib.Vector2::new(x, y),
        r * 0.3,
        @types.color_bg,
      )
    }
  }
}

///|
fn draw_diamond(
  x : Float,
  y : Float,
  size : Float,
  color : @raylib.Color
) -> Unit {
  @raylib.draw_line_ex(
    @raylib.Vector2::new(x, y - size),
    @raylib.Vector2::new(x + size, y),
    2.0,
    color,
  )
  @raylib.draw_line_ex(
    @raylib.Vector2::new(x + size, y),
    @raylib.Vector2::new(x, y + size),
    2.0,
    color,
  )
  @raylib.draw_line_ex(
    @raylib.Vector2::new(x, y + size),
    @raylib.Vector2::new(x - size, y),
    2.0,
    color,
  )
  @raylib.draw_line_ex(
    @raylib.Vector2::new(x - size, y),
    @raylib.Vector2::new(x, y - size),
    2.0,
    color,
  )
}

///|
fn draw_token(
  x : Float,
  y : Float,
  color : @raylib.Color,
  t : Float,
  is_cw : Bool
) -> Unit {
  let pulse : Float = @types.sinf(t * 4.0) * 2.0
  let r : Float = @types.token_radius + pulse
  // Glow
  @raylib.draw_circle_v(
    @raylib.Vector2::new(x, y),
    r + 4.0,
    @raylib.Color::new(
      color.r.to_int(),
      color.g.to_int(),
      color.b.to_int(),
      40,
    ),
  )
  // Main circle
  @raylib.draw_circle_v(@raylib.Vector2::new(x, y), r, color)
  // Direction indicator
  let arrow = if is_cw { ">" } else { "<" }
  @draw.draw_text(arrow, x.to_int() - 4, y.to_int() - 7, 14, @types.color_bg)
}

///|
fn draw_center_target(cx : Float, cy : Float, t : Float) -> Unit {
  let pulse : Float = @types.sinf(t * 2.0) * 3.0
  let r : Float = 20.0 + pulse
  @raylib.draw_circle_lines_v(
    @raylib.Vector2::new(cx, cy),
    r,
    @types.color_star_gold,
  )
  @raylib.draw_circle_lines_v(
    @raylib.Vector2::new(cx, cy),
    r * 0.5,
    @types.color_star_gold,
  )
  @raylib.draw_circle_v(
    @raylib.Vector2::new(cx, cy),
    4.0,
    @types.color_star_gold,
  )
}
