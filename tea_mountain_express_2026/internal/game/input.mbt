///|
fn @types.Game::clear_input(game : @types.Game) -> Unit {
  game.input_steer = 0
  game.input_tilt = 0
  game.input_brake_press = false
  game.input_stabilize_hold = false
  game.input_boost_press = false
  game.input_pause_press = false
  game.input_restart_press = false
  game.input_confirm_press = false
}

///|
fn @types.Game::update_input(game : @types.Game) -> Unit {
  game.clear_input()

  if @raylib.is_key_pressed(@raylib.KeyA) ||
    @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.input_steer = game.input_steer - 1
  }

  if @raylib.is_key_pressed(@raylib.KeyD) ||
    @raylib.is_key_pressed(@raylib.KeyRight) {
    game.input_steer = game.input_steer + 1
  }

  if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
    game.input_tilt = game.input_tilt - 1
  }

  if @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown) {
    game.input_tilt = game.input_tilt + 1
  }

  game.input_steer = game.input_steer.clamp(min=-1, max=1)
  game.input_tilt = game.input_tilt.clamp(min=-1, max=1)

  let j_press = @raylib.is_key_pressed(@raylib.KeyJ)

  game.input_brake_press = j_press
  game.input_stabilize_hold = @raylib.is_key_down(@raylib.KeyK)
  game.input_boost_press = @raylib.is_key_pressed(@raylib.KeySpace)
  game.input_pause_press = @raylib.is_key_pressed(@raylib.KeyP)
  game.input_restart_press = @raylib.is_key_pressed(@raylib.KeyR)
  game.input_confirm_press = j_press
}
