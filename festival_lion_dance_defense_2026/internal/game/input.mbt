///|
/// Zeros all input flags and axes in the game's input state.
fn @types.Game::clear_input(game : @types.Game) -> Unit {
  game.input.move_x = 0
  game.input.move_y = 0
  game.input.press_strike = false
  game.input.press_guard = false
  game.input.press_burst = false
  game.input.press_pause = false
  game.input.press_restart = false
  game.input.press_start = false
}

///|
/// Reads all keyboard input each frame and populates the game's InputState with movement axes and action presses.
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

  game.input.press_strike = @raylib.is_key_pressed(@raylib.KeyJ)
  game.input.press_guard = @raylib.is_key_pressed(@raylib.KeyK)
  game.input.press_burst = @raylib.is_key_pressed(@raylib.KeySpace)
  game.input.press_pause = @raylib.is_key_pressed(@raylib.KeyP)
  game.input.press_restart = @raylib.is_key_pressed(@raylib.KeyR)

  game.input.press_start = game.input.press_strike ||
    @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)
}
