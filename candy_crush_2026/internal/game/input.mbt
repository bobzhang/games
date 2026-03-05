///|
/// Handles start input on the title screen via keyboard or pointer.
fn @types.Game::update_title_input(game : @types.Game) -> Unit {
  if game.touch_count > 0 {
    game.touch_mode = true
  }

  let mut start = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)

  let start_rect = @types.start_button_rect()
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      start_rect.0,
      start_rect.1,
      start_rect.2,
      start_rect.3,
    ) {
    start = true
  }

  if start {
    game.restart_run()
  }
}

///|
/// Handles all gameplay input including cursor movement, selection, hint, shuffle, and restart.
fn @types.Game::update_play_input(game : @types.Game) -> Unit {
  if game.touch_count > 0 {
    game.touch_mode = true
  }

  if @raylib.is_key_pressed(@raylib.KeyLeft) ||
    @raylib.is_key_pressed(@raylib.KeyA) {
    game.move_cursor(-1, 0)
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) ||
    @raylib.is_key_pressed(@raylib.KeyD) {
    game.move_cursor(1, 0)
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    game.move_cursor(0, -1)
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    game.move_cursor(0, 1)
  }

  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.select_or_swap(game.cursor_x, game.cursor_y)
  }

  if @raylib.is_key_pressed(@raylib.KeyH) {
    game.use_hint()
  }

  if @raylib.is_key_pressed(@raylib.KeyJ) {
    game.try_manual_shuffle()
  }

  if @raylib.is_key_pressed(@raylib.KeyR) {
    game.restart_level()
    return
  }

  let tap = @types.pointer_to_cell(
    game.mouse_x,
    game.mouse_y,
    game.mouse_press,
    game.touch_count,
  )
  if tap.0 && game.touch_cd <= 0.0 {
    game.touch_cd = @types.touch_action_cooldown
    game.select_or_swap(tap.1, tap.2)
    return
  }

  if game.touch_cd > 0.0 {
    return
  }

  let hint = @types.hint_button_rect()
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      hint.0,
      hint.1,
      hint.2,
      hint.3,
    ) {
    game.touch_cd = @types.touch_action_cooldown
    game.use_hint()
    return
  }

  let shuffle = @types.shuffle_button_rect()
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      shuffle.0,
      shuffle.1,
      shuffle.2,
      shuffle.3,
    ) {
    game.touch_cd = @types.touch_action_cooldown
    game.try_manual_shuffle()
    return
  }

  let restart = @types.restart_button_rect()
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      restart.0,
      restart.1,
      restart.2,
      restart.3,
    ) {
    game.touch_cd = @types.touch_action_cooldown
    game.restart_level()
  }
}

///|
/// Handles input on level-clear and game-over screens to advance or restart.
fn @types.Game::update_result_input(game : @types.Game) -> Unit {
  if game.touch_count > 0 {
    game.touch_mode = true
  }

  let mut action = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)

  let rect = @types.result_button_rect()
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      rect.0,
      rect.1,
      rect.2,
      rect.3,
    ) {
    action = true
  }

  match game.state {
    LevelClear => {
      if action {
        game.start_next_level()
        return
      }
      if @raylib.is_key_pressed(@raylib.KeyR) {
        game.restart_level()
        return
      }
    }
    _ =>
      if action {
        game.restart_run()
        return
      }
  }
  if @raylib.is_key_pressed(@raylib.KeyT) {
    game.state = Title
    game.clear_selection()
  }
}
