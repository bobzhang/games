///|
/// Returns true when the pointer is hovering over the title-screen start button.
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
/// Returns true when the pointer is hovering over the result-screen retry button.
fn @types.Game::result_hover(game : @types.Game) -> Bool {
  let (x, y, w, h) = @types.result_retry_button()
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
/// Handles keyboard, click, and touch input on the title screen, starting a match when triggered.
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
/// Handles keyboard, click, and touch input on the result screen, restarting the match when triggered.
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
/// Converts pointer coordinates to a board cell, returning whether the point is inside the board and the cell coordinates.
fn @types.Game::board_hover_cell(
  game : @types.Game,
  mx : Float,
  my : Float,
) -> (Bool, Int, Int) {
  game.click_to_cell(mx, my)
}

///|
/// Performs the current action mode (reveal or flag) on the cell at (`x`, `y`).
fn @types.Game::do_action_on_cell(game : @types.Game, x : Int, y : Int) -> Bool {
  match game.mode {
    Reveal => game.reveal_cell(x, y)
    Flag => game.toggle_flag(x, y)
  }
}

///|
/// Moves the keyboard cursor by (`dx`, `dy`) clamped to the board bounds.
fn @types.Game::move_cursor(game : @types.Game, dx : Int, dy : Int) -> Unit {
  game.cursor_x = (game.cursor_x + dx).clamp(min=0, max=@types.board_w - 1)
  game.cursor_y = (game.cursor_y + dy).clamp(min=0, max=@types.board_h - 1)
}

///|
/// Processes keyboard input during play: cursor movement, mode toggle, flag, hint, and reveal actions.
fn @types.Game::handle_keyboard(game : @types.Game) -> Unit {
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

  if @raylib.is_key_pressed(@raylib.KeyM) {
    game.mode = match game.mode {
      Reveal => Flag
      Flag => Reveal
    }
    @types.set_msg(
      game,
      match game.mode {
        Reveal => "Reveal mode"
        Flag => "Flag mode"
      },
      0.8,
    )
  }

  if @raylib.is_key_pressed(@raylib.KeyF) {
    ignore(game.toggle_flag(game.cursor_x, game.cursor_y))
  }

  if @raylib.is_key_pressed(@raylib.KeyH) {
    ignore(game.use_hint())
  }

  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    ignore(game.do_action_on_cell(game.cursor_x, game.cursor_y))
  }
}

///|
/// Handles touch/mouse presses on the on-screen mode, hint, reset, and reveal buttons; returns true if a button was activated.
fn @types.Game::handle_touch_buttons(game : @types.Game) -> Bool {
  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let touch_count = game.touch_count
  let (mx0, my0, mw0, mh0) = @types.touch_mode_button()
  let (hx0, hy0, hw0, hh0) = @types.touch_hint_button()
  let (rx0, ry0, rw0, rh0) = @types.touch_reset_button()
  let (ax0, ay0, aw0, ah0) = @types.touch_reveal_button()

  if game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(mx, my, hold, touch_count, mx0, my0, mw0, mh0) {
    game.mode = match game.mode {
      Reveal => Flag
      Flag => Reveal
    }
    @types.set_msg(
      game,
      match game.mode {
        Reveal => "Reveal mode"
        Flag => "Flag mode"
      },
      0.8,
    )
    game.touch_cd = 0.18
    return true
  }

  if game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(mx, my, hold, touch_count, hx0, hy0, hw0, hh0) {
    ignore(game.use_hint())
    game.touch_cd = 0.18
    return true
  }

  if game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(mx, my, hold, touch_count, rx0, ry0, rw0, rh0) {
    game.start_match()
    game.touch_cd = 0.18
    return true
  }

  if game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(mx, my, hold, touch_count, ax0, ay0, aw0, ah0) {
    ignore(game.do_action_on_cell(game.cursor_x, game.cursor_y))
    game.touch_cd = 0.16
    return true
  }

  false
}

///|
/// Processes all play-state input: keyboard, mouse click/right-click, and touch button handling.
fn @types.Game::update_play_input(game : @types.Game, _dt : Float) -> Unit {
  let mx = game.mouse_x
  let my = game.mouse_y

  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = Title
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyR) {
    game.start_match()
    return
  }

  game.handle_keyboard()

  let hover = game.board_hover_cell(mx, my)
  if hover.0 {
    game.cursor_x = hover.1
    game.cursor_y = hover.2
  }

  if game.handle_touch_buttons() {
    return
  }

  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    if hover.0 {
      ignore(game.do_action_on_cell(hover.1, hover.2))
    }
  }

  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
    if hover.0 {
      ignore(game.toggle_flag(hover.1, hover.2))
    }
  }
}

///|
/// Updates one frame of input handling and play-state progression.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.mouse_x = Float::from_int(@raylib.get_mouse_x())
  game.mouse_y = Float::from_int(@raylib.get_mouse_y())
  game.touch_count = @raylib.get_touch_point_count()
  game.mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
    game.touch_count > 0

  match game.state {
    Title => game.update_title_input()
    Play => {
      game.update_play_input(dt)
      game.update_play(dt)
    }
    Result => {
      game.update_result_input()
      game.update_play(dt)
    }
  }
}
