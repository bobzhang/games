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
    Daily => draw_playing(game)
  }
  // Draw message overlay
  if game.message_timer > 0.0 {
    let tw = @draw.measure_text(game.message, 24)
    let mx = (@types.screen_width - tw) / 2
    @raylib.draw_rectangle(
      mx - 12,
      680,
      tw + 24,
      34,
      @raylib.Color::new(0, 0, 0, 160),
    )
    @draw.draw_text(game.message, mx, 685, 24, @raylib.white)
  }
  @raylib.end_drawing()
}
