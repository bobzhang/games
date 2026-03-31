///|
fn main {
  @raylib.init_window(@types.screen_width, @types.screen_height, "Nomad")
  @raylib.set_target_fps(@types.target_fps)
  @draw.init_font()
  let levels = @levels.create_all_levels()
  let game = @types.new_game()
  while !@raylib.window_should_close() {
    @game.update(game, levels)
    @render.draw_frame(game)
  }
  @draw.cleanup()
  @raylib.close_window()
}
