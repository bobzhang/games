///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    TierSelect => draw_tier_select(game)
    LevelSelect => draw_level_select(game)
    Playing => {
      draw_board(game)
      draw_ui(game)
    }
    Results => draw_results(game)
  }
  // Draw message overlay
  if game.message_timer > 0.0 {
    let alpha = @types.clampf(game.message_timer * 255.0, 0.0, 255.0)
    let a = alpha.to_int()
    let c = @raylib.Color::new(255, 255, 80, a)
    let text_w = @raylib.measure_text(game.message, 24)
    @draw.draw_text(
      game.message,
      (@types.screen_width - text_w) / 2,
      @types.screen_height - 60,
      24,
      c,
    )
  }
  @fps.draw()
  @raylib.end_drawing()
}
