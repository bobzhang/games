///|
pub fn draw_grid_background() -> Unit {
  @raylib.draw_rectangle(
    @types.grid_offset_x,
    @types.grid_offset_y,
    @types.grid_cols * @types.cell_size,
    @types.grid_rows * @types.cell_size,
    grid_color,
  )
  for row in 0..<=@types.grid_rows {
    let y = @types.grid_offset_y + row * @types.cell_size
    @raylib.draw_line(
      @types.grid_offset_x,
      y,
      @types.grid_offset_x + @types.grid_cols * @types.cell_size,
      y,
      grid_line_color,
    )
  }
  for col in 0..<=@types.grid_cols {
    let x = @types.grid_offset_x + col * @types.cell_size
    @raylib.draw_line(
      x,
      @types.grid_offset_y,
      x,
      @types.grid_offset_y + @types.grid_rows * @types.cell_size,
      grid_line_color,
    )
  }
}

///|
pub fn draw_cells(state : @types.LevelState, phase : Float) -> Unit {
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      draw_cell(state.grid[row][col], col, row, phase)
    }
  }
}

///|
fn draw_cell(cell : @types.Cell, col : Int, row : Int, phase : Float) -> Unit {
  let x = @types.cell_screen_x(col)
  let y = @types.cell_screen_y(row)
  let cx = @types.cell_center_x(col)
  let cy = @types.cell_center_y(row)
  let half = @types.cell_size / 2 - 4
  let halfF = Float::from_int(half)
  match cell.kind {
    Empty => ()
    Source => {
      let pulse : Float = @types.sinf(phase * 3.0) * 0.15 + 1.0
      let radius = halfF * pulse
      @raylib.draw_circle_v(@raylib.Vector2::new(cx, cy), radius, source_color)
      @raylib.draw_circle_v(
        @raylib.Vector2::new(cx, cy),
        radius * 0.6,
        @raylib.Color::new(255, 230, 120, 180),
      )
      @draw.draw_text("S", x + half - 3, y + half - 8, 16, @raylib.white)
    }
    Temple(required) => {
      let powered = cell.energy_received >= required
      let color = if powered { temple_powered_color } else { temple_color }
      draw_diamond(cx, cy, halfF, color)
      if powered {
        let glow_alpha = (cell.glow_anim * 100.0).to_int()
        let glow_c = @raylib.Color::new(50, 255, 150, glow_alpha)
        draw_diamond(cx, cy, halfF + 3.0, glow_c)
      }
      let label = required.to_int().to_string()
      let tw = @draw.measure_text(label, 14)
      @draw.draw_text(label, x + half - tw / 2, y + half - 6, 14, @raylib.white)
    }
    Waystone => {
      @raylib.draw_circle_v(
        @raylib.Vector2::new(cx, cy),
        halfF * 0.7,
        waystone_color,
      )
      if cell.energy_received > 0.1 {
        let glow_a = (cell.glow_anim * 80.0).to_int()
        @raylib.draw_circle_v(
          @raylib.Vector2::new(cx, cy),
          halfF * 0.9,
          @raylib.Color::new(180, 160, 255, glow_a),
        )
      }
    }
    Amplifier => {
      let top = @raylib.Vector2::new(cx, cy - halfF)
      let bl = @raylib.Vector2::new(cx - halfF, cy + halfF)
      let br = @raylib.Vector2::new(cx + halfF, cy + halfF)
      @raylib.draw_triangle(top, bl, br, amplifier_color)
      @draw.draw_text("x2", x + half - 8, y + half - 4, 14, @raylib.white)
    }
    Void =>
      @raylib.draw_rectangle(
        x + 1,
        y + 1,
        @types.cell_size - 2,
        @types.cell_size - 2,
        void_color,
      )
  }
}

///|
fn draw_diamond(
  cx : Float,
  cy : Float,
  size : Float,
  color : @raylib.Color,
) -> Unit {
  let top = @raylib.Vector2::new(cx, cy - size)
  let right = @raylib.Vector2::new(cx + size, cy)
  let bottom = @raylib.Vector2::new(cx, cy + size)
  let left = @raylib.Vector2::new(cx - size, cy)
  @raylib.draw_triangle(top, left, right, color)
  @raylib.draw_triangle(left, bottom, right, color)
}

///|
pub fn draw_connections(state : @types.LevelState, phase : Float) -> Unit {
  for i in 0..<state.connections.length() {
    let conn = state.connections[i]
    let x1 = @types.cell_center_x(conn.from_col)
    let y1 = @types.cell_center_y(conn.from_row)
    let x2 = @types.cell_center_x(conn.to_col)
    let y2 = @types.cell_center_y(conn.to_row)
    let has_flow = conn.energy_flow > 0.1
    let base_color = if has_flow { line_active_color } else { line_color }
    let thickness : Float = if has_flow { 3.0 } else { 2.0 }
    @raylib.draw_line_ex(
      @raylib.Vector2::new(x1, y1),
      @raylib.Vector2::new(x2, y2),
      thickness,
      base_color,
    )
    if has_flow {
      let raw_t = phase * 0.5
      let t = raw_t - Float::from_int(raw_t.to_int())
      let px = x1 + (x2 - x1) * t
      let py = y1 + (y2 - y1) * t
      @raylib.draw_circle_v(
        @raylib.Vector2::new(px, py),
        4.0,
        @raylib.Color::new(150, 255, 200, 200),
      )
    }
  }
}

///|
pub fn draw_cursor(state : @types.LevelState, tool : @types.Tool) -> Unit {
  if !state.hover_valid {
    return
  }
  let x = @types.cell_screen_x(state.cursor_col)
  let y = @types.cell_screen_y(state.cursor_row)
  let cell = state.grid[state.cursor_row][state.cursor_col]
  let color = match tool {
    PlaceWaystone =>
      if cell.kind is Empty {
        cursor_valid_color
      } else {
        cursor_invalid_color
      }
    RemoveWaystone =>
      if cell.kind is Waystone {
        cursor_valid_color
      } else {
        cursor_invalid_color
      }
    DrawLine | EraseLine =>
      if @types.is_connectable(cell.kind) {
        cursor_valid_color
      } else {
        cursor_invalid_color
      }
  }
  @raylib.draw_rectangle(
    x + 1,
    y + 1,
    @types.cell_size - 2,
    @types.cell_size - 2,
    color,
  )
}

///|
pub fn draw_energy_labels(state : @types.LevelState) -> Unit {
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      let cell = state.grid[row][col]
      if cell.energy_received > 0.1 &&
        !(cell.kind is Empty || cell.kind is Void) {
        let x = @types.cell_screen_x(col)
        let y = @types.cell_screen_y(row) + @types.cell_size - 14
        let label = cell.energy_received.to_int().to_string()
        @draw.draw_text(label, x + 2, y, 12, energy_text_color)
      }
    }
  }
}

///|
pub fn draw_draw_line_preview(state : @types.LevelState) -> Unit {
  if !state.is_drawing_line {
    return
  }
  let x1 = @types.cell_center_x(state.draw_start_col)
  let y1 = @types.cell_center_y(state.draw_start_row)
  let mx = Float::from_int(@raylib.get_mouse_x())
  let my = Float::from_int(@raylib.get_mouse_y())
  @raylib.draw_line_ex(
    @raylib.Vector2::new(x1, y1),
    @raylib.Vector2::new(mx, my),
    2.0,
    @raylib.Color::new(120, 200, 255, 120),
  )
}
