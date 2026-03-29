///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(@types.screen_w, @types.screen_h, "Abyssal Rift")
  @raylib.set_target_fps(60)
  @draw.init_font()
  @audio.init_audio()
  let game = @types.Game::new()
  while !@raylib.window_should_close() {
    let dt = @types.minf(@raylib.get_frame_time(), 0.05)
    @game.update_game(game, dt)
    @raylib.begin_drawing()
    @render.draw_game(game)
    @raylib.end_drawing()
    @audio.process_events(game.events)
  }
  @audio.cleanup()
  @draw.cleanup()
  @raylib.close_window()
}
