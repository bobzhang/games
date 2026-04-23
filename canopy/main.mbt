///|
fn main {
  @raylib.init_window(@types.screen_width, @types.screen_height, "Canopy")
  @raylib.set_target_fps(@types.target_fps)
  @draw.init_font()
  @render.load_assets()
  let game = @types.new_game()
  while !@raylib.window_should_close() {
    @game.update(game)
    @render.draw_frame(game)
  }
  @render.unload_assets()
  @draw.cleanup()
  @raylib.close_window()
}
