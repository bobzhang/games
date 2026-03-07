///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    @types.screen_width, @types.screen_height, "Space Combat 3D",
  )
  @raylib.set_target_fps(60)
  let game = @types.Game()
  while !@raylib.window_should_close() {
    let frame_dt = @raylib.get_frame_time()
    let dt = if frame_dt > 0.05F { 0.05F } else { frame_dt }
    @game.update_game(game, dt)
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(5, 5, 15, 255))
    if game.state == StatePlaying ||
      game.state == StatePaused ||
      game.state == StateMissionComplete ||
      game.state == StateGameOver {
      @render.draw_world(game)
    }
    @render.draw_ui(game)
    @raylib.end_drawing()
  }
  @raylib.close_window()
}
