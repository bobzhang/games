///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    ModeSelect => draw_mode_select(game)
    DifficultySelect => draw_difficulty_select(game)
    Playing => draw_playing(game)
    PuzzleSelect => draw_puzzle_select(game)
    Results => draw_results(game)
  }
  @fps.draw()
  @raylib.end_drawing()
}
