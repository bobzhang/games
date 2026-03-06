///|
/// Returns true if the pointer is currently over the title-screen start button.
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
/// Returns true if the pointer is currently over the result-screen retry button.
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
/// Reads keyboard, mouse, and touch input on the title screen and starts a new run when any start action is detected.
fn @types.Game::update_title_input(game : @types.Game) -> Unit {
  let key_start : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)
  let click_start : Bool = @raylib.is_mouse_button_pressed(
    @raylib.MouseButtonLeft,
  )
  let tap_start : Bool = game.touch_cd <= 0.0 && game.title_hover()

  if key_start || click_start || tap_start {
    game.start_run()
    game.touch_cd = 0.16
  }
}

///|
/// Reads keyboard, mouse, and touch input on the result screen and starts a new run when the retry action is detected.
fn @types.Game::update_result_input(game : @types.Game) -> Unit {
  let key_retry : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyR)
  let click_retry : Bool = @raylib.is_mouse_button_pressed(
    @raylib.MouseButtonLeft,
  )
  let tap_retry : Bool = game.touch_cd <= 0.0 && game.result_hover()

  if key_retry || click_retry || tap_retry {
    game.start_run()
    game.touch_cd = 0.16
  }
}

///|
/// Returns the position of the nearest active enemy as an auto-aim target, or a point directly above the player if no enemies are active.
fn @types.Game::best_auto_aim(game : @types.Game) -> (Float, Float) {
  let mut tx : Float = game.player_x
  let mut ty : Float = game.player_y - 180.0

  let mut best : Float = 1_000_000_000.0

  for enemy in game.enemies {
    if !enemy.active {
      continue
    }

    let d2 : Float = @types.dist2(
      game.player_x,
      game.player_y,
      enemy.x,
      enemy.y,
    )

    if d2 < best {
      best = d2
      tx = enemy.x
      ty = enemy.y
    }
  }

  (tx, ty)
}

///|
/// Clamps the current aim position to remain within the playfield boundaries.
fn @types.Game::clamp_aim_inside_world(game : @types.Game) -> Unit {
  game.aim_x = @types.clampf(
    game.aim_x,
    @types.world_left(),
    @types.world_right(),
  )
  game.aim_y = @types.clampf(
    game.aim_y,
    @types.world_top(),
    @types.world_bottom(),
  )
}

///|
/// Reads all play-state input: movement axes from keyboard and touch d-pad, pointer-based aim, fire hold (with auto-aim fallback on touch), repair, hint, and restart actions.
fn @types.Game::update_play_input(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = Title
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyR) {
    game.start_run()
    return
  }

  let mx : Float = game.mouse_x
  let my : Float = game.mouse_y
  let hold : Bool = game.mouse_hold
  let touch_count : Int = game.touch_count

  let mut move_x : Float = 0.0
  let mut move_y : Float = 0.0

  if @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft) {
    move_x = move_x - 1.0
  }
  if @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight) {
    move_x = move_x + 1.0
  }
  if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
    move_y = move_y - 1.0
  }
  if @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown) {
    move_y = move_y + 1.0
  }

  let left = @types.btn_left()
  let right = @types.btn_right()
  let up = @types.btn_up()
  let down = @types.btn_down()
  let fire_btn = @types.btn_fire()
  let repair_btn = @types.btn_repair()
  let hint_btn = @types.btn_hint()
  let restart_btn = @types.btn_restart()

  if @types.pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      left.0,
      left.1,
      left.2,
      left.3,
    ) {
    move_x = move_x - 1.0
  }
  if @types.pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      right.0,
      right.1,
      right.2,
      right.3,
    ) {
    move_x = move_x + 1.0
  }
  if @types.pointer_on_rect(mx, my, hold, touch_count, up.0, up.1, up.2, up.3) {
    move_y = move_y - 1.0
  }
  if @types.pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      down.0,
      down.1,
      down.2,
      down.3,
    ) {
    move_y = move_y + 1.0
  }

  game.move_x = @types.clampf(move_x, -1.0, 1.0)
  game.move_y = @types.clampf(move_y, -1.0, 1.0)

  let pointer_in_world : Bool = @types.point_in_rect(
    mx, my, @types.world_x0, @types.world_y0, @types.world_w, @types.world_h,
  )
  if pointer_in_world {
    game.aim_x = mx
    game.aim_y = my
  }

  let key_fire_hold : Bool = @raylib.is_key_down(@raylib.KeySpace) ||
    @raylib.is_key_down(@raylib.KeyJ) ||
    @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)

  let touch_fire : Bool = @types.pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    fire_btn.0,
    fire_btn.1,
    fire_btn.2,
    fire_btn.3,
  )

  if key_fire_hold {
    ignore(game.try_fire(game.aim_x, game.aim_y))
  } else if touch_fire {
    let target = game.best_auto_aim()
    game.aim_x = target.0
    game.aim_y = target.1
    ignore(game.try_fire(game.aim_x, game.aim_y))
  }

  if @raylib.is_key_pressed(@raylib.KeyE) ||
    (
      game.touch_cd <= 0.0 &&
      @types.pointer_on_rect(
        mx,
        my,
        hold,
        touch_count,
        repair_btn.0,
        repair_btn.1,
        repair_btn.2,
        repair_btn.3,
      )
    ) {
    ignore(game.try_repair())
    game.touch_cd = 0.14
  }

  if @raylib.is_key_pressed(@raylib.KeyH) ||
    (
      game.touch_cd <= 0.0 &&
      @types.pointer_on_rect(
        mx,
        my,
        hold,
        touch_count,
        hint_btn.0,
        hint_btn.1,
        hint_btn.2,
        hint_btn.3,
      )
    ) {
    ignore(game.use_hint())
    game.touch_cd = 0.16
  }

  if game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      restart_btn.0,
      restart_btn.1,
      restart_btn.2,
      restart_btn.3,
    ) {
    game.start_run()
    game.touch_cd = 0.16
  }

  game.clamp_aim_inside_world()
}
