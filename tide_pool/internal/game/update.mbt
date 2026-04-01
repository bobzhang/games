///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
  game.anim_timer = game.anim_timer + @raylib.get_frame_time()
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - @raylib.get_frame_time()
  }
  match game.screen {
    Title => handle_title_input(game)
    LevelSelect => handle_level_select_input(game)
    Playing => handle_playing_input(game)
    Simulating => update_simulation(game)
    Results => handle_results_input(game)
  }
}
