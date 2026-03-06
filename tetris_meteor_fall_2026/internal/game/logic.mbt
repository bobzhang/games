///|
fn @types.Game::refill_bag(game : @types.Game) -> Unit {
  for i in 0..<@types.bag_size {
    game.bag[i] = i
  }
  let mut i = @types.bag_size - 1
  while i > 0 {
    let j = @raylib.get_random_value(0, i)
    let tmp = game.bag[i]
    game.bag[i] = game.bag[j]
    game.bag[j] = tmp
    i = i - 1
  }
  game.bag_pos = 0
}

///|
fn @types.Game::take_bag_piece(game : @types.Game) -> Int {
  if game.bag_pos >= @types.bag_size {
    game.refill_bag()
  }
  let kind = game.bag[game.bag_pos]
  game.bag_pos = game.bag_pos + 1
  kind
}

///|
fn @types.Game::lock_piece(game : @types.Game) -> Unit {
  for i in 0..<4 {
    let c = @types.piece_cell(game.piece_kind, game.piece_rot, i)
    let x = game.piece_x + c.x
    let y = game.piece_y + c.y
    if y < 0 {
      game.over = true
      continue
    }
    if x >= 0 && x < @types.board_cols && y >= 0 && y < @types.board_rows {
      game.board[@types.board_index(x, y)] = game.piece_kind + 1
    }
  }
}

///|
fn @types.Game::clear_lines(game : @types.Game) -> Int {
  let mut cleared = 0
  let mut y = @types.board_rows - 1
  while y >= 0 {
    let mut full = true
    for x in 0..<@types.board_cols {
      if game.board[@types.board_index(x, y)] == 0 {
        full = false
      }
    }
    if full {
      cleared = cleared + 1
      let mut yy = y
      while yy > 0 {
        for x in 0..<@types.board_cols {
          game.board[@types.board_index(x, yy)] = game.board[@types.board_index(
              x,
              yy - 1,
            )]
        }
        yy = yy - 1
      }
      for x in 0..<@types.board_cols {
        game.board[@types.board_index(x, 0)] = 0
      }
      // Keep y the same and recheck after shift.
    } else {
      y = y - 1
    }
  }
  cleared
}

///|
fn @types.Game::recalc_speed(game : @types.Game) -> Unit {
  let raw : Float = (0.70 : Float) -
    Float::from_int(game.level - 1) * (0.05 : Float)
  game.drop_interval = if raw < (0.09 : Float) { (0.09 : Float) } else { raw }
}

///|
fn @types.Game::apply_line_score(game : @types.Game, cleared : Int) -> Unit {
  if cleared <= 0 {
    return
  }
  game.lines = game.lines + cleared
  game.level = 1 + game.lines / 10
  game.recalc_speed()
  let base = match cleared {
    1 => @types.score_single
    2 => @types.score_double
    3 => @types.score_triple
    _ => @types.score_tetris
  }
  game.score = game.score + base * game.level
}

///|
fn @types.Game::spawn_piece(game : @types.Game) -> Unit {
  game.piece_kind = game.next_kind
  game.next_kind = game.take_bag_piece()
  game.piece_rot = 0
  game.piece_x = @types.board_cols / 2
  game.piece_y = 0
  game.hold_used = false
  if @types.collides(
      game,
      game.piece_kind,
      game.piece_rot,
      game.piece_x,
      game.piece_y,
    ) {
    game.over = true
  }
}

///|
fn @types.Game::hard_drop(game : @types.Game) -> Unit {
  let mut traveled = 0
  while !@types.collides(
          game,
          game.piece_kind,
          game.piece_rot,
          game.piece_x,
          game.piece_y + 1,
        ) {
    game.piece_y = game.piece_y + 1
    traveled = traveled + 1
  }
  game.score = game.score + traveled * 2
  game.lock_piece()
  let cleared = game.clear_lines()
  game.apply_line_score(cleared)
  if !game.over {
    game.spawn_piece()
  }
}

///|
fn @types.Game::try_move(game : @types.Game, dx : Int, dy : Int) -> Bool {
  let nx = game.piece_x + dx
  let ny = game.piece_y + dy
  if @types.collides(game, game.piece_kind, game.piece_rot, nx, ny) {
    return false
  }
  game.piece_x = nx
  game.piece_y = ny
  true
}

///|
fn @types.Game::try_rotate(game : @types.Game, dir : Int) -> Unit {
  let new_rot = @types.normalize_rot(game.piece_rot + dir)
  let kicks : Array[Int] = [0, -1, 1, -2, 2]
  for kick in kicks {
    let x = game.piece_x + kick
    if !@types.collides(game, game.piece_kind, new_rot, x, game.piece_y) {
      game.piece_rot = new_rot
      game.piece_x = x
      return
    }
  }
}

///|
fn @types.Game::use_hold(game : @types.Game) -> Unit {
  if game.hold_used {
    return
  }
  let current = game.piece_kind
  if game.hold_kind < 0 {
    game.hold_kind = current
    game.piece_kind = game.next_kind
    game.next_kind = game.take_bag_piece()
  } else {
    game.piece_kind = game.hold_kind
    game.hold_kind = current
  }
  game.piece_rot = 0
  game.piece_x = @types.board_cols / 2
  game.piece_y = 0
  game.hold_used = true
  if @types.collides(
      game,
      game.piece_kind,
      game.piece_rot,
      game.piece_x,
      game.piece_y,
    ) {
    game.over = true
  }
}

///|
/// Reinitializes board, bag state, scores, and active piece for a new game.
pub fn reset_game(game : @types.Game) -> Unit {
  for i in 0..<game.board.length() {
    game.board[i] = 0
  }
  game.score = 0
  game.lines = 0
  game.level = 1
  game.drop_timer = 0.0
  game.drop_interval = 0.70
  game.over = false
  game.hold_kind = -1
  game.hold_used = false
  game.bag_pos = @types.bag_size
  game.next_kind = game.take_bag_piece()
  game.piece_kind = game.take_bag_piece()
  game.piece_rot = 0
  game.piece_x = @types.board_cols / 2
  game.piece_y = 0
  game.recalc_speed()
}

///|
/// Advances one frame of Tetris input handling, gravity, and locking.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  if game.over {
    if @raylib.is_key_pressed(@raylib.KeyR) {
      reset_game(game)
    }
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    ignore(game.try_move(-1, 0))
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    ignore(game.try_move(1, 0))
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyX) {
    game.try_rotate(1)
  }
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    game.try_rotate(-1)
  }
  if @raylib.is_key_pressed(@raylib.KeyC) {
    game.use_hold()
  }
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    game.hard_drop()
    game.drop_timer = 0.0
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyDown) {
    if game.try_move(0, 1) {
      game.score = game.score + 1
    }
  }

  let speed_scale : Float = if @raylib.is_key_down(@raylib.KeyDown) {
    (0.08 : Float)
  } else {
    1.0
  }
  game.drop_timer = game.drop_timer + dt
  let interval = game.drop_interval * speed_scale
  if game.drop_timer >= interval {
    game.drop_timer = 0.0
    if !game.try_move(0, 1) {
      game.lock_piece()
      let cleared = game.clear_lines()
      game.apply_line_score(cleared)
      if !game.over {
        game.spawn_piece()
      }
    }
  }
}
