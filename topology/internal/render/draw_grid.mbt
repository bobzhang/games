///|
fn draw_playing(game : @types.Game) -> Unit {
  draw_grid(game)
  draw_target_shape(game)
  draw_current_shape(game)
  draw_hover(game)
  draw_ui(game)
}

///|
fn draw_grid(_game : @types.Game) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  let cols = @types.grid_cols
  let rows = @types.grid_rows
  // Grid background
  @raylib.draw_rectangle(
    ox,
    oy,
    cols * cs,
    rows * cs,
    @types.color_grid_bg,
  )
  // Grid lines
  for i in 0..=cols {
    let x = ox + i * cs
    @raylib.draw_line(x, oy, x, oy + rows * cs, @types.color_grid_line)
  }
  for i in 0..=rows {
    let y = oy + i * cs
    @raylib.draw_line(ox, y, ox + cols * cs, y, @types.color_grid_line)
  }
}

///|
fn draw_target_shape(game : @types.Game) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  let target = game.target_shape
  for i in 0..<target.cells.length() {
    let c = target.cells[i]
    let px = ox + c.x * cs
    let py = oy + c.y * cs
    // Check if current shape also has this cell
    let is_overlap = @types.shape_contains(game.current_shape, c)
    if is_overlap {
      @raylib.draw_rectangle(px + 2, py + 2, cs - 4, cs - 4, @types.color_overlap)
    } else {
      // Target outline only
      @raylib.draw_rectangle(
        px + 2,
        py + 2,
        cs - 4,
        cs - 4,
        @raylib.Color::new(60, 220, 120, 40),
      )
      @raylib.draw_rectangle_lines(
        px + 2,
        py + 2,
        cs - 4,
        cs - 4,
        @types.color_target,
      )
    }
  }
}

///|
fn draw_current_shape(game : @types.Game) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  let shape = game.current_shape
  for i in 0..<shape.cells.length() {
    let c = shape.cells[i]
    let px = ox + c.x * cs
    let py = oy + c.y * cs
    // Don't draw if overlap (already drawn)
    if !(@types.shape_contains(game.target_shape, c)) {
      @raylib.draw_rectangle(px + 2, py + 2, cs - 4, cs - 4, @types.color_shape)
    }
  }
}

///|
fn draw_hover(game : @types.Game) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  match game.play_state {
    SelectingGrowCell => {
      // Show valid grow cells
      let adjacent = @types.shape_adjacent_empty(game.current_shape)
      for i in 0..<adjacent.length() {
        let c = adjacent[i]
        let px = ox + c.x * cs
        let py = oy + c.y * cs
        @raylib.draw_rectangle(
          px + 2,
          py + 2,
          cs - 4,
          cs - 4,
          @types.color_grow_valid,
        )
      }
      // Highlight hovered cell
      match game.hover_cell {
        Some(hc) => {
          let px = ox + hc.x * cs
          let py = oy + hc.y * cs
          @raylib.draw_rectangle_lines(
            px + 1,
            py + 1,
            cs - 2,
            cs - 2,
            @raylib.Color::new(100, 255, 100, 255),
          )
        }
        None => ()
      }
    }
    SelectingShrinkCell => {
      // Show valid shrink cells
      let edges = @types.shape_edge_cells(game.current_shape)
      for i in 0..<edges.length() {
        let c = edges[i]
        let px = ox + c.x * cs
        let py = oy + c.y * cs
        @raylib.draw_rectangle(
          px + 2,
          py + 2,
          cs - 4,
          cs - 4,
          @types.color_shrink_valid,
        )
      }
      match game.hover_cell {
        Some(hc) => {
          let px = ox + hc.x * cs
          let py = oy + hc.y * cs
          @raylib.draw_rectangle_lines(
            px + 1,
            py + 1,
            cs - 2,
            cs - 2,
            @raylib.Color::new(255, 100, 100, 255),
          )
        }
        None => ()
      }
    }
    _ =>
      match game.hover_cell {
        Some(hc) => {
          let px = ox + hc.x * cs
          let py = oy + hc.y * cs
          @raylib.draw_rectangle(
            px + 1,
            py + 1,
            cs - 2,
            cs - 2,
            @types.color_hover,
          )
        }
        None => ()
      }
  }
}
