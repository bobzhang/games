///|
fn opposite_dir(dir : Int) -> Int {
  if dir == @types.dir_up {
    @types.dir_down
  } else if dir == @types.dir_down {
    @types.dir_up
  } else if dir == @types.dir_left {
    @types.dir_right
  } else {
    @types.dir_left
  }
}

///|
fn @types.Game::demo_nearest_enemy(
  game : @types.Game,
  x : Float,
  y : Float,
) -> (Int, Float) {
  let mut best_idx = -1
  let mut best_dist : Float = Float::from_int(1000000000)
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
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
fn @types.Game::demo_nearest_powerup(
  game : @types.Game,
  x : Float,
  y : Float,
) -> (Int, Float) {
  let mut best_idx = -1
  let mut best_dist : Float = Float::from_int(1000000000)
  for i in 0..<game.powerups.length() {
    if not(game.powerups[i].active) {
      continue
    }
    let d = @types.distance_sq(x, y, game.powerups[i].x, game.powerups[i].y)
    if d < best_dist {
      best_dist = d
      best_idx = i
    }
  }
  (best_idx, best_dist)
}

///|
fn @types.Game::demo_can_step(
  game : @types.Game,
  index : Int,
  dir : Int,
  dt : Float,
) -> Bool {
  let player = game.players[index]
  if not(player.active) {
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
  a : Int,
  b : Int,
  c : Int,
  d : Int,
) -> Int {
  if game.demo_can_step(index, a, dt) {
    a
  } else if game.demo_can_step(index, b, dt) {
    b
  } else if game.demo_can_step(index, c, dt) {
    c
  } else if game.demo_can_step(index, d, dt) {
    d
  } else {
    -1
  }
}

///|
fn @types.Game::demo_choose_move_dir(
  game : @types.Game,
  index : Int,
  dt : Float,
  target_x : Float,
  target_y : Float,
) -> Int {
  let player = game.players[index]
  let dx = target_x - player.x
  let dy = target_y - player.y

  let horiz = if dx < 0.0 { @types.dir_left } else { @types.dir_right }
  let vert = if dy < 0.0 { @types.dir_up } else { @types.dir_down }

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

  if move_dir < 0 {
    let random_dir = @types.rand_range(game, 0, 3)
    if game.demo_can_step(index, random_dir, dt) {
      move_dir = random_dir
    }
  }

  move_dir
}

///|
fn demo_line_shot_dir(
  player_x : Float,
  player_y : Float,
  target_x : Float,
  target_y : Float,
) -> (Int, Bool) {
  let epsilon = Float::from_int(@types.tile_size) * 0.42
  let dx = target_x - player_x
  let dy = target_y - player_y
  if dx.abs() <= epsilon {
    (if dy < 0.0 { @types.dir_up } else { @types.dir_down }, true)
  } else if dy.abs() <= epsilon {
    (if dx < 0.0 { @types.dir_left } else { @types.dir_right }, true)
  } else {
    (@types.dir_up, false)
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
) -> (Int, Bool) {
  let player = game.players[index]
  if not(player.active) {
    return (-1, false)
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
      not(@world.sight_blocked(game, player.x, player.y, enemy.x, enemy.y)) {
      move_dir = line_dir
      shoot = true
    }
  }

  if not(shoot) {
    let base_x = @types.tile_center_x(@types.base_tile_x)
    let base_y = @types.tile_center_y(@types.base_tile_y)
    let (line_dir, aligned) = demo_line_shot_dir(
      player.x,
      player.y,
      base_x,
      base_y,
    )
    if aligned && @types.rand_range(game, 0, 99) < 8 {
      move_dir = line_dir
      shoot = true
    }
  }

  if not(shoot) && @types.rand_range(game, 0, 99) < 4 {
    shoot = true
  }

  (move_dir, shoot)
}
