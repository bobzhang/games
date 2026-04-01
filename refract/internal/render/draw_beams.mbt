///|
fn draw_beams(game : @types.Game) -> Unit {
  let cs = @types.cell_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let half = cs / 2
  let time = Float::from_int(game.frame_count) * 0.05
  for i in 0..<game.beams.length() {
    let seg = game.beams[i]
    let x1 = ox + seg.start.x * cs + half
    let y1 = oy + seg.start.y * cs + half
    let x2 = ox + seg.end_.x * cs + half
    let y2 = oy + seg.end_.y * cs + half
    let color = @types.beam_color_to_raylib(seg.color)
    // Outer glow
    let glow = fade_color(color, 40)
    draw_thick_line(x1, y1, x2, y2, 8.0, glow)
    // Main beam
    draw_thick_line(x1, y1, x2, y2, 4.0, fade_color(color, 200))
    // Bright center
    draw_thick_line(x1, y1, x2, y2, 2.0, @raylib.Color::new(255, 255, 255, 160))
    // Pulse animation - moving dot along beam
    let pulse_val = Float::from_double(
      @math.sin(time.to_double() * 3.0 + Float::from_int(i).to_double() * 1.5),
    )
    let t = (pulse_val + 1.0) / 2.0
    let px = Float::from_int(x1) +
      (Float::from_int(x2) - Float::from_int(x1)) * t
    let py = Float::from_int(y1) +
      (Float::from_int(y2) - Float::from_int(y1)) * t
    @raylib.draw_circle(
      px.to_int(),
      py.to_int(),
      3.0,
      @raylib.Color::new(255, 255, 255, 200),
    )
  }
}

///|
fn draw_thick_line(
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
  thickness : Float,
  color : @raylib.Color,
) -> Unit {
  if x1 == x2 && y1 == y2 {
    @raylib.draw_circle(x1, y1, thickness, color)
    return
  }
  // For horizontal or vertical lines, draw a rectangle
  let half_t = (thickness / 2.0).to_int()
  if y1 == y2 {
    // Horizontal
    let min_x = if x1 < x2 { x1 } else { x2 }
    let max_x = if x1 > x2 { x1 } else { x2 }
    @raylib.draw_rectangle(min_x, y1 - half_t, max_x - min_x, half_t * 2, color)
  } else if x1 == x2 {
    // Vertical
    let min_y = if y1 < y2 { y1 } else { y2 }
    let max_y = if y1 > y2 { y1 } else { y2 }
    @raylib.draw_rectangle(x1 - half_t, min_y, half_t * 2, max_y - min_y, color)
  } else {
    // Diagonal - fallback to line
    @raylib.draw_line(x1, y1, x2, y2, color)
  }
}
