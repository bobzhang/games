///|
fn draw_playing(game : @types.Game) -> Unit {
  let level = game.levels[game.current_level]
  draw_grid_background()
  draw_filled_tiles(game, level)
  draw_holes(game, level)
  draw_placed_tiles_validation(game, level)
  draw_hover_preview(game, level)
  draw_symmetry_indicator(game, level)
  draw_palette(game)
  draw_game_hud(game, level)
  // Message
  if game.message_timer > 0.0 {
    let w = @types.screen_width
    let tw = @draw.measure_text(game.message, 24)
    @draw.draw_text(
      game.message,
      (w - tw) / 2,
      @types.screen_height - 60,
      24,
      @types.color_title_accent,
    )
  }
}

///|
fn draw_grid_background() -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  let gw = @types.grid_cols * cs
  let gh = @types.grid_rows * cs
  // Grid background
  @raylib.draw_rectangle(ox - 4, oy - 4, gw + 8, gh + 8, @types.color_grid_bg)
  // Grid lines
  for i in 0..=@types.grid_cols {
    let x = ox + i * cs
    @raylib.draw_line(x, oy, x, oy + gh, @types.color_grid_line)
  }
  for i in 0..=@types.grid_rows {
    let y = oy + i * cs
    @raylib.draw_line(ox, y, ox + gw, y, @types.color_grid_line)
  }
}

///|
fn draw_filled_tiles(game : @types.Game, level : @types.Level) -> Unit {
  let grid = level.grid
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  for y in 0..<grid.height {
    for x in 0..<grid.width {
      if @types.is_hole(grid, @types.vec2i(x, y)) {
        continue
      }
      match @types.get_tile(grid, x, y) {
        Some(tile) => {
          let px = ox + x * cs
          let py = oy + y * cs
          draw_tile_at(tile, px, py, cs, 255)
        }
        None => ()
      }
    }
  }
  // Draw placed tiles
  for i in 0..<game.placed_tiles.length() {
    let (pos, tile) = game.placed_tiles[i]
    let px = ox + pos.x * cs
    let py = oy + pos.y * cs
    draw_tile_at(tile, px, py, cs, 255)
  }
}

///|
fn draw_tile_at(
  tile : @types.Tile,
  px : Int,
  py : Int,
  cs : Int,
  alpha : Int
) -> Unit {
  let color = @types.tile_color_to_raylib(tile.color)
  let r = color.r.to_int()
  let g = color.g.to_int()
  let b = color.b.to_int()
  let c = @raylib.Color::new(r, g, b, alpha)
  let cx = Float::from_int(px + cs / 2)
  let cy = Float::from_int(py + cs / 2)
  let half = Float::from_int(cs) / 2.0 - 3.0
  match tile.shape {
    Square => {
      @raylib.draw_rectangle(px + 2, py + 2, cs - 4, cs - 4, c)
    }
    Circle => {
      @raylib.draw_circle(cx.to_int(), cy.to_int(), half, c)
    }
    Diamond => {
      // Draw diamond as rotated square using lines/triangles
      let top_x = cx
      let top_y = cy - half
      let right_x = cx + half
      let right_y = cy
      let bottom_x = cx
      let bottom_y = cy + half
      let left_x = cx - half
      let left_y = cy
      @raylib.draw_triangle(
        @raylib.Vector2::new(top_x, top_y),
        @raylib.Vector2::new(left_x, left_y),
        @raylib.Vector2::new(bottom_x, bottom_y),
        c,
      )
      @raylib.draw_triangle(
        @raylib.Vector2::new(top_x, top_y),
        @raylib.Vector2::new(bottom_x, bottom_y),
        @raylib.Vector2::new(right_x, right_y),
        c,
      )
    }
    Cross => {
      let arm = (half * 0.35).to_int()
      let arm_f = Float::from_int(arm)
      // Horizontal bar
      @raylib.draw_rectangle(
        (cx - half).to_int(),
        (cy - arm_f).to_int(),
        (half * 2.0).to_int(),
        arm * 2,
        c,
      )
      // Vertical bar
      @raylib.draw_rectangle(
        (cx - arm_f).to_int(),
        (cy - half).to_int(),
        arm * 2,
        (half * 2.0).to_int(),
        c,
      )
    }
    Triangle => {
      draw_oriented_triangle(cx, cy, half, tile.orientation, c)
    }
    Arrow => {
      draw_oriented_arrow(cx, cy, half, tile.orientation, c)
    }
  }
}

///|
fn draw_oriented_triangle(
  cx : Float,
  cy : Float,
  half : Float,
  orient : @types.Orientation,
  color : @raylib.Color
) -> Unit {
  let (p1, p2, p3) = match orient {
    N => (
      @raylib.Vector2::new(cx, cy - half),
      @raylib.Vector2::new(cx - half, cy + half),
      @raylib.Vector2::new(cx + half, cy + half),
    )
    E => (
      @raylib.Vector2::new(cx + half, cy),
      @raylib.Vector2::new(cx - half, cy - half),
      @raylib.Vector2::new(cx - half, cy + half),
    )
    S => (
      @raylib.Vector2::new(cx, cy + half),
      @raylib.Vector2::new(cx + half, cy - half),
      @raylib.Vector2::new(cx - half, cy - half),
    )
    W => (
      @raylib.Vector2::new(cx - half, cy),
      @raylib.Vector2::new(cx + half, cy + half),
      @raylib.Vector2::new(cx + half, cy - half),
    )
  }
  @raylib.draw_triangle(p1, p2, p3, color)
}

///|
fn draw_oriented_arrow(
  cx : Float,
  cy : Float,
  half : Float,
  orient : @types.Orientation,
  color : @raylib.Color
) -> Unit {
  let shaft_w = half * 0.3
  match orient {
    N => {
      // Shaft
      @raylib.draw_rectangle(
        (cx - shaft_w).to_int(),
        cy.to_int(),
        (shaft_w * 2.0).to_int(),
        half.to_int(),
        color,
      )
      // Head
      @raylib.draw_triangle(
        @raylib.Vector2::new(cx, cy - half),
        @raylib.Vector2::new(cx - half * 0.7, cy),
        @raylib.Vector2::new(cx + half * 0.7, cy),
        color,
      )
    }
    E => {
      @raylib.draw_rectangle(
        (cx - half).to_int(),
        (cy - shaft_w).to_int(),
        half.to_int(),
        (shaft_w * 2.0).to_int(),
        color,
      )
      @raylib.draw_triangle(
        @raylib.Vector2::new(cx + half, cy),
        @raylib.Vector2::new(cx, cy + half * 0.7),
        @raylib.Vector2::new(cx, cy - half * 0.7),
        color,
      )
    }
    S => {
      @raylib.draw_rectangle(
        (cx - shaft_w).to_int(),
        (cy - half).to_int(),
        (shaft_w * 2.0).to_int(),
        half.to_int(),
        color,
      )
      @raylib.draw_triangle(
        @raylib.Vector2::new(cx, cy + half),
        @raylib.Vector2::new(cx + half * 0.7, cy),
        @raylib.Vector2::new(cx - half * 0.7, cy),
        color,
      )
    }
    W => {
      @raylib.draw_rectangle(
        cx.to_int(),
        (cy - shaft_w).to_int(),
        half.to_int(),
        (shaft_w * 2.0).to_int(),
        color,
      )
      @raylib.draw_triangle(
        @raylib.Vector2::new(cx - half, cy),
        @raylib.Vector2::new(cx, cy - half * 0.7),
        @raylib.Vector2::new(cx, cy + half * 0.7),
        color,
      )
    }
  }
}

///|
fn draw_holes(game : @types.Game, level : @types.Level) -> Unit {
  let grid = level.grid
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  for i in 0..<grid.holes.length() {
    let h = grid.holes[i]
    // Check if already filled by player
    let mut filled = false
    for j in 0..<game.placed_tiles.length() {
      let (pos, _) = game.placed_tiles[j]
      if @types.vec2i_eq(pos, h) {
        filled = true
        break
      }
    }
    if !filled {
      let px = ox + h.x * cs
      let py = oy + h.y * cs
      @raylib.draw_rectangle(px + 1, py + 1, cs - 2, cs - 2, @types.color_hole)
      @raylib.draw_rectangle_lines(
        px + 1,
        py + 1,
        cs - 2,
        cs - 2,
        @types.color_hole_border,
      )
      // Question mark
      let qw = @draw.measure_text("?", 20)
      @draw.draw_text(
        "?",
        px + (cs - qw) / 2,
        py + cs / 2 - 10,
        20,
        @types.color_hole_border,
      )
    }
  }
  ignore(game)
}

///|
fn draw_placed_tiles_validation(
  game : @types.Game,
  level : @types.Level
) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  for i in 0..<game.placed_tiles.length() {
    let (pos, tile) = game.placed_tiles[i]
    let valid = @symmetry.validate_placement(
      level.grid, pos, tile, level.symmetry,
    )
    let glow_color = if valid {
      @types.color_correct_glow
    } else {
      @types.color_wrong_glow
    }
    let px = ox + pos.x * cs
    let py = oy + pos.y * cs
    @raylib.draw_rectangle_lines(px, py, cs, cs, glow_color)
    @raylib.draw_rectangle_lines(px + 1, py + 1, cs - 2, cs - 2, glow_color)
  }
}

///|
fn draw_hover_preview(game : @types.Game, level : @types.Level) -> Unit {
  match game.hover_cell {
    None => ()
    Some(cell) => {
      // Check it's a hole and not filled
      if !(@types.is_hole(level.grid, cell)) {
        return
      }
      let mut already_filled = false
      for i in 0..<game.placed_tiles.length() {
        let (pos, _) = game.placed_tiles[i]
        if @types.vec2i_eq(pos, cell) {
          already_filled = true
          break
        }
      }
      if already_filled {
        return
      }
      let ox = @types.grid_offset_x
      let oy = @types.grid_offset_y
      let cs = @types.cell_size
      let px = ox + cell.x * cs
      let py = oy + cell.y * cs
      // Draw preview tile semi-transparent
      let preview = @types.new_tile(
        game.selected_color, game.selected_shape, game.selected_orientation,
      )
      draw_tile_at(preview, px, py, cs, 120)
      @raylib.draw_rectangle_lines(px, py, cs, cs, @types.color_hover)
    }
  }
}

///|
fn draw_symmetry_indicator(game : @types.Game, level : @types.Level) -> Unit {
  if !game.show_symmetry_hint {
    return
  }
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  let gw = @types.grid_cols * cs
  let gh = @types.grid_rows * cs
  let pulse = sinf(Float::from_int(game.frame_count) * 0.08)
  let alpha_f : Float = 140.0 + pulse * 40.0
  let alpha = alpha_f.to_int()
  let indicator_color = @raylib.Color::new(255, 255, 100, alpha)
  match level.symmetry {
    MirrorH => {
      // Horizontal line at center
      let cy = oy + gh / 2
      @raylib.draw_line_ex(
        @raylib.Vector2::new(Float::from_int(ox), Float::from_int(cy)),
        @raylib.Vector2::new(Float::from_int(ox + gw), Float::from_int(cy)),
        3.0,
        indicator_color,
      )
    }
    MirrorV => {
      let cx = ox + gw / 2
      @raylib.draw_line_ex(
        @raylib.Vector2::new(Float::from_int(cx), Float::from_int(oy)),
        @raylib.Vector2::new(Float::from_int(cx), Float::from_int(oy + gh)),
        3.0,
        indicator_color,
      )
    }
    MirrorD => {
      @raylib.draw_line_ex(
        @raylib.Vector2::new(Float::from_int(ox), Float::from_int(oy)),
        @raylib.Vector2::new(
          Float::from_int(ox + gw),
          Float::from_int(oy + gh),
        ),
        3.0,
        indicator_color,
      )
    }
    Rotate2 | Rotate4 => {
      let cx = Float::from_int(ox + gw / 2)
      let cy = Float::from_int(oy + gh / 2)
      @raylib.draw_circle(cx.to_int(), cy.to_int(), 8.0, indicator_color)
      @raylib.draw_ring(
        @raylib.Vector2::new(cx, cy),
        14.0,
        18.0,
        0.0,
        360.0,
        32,
        indicator_color,
      )
    }
    Glide => {
      // Show shift + mirror
      let cy = oy + gh / 2
      @raylib.draw_line_ex(
        @raylib.Vector2::new(Float::from_int(ox), Float::from_int(cy)),
        @raylib.Vector2::new(Float::from_int(ox + gw), Float::from_int(cy)),
        2.0,
        indicator_color,
      )
      // Draw shift arrows
      for i in 0..<4 {
        let ax = Float::from_int(ox + i * cs * 2 + cs)
        let ay = Float::from_int(cy)
        @raylib.draw_triangle(
          @raylib.Vector2::new(ax + 10.0, ay),
          @raylib.Vector2::new(ax, ay - 6.0),
          @raylib.Vector2::new(ax, ay + 6.0),
          indicator_color,
        )
      }
    }
  }
}
