///|
/// Returns the x-coordinate for an enemy spawn point based on the given lane slot (0, 1, or 2).
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
/// Finds the first inactive enemy slot in the enemies array and returns its index, or -1 if all slots are in use.
fn @types.Game::alloc_enemy_slot(game : @types.Game) -> Int {
  for i, slot in game.enemies {
    if !slot.active {
      break i
    }
  } nobreak {
    -1
  }
}

///|
/// Attempts to spawn a new enemy tank at a random lane. Returns true if an enemy was successfully placed, or false if the spawn limit was reached, the field is full, or the chosen position is blocked.
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
/// Picks the closest active player to the given enemy tank and returns that player's index, or -1 if no players are alive.
fn @types.Game::choose_enemy_target_player(
  game : @types.Game,
  enemy : @types.Tank,
) -> Int {
  for i in 0..<@types.max_players;
      best_idx = -1, best_dist = Float::from_int(1000000000) {
    let player = game.players[i]
    if player.active {
      let d = @types.distance_sq(enemy.x, enemy.y, player.x, player.y)
      if d < best_dist {
        continue i, d
      }
    }
  } nobreak {
    best_idx
  }
}

///|
/// Decides which direction an enemy tank wants to move. It usually aims toward the nearest player or the base, with some randomness mixed in to keep movement unpredictable.
fn @types.Game::enemy_desired_dir(
  game : @types.Game,
  enemy : @types.Tank,
) -> @types.Dir {
  let target_player = game.choose_enemy_target_player(enemy)
  let base_x = @types.tile_center_x(@types.base_tile_x)
  let base_y = @types.tile_center_y(@types.base_tile_y)
  let (target_x, target_y) = if target_player >= 0 {
    let player = game.players[target_player]
    if @types.rand_range(game, 0, 99) < 62 {
      (player.x, player.y)
    } else {
      (base_x, base_y)
    }
  } else {
    (base_x, base_y)
  }

  let dx = target_x - enemy.x
  let dy = target_y - enemy.y
  let horiz : @types.Dir = if dx < 0.0 { Left } else { Right }
  let vert : @types.Dir = if dy < 0.0 { Up } else { Down }

  let r = @types.rand_range(game, 0, 99)
  if dx.abs() > dy.abs() {
    if r < 72 {
      horiz
    } else if r < 92 {
      vert
    } else {
      @types.rand_dir(game)
    }
  } else if r < 72 {
    vert
  } else if r < 92 {
    horiz
  } else {
    @types.rand_dir(game)
  }
}

///|
/// Tries to move the enemy tank at the given index one step in the specified direction. Returns true if the move succeeded, or false if the path is blocked by walls, other enemies, or players.
fn @types.Game::try_move_enemy(
  game : @types.Game,
  enemy_index : Int,
  dir : @types.Dir,
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
  if @world.tank_hits_players(game, nx, ny, -1) {
    return false
  }

  enemy.x = nx
  enemy.y = ny
  true
}

///|
/// Checks whether the enemy tank at the given index should fire a bullet this frame. It considers line-of-sight to players and the base, reload cooldown, and a random chance that varies by enemy type.
fn @types.Game::enemy_shoot_if_ready(
  game : @types.Game,
  enemy_index : Int,
) -> Unit {
  let enemy = game.enemies[enemy_index]
  if enemy.reload_timer > 0.0 || enemy.invuln_timer > 0.0 {
    return
  }

  let target_player = game.choose_enemy_target_player(enemy)
  let fire_on_player = if target_player >= 0 {
    let player = game.players[target_player]
    if (player.x - enemy.x).abs() < Float::from_int(@types.tile_size) * 0.5 ||
      (player.y - enemy.y).abs() < Float::from_int(@types.tile_size) * 0.5 {
      !@world.sight_blocked(game, enemy.x, enemy.y, player.x, player.y)
    } else {
      false
    }
  } else {
    false
  }

  let fire_on_base = if fire_on_player {
    false
  } else {
    let base_x = @types.tile_center_x(@types.base_tile_x)
    let base_y = @types.tile_center_y(@types.base_tile_y)
    if (base_x - enemy.x).abs() < Float::from_int(@types.tile_size) * 0.5 ||
      (base_y - enemy.y).abs() < Float::from_int(@types.tile_size) * 0.5 {
      !@world.sight_blocked(game, enemy.x, enemy.y, base_x, base_y)
    } else {
      false
    }
  }

  let should_fire = if fire_on_player || fire_on_base {
    true
  } else {
    let chance = match enemy.enemy_kind {
      Fast => 16
      Heavy => 11
      Sniper => 26
      Basic => 13
    }
    @types.rand_range(game, 0, 99) < chance
  }

  if should_fire {
    let muzzle_x = enemy.x +
      @types.dir_vector_x(enemy.dir) * (@types.tank_half + 3.0)
    let muzzle_y = enemy.y +
      @types.dir_vector_y(enemy.dir) * (@types.tank_half + 3.0)
    let speed = match enemy.enemy_kind {
      Sniper => @types.bullet_speed_enemy + 40.0
      _ => @types.bullet_speed_enemy
    }
    let power = match enemy.enemy_kind {
      Heavy => 2
      _ => 1
    }
    game.spawn_bullet(Enemy, muzzle_x, muzzle_y, enemy.dir, speed, power)
    enemy.reload_timer = enemy.reload_delay
    @particles.spawn_spark_burst(game, muzzle_x, muzzle_y, 4)
  }
}

///|
/// Counts down the spawn timer each frame and spawns a new enemy when the timer expires, as long as there are still enemies left to introduce in the current stage.
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
/// Runs one frame of AI logic for every active enemy: updates cooldown timers, picks a movement direction, moves the tank, and fires bullets when appropriate. Enemies are frozen while the freeze-all timer is active.
fn @types.Game::update_enemies(game : @types.Game, dt : Float) -> Unit {
  for i, enemy in game.enemies {
    if !enemy.active {
      continue
    }

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
    if !moved {
      enemy.ai_stuck_timer += dt
      if enemy.ai_stuck_timer > 0.14 {
        enemy.ai_stuck_timer = 0.0
        enemy.dir = @types.rand_dir(game)
      }
    } else {
      enemy.ai_stuck_timer = 0.0
    }

    if enemy.ai_fire_timer <= 0.0 {
      enemy.ai_fire_timer = @types.rand_rangef(game, 0.18, 0.62)
      game.enemy_shoot_if_ready(i)
    }
  }
}

///|
/// Removes the enemy at the given index from play, awards score to the killing team with a combo multiplier, triggers an explosion effect, and may drop a random powerup.
fn @types.Game::destroy_enemy(
  game : @types.Game,
  enemy_index : Int,
  killer_team : @types.Team,
) -> Unit {
  if !game.enemies[enemy_index].active {
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
  let base_bias = match enemy.enemy_kind {
    Heavy => 22
    _ => 14
  }
  let drop_bias = (base_bias + game.profile.drop_bonus).clamp(min=4, max=55)
  if drop_roll < drop_bias {
    game.spawn_random_powerup(enemy.x, enemy.y)
  }
}

///|
/// Returns true when all enemies for the current stage have been spawned and destroyed, meaning the player has cleared the stage.
fn @types.Game::stage_is_clear(game : @types.Game) -> Bool {
  game.enemies_spawned >= game.enemies_to_spawn && game.enemies_alive <= 0
}
