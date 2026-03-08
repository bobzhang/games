///|
fn main {
  @raylib.init_window(
    @types.screen_width, @types.screen_height, "Tetris Meteor Fall 2026",
  )
  @raylib.set_target_fps(60)
  @draw.init_font()
  let game = @types.Game()
  @game.reset_game(game)
  while !@raylib.window_should_close() {
    let frame_dt = @raylib.get_frame_time()
    let dt = if frame_dt > 0.05F { 0.05F } else { frame_dt }
    @game.update_game(game, dt)
    @render.draw_frame(game)
  }
  @draw.cleanup()
  @raylib.close_window()
}
