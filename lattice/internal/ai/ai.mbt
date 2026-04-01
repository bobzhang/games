///|
/// Select a move for the AI player
pub fn select_move(
  board : @types.HexBoard,
  player : @types.Player,
  difficulty : @types.Difficulty,
) -> @types.HexCoord? {
  let empty = @types.empty_positions(board)
  if empty.length() == 0 {
    return None
  }
  match difficulty {
    Easy => select_easy(board, player, empty)
    Normal => select_normal(board, player, empty)
    Hard => select_hard(board, player, empty)
  }
}

///|
/// Easy: biased random -- pick from empty cells, favoring center slightly.
/// Mostly random but avoids the worst moves (light heuristic with high noise).
fn select_easy(
  board : @types.HexBoard,
  player : @types.Player,
  empty : Array[@types.HexCoord],
) -> @types.HexCoord? {
  if empty.length() == 0 {
    return None
  }
  // 70% pure random, 30% pick a decent-looking move
  let rand = @raylib.get_random_value(0, 100)
  if rand < 70 {
    let idx = @raylib.get_random_value(0, empty.length() - 1)
    Some(empty[idx])
  } else {
    // Pick best of 3 random candidates (soft heuristic)
    let pick = select_easy_heuristic(board, player, empty)
    Some(pick)
  }
}

///|
/// Easy heuristic: pick best of a small random sample (testable core)
pub fn select_easy_heuristic(
  board : @types.HexBoard,
  player : @types.Player,
  empty : Array[@types.HexCoord],
) -> @types.HexCoord {
  let sample_size = @types.mini(empty.length(), 3)
  let mut best_score = -999999
  let mut best = empty[0]
  for i in 0..<sample_size {
    let idx = if empty.length() <= sample_size {
      i
    } else {
      @raylib.get_random_value(0, empty.length() - 1)
    }
    let pos = empty[idx]
    let score = evaluate_move(board, pos, player)
    if score > best_score {
      best_score = score
      best = pos
    }
  }
  best
}

///|
/// Normal: evaluate each move by immediate pattern score + capture score.
/// Picks the best immediate move most of the time, with occasional randomness.
fn select_normal(
  board : @types.HexBoard,
  player : @types.Player,
  empty : Array[@types.HexCoord],
) -> @types.HexCoord? {
  if empty.length() == 0 {
    return None
  }
  let ranked = rank_moves(board, player, empty)
  // 10% chance to pick second-best or random for variety
  let rand = @raylib.get_random_value(0, 100)
  if rand < 10 && ranked.length() >= 2 {
    Some(ranked[1])
  } else {
    Some(ranked[0])
  }
}

///|
/// Rank moves by immediate evaluation score (best first). Testable core.
pub fn rank_moves(
  board : @types.HexBoard,
  player : @types.Player,
  empty : Array[@types.HexCoord],
) -> Array[@types.HexCoord] {
  let scored : Array[(Int, Int)] = [] // (score, index)
  for i in 0..<empty.length() {
    scored.push((evaluate_move(board, empty[i], player), i))
  }
  // Selection sort descending by score
  let result : Array[@types.HexCoord] = []
  let used : Array[Bool] = Array::make(empty.length(), false)
  for _pick in 0..<empty.length() {
    let mut best_s = -999999
    let mut best_i = -1
    for j in 0..<scored.length() {
      if !used[j] && scored[j].0 > best_s {
        best_s = scored[j].0
        best_i = j
      }
    }
    if best_i >= 0 {
      used[best_i] = true
      result.push(empty[scored[best_i].1])
    }
  }
  result
}

///|
/// Hard: minimax with alpha-beta pruning, consistent depth-2 lookahead.
/// Evaluates more candidate moves and uses full lookahead for all of them.
fn select_hard(
  board : @types.HexBoard,
  player : @types.Player,
  empty : Array[@types.HexCoord],
) -> @types.HexCoord? {
  if empty.length() == 0 {
    return None
  }
  // Use more candidates for better coverage
  let max_moves = @types.mini(empty.length(), 20)
  let candidates = get_candidate_moves(board, player, empty, max_moves)
  let best = select_hard_core(board, player, candidates)
  Some(best)
}

///|
/// Hard AI core: minimax over candidates. Testable without raylib randomness.
pub fn select_hard_core(
  board : @types.HexBoard,
  player : @types.Player,
  candidates : Array[@types.HexCoord],
) -> @types.HexCoord {
  let mut best_score = -999999
  let mut best_idx = 0
  for i in 0..<candidates.length() {
    let pos = candidates[i]
    let test_board = @types.clone_board(board)
    @types.set_cell(test_board, pos, Occupied(player))
    let captured = @board.resolve_captures(test_board, player)
    let capture_bonus = captured.length() * 3
    let score = capture_bonus +
      minimax(
        test_board,
        @types.opponent(player),
        player,
        2,
        -999999,
        999999,
        false,
      )
    if score > best_score {
      best_score = score
      best_idx = i
    }
  }
  candidates[best_idx]
}

///|
/// Get candidate moves sorted by heuristic value (for pruning efficiency)
fn get_candidate_moves(
  board : @types.HexBoard,
  player : @types.Player,
  empty : Array[@types.HexCoord],
  max_count : Int,
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
/// Minimax with alpha-beta pruning.
/// Uses sorted candidate moves for better pruning efficiency.
fn minimax(
  board : @types.HexBoard,
  current : @types.Player,
  ai_player : @types.Player,
  depth : Int,
  alpha_in : Int,
  beta_in : Int,
  maximizing : Bool,
) -> Int {
  if depth == 0 {
    return evaluate_board(board, ai_player)
  }
  let empty = @types.empty_positions(board)
  if empty.length() == 0 {
    return evaluate_board(board, ai_player)
  }
  // Sort candidates by heuristic for better pruning; evaluate more at depth 2
  let max_eval = @types.mini(empty.length(), if depth >= 2 { 12 } else { 8 })
  let candidates = get_candidate_moves(board, current, empty, max_eval)
  let mut alpha = alpha_in
  let mut beta = beta_in
  if maximizing {
    let mut max_score = -999999
    for i in 0..<candidates.length() {
      let pos = candidates[i]
      let test_board = @types.clone_board(board)
      @types.set_cell(test_board, pos, Occupied(current))
      let _captured = @board.resolve_captures(test_board, current)
      let score = minimax(
        test_board,
        @types.opponent(current),
        ai_player,
        depth - 1,
        alpha,
        beta,
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
    for i in 0..<candidates.length() {
      let pos = candidates[i]
      let test_board = @types.clone_board(board)
      @types.set_cell(test_board, pos, Occupied(current))
      let _captured = @board.resolve_captures(test_board, current)
      let score = minimax(
        test_board,
        @types.opponent(current),
        ai_player,
        depth - 1,
        alpha,
        beta,
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
pub fn evaluate_board(board : @types.HexBoard, player : @types.Player) -> Int {
  let my_patterns = @board.score_patterns(board, player)
  let opp_patterns = @board.score_patterns(board, @types.opponent(player))
  let mut my_stones = 0
  let mut opp_stones = 0
  let mut my_center = 0
  let center = board.size / 2
  for r in 0..<board.size {
    for c in 0..<board.size {
      match board.cells[r][c] {
        Occupied(p) =>
          if p == player {
            my_stones = my_stones + 1
            // Bonus for central positioning
            let dr = r - center
            let dc = c - center
            if dr * dr + dc * dc <= 4 {
              my_center = my_center + 1
            }
          } else {
            opp_stones = opp_stones + 1
          }
        _ => ()
      }
    }
  }
  my_patterns * 3 + my_stones + my_center - opp_patterns * 3 - opp_stones
}

///|
/// Evaluate a single move by placing it on a clone and measuring improvement
pub fn evaluate_move(
  board : @types.HexBoard,
  pos : @types.HexCoord,
  player : @types.Player,
) -> Int {
  let before = @board.score_patterns(board, player)
  let test_board = @types.clone_board(board)
  @types.set_cell(test_board, pos, Occupied(player))
  let captured = @board.resolve_captures(test_board, player)
  let after = @board.score_patterns(test_board, player)
  let pattern_gain = after - before
  let capture_gain = captured.length() * 2
  // Bonus for center positions (stronger gradient)
  let center = @types.board_size / 2
  let dr = pos.row - center
  let dc = pos.col - center
  let dist = dr * dr + dc * dc
  let center_bonus = if dist <= 1 { 3 } else if dist <= 4 { 1 } else { 0 }
  // Bonus for blocking opponent patterns
  let opp = @types.opponent(player)
  let opp_before = @board.score_patterns(board, opp)
  let opp_after = @board.score_patterns(test_board, opp)
  let block_bonus = opp_before - opp_after
  // Bonus for adjacent to own stones (connectivity)
  let nbrs = @types.hex_neighbors_valid(pos, board.size)
  let mut adjacency = 0
  for i in 0..<nbrs.length() {
    if @types.has_stone(board, nbrs[i], player) {
      adjacency = adjacency + 1
    }
  }
  pattern_gain * 3 + capture_gain * 2 + center_bonus + block_bonus + adjacency
}
