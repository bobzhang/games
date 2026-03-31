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
    let msg_w = @draw.measure_text(game.message, 20)
    let mx = (@types.screen_width - msg_w) / 2
    let my = @types.screen_height - 60
    @raylib.draw_rectangle(mx - 12, my - 6, msg_w + 24, 32, @raylib.Color::new(
      0, 0, 0, 180,
    ))
    @draw.draw_text(game.message, mx, my, 20, @raylib.Color::new(
      255, 220, 100, alpha,
    ))
  }
  @raylib.end_drawing()
}
