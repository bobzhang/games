///|
fn main {
  @raylib.init_window(@types.screen_width, @types.screen_height, "Aqueduct")
  @raylib.set_target_fps(@types.target_fps)
  @draw.init_font()
  @render.load_art()
  let all_levels = @levels.create_all_levels()
  let game = @types.new_game(all_levels)
  while !@raylib.window_should_close() {
    @game.update(game)
    @render.draw_frame(game)
  }
  @render.unload_art()
  @draw.cleanup()
  @raylib.close_window()
}
