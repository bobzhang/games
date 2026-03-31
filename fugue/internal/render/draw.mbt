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
  // Draw message overlay
  if game.message_timer > 0.0 {
    let alpha = if game.message_timer > 0.5 {
      255
    } else {
      (game.message_timer * 510.0).to_int()
    }
    let col = @raylib.Color::new(255, 255, 200, alpha)
    let tw = @draw.measure_text(game.message, 28)
    @draw.draw_text(
      game.message,
      (@types.screen_width - tw) / 2,
      @types.screen_height - 60,
      28,
      col,
    )
  }
  @raylib.end_drawing()
}
