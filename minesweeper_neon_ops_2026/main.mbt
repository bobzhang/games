///|
/// Entry point: initialises the window and audio, then runs the frame loop delegating to update and render.
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    @types.screen_w, @types.screen_h, "raylib [game] minesweeper_neon_ops_2026",
  )
  @draw.cleanup()
  defer @raylib.close_window()

  @raylib.init_audio_device()
  defer @raylib.close_audio_device()

  @raylib.set_target_fps(@types.target_fps)
  @draw.init_font()

  let game = @types.Game()

  while !@raylib.window_should_close() {
    let dt = @types.clampf(@raylib.get_frame_time(), 0.0, 0.04)
    @game.update_game(game, dt)
    @raylib.begin_drawing()
    @render.draw_frame(game)
    @fps.draw()
    @raylib.end_drawing()
  }
}
