///|
fn axis(negative : Bool, positive : Bool) -> Float {
  if negative && !positive {
    -1.0
  } else if positive && !negative {
    1.0
  } else {
    0.0
  }
}

///|
fn should_start_duel() -> Bool {
  @raylib.is_key_pressed(@raylib.KeyEnter) ||
  @raylib.is_key_pressed(@raylib.KeyJ) ||
  @raylib.is_key_pressed(@raylib.KeyK) ||
  @raylib.is_key_pressed(@raylib.KeySpace)
}

///|
fn @types.Game::update_input(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyR) {
    game.start_new_run()
    return
  }

  match game.state {
    Title => {
      if should_start_duel() {
        game.start_new_run()
      }
      return
    }
    GameOver => {
      if should_start_duel() {
        game.start_new_run()
      }
      return
    }
    Paused => {
      if @raylib.is_key_pressed(@raylib.KeyP) {
        game.state = Playing
        @types.set_message(game, "Duel resumed.", 0.8)
      }
      return
    }
    Playing => ()
  }

  if @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = Paused
    @types.set_message(game, "Paused.", 10.0)
    return
  }

  let left : Bool = @raylib.is_key_down(@raylib.KeyA) ||
    @raylib.is_key_down(@raylib.KeyLeft)
  let right : Bool = @raylib.is_key_down(@raylib.KeyD) ||
    @raylib.is_key_down(@raylib.KeyRight)
  let up : Bool = @raylib.is_key_down(@raylib.KeyW) ||
    @raylib.is_key_down(@raylib.KeyUp)
  let down : Bool = @raylib.is_key_down(@raylib.KeyS) ||
    @raylib.is_key_down(@raylib.KeyDown)

  game.move_x = axis(left, right)
  game.move_y = axis(up, down)

  if game.move_x.abs() + game.move_y.abs() > 0.01 {
    let facing = @types.normalize(game.move_x, game.move_y)
    game.facing_x = facing.0
    game.facing_y = facing.1
  }

  if @raylib.is_key_pressed(@raylib.KeyJ) {
    ignore(game.try_player_attack(Light))
  }

  if @raylib.is_key_pressed(@raylib.KeyK) {
    ignore(game.try_player_attack(Heavy))
  }

  if @raylib.is_key_pressed(@raylib.KeyL) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    ignore(game.trigger_parry_dash())
  }
}
