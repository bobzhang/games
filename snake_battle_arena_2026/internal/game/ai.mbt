///|
fn wrap_dist(a : Int, b : Int, size : Int) -> Int {
  let d0 : Int = if a > b { a - b } else { b - a }
  d0.min(size - d0)
}

///|
fn food_distance(nx : Int, ny : Int, fx : Int, fy : Int) -> Int {
  wrap_dist(nx, fx, @types.grid_w) + wrap_dist(ny, fy, @types.grid_h)
}

///|
fn @types.Game::direction_score_player(game : @types.Game, dir : Int) -> Int {
  if @types.opposite_dir(game.p_dir, dir) {
    return -100000
  }

  let nx : Int = @types.wrap_x(game.p_seg_x[0] + @types.dir_dx(dir))
  let ny : Int = @types.wrap_y(game.p_seg_y[0] + @types.dir_dy(dir))

  if game.player_segment_at(nx, ny, true) {
    return -90000
  }
  if game.rival_segment_at(nx, ny, -1, false) {
    return -86000
  }
  if game.trap_at(nx, ny) {
    return -83000
  }

  let mut score : Int = 3000 -
    food_distance(nx, ny, game.food_x, game.food_y) * 70

  for d in 0..<4 {
    let tx : Int = @types.wrap_x(nx + @types.dir_dx(d))
    let ty : Int = @types.wrap_y(ny + @types.dir_dy(d))

    if not(game.player_segment_at(tx, ty, true)) &&
      not(game.rival_segment_at(tx, ty, -1, false)) &&
      not(game.trap_at(tx, ty)) {
      score = score + 36
    }
  }

  score
}

///|
fn @types.Game::suggest_player_dir(game : @types.Game) -> Int {
  let mut best_dir : Int = -1
  let mut best_score : Int = -999999

  for d in 0..<4 {
    let s : Int = game.direction_score_player(d)
    if s > best_score {
      best_score = s
      best_dir = d
    }
  }

  best_dir
}

///|
fn @types.Game::direction_score_rival(game : @types.Game, rid : Int, dir : Int) -> Int {
  let rival = game.rivals[rid]

  if @types.opposite_dir(rival.dir, dir) {
    return -100000
  }

  let nx : Int = @types.wrap_x(rival.seg_x[0] + @types.dir_dx(dir))
  let ny : Int = @types.wrap_y(rival.seg_y[0] + @types.dir_dy(dir))

  if game.rival_would_collide(rid, nx, ny) {
    return -90000
  }

  let mut score : Int = 2800 -
    food_distance(nx, ny, game.food_x, game.food_y) * 64

  let pd : Int = food_distance(nx, ny, game.p_seg_x[0], game.p_seg_y[0])
  if pd <= 2 {
    score = score - 120
  }

  for d in 0..<4 {
    let tx : Int = @types.wrap_x(nx + @types.dir_dx(d))
    let ty : Int = @types.wrap_y(ny + @types.dir_dy(d))
    if not(game.rival_would_collide(rid, tx, ty)) {
      score = score + 26
    }
  }

  score + @raylib.get_random_value(-44, 44)
}

///|
fn @types.Game::ai_choose_dir(game : @types.Game, rid : Int) -> Int {
  let rival = game.rivals[rid]

  let mut best_dir : Int = rival.dir
  let mut best_score : Int = -999999

  for d in 0..<4 {
    let s : Int = game.direction_score_rival(rid, d)
    if s > best_score {
      best_score = s
      best_dir = d
    }
  }

  best_dir
}
