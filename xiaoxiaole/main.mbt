///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    @types.screen_w, @types.screen_h, "Xiao Xiao Le - Match 3",
  )
  @draw.cleanup()
  defer @raylib.close_window()
  @raylib.set_target_fps(@types.target_fps)
  @draw.init_font()
  let game = @types.Game()
  while !@raylib.window_should_close() {
    let dt : Float = @types.clampf(@raylib.get_frame_time(), 0.0, 0.05)
    @game.update_game(game, dt)
    @raylib.begin_drawing()
    @render.draw_frame(game)
    @fps.draw()
    @raylib.end_drawing()
  }
}
