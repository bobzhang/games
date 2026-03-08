///|
/// Entry point: initialises the window, runs the game loop collecting mouse/touch input then updating and rendering each frame, and shuts down on exit.
fn main {
  @raylib.init_window(
    @types.screen_w, @types.screen_h, "raylib [game] gomoku street duel 2026",
  )
  defer @raylib.close_window()
  @raylib.set_target_fps(@types.target_fps)

  let game = @types.Game()

  while !@raylib.window_should_close() {
    let frame_dt = @raylib.get_frame_time()
    let dt = if frame_dt > 0.05F { 0.05F } else { frame_dt }

    if @raylib.is_key_pressed(@raylib.KeyF11) {
      @raylib.toggle_borderless_windowed()
    }

    let mouse = @raylib.get_mouse_position()
    game.mouse_x = mouse.x
    game.mouse_y = mouse.y
    game.mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
    game.mouse_press = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)

    let mut touch_count : Int = @raylib.get_touch_point_count()
    if touch_count < 0 {
      touch_count = 0
    }
    game.touch_count = touch_count

    @game.update_game(game, dt)

    @raylib.begin_drawing()
    @render.draw_frame(game)
    @raylib.end_drawing()
  }
}
