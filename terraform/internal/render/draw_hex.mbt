///|
fn draw_hex(
  cx : Float,
  cy : Float,
  size : Float,
  color : @raylib.Color
) -> Unit {
  // Draw a filled hexagon using triangles
  for i in 0..<6 {
    let angle1 = @types.pi / 3.0 * Float::from_int(i) - @types.pi / 6.0
    let angle2 = @types.pi / 3.0 * Float::from_int(i + 1) - @types.pi / 6.0
    let x1 = cx + size * @types.cosf(angle1)
    let y1 = cy + size * @types.sinf(angle1)
    let x2 = cx + size * @types.cosf(angle2)
    let y2 = cy + size * @types.sinf(angle2)
    @raylib.draw_triangle(
      @raylib.Vector2::new(cx, cy),
      @raylib.Vector2::new(x1, y1),
      @raylib.Vector2::new(x2, y2),
      color,
    )
  }
}

///|
fn draw_hex_outline(
  cx : Float,
  cy : Float,
  size : Float,
  color : @raylib.Color
) -> Unit {
  for i in 0..<6 {
    let angle1 = @types.pi / 3.0 * Float::from_int(i) - @types.pi / 6.0
    let angle2 = @types.pi / 3.0 * Float::from_int(i + 1) - @types.pi / 6.0
    let x1 = cx + size * @types.cosf(angle1)
    let y1 = cy + size * @types.sinf(angle1)
    let x2 = cx + size * @types.cosf(angle2)
    let y2 = cy + size * @types.sinf(angle2)
    @raylib.draw_line_ex(
      @raylib.Vector2::new(x1, y1),
      @raylib.Vector2::new(x2, y2),
      1.5,
      color,
    )
  }
}

///|
fn shade_color(base : @raylib.Color, factor : Float) -> @raylib.Color {
  let r = @types.clampf(
    Float::from_int(base.r.to_int()) * factor, 0.0, 255.0,
  )
  let g = @types.clampf(
    Float::from_int(base.g.to_int()) * factor, 0.0, 255.0,
  )
  let b = @types.clampf(
    Float::from_int(base.b.to_int()) * factor, 0.0, 255.0,
  )
  @raylib.Color::new(r.to_int(), g.to_int(), b.to_int(), base.a.to_int())
}

///|
fn alpha_color(base : @raylib.Color, alpha : Int) -> @raylib.Color {
  @raylib.Color::new(
    base.r.to_int(), base.g.to_int(), base.b.to_int(), alpha,
  )
}

///|
fn draw_biome_decoration(
  cx : Float,
  cy : Float,
  biome : @types.BiomeKind,
  time : Float,
  col : Int,
  row : Int
) -> Unit {
  let seed = Float::from_int(col * 17 + row * 31)
  match biome {
    Forest => {
      // Small tree indicators
      let t1x = cx - 6.0 + @types.sinf(seed) * 4.0
      let t1y = cy - 4.0
      @raylib.draw_triangle(
        @raylib.Vector2::new(t1x, t1y - 8.0),
        @raylib.Vector2::new(t1x - 4.0, t1y + 2.0),
        @raylib.Vector2::new(t1x + 4.0, t1y + 2.0),
        @raylib.Color::new(20, 120, 40, 180),
      )
      let t2x = cx + 5.0 + @types.cosf(seed) * 3.0
      let t2y = cy + 2.0
      @raylib.draw_triangle(
        @raylib.Vector2::new(t2x, t2y - 6.0),
        @raylib.Vector2::new(t2x - 3.0, t2y + 2.0),
        @raylib.Vector2::new(t2x + 3.0, t2y + 2.0),
        @raylib.Color::new(25, 140, 50, 160),
      )
    }
    Ocean => {
      // Wave lines
      let wave_y1 = cy - 4.0 + @types.sinf(time * 2.0 + seed) * 2.0
      let wave_y2 = cy + 4.0 + @types.sinf(time * 2.0 + seed + 1.0) * 2.0
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx - 10.0, wave_y1),
        @raylib.Vector2::new(cx + 10.0, wave_y1),
        1.0,
        @raylib.Color::new(80, 160, 255, 100),
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx - 8.0, wave_y2),
        @raylib.Vector2::new(cx + 8.0, wave_y2),
        1.0,
        @raylib.Color::new(80, 160, 255, 80),
      )
    }
    Desert => {
      // Sand dots
      let d1x = cx - 5.0 + @types.sinf(seed * 1.3) * 3.0
      let d1y = cy - 3.0 + @types.cosf(seed * 0.7) * 3.0
      @raylib.draw_circle(
        d1x.to_int(), d1y.to_int(), 1.5,
        @raylib.Color::new(180, 150, 30, 120),
      )
      let d2x = cx + 4.0 + @types.cosf(seed * 1.1) * 3.0
      let d2y = cy + 2.0 + @types.sinf(seed * 0.9) * 3.0
      @raylib.draw_circle(
        d2x.to_int(), d2y.to_int(), 1.5,
        @raylib.Color::new(180, 150, 30, 100),
      )
    }
    Barren => {
      // Subtle texture dot
      let dx = cx + @types.sinf(seed * 2.1) * 5.0
      let dy = cy + @types.cosf(seed * 1.7) * 5.0
      @raylib.draw_circle(
        dx.to_int(), dy.to_int(), 1.0,
        @raylib.Color::new(70, 65, 60, 80),
      )
    }
  }
}

///|
fn draw_locked_indicator(cx : Float, cy : Float) -> Unit {
  // Small lock icon (simplified as a filled square with a circle)
  let size : Float = 4.0
  @raylib.draw_rectangle(
    (cx - size / 2.0).to_int(),
    (cy - size / 2.0 + 1.0).to_int(),
    size.to_int(),
    size.to_int(),
    @types.color_locked,
  )
  @raylib.draw_circle(
    cx.to_int(),
    (cy - size / 2.0).to_int(),
    size * 0.5,
    @types.color_locked,
  )
}

///|
fn draw_grid(game : @types.Game) -> Unit {
  let grid = game.grid
  let w = grid.width
  let h = grid.height
  let time = Float::from_int(game.frame_count) * 0.03
  for row in 0..<h {
    for col in 0..<w {
      let (cx, cy) = @types.hex_to_pixel(col, row)
      let tile = @types.get_tile(grid, col, row)
      let base_color = @types.biome_color(tile.biome)
      // Planet depth shading: tiles near top/bottom are slightly darker (polar regions)
      let row_ratio = Float::from_int(row) / Float::from_int(h - 1)
      let sin_val = @types.sinf(row_ratio * @types.pi)
      let depth_factor : Float = 0.7 + 0.3 * sin_val
      let color = shade_color(base_color, depth_factor)
      // Check if this tile changed during resolve animation
      let idx = @types.grid_index(col, row, w)
      let is_changed = if idx < game.changed_tiles.length() {
        game.changed_tiles[idx]
      } else {
        false
      }
      if is_changed && game.play_state == Resolving {
        // Flash effect during resolution
        let flash = @types.absf(@types.sinf(time * 6.0))
        let flash_color = shade_color(color, 1.0 + flash * 0.5)
        draw_hex(cx, cy, @types.hex_size * 0.92, flash_color)
        // Expanding ring effect
        let ring_size = @types.hex_size * (0.6 + flash * 0.4)
        draw_hex_outline(
          cx, cy, ring_size,
          @raylib.Color::new(255, 255, 255, (flash * 100.0).to_int()),
        )
      } else {
        draw_hex(cx, cy, @types.hex_size * 0.92, color)
      }
      // Biome decoration
      draw_biome_decoration(cx, cy, tile.biome, time, col, row)
      // Locked indicator
      if tile.locked {
        draw_locked_indicator(cx, cy)
      }
      // Grid outline
      let outline_alpha = if tile.biome == Barren { 120 } else { 180 }
      let outline_color = @raylib.Color::new(40, 38, 55, outline_alpha)
      draw_hex_outline(cx, cy, @types.hex_size * 0.92, outline_color)
    }
  }
  // Wrapping visualization: draw faded hexes at edges
  draw_wrap_indicators(game)
  // Hover highlight
  if game.hover_col >= 0 && game.hover_row >= 0 && game.play_state == Painting {
    draw_hover_effect(game, time)
  }
}

///|
fn draw_hover_effect(game : @types.Game, time : Float) -> Unit {
  let (hx, hy) = @types.hex_to_pixel(game.hover_col, game.hover_row)
  let hover_tile = @types.get_tile(
    game.grid, game.hover_col, game.hover_row,
  )
  if !hover_tile.locked && hover_tile.biome == Barren {
    // Preview the selected biome with pulsing alpha
    let preview_color = @types.biome_color_light(game.selected_biome)
    let pulse = @types.sinf(time * 4.0) * 0.2 + 0.5
    let alpha = (pulse * 200.0).to_int()
    let preview = alpha_color(preview_color, alpha)
    draw_hex(hx, hy, @types.hex_size * 0.88, preview)
    // Show biome name near cursor
    let name = @types.biome_name(game.selected_biome)
    let remaining = @types.budget_remaining(
      game.budget, game.selected_biome,
    )
    let label = name + " (" + remaining.to_string() + ")"
    @draw.draw_text(
      label, (hx + 25.0).to_int(), (hy - 10.0).to_int(), 12,
      @types.color_text,
    )
  } else if hover_tile.locked {
    // Red outline for locked tiles
    draw_hex_outline(hx, hy, @types.hex_size * 0.95, @types.color_fail)
  } else {
    // Gray outline for non-barren tiles
    draw_hex_outline(hx, hy, @types.hex_size * 0.95, @types.color_text_dim)
  }
  // White outline on hover
  let hover_pulse = @types.sinf(time * 3.0) * 0.3 + 0.7
  let hover_alpha = (hover_pulse * 255.0).to_int()
  draw_hex_outline(
    hx, hy, @types.hex_size * 0.95,
    @raylib.Color::new(255, 255, 255, hover_alpha),
  )
}

///|
fn draw_wrap_indicators(game : @types.Game) -> Unit {
  let grid = game.grid
  let h = grid.height
  let w = grid.width
  let hex_w = @types.hex_size * @types.sqrtf(3.0)
  // Draw faded copies of edge columns to show wrapping
  for row in 0..<h {
    let x_offset_row = if row % 2 == 1 { hex_w / 2.0 } else { 0.0 }
    let (_, cy) = @types.hex_to_pixel(0, row)
    // Left edge: show column (w-1) faded to the left
    let tile_right = @types.get_tile(grid, w - 1, row)
    let left_x = @types.grid_offset_x + hex_w / 2.0 - hex_w
    let lx = left_x + x_offset_row
    let c1 = @types.biome_color(tile_right.biome)
    let faded1 = alpha_color(c1, 40)
    draw_hex(lx, cy, @types.hex_size * 0.65, faded1)
    draw_hex_outline(lx, cy, @types.hex_size * 0.65, alpha_color(c1, 25))
    // Right edge: show column 0 faded to the right
    let tile_left = @types.get_tile(grid, 0, row)
    let rx = @types.grid_offset_x + Float::from_int(w) * hex_w + x_offset_row +
      hex_w / 2.0
    let c2 = @types.biome_color(tile_left.biome)
    let faded2 = alpha_color(c2, 40)
    draw_hex(rx, cy, @types.hex_size * 0.65, faded2)
    draw_hex_outline(rx, cy, @types.hex_size * 0.65, alpha_color(c2, 25))
  }
}

///|
fn draw_mini_planet(x : Int, y : Int, grid : @types.HexGrid) -> Unit {
  // Draw a tiny circular representation of the planet
  let radius : Float = 35.0
  let cx = Float::from_int(x)
  let cy = Float::from_int(y)
  // Planet body
  @raylib.draw_circle(
    x, y, radius,
    @raylib.Color::new(20, 25, 40, 200),
  )
  // Sample grid to draw colored dots on the planet
  let w = grid.width
  let h = grid.height
  for row in 0..<h {
    for col in 0..<w {
      let tile = @types.get_tile(grid, col, row)
      if tile.biome != Barren {
        // Map grid coords to planet circle
        let angle = Float::from_int(col) / Float::from_int(w) * @types.pi * 2.0
        let row_f = Float::from_int(row) / Float::from_int(h - 1)
        let lat = (row_f - 0.5) * @types.pi
        let px = cx + radius * 0.8 * @types.cosf(angle) * @types.cosf(lat)
        let py = cy + radius * 0.8 * @types.sinf(lat)
        let c = @types.biome_color(tile.biome)
        @raylib.draw_circle(px.to_int(), py.to_int(), 2.0, c)
      }
    }
  }
  // Planet outline
  @raylib.draw_circle_lines(x, y, radius, @types.color_accent)
}
