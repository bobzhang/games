///|
fn enemy_spawn_x(slot : Int) -> Float {
  if slot == 0 {
    @types.enemy_spawn_x0
  } else if slot == 1 {
    @types.enemy_spawn_x1
  } else {
    @types.enemy_spawn_x2
  }
}

///|
fn @types.Game::alloc_enemy_slot(game : @types.Game) -> Int {
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      return i
    }
  }
  -1
}

///|
fn @types.Game::spawn_enemy(game : @types.Game) -> Bool {
  if game.enemies_spawned >= game.enemies_to_spawn {
    return false
  }
  if game.enemies_alive >= @types.enemy_on_field_limit {
    return false
  }

  let slot = game.alloc_enemy_slot()
  if slot < 0 {
    return false
  }

  let spawn_lane = @types.rand_range(game, 0, 2)
  let sx = enemy_spawn_x(spawn_lane)
  let sy = @types.enemy_spawn_y

  if @world.tank_hits_world(game, sx, sy) ||
    @world.tank_hits_players(game, sx, sy, -1) ||
    @world.tank_hits_enemies(game, sx, sy, -1) {
    return false
  }

  let kind = game.stage_enemy_kind(game.stage_index, game.enemies_spawned)
  game.enemies[slot] = @types.Tank::new_enemy(kind, sx, sy)
  game.enemies_spawned += 1
  game.enemies_alive += 1
  @particles.spawn_respawn_burst(game, sx, sy)
  true
}

///|
fn @types.Game::choose_enemy_target_player(
  game : @types.Game,
  enemy : @types.Tank,
) -> Int {
  let mut best_idx = -1
  let mut best_dist : Float = Float::from_int(1000000000)
  for i in 0..<@types.max_players {
    let player = game.players[i]
    if player.active {
      let d = @types.distance_sq(enemy.x, enemy.y, player.x, player.y)
      if d < best_dist {
        best_dist = d
        best_idx = i
      }
    }
  }
  best_idx
}

///|
fn @types.Game::enemy_desired_dir(
  game : @types.Game,
  enemy : @types.Tank,
) -> Int {
  let target_player = game.choose_enemy_target_player(enemy)
  let mut target_x = @types.tile_center_x(@types.base_tile_x)
  let mut target_y = @types.tile_center_y(@types.base_tile_y)

  if target_player >= 0 {
    let player = game.players[target_player]
    if @types.rand_range(game, 0, 99) < 62 {
      target_x = player.x
      target_y = player.y
    }
  }

  let dx = target_x - enemy.x
  let dy = target_y - enemy.y
  let horiz = if dx < 0.0 { @types.dir_left } else { @types.dir_right }
  let vert = if dy < 0.0 { @types.dir_up } else { @types.dir_down }

  let r = @types.rand_range(game, 0, 99)
  if dx.abs() > dy.abs() {
    if r < 72 {
      horiz
    } else if r < 92 {
      vert
    } else {
      @types.rand_range(game, 0, 3)
    }
  } else if r < 72 {
    vert
  } else if r < 92 {
    horiz
  } else {
    @types.rand_range(game, 0, 3)
  }
}

///|
fn @types.Game::try_move_enemy(
  game : @types.Game,
  enemy_index : Int,
  dir : Int,
  dt : Float,
) -> Bool {
  let enemy = game.enemies[enemy_index]
  let step = enemy.move_speed * dt
  let nx = enemy.x + @types.dir_vector_x(dir) * step
  let ny = enemy.y + @types.dir_vector_y(dir) * step

  if @world.tank_hits_world(game, nx, ny) {
    return false
  }
  if @world.tank_hits_enemies(game, nx, ny, enemy_index) {
    return false
  }

  enemy.x = nx
  enemy.y = ny
  true
}

///|
fn enemy_shoot_if_ready(_game : @types.Game, _enemy_index : Int) -> Unit {
  ()
}

///|
fn @types.Game::update_enemy_spawn(game : @types.Game, dt : Float) -> Unit {
  if game.enemies_spawned >= game.enemies_to_spawn {
    return
  }
  game.spawn_timer -= dt
  if game.spawn_timer <= 0.0 {
    if game.spawn_enemy() {
      game.spawn_timer = @types.enemy_spawn_period * game.profile.spawn_scale
    } else {
      game.spawn_timer = 0.25 * game.profile.spawn_scale
    }
  }
}

///|
fn @types.Game::update_enemies(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      continue
    }

    let enemy = game.enemies[i]
    if enemy.reload_timer > 0.0 {
      enemy.reload_timer -= dt
      if enemy.reload_timer < 0.0 {
        enemy.reload_timer = 0.0
      }
    }
    if enemy.invuln_timer > 0.0 {
      enemy.invuln_timer -= dt
      if enemy.invuln_timer < 0.0 {
        enemy.invuln_timer = 0.0
      }
    }

    if game.freeze_all_timer > 0.0 {
      continue
    }

    enemy.ai_move_timer -= dt
    enemy.ai_fire_timer -= dt

    if enemy.ai_move_timer <= 0.0 {
      enemy.ai_move_timer = @types.rand_rangef(game, 0.35, 1.25)
      let new_dir = game.enemy_desired_dir(enemy)
      enemy.dir = new_dir
    }

    let moved = game.try_move_enemy(i, enemy.dir, dt)
    if not(moved) {
      enemy.ai_stuck_timer += dt
      if enemy.ai_stuck_timer > 0.14 {
        enemy.ai_stuck_timer = 0.0
        enemy.dir = @types.rand_range(game, 0, 3)
      }
    } else {
      enemy.ai_stuck_timer = 0.0
    }

    if enemy.ai_fire_timer <= 0.0 {
      enemy.ai_fire_timer = @types.rand_rangef(game, 0.18, 0.62)
      enemy_shoot_if_ready(game, i)
    }

    for p in 0..<@types.max_players {
      let player = game.players[p]
      if not(player.active) {
        continue
      }
      let hit_r = @types.tank_half + @types.tank_half - 2.0
      if @types.distance_sq(enemy.x, enemy.y, player.x, player.y) <=
        hit_r * hit_r {
        game.on_player_destroyed(p)
      }
    }
  }
}

///|
fn @types.Game::destroy_enemy(
  game : @types.Game,
  enemy_index : Int,
  killer_team : @types.Team,
) -> Unit {
  if not(game.enemies[enemy_index].active) {
    return
  }

  let enemy = game.enemies[enemy_index]
  game.enemies[enemy_index].active = false
  game.enemies_alive -= 1

  let score = @types.enemy_score(enemy.enemy_kind)
  let mult = @score.combo_multiplier(game)
  @score.grant_score(game, killer_team, score * mult)
  @score.bump_combo(game)

  @particles.spawn_explosion(game, enemy.x, enemy.y, 1.1)

  // Chance to drop a powerup.
  let drop_roll = @types.rand_range(game, 0, 99)
  let base_bias = if enemy.enemy_kind == Heavy { 22 } else { 14 }
  let drop_bias = (base_bias + game.profile.drop_bonus).clamp(min=4, max=55)
  if drop_roll < drop_bias {
    game.spawn_random_powerup(enemy.x, enemy.y)
  }
}

///|
fn @types.Game::stage_is_clear(game : @types.Game) -> Bool {
  game.enemies_spawned >= game.enemies_to_spawn && game.enemies_alive <= 0
}
