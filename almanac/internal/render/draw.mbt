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
    let msg = game.message
    let mw = @draw.measure_text(msg, 24)
    let mx = (@types.screen_width - mw) / 2
    @raylib.draw_rectangle(mx - 10, 650, mw + 20, 40, @types.color_hud_bg)
    @draw.draw_text(msg, mx, 656, 24, @types.color_hud_text)
  }
  @fps.draw()
  @raylib.end_drawing()
}
