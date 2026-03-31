///|
/// Main render dispatch.
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    WorldSelect => draw_world_select(game)
    LevelSelect => draw_level_select(game)
    Playing => draw_playing(game)
    Results => draw_results(game)
    Paused => {
      draw_playing(game)
      draw_pause_overlay(game)
    }
  }
  @raylib.end_drawing()
}
