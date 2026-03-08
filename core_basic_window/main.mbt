///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - basic window",
  )
  @raylib.set_target_fps(60) // Set our game to run at 60 frames-per-second
  @draw.init_font()

  // Main game loop
  while !@raylib.window_should_close() {
    // Update
    // TODO: Update your variables here

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @draw.draw_text(
      "Congrats! You created your first window!", 190, 200, 20, @raylib.lightgray,
    )
    @fps.draw()
    @raylib.end_drawing()
  }

  // De-Initialization
  @draw.cleanup()
  @raylib.close_window() // Close window and OpenGL context
}
