///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    @types.screen_width, @types.screen_height, "raylib [game] contra 1987 lite",
  )
  @raylib.set_target_fps(60)
  @draw.init_font()

  let game = @types.Game::new()

  while !@raylib.window_should_close() {
    let frame_dt = @raylib.get_frame_time()
    let dt = if frame_dt > 0.05F { 0.05F } else { frame_dt }

    @game.update_game(game, dt)

    @raylib.begin_drawing()
    @render.draw_world(game)
    @render.draw_ui(game)
    @fps.draw()
    @raylib.end_drawing()
  }

  @draw.cleanup()
  @raylib.close_window()
}
