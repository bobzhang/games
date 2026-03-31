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
      draw_shop_items(game)
      draw_shrine(game)
      draw_reward_choices(game)
      draw_enemies(game)
      draw_projectiles(game)
      draw_player(game)
      draw_telegraph_indicators(game)
      draw_particles(game)
      draw_damage_numbers(game)
      @raylib.end_mode_2d()
      // Screen-space UI
      draw_hud(game)
      draw_screen_effects(game)
      if game.pact_offer_active {
        draw_pact_offer(game)
      }
      // Path card selection overlay
      if game.path_active {
        draw_path_cards(game)
      }
      if game.state == Paused {
        draw_pause_overlay(game)
      }
      // Floor transition overlay
      if game.floor_transition_timer > 0.0 {
        let alpha = @types.clampi(
          (game.floor_transition_timer / 2.0 * 255.0).to_int(),
          0,
          255,
        )
        @raylib.draw_rectangle(
          0,
          0,
          @types.screen_w,
          @types.screen_h,
          @raylib.Color::new(0, 0, 0, alpha),
        )
        let floor_text = "FLOOR \{game.floor_num}"
        let ftw = @raylib.measure_text(floor_text, 48)
        @raylib.draw_text(
          floor_text,
          (@types.screen_w - ftw) / 2,
          @types.screen_h / 2 - 30,
          48,
          @raylib.Color::new(255, 255, 255, alpha),
        )
        // Show path name alongside biome
        let path_label = match game.current_path {
          Some(p) => " - " + @types.path_name(p)
          None => ""
        }
        let biome = if game.floor_num <= 5 {
          "Stone Crypt"
        } else {
          "Fungal Caverns"
        }
        let biome_text = biome + path_label
        let bw = @raylib.measure_text(biome_text, 20)
        @raylib.draw_text(
          biome_text,
          (@types.screen_w - bw) / 2,
          @types.screen_h / 2 + 30,
          20,
          @raylib.Color::new(180, 180, 200, alpha),
        )
      }
    }
    GameOver => draw_game_over(game)
    Victory => draw_victory_screen(game)
    MetaScreen => draw_meta_screen(game)
    StarterSelect => draw_starter_select(game)
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
