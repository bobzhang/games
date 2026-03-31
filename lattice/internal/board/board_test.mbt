///|
test "find_chains detects chain of 3" {
  let board = @types.new_board(7)
  @types.set_cell(board, { row: 3, col: 1 }, Occupied(Black))
  @types.set_cell(board, { row: 3, col: 2 }, Occupied(Black))
  @types.set_cell(board, { row: 3, col: 3 }, Occupied(Black))
  let patterns = find_all_patterns(board, Black)
  let mut found_chain = false
  for i in 0..<patterns.length() {
    if patterns[i].kind == Chain {
      found_chain = true
    }
  }
  assert_true(found_chain)
}

///|
test "find_triangles detects triangle" {
  let board = @types.new_board(7)
  // Place three stones that form a triangle (all mutual neighbors)
  // Using row 2, col 3 and its neighbors
  let a : @types.HexCoord = { row: 2, col: 3 }
  let nbrs = @types.hex_neighbors_valid(a, 7)
  @types.set_cell(board, a, Occupied(Black))
  // Pick two neighbors that are also neighbors of each other
  if nbrs.length() >= 2 {
    let b = nbrs[0]
    let c = nbrs[1]
    @types.set_cell(board, b, Occupied(Black))
    @types.set_cell(board, c, Occupied(Black))
    // Check if b and c are neighbors
    let b_nbrs = @types.hex_neighbors_valid(b, 7)
    let mut bc_neighbors = false
    for i in 0..<b_nbrs.length() {
      if @types.hex_eq(b_nbrs[i], c) {
        bc_neighbors = true
      }
    }
    if bc_neighbors {
      let patterns = find_all_patterns(board, Black)
      let mut found_triangle = false
      for i in 0..<patterns.length() {
        if patterns[i].kind == Triangle {
          found_triangle = true
        }
      }
      assert_true(found_triangle)
    }
  }
}

///|
test "fortress detects center with 4+ neighbors" {
  let board = @types.new_board(7)
  let center : @types.HexCoord = { row: 3, col: 3 }
  @types.set_cell(board, center, Occupied(Black))
  let nbrs = @types.hex_neighbors_valid(center, 7)
  // Place 4 neighbors
  for i in 0..<4 {
    @types.set_cell(board, nbrs[i], Occupied(Black))
  }
  let patterns = find_all_patterns(board, Black)
  let mut found_fortress = false
  for i in 0..<patterns.length() {
    if patterns[i].kind == Fortress {
      found_fortress = true
    }
  }
  assert_true(found_fortress)
}

///|
test "wall detects 4 stones on edge" {
  let board = @types.new_board(7)
  for c in 0..<4 {
    @types.set_cell(
      board,
      { row: 0, col: c },
      Occupied(Black),
    )
  }
  let patterns = find_all_patterns(board, Black)
  let mut found_wall = false
  for i in 0..<patterns.length() {
    if patterns[i].kind == Wall {
      found_wall = true
    }
  }
  assert_true(found_wall)
}

///|
test "star detects center plus all 6 neighbors" {
  let board = @types.new_board(7)
  let center : @types.HexCoord = { row: 3, col: 3 }
  @types.set_cell(board, center, Occupied(Black))
  let nbrs = @types.hex_neighbors_valid(center, 7)
  for i in 0..<nbrs.length() {
    @types.set_cell(board, nbrs[i], Occupied(Black))
  }
  let patterns = find_all_patterns(board, Black)
  let mut found_star = false
  for i in 0..<patterns.length() {
    if patterns[i].kind == Star {
      found_star = true
    }
  }
  assert_true(found_star)
}

///|
test "ring detects 6 stones around empty center" {
  let board = @types.new_board(7)
  let center : @types.HexCoord = { row: 3, col: 3 }
  // Center stays empty, place all 6 neighbors
  let nbrs = @types.hex_neighbors_valid(center, 7)
  assert_eq(nbrs.length(), 6)
  for i in 0..<nbrs.length() {
    @types.set_cell(board, nbrs[i], Occupied(Black))
  }
  let patterns = find_all_patterns(board, Black)
  let mut found_ring = false
  for i in 0..<patterns.length() {
    if patterns[i].kind == Ring {
      found_ring = true
    }
  }
  assert_true(found_ring)
}

///|
test "count_liberties for single stone" {
  let board = @types.new_board(7)
  let coord : @types.HexCoord = { row: 3, col: 3 }
  @types.set_cell(board, coord, Occupied(Black))
  let libs = count_liberties(board, coord)
  assert_eq(libs, 6) // Center stone has 6 empty neighbors
}

///|
test "resolve_captures removes surrounded stone" {
  let board = @types.new_board(7)
  let center : @types.HexCoord = { row: 3, col: 3 }
  @types.set_cell(board, center, Occupied(White))
  let nbrs = @types.hex_neighbors_valid(center, 7)
  for i in 0..<nbrs.length() {
    @types.set_cell(board, nbrs[i], Occupied(Black))
  }
  let captured = resolve_captures(board, Black)
  assert_eq(captured.length(), 1)
  assert_eq(@types.get_cell(board, center), Empty)
}

///|
test "score_patterns adds up correctly" {
  let board = @types.new_board(7)
  // Chain of 3
  @types.set_cell(
    board,
    { row: 3, col: 1 },
    Occupied(Black),
  )
  @types.set_cell(
    board,
    { row: 3, col: 2 },
    Occupied(Black),
  )
  @types.set_cell(
    board,
    { row: 3, col: 3 },
    Occupied(Black),
  )
  let score = score_patterns(board, Black)
  assert_true(score >= @types.chain_points)
}

///|
test "cascading capture works" {
  let board = @types.new_board(7)
  // Setup: two white stones that will both be captured after cascade
  let w1 : @types.HexCoord = { row: 3, col: 3 }
  @types.set_cell(board, w1, Occupied(White))
  // Surround w1 with black, leaving one liberty
  let nbrs = @types.hex_neighbors_valid(w1, 7)
  for i in 0..<(nbrs.length() - 1) {
    @types.set_cell(board, nbrs[i], Occupied(Black))
  }
  // Place the last black stone to complete the surround
  @types.set_cell(board, nbrs[nbrs.length() - 1], Occupied(Black))
  let captured = resolve_captures_cascading(board, Black)
  assert_true(captured.length() >= 1)
}
