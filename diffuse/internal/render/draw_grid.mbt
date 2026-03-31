///|
fn cell_x(col : Int) -> Int {
  @types.grid_offset_x + col * @types.cell_size
}

///|
fn cell_y(row : Int) -> Int {
  @types.grid_offset_y + row * @types.cell_size
}

///|
pub fn draw_grid(game : @types.Game) -> Unit {
  let g = game.grid
  let cs = @types.cell_size
  // Compute spread preview if in placing state
  let preview : Array[Bool] = if game.show_preview && game.play_state == Placing {
    @ink.compute_preview(g)
  } else {
    Array::make(g.width * g.height, false)
  }
  // Draw tiles
  for row in 0..<g.height {
    for col in 0..<g.width {
      let x = cell_x(col)
      let y = cell_y(row)
      let tile = @types.grid_get(g, col, row)
      let idx = @types.grid_index(g, col, row)
      match tile.kind {
        Barrier => {
          @raylib.draw_rectangle(x, y, cs, cs, @types.color_barrier)
          // Draw subtle cross pattern on barriers
          let cx = x + cs / 2
          let cy = y + cs / 2
          let hs = cs / 4
          @raylib.draw_line(
            cx - hs, cy - hs, cx + hs, cy + hs,
            @raylib.Color::new(80, 75, 70, 255),
          )
          @raylib.draw_line(
            cx + hs, cy - hs, cx - hs, cy + hs,
            @raylib.Color::new(80, 75, 70, 255),
          )
        }
        Paper | Target => {
          // Base paper color
          @raylib.draw_rectangle(x, y, cs, cs, @types.color_paper)
          // Draw ink if present
          if !@types.ink_is_empty(tile.ink) {
            let ink_color = @types.ink_to_color(tile.ink)
            @raylib.draw_rectangle(x + 2, y + 2, cs - 4, cs - 4, ink_color)
          }
          // Spread preview overlay
          if preview[idx] {
            @raylib.draw_rectangle(x + 2, y + 2, cs - 4, cs - 4, @types.color_preview)
          }
          // Target ring
          if tile.kind == Target {
            let target_col = @types.ink_to_color(tile.target_color)
            // Draw target indicator - colored border ring
            @raylib.draw_rectangle_lines(
              x + 3, y + 3, cs - 6, cs - 6, target_col,
            )
            @raylib.draw_rectangle_lines(
              x + 4, y + 4, cs - 8, cs - 8, target_col,
            )
            @raylib.draw_rectangle_lines(
              x + 5, y + 5, cs - 10, cs - 10, target_col,
            )
            // Draw small target color indicator in corner
            @raylib.draw_rectangle(x + cs - 16, y + 2, 14, 14, target_col)
            @raylib.draw_rectangle_lines(
              x + cs - 16, y + 2, 14, 14,
              @raylib.Color::new(0, 0, 0, 100),
            )
            // Check mark if satisfied
            if @types.ink_equals(tile.ink, tile.target_color) {
              @draw.draw_text(
                "OK", x + cs / 2 - 10, y + cs / 2 - 8, 16,
                @raylib.Color::new(255, 255, 255, 200),
              )
            }
          }
        }
      }
    }
  }
  // Grid lines
  for row in 0..=g.height {
    let y = cell_y(row)
    let x_start = cell_x(0)
    let x_end = cell_x(g.width)
    @raylib.draw_line(x_start, y, x_end, y, @types.color_grid_line)
  }
  for col in 0..=g.width {
    let x = cell_x(col)
    let y_start = cell_y(0)
    let y_end = cell_y(g.height)
    @raylib.draw_line(x, y_start, x, y_end, @types.color_grid_line)
  }
  // Hover highlight
  if game.play_state == Placing &&
    game.hover_col >= 0 &&
    game.hover_col < g.width &&
    game.hover_row >= 0 &&
    game.hover_row < g.height {
    let tile = @types.grid_get(g, game.hover_col, game.hover_row)
    if tile.kind != Barrier {
      let hx = cell_x(game.hover_col)
      let hy = cell_y(game.hover_row)
      let ch_color = @types.channel_to_color(game.selected_channel)
      let hover_col = @raylib.Color::new(
        ch_color.r.to_int(), ch_color.g.to_int(), ch_color.b.to_int(), 80,
      )
      @raylib.draw_rectangle(hx + 1, hy + 1, cs - 2, cs - 2, hover_col)
      @raylib.draw_rectangle_lines(
        hx, hy, cs, cs, @types.color_selected_border,
      )
    }
  }
}
