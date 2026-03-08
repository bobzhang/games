///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - generate random values",
  )

  let mut rand_value = @raylib.get_random_value(-8, 5)
  let mut frames_counter = 0

  @raylib.set_target_fps(60)
  @draw.init_font()

  // Main game loop
  while !@raylib.window_should_close() {
    // Update
    frames_counter += 1

    // Every two seconds (120 frames) a new random value is generated
    if frames_counter / 120 % 2 == 1 {
      rand_value = @raylib.get_random_value(-8, 5)
      frames_counter = 0
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @draw.draw_text(
      "Every 2 seconds a new random value is generated:", 130, 100, 20, @raylib.maroon,
    )
    @draw.draw_text("\{rand_value}", 360, 180, 80, @raylib.lightgray)
    @fps.draw()
    @raylib.end_drawing()
  }

  // De-Initialization
  @draw.cleanup()
  @raylib.close_window()
}
