///|
test "can_place_piece valid placement" {
  let region = @types.rect_region(0, 0, 5, 5)
  let grid = @types.new_grid()
  let cells = [@types.vec2i(0, 0), @types.vec2i(1, 0)]
  let pos = @types.vec2i(1, 1)
  inspect(@packing.can_place_piece(region, grid, cells, pos), content="true")
}

///|
test "can_place_piece out of bounds" {
  let region = @types.rect_region(0, 0, 5, 5)
  let grid = @types.new_grid()
  let cells = [@types.vec2i(0, 0), @types.vec2i(1, 0)]
  let pos = @types.vec2i(9, 0)
  inspect(@packing.can_place_piece(region, grid, cells, pos), content="false")
}

///|
test "can_place_piece outside active region" {
  let region = @types.rect_region(2, 2, 3, 3)
  let grid = @types.new_grid()
  let cells = [@types.vec2i(0, 0), @types.vec2i(1, 0)]
  let pos = @types.vec2i(0, 0)
  inspect(@packing.can_place_piece(region, grid, cells, pos), content="false")
}

///|
test "can_place_piece overlap detection" {
  let region = @types.rect_region(0, 0, 5, 5)
  let grid = @types.new_grid()
  grid[1][1] = 0
  let cells = [@types.vec2i(0, 0), @types.vec2i(1, 0)]
  let pos = @types.vec2i(1, 1)
  inspect(@packing.can_place_piece(region, grid, cells, pos), content="false")
}

///|
test "place and remove piece" {
  let grid = @types.new_grid()
  let cells = [@types.vec2i(0, 0), @types.vec2i(1, 0)]
  let pos = @types.vec2i(2, 3)
  @packing.place_piece(grid, cells, pos, 0)
  inspect(grid[3][2], content="0")
  inspect(grid[3][3], content="0")
  @packing.remove_piece(grid, 0)
  inspect(grid[3][2], content="-1")
  inspect(grid[3][3], content="-1")
}

///|
test "is_region_complete" {
  let region = @types.rect_region(0, 0, 2, 2)
  let grid = @types.new_grid()
  inspect(@packing.is_region_complete(region, grid), content="false")
  grid[0][0] = 0
  grid[0][1] = 0
  grid[1][0] = 1
  grid[1][1] = 1
  inspect(@packing.is_region_complete(region, grid), content="true")
}

///|
test "count_empty_cells" {
  let region = @types.rect_region(0, 0, 3, 3)
  let grid = @types.new_grid()
  inspect(@packing.count_empty_cells(region, grid), content="9")
  grid[0][0] = 0
  grid[0][1] = 0
  inspect(@packing.count_empty_cells(region, grid), content="7")
}

///|
test "is_piece_used" {
  let placed : Array[@types.PlacedPiece] = [
    {
      piece_index: 0,
      position: @types.vec2i(0, 0),
      rotation: 0,
      flipped: false,
    },
    {
      piece_index: 2,
      position: @types.vec2i(3, 3),
      rotation: 1,
      flipped: true,
    },
  ]
  inspect(@packing.is_piece_used(placed, 0), content="true")
  inspect(@packing.is_piece_used(placed, 1), content="false")
  inspect(@packing.is_piece_used(placed, 2), content="true")
}

///|
test "calculate_stars" {
  // Complete but slow
  inspect(@packing.calculate_stars(100, 20, 60, 10), content="1")
  // Within par time but too many rotations
  inspect(@packing.calculate_stars(50, 20, 60, 10), content="2")
  // Perfect
  inspect(@packing.calculate_stars(50, 8, 60, 10), content="3")
}

///|
test "count_placed" {
  let placed : Array[@types.PlacedPiece] = []
  inspect(@packing.count_placed(placed), content="0")
  placed.push(
    {
      piece_index: 0,
      position: @types.vec2i(0, 0),
      rotation: 0,
      flipped: false,
    },
  )
  inspect(@packing.count_placed(placed), content="1")
}
