///|
test "get_neighbors corner" {
  let n = @heat.get_neighbors(0, 0, 8)
  assert_eq(n.length(), 2)
}

///|
test "get_neighbors center" {
  let n = @heat.get_neighbors(3, 3, 8)
  assert_eq(n.length(), 4)
}

///|
test "get_neighbors edge" {
  let n = @heat.get_neighbors(0, 3, 8)
  assert_eq(n.length(), 3)
}

///|
test "heat spreads from source to metal" {
  let grid = @types.new_grid()
  // Place heat source at (0,0)
  grid.tiles[0][0].kind = HeatSource(200.0)
  grid.tiles[0][0].material = Metal
  grid.tiles[0][0].temperature = 200.0
  // Place metal at (0,1) and (1,0)
  grid.tiles[0][1].material = Metal
  grid.tiles[1][0].material = Metal
  // Run one step
  @heat.simulate_step(grid)
  // Metal neighbors should have warmed up
  assert_true(grid.tiles[0][1].temperature > @types.ambient_temp)
  assert_true(grid.tiles[1][0].temperature > @types.ambient_temp)
  // Source should maintain temperature
  assert_eq(grid.tiles[0][0].temperature, 200.0)
}

///|
test "insulator blocks heat" {
  let grid = @types.new_grid()
  // Heat source at (0,0)
  grid.tiles[0][0].kind = HeatSource(200.0)
  grid.tiles[0][0].material = Metal
  grid.tiles[0][0].temperature = 200.0
  // Insulator at (0,1)
  grid.tiles[0][1].material = Insulator
  // Metal at (0,2)
  grid.tiles[0][2].material = Metal
  // Run multiple steps
  for _i in 0..<10 {
    @heat.simulate_step(grid)
  }
  // Insulator should stay at ambient
  assert_eq(grid.tiles[0][1].temperature, @types.ambient_temp)
  // Metal behind insulator should also stay cool
  assert_eq(grid.tiles[0][2].temperature, @types.ambient_temp)
}

///|
test "metal conducts faster than stone" {
  let grid1 = @types.new_grid()
  let grid2 = @types.new_grid()
  // Same source setup for both
  grid1.tiles[0][0].kind = HeatSource(200.0)
  grid1.tiles[0][0].material = Metal
  grid1.tiles[0][0].temperature = 200.0
  grid2.tiles[0][0].kind = HeatSource(200.0)
  grid2.tiles[0][0].material = Metal
  grid2.tiles[0][0].temperature = 200.0
  // Metal path
  grid1.tiles[0][1].material = Metal
  // Stone path
  grid2.tiles[0][1].material = Stone
  // Run 5 steps
  for _i in 0..<5 {
    @heat.simulate_step(grid1)
    @heat.simulate_step(grid2)
  }
  // Metal should be warmer
  assert_true(grid1.tiles[0][1].temperature > grid2.tiles[0][1].temperature)
}

///|
test "empty tiles dont conduct" {
  let grid = @types.new_grid()
  grid.tiles[0][0].kind = HeatSource(200.0)
  grid.tiles[0][0].material = Metal
  grid.tiles[0][0].temperature = 200.0
  // Leave (0,1) as Empty
  // Run steps
  for _i in 0..<10 {
    @heat.simulate_step(grid)
  }
  // Empty tile should stay at ambient
  assert_eq(grid.tiles[0][1].temperature, @types.ambient_temp)
}

///|
test "is_stable returns true when no heat flow" {
  let grid = @types.new_grid()
  // All at ambient, no sources
  assert_true(@heat.is_stable(grid, 0.5))
}

///|
test "is_stable returns false with active heat flow" {
  let grid = @types.new_grid()
  grid.tiles[0][0].kind = HeatSource(200.0)
  grid.tiles[0][0].material = Metal
  grid.tiles[0][0].temperature = 200.0
  grid.tiles[0][1].material = Metal
  assert_true(@heat.is_stable(grid, 0.5) == false)
}

///|
test "run_simulation runs and produces result" {
  let grid = @types.new_grid()
  grid.tiles[3][3].kind = HeatSource(100.0)
  grid.tiles[3][3].material = Metal
  grid.tiles[3][3].temperature = 100.0
  grid.tiles[3][4].material = Metal
  grid.tiles[4][3].material = Metal
  // Run just one step and check
  @heat.simulate_step(grid)
  let t1 = grid.tiles[3][4].temperature
  // After one step, metal tile next to 100C source should be warmer than ambient
  assert_true(t1 > @types.ambient_temp)
  // Run more steps
  for _i in 0..<50 {
    @heat.simulate_step(grid)
  }
  let t2 = grid.tiles[3][4].temperature
  // After 51 steps, should be substantially warmer
  assert_true(t2 > t1)
}

///|
test "wood conducts slowly" {
  let grid = @types.new_grid()
  grid.tiles[0][0].kind = HeatSource(200.0)
  grid.tiles[0][0].material = Metal
  grid.tiles[0][0].temperature = 200.0
  grid.tiles[0][1].material = Wood
  @heat.simulate_step(grid)
  let wood_temp = grid.tiles[0][1].temperature
  // Wood should have gained some heat but not much
  assert_true(wood_temp > @types.ambient_temp)
  assert_true(wood_temp < 60.0)
}
