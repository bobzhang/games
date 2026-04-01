///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title_screen(game)
    LevelSelect => draw_level_select(game)
    Playing => draw_playing_screen(game)
    Simulating => draw_simulating_screen(game)
    Results => draw_results_screen(game)
  }
  @raylib.end_drawing()
}
