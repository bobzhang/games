///|
/// Select a move for the AI player
pub fn select_move(
  board : @types.HexBoard,
  player : @types.Player,
  difficulty : @types.Difficulty
) -> @types.HexCoord? {
  let empty = @types.empty_positions(board)
  if empty.length() == 0 {
    return None
  }
  match difficulty {
    Easy => select_easy(empty)
    Normal => select_normal(board, player, empty)
    Hard => select_hard(board, player, empty)
  }
}

///|
/// Easy: pick a random valid move
fn select_easy(empty : Array[@types.HexCoord]) -> @types.HexCoord? {
  if empty.length() == 0 {
    return None
  }
  let idx = @raylib.get_random_value(0, empty.length() - 1)
  Some(empty[idx])
}

///|
/// Normal: evaluate each move by immediate pattern score + capture score
fn select_normal(
  board : @types.HexBoard,
  player : @types.Player,
  empty : Array[@types.HexCoord]
) -> @types.HexCoord? {
  if empty.length() == 0 {
    return None
  }
  let mut best_score = -1
  let mut best_idx = 0
  for i in 0..<empty.length() {
    let pos = empty[i]
    let score = evaluate_move(board, pos, player)
    if score > best_score {
      best_score = score
      best_idx = i
    }
  }
  // Add some randomness - occasionally pick a random move
  let rand = @raylib.get_random_value(0, 100)
  if rand < 15 {
    select_easy(empty)
  } else {
    Some(empty[best_idx])
  }
}

///|
/// Hard: minimax with alpha-beta pruning, depth 2
fn select_hard(
  board : @types.HexBoard,
  player : @types.Player,
  empty : Array[@types.HexCoord]
) -> @types.HexCoord? {
  if empty.length() == 0 {
    return None
  }
  let mut best_score = -999999
  let mut best_idx = 0
  // Limit moves to evaluate for performance
  let max_moves = @types.mini(empty.length(), 15)
  let candidates = get_candidate_moves(board, player, empty, max_moves)
  for i in 0..<candidates.length() {
    let pos = candidates[i]
    let test_board = @types.clone_board(board)
    @types.set_cell(test_board, pos, Occupied(player))
    let captured = @board.resolve_captures(test_board, player)
    let capture_bonus = captured.length() * 2
    let score = capture_bonus + minimax(
        test_board, @types.opponent(player), player, 2, -999999, 999999, false,
      )
    if score > best_score {
      best_score = score
      best_idx = i
    }
  }
  Some(candidates[best_idx])
}

///|
/// Get candidate moves sorted by heuristic value (for pruning efficiency)
fn get_candidate_moves(
  board : @types.HexBoard,
  player : @types.Player,
  empty : Array[@types.HexCoord],
  max_count : Int
) -> Array[@types.HexCoord] {
  // Score each move quickly and take the top ones
  let scores : Array[(Int, Int)] = [] // (score, index)
  for i in 0..<empty.length() {
    let s = evaluate_move(board, empty[i], player)
    scores.push((s, i))
  }
  // Sort by score descending (simple selection)
  let result : Array[@types.HexCoord] = []
  let used : Array[Bool] = Array::make(empty.length(), false)
  for _pick in 0..<max_count {
    let mut best_s = -999999
    let mut best_i = -1
    for j in 0..<scores.length() {
      if !used[j] && scores[j].0 > best_s {
        best_s = scores[j].0
        best_i = j
      }
    }
    if best_i >= 0 {
      used[best_i] = true
      result.push(empty[scores[best_i].1])
    }
  }
  result
}

///|
/// Minimax with alpha-beta pruning
fn minimax(
  board : @types.HexBoard,
  current : @types.Player,
  ai_player : @types.Player,
  depth : Int,
  alpha_in : Int,
  beta_in : Int,
  maximizing : Bool
) -> Int {
  if depth == 0 {
    return evaluate_board(board, ai_player)
  }
  let empty = @types.empty_positions(board)
  if empty.length() == 0 {
    return evaluate_board(board, ai_player)
  }
  let max_eval = @types.mini(empty.length(), 8)
  let mut alpha = alpha_in
  let mut beta = beta_in
  if maximizing {
    let mut max_score = -999999
    for i in 0..<max_eval {
      let pos = empty[i]
      let test_board = @types.clone_board(board)
      @types.set_cell(test_board, pos, Occupied(current))
      let _captured = @board.resolve_captures(test_board, current)
      let score = minimax(
        test_board, @types.opponent(current), ai_player, depth - 1, alpha, beta,
        false,
      )
      if score > max_score {
        max_score = score
      }
      if score > alpha {
        alpha = score
      }
      if beta <= alpha {
        break
      }
    }
    max_score
  } else {
    let mut min_score = 999999
    for i in 0..<max_eval {
      let pos = empty[i]
      let test_board = @types.clone_board(board)
      @types.set_cell(test_board, pos, Occupied(current))
      let _captured = @board.resolve_captures(test_board, current)
      let score = minimax(
        test_board, @types.opponent(current), ai_player, depth - 1, alpha, beta,
        true,
      )
      if score < min_score {
        min_score = score
      }
      if score < beta {
        beta = score
      }
      if beta <= alpha {
        break
      }
    }
    min_score
  }
}

///|
/// Quick board evaluation for a player
fn evaluate_board(board : @types.HexBoard, player : @types.Player) -> Int {
  let my_patterns = @board.score_patterns(board, player)
  let opp_patterns = @board.score_patterns(board, @types.opponent(player))
  let mut my_stones = 0
  let mut opp_stones = 0
  for r in 0..<board.size {
    for c in 0..<board.size {
      match board.cells[r][c] {
        Occupied(p) =>
          if p == player {
            my_stones = my_stones + 1
          } else {
            opp_stones = opp_stones + 1
          }
        _ => ()
      }
    }
  }
  my_patterns * 3 + my_stones - opp_patterns * 3 - opp_stones
}

///|
/// Evaluate a single move by placing it on a clone and measuring improvement
fn evaluate_move(
  board : @types.HexBoard,
  pos : @types.HexCoord,
  player : @types.Player
) -> Int {
  let before = @board.score_patterns(board, player)
  let test_board = @types.clone_board(board)
  @types.set_cell(test_board, pos, Occupied(player))
  let captured = @board.resolve_captures(test_board, player)
  let after = @board.score_patterns(test_board, player)
  let pattern_gain = after - before
  let capture_gain = captured.length() * 2
  // Bonus for center positions
  let center = @types.board_size / 2
  let dr = pos.row - center
  let dc = pos.col - center
  let dist = dr * dr + dc * dc
  let center_bonus = if dist <= 2 { 1 } else { 0 }
  // Bonus for blocking opponent patterns
  let opp = @types.opponent(player)
  let opp_before = @board.score_patterns(board, opp)
  let opp_after = @board.score_patterns(test_board, opp)
  let block_bonus = opp_before - opp_after
  pattern_gain * 3 + capture_gain * 2 + center_bonus + block_bonus
}
