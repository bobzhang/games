///|
fn draw_playing(game : @types.Game) -> Unit {
  let level_idx = @types.level_index(game.current_tier, game.current_level)
  let level = @levels.get_level(level_idx)
  draw_grid(game, level)
  draw_placed_pieces(game, level)
  draw_hover_preview(game, level)
  draw_palette(game, level)
  draw_game_ui(game, level)
}

///|
fn draw_grid(_game : @types.Game, level : @types.Level) -> Unit {
  let cs = @types.cell_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let region = level.region
  for r in 0..<region.height {
    for c in 0..<region.width {
      let px = ox + c * cs
      let py = oy + r * cs
      if region.active[r][c] {
        @raylib.draw_rectangle(px, py, cs, cs, @types.color_active)
        @raylib.draw_rectangle_lines(
          px,
          py,
          cs,
          cs,
          @types.color_grid_line,
        )
      } else {
        @raylib.draw_rectangle(px, py, cs, cs, @types.color_inactive)
      }
    }
  }
}

///|
fn draw_placed_pieces(game : @types.Game, level : @types.Level) -> Unit {
  let cs = @types.cell_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  for i in 0..<game.placed_pieces.length() {
    let pp = game.placed_pieces[i]
    let piece = level.pieces[pp.piece_index]
    let cells = @types.transform_cells(piece.cells, pp.rotation, pp.flipped)
    for j in 0..<cells.length() {
      let gx = pp.position.x + cells[j].x
      let gy = pp.position.y + cells[j].y
      let px = ox + gx * cs
      let py = oy + gy * cs
      @raylib.draw_rectangle(px + 1, py + 1, cs - 2, cs - 2, piece.color)
      // Slight highlight on top-left for 3D effect
      @raylib.draw_rectangle(
        px + 1,
        py + 1,
        cs - 2,
        3,
        @raylib.Color::new(255, 255, 255, 60),
      )
      @raylib.draw_rectangle(
        px + 1,
        py + 1,
        3,
        cs - 2,
        @raylib.Color::new(255, 255, 255, 40),
      )
    }
  }
}

///|
fn draw_hover_preview(game : @types.Game, level : @types.Level) -> Unit {
  if game.selected_piece < 0 || game.selected_piece >= level.pieces.length() {
    return
  }
  if game.hover_x < 0 || game.hover_y < 0 {
    return
  }
  let piece = level.pieces[game.selected_piece]
  let cells = @types.transform_cells(piece.cells, game.rotation, game.flipped)
  let pos = @types.vec2i(game.hover_x, game.hover_y)
  let valid = @packing.can_place_piece(level.region, game.grid, cells, pos)
  let color = if valid {
    @types.color_hover_valid
  } else {
    @types.color_hover_invalid
  }
  let cs = @types.cell_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  for i in 0..<cells.length() {
    let gx = pos.x + cells[i].x
    let gy = pos.y + cells[i].y
    if gx >= 0 && gx < @types.grid_cols && gy >= 0 && gy < @types.grid_rows {
      let px = ox + gx * cs
      let py = oy + gy * cs
      @raylib.draw_rectangle(px + 2, py + 2, cs - 4, cs - 4, color)
    }
  }
}

///|
fn draw_palette(game : @types.Game, level : @types.Level) -> Unit {
  let px = @types.palette_x
  let py = @types.palette_y
  let pc = @types.palette_cell
  // Title
  @draw.draw_text("Pieces", px, py - 30, 22, @types.color_text)
  for i in 0..<level.pieces.length() {
    let row = i / @types.palette_cols
    let col = i % @types.palette_cols
    let bx = px + col * 120
    let by = py + row * 110
    let used = @packing.is_piece_used(game.placed_pieces, i)
    let selected = game.selected_piece == i
    // Background box
    let bg = if used {
      @raylib.Color::new(40, 40, 50, 200)
    } else if selected {
      @raylib.Color::new(80, 80, 40, 255)
    } else {
      @raylib.Color::new(50, 50, 65, 255)
    }
    @raylib.draw_rectangle(bx, by, 110, 100, bg)
    if selected {
      @raylib.draw_rectangle_lines(
        bx,
        by,
        110,
        100,
        @types.color_selected,
      )
    } else {
      @raylib.draw_rectangle_lines(
        bx,
        by,
        110,
        100,
        @raylib.Color::new(100, 100, 120, 150),
      )
    }
    // Draw piece cells in palette
    let piece = level.pieces[i]
    let (min_x, min_y, max_x, max_y) = @types.piece_bounds(piece.cells)
    let pw = max_x - min_x + 1
    let ph = max_y - min_y + 1
    let off_x = bx + (110 - pw * pc) / 2
    let off_y = by + (80 - ph * pc) / 2 + 5
    let color = if used {
      @raylib.Color::new(
        piece.color.r.to_int() / 3,
        piece.color.g.to_int() / 3,
        piece.color.b.to_int() / 3,
        150,
      )
    } else {
      piece.color
    }
    for j in 0..<piece.cells.length() {
      let cx = off_x + (piece.cells[j].x - min_x) * pc
      let cy = off_y + (piece.cells[j].y - min_y) * pc
      @raylib.draw_rectangle(cx + 1, cy + 1, pc - 2, pc - 2, color)
    }
    // Index label
    let label = (i + 1).to_string()
    @draw.draw_text(label, bx + 4, by + 82, 14, @types.color_text)
    if used {
      @draw.draw_text("used", bx + 40, by + 82, 14, @raylib.Color::new(150, 150, 150, 200))
    }
  }
}
