///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    LevelSelect => draw_level_select(game)
    Planning => draw_planning(game)
    Simulate => draw_simulate(game)
    Results => draw_results(game)
  }
  @raylib.end_drawing()
}
