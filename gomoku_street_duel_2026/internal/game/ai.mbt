///|
/// Returns true if any cell within Manhattan radius `r` of `(x, y)` is occupied.
fn has_neighbor(game : @types.Game, x : Int, y : Int, r : Int) -> Bool {
  for yy in (y - r)..<=(y + r) {
    for xx in (x - r)..<=(x + r) {
      if xx == x && yy == y {
        continue
      }

      if @types.in_board(xx, yy) && @types.cell_at(game, xx, yy) != Empty {
        return true
      }
    }
  }

  false
}

///|
/// Counts consecutive cells belonging to `p` from `(x, y)` in direction `(dx, dy)` and returns `(count, 1)` if the next cell is empty or `(count, 0)` otherwise.
fn count_chain_and_open(
  game : @types.Game,
  x : Int,
  y : Int,
  p : @types.Player,
  dx : Int,
  dy : Int,
) -> (Int, Int) {
  let mut cx : Int = x + dx
  let mut cy : Int = y + dy
  let mut c : Int = 0

  while @types.in_board(cx, cy) && @types.cell_at(game, cx, cy) == p {
    c = c + 1
    cx = cx + dx
    cy = cy + dy
  }

  let open : Int = if @types.in_board(cx, cy) &&
    @types.cell_at(game, cx, cy) == Empty {
    1
  } else {
    0
  }

  (c, open)
}

///|
/// Returns a threat score for a line segment of length `total` with `open` open ends, using predefined thresholds for four, three, two, and one in a row.
fn line_pattern_score(total : Int, open : Int) -> Int {
  if total >= 4 {
    220000
  } else if total == 3 && open == 2 {
    36000
  } else if total == 3 && open == 1 {
    7600
  } else if total == 2 && open == 2 {
    2100
  } else if total == 2 && open == 1 {
    460
  } else if total == 1 && open == 2 {
    130
  } else if total == 1 && open == 1 {
    48
  } else {
    10
  }
}

///|
/// Evaluates the threat score for player `p` along one axis direction `(dx, dy)` from `(x, y)` by combining counts on both sides with `line_pattern_score`.
fn score_dir(
  game : @types.Game,
  x : Int,
  y : Int,
  p : @types.Player,
  dx : Int,
  dy : Int,
) -> Int {
  let left = count_chain_and_open(game, x, y, p, -dx, -dy)
  let right = count_chain_and_open(game, x, y, p, dx, dy)

  let total : Int = left.0 + right.0
  let open : Int = left.1 + right.1

  line_pattern_score(total, open) + total * 11 + open * 5
}

///|
/// Returns a heuristic placement score for player `p` at empty cell `(x, y)`, summing directional threat scores and a center-proximity bonus; returns -1 if the cell is occupied.
fn score_cell_for(
  game : @types.Game,
  x : Int,
  y : Int,
  p : @types.Player,
) -> Int {
  if @types.cell_at(game, x, y) != Empty {
    return -1
  }

  let mut score : Int = 0
  score = score + score_dir(game, x, y, p, 1, 0)
  score = score + score_dir(game, x, y, p, 0, 1)
  score = score + score_dir(game, x, y, p, 1, 1)
  score = score + score_dir(game, x, y, p, 1, -1)

  let cx : Int = @types.board_n / 2
  let dist : Int = Float::from_int(x - cx).abs().to_int() +
    Float::from_int(y - cx).abs().to_int()
  score = score + (0).max(50 - dist * 3)

  score
}

///|
/// Returns true if placing player `p` at `(x, y)` would immediately complete a five-in-a-row.
fn would_win_if_place(
  game : @types.Game,
  x : Int,
  y : Int,
  p : @types.Player,
) -> Bool {
  if @types.cell_at(game, x, y) != Empty {
    return false
  }

  @types.set_cell(game, x, y, p)
  let win : Bool = check_five_from(game, x, y, p)
  @types.set_cell(game, x, y, Empty)
  win
}

///|
/// Returns `(found, x, y, score)` for the highest-scoring empty cell for player `p`, prioritising immediate wins, blocking the opponent's wins, and combined offensive/defensive heuristics.
fn best_move_for(
  game : @types.Game,
  p : @types.Player,
  opp : @types.Player,
) -> (Bool, Int, Int, Int) {
  if game.move_count == 0 {
    return (true, @types.board_n / 2, @types.board_n / 2, 100)
  }

  let mut found : Bool = false
  let mut best_score : Int = -1
  let mut best_x : Int = @types.board_n / 2
  let mut best_y : Int = @types.board_n / 2

  for y in 0..<@types.board_n {
    for x in 0..<@types.board_n {
      if @types.cell_at(game, x, y) != Empty {
        continue
      }

      if not(has_neighbor(game, x, y, 2)) {
        continue
      }

      let mut s : Int = 0

      if would_win_if_place(game, x, y, p) {
        s = 1000000
      } else if would_win_if_place(game, x, y, opp) {
        s = 760000
      } else {
        let off : Int = score_cell_for(game, x, y, p)
        let def : Int = score_cell_for(game, x, y, opp)
        s = off + def * 11 / 10
      }

      s = s + @raylib.get_random_value(0, 6)

      if not(found) || s > best_score {
        found = true
        best_score = s
        best_x = x
        best_y = y
      }
    }
  }

  if not(found) {
    for y in 0..<@types.board_n {
      for x in 0..<@types.board_n {
        if @types.cell_at(game, x, y) == Empty {
          return (true, x, y, 1)
        }
      }
    }
    return (false, 0, 0, 0)
  }

  (true, best_x, best_y, best_score)
}

///|
/// Executes the AI's turn by selecting and placing the best move when it is the AI's turn and the delay timer has expired; declares a draw if no move is available.
fn ai_step(game : @types.Game) -> Unit {
  if game.state != Play || game.turn != AI || game.ai_delay > 0.0 {
    return
  }

  let mv = best_move_for(game, AI, Human)
  if not(mv.0) {
    game.state = Result
    game.winner = Empty
    game.draws = game.draws + 1
    @types.set_message(game, "No move, draw", 1.4)
    return
  }

  let x : Int = mv.1
  let y : Int = mv.2
  ignore(place_stone(game, x, y, AI))

  if game.state == Play {
    @types.set_message(game, "AI moved", 0.45)
  }
}

///|
/// Spends one hint charge to show the AI-recommended move for the human player, moves the cursor there, and emits hint sparks; returns true on success.
fn use_hint(game : @types.Game) -> Bool {
  if game.state != Play || game.turn != Human {
    return false
  }

  if game.hints_left <= 0 {
    @types.set_message(game, "No hints left", 0.8)
    return false
  }

  let mv = best_move_for(game, Human, AI)
  if not(mv.0) {
    @types.set_message(game, "No suggestion", 0.8)
    return false
  }

  game.hints_left = game.hints_left - 1
  game.hint_active = true
  game.hint_ttl = 3.0
  game.hint_x = mv.1
  game.hint_y = mv.2

  game.cursor_x = mv.1
  game.cursor_y = mv.2

  @types.set_message(game, "Hint suggested", 0.9)
  @types.burst_move(game, mv.1, mv.2, 10, SparkHint)

  true
}
