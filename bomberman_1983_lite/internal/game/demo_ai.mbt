///|
fn opposite_dir(dir : @types.Dir) -> @types.Dir {
  match dir {
    Up => Down
    Down => Up
    Left => Right
    Right => Left
  }
}

///|
fn @types.Game::demo_nearest_enemy(
  game : @types.Game,
  x : Float,
  y : Float,
) -> (Int, Float) {
  for i, enemy in game.enemies;
      best_idx = -1, best_dist = Float::from_int(1000000000) {
    if !enemy.active {
      continue
    }
    let d = @types.distance_sq(x, y, enemy.x, enemy.y)
    if d < best_dist {
      continue i, d
    }
  } nobreak {
    (best_idx, best_dist)
  }
}

///|
fn @types.Game::demo_nearest_powerup(
  game : @types.Game,
  x : Float,
  y : Float,
) -> (Int, Float) {
  for i, powerup in game.powerups;
      best_idx = -1, best_dist = Float::from_int(1000000000) {
    if !powerup.active {
      continue
    }
    let d = @types.distance_sq(x, y, powerup.x, powerup.y)
    if d < best_dist {
      continue i, d
    }
  } nobreak {
    (best_idx, best_dist)
  }
}

///|
fn @types.Game::demo_can_step(
  game : @types.Game,
  index : Int,
  dir : @types.Dir,
  dt : Float,
) -> Bool {
  let player = game.players[index]
  if !player.active {
    return false
  }

  let step = player.move_speed * (dt * 0.9 + 0.014)
  let nx = player.x + @types.dir_vector_x(dir) * step
  let ny = player.y + @types.dir_vector_y(dir) * step

  if @world.tank_hits_world(game, nx, ny) {
    return false
  }
  if @world.tank_hits_players(game, nx, ny, index) {
    return false
  }
  if @world.tank_hits_enemies(game, nx, ny, -1) {
    return false
  }
  true
}

///|
fn @types.Game::demo_priority_dir(
  game : @types.Game,
  index : Int,
  dt : Float,
  a : @types.Dir,
  b : @types.Dir,
  c : @types.Dir,
  d : @types.Dir,
) -> @types.Dir? {
  if game.demo_can_step(index, a, dt) {
    Some(a)
  } else if game.demo_can_step(index, b, dt) {
    Some(b)
  } else if game.demo_can_step(index, c, dt) {
    Some(c)
  } else if game.demo_can_step(index, d, dt) {
    Some(d)
  } else {
    None
  }
}

///|
fn @types.Game::demo_choose_move_dir(
  game : @types.Game,
  index : Int,
  dt : Float,
  target_x : Float,
  target_y : Float,
) -> @types.Dir? {
  let player = game.players[index]
  let dx = target_x - player.x
  let dy = target_y - player.y

  let horiz : @types.Dir = if dx < 0.0 { Left } else { Right }
  let vert : @types.Dir = if dy < 0.0 { Up } else { Down }

  let primary_dir : @types.Dir? = if dx.abs() > dy.abs() {
    game.demo_priority_dir(
      index,
      dt,
      horiz,
      vert,
      opposite_dir(horiz),
      opposite_dir(vert),
    )
  } else {
    game.demo_priority_dir(
      index,
      dt,
      vert,
      horiz,
      opposite_dir(vert),
      opposite_dir(horiz),
    )
  }

  match primary_dir {
    Some(dir) => Some(dir)
    None => {
      let random_dir = @types.Dir::from_int(@types.rand_range(game, 0, 3))
      if game.demo_can_step(index, random_dir, dt) {
        Some(random_dir)
      } else {
        None
      }
    }
  }
}

///|
fn demo_line_shot_dir(
  player_x : Float,
  player_y : Float,
  target_x : Float,
  target_y : Float,
) -> (@types.Dir, Bool) {
  let epsilon = Float::from_int(@types.tile_size) * 0.42
  let dx = target_x - player_x
  let dy = target_y - player_y
  if dx.abs() <= epsilon {
    (if dy < 0.0 { Up } else { Down }, true)
  } else if dy.abs() <= epsilon {
    (if dx < 0.0 { Left } else { Right }, true)
  } else {
    (Up, false)
  }
}

///|
fn @types.Game::demo_target_position(
  game : @types.Game,
  player : @types.Tank,
  nearest_enemy : Int,
  enemy_dist : Float,
  nearest_powerup : Int,
  powerup_dist : Float,
) -> (Float, Float) {
  if nearest_powerup >= 0 &&
    (nearest_enemy < 0 || powerup_dist < enemy_dist * 0.8) {
    (game.powerups[nearest_powerup].x, game.powerups[nearest_powerup].y)
  } else if nearest_enemy >= 0 {
    (game.enemies[nearest_enemy].x, game.enemies[nearest_enemy].y)
  } else {
    let guard_tile_x = if player.x < @types.tile_center_x(@types.base_tile_x) {
      0
    } else {
      1
    }
    let guard_x = @types.tile_center_x(@types.base_tile_x + guard_tile_x)
    let guard_y = @types.tile_center_y(@types.base_tile_y - 1)
    (guard_x, guard_y)
  }
}

///|
fn @types.Game::demo_player_command(
  game : @types.Game,
  index : Int,
  dt : Float,
) -> (@types.Dir?, Bool) {
  let player = game.players[index]
  if !player.active {
    return (None, false)
  }

  let (nearest_enemy, enemy_dist) = game.demo_nearest_enemy(player.x, player.y)
  let (nearest_powerup, powerup_dist) = game.demo_nearest_powerup(
    player.x,
    player.y,
  )
  let (target_x, target_y) = game.demo_target_position(
    player, nearest_enemy, enemy_dist, nearest_powerup, powerup_dist,
  )

  let move_dir0 = game.demo_choose_move_dir(index, dt, target_x, target_y)
  let (move_dir, shoot) = if nearest_enemy >= 0 {
    let enemy = game.enemies[nearest_enemy]
    let (line_dir, aligned) = demo_line_shot_dir(
      player.x,
      player.y,
      enemy.x,
      enemy.y,
    )
    if aligned && !game.sight_blocked(player.x, player.y, enemy.x, enemy.y) {
      (Some(line_dir), true)
    } else {
      (move_dir0, false)
    }
  } else {
    (move_dir0, false)
  }

  let (move_dir, shoot) = if !shoot {
    let base_x = @types.tile_center_x(@types.base_tile_x)
    let base_y = @types.tile_center_y(@types.base_tile_y)
    let (line_dir, aligned) = demo_line_shot_dir(
      player.x,
      player.y,
      base_x,
      base_y,
    )
    if aligned && @types.rand_range(game, 0, 99) < 8 {
      (Some(line_dir), true)
    } else {
      (move_dir, false)
    }
  } else {
    (move_dir, shoot)
  }

  let shoot = if shoot {
    true
  } else {
    @types.rand_range(game, 0, 99) < 4
  }

  (move_dir, shoot)
}
