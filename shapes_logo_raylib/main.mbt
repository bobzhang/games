///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - raylib logo using shapes",
  )
  @raylib.set_target_fps(60)
  @draw.init_font()

  // Main game loop
  while !@raylib.window_should_close() {
    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_rectangle(
      screen_width / 2 - 128,
      screen_height / 2 - 128,
      256,
      256,
      @raylib.black,
    )
    @raylib.draw_rectangle(
      screen_width / 2 - 112,
      screen_height / 2 - 112,
      224,
      224,
      @raylib.raywhite,
    )
    @draw.draw_text(
      "raylib",
      screen_width / 2 - 44,
      screen_height / 2 + 48,
      50,
      @raylib.black,
    )
    @draw.draw_text("this is NOT a texture!", 350, 370, 10, @raylib.gray)
    @fps.draw()
    @raylib.end_drawing()
  }

  // De-Initialization
  @draw.cleanup()
  @raylib.close_window()
}
