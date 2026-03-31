///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    WorldSelect => draw_world_select(game)
    LevelSelect => draw_level_select(game)
    Playing => {
      draw_worlds(game)
      draw_ui(game)
    }
    Results => draw_results(game)
  }
  @raylib.end_drawing()
}
