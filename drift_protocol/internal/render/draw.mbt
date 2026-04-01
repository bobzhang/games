///|
/// Main draw dispatch
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    LevelSelect => draw_level_select(game)
    Playing => draw_playing(game)
    Paused => {
      draw_playing(game)
      draw_pause(game)
    }
    Hacking => {
      draw_playing(game)
      draw_hack_overlay(game)
    }
    Results => draw_results(game)
    Victory => draw_victory(game)
  }
  @raylib.end_drawing()
}

///|
fn draw_playing(game : @types.Game) -> Unit {
  // Draw world
  draw_tiles(game)
  draw_shadow_overlay(game)
  draw_wall_edges(game)
  draw_grid_border()
  draw_power_connections(game)
  draw_power_indicators(game)
  draw_laser_beams(game)
  draw_terminal_glow(game)
  draw_exit_glow(game)
  draw_door_labels(game)
  draw_noise_ring(game)
  draw_coin(game)
  // Draw entities
  draw_cameras(game)
  draw_guards(game)
  draw_player(game)
  // Draw overlays
  draw_interaction_prompt(game)
  draw_alert_border(game)
  draw_scanlines(game)
  // Draw HUD
  draw_hud(game)
  // Detection pause flash
  if game.detection_pause > 0.0 {
    let flash_ratio : Float = game.detection_pause / @types.detection_pause_duration
    let flash_alpha_f : Float = 80.0 * flash_ratio
    @raylib.draw_rectangle(
      0,
      0,
      @types.screen_width,
      @types.screen_height,
      @raylib.Color::new(
        255,
        50,
        50,
        @types.clampi(flash_alpha_f.to_int(), 0, 255),
      ),
    )
  }
  // Fade effect when caught
  if game.fade_timer > 0.0 {
    let alpha = (game.fade_timer * 255.0).to_int()
    @raylib.draw_rectangle(
      0,
      0,
      @types.screen_width,
      @types.screen_height,
      @raylib.Color::new(0, 0, 0, @types.clampi(alpha, 0, 255)),
    )
  }
}
