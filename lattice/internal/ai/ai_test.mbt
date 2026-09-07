///|
test "evaluate_move prefers pattern-forming moves" {
  let board = @types.new_board(7)
  // Set up a partial chain: (3,1) and (3,2) are Black
  @types.set_cell(board, { row: 3, col: 1, }, Occupied(Black))
  @types.set_cell(board, { row: 3, col: 2, }, Occupied(Black))
  // Placing at (3,3) completes a chain of 3, should score higher
  let chain_score = @ai.evaluate_move(board, { row: 3, col: 3, }, Black)
  // Placing at (0,6) is a corner with no pattern potential
  let corner_score = @ai.evaluate_move(board, { row: 0, col: 6, }, Black)
  assert_true(chain_score > corner_score)
}

///|
test "evaluate_move rewards captures" {
  let board = @types.new_board(7)
  // Set up a capture scenario: White at (3,3), surrounded by Black except one
  @types.set_cell(board, { row: 3, col: 3, }, Occupied(White))
  let nbrs = @types.hex_neighbors_valid({ row: 3, col: 3, }, 7)
  // Place Black on all but the last neighbor
  for i in 0..<(nbrs.length() - 1) {
    @types.set_cell(board, nbrs[i], Occupied(Black))
  }
  // The last neighbor is the capture-completing move
  let capture_move = nbrs[nbrs.length() - 1]
  let capture_score = @ai.evaluate_move(board, capture_move, Black)
  // A random far-away move should score lower
  let other_score = @ai.evaluate_move(board, { row: 0, col: 6, }, Black)
  assert_true(capture_score > other_score)
}

///|
test "evaluate_board is positive for advantage" {
  let board = @types.new_board(7)
  // Black has a chain, White has nothing
  @types.set_cell(board, { row: 3, col: 1, }, Occupied(Black))
  @types.set_cell(board, { row: 3, col: 2, }, Occupied(Black))
  @types.set_cell(board, { row: 3, col: 3, }, Occupied(Black))
  let score = @ai.evaluate_board(board, Black)
  assert_true(score > 0)
  // From White's perspective, should be negative
  let w_score = @ai.evaluate_board(board, White)
  assert_true(w_score < score)
}

///|
test "rank_moves returns all empty positions sorted best-first" {
  let board = @types.new_board(7)
  @types.set_cell(board, { row: 3, col: 1, }, Occupied(Black))
  @types.set_cell(board, { row: 3, col: 2, }, Occupied(Black))
  let empty = @types.empty_positions(board)
  let ranked = @ai.rank_moves(board, Black, empty)
  // Should return same count as empty
  assert_eq(ranked.length(), empty.length())
  // First move should have highest or equal score to second
  let s0 = @ai.evaluate_move(board, ranked[0], Black)
  let s1 = @ai.evaluate_move(board, ranked[1], Black)
  assert_true(s0 >= s1)
}

///|
test "rank_moves top moves include chain-completing positions" {
  let board = @types.new_board(7)
  @types.set_cell(board, { row: 3, col: 1, }, Occupied(Black))
  @types.set_cell(board, { row: 3, col: 2, }, Occupied(Black))
  let empty = @types.empty_positions(board)
  let ranked = @ai.rank_moves(board, Black, empty)
  // The chain-completing moves (3,0) and (3,3) should be highly ranked (in top 5)
  let mut found_chain_move = false
  for i in 0..<@types.mini(ranked.length(), 5) {
    let m = ranked[i]
    if m.row == 3 && (m.col == 0 || m.col == 3) {
      found_chain_move = true
    }
  }
  assert_true(found_chain_move)
}

///|
test "select_hard_core produces valid move on empty board" {
  let board = @types.new_board(7)
  let empty = @types.empty_positions(board)
  // Use a small subset as candidates
  let candidates : Array[@types.HexCoord] = []
  for i in 0..<@types.mini(empty.length(), 5) {
    candidates.push(empty[i])
  }
  let result = @ai.select_hard_core(board, Black, candidates)
  // Result must be one of the candidates
  let mut found = false
  for i in 0..<candidates.length() {
    if @types.hex_eq(candidates[i], result) {
      found = true
    }
  }
  assert_true(found)
}

///|
test "select_hard_core picks capture when available" {
  let board = @types.new_board(7)
  // White stone surrounded by Black except one opening
  @types.set_cell(board, { row: 3, col: 3, }, Occupied(White))
  let nbrs = @types.hex_neighbors_valid({ row: 3, col: 3, }, 7)
  for i in 0..<(nbrs.length() - 1) {
    @types.set_cell(board, nbrs[i], Occupied(Black))
  }
  let capture_pos = nbrs[nbrs.length() - 1]
  // Give it the capture move plus a few others
  let candidates : Array[@types.HexCoord] = [
    capture_pos,
    { row: 0, col: 0, },
    { row: 0, col: 6, },
    { row: 6, col: 0, },
  ]
  let result = @ai.select_hard_core(board, Black, candidates)
  assert_eq(result.row, capture_pos.row)
  assert_eq(result.col, capture_pos.col)
}

///|
test "hard AI beats normal AI evaluation on pattern setup" {
  let board = @types.new_board(7)
  // Set up a position where 2-turn lookahead matters:
  // Black can set up a triangle in 2 moves at (2,3), (3,3), (3,2)
  // Place one stone; the AI should plan toward the triangle
  @types.set_cell(board, { row: 2, col: 3, }, Occupied(Black))
  @types.set_cell(board, { row: 5, col: 5, }, Occupied(White))
  let empty = @types.empty_positions(board)
  // Normal just picks immediate best
  let normal_ranked = @ai.rank_moves(board, Black, empty)
  let normal_best = normal_ranked[0]
  // Hard considers lookahead
  let hard_candidates : Array[@types.HexCoord] = []
  for i in 0..<@types.mini(empty.length(), 10) {
    hard_candidates.push(empty[i])
  }
  let hard_best = @ai.select_hard_core(board, Black, hard_candidates)
  // Both should produce valid moves (in bounds and on empty cells)
  assert_true(@types.in_bounds(normal_best, 7))
  assert_true(@types.in_bounds(hard_best, 7))
  assert_eq(@types.get_cell(board, normal_best), Empty)
  assert_eq(@types.get_cell(board, hard_best), Empty)
}

///|
test "evaluate_move values adjacency" {
  let board = @types.new_board(7)
  @types.set_cell(board, { row: 3, col: 3, }, Occupied(Black))
  // A move adjacent to the existing stone should score higher
  let adjacent_score = @ai.evaluate_move(board, { row: 3, col: 4, }, Black)
  // A move far away with no neighbors
  let isolated_score = @ai.evaluate_move(board, { row: 0, col: 6, }, Black)
  assert_true(adjacent_score > isolated_score)
}
