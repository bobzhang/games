///|
test "water flows downhill through aqueduct" {
  let level : @types.Level = {
    name: "test",
    tier: Tier1,
    grid_cols: 3,
    grid_rows: 1,
    elevations: [3, 2, 1],
    springs: [{ x: 0, y: 0, }],
    fountains: [{ x: 2, y: 0, }],
    reservoirs: [],
    dams: [],
    par_segments: 1,
  }
  let game = @types.new_game([level])
  game.current_level = 0
  @types.init_grid(game)
  // Place aqueduct at (1,0)
  let idx = @types.pos_to_index({ x: 1, y: 0, }, 3)
  game.grid[idx].kind = Aqueduct
  game.grid[idx].connections = @types.all_directions.copy()
  run_simulation(game)
  inspect(game.fountains_filled, content="1")
  inspect(game.total_fountains, content="1")
}

///|
test "water does not flow uphill" {
  let level : @types.Level = {
    name: "test_uphill",
    tier: Tier1,
    grid_cols: 3,
    grid_rows: 1,
    elevations: [1, 2, 3],
    springs: [{ x: 0, y: 0, }],
    fountains: [{ x: 2, y: 0, }],
    reservoirs: [],
    dams: [],
    par_segments: 1,
  }
  let game = @types.new_game([level])
  game.current_level = 0
  @types.init_grid(game)
  let idx = @types.pos_to_index({ x: 1, y: 0, }, 3)
  game.grid[idx].kind = Aqueduct
  game.grid[idx].connections = @types.all_directions.copy()
  run_simulation(game)
  inspect(game.fountains_filled, content="0")
}

///|
test "star calculation" {
  let level : @types.Level = {
    name: "test_stars",
    tier: Tier1,
    grid_cols: 3,
    grid_rows: 1,
    elevations: [3, 2, 1],
    springs: [{ x: 0, y: 0, }],
    fountains: [{ x: 2, y: 0, }],
    reservoirs: [],
    dams: [],
    par_segments: 1,
  }
  let game = @types.new_game([level])
  game.current_level = 0
  @types.init_grid(game)
  let idx = @types.pos_to_index({ x: 1, y: 0, }, 3)
  game.grid[idx].kind = Aqueduct
  game.grid[idx].connections = @types.all_directions.copy()
  run_simulation(game)
  let stars = calculate_stars(game)
  inspect(stars, content="3")
}

///|
test "reset_water clears water state" {
  let level : @types.Level = {
    name: "test_reset",
    tier: Tier1,
    grid_cols: 3,
    grid_rows: 1,
    elevations: [3, 2, 1],
    springs: [{ x: 0, y: 0, }],
    fountains: [{ x: 2, y: 0, }],
    reservoirs: [],
    dams: [],
    par_segments: 1,
  }
  let game = @types.new_game([level])
  game.current_level = 0
  @types.init_grid(game)
  let idx = @types.pos_to_index({ x: 1, y: 0, }, 3)
  game.grid[idx].kind = Aqueduct
  game.grid[idx].connections = @types.all_directions.copy()
  run_simulation(game)
  inspect(game.fountains_filled, content="1")
  reset_water(game)
  inspect(game.fountains_filled, content="0")
  // Spring should still have water
  let spring_idx = @types.pos_to_index({ x: 0, y: 0, }, 3)
  inspect(game.grid[spring_idx].has_water, content="true")
  // Fountain should not
  let fountain_idx = @types.pos_to_index({ x: 2, y: 0, }, 3)
  inspect(game.grid[fountain_idx].has_water, content="false")
}

///|
test "dam blocks flow in specified direction" {
  // Layout: Spring(3) -> Dam(2,blocks East) -> Fountain(1)
  // Dam blocks east so water should NOT reach fountain
  let level : @types.Level = {
    name: "test_dam",
    tier: Tier3,
    grid_cols: 3,
    grid_rows: 1,
    elevations: [3, 2, 1],
    springs: [{ x: 0, y: 0, }],
    fountains: [{ x: 2, y: 0, }],
    reservoirs: [],
    dams: [({ x: 1, y: 0, }, East)],
    par_segments: 1,
  }
  let game = @types.new_game([level])
  game.current_level = 0
  @types.init_grid(game)
  run_simulation(game)
  inspect(game.fountains_filled, content="0")
}

///|
test "reservoir fills then releases" {
  // Spring(4) -> Aqueduct(3) -> Reservoir(2) -> Aqueduct(1) -> Fountain(0)
  let level : @types.Level = {
    name: "test_reservoir",
    tier: Tier2,
    grid_cols: 5,
    grid_rows: 1,
    elevations: [4, 3, 2, 1, 0],
    springs: [{ x: 0, y: 0, }],
    fountains: [{ x: 4, y: 0, }],
    reservoirs: [{ x: 2, y: 0, }],
    dams: [],
    par_segments: 2,
  }
  let game = @types.new_game([level])
  game.current_level = 0
  @types.init_grid(game)
  // Place aqueducts
  let idx1 = @types.pos_to_index({ x: 1, y: 0, }, 5)
  game.grid[idx1].kind = Aqueduct
  game.grid[idx1].connections = @types.all_directions.copy()
  let idx3 = @types.pos_to_index({ x: 3, y: 0, }, 5)
  game.grid[idx3].kind = Aqueduct
  game.grid[idx3].connections = @types.all_directions.copy()
  run_simulation(game)
  inspect(game.fountains_filled, content="1")
}
