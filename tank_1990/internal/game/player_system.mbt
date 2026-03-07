///|
/// Checks whether the player at the given index is enabled. Player 0 is always
/// enabled; player 1 is only enabled when co-op mode is turned on.
fn @types.Game::is_player_enabled(game : @types.Game, index : Int) -> Bool {
  if index == 0 {
    true
  } else {
    game.coop_enabled
  }
}

///|
/// Reads the keyboard to determine which direction the player wants to move.
/// Player 0 uses the arrow keys; player 1 uses W/A/S/D. Returns None if no
/// movement key is held down.
fn read_player_move_dir(index : Int) -> @types.Dir? {
  if index == 0 {
    if @raylib.is_key_down(@raylib.KeyUp) {
      Some(Up)
    } else if @raylib.is_key_down(@raylib.KeyDown) {
      Some(Down)
    } else if @raylib.is_key_down(@raylib.KeyLeft) {
      Some(Left)
    } else if @raylib.is_key_down(@raylib.KeyRight) {
      Some(Right)
    } else {
      None
    }
  } else if @raylib.is_key_down(@raylib.KeyW) {
    Some(Up)
  } else if @raylib.is_key_down(@raylib.KeyS) {
    Some(Down)
  } else if @raylib.is_key_down(@raylib.KeyA) {
    Some(Left)
  } else if @raylib.is_key_down(@raylib.KeyD) {
    Some(Right)
  } else {
    None
  }
}

///|
/// Returns true if the shoot key for the given player is currently held down.
/// Player 0 shoots with Right Shift or Enter; player 1 shoots with Space.
fn is_player_shoot_pressed(index : Int) -> Bool {
  if index == 0 {
    @raylib.is_key_down(@raylib.KeyRightShift) ||
    @raylib.is_key_down(@raylib.KeyEnter)
  } else {
    @raylib.is_key_down(@raylib.KeySpace)
  }
}

///|
/// Checks whether the player's tank is currently standing on an ice tile, which
/// causes the tank to slide and skid.
fn @types.Game::player_is_on_ice(
  game : @types.Game,
  player : @types.Tank,
) -> Bool {
  let tx = @types.world_x_to_tile(player.x)
  let ty = @types.world_y_to_tile(player.y)
  game.get_tile(tx, ty) == Ice
}

///|
/// Determines whether the player is allowed to fire a bullet right now. A player
/// cannot fire if the tank is inactive, the reload cooldown has not expired, or
/// the maximum number of active bullets for this player has been reached.
fn @types.Game::can_player_fire(game : @types.Game, index : Int) -> Bool {
  let player = game.players[index]
  if !player.active {
    return false
  }
  if player.reload_timer > 0.0 {
    return false
  }

  let team = @types.team_of_player(index)
  let mut active_count = 0
  for bullet in game.bullets {
    if bullet.active && bullet.owner_team == team {
      active_count += 1
    }
  }

  let cap = if player.weapon_level >= 2 { 2 } else { 1 }
  active_count < cap
}

///|
/// Ticks down all per-player timers each frame, including the reload cooldown,
/// invulnerability timer, shield timer, ice-skid timer, and the visual blink
/// counter used for flashing effects.
fn @types.Game::update_player_reload_timers(
  game : @types.Game,
  dt : Float,
) -> Unit {
  for i in 0..<@types.max_players {
    let player = game.players[i]
    if player.reload_timer > 0.0 {
      player.reload_timer -= dt
      if player.reload_timer < 0.0 {
        player.reload_timer = 0.0
      }
    }
    if player.invuln_timer > 0.0 {
      player.invuln_timer -= dt
      if player.invuln_timer < 0.0 {
        player.invuln_timer = 0.0
      }
    }
    if player.shield_timer > 0.0 {
      player.shield_timer -= dt
      if player.shield_timer < 0.0 {
        player.shield_timer = 0.0
      }
    }
    if player.skid_timer > 0.0 {
      player.skid_timer -= dt
      if player.skid_timer < 0.0 {
        player.skid_timer = 0.0
      }
    }
    player.blink_timer += dt * 5.0
  }
}

///|
/// Attempts to move a player's tank one step in the given direction. The move is
/// rejected if the new position would collide with a wall, another player, or an
/// enemy tank.
fn @types.Game::try_move_player(
  game : @types.Game,
  index : Int,
  dir : @types.Dir,
  dt : Float,
) -> Unit {
  let player = game.players[index]
  if !player.active {
    return
  }

  let vx = @types.dir_vector_x(dir)
  let vy = @types.dir_vector_y(dir)
  let step = player.move_speed * dt
  let nx = player.x + vx * step
  let ny = player.y + vy * step

  if @world.tank_hits_world(game, nx, ny) {
    return
  }
  if @world.tank_hits_players(game, nx, ny, index) {
    return
  }
  if @world.tank_hits_enemies(game, nx, ny, -1) {
    return
  }

  player.x = nx
  player.y = ny
}

///|
/// Processes player input (or demo AI commands) each frame for every active
/// player. Handles movement, ice skidding, and firing bullets when the shoot
/// key is pressed and the player is allowed to fire.
fn @types.Game::update_player_input(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<@types.max_players {
    if !game.is_player_enabled(i) {
      continue
    }

    let player = game.players[i]
    if !player.active {
      continue
    }

    let (move_dir, shoot_pressed) = if game.demo_mode {
      game.demo_player_command(i, dt)
    } else {
      (read_player_move_dir(i), is_player_shoot_pressed(i))
    }
    match move_dir {
      Some(dir) => {
        player.dir = dir
        game.try_move_player(i, dir, dt)
        if game.player_is_on_ice(player) {
          player.skid_timer = 0.12
        }
      }
      None =>
        if player.skid_timer > 0.0 && game.player_is_on_ice(player) {
          game.try_move_player(i, player.dir, dt * 0.55)
        }
    }

    if shoot_pressed && game.can_player_fire(i) {
      let muzzle_x = player.x +
        @types.dir_vector_x(player.dir) * (@types.tank_half + 3.0)
      let muzzle_y = player.y +
        @types.dir_vector_y(player.dir) * (@types.tank_half + 3.0)
      let speed = @types.bullet_speed_player +
        Float::from_int(player.weapon_level) * 38.0
      let power = if player.weapon_level >= 3 {
        3
      } else if player.weapon_level >= 1 {
        2
      } else {
        1
      }
      game.spawn_bullet(
        @types.team_of_player(i),
        muzzle_x,
        muzzle_y,
        player.dir,
        speed,
        power,
      )
      player.reload_timer = player.reload_delay
      @particles.spawn_spark_burst(game, muzzle_x, muzzle_y, 5)
    }
  }
}

///|
/// Handles what happens when a player's tank is hit. If the player has
/// invulnerability or a shield active the hit is absorbed with a spark effect.
/// Otherwise the tank is destroyed: lives are decremented, weapon level drops,
/// an explosion is spawned, and a respawn timer begins.
fn @types.Game::on_player_destroyed(game : @types.Game, index : Int) -> Unit {
  let player = game.players[index]
  if !player.active {
    return
  }
  if player.invuln_timer > 0.0 || player.shield_timer > 0.0 {
    @particles.spawn_spark_burst(game, player.x, player.y, 7)
    return
  }

  player.active = false
  player.lives -= 1
  if player.weapon_level > 0 {
    player.weapon_level -= 1
  }
  player.reload_delay = @types.player_reload_base *
    (1.0 - Float::from_int(player.weapon_level) * 0.08)
  if player.reload_delay < 0.12 {
    player.reload_delay = 0.12
  }
  player.respawn_timer = @types.player_respawn_delay
  @particles.spawn_explosion(game, player.x, player.y, 1.25)
}

///|
/// Counts down the respawn timer for each destroyed player who still has lives
/// remaining. When the timer reaches zero the tank is placed back on the field
/// and a respawn particle burst is shown.
fn @types.Game::update_player_respawns(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<@types.max_players {
    if !game.is_player_enabled(i) {
      continue
    }
    let player = game.players[i]
    if player.active {
      continue
    }
    if player.lives <= 0 {
      continue
    }
    player.respawn_timer -= dt
    if player.respawn_timer <= 0.0 {
      game.respawn_player_tank(i)
      @particles.spawn_respawn_burst(game, player.x, player.y)
    }
  }
}

///|
/// Returns true when every enabled player is both inactive (destroyed) and has
/// zero lives left, meaning the game is over.
fn @types.Game::all_players_out(game : @types.Game) -> Bool {
  let mut living = 0
  for i in 0..<@types.max_players {
    if !game.is_player_enabled(i) {
      continue
    }
    let player = game.players[i]
    if player.active || player.lives > 0 {
      living += 1
    }
  }
  living == 0
}
