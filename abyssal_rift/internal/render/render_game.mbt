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
      draw_stairs(game)
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
    Victory => draw_victory_screen(game)
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
