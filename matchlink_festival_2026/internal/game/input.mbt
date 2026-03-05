///|
/// Returns the currently held directional input from keyboard (WASD/arrows) or on-screen D-pad buttons.
fn @types.Game::detect_held_dir(game : @types.Game) -> @types.Direction {
  let mut dir : @types.Direction = DirNone

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
/// Returns true if the select action was triggered this frame via Enter, Space, or the SELECT button.
fn @types.Game::detect_select_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)

  let (x, y, w, h) = @types.select_button_rect()
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
/// Returns true if the hint action was triggered this frame via the H key or the HINT button.
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
/// Returns true if the shuffle action was triggered this frame via the J key or the SHUFFLE button.
fn @types.Game::detect_shuffle_press(game : @types.Game) -> Bool {
  let mut press : Bool = @raylib.is_key_pressed(@raylib.KeyJ)

  let (x, y, w, h) = @types.shuffle_button_rect()
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
/// Returns true if the clear-selection action was triggered this frame via C, Backspace, or the CLEAR button.
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
/// Returns true if the reset action was triggered this frame via the R key or the RESET button.
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
/// Returns true if the start action was triggered this frame via Enter, Space, or the start button on the title screen.
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
/// Returns true if the next-stage action was triggered this frame via Enter, Space, N, or the NEXT button.
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
/// Detects a mouse click or touch point that lands inside the board area and returns found status with the mapped tile column and row.
fn @types.Game::detect_board_tap(game : @types.Game) -> (Bool, Int, Int) {
  let (board_x, board_y, tile) = @types.board_metrics(game)

  let bw : Int = game.board_w * tile
  let bh : Int = game.board_h * tile

  fn map_to_cell(px : Float, py : Float) -> (Bool, Int, Int) {
    if not(@types.inside_rect(px, py, board_x, board_y, bw, bh)) {
      return (false, 0, 0)
    }

    let cx : Int = ((px.to_int() - board_x) / tile + 1).clamp(
      min=1,
      max=game.board_w,
    )
    let cy : Int = ((py.to_int() - board_y) / tile + 1).clamp(
      min=1,
      max=game.board_h,
    )
    (true, cx, cy)
  }

  if game.mouse_press {
    let r = map_to_cell(game.mouse_x, game.mouse_y)
    if r.0 {
      return r
    }
  }

  if game.touch_count > 0 && game.touch_action_cd <= 0.0 {
    for i in 0..<game.touch_count {
      let p = @raylib.get_touch_position(i)
      let r = map_to_cell(p.x, p.y)
      if r.0 {
        return r
      }
    }
  }

  (false, 0, 0)
}
