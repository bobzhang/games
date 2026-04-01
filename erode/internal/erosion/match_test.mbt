///|
test "perfect match counts correctly" {
  let grid = @types.new_grid(3, true)
  let target = @types.new_grid(3, true)
  let result = compare_grids(grid, target)
  inspect(result.matching, content="9")
  inspect(result.over_eroded, content="0")
  inspect(result.under_eroded, content="0")
}

///|
test "over-eroded cells detected" {
  let grid = @types.new_grid(3, false) // all empty
  let target = @types.new_grid(3, true) // all solid
  let result = compare_grids(grid, target)
  inspect(result.over_eroded, content="9") // all cells over-eroded
  inspect(result.under_eroded, content="0")
  inspect(result.matching, content="0")
}

///|
test "under-eroded cells detected" {
  let grid = @types.new_grid(3, true) // all solid
  let target = @types.new_grid(3, false) // all empty
  let result = compare_grids(grid, target)
  inspect(result.under_eroded, content="9")
  inspect(result.over_eroded, content="0")
  inspect(result.matching, content="0")
}

///|
test "match percentage 100 on perfect match" {
  let grid = @types.new_grid(3, true)
  let target = @types.new_grid(3, true)
  let pct = match_percentage(grid, target)
  inspect(pct, content="100")
}

///|
test "match percentage 0 on total mismatch" {
  let grid = @types.new_grid(3, true)
  let target = @types.new_grid(3, false)
  let pct = match_percentage(grid, target)
  inspect(pct, content="0")
}

///|
test "mixed match counts" {
  let grid = @types.new_grid(3, true)
  let target = @types.new_grid(3, true)
  // Remove one cell from grid that target wants solid -> over-eroded
  @types.grid_set(grid, 0, 0, false)
  // Remove one cell from target that grid has solid -> under-eroded
  @types.grid_set(target, 2, 2, false)
  let result = compare_grids(grid, target)
  inspect(result.over_eroded, content="1") // (0,0): target solid, grid empty
  inspect(result.under_eroded, content="1") // (2,2): target empty, grid solid
  inspect(result.matching, content="7") // 9 - 2 = 7
}

///|
test "is_perfect_match true when grids identical" {
  let a = @types.new_grid(4, true)
  let b = @types.new_grid(4, true)
  @types.grid_set(a, 0, 0, false)
  @types.grid_set(b, 0, 0, false)
  inspect(is_perfect_match(a, b), content="true")
}

///|
test "is_perfect_match false when grids differ" {
  let a = @types.new_grid(4, true)
  let b = @types.new_grid(4, true)
  @types.grid_set(a, 0, 0, false)
  inspect(is_perfect_match(a, b), content="false")
}

///|
test "full grid match after erosion" {
  // Start with full 4x4 grid, apply water, check against target with top row removed
  let grid = @types.new_grid(4, true)
  let target = @types.new_grid(4, true)
  // Remove top row from target
  for c in 0..<4 {
    @types.grid_set(target, 0, c, false)
  }
  // Apply water
  let result = apply_water(grid)
  inspect(is_perfect_match(result, target), content="true")
}

///|
test "stars calculation" {
  let grid = @types.new_grid(3, true)
  let target = @types.new_grid(3, true)
  // Perfect match, within par -> 3 stars
  inspect(calculate_stars(grid, target, 2, 3), content="3")
  // Perfect match, over par -> 1 star
  inspect(calculate_stars(grid, target, 5, 3), content="1")
  // Not matching -> 0 stars
  @types.grid_set(grid, 0, 0, false)
  inspect(calculate_stars(grid, target, 2, 3), content="0")
}
