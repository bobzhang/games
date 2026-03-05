///|
/// Returns true when the pointer is currently over the title screen start button.
fn @types.Game::title_hover(game : @types.Game) -> Bool {
  let (x, y, w, h) = @types.title_start_button()
  @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    x,
    y,
    w,
    h,
  )
}

///|
/// Returns true when the pointer is currently over the result screen retry button.
fn @types.Game::result_hover(game : @types.Game) -> Bool {
  let (x, y, w, h) = @types.retry_button()
  @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    x,
    y,
    w,
    h,
  )
}

///|
/// Handles start-game transitions from the title screen via keyboard, mouse, or touch.
fn @types.Game::update_title_input(game : @types.Game) -> Unit {
  let key_start : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)
  let click_start : Bool = @raylib.is_mouse_button_pressed(
    @raylib.MouseButtonLeft,
  )
  let tap_start : Bool = game.touch_cd <= 0.0 && game.title_hover()

  if key_start || click_start || tap_start {
    game.start_match()
    game.touch_cd = 0.16
  }
}

///|
/// Handles retry transitions from the result screen via keyboard, mouse, or touch.
fn @types.Game::update_result_input(game : @types.Game) -> Unit {
  let key_retry : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyR)
  let click_retry : Bool = @raylib.is_mouse_button_pressed(
    @raylib.MouseButtonLeft,
  )
  let tap_retry : Bool = game.touch_cd <= 0.0 && game.result_hover()

  if key_retry || click_retry || tap_retry {
    game.start_match()
    game.touch_cd = 0.16
  }
}

///|
/// Returns true when the pointer is inside `rect` and the touch cooldown has fully expired.
fn @types.Game::btn_pressed(game : @types.Game, rect : (Int, Int, Int, Int)) -> Bool {
  if game.touch_cd > 0.0 {
    return false
  }

  @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    rect.0,
    rect.1,
    rect.2,
    rect.3,
  )
}

///|
/// Checks all on-screen directional and action buttons and dispatches the corresponding move or action.
fn @types.Game::handle_buttons(game : @types.Game) -> Bool {
  if game.btn_pressed(@types.btn_left()) {
    ignore(game.try_move(DirLeft))
    game.touch_cd = 0.14
    return true
  }
  if game.btn_pressed(@types.btn_right()) {
    ignore(game.try_move(DirRight))
    game.touch_cd = 0.14
    return true
  }
  if game.btn_pressed(@types.btn_up()) {
    ignore(game.try_move(DirUp))
    game.touch_cd = 0.14
    return true
  }
  if game.btn_pressed(@types.btn_down()) {
    ignore(game.try_move(DirDown))
    game.touch_cd = 0.14
    return true
  }
  if game.btn_pressed(@types.btn_zap()) {
    ignore(game.use_zap(game.cursor_x, game.cursor_y))
    game.touch_cd = 0.16
    return true
  }
  if game.btn_pressed(@types.btn_undo()) {
    ignore(game.restore_undo())
    game.touch_cd = 0.16
    return true
  }
  if game.btn_pressed(@types.btn_restart()) {
    game.start_match()
    game.touch_cd = 0.16
    return true
  }

  false
}

///|
/// Processes all keyboard, mouse, and touch input for the play state during one frame.
fn @types.Game::update_play_input(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = Title
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyR) {
    game.start_match()
    return
  }

  let hover = @types.pointer_cell(game, game.mouse_x, game.mouse_y)
  if hover.0 {
    game.cursor_x = hover.1
    game.cursor_y = hover.2
  }

  if @raylib.is_key_pressed(@raylib.KeyLeft) ||
    @raylib.is_key_pressed(@raylib.KeyA) {
    ignore(game.try_move(DirLeft))
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) ||
    @raylib.is_key_pressed(@raylib.KeyD) {
    ignore(game.try_move(DirRight))
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    ignore(game.try_move(DirUp))
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    ignore(game.try_move(DirDown))
  }

  if @raylib.is_key_pressed(@raylib.KeyZ) ||
    @raylib.is_key_pressed(@raylib.KeyU) {
    ignore(game.restore_undo())
  }

  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    ignore(game.use_zap(game.cursor_x, game.cursor_y))
  }

  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
    if hover.0 {
      ignore(game.use_zap(hover.1, hover.2))
    }
  }

  if game.handle_buttons() {
    return
  }
}
