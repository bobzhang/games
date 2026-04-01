///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    TierSelect => draw_tier_select(game)
    TabletSelect => draw_tablet_select(game)
    Playing => draw_playing(game)
    Results => draw_results(game)
  }
  @raylib.end_drawing()
}
