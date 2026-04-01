///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.03
  // Animated molten metal particles
  for i in 0..<50 {
    let fi = Float::from_int(i)
    let px = ((fi * 127.3 + time * 18.0) % Float::from_int(w)).to_int()
    let py_base = Float::from_int(h) -
      (fi * 83.7 + time * 25.0 * (fi % 4.0 + 1.0)) % Float::from_int(h)
    let py = py_base.to_int()
    let heat = (fi * 23.0 % 100.0).to_int()
    let cr = 180 + heat / 2
    let cg = 100 + heat
    let cb = 20 + heat / 3
    @raylib.draw_circle(
      px,
      py,
      1.5 + fi % 3.0,
      @raylib.Color::new(cr, cg, cb, 120),
    )
  }
  // Title
  let title = "ALLOY"
  let title_w = @draw.measure_text(title, 80)
  let pulse = sinf(time * 2.0) * 0.15 + 0.85
  let alpha = (pulse * 255.0).to_int()
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    h / 4 - 30,
    80,
    @raylib.Color::new(255, 160, 40, alpha),
  )
  // Subtitle
  let sub = "METALLURGY BLENDING PUZZLE"
  let sub_w = @draw.measure_text(sub, 22)
  @draw.draw_text(sub, (w - sub_w) / 2, h / 4 + 60, 22, @types.color_hud_text)
  // Decorative crucible icon (simple trapezoid)
  let cx = w / 2
  let cy = h / 2 + 20
  draw_crucible_icon(cx, cy, 60, game.frame_count)
  // Stars display
  let star_text = "Total Stars: " +
    game.total_stars.to_string() +
    " / " +
    (@types.total_levels * 3).to_string()
  let star_w = @draw.measure_text(star_text, 18)
  @draw.draw_text(
    star_text,
    (w - star_w) / 2,
    h / 2 + 80,
    18,
    @types.color_star_gold,
  )
  // Start prompt
  let start_text = "PRESS ENTER TO START"
  let start_w = @draw.measure_text(start_text, 24)
  let blink = if game.frame_count % 60 < 40 { 255 } else { 100 }
  @draw.draw_text(
    start_text,
    (w - start_w) / 2,
    h * 3 / 4,
    24,
    @raylib.Color::new(220, 215, 230, blink),
  )
  // Controls hint
  let hint = "Blend metals to match target alloy properties"
  let hint_w = @draw.measure_text(hint, 16)
  @draw.draw_text(hint, (w - hint_w) / 2, h * 3 / 4 + 45, 16, @types.color_hud_dim)
}

///|
fn draw_crucible_icon(cx : Int, cy : Int, size : Int, frame : Int) -> Unit {
  let time = Float::from_int(frame) * 0.04
  let half = size / 2
  // Crucible body
  @raylib.draw_rectangle(
    cx - half,
    cy - half / 2,
    size,
    half + half / 3,
    @types.color_crucible,
  )
  @raylib.draw_rectangle(
    cx - half + 4,
    cy - half / 2 + 4,
    size - 8,
    half + half / 3 - 8,
    @types.color_crucible_inner,
  )
  // Glowing molten surface
  let glow_alpha = ((sinf(time * 3.0) * 0.3 + 0.7) * 200.0).to_int()
  @raylib.draw_rectangle(
    cx - half + 6,
    cy - half / 2 + 6,
    size - 12,
    12,
    @raylib.Color::new(255, 140, 30, glow_alpha),
  )
}
