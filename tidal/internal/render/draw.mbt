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
  @raylib.end_drawing()
}

///|
fn draw_playing(game : @types.Game) -> Unit {
  draw_grid(game)
  draw_ui(game)
  draw_preview(game)
  // Message overlay
  if game.message_timer > 0.0 {
    let msg = game.message
    let tw = @draw.measure_text(msg, 28)
    let x = (@types.screen_width - tw) / 2
    @draw.draw_text(msg, x, @types.screen_height - 60, 28, @types.color_ui_highlight)
  }
}
