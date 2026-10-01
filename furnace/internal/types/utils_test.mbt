///|
test "conductivity values" {
  assert_eq(@types.conductivity(Metal), 0.9)
  assert_eq(@types.conductivity(Stone), 0.5)
  assert_eq(@types.conductivity(Wood), 0.2)
  assert_eq(@types.conductivity(Insulator), 0.0)
  assert_eq(@types.conductivity(Glass), 0.4)
  assert_eq(@types.conductivity(Empty), 0.0)
}

///|
test "material_name" {
  assert_eq(@types.material_name(Metal), "Metal")
  assert_eq(@types.material_name(Stone), "Stone")
  assert_eq(@types.material_name(Wood), "Wood")
  assert_eq(@types.material_name(Insulator), "Insulator")
  assert_eq(@types.material_name(Glass), "Glass")
  assert_eq(@types.material_name(Empty), "Empty")
}

///|
test "new_tile defaults" {
  let tile = @types.new_tile()
  assert_eq(tile.material, Empty)
  assert_eq(tile.kind, Normal)
  assert_eq(tile.temperature, @types.ambient_temp)
  assert_eq(tile.locked, false)
}

///|
test "new_grid dimensions" {
  let grid = @types.new_grid()
  assert_eq(grid.size, @types.grid_size)
  assert_eq(grid.tiles.length(), @types.grid_size)
  assert_eq(grid.tiles[0].length(), @types.grid_size)
}

///|
test "reset_temperatures" {
  let grid = @types.new_grid()
  grid.tiles[0][0].temperature = 100.0
  grid.tiles[3][3].temperature = 50.0
  @types.reset_temperatures(grid)
  assert_eq(grid.tiles[0][0].temperature, @types.ambient_temp)
  assert_eq(grid.tiles[3][3].temperature, @types.ambient_temp)
}

///|
test "count_placed_materials" {
  let grid = @types.new_grid()
  assert_eq(@types.count_placed_materials(grid), 0)
  grid.tiles[0][0].material = Metal
  assert_eq(@types.count_placed_materials(grid), 1)
  grid.tiles[1][1].material = Stone
  assert_eq(@types.count_placed_materials(grid), 2)
  // Locked tiles should not count
  grid.tiles[2][2].material = Wood
  grid.tiles[2][2].locked = true
  assert_eq(@types.count_placed_materials(grid), 2)
}

///|
test "star_count" {
  assert_eq(@types.star_count(Zero), 0)
  assert_eq(@types.star_count(One), 1)
  assert_eq(@types.star_count(Two), 2)
  assert_eq(@types.star_count(Three), 3)
}

///|
test "clampf" {
  assert_eq(@types.clampf(5.0, 0.0, 10.0), 5.0)
  assert_eq(@types.clampf(-1.0, 0.0, 10.0), 0.0)
  assert_eq(@types.clampf(15.0, 0.0, 10.0), 10.0)
}

///|
test "maxf/minf/absf" {
  assert_eq(@types.maxf(3.0, 5.0), 5.0)
  assert_eq(@types.minf(3.0, 5.0), 3.0)
  assert_eq(@types.absf(-3.0), 3.0)
  assert_eq(@types.absf(3.0), 3.0)
}

///|
test "calculate_stars" {
  // Not met
  assert_eq(@types.calculate_stars(false, 3, 5, 5, 10), Zero)
  // Met but over par
  assert_eq(@types.calculate_stars(true, 10, 5, 5, 10), One)
  // Met and at par materials
  assert_eq(@types.calculate_stars(true, 5, 15, 5, 10), Two)
  // Met and at par for both
  assert_eq(@types.calculate_stars(true, 5, 10, 5, 10), Three)
  assert_eq(@types.calculate_stars(true, 3, 8, 5, 10), Three)
}

///|
test "check_all_targets" {
  let grid = @types.new_grid()
  // No targets means all met
  assert_eq(@types.check_all_targets(grid), true)
  // Add target in range
  grid.tiles[0][0].kind = Target(50.0, 70.0)
  grid.tiles[0][0].temperature = 60.0
  assert_eq(@types.check_all_targets(grid), true)
  // Target out of range
  grid.tiles[0][0].temperature = 30.0
  assert_eq(@types.check_all_targets(grid), false)
}

///|
test "is_level_unlocked" {
  let game = @types.new_game()
  // Level 0 always unlocked
  assert_eq(@types.is_level_unlocked(game, 0), true)
  // Level 1 locked until level 0 completed
  assert_eq(@types.is_level_unlocked(game, 1), false)
  game.level_progress[0].completed = true
  assert_eq(@types.is_level_unlocked(game, 1), true)
}

///|
test "reset_grid" {
  let grid = @types.new_grid()
  grid.tiles[0][0].material = Metal
  grid.tiles[0][0].temperature = 100.0
  grid.tiles[0][0].kind = HeatSource(200.0)
  grid.tiles[0][0].locked = true
  @types.reset_grid(grid)
  assert_eq(grid.tiles[0][0].material, Empty)
  assert_eq(grid.tiles[0][0].temperature, @types.ambient_temp)
  assert_eq(grid.tiles[0][0].kind, Normal)
  assert_eq(grid.tiles[0][0].locked, false)
}
