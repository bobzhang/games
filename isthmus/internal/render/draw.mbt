///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    TierSelect => draw_tier_select(game)
    LevelSelect => draw_level_select(game)
    Playing => {
      draw_grid(game)
      draw_ui(game)
    }
    Results => draw_results(game)
  }
  // Draw message overlay
  if game.message_timer > 0.0 {
    let alpha = if game.message_timer < 0.5 {
      (game.message_timer * 2.0 * 255.0).to_int()
    } else {
      255
    }
    let color = @raylib.Color::new(255, 255, 255, alpha)
    let tw = @draw.measure_text(game.message, 28)
    @draw.draw_text(
      game.message,
      (@types.screen_width - tw) / 2,
      @types.screen_height - 80,
      28,
      color,
    )
  }
  @raylib.end_drawing()
}
