///|
/// Resets all input fields in the game's input state to their neutral default values.
fn @types.Game::clear_input(game : @types.Game) -> Unit {
  game.input.move_x = 0
  game.input.move_y = 0
  game.input.press_interact = false
  game.input.press_cancel = false
  game.input.press_calm = false
  game.input.press_pause = false
  game.input.press_restart = false
  game.input.press_start = false
}

///|
/// Reads keyboard state and populates the game input snapshot for the current frame.
fn @types.Game::update_input(game : @types.Game) -> Unit {
  game.clear_input()

  if @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft) {
    game.input.move_x = game.input.move_x - 1
  }
  if @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight) {
    game.input.move_x = game.input.move_x + 1
  }
  if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
    game.input.move_y = game.input.move_y - 1
  }
  if @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown) {
    game.input.move_y = game.input.move_y + 1
  }

  game.input.move_x = game.input.move_x.clamp(min=-1, max=1)
  game.input.move_y = game.input.move_y.clamp(min=-1, max=1)

  game.input.press_interact = @raylib.is_key_pressed(@raylib.KeyJ)
  game.input.press_cancel = @raylib.is_key_pressed(@raylib.KeyK)
  game.input.press_calm = @raylib.is_key_pressed(@raylib.KeySpace)
  game.input.press_pause = @raylib.is_key_pressed(@raylib.KeyP)
  game.input.press_restart = @raylib.is_key_pressed(@raylib.KeyR)

  game.input.press_start = game.input.press_interact ||
    game.input.press_calm ||
    @raylib.is_key_pressed(@raylib.KeyEnter)
}
