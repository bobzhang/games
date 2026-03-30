///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    @types.screen_width, @types.screen_height, "Kart Racing 3D",
  )
  @raylib.set_target_fps(60)
  @draw.init_font()
  let game = @types.Game()
  while !@raylib.window_should_close() {
    let frame_dt = @raylib.get_frame_time()
    let dt = if frame_dt > 0.05F { 0.05F } else { frame_dt }
    @game.update_game(game, dt)
    @raylib.begin_drawing()
    // Use theme sky color for clearing when in a race, default blue for menus
    let sky_c = if game.state != Menu {
      let ti = @types.theme_to_int(game.track_theme)
      if ti < @types.theme_sky_colors.length() {
        @types.theme_sky_colors[ti]
      } else {
        (100, 180, 255)
      }
    } else {
      (100, 180, 255)
    }
    @raylib.clear_background(@raylib.Color::new(sky_c.0, sky_c.1, sky_c.2, 255))
    if game.state != Menu {
      @render.draw_world(game)
    }
    @render.draw_ui(game)
    @fps.draw()
    @raylib.end_drawing()
  }
  @draw.cleanup()
  @raylib.close_window()
}
