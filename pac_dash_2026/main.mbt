///|
/// Initializes the window, creates the game state, and runs the frame loop until the window closes.
fn main {
  @raylib.init_window(
    @types.screen_width, @types.screen_height, "Pac Dash 2026",
  )
  defer @raylib.close_window()
  @raylib.set_target_fps(60)
  @draw.init_font()
  defer @draw.cleanup()
  let art = @render.load_game_art()
  defer @render.unload_game_art(art)

  let game = @types.Game()
  @game.init_game(game)

  while !@raylib.window_should_close() {
    let frame_dt = @raylib.get_frame_time()
    let dt = if frame_dt > 0.05F { 0.05F } else { frame_dt }
    @game.update_game(game, dt)
    @render.draw_frame(game, art)
  }
}
