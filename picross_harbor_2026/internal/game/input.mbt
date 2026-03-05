///|
/// Returns the directional constant for the currently held keyboard key or on-screen D-pad button, or dir_none if none is active.
fn @types.Game::detect_held_dir(game : @types.Game) -> @types.Dir {
  let mut dir : @types.Dir = None

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
/// Returns true if the fill action was triggered via keyboard or the on-screen Fill button this frame.
fn @types.Game::detect_fill_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyF)

  let (x, y, w, h) = @types.fill_button_rect()
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
/// Returns true if the cross/mark action was triggered via keyboard or the on-screen Mark button this frame.
fn @types.Game::detect_cross_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyX) ||
    @raylib.is_key_pressed(@raylib.KeyC)

  let (x, y, w, h) = @types.cross_button_rect()
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
/// Returns true if the undo action was triggered via keyboard or the on-screen Undo button this frame.
fn @types.Game::detect_undo_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyZ) ||
    @raylib.is_key_pressed(@raylib.KeyBackspace)

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
/// Returns true if the hint action was triggered via keyboard or the on-screen Hint button this frame.
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
/// Returns true if the reset action was triggered via keyboard or the on-screen Reset button this frame.
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
/// Returns true if the tool-swap key (Tab or T) was pressed this frame.
fn detect_toggle_tool() -> Bool {
  @raylib.is_key_pressed(@raylib.KeyTab) || @raylib.is_key_pressed(@raylib.KeyT)
}

///|
/// Returns true if the next/advance action was triggered via keyboard or the on-screen Next button this frame.
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
/// Returns true if the start/confirm action was triggered via keyboard or the on-screen Start button this frame.
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
/// Returns (true, col, row) if a mouse click or touch point hit a cell within the puzzle board this frame, or (false, 0, 0) otherwise.
fn @types.Game::detect_board_tap(game : @types.Game) -> (Bool, Int, Int) {
  let (board_x, board_y, tile, _, _, _, _) = @types.board_metrics(game)

  let bw : Int = game.grid_w * tile
  let bh : Int = game.grid_h * tile

  fn map_point(px : Float, py : Float) -> (Bool, Int, Int) {
    if not(@types.inside_rect(px, py, board_x, board_y, bw, bh)) {
      return (false, 0, 0)
    }

    let cx : Int = ((px.to_int() - board_x) / tile).clamp(
      min=0,
      max=game.grid_w - 1,
    )
    let cy : Int = ((py.to_int() - board_y) / tile).clamp(
      min=0,
      max=game.grid_h - 1,
    )
    (true, cx, cy)
  }

  if game.mouse_press {
    let res = map_point(game.mouse_x, game.mouse_y)
    if res.0 {
      return res
    }
  }

  if game.touch_count > 0 && game.touch_action_cd <= 0.0 {
    for i in 0..<game.touch_count {
      let p = @raylib.get_touch_position(i)
      let res = map_point(p.x, p.y)
      if res.0 {
        return res
      }
    }
  }

  (false, 0, 0)
}
