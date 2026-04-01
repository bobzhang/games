///|
/// Main draw_frame entry point.
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    TierSelect => draw_tier_select(game)
    LevelSelect => draw_level_select(game)
    Playing => {
      draw_grid(game)
      draw_tiles(game)
      draw_water_overlay(game)
      draw_hover(game)
      draw_hud(game)
      draw_play_state(game)
      draw_message(game)
    }
    Results => draw_results(game)
  }
  @raylib.end_drawing()
}
