///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    @types.screen_w, @types.screen_h, "Physics Tower",
  )
  @draw.cleanup()
  defer @raylib.close_window()
  @raylib.set_target_fps(@types.target_fps)
  @draw.init_font()
  let game = @types.new_game()
  while !(@raylib.window_should_close()) {
    let dt : Float = @raylib.get_frame_time()
    @game.update(game, dt)
    @raylib.begin_drawing()
    @render.draw_frame(game)
    @fps.draw()
    @raylib.end_drawing()
  }
}
