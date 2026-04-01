///|
fn draw_playing(game : @types.Game) -> Unit {
  let board = game.board
  let cs = @types.cell_size_for(board.size)
  let gx = @types.grid_offset_x
  let gy = @types.grid_offset_y
  let grid_w = board.size * cs
  let grid_h = board.size * cs
  // Draw grid background
  @raylib.draw_rectangle(gx - 4, gy - 4, grid_w + 8, grid_h + 8, @types.color_grid_line)
  @raylib.draw_rectangle(gx, gy, grid_w, grid_h, @types.color_grid_bg)
  // Draw cells
  for row in 0..<board.size {
    for col in 0..<board.size {
      let cx = gx + col * cs
      let cy = gy + row * cs
      // Cell border
      @raylib.draw_rectangle_lines(cx, cy, cs, cs, @types.color_grid_line)
      match @types.board_get(board, row, col) {
        Some(patch) => draw_patch(board, patch, cx, cy, cs, row, col)
        None => {
          // Empty cell - draw dashed outline
          let qx = cx + cs / 4
          let qy = cy + cs / 4
          let qs = cs / 2
          @raylib.draw_rectangle_lines(qx, qy, qs, qs, @types.color_text_light)
        }
      }
      // Highlight selected board cell
      if game.selected_board == row * board.size + col {
        @raylib.draw_rectangle(cx + 2, cy + 2, cs - 4, cs - 4, @types.color_selected)
      }
    }
  }
  // Draw tray
  draw_tray(game)
  // Draw UI
  draw_hud(game)
}

///|
fn draw_patch(
  board : @types.Board,
  patch : @types.Patch,
  x : Int,
  y : Int,
  size : Int,
  row : Int,
  col : Int
) -> Unit {
  let base_color = if patch.pinned {
    @types.color_pinned
  } else {
    @types.color_patch_base
  }
  @raylib.draw_rectangle(x + 1, y + 1, size - 2, size - 2, base_color)
  // Draw fabric pattern (subtle diagonal lines for texture)
  let step = 8
  for i in 0..<(size / step) {
    let offset = i * step
    @raylib.draw_line(
      x + offset,
      y + 1,
      x + 1,
      y + offset,
      @raylib.Color::new(0, 0, 0, 15),
    )
    @raylib.draw_line(
      x + size - 1,
      y + offset,
      x + offset,
      y + size - 1,
      @raylib.Color::new(0, 0, 0, 15),
    )
  }
  // Draw edge patterns
  draw_edge_pattern(patch, x, y, size, 0, board, row, col) // North
  draw_edge_pattern(patch, x, y, size, 1, board, row, col) // East
  draw_edge_pattern(patch, x, y, size, 2, board, row, col) // South
  draw_edge_pattern(patch, x, y, size, 3, board, row, col) // West
  // Pinned indicator
  if patch.pinned {
    draw_lock_icon(x + size / 2 - 6, y + size / 2 - 6)
  }
}

///|
fn draw_edge_pattern(
  patch : @types.Patch,
  x : Int,
  y : Int,
  size : Int,
  edge_idx : Int,
  board : @types.Board,
  row : Int,
  col : Int
) -> Unit {
  let pattern = patch.edges[edge_idx]
  let is_wildcard = patch.wildcard_edges[edge_idx]
  let dir : @types.Direction = match edge_idx {
    0 => North
    1 => East
    2 => South
    _ => West
  }
  let matched = @matching.edge_matched_at(board, row, col, dir)
  let has_neighbor = match dir {
    North => row > 0 && @types.board_get(board, row - 1, col) != None
    East =>
      col + 1 < board.size && @types.board_get(board, row, col + 1) != None
    South =>
      row + 1 < board.size && @types.board_get(board, row + 1, col) != None
    West => col > 0 && @types.board_get(board, row, col - 1) != None
  }
  let edge_color = if is_wildcard {
    @types.color_wildcard
  } else {
    @types.pattern_color(pattern)
  }
  // Draw thick edge stripe with outer border for clarity
  let thickness = 8
  let margin = 3
  match edge_idx {
    0 => {
      // North
      @raylib.draw_rectangle(
        x + margin,
        y + 1,
        size - margin * 2,
        thickness,
        edge_color,
      )
      // Outer border line for definition
      @raylib.draw_rectangle(
        x + margin,
        y + thickness + 1,
        size - margin * 2,
        1,
        @raylib.Color::new(0, 0, 0, 40),
      )
      draw_pattern_marks(pattern, is_wildcard, x + margin, y + 1, size - margin * 2, thickness, true)
    }
    1 => {
      // East
      @raylib.draw_rectangle(
        x + size - thickness - 1,
        y + margin,
        thickness,
        size - margin * 2,
        edge_color,
      )
      @raylib.draw_rectangle(
        x + size - thickness - 2,
        y + margin,
        1,
        size - margin * 2,
        @raylib.Color::new(0, 0, 0, 40),
      )
      draw_pattern_marks(
        pattern,
        is_wildcard,
        x + size - thickness - 1,
        y + margin,
        thickness,
        size - margin * 2,
        false,
      )
    }
    2 => {
      // South
      @raylib.draw_rectangle(
        x + margin,
        y + size - thickness - 1,
        size - margin * 2,
        thickness,
        edge_color,
      )
      @raylib.draw_rectangle(
        x + margin,
        y + size - thickness - 2,
        size - margin * 2,
        1,
        @raylib.Color::new(0, 0, 0, 40),
      )
      draw_pattern_marks(
        pattern,
        is_wildcard,
        x + margin,
        y + size - thickness - 1,
        size - margin * 2,
        thickness,
        true,
      )
    }
    _ => {
      // West
      @raylib.draw_rectangle(
        x + 1,
        y + margin,
        thickness,
        size - margin * 2,
        edge_color,
      )
      @raylib.draw_rectangle(
        x + thickness + 1,
        y + margin,
        1,
        size - margin * 2,
        @raylib.Color::new(0, 0, 0, 40),
      )
      draw_pattern_marks(pattern, is_wildcard, x + 1, y + margin, thickness, size - margin * 2, false)
    }
  }
  // Match/mismatch indicator - larger and more visible
  if has_neighbor {
    let ix : Int = match edge_idx {
      0 => x + size / 2
      1 => x + size - 12
      2 => x + size / 2
      _ => x + 8
    }
    let iy : Int = match edge_idx {
      0 => y + 12
      1 => y + size / 2
      2 => y + size - 16
      _ => y + size / 2
    }
    if matched {
      // Green checkmark circle - larger glow + solid center
      @raylib.draw_circle(ix, iy, 6.0, @raylib.Color::new(80, 200, 120, 60))
      @raylib.draw_circle(ix, iy, 4.0, @types.color_matched)
      // Small check mark lines
      @raylib.draw_line(ix - 2, iy, ix - 1, iy + 2, @raylib.white)
      @raylib.draw_line(ix - 1, iy + 2, ix + 3, iy - 2, @raylib.white)
    } else {
      // Red X circle - larger glow + solid center
      @raylib.draw_circle(ix, iy, 6.0, @raylib.Color::new(220, 80, 80, 60))
      @raylib.draw_circle(ix, iy, 4.0, @types.color_mismatched)
      // Small X lines
      @raylib.draw_line(ix - 2, iy - 2, ix + 2, iy + 2, @raylib.white)
      @raylib.draw_line(ix + 2, iy - 2, ix - 2, iy + 2, @raylib.white)
    }
  }
}

///|
fn draw_pattern_marks(
  pattern : @types.EdgePattern,
  is_wildcard : Bool,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  horizontal : Bool
) -> Unit {
  let mark_color = @raylib.Color::new(255, 255, 255, 200)
  let mark_shadow = @raylib.Color::new(0, 0, 0, 60)
  if is_wildcard {
    // Rainbow shimmer for wildcard
    let colors = [
      @raylib.Color::new(255, 50, 50, 170),
      @raylib.Color::new(255, 180, 0, 170),
      @raylib.Color::new(255, 255, 50, 170),
      @raylib.Color::new(50, 255, 50, 170),
      @raylib.Color::new(50, 100, 255, 170),
    ]
    let count = 5
    if horizontal {
      let seg = w / count
      for i in 0..<count {
        @raylib.draw_rectangle(x + i * seg, y, seg, h, colors[i])
      }
    } else {
      let seg = h / count
      for i in 0..<count {
        @raylib.draw_rectangle(x, y + i * seg, w, seg, colors[i])
      }
    }
    return
  }
  match pattern {
    Zigzag =>
      // Thick zigzag marks with shadow
      if horizontal {
        let count = w / 14
        for i in 0..<count {
          let bx = x + i * 14 + 2
          // Shadow
          @raylib.draw_line(bx + 1, y + h / 2 + 1, bx + 7, y + 1, mark_shadow)
          @raylib.draw_line(bx + 7, y + 1, bx + 13, y + h / 2 + 1, mark_shadow)
          // Main lines (draw twice for thickness)
          @raylib.draw_line(bx, y + h / 2, bx + 6, y, mark_color)
          @raylib.draw_line(bx + 6, y, bx + 12, y + h / 2, mark_color)
          @raylib.draw_line(bx, y + h / 2 - 1, bx + 6, y + 1, mark_color)
          @raylib.draw_line(bx + 6, y + 1, bx + 12, y + h / 2 - 1, mark_color)
        }
      } else {
        let count = h / 14
        for i in 0..<count {
          let by = y + i * 14 + 2
          @raylib.draw_line(x + w / 2 + 1, by + 1, x + 1, by + 7, mark_shadow)
          @raylib.draw_line(x + 1, by + 7, x + w / 2 + 1, by + 13, mark_shadow)
          @raylib.draw_line(x + w / 2, by, x, by + 6, mark_color)
          @raylib.draw_line(x, by + 6, x + w / 2, by + 12, mark_color)
          @raylib.draw_line(x + w / 2 - 1, by, x + 1, by + 6, mark_color)
          @raylib.draw_line(x + 1, by + 6, x + w / 2 - 1, by + 12, mark_color)
        }
      }
    Dots =>
      // Larger, filled dots with outline
      if horizontal {
        let count = w / 16
        for i in 0..<count {
          let cx = x + 8 + i * 16
          let cy = y + h / 2
          @raylib.draw_circle(cx, cy, 3.5, mark_shadow)
          @raylib.draw_circle(cx, cy, 3.0, mark_color)
        }
      } else {
        let count = h / 16
        for i in 0..<count {
          let cx = x + w / 2
          let cy = y + 8 + i * 16
          @raylib.draw_circle(cx, cy, 3.5, mark_shadow)
          @raylib.draw_circle(cx, cy, 3.0, mark_color)
        }
      }
    Stripes =>
      // Thicker perpendicular stripes (double-line)
      if horizontal {
        let count = w / 12
        for i in 0..<count {
          let sx = x + 6 + i * 12
          @raylib.draw_line(sx + 1, y, sx + 1, y + h, mark_shadow)
          @raylib.draw_line(sx, y, sx, y + h, mark_color)
          @raylib.draw_line(sx + 1, y, sx + 1, y + h, mark_color)
        }
      } else {
        let count = h / 12
        for i in 0..<count {
          let sy = y + 6 + i * 12
          @raylib.draw_line(x, sy + 1, x + w, sy + 1, mark_shadow)
          @raylib.draw_line(x, sy, x + w, sy, mark_color)
          @raylib.draw_line(x, sy + 1, x + w, sy + 1, mark_color)
        }
      }
    Waves =>
      // Thicker wave marks with doubled lines
      if horizontal {
        let count = w / 18
        for i in 0..<count {
          let bx = x + i * 18 + 2
          // Shadow
          @raylib.draw_line(bx + 1, y + h / 2 + 1, bx + 5, y + 2, mark_shadow)
          @raylib.draw_line(bx + 5, y + 2, bx + 9, y + h / 2 + 1, mark_shadow)
          @raylib.draw_line(bx + 9, y + h / 2 + 1, bx + 13, y + h, mark_shadow)
          @raylib.draw_line(bx + 13, y + h, bx + 17, y + h / 2 + 1, mark_shadow)
          // Main + thickness
          @raylib.draw_line(bx, y + h / 2, bx + 4, y + 1, mark_color)
          @raylib.draw_line(bx + 4, y + 1, bx + 8, y + h / 2, mark_color)
          @raylib.draw_line(bx + 8, y + h / 2, bx + 12, y + h - 1, mark_color)
          @raylib.draw_line(bx + 12, y + h - 1, bx + 16, y + h / 2, mark_color)
          @raylib.draw_line(bx, y + h / 2 + 1, bx + 4, y + 2, mark_color)
          @raylib.draw_line(bx + 4, y + 2, bx + 8, y + h / 2 + 1, mark_color)
          @raylib.draw_line(bx + 8, y + h / 2 + 1, bx + 12, y + h, mark_color)
          @raylib.draw_line(bx + 12, y + h, bx + 16, y + h / 2 + 1, mark_color)
        }
      } else {
        let count = h / 18
        for i in 0..<count {
          let by = y + i * 18 + 2
          @raylib.draw_line(x + w / 2 + 1, by + 1, x + 2, by + 5, mark_shadow)
          @raylib.draw_line(x + 2, by + 5, x + w / 2 + 1, by + 9, mark_shadow)
          @raylib.draw_line(x + w / 2, by, x + 1, by + 4, mark_color)
          @raylib.draw_line(x + 1, by + 4, x + w / 2, by + 8, mark_color)
          @raylib.draw_line(x + w / 2, by + 8, x + w - 1, by + 12, mark_color)
          @raylib.draw_line(x + w - 1, by + 12, x + w / 2, by + 16, mark_color)
          @raylib.draw_line(x + w / 2 + 1, by, x + 2, by + 4, mark_color)
          @raylib.draw_line(x + 2, by + 4, x + w / 2 + 1, by + 8, mark_color)
          @raylib.draw_line(x + w / 2 + 1, by + 8, x + w, by + 12, mark_color)
          @raylib.draw_line(x + w, by + 12, x + w / 2 + 1, by + 16, mark_color)
        }
      }
    Diamonds =>
      // Larger diamond shapes with fill
      if horizontal {
        let count = w / 18
        for i in 0..<count {
          let cx = x + 9 + i * 18
          let cy = y + h / 2
          // Shadow
          @raylib.draw_line(cx + 1, cy - 3, cx + 5, cy + 1, mark_shadow)
          @raylib.draw_line(cx + 5, cy + 1, cx + 1, cy + 4, mark_shadow)
          // Diamond outline (doubled for thickness)
          @raylib.draw_line(cx, cy - 3, cx + 4, cy, mark_color)
          @raylib.draw_line(cx + 4, cy, cx, cy + 3, mark_color)
          @raylib.draw_line(cx, cy + 3, cx - 4, cy, mark_color)
          @raylib.draw_line(cx - 4, cy, cx, cy - 3, mark_color)
          @raylib.draw_line(cx, cy - 2, cx + 3, cy, mark_color)
          @raylib.draw_line(cx + 3, cy, cx, cy + 2, mark_color)
          @raylib.draw_line(cx, cy + 2, cx - 3, cy, mark_color)
          @raylib.draw_line(cx - 3, cy, cx, cy - 2, mark_color)
        }
      } else {
        let count = h / 18
        for i in 0..<count {
          let cx = x + w / 2
          let cy = y + 9 + i * 18
          @raylib.draw_line(cx + 1, cy - 3, cx + 4, cy + 1, mark_shadow)
          @raylib.draw_line(cx + 4, cy + 1, cx + 1, cy + 4, mark_shadow)
          @raylib.draw_line(cx, cy - 3, cx + 3, cy, mark_color)
          @raylib.draw_line(cx + 3, cy, cx, cy + 3, mark_color)
          @raylib.draw_line(cx, cy + 3, cx - 3, cy, mark_color)
          @raylib.draw_line(cx - 3, cy, cx, cy - 3, mark_color)
          @raylib.draw_line(cx, cy - 2, cx + 2, cy, mark_color)
          @raylib.draw_line(cx + 2, cy, cx, cy + 2, mark_color)
          @raylib.draw_line(cx, cy + 2, cx - 2, cy, mark_color)
          @raylib.draw_line(cx - 2, cy, cx, cy - 2, mark_color)
        }
      }
    Stars =>
      // Larger star/cross marks with proper 6-point star feel
      if horizontal {
        let count = w / 18
        for i in 0..<count {
          let cx = x + 9 + i * 18
          let cy = y + h / 2
          // Shadow
          @raylib.draw_circle(cx + 1, cy + 1, 2.0, mark_shadow)
          // Cross + diagonal for 8-point star
          @raylib.draw_line(cx - 3, cy, cx + 3, cy, mark_color)
          @raylib.draw_line(cx, cy - 3, cx, cy + 3, mark_color)
          @raylib.draw_line(cx - 2, cy - 2, cx + 2, cy + 2, mark_color)
          @raylib.draw_line(cx + 2, cy - 2, cx - 2, cy + 2, mark_color)
          // Center dot
          @raylib.draw_circle(cx, cy, 1.5, mark_color)
        }
      } else {
        let count = h / 18
        for i in 0..<count {
          let cx = x + w / 2
          let cy = y + 9 + i * 18
          @raylib.draw_circle(cx + 1, cy + 1, 2.0, mark_shadow)
          @raylib.draw_line(cx - 3, cy, cx + 3, cy, mark_color)
          @raylib.draw_line(cx, cy - 3, cx, cy + 3, mark_color)
          @raylib.draw_line(cx - 2, cy - 2, cx + 2, cy + 2, mark_color)
          @raylib.draw_line(cx + 2, cy - 2, cx - 2, cy + 2, mark_color)
          @raylib.draw_circle(cx, cy, 1.5, mark_color)
        }
      }
  }
}

///|
fn draw_lock_icon(x : Int, y : Int) -> Unit {
  // Simple lock icon
  @raylib.draw_rectangle(x, y + 5, 12, 8, @raylib.Color::new(100, 90, 80, 200))
  @raylib.draw_rectangle_lines(x, y + 5, 12, 8, @raylib.Color::new(60, 50, 40, 255))
  // Lock shackle
  @raylib.draw_rectangle_lines(x + 2, y, 8, 7, @raylib.Color::new(60, 50, 40, 255))
}
