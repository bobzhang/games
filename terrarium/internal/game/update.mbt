///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count += 1
  if game.message_timer > 0.0 {
    game.message_timer -= @raylib.get_frame_time()
    if game.message_timer < 0.0 {
      game.message_timer = 0.0
    }
  }
  match game.screen {
    Title => handle_title_input(game)
    LevelSelect => handle_level_select_input(game)
    Playing => handle_playing_input(game)
    Simulating => {
      handle_simulating_input(game)
      update_simulation(game)
    }
    Results => handle_results_input(game)
  }
}
