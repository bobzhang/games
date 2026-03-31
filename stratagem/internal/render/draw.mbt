///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    Campaign => draw_campaign(game)
    Skirmish => draw_skirmish(game)
    Playing => draw_playing(game)
    Results => draw_results(game)
  }
  @fps.draw()
  @raylib.end_drawing()
}
