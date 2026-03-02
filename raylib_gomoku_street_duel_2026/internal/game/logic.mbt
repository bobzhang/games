///|
/// Sets every cell on the board to `Empty`.
fn clear_board(game : @types.Game) -> Unit {
  for i in 0..<game.board.length() {
    game.board[i] = Empty
  }
}

///|
/// Resets the move history stack length to zero and clears all history entry fields.
fn clear_history(game : @types.Game) -> Unit {
  game.hist_len = 0
  for i in 0..<game.hist_x.length() {
    game.hist_x[i] = 0
    game.hist_y[i] = 0
    game.hist_p[i] = Empty
  }
}

///|
/// Deactivates all sparks and resets their fields to defaults.
fn clear_sparks(game : @types.Game) -> Unit {
  for spark in game.sparks {
    spark.active = false
    spark.x = 0.0
    spark.y = 0.0
    spark.vx = 0.0
    spark.vy = 0.0
    spark.life = 0.0
    spark.size = 0.0
    spark.kind = SparkAI
  }
}

///|
/// Clears the last-move marker coordinates for both the human and the AI.
fn clear_last_moves(game : @types.Game) -> Unit {
  game.last_hx = -1
  game.last_hy = -1
  game.last_ax = -1
  game.last_ay = -1
}

///|
/// Appends a move `(x, y, p)` to the history stack, silently capping at the maximum capacity.
fn push_history(
  game : @types.Game,
  x : Int,
  y : Int,
  p : @types.Player,
) -> Unit {
  if game.hist_len >= game.hist_x.length() {
    return
  }

  game.hist_x[game.hist_len] = x
  game.hist_y[game.hist_len] = y
  game.hist_p[game.hist_len] = p
  game.hist_len = game.hist_len + 1
}

///|
/// Removes and returns the most recent history entry as `(true, x, y, player)`, or `(false, 0, 0, Empty)` if the stack is empty.
fn pop_history(game : @types.Game) -> (Bool, Int, Int, @types.Player) {
  if game.hist_len <= 0 {
    return (false, 0, 0, Empty)
  }

  game.hist_len = game.hist_len - 1
  (
    true,
    game.hist_x[game.hist_len],
    game.hist_y[game.hist_len],
    game.hist_p[game.hist_len],
  )
}

///|
/// Counts consecutive cells belonging to `p` starting from `(x+dx, y+dy)` and advancing in direction `(dx, dy)`.
fn count_one_side(
  game : @types.Game,
  x : Int,
  y : Int,
  p : @types.Player,
  dx : Int,
  dy : Int,
) -> Int {
  let mut cx : Int = x + dx
  let mut cy : Int = y + dy
  let mut c : Int = 0

  while @types.in_board(cx, cy) && @types.cell_at(game, cx, cy) == p {
    c = c + 1
    cx = cx + dx
    cy = cy + dy
  }

  c
}

///|
/// Returns true if placing `p` at `(x, y)` forms a five-in-a-row in any of the four line directions.
fn check_five_from(
  game : @types.Game,
  x : Int,
  y : Int,
  p : @types.Player,
) -> Bool {
  let dirs : Array[(Int, Int)] = [(1, 0), (0, 1), (1, 1), (1, -1)]

  for dir in dirs {
    let (dx, dy) = dir
    let c1 : Int = count_one_side(game, x, y, p, dx, dy)
    let c2 : Int = count_one_side(game, x, y, p, -dx, -dy)

    if 1 + c1 + c2 >= 5 {
      return true
    }
  }

  false
}

///|
/// Returns true when the total move count equals the number of board cells.
fn board_full(game : @types.Game) -> Bool {
  game.move_count >= @types.board_n * @types.board_n
}

///|
/// Places player `p`'s stone at `(x, y)`, records history, emits sparks, checks for a win or draw, and advances the turn; returns false if placement is invalid.
fn place_stone(game : @types.Game, x : Int, y : Int, p : @types.Player) -> Bool {
  if game.state != Play {
    return false
  }

  if not(@types.in_board(x, y)) {
    return false
  }

  if @types.cell_at(game, x, y) != Empty {
    return false
  }

  @types.set_cell(game, x, y, p)
  push_history(game, x, y, p)
  game.move_count = game.move_count + 1

  match p {
    Human => {
      game.last_hx = x
      game.last_hy = y
      @types.burst_move(game, x, y, 12, SparkHuman)
    }
    _ => {
      game.last_ax = x
      game.last_ay = y
      @types.burst_move(game, x, y, 12, SparkAI)
    }
  }

  if check_five_from(game, x, y, p) {
    game.state = Result
    game.winner = p
    match p {
      Human => {
        game.human_wins = game.human_wins + 1
        @types.set_message(game, "You win!", 1.6)
      }
      _ => {
        game.ai_wins = game.ai_wins + 1
        @types.set_message(game, "AI wins", 1.6)
      }
    }
    game.shake_t = 0.24
    return true
  }

  if board_full(game) {
    game.state = Result
    game.winner = Empty
    game.draws = game.draws + 1
    @types.set_message(game, "Draw", 1.4)
    return true
  }

  game.turn = match p {
    Human => AI
    _ => Human
  }
  game.ai_delay = if game.turn == AI { 0.26 } else { 0.0 }

  true
}

///|
/// Pops the most recent history entry, removes that stone from the board, decrements the move count, and emits undo sparks; returns false if history is empty.
fn undo_round_step(game : @types.Game) -> Bool {
  let pop = pop_history(game)
  if not(pop.0) {
    return false
  }

  let x : Int = pop.1
  let y : Int = pop.2

  if @types.in_board(x, y) && @types.cell_at(game, x, y) != Empty {
    @types.set_cell(game, x, y, Empty)
    game.move_count = @types.maxi(0, game.move_count - 1)
    @types.burst_move(game, x, y, 8, SparkUndo)
  }

  true
}

///|
/// Rolls back one full human turn (and the preceding AI move if applicable), restores last-move markers from history, and returns the turn to the human; returns false if undo is not possible.
fn undo_last_turn(game : @types.Game) -> Bool {
  if game.state != Play {
    @types.set_message(game, "Undo only during play", 0.8)
    return false
  }

  if game.hist_len <= 0 {
    @types.set_message(game, "Nothing to undo", 0.8)
    return false
  }

  if game.turn == AI {
    // Human just moved, rollback one move.
    if not(undo_round_step(game)) {
      return false
    }
    game.turn = Human
  } else {
    // AI just moved, rollback AI + previous human when possible.
    if not(undo_round_step(game)) {
      return false
    }
    ignore(undo_round_step(game))
    game.turn = Human
  }

  @types.clear_hint(game)
  game.ai_delay = 0.0

  // Rebuild last move markers.
  clear_last_moves(game)
  for i in 0..<game.hist_len {
    let p : @types.Player = game.hist_p[i]
    match p {
      Human => {
        game.last_hx = game.hist_x[i]
        game.last_hy = game.hist_y[i]
      }
      AI => {
        game.last_ax = game.hist_x[i]
        game.last_ay = game.hist_y[i]
      }
      _ => ()
    }
  }

  @types.set_message(game, "Undo", 0.6)
  game.shake_t = 0.08

  true
}

///|
/// Moves the cursor one step in `dir`, clamping it within the board boundaries.
fn move_cursor_once(game : @types.Game, dir : @types.Dir) -> Unit {
  if game.state != Play {
    return
  }

  match dir {
    Left =>
      game.cursor_x = @types.clampi(game.cursor_x - 1, 0, @types.board_n - 1)
    Right =>
      game.cursor_x = @types.clampi(game.cursor_x + 1, 0, @types.board_n - 1)
    Up =>
      game.cursor_y = @types.clampi(game.cursor_y - 1, 0, @types.board_n - 1)
    Down =>
      game.cursor_y = @types.clampi(game.cursor_y + 1, 0, @types.board_n - 1)
    DirNone => ()
  }
}

///|
/// Handles held-direction key repeat: moves the cursor immediately on direction change, then again at a fixed repeat interval while the key remains held.
fn update_cursor_hold(
  game : @types.Game,
  dt : Float,
  held_dir : @types.Dir,
) -> Unit {
  if game.state != Play {
    game.hold_dir = DirNone
    game.repeat_t = 0.0
    return
  }

  if held_dir == DirNone {
    game.hold_dir = DirNone
    game.repeat_t = 0.0
    return
  }

  if game.hold_dir != held_dir {
    game.hold_dir = held_dir
    game.repeat_t = 0.2
    move_cursor_once(game, held_dir)
  } else {
    game.repeat_t = game.repeat_t - dt
    if game.repeat_t <= 0.0 {
      game.repeat_t = 0.095
      move_cursor_once(game, held_dir)
    }
  }
}

///|
/// Advances each active spark's position and velocity with drag, then deactivates sparks whose lifetime has expired.
fn update_sparks(game : @types.Game, dt : Float) -> Unit {
  for spark in game.sparks {
    if not(spark.active) {
      continue
    }

    spark.life = spark.life - dt
    if spark.life <= 0.0 {
      spark.active = false
      continue
    }

    spark.x = spark.x + spark.vx * dt
    spark.y = spark.y + spark.vy * dt
    spark.vx = spark.vx * (1.0 - dt * 1.8)
    spark.vy = spark.vy * (1.0 - dt * 1.8) + dt * 34.0
  }
}

///|
/// Advances all time-based fields — ui clock, game clock, AI delay, message TTL, shake timer, touch cooldown, and hint TTL — and steps spark simulation.
fn update_timers(game : @types.Game, dt : Float) -> Unit {
  game.ui_t = game.ui_t + dt

  if game.state == Play {
    game.game_time = game.game_time + dt
  }

  if game.ai_delay > 0.0 {
    game.ai_delay = game.ai_delay - dt
    if game.ai_delay < 0.0 {
      game.ai_delay = 0.0
    }
  }

  if game.message_t > 0.0 {
    game.message_t = game.message_t - dt
    if game.message_t < 0.0 {
      game.message_t = 0.0
    }
  }

  if game.shake_t > 0.0 {
    game.shake_t = game.shake_t - dt
    if game.shake_t < 0.0 {
      game.shake_t = 0.0
    }
  }

  if game.touch_action_cd > 0.0 {
    game.touch_action_cd = game.touch_action_cd - dt
    if game.touch_action_cd < 0.0 {
      game.touch_action_cd = 0.0
    }
  }

  if game.hint_active {
    game.hint_ttl = game.hint_ttl - dt
    if game.hint_ttl <= 0.0 {
      @types.clear_hint(game)
    }
  }

  update_sparks(game, dt)
}

///|
/// Clears the board, history, sparks, hint, and last-move markers, then starts a new round with the human or AI moving first based on `human_first`.
fn reset_round(game : @types.Game, human_first : Bool) -> Unit {
  clear_board(game)
  clear_history(game)
  clear_sparks(game)
  @types.clear_hint(game)
  clear_last_moves(game)

  game.state = Play
  game.turn = if human_first { Human } else { AI }
  game.winner = Empty
  game.move_count = 0

  game.cursor_x = @types.board_n / 2
  game.cursor_y = @types.board_n / 2

  game.hints_left = 4
  game.ai_delay = if game.turn == AI { 0.35 } else { 0.0 }
  game.game_time = 0.0

  game.hold_dir = DirNone
  game.repeat_t = 0.0
  game.touch_action_cd = 0.0

  @types.set_message(game, "Round started", 0.9)
}
