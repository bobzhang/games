///|
/// Initializes the window, runs the main game loop, and cleans up on exit.
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    @types.screen_w, @types.screen_h, "raylib [game] candy crush 2026",
  )
  @draw.cleanup()
  defer @raylib.close_window()
  @raylib.set_target_fps(@types.target_fps)
  @draw.init_font()

  let game = @types.Game()

  while !@raylib.window_should_close() {
    let dt = @types.clampf(@raylib.get_frame_time(), 0.0, 0.05)

    if @raylib.is_key_pressed(@raylib.KeyF11) {
      @raylib.toggle_borderless_windowed()
    }

    let mouse = @raylib.get_mouse_position()
    game.mouse_x = mouse.x
    game.mouse_y = mouse.y
    game.mouse_press = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
    let mut tc = @raylib.get_touch_point_count()
    if tc < 0 {
      tc = 0
    }
    game.touch_count = tc

    @game.update_game(game, dt)

    @raylib.begin_drawing()
    @render.draw_frame(game)
    @fps.draw()
    @raylib.end_drawing()
  }
}
