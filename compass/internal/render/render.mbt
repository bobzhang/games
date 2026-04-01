///|
pub fn draw_frame(game : @types.GameState) -> Unit {
  @raylib.begin_drawing()
  match game.phase {
    Menu => draw_menu(game, game.frame_count)
    LevelSelect => draw_level_select(game, game.frame_count)
    Playing | LevelComplete | GameOver =>
      match game.level_state {
        Some(state) => {
          @raylib.clear_background(menu_bg)
          draw_grid(state, game.frame_count)
          draw_fog_overlay(state, game.frame_count)
          draw_water_ripples(state, game.frame_count)
          draw_ship(state, game.frame_count)
          draw_hud(state, game.current_level, game.frame_count)
          draw_minimap(state)
          if state.phase is LevelComplete {
            draw_level_complete(state, game.frame_count)
          }
          if state.phase is GameOver {
            draw_game_over(game.frame_count)
          }
        }
        None => {
          @raylib.clear_background(menu_bg)
          @draw.draw_text("No level loaded", 400, 350, 24, text_bright)
        }
      }
  }
  @raylib.end_drawing()
}
