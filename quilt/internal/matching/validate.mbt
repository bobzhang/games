///|
pub fn count_edge_pairs(board : @types.Board) -> Int {
  let size = board.size
  let mut count = 0
  for row in 0..<size {
    for col in 0..<size {
      // Right neighbor
      if col + 1 < size {
        count += 1
      }
      // Bottom neighbor
      if row + 1 < size {
        count += 1
      }
    }
  }
  count
}

///|
pub fn count_matched_pairs(board : @types.Board) -> Int {
  let size = board.size
  let mut matched = 0
  for row in 0..<size {
    for col in 0..<size {
      match @types.board_get(board, row, col) {
        None => ()
        Some(patch) => {
          // Check east neighbor
          if col + 1 < size {
            match @types.board_get(board, row, col + 1) {
              Some(right) =>
                if @types.edges_match(
                    patch.edges[1],
                    patch.wildcard_edges[1],
                    right.edges[3],
                    right.wildcard_edges[3],
                  ) {
                  matched += 1
                }
              None => ()
            }
          }
          // Check south neighbor
          if row + 1 < size {
            match @types.board_get(board, row + 1, col) {
              Some(below) =>
                if @types.edges_match(
                    patch.edges[2],
                    patch.wildcard_edges[2],
                    below.edges[0],
                    below.wildcard_edges[0],
                  ) {
                  matched += 1
                }
              None => ()
            }
          }
        }
      }
    }
  }
  matched
}

///|
pub fn count_filled_cells(board : @types.Board) -> Int {
  let mut count = 0
  for i in 0..<board.cells.length() {
    match board.cells[i] {
      Some(_) => count += 1
      None => ()
    }
  }
  count
}

///|
pub fn is_board_full(board : @types.Board) -> Bool {
  count_filled_cells(board) == board.size * board.size
}

///|
pub fn is_board_complete(board : @types.Board) -> Bool {
  if !is_board_full(board) {
    return false
  }
  let total = count_edge_pairs(board)
  let matched = count_matched_pairs(board)
  matched == total
}

///|
pub fn match_percentage(board : @types.Board) -> Float {
  let total = count_edge_pairs(board)
  if total == 0 {
    return 0.0
  }
  let matched = count_matched_pairs(board)
  Float::from_int(matched * 100) / Float::from_int(total)
}

///|
pub fn edge_matched_at(
  board : @types.Board,
  row : Int,
  col : Int,
  dir : @types.Direction,
) -> Bool {
  match @types.board_get(board, row, col) {
    None => false
    Some(patch) =>
      match dir {
        North =>
          if row > 0 {
            match @types.board_get(board, row - 1, col) {
              Some(neighbor) =>
                @types.edges_match(
                  patch.edges[0],
                  patch.wildcard_edges[0],
                  neighbor.edges[2],
                  neighbor.wildcard_edges[2],
                )
              None => false
            }
          } else {
            true
          }
        East =>
          if col + 1 < board.size {
            match @types.board_get(board, row, col + 1) {
              Some(neighbor) =>
                @types.edges_match(
                  patch.edges[1],
                  patch.wildcard_edges[1],
                  neighbor.edges[3],
                  neighbor.wildcard_edges[3],
                )
              None => false
            }
          } else {
            true
          }
        South =>
          if row + 1 < board.size {
            match @types.board_get(board, row + 1, col) {
              Some(neighbor) =>
                @types.edges_match(
                  patch.edges[2],
                  patch.wildcard_edges[2],
                  neighbor.edges[0],
                  neighbor.wildcard_edges[0],
                )
              None => false
            }
          } else {
            true
          }
        West =>
          if col > 0 {
            match @types.board_get(board, row, col - 1) {
              Some(neighbor) =>
                @types.edges_match(
                  patch.edges[3],
                  patch.wildcard_edges[3],
                  neighbor.edges[1],
                  neighbor.wildcard_edges[1],
                )
              None => false
            }
          } else {
            true
          }
      }
  }
}

///|
pub fn compute_stars(level : @types.Level, rotations : Int, swaps : Int) -> Int {
  // 1 star: all matched
  // 2 stars: within par rotations
  // 3 stars: par rotations + par swaps
  let mut stars = 1
  if rotations <= level.par_rotations {
    stars = 2
  }
  if rotations <= level.par_rotations && swaps <= level.par_swaps {
    stars = 3
  }
  stars
}
