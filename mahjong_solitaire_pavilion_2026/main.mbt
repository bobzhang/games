///|
/// Entry point: opens the window, creates game state, and runs the main update-and-draw loop.
fn main {
  @raylib.init_window(
    @types.screen_w, @types.screen_h, "raylib [game] mahjong solitaire pavilion 2026",
  )
  defer @raylib.close_window()
  @raylib.set_target_fps(@types.target_fps)
  @draw.init_font()
  defer @draw.cleanup()
  let art = @render.load_game_art()
  defer @render.unload_game_art(art)

  let game = @types.Game()

  while !@raylib.window_should_close() {
    let frame_dt = @raylib.get_frame_time()
    let dt = if frame_dt > 0.05F { 0.05F } else { frame_dt }

    @game.update_game(game, dt)

    @raylib.begin_drawing()
    @render.draw_frame(game, art)
    @fps.draw()
    @raylib.end_drawing()
  }
}
