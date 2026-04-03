///|
fn draw_fog_overlay(state : @types.LevelState, frame : Int) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  // Draw animated fog particles over unrevealed tiles
  for y in 0..<@types.grid_rows {
    for x in 0..<@types.grid_cols {
      if !state.revealed[y][x] {
        let px = ox + x * ts
        let py = oy + y * ts
        // Drifting fog wisps
        let drift_x = @math.sinf(
            Float::from_int(frame + x * 17 + y * 31) * 0.03,
          ) *
          6.0
        let drift_y = @math.cosf(
            Float::from_int(frame + x * 23 + y * 13) * 0.02,
          ) *
          4.0
        let wisp_x = Float::from_int(px + ts / 2) + drift_x
        let wisp_y = Float::from_int(py + ts / 2) + drift_y
        let alpha_mod = @math.sinf(
            Float::from_int(frame + x * 7 + y * 11) * 0.04,
          ) *
          30.0 +
          40.0
        let alpha = alpha_mod.to_int()
        let clamped = if alpha < 0 {
          0
        } else if alpha > 80 {
          80
        } else {
          alpha
        }
        @raylib.draw_circle(
          wisp_x.to_int(),
          wisp_y.to_int(),
          8.0,
          @raylib.Color::new(30, 40, 60, clamped),
        )
      }
    }
  }
}

///|
fn draw_water_ripples(state : @types.LevelState, frame : Int) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let ship_x = state.ship.pos.x
  let ship_y = state.ship.pos.y
  // Draw ripple rings around ship on revealed ocean tiles
  for dy in -2..<=2 {
    for dx in -2..<=2 {
      let gx = ship_x + dx
      let gy = ship_y + dy
      if @types.in_bounds(gx, gy) && state.revealed[gy][gx] {
        if state.data.grid[gy][gx] is Ocean {
          let dist = dx * dx + dy * dy
          if dist > 0 && dist <= 4 {
            let px = ox + gx * ts + ts / 2
            let py = oy + gy * ts + ts / 2
            let phase = Float::from_int(frame - dist * 8) * 0.12
            let ripple_r = @math.sinf(phase)
            if ripple_r > 0.0 {
              let radius = Float::from_int(ts / 4) * ripple_r
              let alpha : Float = (1.0 - ripple_r) * 60.0
              @raylib.draw_circle_lines(
                px,
                py,
                radius,
                @raylib.Color::new(100, 150, 200, alpha.to_int()),
              )
            }
          }
        }
      }
    }
  }
}

///|
fn draw_minimap(state : @types.LevelState) -> Unit {
  let mx = @types.screen_width - 145
  let my = @types.screen_height - 135
  let cell = 10
  // Border
  @raylib.draw_rectangle(mx - 3, my - 3, 126, 106, panel_border)
  @raylib.draw_rectangle(mx - 1, my - 1, 122, 102, panel_bg)
  // Mini title
  @draw.draw_text("Map", mx + 40, my - 20, 14, text_dim)
  for y in 0..<@types.grid_rows {
    for x in 0..<@types.grid_cols {
      let px = mx + x * cell
      let py = my + y * cell
      if state.revealed[y][x] {
        let tile = state.data.grid[y][x]
        let color = match tile {
          Ocean => @raylib.Color::new(40, 70, 130, 200)
          Land => @raylib.Color::new(70, 120, 50, 200)
          Lighthouse => @raylib.Color::new(255, 255, 80, 255)
          Reef => @raylib.Color::new(180, 50, 50, 200)
          Landmark => @raylib.Color::new(80, 180, 200, 200)
          Current(_) => @raylib.Color::new(60, 160, 230, 200)
        }
        @raylib.draw_rectangle(px, py, cell, cell, color)
      } else {
        @raylib.draw_rectangle(
          px,
          py,
          cell,
          cell,
          @raylib.Color::new(15, 18, 30, 200),
        )
      }
    }
  }
  // Ship position on minimap
  let sx = mx + state.ship.pos.x * cell
  let sy = my + state.ship.pos.y * cell
  @raylib.draw_rectangle(
    sx + 1,
    sy + 1,
    cell - 2,
    cell - 2,
    @raylib.Color::new(255, 200, 50, 255),
  )
}
