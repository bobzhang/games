///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    LevelSelect => draw_level_select(game)
    Playing => draw_playing(game)
    LevelComplete => draw_level_complete(game)
    Paused => draw_paused(game)
  }
  @raylib.end_drawing()
}
