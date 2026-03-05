///|
fn @types.Game::title_hover(game : @types.Game) -> Bool {
  let b = @types.start_button_rect()
  @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    b.0,
    b.1,
    b.2,
    b.3,
  )
}

///|
fn @types.Game::result_hover(game : @types.Game) -> Bool {
  let b = @types.retry_button_rect()
  @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    b.0,
    b.1,
    b.2,
    b.3,
  )
}

///|
fn @types.Game::board_cell_from_pointer(game : @types.Game) -> (Bool, Int, Int) {
  let (bx, by, tile) = @types.board_metrics(game.shake_t)

  let x : Int = (game.mouse_x.to_int() - bx) / tile
  let y : Int = (game.mouse_y.to_int() - by) / tile

  if x >= 0 && x < @types.grid_w && y >= 0 && y < @types.grid_h {
    (true, x, y)
  } else {
    (false, 0, 0)
  }
}

///|
fn @types.Game::direction_to_cell(
  game : @types.Game,
  tx : Int,
  ty : Int,
) -> Int {
  let hx : Int = game.p_seg_x[0]
  let hy : Int = game.p_seg_y[0]

  let mut dx : Int = tx - hx
  let mut dy : Int = ty - hy

  if Float::from_int(dx).abs() > Float::from_int(@types.grid_w / 2) {
    dx = if dx > 0 { dx - @types.grid_w } else { dx + @types.grid_w }
  }
  if Float::from_int(dy).abs() > Float::from_int(@types.grid_h / 2) {
    dy = if dy > 0 { dy - @types.grid_h } else { dy + @types.grid_h }
  }

  if Float::from_int(dx).abs() > Float::from_int(dy).abs() {
    if dx < 0 {
      @types.dir_left
    } else {
      @types.dir_right
    }
  } else if dy < 0 {
    @types.dir_up
  } else {
    @types.dir_down
  }
}

///|
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
fn @types.Game::handle_touch_buttons(game : @types.Game) -> Bool {
  if game.touch_cd > 0.0 {
    return false
  }

  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let tc = game.touch_count

  let left = @types.btn_left()
  let right = @types.btn_right()
  let up = @types.btn_up()
  let down = @types.btn_down()
  let boost = @types.btn_boost()
  let restart = @types.btn_restart()
  let hint = @types.btn_hint()

  if @types.pointer_on_rect(mx, my, hold, tc, left.0, left.1, left.2, left.3) {
    game.p_next_dir = @types.dir_left
    game.touch_cd = 0.12
    return true
  }
  if @types.pointer_on_rect(
      mx,
      my,
      hold,
      tc,
      right.0,
      right.1,
      right.2,
      right.3,
    ) {
    game.p_next_dir = @types.dir_right
    game.touch_cd = 0.12
    return true
  }
  if @types.pointer_on_rect(mx, my, hold, tc, up.0, up.1, up.2, up.3) {
    game.p_next_dir = @types.dir_up
    game.touch_cd = 0.12
    return true
  }
  if @types.pointer_on_rect(mx, my, hold, tc, down.0, down.1, down.2, down.3) {
    game.p_next_dir = @types.dir_down
    game.touch_cd = 0.12
    return true
  }

  if @types.pointer_on_rect(
      mx,
      my,
      hold,
      tc,
      restart.0,
      restart.1,
      restart.2,
      restart.3,
    ) {
    game.start_match()
    game.touch_cd = 0.16
    return true
  }

  if @types.pointer_on_rect(mx, my, hold, tc, hint.0, hint.1, hint.2, hint.3) {
    ignore(game.use_hint())
    game.touch_cd = 0.16
    return true
  }

  if @types.pointer_on_rect(
      mx,
      my,
      hold,
      tc,
      boost.0,
      boost.1,
      boost.2,
      boost.3,
    ) {
    game.boost_on = game.boost_meter > 0.08
    return true
  }

  false
}

///|
fn @types.Game::update_play_input(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = @types.state_title
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyR) {
    game.start_match()
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyLeft) ||
    @raylib.is_key_pressed(@raylib.KeyA) {
    game.p_next_dir = @types.dir_left
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) ||
    @raylib.is_key_pressed(@raylib.KeyD) {
    game.p_next_dir = @types.dir_right
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    game.p_next_dir = @types.dir_up
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    game.p_next_dir = @types.dir_down
  }

  if @raylib.is_key_pressed(@raylib.KeyH) {
    ignore(game.use_hint())
  }

  let boost_key : Bool = @raylib.is_key_down(@raylib.KeyLeftShift) ||
    @raylib.is_key_down(@raylib.KeyRightShift) ||
    @raylib.is_key_down(@raylib.KeyJ)

  game.boost_on = boost_key && game.boost_meter > 0.08

  let cell = game.board_cell_from_pointer()
  if cell.0 {
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
      game.p_next_dir = game.direction_to_cell(cell.1, cell.2)
    }
  }

  ignore(game.handle_touch_buttons())
}
