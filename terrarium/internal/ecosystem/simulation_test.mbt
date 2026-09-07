///|
test "check_organism_alive_healthy" {
  let org : @types.OrganismState = {
    kind: Moss,
    row: 0,
    col: 0,
    alive: true,
    health: 100.0,
  }
  let res = @types.new_resources(50.0, 50.0, 50.0, 50.0)
  assert_true(check_organism_alive(org, res))
}

///|
test "check_organism_alive_no_water" {
  let org : @types.OrganismState = {
    kind: Moss,
    row: 0,
    col: 0,
    alive: true,
    health: 100.0,
  }
  let res = @types.new_resources(50.0, 50.0, 0.0, 50.0)
  assert_false(check_organism_alive(org, res))
}

///|
test "check_organism_alive_beetle_no_o2" {
  let org : @types.OrganismState = {
    kind: Beetle,
    row: 0,
    col: 0,
    alive: true,
    health: 100.0,
  }
  let res = @types.new_resources(0.0, 50.0, 50.0, 50.0)
  assert_false(check_organism_alive(org, res))
}

///|
test "count_adjacent_plants_none" {
  let grid : Array[Array[@types.CellContent]] = []
  for _r in 0..<@types.grid_size {
    let row : Array[@types.CellContent] = []
    for _c in 0..<@types.grid_size {
      row.push(Empty)
    }
    grid.push(row)
  }
  assert_eq(count_adjacent_plants(grid, 3, 3), 0)
}

///|
test "count_adjacent_plants_surrounded" {
  let grid : Array[Array[@types.CellContent]] = []
  for _r in 0..<@types.grid_size {
    let row : Array[@types.CellContent] = []
    for _c in 0..<@types.grid_size {
      row.push(Empty)
    }
    grid.push(row)
  }
  grid[2][3] = Organism(Moss)
  grid[4][3] = Organism(Fern)
  grid[3][2] = Organism(Moss)
  grid[3][4] = Organism(Fern)
  assert_eq(count_adjacent_plants(grid, 3, 3), 4)
}

///|
test "count_adjacent_plants_corner" {
  let grid : Array[Array[@types.CellContent]] = []
  for _r in 0..<@types.grid_size {
    let row : Array[@types.CellContent] = []
    for _c in 0..<@types.grid_size {
      row.push(Empty)
    }
    grid.push(row)
  }
  grid[0][1] = Organism(Moss)
  grid[1][0] = Organism(Fern)
  assert_eq(count_adjacent_plants(grid, 0, 0), 2)
}

///|
test "herbivore_has_food_no_plants" {
  let grid : Array[Array[@types.CellContent]] = []
  for _r in 0..<@types.grid_size {
    let row : Array[@types.CellContent] = []
    for _c in 0..<@types.grid_size {
      row.push(Empty)
    }
    grid.push(row)
  }
  assert_false(herbivore_has_food(grid, 3, 3))
}

///|
test "herbivore_has_food_with_plant" {
  let grid : Array[Array[@types.CellContent]] = []
  for _r in 0..<@types.grid_size {
    let row : Array[@types.CellContent] = []
    for _c in 0..<@types.grid_size {
      row.push(Empty)
    }
    grid.push(row)
  }
  grid[2][3] = Organism(Moss)
  assert_true(herbivore_has_food(grid, 3, 3))
}

///|
test "count_alive_all_alive" {
  let orgs : Array[@types.OrganismState] = [
    { kind: Moss, row: 0, col: 0, alive: true, health: 100.0, },
    { kind: Beetle, row: 1, col: 1, alive: true, health: 100.0, },
  ]
  assert_eq(count_alive(orgs), 2)
}

///|
test "count_alive_some_dead" {
  let orgs : Array[@types.OrganismState] = [
    { kind: Moss, row: 0, col: 0, alive: true, health: 100.0, },
    { kind: Beetle, row: 1, col: 1, alive: false, health: 0.0, },
    { kind: Fern, row: 2, col: 2, alive: true, health: 50.0, },
  ]
  assert_eq(count_alive(orgs), 2)
}

///|
test "count_alive_all_dead" {
  let orgs : Array[@types.OrganismState] = [
    { kind: Moss, row: 0, col: 0, alive: false, health: 0.0, },
  ]
  assert_eq(count_alive(orgs), 0)
}

///|
test "apply_organism_effects_moss_produces_o2" {
  let grid : Array[Array[@types.CellContent]] = []
  for _r in 0..<@types.grid_size {
    let row : Array[@types.CellContent] = []
    for _c in 0..<@types.grid_size {
      row.push(Empty)
    }
    grid.push(row)
  }
  grid[0][0] = Organism(Moss)
  let orgs : Array[@types.OrganismState] = [
    { kind: Moss, row: 0, col: 0, alive: true, health: 100.0, },
  ]
  let res = @types.new_resources(50.0, 50.0, 50.0, 50.0)
  let events = apply_organism_effects(orgs, res, grid)
  inspect(events.length(), content="0")
  // O2 should increase by moss o2_delta (8.0)
  inspect(res.o2.to_double(), content="58")
}

///|
test "apply_organism_effects_beetle_no_food_loses_health" {
  let grid : Array[Array[@types.CellContent]] = []
  for _r in 0..<@types.grid_size {
    let row : Array[@types.CellContent] = []
    for _c in 0..<@types.grid_size {
      row.push(Empty)
    }
    grid.push(row)
  }
  grid[2][2] = Organism(Beetle)
  let orgs : Array[@types.OrganismState] = [
    { kind: Beetle, row: 2, col: 2, alive: true, health: 100.0, },
  ]
  let res = @types.new_resources(50.0, 50.0, 50.0, 50.0)
  let events = apply_organism_effects(orgs, res, grid)
  assert_true(events.length() > 0)
  inspect(orgs[0].health.to_double(), content="85")
}

///|
test "apply_organism_effects_beetle_starves" {
  let grid : Array[Array[@types.CellContent]] = []
  for _r in 0..<@types.grid_size {
    let row : Array[@types.CellContent] = []
    for _c in 0..<@types.grid_size {
      row.push(Empty)
    }
    grid.push(row)
  }
  grid[2][2] = Organism(Beetle)
  let orgs : Array[@types.OrganismState] = [
    { kind: Beetle, row: 2, col: 2, alive: true, health: 10.0, },
  ]
  let res = @types.new_resources(50.0, 50.0, 50.0, 50.0)
  let _events = apply_organism_effects(orgs, res, grid)
  assert_false(orgs[0].alive)
  assert_eq(grid[2][2], Empty)
}

///|
test "check_resource_deaths_no_deaths" {
  let grid : Array[Array[@types.CellContent]] = []
  for _r in 0..<@types.grid_size {
    let row : Array[@types.CellContent] = []
    for _c in 0..<@types.grid_size {
      row.push(Empty)
    }
    grid.push(row)
  }
  grid[0][0] = Organism(Moss)
  let orgs : Array[@types.OrganismState] = [
    { kind: Moss, row: 0, col: 0, alive: true, health: 100.0, },
  ]
  let res = @types.new_resources(50.0, 50.0, 50.0, 50.0)
  let events = check_resource_deaths(orgs, res, grid)
  assert_eq(events.length(), 0)
  assert_true(orgs[0].alive)
}

///|
test "check_resource_deaths_low_water_kills_moss" {
  let grid : Array[Array[@types.CellContent]] = []
  for _r in 0..<@types.grid_size {
    let row : Array[@types.CellContent] = []
    for _c in 0..<@types.grid_size {
      row.push(Empty)
    }
    grid.push(row)
  }
  grid[0][0] = Organism(Moss)
  let orgs : Array[@types.OrganismState] = [
    { kind: Moss, row: 0, col: 0, alive: true, health: 100.0, },
  ]
  let res = @types.new_resources(50.0, 50.0, 0.0, 50.0)
  let events = check_resource_deaths(orgs, res, grid)
  assert_true(events.length() > 0)
  assert_false(orgs[0].alive)
  assert_eq(grid[0][0], Empty)
}

///|
test "simulate_turn_increments_turn" {
  let game = @types.new_game()
  game.grid[0][0] = Organism(Moss)
  game.organisms.push({
    kind: Moss,
    row: 0,
    col: 0,
    alive: true,
    health: 100.0,
  })
  game.resources = @types.new_resources(50.0, 50.0, 50.0, 50.0)
  let log = simulate_turn(game)
  assert_eq(log.turn, 1)
  assert_eq(game.current_turn, 1)
}

///|
test "simulate_turn_moss_changes_resources" {
  let game = @types.new_game()
  game.grid[0][0] = Organism(Moss)
  game.organisms.push({
    kind: Moss,
    row: 0,
    col: 0,
    alive: true,
    health: 100.0,
  })
  game.resources = @types.new_resources(50.0, 50.0, 50.0, 50.0)
  let _log = simulate_turn(game)
  // Moss: o2+8, co2-4, water-3, nutrients-1
  inspect(game.resources.o2.to_double(), content="58")
  inspect(game.resources.co2.to_double(), content="46")
  inspect(game.resources.water.to_double(), content="47")
  inspect(game.resources.nutrients.to_double(), content="49")
}

///|
test "evaluate_result_victory" {
  let game = @types.new_game()
  game.current_turn = 10
  game.organisms.push({
    kind: Moss,
    row: 0,
    col: 0,
    alive: true,
    health: 100.0,
  })
  let result = evaluate_result(game)
  assert_eq(result, Victory)
}

///|
test "evaluate_result_all_dead" {
  let game = @types.new_game()
  game.current_turn = 5
  game.organisms.push({ kind: Moss, row: 0, col: 0, alive: false, health: 0.0, })
  let result = evaluate_result(game)
  assert_eq(result, Failure("All organisms died!"))
}

///|
test "evaluate_result_collapse" {
  let game = @types.new_game()
  game.current_turn = 7
  game.organisms.push({
    kind: Moss,
    row: 0,
    col: 0,
    alive: true,
    health: 100.0,
  })
  let result = evaluate_result(game)
  assert_eq(result, Failure("Ecosystem collapsed at turn 7"))
}

///|
test "run_full_simulation_10_turns" {
  let game = @types.new_game()
  game.grid[0][0] = Organism(Moss)
  game.grid[1][1] = Organism(Worm)
  game.organisms = [
    { kind: Moss, row: 0, col: 0, alive: true, health: 100.0, },
    { kind: Worm, row: 1, col: 1, alive: true, health: 100.0, },
  ]
  game.resources = @types.new_resources(50.0, 50.0, 50.0, 50.0)
  run_full_simulation(game)
  assert_true(game.sim_log.length() > 0)
  assert_true(game.sim_log.length() <= @types.max_turns)
}

///|
test "dead_organism_does_not_produce" {
  let grid : Array[Array[@types.CellContent]] = []
  for _r in 0..<@types.grid_size {
    let row : Array[@types.CellContent] = []
    for _c in 0..<@types.grid_size {
      row.push(Empty)
    }
    grid.push(row)
  }
  let orgs : Array[@types.OrganismState] = [
    { kind: Moss, row: 0, col: 0, alive: false, health: 0.0, },
  ]
  let res = @types.new_resources(50.0, 50.0, 50.0, 50.0)
  let events = apply_organism_effects(orgs, res, grid)
  assert_eq(events.length(), 0)
  inspect(res.o2.to_double(), content="50")
}
