///|
fn draw_blending(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  // Dim background
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 0, 0, 160))
  let progress = @types.clampf(
    game.blend_timer / @types.blend_anim_duration,
    0.0,
    1.0,
  )
  let cx = w / 2
  let cy = h / 2 - 40
  // Crucible body
  let crucible_w = 200
  let crucible_h = 160
  @raylib.draw_rectangle(
    cx - crucible_w / 2,
    cy - crucible_h / 2,
    crucible_w,
    crucible_h,
    @types.color_crucible,
  )
  @raylib.draw_rectangle(
    cx - crucible_w / 2 + 6,
    cy - crucible_h / 2 + 6,
    crucible_w - 12,
    crucible_h - 12,
    @types.color_crucible_inner,
  )
  // Swirling ingredients
  let time = game.blend_timer * 4.0
  let shrink_r : Float = 0.6
  let shrink_s : Float = 0.3
  let orbit_h : Float = 0.6
  for i in 0..<game.crucible.length() {
    let ing = game.crucible[i]
    let fi = Float::from_int(i)
    let angle = fi * 1.2 + time
    let radius : Float = 40.0 * (1.0 - progress * shrink_r)
    let px = Float::from_int(cx) + cosf(angle) * radius
    let py = Float::from_int(cy) + sinf(angle) * radius * orbit_h
    let size : Float = 12.0 * (1.0 - progress * shrink_s)
    let color = @types.metal_color(ing.metal)
    @raylib.draw_circle(px.to_int(), py.to_int(), size, color)
  }
  // Glow effect at center during blend
  let glow_threshold : Float = 0.3
  if progress > glow_threshold {
    let frac = (progress - glow_threshold) / (1.0 - glow_threshold)
    let glow_alpha = (frac * 200.0).to_int()
    let glow_size : Float = 30.0 + progress * 40.0
    let inner_frac : Float = 0.6
    @raylib.draw_circle(
      cx,
      cy,
      glow_size,
      @raylib.Color::new(255, 200, 80, glow_alpha),
    )
    @raylib.draw_circle(
      cx,
      cy,
      glow_size * inner_frac,
      @raylib.Color::new(255, 240, 180, glow_alpha),
    )
  }
  // Progress text
  let pct = (progress * 100.0).to_int()
  let pct_str = "Blending... " + pct.to_string() + "%"
  let pw = @draw.measure_text(pct_str, 24)
  @draw.draw_text(pct_str, (w - pw) / 2, cy + 100, 24, @types.color_hud_text)
  // Temperature indicator
  let temp_str = "Temperature: " + @types.temp_name(game.temperature)
  let tw = @draw.measure_text(temp_str, 16)
  @draw.draw_text(
    temp_str,
    (w - tw) / 2,
    cy + 130,
    16,
    @types.temp_color(game.temperature),
  )
}
