///|
fn make_test_grid(
  kinds : Array[Array[@types.TileKind]]
) -> Array[Array[@types.Tile]] {
  let grid : Array[Array[@types.Tile]] = []
  for r in 0..<kinds.length() {
    let row : Array[@types.Tile] = []
    for c in 0..<kinds[r].length() {
      row.push(@types.new_tile(kinds[r][c], 0))
    }
    grid.push(row)
  }
  grid
}

///|
fn make_flat_elevations() -> Array[Array[Int]] {
  let elevs : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    let row : Array[Int] = []
    for _c in 0..<@types.grid_cols {
      row.push(0)
    }
    elevs.push(row)
  }
  elevs
}

///|
fn empty_row() -> Array[@types.TileKind] {
  [Empty, Empty, Empty, Empty, Empty, Empty, Empty, Empty, Empty, Empty]
}

///|
test "line_of_sight clear path" {
  let kinds : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    kinds.push(empty_row())
  }
  let grid = make_test_grid(kinds)
  assert_true!(line_of_sight(grid, 0, 0, 5, 0))
  assert_true!(line_of_sight(grid, 3, 0, 3, 5))
}

///|
test "line_of_sight blocked by mountain" {
  let kinds : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    kinds.push(empty_row())
  }
  kinds[0][2] = Mountain
  let grid = make_test_grid(kinds)
  assert_false!(line_of_sight(grid, 0, 0, 5, 0))
}

///|
test "can_reach cardinal only" {
  let kinds : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    kinds.push(empty_row())
  }
  let grid = make_test_grid(kinds)
  // Diagonal should fail
  assert_false!(can_reach(grid, 0, 0, 2, 2, 5))
  // Cardinal should succeed
  assert_true!(can_reach(grid, 0, 0, 3, 0, 5))
}

///|
test "can_reach respects range" {
  let kinds : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    kinds.push(empty_row())
  }
  let grid = make_test_grid(kinds)
  assert_true!(can_reach(grid, 0, 0, 3, 0, 3))
  assert_false!(can_reach(grid, 0, 0, 4, 0, 3))
}

///|
test "propagate simple transmitter to receiver" {
  let kinds : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    kinds.push(empty_row())
  }
  kinds[0][0] = Transmitter
  kinds[0][2] = Receiver
  let elevs = make_flat_elevations()
  let data : @types.LevelData = {
    id: 0,
    name: "test",
    tier: 1,
    par_towers: 0,
    par_chain: 0,
    budget: 5,
    grid: kinds,
    elevations: elevs,
  }
  let state = @types.new_level_state(data)
  let (all_lit, chain, paths) = propagate(state, data)
  assert_true!(all_lit)
  assert_eq!(chain, 0)
  assert_true!(paths.length() > 0)
}

///|
test "propagate transmitter blocked by mountain" {
  let kinds : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    kinds.push(empty_row())
  }
  kinds[0][0] = Transmitter
  kinds[0][1] = Mountain
  kinds[0][3] = Receiver
  let elevs = make_flat_elevations()
  let data : @types.LevelData = {
    id: 0,
    name: "test",
    tier: 1,
    par_towers: 1,
    par_chain: 1,
    budget: 5,
    grid: kinds,
    elevations: elevs,
  }
  let state = @types.new_level_state(data)
  let (all_lit, _chain, _paths) = propagate(state, data)
  assert_false!(all_lit)
}

///|
test "propagate relay through tower" {
  let kinds : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    kinds.push(empty_row())
  }
  kinds[0][0] = Transmitter
  kinds[0][2] = Tower
  kinds[0][5] = Receiver
  let elevs = make_flat_elevations()
  let data : @types.LevelData = {
    id: 0,
    name: "test",
    tier: 1,
    par_towers: 1,
    par_chain: 1,
    budget: 5,
    grid: kinds,
    elevations: elevs,
  }
  let state = @types.new_level_state(data)
  let (all_lit, chain, _paths) = propagate(state, data)
  assert_true!(all_lit)
  assert_eq!(chain, 1)
}

///|
test "compute_stars three stars" {
  assert_eq!(compute_stars(2, 1, 2, 2), Three)
}

///|
test "compute_stars two stars" {
  assert_eq!(compute_stars(2, 3, 2, 2), Two)
}

///|
test "compute_stars one star" {
  assert_eq!(compute_stars(4, 1, 2, 2), One)
}

///|
test "propagate elevation extends range" {
  let kinds : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    kinds.push(empty_row())
  }
  kinds[0][0] = Transmitter
  kinds[0][6] = Receiver
  let elevs = make_flat_elevations()
  // Give transmitter elevation 3, range = 3+3 = 6
  elevs[0][0] = 3
  let data : @types.LevelData = {
    id: 0,
    name: "test",
    tier: 1,
    par_towers: 0,
    par_chain: 0,
    budget: 5,
    grid: kinds,
    elevations: elevs,
  }
  let state = @types.new_level_state(data)
  let (all_lit, _chain, _paths) = propagate(state, data)
  assert_true!(all_lit)
}
