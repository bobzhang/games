///|
fn @types.Game::clear_cores(game : @types.Game) -> Unit {
  for i in 0..<game.cores.length() {
    game.cores[i] = @types.BioCore::inactive()
  }
  game.cores_goal = 0
  game.cores_destroyed = 0
}

///|
fn @types.Game::alloc_core_slot(game : @types.Game) -> Int {
  for i, slot in game.cores {
    if !slot.active {
      break i
    }
  } nobreak {
    -1
  }
}

///|
fn @types.Game::spawn_core_entity(
  game : @types.Game,
  x : Float,
  y : Float,
  hp : Int,
) -> Bool {
  let slot = game.alloc_core_slot()
  if slot < 0 {
    return false
  }

  let core = game.cores[slot]
  core.active = true
  core.x = x
  core.y = y
  core.hp = hp.clamp(min=4, max=999)
  core.max_hp = core.hp
  core.pulse = @types.rand_rangef(game, 0.0, 6.2)
  core.flash = 0.0
  true
}

///|
fn core_goal_for_stage(stage : Int) -> Int {
  let wave = stage + 1
  (3 + wave / 4).clamp(min=3, max=8)
}

///|
fn tile_is_core_spawnable(tile : @types.Tile) -> Bool {
  match tile {
    Empty | Bush | Ice => true
    Brick | Steel | Water | Base => false
  }
}

///|
fn @types.Game::try_spawn_core_at_tile(
  game : @types.Game,
  tx : Int,
  ty : Int,
  hp : Int,
) -> Bool {
  if !@types.in_tile_bounds(tx, ty) {
    return false
  }
  if Float::from_int(tx - @types.base_tile_x).abs() <= 2.0 &&
    Float::from_int(ty - @types.base_tile_y).abs() <= 2.0 {
    return false
  }

  let tile = @types.get_tile(game, tx, ty)
  if !tile_is_core_spawnable(tile) {
    return false
  }

  let x = @types.tile_center_x(tx)
  let y = @types.tile_center_y(ty)

  for core in game.cores {
    if !core.active {
      continue
    }
    if @types.distance_sq(x, y, core.x, core.y) <= 3000.0 {
      return false
    }
  }

  game.spawn_core_entity(x, y, hp)
}

///|
fn @types.Game::seed_stage_cores(game : @types.Game, stage : Int) -> Unit {
  game.clear_cores()
  let wave = stage + 1
  let hp = @types.core_hp_base + wave * 2
  game.cores_goal = core_goal_for_stage(stage)

  let placed = for tries = 0, placed = 0 {
    if placed >= game.cores_goal || tries >= 1200 {
      break placed
    }
    let tx = @types.rand_range(game, 2, @types.map_tiles_w - 3)
    let ty = @types.rand_range(game, 2, @types.map_tiles_h - 3)
    if game.try_spawn_core_at_tile(tx, ty, hp) {
      continue tries + 1, placed + 1
    }
    continue tries + 1, placed
  }

  let placed = if placed < game.cores_goal {
    for ty = 2, placed = placed {
      if ty >= @types.map_tiles_h - 2 || placed >= game.cores_goal {
        break placed
      }
      let placed = for tx = 2, placed = placed {
        if tx >= @types.map_tiles_w - 2 || placed >= game.cores_goal {
          break placed
        }
        if game.try_spawn_core_at_tile(tx, ty, hp) {
          continue tx + 1, placed + 1
        }
        continue tx + 1, placed
      }
      continue ty + 1, placed
    }
  } else {
    placed
  }

  game.cores_goal = placed
}

///|
fn @types.Game::core_objective_done(game : @types.Game) -> Bool {
  if game.cores_goal <= 0 {
    true
  } else {
    game.cores_destroyed >= game.cores_goal
  }
}

///|
fn @types.Game::damage_core(
  game : @types.Game,
  index : Int,
  team : @types.Team,
  power : Int,
) -> Bool {
  if index < 0 || index >= game.cores.length() {
    return false
  }

  let core = game.cores[index]
  if !core.active {
    return false
  }

  core.hp -= power.clamp(min=1, max=8)
  core.flash = 0.14
  @particles.spawn_spark_burst(game, core.x, core.y, 8)

  if core.hp <= 0 {
    core.active = false
    game.cores_destroyed += 1

    let bonus = @types.core_score_base +
      (game.stage_index * 18).clamp(min=0, max=480)
    @score.grant_score(game, team, bonus)
    @particles.spawn_explosion(game, core.x, core.y, 1.8)
    @types.push_camera_shake(game, 2.2)
  } else {
    @types.push_camera_shake(game, 0.7)
  }

  true
}

///|
fn @types.Game::update_cores(game : @types.Game, dt : Float) -> Unit {
  for core in game.cores {
    if !core.active {
      continue
    }
    core.pulse += dt * 3.8
    core.flash -= dt
    if core.flash < 0.0 {
      core.flash = 0.0
    }
  }
}
