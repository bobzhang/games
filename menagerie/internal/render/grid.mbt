///|
fn draw_grid(game : @types.Game) -> Unit {
  let gx = @types.grid_offset_x
  let gy = @types.grid_offset_y
  let cs = @types.cell_size
  let cols = @types.grid_cols
  let rows = @types.grid_rows
  // Draw cells
  for r in 0..<rows {
    for c in 0..<cols {
      let x = gx + c * cs
      let y = gy + r * cs
      let cell = game.grid.cells[r][c]
      // Background
      let bg = match cell.terrain {
        Some(t) => @types.terrain_color(t)
        None => @types.color_empty
      }
      @raylib.draw_rectangle(x + 1, y + 1, cs - 2, cs - 2, bg)
      // Animal icon
      match cell.animal {
        Some(sp) => {
          let icon = @types.species_icon(sp)
          let col = @types.species_color(sp)
          let iw = @draw.measure_text(icon, 28)
          @draw.draw_text(icon, x + (cs - iw) / 2, y + (cs - 28) / 2, 28, col)
        }
        None => ()
      }
      // Grid lines
      @raylib.draw_rectangle_lines(x, y, cs, cs, @types.color_grid_line)
    }
  }
  // Draw fences
  draw_fences(game)
  // Hover highlight
  if game.hover_col >= 0 && game.hover_row >= 0 {
    let hx = gx + game.hover_col * cs
    let hy = gy + game.hover_row * cs
    let hover_color = @raylib.Color::new(255, 255, 255, 60)
    @raylib.draw_rectangle(hx, hy, cs, cs, hover_color)
    // Show fence placement preview
    match game.current_tool {
      FenceTool =>
        match game.fence_mode {
          Horizontal =>
            @raylib.draw_rectangle(hx, hy, cs, 4, @types.color_fence_highlight)
          Vertical =>
            @raylib.draw_rectangle(hx, hy, 4, cs, @types.color_fence_highlight)
        }
      _ => ()
    }
  }
}

///|
fn draw_fences(game : @types.Game) -> Unit {
  let gx = @types.grid_offset_x
  let gy = @types.grid_offset_y
  let cs = @types.cell_size
  let cols = @types.grid_cols
  let rows = @types.grid_rows
  for r in 0..<rows {
    for c in 0..<cols {
      let cell = game.grid.cells[r][c]
      let x = gx + c * cs
      let y = gy + r * cs
      if cell.fence_top {
        @raylib.draw_rectangle(x, y - 2, cs, 5, @types.color_fence)
      }
      if cell.fence_left {
        @raylib.draw_rectangle(x - 2, y, 5, cs, @types.color_fence)
      }
    }
  }
  // Draw border fences (grid boundary)
  let bx = gx
  let by = gy
  let bw = cols * cs
  let bh = rows * cs
  @raylib.draw_rectangle(bx - 2, by - 2, bw + 4, 4, @types.color_fence)
  @raylib.draw_rectangle(bx - 2, by + bh - 2, bw + 4, 4, @types.color_fence)
  @raylib.draw_rectangle(bx - 2, by - 2, 4, bh + 4, @types.color_fence)
  @raylib.draw_rectangle(bx + bw - 2, by - 2, 4, bh + 4, @types.color_fence)
}
