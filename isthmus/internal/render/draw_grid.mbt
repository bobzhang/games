///|
fn water_color(depth : Int) -> @raylib.Color {
  if depth <= 1 {
    @types.color_water_shallow
  } else if depth <= 2 {
    @types.color_water_mid
  } else {
    @types.color_water_deep
  }
}

///|
fn land_color(height : Int, sea_level : Int) -> @raylib.Color {
  let above = height - sea_level
  if above <= 1 {
    @types.color_land_low
  } else if above <= 2 {
    @types.color_land_mid
  } else if above <= 3 {
    @types.color_land_high
  } else {
    @types.color_land_peak
  }
}

///|
fn draw_tile(
  x : Int,
  y : Int,
  tile : @types.Tile,
  sea_level : Int,
  frame : Int,
) -> Unit {
  let px = @types.grid_offset_x + x * @types.cell_size
  let py = @types.grid_offset_y + y * @types.cell_size
  let cs = @types.cell_size
  if tile.height <= sea_level {
    // Water tile
    let depth = sea_level - tile.height
    let base = water_color(depth)
    // Slight wave animation
    let wave = Float::from_double(
      @math.sin(Float::from_int(x + frame / 10).to_double() * 0.5),
    )
    let brightness : Float = 1.0 + wave * 0.05
    let r = (Float::from_int(base.r.to_int()) * brightness).to_int()
    let g = (Float::from_int(base.g.to_int()) * brightness).to_int()
    let b = (Float::from_int(base.b.to_int()) * brightness).to_int()
    let color = @raylib.Color::new(
      @types.mini(r, 255),
      @types.mini(g, 255),
      @types.mini(b, 255),
      255,
    )
    @raylib.draw_rectangle(px, py, cs, cs, color)
  } else if tile.is_settlement {
    // Settlement: land background + house
    let lc = land_color(tile.height, sea_level)
    @raylib.draw_rectangle(px, py, cs, cs, lc)
    draw_settlement(px, py, cs)
  } else if tile.is_sand {
    // Sand tile
    @raylib.draw_rectangle(px, py, cs, cs, @types.color_sand)
    // Height indicator
    let h_text = tile.height.to_string()
    @draw.draw_text(
      h_text,
      px + cs / 2 - 4,
      py + cs / 2 - 6,
      12,
      @types.color_bg,
    )
  } else {
    // Regular land
    let lc = land_color(tile.height, sea_level)
    @raylib.draw_rectangle(px, py, cs, cs, lc)
    // Height indicator for higher tiles
    if tile.height > sea_level + 1 {
      let h_text = tile.height.to_string()
      let text_color = @raylib.Color::new(0, 0, 0, 80)
      @draw.draw_text(h_text, px + cs / 2 - 4, py + cs / 2 - 6, 12, text_color)
    }
  }
  // Grid border
  @raylib.draw_rectangle_lines(px, py, cs, cs, @raylib.Color::new(0, 0, 0, 40))
}

///|
fn draw_settlement(px : Int, py : Int, cs : Int) -> Unit {
  let cx = px + cs / 2
  let cy = py + cs / 2
  let size = cs / 3
  // House body
  @raylib.draw_rectangle(
    cx - size,
    cy - size / 2,
    size * 2,
    size + size / 2,
    @types.color_settlement,
  )
  // Roof (triangle)
  let roof_color = @raylib.Color::new(200, 150, 30, 255)
  @raylib.draw_triangle(
    @raylib.Vector2::new(
      Float::from_int(cx - size - 2),
      Float::from_int(cy - size / 2),
    ),
    @raylib.Vector2::new(
      Float::from_int(cx + size + 2),
      Float::from_int(cy - size / 2),
    ),
    @raylib.Vector2::new(Float::from_int(cx), Float::from_int(cy - size - 4)),
    roof_color,
  )
  // Door
  @raylib.draw_rectangle(
    cx - 2,
    cy + 2,
    4,
    size - 2,
    @raylib.Color::new(100, 60, 20, 255),
  )
}

///|
fn draw_grid(game : @types.Game) -> Unit {
  let grid = game.grid
  // Draw all tiles
  for y in 0..<grid.height {
    for x in 0..<grid.width {
      let tile = @types.grid_get(grid, x, y)
      draw_tile(x, y, tile, game.sea_level, game.frame_count)
    }
  }
  // Draw flood preview (tiles that will flood next turn)
  if game.show_flood_preview && game.play_state == Placing {
    let flooding = @terrain.tiles_flooding_next(grid, game.sea_level)
    for i in 0..<flooding.length() {
      let (fx, fy) = @types.index_to_xy(grid, flooding[i])
      let px = @types.grid_offset_x + fx * @types.cell_size
      let py = @types.grid_offset_y + fy * @types.cell_size
      @raylib.draw_rectangle(
        px, py, @types.cell_size, @types.cell_size, @types.color_flood_preview,
      )
    }
  }
  // Draw hover indicator
  if game.play_state == Placing && game.hover_x >= 0 && game.hover_y >= 0 {
    let px = @types.grid_offset_x + game.hover_x * @types.cell_size
    let py = @types.grid_offset_y + game.hover_y * @types.cell_size
    let can_place = @terrain.can_place_sand(
      grid,
      game.hover_x,
      game.hover_y,
      game.sea_level,
    )
    let hover_color = if can_place && game.sand_remaining > 0 {
      @types.color_hover_valid
    } else {
      @types.color_hover_invalid
    }
    @raylib.draw_rectangle(
      px, py, @types.cell_size, @types.cell_size, hover_color,
    )
  }
  // Draw connectivity lines between settlements
  draw_connectivity(game)
}

///|
fn draw_connectivity(game : @types.Game) -> Unit {
  let settlements = @types.settlement_positions(game.grid)
  if settlements.length() < 2 {
    return
  }
  let connected = @terrain.all_settlements_connected(game.grid, game.sea_level)
  let line_color = if connected {
    @types.color_connected
  } else {
    @types.color_disconnected
  }
  // Draw lines between consecutive settlement pairs
  let pair_count = settlements.length() - 1
  for i in 0..<pair_count {
    let (x1, y1) = @types.index_to_xy(game.grid, settlements[i])
    let (x2, y2) = @types.index_to_xy(game.grid, settlements[i + 1])
    let px1 = @types.grid_offset_x +
      x1 * @types.cell_size +
      @types.cell_size / 2
    let py1 = @types.grid_offset_y +
      y1 * @types.cell_size +
      @types.cell_size / 2
    let px2 = @types.grid_offset_x +
      x2 * @types.cell_size +
      @types.cell_size / 2
    let py2 = @types.grid_offset_y +
      y2 * @types.cell_size +
      @types.cell_size / 2
    @raylib.draw_line(px1, py1, px2, py2, line_color)
  }
}
