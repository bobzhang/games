///|
fn draw_compass(state : @types.LevelState, frame : Int) -> Unit {
  let cx = 160
  let cy = 200
  let radius : Float = 80.0
  // Background circle
  @raylib.draw_circle(cx, cy, radius + 8.0, panel_border)
  @raylib.draw_circle(cx, cy, radius + 4.0, compass_bg)
  @raylib.draw_circle(cx, cy, radius, @raylib.Color::new(20, 25, 45, 255))
  // Ring markings
  let ring_r = radius - 5.0
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy)
  let pi = Float::from_double(@math.PI)
  for i in 0..<36 {
    let angle = Float::from_int(i) * pi * 2.0 / 36.0
    let inner_r = if i % 9 == 0 { ring_r - 12.0 } else { ring_r - 6.0 }
    let x1 = fcx + @math.sinf(angle) * inner_r
    let y1 = fcy - @math.cosf(angle) * inner_r
    let x2 = fcx + @math.sinf(angle) * ring_r
    let y2 = fcy - @math.cosf(angle) * ring_r
    let color = if i % 9 == 0 { compass_ring } else { text_dim }
    @raylib.draw_line_ex(
      @raylib.Vector2::new(x1, y1),
      @raylib.Vector2::new(x2, y2),
      2.0,
      color,
    )
  }
  // Cardinal labels
  @draw.draw_text("N", cx - 5, cy - 75, 16, text_bright)
  @draw.draw_text("S", cx - 4, cy + 60, 16, text_dim)
  @draw.draw_text("E", cx + 60, cy - 6, 16, text_dim)
  @draw.draw_text("W", cx - 72, cy - 6, 16, text_dim)
  // Needle pointing toward lighthouse
  let heading = state.ship.heading
  let needle_len = radius * 0.65
  let nx = fcx + @math.sinf(heading) * needle_len
  let ny = fcy - @math.cosf(heading) * needle_len
  // Needle body (red triangle)
  let perp_x = @math.cosf(heading) * 4.0
  let perp_y = @math.sinf(heading) * 4.0
  @raylib.draw_triangle(
    @raylib.Vector2::new(nx, ny),
    @raylib.Vector2::new(fcx - perp_x, fcy - perp_y),
    @raylib.Vector2::new(fcx + perp_x, fcy + perp_y),
    compass_needle,
  )
  // Tail (white)
  let tail_x = fcx - @math.sinf(heading) * needle_len * 0.4
  let tail_y = fcy + @math.cosf(heading) * needle_len * 0.4
  @raylib.draw_triangle(
    @raylib.Vector2::new(tail_x, tail_y),
    @raylib.Vector2::new(fcx + perp_x, fcy + perp_y),
    @raylib.Vector2::new(fcx - perp_x, fcy - perp_y),
    @raylib.Color::new(200, 200, 220, 200),
  )
  // Center dot
  @raylib.draw_circle(cx, cy, 5.0, compass_ring)
  @raylib.draw_circle(cx, cy, 3.0, @raylib.Color::new(40, 35, 30, 255))
  // Bearing text
  let degrees = @types.bearing_to_degrees(heading)
  let bearing_str = "\{degrees.to_int()}"
  @draw.draw_text(bearing_str, cx - 15, cy + 90, 20, text_bright)
  // Compass beep indicator
  if state.compass_beep {
    let blink = frame % 30 < 15
    if blink {
      let land_dir = @types.direction_name(state.near_land_dir)
      @draw.draw_text("! Land \{land_dir}", cx - 35, cy + 115, 16, hp_warn)
    }
  }
}
