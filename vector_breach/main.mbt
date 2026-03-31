///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(@types.screen_w, @types.screen_h, "Vector Breach")
  @raylib.set_target_fps(60)
  @draw.init_font()
  let game = @types.Game()
  while !@raylib.window_should_close() {
    let frame_dt = @raylib.get_frame_time()
    let dt = if frame_dt > @types.max_frame_dt {
      @types.max_frame_dt
    } else {
      frame_dt
    }
    @game.update(game, dt)
    @raylib.begin_drawing()
    @render.draw(game)
    @raylib.end_drawing()
  }
  @draw.cleanup()
  @raylib.close_window()
}
