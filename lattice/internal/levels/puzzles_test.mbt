///|
test "create_puzzles returns exactly 20 puzzles" {
  let puzzles = @levels.create_puzzles()
  assert_eq(puzzles.length(), 20)
}

///|
test "all puzzles have sequential IDs 1-20" {
  let puzzles = @levels.create_puzzles()
  for i in 0..<puzzles.length() {
    assert_eq(puzzles[i].id, i + 1)
  }
}

///|
test "all puzzles have valid board dimensions" {
  let puzzles = @levels.create_puzzles()
  for i in 0..<puzzles.length() {
    let p = puzzles[i]
    assert_eq(p.board.size, @types.board_size)
    assert_eq(p.board.cells.length(), @types.board_size)
    for r in 0..<p.board.size {
      assert_eq(p.board.cells[r].length(), @types.board_size)
    }
  }
}

///|
test "all puzzles have positive target scores" {
  let puzzles = @levels.create_puzzles()
  for i in 0..<puzzles.length() {
    assert_true(puzzles[i].target_score > 0)
  }
}

///|
test "all puzzles have non-empty hints" {
  let puzzles = @levels.create_puzzles()
  for i in 0..<puzzles.length() {
    assert_true(puzzles[i].hint.length() > 0)
  }
}

///|
test "all puzzles have at least one stone placed" {
  let puzzles = @levels.create_puzzles()
  for i in 0..<puzzles.length() {
    let p = puzzles[i]
    let empty_count = @types.count_empty(p.board)
    let total = @types.board_size * @types.board_size
    assert_true(empty_count < total)
  }
}

///|
test "all puzzles have at least one empty cell for player move" {
  let puzzles = @levels.create_puzzles()
  for i in 0..<puzzles.length() {
    let empty_count = @types.count_empty(puzzles[i].board)
    assert_true(empty_count > 0)
  }
}

///|
test "puzzle 1 (Bridge) board has exactly 1 black stone" {
  let puzzles = @levels.create_puzzles()
  let p = puzzles[0]
  let mut black_count = 0
  for r in 0..<p.board.size {
    for c in 0..<p.board.size {
      if p.board.cells[r][c] == Occupied(Black) {
        black_count += 1
      }
    }
  }
  assert_eq(black_count, 1)
  assert_eq(p.target_score, 2)
}

///|
test "puzzle 2 (Chain) board has 2 black stones in a row" {
  let puzzles = @levels.create_puzzles()
  let p = puzzles[1]
  assert_true(@types.has_stone(p.board, { row: 3, col: 1 }, Black))
  assert_true(@types.has_stone(p.board, { row: 3, col: 2 }, Black))
  assert_eq(p.target_score, 3)
}

///|
test "puzzle 4 (Capture) board has white stone nearly surrounded" {
  let puzzles = @levels.create_puzzles()
  let p = puzzles[3]
  assert_true(@types.has_stone(p.board, { row: 3, col: 3 }, White))
  // Count surrounding Black stones
  let nbrs = @types.hex_neighbors_valid({ row: 3, col: 3 }, 7)
  let mut black_around = 0
  for i in 0..<nbrs.length() {
    if @types.has_stone(p.board, nbrs[i], Black) {
      black_around += 1
    }
  }
  // Most neighbors should be Black (leaving 1 liberty for player to close)
  assert_true(black_around >= 4)
}

///|
test "puzzle 6 (Wall) board has 3 black stones on top edge" {
  let puzzles = @levels.create_puzzles()
  let p = puzzles[5]
  assert_true(@types.has_stone(p.board, { row: 0, col: 0 }, Black))
  assert_true(@types.has_stone(p.board, { row: 0, col: 1 }, Black))
  assert_true(@types.has_stone(p.board, { row: 0, col: 2 }, Black))
  assert_eq(p.target_score, 3)
}

///|
test "puzzle 12 (Ring) board has 5 stones around center" {
  let puzzles = @levels.create_puzzles()
  let p = puzzles[11]
  // Center (3,3) should be empty
  assert_eq(@types.get_cell(p.board, { row: 3, col: 3 }), Empty)
  // Count stones adjacent to center
  let nbrs = @types.hex_neighbors_valid({ row: 3, col: 3 }, 7)
  let mut stone_count = 0
  for i in 0..<nbrs.length() {
    if @types.has_stone(p.board, nbrs[i], Black) {
      stone_count += 1
    }
  }
  assert_eq(stone_count, 5)
  assert_eq(p.target_score, 7)
}

///|
test "puzzle 13 (Star) board has center + 5 neighbors" {
  let puzzles = @levels.create_puzzles()
  let p = puzzles[12]
  assert_true(@types.has_stone(p.board, { row: 3, col: 3 }, Black))
  let nbrs = @types.hex_neighbors_valid({ row: 3, col: 3 }, 7)
  let mut stone_count = 0
  for i in 0..<nbrs.length() {
    if @types.has_stone(p.board, nbrs[i], Black) {
      stone_count += 1
    }
  }
  assert_eq(stone_count, 5)
  assert_eq(p.target_score, 8)
}

///|
test "puzzle 20 (Grand Finale) board has both black and white stones" {
  let puzzles = @levels.create_puzzles()
  let p = puzzles[19]
  let mut black_count = 0
  let mut white_count = 0
  for r in 0..<p.board.size {
    for c in 0..<p.board.size {
      match p.board.cells[r][c] {
        Occupied(Black) => black_count += 1
        Occupied(White) => white_count += 1
        Empty => ()
      }
    }
  }
  assert_true(black_count >= 4)
  assert_true(white_count >= 1)
  assert_eq(p.target_score, 10)
}

///|
test "all puzzles have achievable target scores via patterns or captures" {
  let puzzles = @levels.create_puzzles()
  for idx in 0..<puzzles.length() {
    let p = puzzles[idx]
    // Check there exists at least one move that could contribute points
    let empty = @types.empty_positions(p.board)
    let mut max_score_gain = 0
    let base_patterns = @board.score_patterns(p.board, p.current_player)
    for i in 0..<empty.length() {
      let test_board = @types.clone_board(p.board)
      @types.set_cell(test_board, empty[i], Occupied(p.current_player))
      let captured = @board.resolve_captures(test_board, p.current_player)
      let new_patterns = @board.score_patterns(test_board, p.current_player)
      let gain = new_patterns - base_patterns + captured.length()
      if gain > max_score_gain {
        max_score_gain = gain
      }
    }
    // At least one move should produce some points
    assert_true(max_score_gain > 0)
  }
}

///|
test "all puzzles current_player is Black" {
  let puzzles = @levels.create_puzzles()
  for i in 0..<puzzles.length() {
    assert_eq(puzzles[i].current_player, Black)
  }
}

///|
test "all puzzles have stones only at valid positions" {
  let puzzles = @levels.create_puzzles()
  for i in 0..<puzzles.length() {
    let p = puzzles[i]
    for r in 0..<p.board.size {
      for c in 0..<p.board.size {
        let cell = p.board.cells[r][c]
        match cell {
          Occupied(player) => assert_true(player == Black || player == White)
          Empty => ()
        }
      }
    }
  }
}

///|
test "puzzle boards are independent copies" {
  let puzzles = @levels.create_puzzles()
  // Modify puzzle 1's board, puzzle 2 should be unaffected
  let p1_original_cell = @types.get_cell(puzzles[0].board, { row: 0, col: 0 })
  @types.set_cell(puzzles[0].board, { row: 0, col: 0 }, Occupied(White))
  let p2_cell = @types.get_cell(puzzles[1].board, { row: 0, col: 0 })
  // Restore
  @types.set_cell(puzzles[0].board, { row: 0, col: 0 }, p1_original_cell)
  // Puzzle 2 should not have been affected
  assert_eq(p2_cell, Empty)
}
