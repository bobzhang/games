///|
fn main {
  @raylib.init_window(@types.screen_width, @types.screen_height, "Cradle")
  @raylib.set_target_fps(@types.target_fps)
  @draw.init_font()
  let levels = @levels.make_all_levels()
  let game = @types.new_game(levels)
  while !@raylib.window_should_close() {
    @game.update(game)
    @render.draw_frame(game)
  }
  @draw.cleanup()
  @raylib.close_window()
}
