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
    let tw = @draw.measure_text(game.message, 22)
    let mx = (@types.screen_width - tw) / 2
    @raylib.draw_rectangle(
      mx - 12,
      @types.screen_height - 40,
      tw + 24,
      34,
      @raylib.Color::new(0, 0, 0, 160),
    )
    @draw.draw_text(
      game.message,
      mx,
      @types.screen_height - 35,
      22,
      @raylib.white,
    )
  }
  @raylib.end_drawing()
}
