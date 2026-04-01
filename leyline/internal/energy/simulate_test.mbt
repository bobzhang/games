///|
test "reset_energy clears all values" {
  let grid : Array[Array[@types.Cell]] = [
    [@types.new_cell(Source), @types.new_cell(Empty)],
  ]
  grid[0][0].energy_received = 50.0
  let state : @types.LevelState = {
    grid,
    connections: [],
    waystones_placed: 0,
    waystone_budget: 5,
    all_temples_powered: false,
    total_energy_delivered: 0.0,
    cursor_col: -1,
    cursor_row: -1,
    hover_valid: false,
    draw_start_col: -1,
    draw_start_row: -1,
    is_drawing_line: false,
  }
  @energy.simulate(state)
  // Source should have energy from self-propagation
  inspect(state.grid[0][0].energy_received > 0.0, content="true")
}

///|
test "simple source-to-temple propagation" {
  // Build a minimal 10x8 grid
  let grid : Array[Array[@types.Cell]] = []
  for _row in 0..<8 {
    let row_arr : Array[@types.Cell] = []
    for _col in 0..<10 {
      row_arr.push(@types.new_cell(Empty))
    }
    grid.push(row_arr)
  }
  // Place source at (0,0), waystone at (1,0), temple at (2,0)
  grid[0][0].kind = Source
  grid[0][1].kind = Waystone
  grid[0][2].kind = Temple(50.0)
  let connections : Array[@types.Connection] = [
    @types.new_connection(0, 0, 1, 0), @types.new_connection(1, 0, 2, 0),
  ]
  let state : @types.LevelState = {
    grid,
    connections,
    waystones_placed: 1,
    waystone_budget: 5,
    all_temples_powered: false,
    total_energy_delivered: 0.0,
    cursor_col: -1,
    cursor_row: -1,
    hover_valid: false,
    draw_start_col: -1,
    draw_start_row: -1,
    is_drawing_line: false,
  }
  @energy.simulate(state)
  // Source: 100, after 1 hop with 10% decay = 90, after 2nd hop = 81
  inspect(state.grid[0][0].energy_received > 99.0, content="true")
  inspect(state.grid[0][1].energy_received > 89.0, content="true")
  inspect(state.grid[0][2].energy_received > 80.0, content="true")
  inspect(state.all_temples_powered, content="true")
}

///|
test "energy splits at branch" {
  let grid : Array[Array[@types.Cell]] = []
  for _row in 0..<8 {
    let row_arr : Array[@types.Cell] = []
    for _col in 0..<10 {
      row_arr.push(@types.new_cell(Empty))
    }
    grid.push(row_arr)
  }
  // Source at (1,1), waystone at (2,1), branches to (3,1) and (2,2)
  grid[1][1].kind = Source
  grid[1][2].kind = Waystone
  grid[1][3].kind = Temple(30.0)
  grid[2][2].kind = Temple(30.0)
  let connections : Array[@types.Connection] = [
    @types.new_connection(1, 1, 2, 1),
    @types.new_connection(2, 1, 3, 1),
    @types.new_connection(2, 1, 2, 2),
  ]
  let state : @types.LevelState = {
    grid,
    connections,
    waystones_placed: 1,
    waystone_budget: 5,
    all_temples_powered: false,
    total_energy_delivered: 0.0,
    cursor_col: -1,
    cursor_row: -1,
    hover_valid: false,
    draw_start_col: -1,
    draw_start_row: -1,
    is_drawing_line: false,
  }
  @energy.simulate(state)
  // Waystone gets 90, splits to 2 branches: 45 each, decayed to 40.5
  inspect(state.grid[1][3].energy_received > 40.0, content="true")
  inspect(state.grid[2][2].energy_received > 40.0, content="true")
}

///|
test "amplifier doubles energy" {
  let grid : Array[Array[@types.Cell]] = []
  for _row in 0..<8 {
    let row_arr : Array[@types.Cell] = []
    for _col in 0..<10 {
      row_arr.push(@types.new_cell(Empty))
    }
    grid.push(row_arr)
  }
  grid[0][0].kind = Source
  grid[0][1].kind = Amplifier
  grid[0][2].kind = Temple(50.0)
  let connections : Array[@types.Connection] = [
    @types.new_connection(0, 0, 1, 0), @types.new_connection(1, 0, 2, 0),
  ]
  let state : @types.LevelState = {
    grid,
    connections,
    waystones_placed: 0,
    waystone_budget: 5,
    all_temples_powered: false,
    total_energy_delivered: 0.0,
    cursor_col: -1,
    cursor_row: -1,
    hover_valid: false,
    draw_start_col: -1,
    draw_start_row: -1,
    is_drawing_line: false,
  }
  @energy.simulate(state)
  // Source 100 -> amp: 90 * 2 = 180 -> temple: 180 * 0.9 = 162
  inspect(state.grid[0][1].energy_received > 170.0, content="true")
  inspect(state.grid[0][2].energy_received > 140.0, content="true")
  inspect(state.all_temples_powered, content="true")
}

///|
test "disconnected temple not powered" {
  let grid : Array[Array[@types.Cell]] = []
  for _row in 0..<8 {
    let row_arr : Array[@types.Cell] = []
    for _col in 0..<10 {
      row_arr.push(@types.new_cell(Empty))
    }
    grid.push(row_arr)
  }
  grid[0][0].kind = Source
  grid[0][5].kind = Temple(50.0)
  let state : @types.LevelState = {
    grid,
    connections: [],
    waystones_placed: 0,
    waystone_budget: 5,
    all_temples_powered: false,
    total_energy_delivered: 0.0,
    cursor_col: -1,
    cursor_row: -1,
    hover_valid: false,
    draw_start_col: -1,
    draw_start_row: -1,
    is_drawing_line: false,
  }
  @energy.simulate(state)
  inspect(state.grid[0][5].energy_received < 0.01, content="true")
  inspect(state.all_temples_powered, content="false")
}
