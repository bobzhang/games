///|
/// Returns the movement direction derived from keyboard keys or on-screen D-pad buttons.
fn @types.Game::detect_move_dir(game : @types.Game) -> @types.Direction {
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

  let (lx, ly, lw, lh) = @types.dpad_left_rect()
  let (rx, ry, rw, rh) = @types.dpad_right_rect()
  let (ux, uy, uw, uh) = @types.dpad_up_rect()
  let (dx, dy, dw, dh) = @types.dpad_down_rect()

  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_hold,
      game.touch_count,
      lx,
      ly,
      lw,
      lh,
    ) {
    dir = Left
  }
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_hold,
      game.touch_count,
      rx,
      ry,
      rw,
      rh,
    ) {
    dir = Right
  }
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_hold,
      game.touch_count,
      ux,
      uy,
      uw,
      uh,
    ) {
    dir = Up
  }
  if @types.pointer_on_rect(
      game.mouse_x,
      game.mouse_y,
      game.mouse_hold,
      game.touch_count,
      dx,
      dy,
      dw,
      dh,
    ) {
    dir = Down
  }

  dir
}

///|
/// Returns true when the start button is pressed via keyboard or touch.
fn @types.Game::detect_start_press(game : @types.Game) -> Bool {
  let mut pressed = @raylib.is_key_pressed(@raylib.KeyEnter) ||
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
    pressed = true
  }

  pressed
}

///|
/// Returns true when the next/advance button is pressed via keyboard or touch.
fn @types.Game::detect_next_press(game : @types.Game) -> Bool {
  let mut pressed = @raylib.is_key_pressed(@raylib.KeyEnter) ||
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
    pressed = true
  }

  pressed
}

///|
/// Returns true when the retry button is pressed via keyboard or touch.
fn @types.Game::detect_retry_press(game : @types.Game) -> Bool {
  let mut pressed = @raylib.is_key_pressed(@raylib.KeyR) ||
    @raylib.is_key_pressed(@raylib.KeyBackspace)

  let (x, y, w, h) = @types.retry_button_rect()
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
    pressed = true
  }

  pressed
}

///|
/// Returns true when the in-play restart button is pressed via keyboard or touch.
fn @types.Game::detect_restart_play_press(game : @types.Game) -> Bool {
  let mut pressed = @raylib.is_key_pressed(@raylib.KeyR)
  let (x, y, w, h) = @types.restart_button_rect()
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
    pressed = true
  }
  pressed
}

///|
/// Collects all input for the current frame into a `FrameInput` snapshot.
fn @types.Game::gather_input(game : @types.Game) -> @types.FrameInput {
  let move_dir = match game.state {
    Play => game.detect_move_dir()
    _ => DirNone
  }

  {
    move_dir,
    start_pressed: game.detect_start_press(),
    next_pressed: game.detect_next_press(),
    retry_pressed: game.detect_retry_press(),
    restart_pressed: game.detect_restart_play_press(),
  }
}
