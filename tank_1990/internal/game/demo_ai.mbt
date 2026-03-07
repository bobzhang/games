///|
/// Returns the opposite direction (e.g. Up becomes Down, Left becomes Right).
fn opposite_dir(dir : @types.Dir) -> @types.Dir {
  match dir {
    Up => Down
    Down => Up
    Left => Right
    Right => Left
  }
}

///|
/// Finds the nearest active enemy to the given position and returns its index and squared distance.
fn @types.Game::demo_nearest_enemy(
  game : @types.Game,
  x : Float,
  y : Float,
) -> (Int, Float) {
  let mut best_idx = -1
  let mut best_dist : Float = Float::from_int(1000000000)
  for i in 0..<game.enemies.length() {
    if !game.enemies[i].active {
      continue
    }
    let d = @types.distance_sq(x, y, game.enemies[i].x, game.enemies[i].y)
    if d < best_dist {
      best_dist = d
      best_idx = i
    }
  }
  (best_idx, best_dist)
}

///|
/// Finds the nearest active power-up to the given position and returns its index and squared distance.
fn @types.Game::demo_nearest_powerup(
  game : @types.Game,
  x : Float,
  y : Float,
) -> (Int, Float) {
  for i, powerup in game.powerups; best_idx = -1, best_dist = 1000000000.F {
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
/// Checks whether the player tank at the given index can move one step in the specified direction without colliding with walls, other players, or enemies.
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
/// Tries each of four candidate directions in priority order and returns the first one the player can actually step into, or None if all are blocked.
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
/// Decides which direction the AI player should move to reach the target position, preferring the axis with the larger gap and falling back to a random direction if stuck.
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

  let mut move_dir = if dx.abs() > dy.abs() {
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

  if move_dir is None {
    let random_dir = @types.rand_dir(game)
    if game.demo_can_step(index, random_dir, dt) {
      move_dir = Some(random_dir)
    }
  }

  move_dir
}

///|
/// Determines if the player and target are roughly aligned on the same row or column so a straight shot is possible, returning the aiming direction and whether alignment was found.
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
/// Picks a target position for the AI player to move toward: a nearby power-up if one is close enough, the nearest enemy otherwise, or a guard position near the base when no enemies remain.
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
/// Produces the AI move direction and shoot decision for one demo player each frame, combining target selection, pathfinding, line-of-sight shooting, and random fire.
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

  let mut move_dir = game.demo_choose_move_dir(index, dt, target_x, target_y)
  let mut shoot = false

  if nearest_enemy >= 0 {
    let enemy = game.enemies[nearest_enemy]
    let (line_dir, aligned) = demo_line_shot_dir(
      player.x,
      player.y,
      enemy.x,
      enemy.y,
    )
    if aligned &&
      !@world.sight_blocked(game, player.x, player.y, enemy.x, enemy.y) {
      move_dir = Some(line_dir)
      shoot = true
    }
  }

  if !shoot {
    let base_x = @types.tile_center_x(@types.base_tile_x)
    let base_y = @types.tile_center_y(@types.base_tile_y)
    let (line_dir, aligned) = demo_line_shot_dir(
      player.x,
      player.y,
      base_x,
      base_y,
    )
    if aligned && @types.rand_range(game, 0, 99) < 8 {
      move_dir = Some(line_dir)
      shoot = true
    }
  }

  if !shoot && @types.rand_range(game, 0, 99) < 4 {
    shoot = true
  }

  (move_dir, shoot)
}
