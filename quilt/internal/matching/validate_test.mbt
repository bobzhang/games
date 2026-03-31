///|
test "count_edge_pairs 3x3" {
  let board = @types.new_board(3)
  // 3x3 grid: 3*2 horizontal + 2*3 vertical = 12 pairs
  inspect(@matching.count_edge_pairs(board), content="12")
}

///|
test "count_edge_pairs 4x4" {
  let board = @types.new_board(4)
  // 4x4 grid: 4*3 horizontal + 3*4 vertical = 24 pairs
  inspect(@matching.count_edge_pairs(board), content="24")
}

///|
test "count_filled_cells empty" {
  let board = @types.new_board(3)
  inspect(@matching.count_filled_cells(board), content="0")
}

///|
test "count_filled_cells partial" {
  let board = @types.new_board(3)
  @types.board_set(board, 0, 0, Some(@types.new_patch(Zigzag, Dots, Stripes, Waves)))
  @types.board_set(board, 1, 1, Some(@types.new_patch(Dots, Stripes, Waves, Zigzag)))
  inspect(@matching.count_filled_cells(board), content="2")
}

///|
test "is_board_full false when empty" {
  let board = @types.new_board(3)
  inspect(@matching.is_board_full(board), content="false")
}

///|
test "count_matched_pairs matching neighbors" {
  let board = @types.new_board(2)
  // Place two patches side by side with matching east/west edges
  // Left patch east edge = Dots, Right patch west edge = Dots
  @types.board_set(board, 0, 0, Some(@types.new_patch(Zigzag, Dots, Stripes, Waves)))
  @types.board_set(board, 0, 1, Some(@types.new_patch(Zigzag, Stripes, Waves, Dots)))
  // East of (0,0) = Dots, West of (0,1) = Dots -> match
  let matched = @matching.count_matched_pairs(board)
  inspect(matched, content="1")
}

///|
test "count_matched_pairs mismatched neighbors" {
  let board = @types.new_board(2)
  @types.board_set(board, 0, 0, Some(@types.new_patch(Zigzag, Dots, Stripes, Waves)))
  @types.board_set(board, 0, 1, Some(@types.new_patch(Zigzag, Stripes, Waves, Stripes)))
  // East of (0,0) = Dots, West of (0,1) = Stripes -> no match
  let matched = @matching.count_matched_pairs(board)
  inspect(matched, content="0")
}

///|
test "count_matched_pairs with wildcard" {
  let board = @types.new_board(2)
  // Left patch has wildcard east edge
  @types.board_set(
    board,
    0,
    0,
    Some(
      @types.new_patch_wildcard(
        Zigzag, Dots, Stripes, Waves, false, true, false, false,
      ),
    ),
  )
  @types.board_set(board, 0, 1, Some(@types.new_patch(Zigzag, Stripes, Waves, Stars)))
  // East of (0,0) is wildcard -> always matches
  let matched = @matching.count_matched_pairs(board)
  inspect(matched, content="1")
}

///|
test "is_board_complete with fully matched 2x2" {
  let board = @types.new_board(2)
  // Create a fully matched 2x2:
  // (0,0) East=D, South=S    (0,1) West=D, South=W
  // (1,0) North=S, East=Z    (1,1) North=W, West=Z
  @types.board_set(board, 0, 0, Some(@types.new_patch(Zigzag, Dots, Stripes, Waves)))
  @types.board_set(board, 0, 1, Some(@types.new_patch(Zigzag, Stars, Waves, Dots)))
  @types.board_set(board, 1, 0, Some(@types.new_patch(Stripes, Zigzag, Diamonds, Stars)))
  @types.board_set(board, 1, 1, Some(@types.new_patch(Waves, Diamonds, Stars, Zigzag)))
  inspect(@matching.is_board_complete(board), content="true")
}

///|
test "is_board_complete fails when not full" {
  let board = @types.new_board(2)
  @types.board_set(board, 0, 0, Some(@types.new_patch(Zigzag, Dots, Stripes, Waves)))
  inspect(@matching.is_board_complete(board), content="false")
}

///|
test "match_percentage empty board" {
  let board = @types.new_board(3)
  inspect(@matching.match_percentage(board), content="0")
}

///|
test "compute_stars 3 stars" {
  let level : @types.Level = {
    board_size: 3,
    patches: [],
    pinned_positions: [],
    pinned_patches: [],
    par_rotations: 10,
    par_swaps: 5,
    tier: Scraps,
    level_num: 1,
  }
  inspect(@matching.compute_stars(level, 8, 3), content="3")
}

///|
test "compute_stars 2 stars" {
  let level : @types.Level = {
    board_size: 3,
    patches: [],
    pinned_positions: [],
    pinned_patches: [],
    par_rotations: 10,
    par_swaps: 5,
    tier: Scraps,
    level_num: 1,
  }
  inspect(@matching.compute_stars(level, 9, 8), content="2")
}

///|
test "compute_stars 1 star" {
  let level : @types.Level = {
    board_size: 3,
    patches: [],
    pinned_positions: [],
    pinned_patches: [],
    par_rotations: 10,
    par_swaps: 5,
    tier: Scraps,
    level_num: 1,
  }
  inspect(@matching.compute_stars(level, 15, 8), content="1")
}

///|
test "edge_matched_at boundary returns true" {
  let board = @types.new_board(3)
  @types.board_set(board, 0, 0, Some(@types.new_patch(Zigzag, Dots, Stripes, Waves)))
  // North edge at row 0 has no neighbor -> true (boundary)
  inspect(@matching.edge_matched_at(board, 0, 0, North), content="true")
  // West edge at col 0 has no neighbor -> true
  inspect(@matching.edge_matched_at(board, 0, 0, West), content="true")
}

///|
test "daily seed determinism" {
  let h1 = @matching.date_hash(2026, 3, 31)
  let h2 = @matching.date_hash(2026, 3, 31)
  inspect(h1 == h2, content="true")
  // Different dates produce different hashes
  let h3 = @matching.date_hash(2026, 4, 1)
  inspect(h1 == h3, content="false")
}

///|
test "generate_daily_board produces valid board and tray" {
  let (board, tray) = @matching.generate_daily_board(12345)
  inspect(board.size, content="4")
  inspect(tray.length(), content="16")
  // Board should be empty
  inspect(@matching.count_filled_cells(board), content="0")
}
