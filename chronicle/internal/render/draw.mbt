///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    TierSelect => draw_tier_select(game)
    CaseSelect => draw_case_select(game)
    Playing => draw_playing(game)
    Results => draw_results(game)
  }
  // Draw message overlay
  if game.message_timer > 0.0 {
    let tw = @draw.measure_text(game.message, 24)
    let mx = (@types.screen_width - tw) / 2
    @raylib.draw_rectangle(
      mx - 10,
      340,
      tw + 20,
      40,
      @types.color_clue_panel_bg,
    )
    @draw.draw_text(game.message, mx, 348, 24, @types.color_clue)
  }
  @raylib.end_drawing()
}
