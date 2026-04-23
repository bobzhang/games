///|
pub fn draw_grid(game : @types.Game) -> Unit {
  let g = game.grid
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  for r in 0..<g.height {
    for c in 0..<g.width {
      let tile = @types.grid_get(g, c, r)
      let x = ox + c * cs
      let y = oy + r * cs
      // Draw terrain base with height shading
      let base_color = @types.height_color(tile.height)
      @raylib.draw_rectangle(x, y, cs, cs, base_color)
      // Draw height contour lines
      if tile.height > 0 {
        let contour_alpha = 40 + tile.height * 30
        let contour_color = @raylib.Color::new(200, 200, 180, contour_alpha)
        for h in 0..<tile.height {
          let inset = (h + 1) * 4
          @raylib.draw_rectangle_lines(
            x + inset,
            y + inset,
            cs - inset * 2,
            cs - inset * 2,
            contour_color,
          )
        }
      }
      // Draw weather state overlay
      draw_weather_icon(tile.weather, x, y, cs, game.frame_count)
      // Draw target indicator
      if tile.is_target {
        draw_target_indicator(tile, x, y, cs, game.frame_count)
      }
      // Draw grid lines
      @raylib.draw_rectangle_lines(
        x,
        y,
        cs,
        cs,
        @raylib.Color::new(60, 70, 80, 120),
      )
    }
  }
  // Draw placed sources
  draw_sources(game)
  // Draw cursor highlight if placing
  if game.play_state == Placing {
    draw_cursor(game)
  }
}

///|
fn draw_weather_icon(
  weather : @types.WeatherState,
  x : Int,
  y : Int,
  cs : Int,
  frame : Int,
) -> Unit {
  let cx = x + cs / 2
  let cy = y + cs / 2
  let time = Float::from_int(frame) * 0.05
  match weather_art(weather) {
    Some(texture) => {
      let bob = if weather == Cloudy || weather == Windy {
        @types.sinf(time) * 2.0
      } else {
        0.0
      }
      let rotation = if weather == Sunny {
        time * 6.0
      } else if weather == Windy {
        @types.sinf(time * 2.0) * 3.0
      } else {
        0.0
      }
      let alpha = if weather == Stormy && frame % 30 < 5 { 255 } else { 230 }
      draw_art_fit(
        texture,
        Float::from_int(cx),
        Float::from_int(cy) + bob,
        Float::from_int(cs) * 0.72,
        Float::from_int(cs) * 0.72,
        rotation,
        @raylib.Color::new(255, 255, 255, alpha),
      )
      return
    }
    None => ()
  }
  match weather {
    Clear => ()
    Sunny => {
      // Sun rays
      let col = @types.color_sunny
      @raylib.draw_circle(
        cx,
        cy,
        10.0,
        @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 180),
      )
      // Animated rays
      for i in 0..<8 {
        let angle = Float::from_int(i) * 0.785 + time
        let dx = @types.cosf(angle) * 16.0
        let dy = @types.sinf(angle) * 16.0
        let dx2 = @types.cosf(angle) * 22.0
        let dy2 = @types.sinf(angle) * 22.0
        @raylib.draw_line(
          cx + dx.to_int(),
          cy + dy.to_int(),
          cx + dx2.to_int(),
          cy + dy2.to_int(),
          col,
        )
      }
    }
    Rainy => {
      // Rain drops
      let col = @types.color_rainy
      for i in 0..<3 {
        let fi = Float::from_int(i)
        let drop_x = cx - 8 + (fi * 8.0).to_int()
        let drop_y_offset = @types.sinf(time * 2.0 + fi * 1.5) * 6.0
        let drop_y = cy - 5 + drop_y_offset.to_int()
        @raylib.draw_line(drop_x, drop_y, drop_x, drop_y + 8, col)
        @raylib.draw_circle(drop_x, drop_y + 9, 2.0, col)
      }
    }
    Cloudy => {
      // Cloud puff
      let col = @types.color_cloudy
      let bob = @types.sinf(time) * 2.0
      let by = cy - 4 + bob.to_int()
      @raylib.draw_circle(cx - 8, by + 2, 8.0, col)
      @raylib.draw_circle(cx, by - 2, 10.0, col)
      @raylib.draw_circle(cx + 8, by + 2, 8.0, col)
    }
    Windy => {
      // Wind arrows
      let col = @types.color_windy
      let shift = @types.sinf(time * 3.0) * 4.0
      for i in 0..<3 {
        let fi = Float::from_int(i)
        let ly = cy - 8 + (fi * 8.0).to_int()
        let lx1 = cx - 12 + shift.to_int()
        let lx2 = cx + 8 + shift.to_int()
        @raylib.draw_line(lx1, ly, lx2, ly, col)
        // Arrow head
        @raylib.draw_line(lx2, ly, lx2 - 4, ly - 3, col)
        @raylib.draw_line(lx2, ly, lx2 - 4, ly + 3, col)
      }
    }
    Stormy => {
      // Storm: cloud + lightning
      let col = @types.color_stormy
      let flash = if frame % 30 < 5 { 255 } else { 180 }
      let flash_col = @raylib.Color::new(
        col.r.to_int(),
        col.g.to_int(),
        col.b.to_int(),
        flash,
      )
      // Cloud base
      @raylib.draw_circle(cx - 6, cy - 8, 7.0, @types.color_cloudy)
      @raylib.draw_circle(cx + 4, cy - 6, 8.0, @types.color_cloudy)
      // Lightning bolt
      @raylib.draw_line(cx, cy - 2, cx - 4, cy + 6, flash_col)
      @raylib.draw_line(cx - 4, cy + 6, cx + 2, cy + 4, flash_col)
      @raylib.draw_line(cx + 2, cy + 4, cx - 2, cy + 14, flash_col)
      // Rain drops
      @raylib.draw_line(cx - 10, cy + 2, cx - 10, cy + 8, @types.color_rainy)
      @raylib.draw_line(cx + 10, cy, cx + 10, cy + 6, @types.color_rainy)
    }
  }
}

///|
fn draw_target_indicator(
  tile : @types.Tile,
  x : Int,
  y : Int,
  cs : Int,
  frame : Int,
) -> Unit {
  let pulse = @types.sinf(Float::from_int(frame) * 0.08) * 0.3 + 0.7
  let alpha = (pulse * 200.0).to_int()
  let met = tile.weather == tile.target_weather
  let ring_color = if met {
    @raylib.Color::new(0, 255, 0, alpha)
  } else {
    @raylib.Color::new(255, 255, 0, alpha)
  }
  // Corner brackets
  let sz = 8
  // Top-left
  @raylib.draw_line(x + 2, y + 2, x + sz, y + 2, ring_color)
  @raylib.draw_line(x + 2, y + 2, x + 2, y + sz, ring_color)
  // Top-right
  @raylib.draw_line(x + cs - 2, y + 2, x + cs - sz, y + 2, ring_color)
  @raylib.draw_line(x + cs - 2, y + 2, x + cs - 2, y + sz, ring_color)
  // Bottom-left
  @raylib.draw_line(x + 2, y + cs - 2, x + sz, y + cs - 2, ring_color)
  @raylib.draw_line(x + 2, y + cs - 2, x + 2, y + cs - sz, ring_color)
  // Bottom-right
  @raylib.draw_line(x + cs - 2, y + cs - 2, x + cs - sz, y + cs - 2, ring_color)
  @raylib.draw_line(x + cs - 2, y + cs - 2, x + cs - 2, y + cs - sz, ring_color)
  // Target weather label (small, at bottom)
  let label = @types.weather_name(tile.target_weather)
  let lw = @draw.measure_text(label, 10)
  let wcol = @types.weather_color(tile.target_weather)
  @draw.draw_text(
    label,
    x + (cs - lw) / 2,
    y + cs - 14,
    10,
    if met {
      @raylib.Color::new(0, 255, 0, 200)
    } else {
      @raylib.Color::new(wcol.r.to_int(), wcol.g.to_int(), wcol.b.to_int(), 200)
    },
  )
}

///|
fn draw_sources(game : @types.Game) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  for i in 0..<game.placed_sources.length() {
    let src = game.placed_sources[i]
    let x = ox + src.col * cs
    let y = oy + src.row * cs
    let col = @types.source_color(src.kind)
    // Draw source marker: generated icon with outlined diamond
    let cx_pos = x + cs / 2
    let cy_pos = y + cs / 2
    let sz = cs / 3
    match source_art(src.kind) {
      Some(texture) =>
        draw_art_fit(
          texture,
          Float::from_int(cx_pos),
          Float::from_int(cy_pos),
          Float::from_int(cs) * 0.62,
          Float::from_int(cs) * 0.62,
          0.0,
          @raylib.white,
        )
      None => ()
    }
    @raylib.draw_line(cx_pos, cy_pos - sz, cx_pos + sz, cy_pos, col)
    @raylib.draw_line(cx_pos + sz, cy_pos, cx_pos, cy_pos + sz, col)
    @raylib.draw_line(cx_pos, cy_pos + sz, cx_pos - sz, cy_pos, col)
    @raylib.draw_line(cx_pos - sz, cy_pos, cx_pos, cy_pos - sz, col)
    // Source label
    let label = @types.source_name(src.kind)
    let lw = @draw.measure_text(label, 10)
    @draw.draw_text(label, x + (cs - lw) / 2, y + 2, 10, col)
    // Wind direction arrow for wind sources
    if src.kind == Wind {
      let dx = @types.wind_dir_dx(src.wind_dir)
      let dy = @types.wind_dir_dy(src.wind_dir)
      let ax = cx_pos + dx * 18
      let ay = cy_pos + dy * 18
      @raylib.draw_line(cx_pos, cy_pos, ax, ay, col)
      @raylib.draw_circle(ax, ay, 3.0, col)
    }
  }
}

///|
fn draw_cursor(game : @types.Game) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  let x = ox + game.cursor_col * cs
  let y = oy + game.cursor_row * cs
  let pulse = @types.sinf(Float::from_int(game.frame_count) * 0.1) * 0.3 + 0.7
  let alpha = (pulse * 180.0).to_int()
  // Determine cursor color based on selected source
  let col = if game.available_sources.length() > 0 &&
    game.selected_source < game.available_sources.length() {
    let (kind, _count) = game.available_sources[game.selected_source]
    let sc = @types.source_color(kind)
    @raylib.Color::new(sc.r.to_int(), sc.g.to_int(), sc.b.to_int(), alpha)
  } else {
    @raylib.Color::new(255, 255, 255, alpha)
  }
  @raylib.draw_rectangle_lines(x - 1, y - 1, cs + 2, cs + 2, col)
  @raylib.draw_rectangle_lines(x - 2, y - 2, cs + 4, cs + 4, col)
}
