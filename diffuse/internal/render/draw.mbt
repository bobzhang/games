///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    TierSelect => draw_tier_select(game)
    LevelSelect => draw_level_select(game)
    Playing => {
      draw_grid(game)
      draw_ui(game)
      if game.play_state == Won || game.play_state == Failed {
        draw_results_overlay(game)
      }
    }
    Results => draw_results_screen(game)
  }
  @raylib.end_drawing()
}
