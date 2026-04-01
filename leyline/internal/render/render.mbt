///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  match game.screen {
    Title => draw_title(game)
    LevelSelect => draw_level_select(game)
    Playing => draw_playing(game)
    LevelComplete => draw_level_complete(game)
    LevelFailed => draw_level_failed(game)
  }
  @raylib.end_drawing()
}
