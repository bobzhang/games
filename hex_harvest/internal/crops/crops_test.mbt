///|
test "adjacency_bonus_same_type" {
  let grid = @types.new_grid(3, 3)
  // Place wheat at (0,0) and (1,0)
  grid.tiles[0][0].crop = Some(Wheat)
  grid.tiles[0][0].crop_state = Growing
  grid.tiles[0][1].crop = Some(Wheat)
  grid.tiles[0][1].crop_state = Growing
  // Check bonus for tile at (0,0)
  let bonus = adjacency_bonus(grid, 0, 0)
  // Should get +1 for same-type neighbor
  assert_true(bonus >= 1)
}

///|
test "adjacency_bonus_wheat_corn_combo" {
  let grid = @types.new_grid(3, 3)
  // Place wheat at (0,0) and corn at (1,0)
  grid.tiles[0][0].crop = Some(Wheat)
  grid.tiles[0][0].crop_state = Growing
  grid.tiles[0][1].crop = Some(Corn)
  grid.tiles[0][1].crop_state = Growing
  let bonus = adjacency_bonus(grid, 0, 0)
  // Should get +2 for wheat+corn combo
  assert_true(bonus >= 2)
}

///|
test "adjacency_bonus_berry_flower_combo" {
  let grid = @types.new_grid(3, 3)
  grid.tiles[0][0].crop = Some(Berry)
  grid.tiles[0][0].crop_state = Growing
  grid.tiles[0][1].crop = Some(Flower)
  grid.tiles[0][1].crop_state = Growing
  let bonus = adjacency_bonus(grid, 0, 0)
  // Should get +3 for berry+flower combo
  assert_true(bonus >= 3)
}

///|
test "adjacency_bonus_no_crop" {
  let grid = @types.new_grid(3, 3)
  // No crop at (1,1)
  let bonus = adjacency_bonus(grid, 1, 1)
  assert_eq(bonus, 0)
}

///|
test "grow_crops_watered" {
  let grid = @types.new_grid(3, 3)
  grid.tiles[0][0].crop = Some(Wheat)
  grid.tiles[0][0].crop_state = Seed
  grid.tiles[0][0].watered = true
  grid.tiles[0][0].crop_turns = 0
  let _matured = grow_crops(grid)
  // Should advance from Seed to Growing
  assert_eq(grid.tiles[0][0].crop_state, Growing)
  assert_eq(grid.tiles[0][0].crop_turns, 1)
}

///|
test "grow_crops_not_watered" {
  let grid = @types.new_grid(3, 3)
  grid.tiles[0][0].crop = Some(Wheat)
  grid.tiles[0][0].crop_state = Seed
  grid.tiles[0][0].watered = false
  let _matured = grow_crops(grid)
  // Should NOT advance
  assert_eq(grid.tiles[0][0].crop_state, Seed)
}

///|
test "harvest_mature_crops" {
  let grid = @types.new_grid(3, 3)
  grid.tiles[0][0].crop = Some(Wheat)
  grid.tiles[0][0].crop_state = Mature
  let (yield_val, harvested) = harvest_mature(grid)
  // Wheat base yield is 1
  assert_true(yield_val >= 1)
  assert_eq(harvested.length(), 1)
  assert_eq(grid.tiles[0][0].crop_state, Harvested)
}

///|
test "projected_yield" {
  let grid = @types.new_grid(3, 3)
  grid.tiles[0][0].crop = Some(Wheat)
  grid.tiles[0][0].crop_state = Growing
  grid.tiles[0][1].crop = Some(Corn)
  grid.tiles[0][1].crop_state = Seed
  let proj = projected_yield(grid)
  // Wheat(1) + Corn(2) + adjacency bonuses
  assert_true(proj >= 3)
}

///|
test "count_crops" {
  let grid = @types.new_grid(3, 3)
  grid.tiles[0][0].crop = Some(Wheat)
  grid.tiles[0][0].crop_state = Seed
  grid.tiles[0][1].crop = Some(Corn)
  grid.tiles[0][1].crop_state = Growing
  grid.tiles[1][0].crop = Some(Berry)
  grid.tiles[1][0].crop_state = Mature
  let (seeds, growing, mature, harvested) = count_crops(grid)
  assert_eq(seeds, 1)
  assert_eq(growing, 1)
  assert_eq(mature, 1)
  assert_eq(harvested, 0)
}
