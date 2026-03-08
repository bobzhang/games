///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    @types.screen_width, @types.screen_height, @types.game_title,
  )
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

    @game.update_game(game, dt)

    @raylib.begin_drawing()
    @render.draw_game(game)
    @fps.draw()
    @raylib.end_drawing()
  }

  @draw.cleanup()
  @raylib.close_window()
}
