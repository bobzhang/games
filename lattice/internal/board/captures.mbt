///|
/// Count liberties (empty adjacent cells) for a group containing the given stone
pub fn count_liberties(board : @types.HexBoard, coord : @types.HexCoord) -> Int {
  let state = @types.get_cell(board, coord)
  match state {
    Empty => 0
    Occupied(player) => {
      let group = find_group(board, coord, player)
      let mut liberties = 0
      let counted : Array[@types.HexCoord] = []
      for gi in 0..<group.length() {
        let nbrs = @types.hex_neighbors_valid(group[gi], board.size)
        for ni in 0..<nbrs.length() {
          let n = nbrs[ni]
          if @types.get_cell(board, n) == Empty {
            if !@types.hex_contains(counted, n) {
              counted.push(n)
              liberties = liberties + 1
            }
          }
        }
      }
      liberties
    }
  }
}

///|
/// Find all connected stones of the same player starting from coord (flood fill)
pub fn find_group(
  board : @types.HexBoard,
  start : @types.HexCoord,
  player : @types.Player,
) -> Array[@types.HexCoord] {
  let group : Array[@types.HexCoord] = []
  let stack : Array[@types.HexCoord] = [start]
  let visited : Array[@types.HexCoord] = []
  while stack.length() > 0 {
    let cur = stack.unsafe_pop()
    if @types.hex_contains(visited, cur) {
      continue
    }
    visited.push(cur)
    if @types.has_stone(board, cur, player) {
      group.push(cur)
      let nbrs = @types.hex_neighbors_valid(cur, board.size)
      for i in 0..<nbrs.length() {
        if !@types.hex_contains(visited, nbrs[i]) {
          stack.push(nbrs[i])
        }
      }
    }
  }
  group
}

///|
/// Remove captured stones for the opponent of the player who just moved.
/// Returns the number of stones captured and their positions.
pub fn resolve_captures(
  board : @types.HexBoard,
  last_player : @types.Player,
) -> Array[@types.HexCoord] {
  let captured : Array[@types.HexCoord] = []
  let opp = @types.opponent(last_player)
  // Find all opponent groups and check if any have 0 liberties
  let checked : Array[@types.HexCoord] = []
  for r in 0..<board.size {
    for c in 0..<board.size {
      let coord : @types.HexCoord = { row: r, col: c }
      if @types.has_stone(board, coord, opp) &&
        !@types.hex_contains(checked, coord) {
        let group = find_group(board, coord, opp)
        for gi in 0..<group.length() {
          checked.push(group[gi])
        }
        let libs = count_group_liberties(board, group)
        if libs == 0 {
          for gi in 0..<group.length() {
            captured.push(group[gi])
          }
        }
      }
    }
  }
  // Remove captured stones
  for i in 0..<captured.length() {
    @types.set_cell(board, captured[i], Empty)
  }
  captured
}

///|
/// Count liberties for a pre-found group
fn count_group_liberties(
  board : @types.HexBoard,
  group : Array[@types.HexCoord],
) -> Int {
  let mut liberties = 0
  let counted : Array[@types.HexCoord] = []
  for gi in 0..<group.length() {
    let nbrs = @types.hex_neighbors_valid(group[gi], board.size)
    for ni in 0..<nbrs.length() {
      let n = nbrs[ni]
      if @types.get_cell(board, n) == Empty {
        if !@types.hex_contains(counted, n) {
          counted.push(n)
          liberties = liberties + 1
        }
      }
    }
  }
  liberties
}

///|
/// Resolve captures with cascading: removing one group may free up
/// space that causes another group to lose all liberties
pub fn resolve_captures_cascading(
  board : @types.HexBoard,
  last_player : @types.Player,
) -> Array[@types.HexCoord] {
  let all_captured : Array[@types.HexCoord] = []
  // First capture opponent stones
  let captured = resolve_captures(board, last_player)
  for i in 0..<captured.length() {
    all_captured.push(captured[i])
  }
  // If captures happened, check if the removal causes new captures
  // (cascading) - now check the player's own stones too
  if captured.length() > 0 {
    // Re-check both players for new captures
    let cascade1 = resolve_captures(board, @types.opponent(last_player))
    for i in 0..<cascade1.length() {
      all_captured.push(cascade1[i])
    }
    // And check opponent again
    let cascade2 = resolve_captures(board, last_player)
    for i in 0..<cascade2.length() {
      all_captured.push(cascade2[i])
    }
  }
  all_captured
}

///|
/// Evaluate capture potential for a move (how many stones would be captured)
pub fn evaluate_captures(
  board : @types.HexBoard,
  coord : @types.HexCoord,
  player : @types.Player,
) -> Int {
  let test_board = @types.clone_board(board)
  @types.set_cell(test_board, coord, Occupied(player))
  let captured = resolve_captures(test_board, player)
  captured.length()
}
