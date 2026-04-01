///|
fn draw_beams(game : @types.Game) -> Unit {
  let time = Float::from_int(game.frame_count) * 0.05
  for i in 0..<game.beams.length() {
    let seg = game.beams[i]
    let x1 = @types.hex_to_pixel_x(seg.start.q, seg.start.r)
    let y1 = @types.hex_to_pixel_y(seg.start.q, seg.start.r)
    let x2 = @types.hex_to_pixel_x(seg.end_.q, seg.end_.r)
    let y2 = @types.hex_to_pixel_y(seg.end_.q, seg.end_.r)
    let color = @types.beam_color_to_raylib(seg.color)
    // Outer glow
    draw_beam_line(
      x1.to_int(),
      y1.to_int(),
      x2.to_int(),
      y2.to_int(),
      8.0,
      fade_color(color, 35),
    )
    // Main beam
    draw_beam_line(
      x1.to_int(),
      y1.to_int(),
      x2.to_int(),
      y2.to_int(),
      3.0,
      fade_color(color, 200),
    )
    // Bright center
    draw_beam_line(
      x1.to_int(),
      y1.to_int(),
      x2.to_int(),
      y2.to_int(),
      1.0,
      @raylib.Color::new(255, 255, 255, 150),
    )
    // Pulse dot along beam
    let pulse_val = Float::from_double(
      @math.sin(time.to_double() * 3.0 + Float::from_int(i).to_double() * 1.3),
    )
    let t = (pulse_val + 1.0) / 2.0
    let px = x1 + (x2 - x1) * t
    let py = y1 + (y2 - y1) * t
    @raylib.draw_circle(
      px.to_int(),
      py.to_int(),
      2.5,
      @raylib.Color::new(255, 255, 255, 180),
    )
  }
}

///|
fn draw_beam_line(
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
  @raylib.draw_line_ex(
    @raylib.Vector2::new(Float::from_int(x1), Float::from_int(y1)),
    @raylib.Vector2::new(Float::from_int(x2), Float::from_int(y2)),
    thickness,
    color,
  )
}
