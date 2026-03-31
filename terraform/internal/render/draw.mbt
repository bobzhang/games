///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    TierSelect => draw_tier_select(game)
    LevelSelect => draw_level_select(game)
    Playing => draw_playing(game)
    Results => draw_results(game)
  }
  // Draw message overlay if active
  if game.message_timer > 0.0 {
    let alpha = @types.minf(game.message_timer * 2.0, 1.0)
    let a = (alpha * 255.0).to_int()
    let tw = @draw.measure_text(game.message, 28)
    @draw.draw_text(
      game.message,
      (@types.screen_width - tw) / 2,
      @types.screen_height - 60,
      28,
      @raylib.Color::new(255, 255, 255, a),
    )
  }
  @fps.draw()
  @raylib.end_drawing()
}
