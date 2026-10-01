///|
test "hex_neighbors returns 6 neighbors" {
  let coord : @types.HexCoord = { row: 3, col: 3, }
  let nbrs = @types.hex_neighbors(coord)
  assert_eq(nbrs.length(), 6)
}

///|
test "hex_neighbors_valid filters out of bounds" {
  let coord : @types.HexCoord = { row: 0, col: 0, }
  let nbrs = @types.hex_neighbors_valid(coord, @types.board_size)
  // Corner cell should have fewer than 6 valid neighbors
  assert_true(nbrs.length() < 6)
  assert_true(nbrs.length() >= 2)
}

///|
test "hex_to_pixel and pixel_to_hex roundtrip" {
  let coord : @types.HexCoord = { row: 3, col: 3, }
  let (px, py) = @types.hex_to_pixel(coord, @types.hex_size)
  let result = @types.pixel_to_hex(px, py, @types.hex_size)
  match result {
    Some(c) => {
      assert_eq(c.row, 3)
      assert_eq(c.col, 3)
    }
    None => assert_true(false)
  }
}

///|
test "new_board creates empty board" {
  let board = @types.new_board(7)
  assert_eq(board.size, 7)
  assert_eq(@types.count_empty(board), 49)
}

///|
test "set_cell and get_cell" {
  let board = @types.new_board(7)
  let coord : @types.HexCoord = { row: 2, col: 3, }
  @types.set_cell(board, coord, Occupied(Black))
  assert_eq(@types.get_cell(board, coord), Occupied(Black))
  assert_true(@types.has_stone(board, coord, Black))
  assert_true(!@types.has_stone(board, coord, White))
}

///|
test "clone_board creates independent copy" {
  let board = @types.new_board(7)
  @types.set_cell(board, { row: 0, col: 0, }, Occupied(Black))
  let cloned = @types.clone_board(board)
  @types.set_cell(cloned, { row: 0, col: 0, }, Empty)
  assert_eq(@types.get_cell(board, { row: 0, col: 0, }), Occupied(Black))
  assert_eq(@types.get_cell(cloned, { row: 0, col: 0, }), Empty)
}

///|
test "is_edge detects edge positions" {
  assert_true(@types.is_edge({ row: 0, col: 3, }, 7))
  assert_true(@types.is_edge({ row: 6, col: 3, }, 7))
  assert_true(@types.is_edge({ row: 3, col: 0, }, 7))
  assert_true(@types.is_edge({ row: 3, col: 6, }, 7))
  assert_true(!@types.is_edge({ row: 3, col: 3, }, 7))
}

///|
test "opponent returns opposite player" {
  assert_eq(@types.opponent(Black), White)
  assert_eq(@types.opponent(White), Black)
}

///|
test "empty_positions returns all empty cells" {
  let board = @types.new_board(7)
  @types.set_cell(board, { row: 0, col: 0, }, Occupied(Black))
  @types.set_cell(board, { row: 1, col: 1, }, Occupied(White))
  let empty = @types.empty_positions(board)
  assert_eq(empty.length(), 47)
}
