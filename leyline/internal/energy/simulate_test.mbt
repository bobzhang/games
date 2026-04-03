///|
fn make_test_grid() -> Array[Array[@types.Cell]] {
  let grid : Array[Array[@types.Cell]] = []
  for _row in 0..<8 {
    let row_arr : Array[@types.Cell] = []
    for _col in 0..<10 {
      row_arr.push(@types.new_cell(Empty))
    }
    grid.push(row_arr)
  }
  grid
}

///|
fn make_test_state(
  grid : Array[Array[@types.Cell]],
  connections : Array[@types.Connection],
) -> @types.LevelState {
  {
    grid,
    connections,
    waystones_placed: 0,
    waystone_budget: 10,
    all_temples_powered: false,
    total_energy_delivered: 0.0,
    cursor_col: -1,
    cursor_row: -1,
    hover_valid: false,
    draw_start_col: -1,
    draw_start_row: -1,
    is_drawing_line: false,
  }
}

///|
test "reset_energy clears all values" {
  let grid = make_test_grid()
  grid[0][0].kind = Source
  grid[0][0].energy_received = 50.0
  let state = make_test_state(grid, [])
  @energy.simulate(state)
  inspect(state.grid[0][0].energy_received > 0.0, content="true")
}

///|
test "simple source-to-temple propagation" {
  let grid = make_test_grid()
  grid[0][0].kind = Source
  grid[0][1].kind = Waystone
  grid[0][2].kind = Temple(50.0)
  let connections : Array[@types.Connection] = [
    @types.new_connection(0, 0, 1, 0),
    @types.new_connection(1, 0, 2, 0),
  ]
  let state = make_test_state(grid, connections)
  @energy.simulate(state)
  // Source: 100, hop1 decay: 90, hop2 decay: 81
  inspect(state.grid[0][0].energy_received > 99.0, content="true")
  inspect(state.grid[0][1].energy_received > 89.0, content="true")
  inspect(state.grid[0][2].energy_received > 80.0, content="true")
  inspect(state.all_temples_powered, content="true")
}

///|
test "energy splits at branch" {
  let grid = make_test_grid()
  grid[1][1].kind = Source
  grid[1][2].kind = Waystone
  grid[1][3].kind = Temple(30.0)
  grid[2][2].kind = Temple(30.0)
  let connections : Array[@types.Connection] = [
    @types.new_connection(1, 1, 2, 1),
    @types.new_connection(2, 1, 3, 1),
    @types.new_connection(2, 1, 2, 2),
  ]
  let state = make_test_state(grid, connections)
  @energy.simulate(state)
  // Waystone gets 90, splits 2 ways: 45 each, decayed = 40.5
  inspect(state.grid[1][3].energy_received > 40.0, content="true")
  inspect(state.grid[2][2].energy_received > 40.0, content="true")
}

///|
test "amplifier doubles energy" {
  let grid = make_test_grid()
  grid[0][0].kind = Source
  grid[0][1].kind = Amplifier
  grid[0][2].kind = Temple(50.0)
  let connections : Array[@types.Connection] = [
    @types.new_connection(0, 0, 1, 0),
    @types.new_connection(1, 0, 2, 0),
  ]
  let state = make_test_state(grid, connections)
  @energy.simulate(state)
  // Source 100 -> amp: 90 * 2 = 180 -> temple: 180 * 0.9 = 162
  inspect(state.grid[0][1].energy_received > 170.0, content="true")
  inspect(state.grid[0][2].energy_received > 140.0, content="true")
  inspect(state.all_temples_powered, content="true")
}

///|
test "disconnected temple not powered" {
  let grid = make_test_grid()
  grid[0][0].kind = Source
  grid[0][5].kind = Temple(50.0)
  let state = make_test_state(grid, [])
  @energy.simulate(state)
  inspect(state.grid[0][5].energy_received < 0.01, content="true")
  inspect(state.all_temples_powered, content="false")
}

///|
test "energy decays over long path" {
  let grid = make_test_grid()
  grid[0][0].kind = Source
  // Chain of waystones from (1,0) to (7,0)
  for col in 1..<8 {
    grid[0][col].kind = Waystone
  }
  grid[0][8].kind = Temple(30.0)
  let connections : Array[@types.Connection] = []
  for col in 0..<8 {
    connections.push(@types.new_connection(col, 0, col + 1, 0))
  }
  let state = make_test_state(grid, connections)
  @energy.simulate(state)
  // 100 * 0.9^8 = ~43.0
  inspect(state.grid[0][8].energy_received > 42.0, content="true")
  inspect(state.grid[0][8].energy_received < 44.0, content="true")
  inspect(state.all_temples_powered, content="true")
}

///|
test "multiple sources contribute energy" {
  let grid = make_test_grid()
  grid[0][0].kind = Source
  grid[0][4].kind = Source
  grid[0][2].kind = Temple(150.0)
  grid[0][1].kind = Waystone
  grid[0][3].kind = Waystone
  let connections : Array[@types.Connection] = [
    @types.new_connection(0, 0, 1, 0),
    @types.new_connection(1, 0, 2, 0),
    @types.new_connection(4, 0, 3, 0),
    @types.new_connection(3, 0, 2, 0),
  ]
  let state = make_test_state(grid, connections)
  @energy.simulate(state)
  // Both sources contribute ~81 each = ~162
  inspect(state.grid[0][2].energy_received > 150.0, content="true")
  inspect(state.all_temples_powered, content="true")
}

///|
test "void blocks connections" {
  let grid = make_test_grid()
  grid[0][0].kind = Source
  grid[0][1].kind = Void
  grid[0][2].kind = Temple(50.0)
  // Cannot connect through void (is_connectable returns false for void)
  // So no connections should work
  let state = make_test_state(grid, [])
  @energy.simulate(state)
  inspect(state.grid[0][2].energy_received < 0.01, content="true")
  inspect(state.all_temples_powered, content="false")
}
