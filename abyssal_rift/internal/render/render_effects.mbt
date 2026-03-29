///|
pub fn draw_screen_effects(game : @types.Game) -> Unit {
  // Low HP vignette
  let hp_ratio = Float::from_int(game.player.hp) / Float::from_int(
      game.player.max_hp,
    )
  let threshold : Float = 0.3
  if hp_ratio < threshold {
    let intensity = ((1.0 : Float) - hp_ratio / threshold) * (120.0 : Float)
    let alpha = intensity.to_int()
    // Red edges
    @raylib.draw_rectangle(
      0, 0, @types.screen_w, 8, @raylib.Color::new(200, 0, 0, alpha),
    )
    @raylib.draw_rectangle(
      0,
      @types.screen_h - 8,
      @types.screen_w,
      8,
      @raylib.Color::new(200, 0, 0, alpha),
    )
    @raylib.draw_rectangle(
      0, 0, 8, @types.screen_h, @raylib.Color::new(200, 0, 0, alpha),
    )
    @raylib.draw_rectangle(
      @types.screen_w - 8,
      0,
      8,
      @types.screen_h,
      @raylib.Color::new(200, 0, 0, alpha),
    )
  }
  // Boss phase flash
  let boss_threshold : Float = 0.3
  if game.boss_active && game.boss_phase_timer < boss_threshold {
    let flash_alpha = ((boss_threshold - game.boss_phase_timer) / boss_threshold *
      (80.0 : Float)).to_int()
    @raylib.draw_rectangle(
      0,
      0,
      @types.screen_w,
      @types.screen_h,
      @raylib.Color::new(255, 200, 100, @types.clampi(flash_alpha, 0, 80)),
    )
  }
}
