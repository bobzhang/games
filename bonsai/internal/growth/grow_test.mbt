///|
test "growth direction dx dy" {
  // Up: dx=0, dy=-1
  assert_eq(@types.dir_dx(Up), 0)
  assert_eq(@types.dir_dy(Up), -1)
  // UpLeft: dx=-1, dy=-1
  assert_eq(@types.dir_dx(UpLeft), -1)
  assert_eq(@types.dir_dy(UpLeft), -1)
  // UpRight: dx=1, dy=-1
  assert_eq(@types.dir_dx(UpRight), 1)
  assert_eq(@types.dir_dy(UpRight), -1)
  // Left: dx=-1, dy=0
  assert_eq(@types.dir_dx(Left), -1)
  assert_eq(@types.dir_dy(Left), 0)
  // Right: dx=1, dy=0
  assert_eq(@types.dir_dx(Right), 1)
  assert_eq(@types.dir_dy(Right), 0)
}

///|
test "fork interval per species" {
  assert_eq(@types.fork_interval(Pine), 3)
  assert_eq(@types.fork_interval(Maple), 2)
  assert_eq(@types.fork_interval(Cherry), 2)
}

///|
test "simple growth - pine grows upward" {
  let grid = @types.new_grid(5, 10)
  // Place a trunk at (2, 9)
  @types.grid_set_kind(grid, 2, 9, Trunk, Up)
  grid.cells[@types.grid_index(grid, 2, 9)].age = 1
  // Grow one turn
  let result = grow_one_turn(grid, Pine)
  // Should have a new branch at (2, 8)
  let cell = @types.grid_get(result, 2, 8)
  assert_eq(cell.kind, Branch)
  assert_eq(cell.growth_dir, Up)
}

///|
test "pine fork at interval 3" {
  let grid = @types.new_grid(7, 12)
  // Place a trunk
  @types.grid_set_kind(grid, 3, 11, Trunk, Up)
  grid.cells[@types.grid_index(grid, 3, 11)].age = 0
  // Grow 3 turns to trigger fork (age must reach fork_interval=3)
  let mut current = grid
  for _i in 0..<4 {
    current = grow_one_turn(current, Pine)
  }
  // After 4 turns of growth, there should be cells that forked
  // The trunk grows at age 0,1,2,3 and forks at age 3
  let mut found_branch = false
  for y in 0..<current.height {
    for x in 0..<current.width {
      let c = @types.grid_get(current, x, y)
      if c.kind == Branch && (c.growth_dir == UpLeft || c.growth_dir == UpRight) {
        found_branch = true
      }
    }
  }
  assert_true(found_branch)
}

///|
test "prune removes above" {
  let grid = @types.new_grid(5, 10)
  // Build a small tree: trunk at (2,9), branch at (2,8), branch at (2,7)
  @types.grid_set_kind(grid, 2, 9, Trunk, Up)
  @types.grid_set_kind(grid, 2, 8, Branch, Up)
  @types.grid_set_kind(grid, 2, 7, Branch, Up)
  // Prune at (2,8) should remove (2,8) and (2,7)
  let count = prune_at(grid, 2, 8)
  assert_eq(count, 2)
  // Both should be Pruned now
  assert_eq(@types.grid_get(grid, 2, 8).kind, Pruned)
  assert_eq(@types.grid_get(grid, 2, 7).kind, Pruned)
  // Trunk should remain
  assert_eq(@types.grid_get(grid, 2, 9).kind, Trunk)
}

///|
test "cannot prune trunk" {
  let grid = @types.new_grid(5, 10)
  @types.grid_set_kind(grid, 2, 9, Trunk, Up)
  let count = prune_at(grid, 2, 9)
  assert_eq(count, 0)
  assert_eq(@types.grid_get(grid, 2, 9).kind, Trunk)
}

///|
test "zone satisfaction - required" {
  let grid = @types.new_grid(5, 10)
  @types.grid_set_kind(grid, 2, 5, Branch, Up)
  @types.grid_set_kind(grid, 2, 6, Branch, Up)
  let zones : Array[@types.Zone] = [
    { positions: [{ x: 2, y: 5 }, { x: 2, y: 6 }], kind: Required },
  ]
  let (req_ok, forb_ok, tip_ok) = check_zones(grid, zones)
  assert_true(req_ok)
  assert_true(forb_ok)
  // tip_ok is true vacuously (no tip zones)
  assert_true(tip_ok)
}

///|
test "zone satisfaction - forbidden violated" {
  let grid = @types.new_grid(5, 10)
  @types.grid_set_kind(grid, 2, 5, Branch, Up)
  let zones : Array[@types.Zone] = [
    { positions: [{ x: 2, y: 5 }], kind: Forbidden },
  ]
  let (_, forb_ok, _) = check_zones(grid, zones)
  assert_false(forb_ok)
}

///|
test "ghost preview matches actual growth" {
  let grid = @types.new_grid(7, 12)
  @types.grid_set_kind(grid, 3, 11, Trunk, Up)
  grid.cells[@types.grid_index(grid, 3, 11)].age = 1
  // Preview 1 turn
  let preview = preview_one_turn(grid, Pine)
  // Actually grow 1 turn
  let actual = grow_one_turn(grid, Pine)
  // Compare all cells
  let mut match_ = true
  for i in 0..<preview.cells.length() {
    if preview.cells[i].kind != actual.cells[i].kind {
      match_ = false
    }
  }
  assert_true(match_)
}

///|
test "leaf generation on stagnant tips" {
  let grid = @types.new_grid(5, 10)
  // Place a branch that's at the edge and can't grow
  @types.grid_set_kind(grid, 2, 0, Branch, Up)
  grid.cells[@types.grid_index(grid, 2, 0)].stagnant_turns = 2
  // Generate leaves
  generate_leaves(grid)
  assert_eq(@types.grid_get(grid, 2, 0).kind, Leaf)
}

///|
test "star calculation" {
  let grid = @types.new_grid(5, 10)
  @types.grid_set_kind(grid, 2, 5, Branch, Up)
  // Required zone at (2,5): filled
  // No forbidden zones
  // No tip targets
  let zones : Array[@types.Zone] = [
    { positions: [{ x: 2, y: 5 }], kind: Required },
  ]
  // 0 prunes, par 0 => 3 stars (no tip targets, so tip_ok is vacuously true)
  let stars = calculate_stars(grid, zones, 0, 0)
  // Since there are no TipTarget zones, tip_ok is true => 3 stars
  assert_eq(stars, 3)
}
