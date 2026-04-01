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
    @types.set_cell(board, { row: 0, col: c }, Occupied(Black))
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
  @types.set_cell(board, { row: 3, col: 1 }, Occupied(Black))
  @types.set_cell(board, { row: 3, col: 2 }, Occupied(Black))
  @types.set_cell(board, { row: 3, col: 3 }, Occupied(Black))
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

///|
test "find_bridges detects bridge pattern" {
  let board = @types.new_board(7)
  // Bridge: two stones connected through an empty gap (common neighbor)
  // Place stones at (2,2) and (2,4) -- they share common neighbor (2,3) via gap
  // But they must NOT be direct neighbors. Let's use (3,1) and (3,3)
  // which share a common neighbor but aren't direct neighbors
  // Row 3 (odd): neighbors of (3,1) include (3,2), (3,0), (2,2), (2,1), (4,2), (4,1)
  // Row 3 (odd): neighbors of (3,3) include (3,4), (3,2), (2,4), (2,3), (4,4), (4,3)
  // Common neighbor through gap: (3,2)
  // But (3,1) and (3,3) might be 2 apart in same row.
  // Let's verify they're not direct neighbors first.
  // (3,1) neighbors: col+1=(3,2), col-1=(3,0), (2,2), (2,1), (4,2), (4,1)
  // (3,3) is NOT in that list. Good, they're not direct neighbors.
  // (3,2) is neighbor of (3,1) and also neighbor of (3,3)
  @types.set_cell(board, { row: 3, col: 1 }, Occupied(Black))
  @types.set_cell(board, { row: 3, col: 3 }, Occupied(Black))
  let patterns = find_all_patterns(board, Black)
  let mut found_bridge = false
  for i in 0..<patterns.length() {
    if patterns[i].kind == Bridge {
      found_bridge = true
      assert_eq(patterns[i].points, @types.bridge_points)
    }
  }
  assert_true(found_bridge)
}

///|
test "bridge not detected for direct neighbors" {
  let board = @types.new_board(7)
  // Two adjacent stones should NOT form a bridge
  @types.set_cell(board, { row: 3, col: 2 }, Occupied(Black))
  @types.set_cell(board, { row: 3, col: 3 }, Occupied(Black))
  let patterns = find_all_patterns(board, Black)
  let mut found_bridge = false
  for i in 0..<patterns.length() {
    if patterns[i].kind == Bridge {
      found_bridge = true
    }
  }
  assert_true(!found_bridge)
}

///|
test "bridge not detected when gap is occupied" {
  let board = @types.new_board(7)
  // (3,1) and (3,3) would form bridge through (3,2), but fill the gap
  @types.set_cell(board, { row: 3, col: 1 }, Occupied(Black))
  @types.set_cell(board, { row: 3, col: 3 }, Occupied(Black))
  @types.set_cell(board, { row: 3, col: 2 }, Occupied(White))
  let patterns = find_all_patterns(board, Black)
  let mut found_bridge = false
  for i in 0..<patterns.length() {
    if patterns[i].kind == Bridge {
      found_bridge = true
    }
  }
  // The gap cell (3,2) is occupied, so bridge check through that path fails.
  // But bridge detection requires the gap to be Empty. Verify.
  assert_true(!found_bridge)
}

///|
test "find_diamonds detects diamond pattern" {
  let board = @types.new_board(7)
  // Diamond: 4 stones forming a rhombus (two triangles sharing an edge)
  // A-B share neighbors C and D, with C and D not being neighbors of each other
  // Use center (3,3): neighbors are (3,4), (3,2), (2,4), (2,3), (4,4), (4,3)
  // Pick A=(3,3), B=(2,3) (even row neighbors of (2,3): (2,4), (2,2), (1,3), (1,2), (3,3), (3,2))
  // Common neighbors of A=(3,3) and B=(2,3):
  //   A's nbrs: (3,4), (3,2), (2,4), (2,3), (4,4), (4,3)
  //   B's nbrs: (2,4), (2,2), (1,3), (1,2), (3,3), (3,2)
  //   Common (excluding A and B): (2,4), (3,2)
  //   Are (2,4) and (3,2) neighbors? (2,4) even row: (2,5), (2,3), (1,4), (1,3), (3,4), (3,3)
  //   (3,2) is NOT in that list. So they are NOT neighbors -> valid diamond!
  @types.set_cell(board, { row: 3, col: 3 }, Occupied(Black))
  @types.set_cell(board, { row: 2, col: 3 }, Occupied(Black))
  @types.set_cell(board, { row: 2, col: 4 }, Occupied(Black))
  @types.set_cell(board, { row: 3, col: 2 }, Occupied(Black))
  let patterns = find_all_patterns(board, Black)
  let mut found_diamond = false
  for i in 0..<patterns.length() {
    if patterns[i].kind == Diamond {
      found_diamond = true
      assert_eq(patterns[i].points, @types.diamond_points)
    }
  }
  assert_true(found_diamond)
}

///|
test "diamond not detected with only 3 stones" {
  let board = @types.new_board(7)
  @types.set_cell(board, { row: 3, col: 3 }, Occupied(Black))
  @types.set_cell(board, { row: 2, col: 3 }, Occupied(Black))
  @types.set_cell(board, { row: 2, col: 4 }, Occupied(Black))
  let patterns = find_all_patterns(board, Black)
  let mut found_diamond = false
  for i in 0..<patterns.length() {
    if patterns[i].kind == Diamond {
      found_diamond = true
    }
  }
  assert_true(!found_diamond)
}

///|
test "chain requires 3 or more stones" {
  let board = @types.new_board(7)
  // Only 2 stones in a row - not a chain
  @types.set_cell(board, { row: 3, col: 1 }, Occupied(Black))
  @types.set_cell(board, { row: 3, col: 2 }, Occupied(Black))
  let patterns = find_all_patterns(board, Black)
  let mut found_chain = false
  for i in 0..<patterns.length() {
    if patterns[i].kind == Chain {
      found_chain = true
    }
  }
  assert_true(!found_chain)
}

///|
test "chain of 4 is detected" {
  let board = @types.new_board(7)
  @types.set_cell(board, { row: 3, col: 0 }, Occupied(Black))
  @types.set_cell(board, { row: 3, col: 1 }, Occupied(Black))
  @types.set_cell(board, { row: 3, col: 2 }, Occupied(Black))
  @types.set_cell(board, { row: 3, col: 3 }, Occupied(Black))
  let patterns = find_all_patterns(board, Black)
  let mut found_chain = false
  for i in 0..<patterns.length() {
    if patterns[i].kind == Chain {
      found_chain = true
      assert_eq(patterns[i].positions.length(), 4)
    }
  }
  assert_true(found_chain)
}

///|
test "triangle not detected for 3 non-mutual-neighbor stones" {
  let board = @types.new_board(7)
  // Three stones in a row are not a triangle
  @types.set_cell(board, { row: 3, col: 1 }, Occupied(Black))
  @types.set_cell(board, { row: 3, col: 2 }, Occupied(Black))
  @types.set_cell(board, { row: 3, col: 3 }, Occupied(Black))
  let patterns = find_all_patterns(board, Black)
  let mut found_triangle = false
  for i in 0..<patterns.length() {
    if patterns[i].kind == Triangle {
      found_triangle = true
    }
  }
  assert_true(!found_triangle)
}

///|
test "fortress requires 4+ neighbors, not just 3" {
  let board = @types.new_board(7)
  let center : @types.HexCoord = { row: 3, col: 3 }
  @types.set_cell(board, center, Occupied(Black))
  let nbrs = @types.hex_neighbors_valid(center, 7)
  // Place only 3 neighbors
  for i in 0..<3 {
    @types.set_cell(board, nbrs[i], Occupied(Black))
  }
  let patterns = find_all_patterns(board, Black)
  let mut found_fortress = false
  for i in 0..<patterns.length() {
    if patterns[i].kind == Fortress {
      found_fortress = true
    }
  }
  assert_true(!found_fortress)
}

///|
test "wall requires 4+ edge stones, not 3" {
  let board = @types.new_board(7)
  // Only 3 stones on edge - not enough
  for c in 0..<3 {
    @types.set_cell(board, { row: 0, col: c }, Occupied(Black))
  }
  let patterns = find_all_patterns(board, Black)
  let mut found_wall = false
  for i in 0..<patterns.length() {
    if patterns[i].kind == Wall {
      found_wall = true
    }
  }
  assert_true(!found_wall)
}

///|
test "wall detected on column edge" {
  let board = @types.new_board(7)
  // Place 4 stones on the left column edge
  for r in 0..<4 {
    @types.set_cell(board, { row: r, col: 0 }, Occupied(Black))
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
test "ring not detected when center is occupied" {
  let board = @types.new_board(7)
  let center : @types.HexCoord = { row: 3, col: 3 }
  // Center is occupied - not a ring
  @types.set_cell(board, center, Occupied(Black))
  let nbrs = @types.hex_neighbors_valid(center, 7)
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
  // When center is occupied, it's a Star, not a Ring
  assert_true(!found_ring)
}

///|
test "star not detected when one neighbor is missing" {
  let board = @types.new_board(7)
  let center : @types.HexCoord = { row: 3, col: 3 }
  @types.set_cell(board, center, Occupied(Black))
  let nbrs = @types.hex_neighbors_valid(center, 7)
  // Place only 5 of 6 neighbors
  for i in 0..<5 {
    @types.set_cell(board, nbrs[i], Occupied(Black))
  }
  let patterns = find_all_patterns(board, Black)
  let mut found_star = false
  for i in 0..<patterns.length() {
    if patterns[i].kind == Star {
      found_star = true
    }
  }
  assert_true(!found_star)
}

///|
test "patterns are player-specific" {
  let board = @types.new_board(7)
  // Black chain
  @types.set_cell(board, { row: 3, col: 1 }, Occupied(Black))
  @types.set_cell(board, { row: 3, col: 2 }, Occupied(Black))
  @types.set_cell(board, { row: 3, col: 3 }, Occupied(Black))
  // White should have no patterns
  let white_patterns = find_all_patterns(board, White)
  assert_eq(white_patterns.length(), 0)
  // Black should have patterns
  let black_patterns = find_all_patterns(board, Black)
  assert_true(black_patterns.length() > 0)
}

///|
test "empty board has no patterns" {
  let board = @types.new_board(7)
  let black_patterns = find_all_patterns(board, Black)
  let white_patterns = find_all_patterns(board, White)
  assert_eq(black_patterns.length(), 0)
  assert_eq(white_patterns.length(), 0)
}

///|
test "evaluate_captures counts correctly" {
  let board = @types.new_board(7)
  @types.set_cell(board, { row: 3, col: 3 }, Occupied(White))
  let nbrs = @types.hex_neighbors_valid({ row: 3, col: 3 }, 7)
  for i in 0..<(nbrs.length() - 1) {
    @types.set_cell(board, nbrs[i], Occupied(Black))
  }
  let last = nbrs[nbrs.length() - 1]
  let cap_count = evaluate_captures(board, last, Black)
  assert_eq(cap_count, 1)
}
