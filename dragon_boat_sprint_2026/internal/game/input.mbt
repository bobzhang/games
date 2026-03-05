///|
/// Resets all input fields in the game's input snapshot to their neutral defaults.
fn @types.Game::clear_input(game : @types.Game) -> Unit {
  game.input.steer = 0.0
  game.input.paddle_pressed = false
  game.input.stabilize_down = false
  game.input.burst_pressed = false
  game.input.pause_pressed = false
  game.input.restart_pressed = false
  game.input.start_pressed = false
}

///|
/// Polls all keyboard keys and writes the current frame's input into the game snapshot.
fn @types.Game::sample_input(game : @types.Game) -> Unit {
  game.clear_input()

  let mut steer : Float = 0.0
  if @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft) {
    steer = steer - 1.0
  }
  if @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight) {
    steer = steer + 1.0
  }

  game.input.steer = steer

  game.input.paddle_pressed = @raylib.is_key_pressed(@raylib.KeyJ)
  game.input.stabilize_down = @raylib.is_key_down(@raylib.KeyK)
  game.input.burst_pressed = @raylib.is_key_pressed(@raylib.KeySpace)
  game.input.pause_pressed = @raylib.is_key_pressed(@raylib.KeyP)
  game.input.restart_pressed = @raylib.is_key_pressed(@raylib.KeyR)

  game.input.start_pressed = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeyJ) ||
    @raylib.is_key_pressed(@raylib.KeySpace)
}
