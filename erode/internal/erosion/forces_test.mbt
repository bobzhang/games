///|
test "water removes top-exposed cells" {
  // 3x3 grid with top row solid, rest solid
  let grid = @types.new_grid(3, true)
  let result = apply_water(grid)
  // Top row should be removed (all are top-exposed)
  inspect(result.cells[0], content="false") // (0,0) was top-exposed
  inspect(result.cells[1], content="false") // (0,1) was top-exposed
  inspect(result.cells[2], content="false") // (0,2) was top-exposed
  // Second row should now be intact (was not top-exposed in original)
  inspect(result.cells[3], content="true") // (1,0)
  inspect(result.cells[4], content="true") // (1,1)
  inspect(result.cells[5], content="true") // (1,2)
}

///|
test "water does not remove cells with solid above" {
  // 3x3 fully solid grid
  let grid = @types.new_grid(3, true)
  let result = apply_water(grid)
  // Only top row removed, middle and bottom remain
  inspect(result.cells[3], content="true") // row 1
  inspect(result.cells[6], content="true") // row 2
}

///|
test "water removes cells exposed by gap above" {
  // 3x3 grid: top row has a gap in middle
  let grid = @types.new_grid(3, true)
  @types.grid_set(grid, 0, 1, false) // Create gap at (0,1)
  let result = apply_water(grid)
  // (0,0) and (0,2) are top-exposed -> removed
  inspect(result.cells[0], content="false")
  inspect(result.cells[2], content="false")
  // (1,1) now has empty space above -> should be removed
  inspect(result.cells[4], content="false")
  // (1,0) still has solid (0,0) above in ORIGINAL grid... wait, (0,0) is solid in original
  // so (1,0) is NOT top-exposed. Let me re-check: is_top_exposed checks original grid
  inspect(result.cells[3], content="true") // (1,0) had solid above
}

///|
test "wind left removes left-exposed cells" {
  let grid = @types.new_grid(3, true)
  let result = apply_wind_left(grid)
  // Left column should be removed
  inspect(result.cells[0], content="false") // (0,0)
  inspect(result.cells[3], content="false") // (1,0)
  inspect(result.cells[6], content="false") // (2,0)
  // Middle column should remain
  inspect(result.cells[1], content="true") // (0,1)
  inspect(result.cells[4], content="true") // (1,1)
}

///|
test "wind right removes right-exposed cells" {
  let grid = @types.new_grid(3, true)
  let result = apply_wind_right(grid)
  // Right column should be removed
  inspect(result.cells[2], content="false") // (0,2)
  inspect(result.cells[5], content="false") // (1,2)
  inspect(result.cells[8], content="false") // (2,2)
  // Middle column should remain
  inspect(result.cells[1], content="true") // (0,1)
}

///|
test "frost removes cells with 3+ empty neighbors" {
  // 3x3 grid with only center and one neighbor solid
  let grid = @types.new_grid(3, false)
  @types.grid_set(grid, 1, 1, true) // center
  @types.grid_set(grid, 1, 0, true) // left of center
  // Center has: up=empty, down=empty, left=solid, right=empty -> 3 empty neighbors
  let result = apply_frost(grid)
  inspect(result.cells[4], content="false") // center removed (3 empty neighbors)
  // (1,0) has: up=empty, down=empty, left=empty(edge), right=solid -> 3 empty neighbors
  inspect(result.cells[3], content="false") // (1,0) also removed
}

///|
test "frost does not remove cells with fewer than 3 empty neighbors" {
  // 3x3 fully solid, frost should remove corners (3 empty edges each)
  let grid = @types.new_grid(3, true)
  let result = apply_frost(grid)
  // Corner (0,0): up=edge(empty), left=edge(empty), down=solid, right=solid -> 2 empty
  // Wait - count_empty_neighbors counts edges as empty
  // (0,0): up -> row=0, so counted as empty. left -> col=0, so counted as empty.
  //        down -> (1,0) solid. right -> (0,1) solid. Total: 2 empty neighbors
  inspect(result.cells[0], content="true") // corner NOT removed (only 2)
  inspect(result.cells[4], content="true") // center has 0 empty neighbors
}

///|
test "heat removes cells with 2+ empty orthogonal neighbors" {
  // 3x3 fully solid grid
  let grid = @types.new_grid(3, true)
  let result = apply_heat(grid)
  // Corner (0,0): 2 empty neighbors (top edge, left edge) -> removed
  inspect(result.cells[0], content="false")
  // Edge (0,1): 1 empty neighbor (top edge) -> NOT removed
  inspect(result.cells[1], content="true")
  // Center (1,1): 0 empty neighbors -> NOT removed
  inspect(result.cells[4], content="true")
}

///|
test "heat removes thin walls" {
  // 3x3 grid with a single thin line
  let grid = @types.new_grid(3, false)
  @types.grid_set(grid, 1, 0, true)
  @types.grid_set(grid, 1, 1, true)
  @types.grid_set(grid, 1, 2, true)
  // (1,0): up=empty, down=empty, left=edge(empty), right=solid -> 3 empty -> removed
  // (1,1): up=empty, down=empty, left=solid, right=solid -> 2 empty -> removed
  // (1,2): up=empty, down=empty, left=solid, right=edge(empty) -> 3 empty -> removed
  let result = apply_heat(grid)
  inspect(result.cells[3], content="false") // (1,0) removed
  inspect(result.cells[4], content="false") // (1,1) removed
  inspect(result.cells[5], content="false") // (1,2) removed
}
