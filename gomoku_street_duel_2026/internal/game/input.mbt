///|
/// Returns the currently held directional input from keyboard arrow/WASD keys or the on-screen D-pad.
fn @types.Game::detect_held_dir(game : @types.Game) -> @types.Dir {
  let mut dir : @types.Dir = DirNone

  if @raylib.is_key_down(@raylib.KeyLeft) || @raylib.is_key_down(@raylib.KeyA) {
    dir = Left
  }
  if @raylib.is_key_down(@raylib.KeyRight) || @raylib.is_key_down(@raylib.KeyD) {
    dir = Right
  }
  if @raylib.is_key_down(@raylib.KeyUp) || @raylib.is_key_down(@raylib.KeyW) {
    dir = Up
  }
  if @raylib.is_key_down(@raylib.KeyDown) || @raylib.is_key_down(@raylib.KeyS) {
    dir = Down
  }

  let cx : Int = @types.dpad_center_x()
  let cy : Int = @types.dpad_center_y()
  let s : Int = @types.dpad_size()

  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_hold,
      game.touch_count,
      cx - s - 18,
      cy - s / 2,
      s,
      s,
    ) {
    dir = Left
  }
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_hold,
      game.touch_count,
      cx + 18,
      cy - s / 2,
      s,
      s,
    ) {
    dir = Right
  }
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_hold,
      game.touch_count,
      cx - s / 2,
      cy - s - 18,
      s,
      s,
    ) {
    dir = Up
  }
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_hold,
      game.touch_count,
      cx - s / 2,
      cy + 18,
      s,
      s,
    ) {
    dir = Down
  }

  dir
}

///|
/// Returns true if the player triggered a stone-placement action via Enter/Space or the PLACE touch button.
fn @types.Game::detect_place_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)

  let (x, y, w, h) = @types.place_button_rect()
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      x,
      y,
      w,
      h,
    ) {
    press = true
  }

  press
}

///|
/// Returns true if the player triggered a hint request via H key or the HINT touch button.
fn @types.Game::detect_hint_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyH)

  let (x, y, w, h) = @types.hint_button_rect()
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      x,
      y,
      w,
      h,
    ) {
    press = true
  }

  press
}

///|
/// Returns true if the player triggered an undo action via U/Z keys or the UNDO touch button.
fn @types.Game::detect_undo_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyU) ||
    @raylib.is_key_pressed(@raylib.KeyZ)

  let (x, y, w, h) = @types.undo_button_rect()
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      x,
      y,
      w,
      h,
    ) {
    press = true
  }

  press
}

///|
/// Returns true if the player triggered a hint-clear action via C/Backspace keys or the CLEAR touch button.
fn @types.Game::detect_clear_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyC) ||
    @raylib.is_key_pressed(@raylib.KeyBackspace)

  let (x, y, w, h) = @types.clear_button_rect()
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      x,
      y,
      w,
      h,
    ) {
    press = true
  }

  press
}

///|
/// Returns true if the player triggered a round-reset action via R key or the RESET touch button.
fn @types.Game::detect_reset_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyR)

  let (x, y, w, h) = @types.reset_button_rect()
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      x,
      y,
      w,
      h,
    ) {
    press = true
  }

  press
}

///|
/// Returns true if the player triggered a game-start action via Enter/Space or the start touch button.
fn @types.Game::detect_start_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)

  let (x, y, w, h) = @types.start_button_rect()
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      x,
      y,
      w,
      h,
    ) {
    press = true
  }

  press
}

///|
/// Returns true if the player triggered a next-round action via Enter/Space/N or the NEXT touch button.
fn @types.Game::detect_next_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyN)

  let (x, y, w, h) = @types.next_button_rect()
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_press,
      game.touch_count,
      x,
      y,
      w,
      h,
    ) {
    press = true
  }

  press
}

///|
/// Returns `(true, col, row)` if the current mouse click or touch point maps to a board cell, otherwise `(false, 0, 0)`.
fn @types.Game::detect_board_tap(game : @types.Game) -> (Bool, Int, Int) {
  let (board_x, board_y, tile) = @types.board_metrics(game)
  let bw : Int = @types.board_n * tile
  let bh : Int = @types.board_n * tile

  fn map(px : Float, py : Float) -> (Bool, Int, Int) {
    if !@types.inside_rect(px, py, board_x, board_y, bw, bh) {
      return (false, 0, 0)
    }

    let cx : Int = ((px.to_int() - board_x) / tile).clamp(
      min=0,
      max=@types.board_n - 1,
    )
    let cy : Int = ((py.to_int() - board_y) / tile).clamp(
      min=0,
      max=@types.board_n - 1,
    )
    (true, cx, cy)
  }

  if game.mouse_press {
    let r = map(game.mouse_x, game.mouse_y)
    if r.0 {
      return r
    }
  }

  if game.touch_count > 0 && game.touch_action_cd <= 0.0 {
    for i in 0..<game.touch_count {
      let p = @raylib.get_touch_position(i)
      let r = map(p.x, p.y)
      if r.0 {
        return r
      }
    }
  }

  (false, 0, 0)
}
