///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    @types.screen_w, @types.screen_h, "Super Mario - MoonBit Edition",
  )
  @raylib.set_target_fps(@types.target_fps)
  let game = @types.Game::new()
  while not(@raylib.window_should_close()) {
    let frame_dt = @raylib.get_frame_time()
    @game.record_frame_time(game, frame_dt)
    let max_dt : Float = 0.05
    let dt : Float = if frame_dt > max_dt { max_dt } else { frame_dt }
    @game.update_game(game, dt)
    @raylib.begin_drawing()
    @render.draw_game(game)
    @render.draw_ui(game)
    @raylib.end_drawing()
  }
  @raylib.close_window()
}
