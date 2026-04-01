///|
fn draw_grid(state : @types.LevelState, frame : Int) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  // Draw grid background
  @raylib.draw_rectangle(
    ox - 2,
    oy - 2,
    @types.grid_cols * ts + 4,
    @types.grid_rows * ts + 4,
    panel_border,
  )
  for y in 0..<@types.grid_rows {
    for x in 0..<@types.grid_cols {
      let px = ox + x * ts
      let py = oy + y * ts
      if state.revealed[y][x] {
        let tile = state.data.grid[y][x]
        let color = tile_color(tile)
        @raylib.draw_rectangle(px, py, ts, ts, color)
        draw_tile_detail(tile, px, py, ts, frame)
      } else {
        @raylib.draw_rectangle(px, py, ts, ts, fog_color)
        // Subtle fog pattern
        if (x + y) % 3 == 0 {
          @raylib.draw_rectangle(
            px + ts / 4,
            py + ts / 4,
            ts / 2,
            ts / 2,
            @raylib.Color::new(25, 30, 50, 180),
          )
        }
      }
      // Grid lines
      @raylib.draw_rectangle_lines(
        px,
        py,
        ts,
        ts,
        @raylib.Color::new(40, 50, 70, 100),
      )
    }
  }
}

///|
fn tile_color(tile : @types.Tile) -> @raylib.Color {
  match tile {
    Ocean => ocean_color
    Land => land_color
    Lighthouse => lighthouse_color
    Reef => reef_color
    Landmark => landmark_color
    Current(_) => current_color
  }
}

///|
fn draw_tile_detail(
  tile : @types.Tile,
  px : Int,
  py : Int,
  ts : Int,
  frame : Int
) -> Unit {
  match tile {
    Lighthouse => {
      // Pulsing glow
      let pulse = @math.sinf(Float::from_int(frame) * 0.1)
      let radius = Float::from_int(ts / 3) + pulse * 4.0
      @raylib.draw_circle(
        px + ts / 2,
        py + ts / 2,
        radius,
        @raylib.Color::new(255, 255, 200, 120),
      )
      @draw.draw_text("L", px + ts / 3, py + ts / 4, 20, @raylib.white)
    }
    Reef =>
      @draw.draw_text(
        "~",
        px + ts / 4,
        py + ts / 4,
        18,
        @raylib.Color::new(255, 100, 100, 200),
      )
    Landmark =>
      @draw.draw_text("*", px + ts / 3, py + ts / 5, 22, @raylib.white)
    Current(dir) => {
      let arrow = match dir {
        North => "^"
        South => "v"
        East => ">"
        West => "<"
      }
      @draw.draw_text(arrow, px + ts / 3, py + ts / 4, 20, @raylib.white)
    }
    Ocean =>
      // Subtle wave pattern
      if (px + frame) % 96 < 48 {
        @raylib.draw_rectangle(px, py, ts, ts, ocean_light)
      }
    Land =>
      // Land texture dots
      @raylib.draw_rectangle(
        px + ts / 4,
        py + ts / 4,
        3,
        3,
        @raylib.Color::new(60, 110, 50, 200),
      )
  }
}

///|
fn draw_ship(state : @types.LevelState, frame : Int) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let sx = ox + state.ship.pos.x * ts + ts / 2
  let sy = oy + state.ship.pos.y * ts + ts / 2
  // Ship body - triangle pointing in heading direction
  let bob = @math.sinf(Float::from_int(frame) * 0.08) * 2.0
  let fsy = Float::from_int(sy) + bob
  let r : Float = Float::from_int(ts) * 0.35
  let heading = state.ship.heading
  // Draw ship as a triangle
  let cos_h = @math.cosf(heading)
  let sin_h = @math.sinf(heading)
  let fsx = Float::from_int(sx)
  let tip_x = fsx + sin_h * r
  let tip_y = fsy - cos_h * r
  let pi = Float::from_double(@math.PI)
  let left_x = fsx + @math.sinf(heading + pi * 0.75) * r * 0.7
  let left_y = fsy - @math.cosf(heading + pi * 0.75) * r * 0.7
  let right_x = fsx + @math.sinf(heading - pi * 0.75) * r * 0.7
  let right_y = fsy - @math.cosf(heading - pi * 0.75) * r * 0.7
  @raylib.draw_triangle(
    @raylib.Vector2::new(tip_x, tip_y),
    @raylib.Vector2::new(left_x, left_y),
    @raylib.Vector2::new(right_x, right_y),
    ship_color,
  )
  // Small glow
  @raylib.draw_circle(
    sx,
    sy,
    3.0,
    @raylib.Color::new(255, 220, 100, 150),
  )
}
