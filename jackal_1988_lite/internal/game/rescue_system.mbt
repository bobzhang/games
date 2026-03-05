///|
fn @types.Game::clear_hostages(game : @types.Game) -> Unit {
  for i in 0..<game.hostages.length() {
    game.hostages[i] = @types.Hostage::inactive()
  }
  game.hostages_rescued = 0
  game.rescue_stage_bonus_awarded = false
}

///|
fn @types.Game::alloc_hostage_slot(game : @types.Game) -> Int {
  for i in 0..<game.hostages.length() {
    if not(game.hostages[i].active) {
      return i
    }
  }
  -1
}

///|
fn hostage_goal_for_stage(stage : Int) -> Int {
  let wave = stage + 1
  (@types.rescue_goal_base + wave / 3).clamp(
    min=@types.rescue_goal_base,
    max=12,
  )
}

///|
fn tile_is_hostage_spawnable(tile : Int) -> Bool {
  tile == @types.tile_empty ||
  tile == @types.tile_bush ||
  tile == @types.tile_ice
}

///|
fn @types.Game::try_spawn_hostage_at_tile(game : @types.Game, tx : Int, ty : Int) -> Bool {
  if not(@types.in_tile_bounds(tx, ty)) {
    return false
  }
  if Float::from_int(tx - @types.base_tile_x).abs() <= 2.0 &&
    Float::from_int(ty - @types.base_tile_y).abs() <= 2.0 {
    return false
  }
  let tile = @types.get_tile(game, tx, ty)
  if not(tile_is_hostage_spawnable(tile)) {
    return false
  }

  let slot = game.alloc_hostage_slot()
  if slot < 0 {
    return false
  }

  let hostage = game.hostages[slot]
  hostage.active = true
  hostage.x = @types.tile_center_x(tx)
  hostage.y = @types.tile_center_y(ty)
  hostage.bob = @types.rand_rangef(game, 0.0, 6.28)
  hostage.blink = @types.rand_rangef(game, 0.0, 2.0)

  if tile == @types.tile_empty {
    @types.set_tile(game, tx, ty, @types.tile_camp, 1)
  }
  true
}

///|
fn @types.Game::seed_stage_hostages(game : @types.Game, stage : Int) -> Unit {
  game.clear_hostages()
  game.hostages_goal = hostage_goal_for_stage(stage)

  let mut placed = 0
  let mut attempts = 0
  while placed < game.hostages_goal && attempts < 900 {
    attempts += 1
    let tx = @types.rand_range(game, 1, @types.map_tiles_w - 2)
    let ty = @types.rand_range(game, 2, @types.map_tiles_h - 4)
    if game.try_spawn_hostage_at_tile(tx, ty) {
      placed += 1
    }
  }

  if placed < game.hostages_goal {
    for ty = 3
        ty < @types.map_tiles_h - 3 && placed < game.hostages_goal
        ty = ty + 1 {
      for tx = 2
          tx < @types.map_tiles_w - 2 && placed < game.hostages_goal
          tx = tx + 1 {
        if game.try_spawn_hostage_at_tile(tx, ty) {
          placed += 1
        }
      }
    }
  }

  game.hostages_goal = placed
}

///|
fn @types.Game::rescue_objective_done(game : @types.Game) -> Bool {
  if game.hostages_goal <= 0 {
    true
  } else {
    game.hostages_rescued >= game.hostages_goal
  }
}

///|
fn @types.Game::update_hostages(game : @types.Game, dt : Float) -> Unit {
  let pickup_r2 = @types.rescue_pickup_radius * @types.rescue_pickup_radius

  for hostage in game.hostages {
    if not(hostage.active) {
      continue
    }

    hostage.bob += dt * 3.4
    hostage.blink += dt

    for p in 0..<@types.max_players {
      let player = game.players[p]
      if not(player.active) {
        continue
      }

      if @types.distance_sq(hostage.x, hostage.y, player.x, player.y) <=
        pickup_r2 {
        hostage.active = false
        game.hostages_rescued += 1

        let team = @types.team_of_player(p)
        @score.grant_score(game, team, @types.rescue_score_each)
        @particles.spawn_spark_burst(game, hostage.x, hostage.y - 8.0, 12)
        @particles.spawn_respawn_burst(game, hostage.x, hostage.y)

        if game.rescue_objective_done() && not(game.rescue_stage_bonus_awarded) {
          game.rescue_stage_bonus_awarded = true
          @score.grant_score(game, team, @types.rescue_stage_bonus)
          @particles.spawn_spark_burst(
            game,
            Float::from_int(@types.map_pixel_w / 2),
            Float::from_int(@types.map_pixel_h / 2),
            32,
          )
          @types.push_camera_shake(game, 1.9)
        }
        break
      }
    }
  }
}
