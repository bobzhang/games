///|
pub fn draw_game(game : @types.Game) -> Unit {
  match game.state {
    Title => draw_title_screen(game)
    Playing | Paused => {
      @raylib.clear_background(@types.color_bg)
      // World-space rendering (with camera)
      let cam = get_camera2d(game)
      @raylib.begin_mode_2d(cam)
      draw_world(game)
      draw_items(game)
      draw_enemies(game)
      draw_projectiles(game)
      draw_player(game)
      draw_telegraph_indicators(game)
      draw_particles(game)
      draw_damage_numbers(game)
      @raylib.end_mode_2d()
      // Screen-space UI
      draw_hud(game)
      if game.state == Paused {
        draw_pause_overlay(game)
      }
    }
    GameOver => draw_game_over(game)
    Victory => {
      @raylib.clear_background(@types.color_bg)
      let text = "VICTORY!"
      let tw = @raylib.measure_text(text, 56)
      @raylib.draw_text(text, (@types.screen_w - tw) / 2, 300, 56, @raylib.Color::new(255, 215, 0, 255))
    }
  }
}

///|
fn get_camera2d(game : @types.Game) -> @raylib.Camera2D {
  let cam = game.camera
  @raylib.Camera2D::new(
    @raylib.Vector2::new(
      Float::from_int(@types.screen_w) / 2.0 + cam.offset_x,
      Float::from_int(@types.screen_h) / 2.0 + cam.offset_y,
    ),
    @raylib.Vector2::new(cam.x, cam.y),
    0.0,
    1.0,
  )
}
