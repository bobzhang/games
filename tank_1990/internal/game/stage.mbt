///|
/// Removes all active enemies, bullets, particles, and powerups from the game
/// and resets stage-related timers and counters to prepare for a new stage.
fn @types.Game::clear_entities_for_stage(game : @types.Game) -> Unit {
  for i in 0..<game.enemies.length() {
    game.enemies[i] = @types.Tank::inactive()
  }
  for i in 0..<game.bullets.length() {
    game.bullets[i] = @types.Bullet::inactive()
  }
  for i in 0..<game.particles.length() {
    game.particles[i] = @types.Particle::inactive()
  }
  for i in 0..<game.powerups.length() {
    game.powerups[i] = @types.Powerup::inactive()
  }
  game.enemies_alive = 0
  game.enemies_spawned = 0
  game.spawn_timer = @types.enemy_spawn_period * game.profile.spawn_scale
  game.freeze_all_timer = 0.0
  game.shovel_timer = 0.0
  game.kill_combo = 0
  game.combo_timer = 0.0
  game.base_flash = 0.0
}

///|
/// Calculates the total number of enemies for a given stage. Higher stages
/// have more enemies, clamped between 18 and 44.
fn stage_enemy_total(stage : Int) -> Int {
  let wave = stage + 1
  (16 + wave * 2).clamp(min=18, max=44)
}

///|
/// Randomly picks an enemy type (Basic, Fast, Sniper, or Heavy) for a newly
/// spawned enemy. Later stages increase the chance of tougher enemy types.
fn @types.Game::stage_enemy_kind(
  game : @types.Game,
  stage : Int,
  spawned_index : Int,
) -> @types.EnemyKind {
  let wave = stage + 1
  let roll = @types.rand_range(game, 0, 99)
  if wave < 4 {
    if roll < 70 {
      Basic
    } else if roll < 88 {
      Fast
    } else if roll < 96 {
      Sniper
    } else {
      Heavy
    }
  } else if wave < 10 {
    if roll < 52 {
      Basic
    } else if roll < 72 {
      Fast
    } else if roll < 88 {
      Sniper
    } else {
      Heavy
    }
  } else {
    let bias = (spawned_index + wave) % 6
    if bias == 0 {
      Heavy
    } else if roll < 36 {
      Basic
    } else if roll < 58 {
      Fast
    } else if roll < 80 {
      Sniper
    } else {
      Heavy
    }
  }
}

///|
/// Converts a single ASCII character from a level pattern string into its
/// corresponding tile type and hit-point value (e.g., '#' becomes Brick with 1 HP).
fn parse_level_char(ch : Byte) -> (@types.Tile, Int) {
  if ch == b'#' {
    (Brick, 1)
  } else if ch == b'@' {
    (Steel, 999)
  } else if ch == b'~' {
    (Water, 1)
  } else if ch == b'^' {
    (Bush, 1)
  } else if ch == b'=' {
    (Ice, 1)
  } else if ch == b'B' {
    (Base, 1)
  } else {
    (Empty, 0)
  }
}

///|
/// Saves the current tile types around the player base into a cache so they
/// can be restored later after a shovel powerup wears off.
fn @types.Game::cache_base_ring(game : @types.Game) -> Unit {
  for i in 0..<@types.base_ring_count {
    let tx = @types.base_ring_x[i]
    let ty = @types.base_ring_y[i]
    game.base_tiles_cached[i] = game.get_tile(tx, ty)
  }
}

///|
/// Upgrades the tiles surrounding the player base to steel walls, creating a
/// temporary fortress when the shovel powerup is collected.
fn @types.Game::apply_shovel_fortress(game : @types.Game) -> Unit {
  for i in 0..<@types.base_ring_count {
    let tx = @types.base_ring_x[i]
    let ty = @types.base_ring_y[i]
    let tile = game.get_tile(tx, ty)
    if tile != Base {
      game.set_tile(tx, ty, Steel, 999)
    }
  }
}

///|
/// Restores the tiles around the player base back to their original types
/// from the cache after the shovel powerup effect expires.
fn @types.Game::restore_base_ring(game : @types.Game) -> Unit {
  for i in 0..<@types.base_ring_count {
    let tx = @types.base_ring_x[i]
    let ty = @types.base_ring_y[i]
    let cached = game.base_tiles_cached[i]
    if game.get_tile(tx, ty) != Base {
      match cached {
        Steel => game.set_tile(tx, ty, Steel, 999)
        Brick => game.set_tile(tx, ty, Brick, 1)
        Empty => game.set_tile(tx, ty, Empty, 0)
        _ => game.set_tile(tx, ty, cached, 1)
      }
    }
  }
}

///|
/// Places a player tank back at its spawn point with default stats and a brief
/// invulnerability period. The player index (0 or 1) determines the spawn location.
fn @types.Game::respawn_player_tank(game : @types.Game, index : Int) -> Unit {
  let spawn_x = if index == 0 {
    @types.player1_spawn_x
  } else {
    @types.player2_spawn_x
  }
  let spawn_y = if index == 0 {
    @types.player1_spawn_y
  } else {
    @types.player2_spawn_y
  }
  let player = game.players[index]
  player.active = true
  player.x = spawn_x
  player.y = spawn_y
  player.spawn_x = spawn_x
  player.spawn_y = spawn_y
  player.hp = 1
  player.max_hp = 1
  player.move_speed = @types.speed_player
  player.reload_delay = @types.player_reload_base *
    (1.0 - Float::from_int(player.weapon_level) * 0.07)
  player.reload_timer = 0.0
  player.ai_move_timer = 0.0
  player.ai_fire_timer = 0.0
  player.ai_stuck_timer = 0.0
  player.dir = Up
  player.invuln_timer = @types.player_invuln_spawn
  player.shield_timer = 0.0
  player.respawn_timer = 0.0
  player.skid_timer = 0.0
  player.blink_timer = 0.0
}

///|
/// Sets up all player tanks at the start of a new stage. Players with remaining
/// lives are respawned; players with zero lives are deactivated.
fn @types.Game::prepare_players_for_stage(game : @types.Game) -> Unit {
  for i in 0..<@types.max_players {
    if i == 1 && !game.coop_enabled {
      game.players[i].active = false
      game.players[i].lives = 0
      game.players[i].respawn_timer = 0.0
      continue
    }
    if game.players[i].lives < 0 {
      game.players[i].lives = 0
    }
    if game.players[i].lives == 0 {
      game.players[i].active = false
      game.players[i].respawn_timer = 0.0
    } else {
      game.respawn_player_tank(i)
    }
  }
}

///|
/// Reads the level pattern for the given stage and fills the tile map with
/// walls, water, bushes, ice, and the player base.
fn @types.Game::load_stage_map(game : @types.Game, stage : Int) -> Unit {
  let rows = @levels.level_pattern(stage)
  for y in 0..<@types.map_tiles_h {
    let bytes = rows[y]
    for x in 0..<@types.map_tiles_w {
      let ch = bytes[x]
      let (tile, hp) = parse_level_char(ch)
      game.set_tile(x, y, tile, hp)
    }
  }

  // Guarantee a fortified base shell in case the pattern is too open.
  for i in 0..<@types.base_ring_count {
    let tx = @types.base_ring_x[i]
    let ty = @types.base_ring_y[i]
    if game.get_tile(tx, ty) == Empty {
      game.set_tile(tx, ty, Brick, 1)
    }
  }

  game.set_tile(@types.base_tile_x, @types.base_tile_y, Base, 1)
  game.set_tile(@types.base_tile_x + 1, @types.base_tile_y, Base, 1)

  game.base_alive = true
  game.cache_base_ring()
}

///|
/// Resets the entire campaign to its initial state: score set to zero, stage
/// index back to the first level, and both player tanks freshly created.
fn @types.Game::reset_campaign(game : @types.Game) -> Unit {
  game.score_total = 0
  game.stage_index = 0
  for i in 0..<@types.max_players {
    game.players[i] = if i == 0 {
      @types.Tank::new_player(0, @types.player1_spawn_x, @types.player1_spawn_y)
    } else {
      @types.Tank::new_player(1, @types.player2_spawn_x, @types.player2_spawn_y)
    }
    if i == 1 && !game.coop_enabled {
      game.players[i].active = false
      game.players[i].lives = 0
    }
  }
}

///|
/// Loads a specific stage by clearing old entities, building the tile map,
/// spawning players, and configuring enemy counts and intro timing.
fn @types.Game::load_stage(game : @types.Game, stage : Int) -> Unit {
  game.profile = @levels.get_stage_profile(stage)
  game.clear_entities_for_stage()
  game.load_stage_map(stage)
  game.prepare_players_for_stage()
  let base_total = stage_enemy_total(stage)
  game.enemies_to_spawn = (base_total + game.profile.enemy_bonus).clamp(
    min=18,
    max=60,
  )
  game.stage_intro_timer = if game.demo_mode {
    0.45
  } else {
    @types.stage_intro_time
  }
  game.stage_clear_timer = 0.0
  game.game_over_timer = 0.0
  game.campaign_clear_timer = 0.0
  game.state = StageIntro
}

///|
/// Begins a brand-new campaign from scratch by resetting all progress and
/// loading the very first stage.
fn @types.Game::start_new_campaign(game : @types.Game) -> Unit {
  game.reset_campaign()
  game.load_stage(0)
}
