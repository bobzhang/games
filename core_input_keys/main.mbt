///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - keyboard input",
  )
  let mut ball_position = @raylib.Vector2::new(
    Float::from_int(screen_width) / 2.0,
    Float::from_int(screen_height) / 2.0,
  )
  @raylib.set_target_fps(60)
  @draw.init_font()

  // Main game loop
  while !@raylib.window_should_close() {
    // Update
    if @raylib.is_key_down(@raylib.KeyRight) {
      ball_position = @raylib.Vector2::new(
        ball_position.x + 2.0,
        ball_position.y,
      )
    }
    if @raylib.is_key_down(@raylib.KeyLeft) {
      ball_position = @raylib.Vector2::new(
        ball_position.x - 2.0,
        ball_position.y,
      )
    }
    if @raylib.is_key_down(@raylib.KeyUp) {
      ball_position = @raylib.Vector2::new(
        ball_position.x,
        ball_position.y - 2.0,
      )
    }
    if @raylib.is_key_down(@raylib.KeyDown) {
      ball_position = @raylib.Vector2::new(
        ball_position.x,
        ball_position.y + 2.0,
      )
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @draw.draw_text(
      "move the ball with arrow keys", 10, 10, 20, @raylib.darkgray,
    )
    @raylib.draw_circle_v(ball_position, 50.0, @raylib.maroon)
    @fps.draw()
    @raylib.end_drawing()
  }

  // De-Initialization
  @draw.cleanup()
  @raylib.close_window()
}
