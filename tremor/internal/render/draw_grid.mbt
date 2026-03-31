///|
fn draw_playing(game : @types.Game) -> Unit {
  match game.level {
    None => ()
    Some(level) => {
      draw_grid(game, level)
      draw_sensor_readings(game)
      if game.show_overlap && game.readings.length() > 1 {
        draw_overlap(game)
      }
      draw_sensors(game)
      draw_hover(game, level)
      draw_guess(game)
      if game.play_state == Complete {
        draw_epicenters(level)
      }
      draw_ui_panel(game, level)
      draw_message(game)
    }
  }
}

///|
fn draw_grid(game : @types.Game, level : @types.Level) -> Unit {
  let _ = game
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  // Draw grid background
  @raylib.draw_rectangle(
    ox,
    oy,
    @types.grid_cols * cs,
    @types.grid_rows * cs,
    @types.color_grid_bg,
  )
  // Draw tiles
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      let tx = ox + col * cs
      let ty = oy + row * cs
      let tile = level.grid[row][col]
      match tile.kind {
        Blocked =>
          @raylib.draw_rectangle(tx + 1, ty + 1, cs - 2, cs - 2, @types.color_blocked)
        Town => {
          @raylib.draw_rectangle(tx + 1, ty + 1, cs - 2, cs - 2, @raylib.Color::new(
              40, 35, 20, 255,
            ))
          // Town indicator - small house shape
          let cx = tx + cs / 2
          let cy = ty + cs / 2
          @raylib.draw_rectangle(
            cx - 8,
            cy - 2,
            16,
            12,
            @types.color_town,
          )
          @raylib.draw_triangle(
            @raylib.Vector2::new(
              Float::from_int(cx - 10),
              Float::from_int(cy - 2),
            ),
            @raylib.Vector2::new(Float::from_int(cx), Float::from_int(cy - 12)),
            @raylib.Vector2::new(
              Float::from_int(cx + 10),
              Float::from_int(cy - 2),
            ),
            @types.color_town,
          )
        }
        Noisy => {
          @raylib.draw_rectangle(tx + 1, ty + 1, cs - 2, cs - 2, @types.color_noisy)
          // Draw noise stripes
          let stripe_color = @raylib.Color::new(100, 60, 85, 255)
          for s in 0..<4 {
            let sy = ty + 5 + s * 12
            @raylib.draw_line_ex(
              @raylib.Vector2::new(Float::from_int(tx + 4), Float::from_int(sy)),
              @raylib.Vector2::new(
                Float::from_int(tx + cs - 4),
                Float::from_int(sy),
              ),
              1.0,
              stripe_color,
            )
          }
        }
        Empty => ()
      }
    }
  }
  // Draw grid lines
  for row in 0..=@types.grid_rows {
    let y = oy + row * cs
    @raylib.draw_line_ex(
      @raylib.Vector2::new(Float::from_int(ox), Float::from_int(y)),
      @raylib.Vector2::new(
        Float::from_int(ox + @types.grid_cols * cs),
        Float::from_int(y),
      ),
      1.0,
      @types.color_grid_line,
    )
  }
  for col in 0..=@types.grid_cols {
    let x = ox + col * cs
    @raylib.draw_line_ex(
      @raylib.Vector2::new(Float::from_int(x), Float::from_int(oy)),
      @raylib.Vector2::new(
        Float::from_int(x),
        Float::from_int(oy + @types.grid_rows * cs),
      ),
      1.0,
      @types.color_grid_line,
    )
  }
}

///|
fn draw_sensors(game : @types.Game) -> Unit {
  for i in 0..<game.sensors.length() {
    let s = game.sensors[i]
    let cx = @types.tile_center_x(s.pos.x)
    let cy = @types.tile_center_y(s.pos.y)
    let color = @types.sensor_color(s.kind)
    match s.kind {
      Broad =>
        // Circle for broad sensor
        @raylib.draw_circle(
          cx.to_int(), cy.to_int(), 14.0, color,
        )
      Precise => {
        // Diamond shape for precise sensor
        let size : Float = 12.0
        @raylib.draw_triangle(
          @raylib.Vector2::new(cx, cy - size),
          @raylib.Vector2::new(cx - size, cy),
          @raylib.Vector2::new(cx + size, cy),
          color,
        )
        @raylib.draw_triangle(
          @raylib.Vector2::new(cx - size, cy),
          @raylib.Vector2::new(cx, cy + size),
          @raylib.Vector2::new(cx + size, cy),
          color,
        )
      }
      Directional => {
        // Wedge shape for directional sensor
        let angle = @types.compass_angle(s.direction)
        let len : Float = 16.0
        let half : Float = @types.pi / 4.0
        let x1 = cx + @types.cosf(angle - half) * len
        let y1 = cy + @types.sinf(angle - half) * len
        let x2 = cx + @types.cosf(angle + half) * len
        let y2 = cy + @types.sinf(angle + half) * len
        @raylib.draw_triangle(
          @raylib.Vector2::new(cx, cy),
          @raylib.Vector2::new(x1, y1),
          @raylib.Vector2::new(x2, y2),
          color,
        )
      }
    }
  }
}

///|
fn draw_sensor_readings(game : @types.Game) -> Unit {
  let cs_f = Float::from_int(@types.cell_size)
  for i in 0..<game.readings.length() {
    let r = game.readings[i]
    let cx = @types.tile_center_x(r.center.x)
    let cy = @types.tile_center_y(r.center.y)
    let color = @types.ring_color(r.kind)
    match r.kind {
      Directional => {
        // Draw wedge
        let center_angle = @types.compass_angle(r.direction)
        let half_angle_rad = r.angle * @types.pi / 360.0
        // Convert to degrees for raylib (start/end angle)
        let start_deg = (center_angle - half_angle_rad) * 180.0 / @types.pi
        let end_deg = (center_angle + half_angle_rad) * 180.0 / @types.pi
        // Outer ring
        @raylib.draw_ring(
          @raylib.Vector2::new(cx, cy),
          r.min_dist * cs_f,
          r.max_dist * cs_f,
          start_deg,
          end_deg,
          36,
          color,
        )
        // Ring outline
        let outline = @raylib.Color::new(
          color.r.to_int(),
          color.g.to_int(),
          color.b.to_int(),
          160,
        )
        @raylib.draw_ring_lines(
          @raylib.Vector2::new(cx, cy),
          r.min_dist * cs_f,
          r.max_dist * cs_f,
          start_deg,
          end_deg,
          36,
          outline,
        )
      }
      _ => {
        // Draw concentric ring (uncertainty band)
        @raylib.draw_ring(
          @raylib.Vector2::new(cx, cy),
          r.min_dist * cs_f,
          r.max_dist * cs_f,
          0.0,
          360.0,
          64,
          color,
        )
        // Ring outlines
        let outline = @raylib.Color::new(
          color.r.to_int(),
          color.g.to_int(),
          color.b.to_int(),
          180,
        )
        @raylib.draw_circle_lines(
          cx.to_int(),
          cy.to_int(),
          r.min_dist * cs_f,
          outline,
        )
        @raylib.draw_circle_lines(
          cx.to_int(),
          cy.to_int(),
          r.max_dist * cs_f,
          outline,
        )
      }
    }
  }
}

///|
fn draw_overlap(game : @types.Game) -> Unit {
  let overlap = @sensors.compute_overlap_tiles(game.readings)
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  for i in 0..<overlap.length() {
    let tile = overlap[i]
    let tx = ox + tile.x * cs
    let ty = oy + tile.y * cs
    @raylib.draw_rectangle(tx + 2, ty + 2, cs - 4, cs - 4, @types.color_overlap)
  }
}

///|
fn draw_hover(game : @types.Game, level : @types.Level) -> Unit {
  if game.play_state != Placing && game.play_state != Guessing {
    return
  }
  match game.hover_tile {
    None => ()
    Some(tile) => {
      let ox = @types.grid_offset_x
      let oy = @types.grid_offset_y
      let cs = @types.cell_size
      let tx = ox + tile.x * cs
      let ty = oy + tile.y * cs
      if game.play_state == Placing {
        let can_place = tile.y >= 0 &&
          tile.y < @types.grid_rows &&
          tile.x >= 0 &&
          tile.x < @types.grid_cols &&
          level.grid[tile.y][tile.x].kind != Blocked
        let color = if can_place {
          @raylib.Color::new(100, 255, 100, 60)
        } else {
          @raylib.Color::new(255, 100, 100, 60)
        }
        @raylib.draw_rectangle(tx + 1, ty + 1, cs - 2, cs - 2, color)
      } else {
        // Guessing mode - crosshair cursor
        let color = @raylib.Color::new(255, 255, 100, 100)
        @raylib.draw_rectangle(tx + 1, ty + 1, cs - 2, cs - 2, color)
        let cx = @types.tile_center_x(tile.x)
        let cy = @types.tile_center_y(tile.y)
        let line_color = @types.color_guess
        @raylib.draw_line_ex(
          @raylib.Vector2::new(cx - 15.0, cy),
          @raylib.Vector2::new(cx + 15.0, cy),
          2.0,
          line_color,
        )
        @raylib.draw_line_ex(
          @raylib.Vector2::new(cx, cy - 15.0),
          @raylib.Vector2::new(cx, cy + 15.0),
          2.0,
          line_color,
        )
      }
    }
  }
}

///|
fn draw_guess(game : @types.Game) -> Unit {
  match game.guess_pos {
    None => ()
    Some(pos) => {
      let cx = @types.tile_center_x(pos.x)
      let cy = @types.tile_center_y(pos.y)
      // Pulsing guess marker
      let pulse : Float = @types.sinf(game.anim_timer * 4.0) * 0.3 + 0.7
      let size : Float = 10.0 + pulse * 5.0
      @raylib.draw_circle(cx.to_int(), cy.to_int(), size, @raylib.fade(
          @types.color_guess, pulse,
        ))
      @raylib.draw_circle_lines(cx.to_int(), cy.to_int(), size + 3.0, @types.color_guess)
    }
  }
}

///|
fn draw_epicenters(level : @types.Level) -> Unit {
  for i in 0..<level.epicenters.length() {
    let e = level.epicenters[i]
    let cx = @types.tile_center_x(e.pos.x)
    let cy = @types.tile_center_y(e.pos.y)
    let color = if e.found {
      @raylib.Color::new(50, 255, 50, 255)
    } else {
      @types.color_epicenter
    }
    // X marker for epicenter
    @raylib.draw_line_ex(
      @raylib.Vector2::new(cx - 12.0, cy - 12.0),
      @raylib.Vector2::new(cx + 12.0, cy + 12.0),
      3.0,
      color,
    )
    @raylib.draw_line_ex(
      @raylib.Vector2::new(cx + 12.0, cy - 12.0),
      @raylib.Vector2::new(cx - 12.0, cy + 12.0),
      3.0,
      color,
    )
    @raylib.draw_circle_lines(cx.to_int(), cy.to_int(), 16.0, color)
  }
}
