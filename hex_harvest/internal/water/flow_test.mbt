///|
test "water_flows_downhill" {
  let grid = @types.new_grid(3, 3)
  // Set up: water source at (1,0) height 2, dirt at (1,1) height 1
  grid.tiles[0][1].kind = WaterSource
  grid.tiles[0][1].height = 2
  grid.tiles[0][1].watered = true
  grid.tiles[1][1].kind = Dirt
  grid.tiles[1][1].height = 1
  let newly = flow_water(grid)
  // Water should have spread to lower neighbor
  assert_true(newly.length() > 0)
}

///|
test "water_blocked_by_rock" {
  let grid = @types.new_grid(3, 3)
  grid.tiles[0][1].kind = WaterSource
  grid.tiles[0][1].height = 2
  grid.tiles[0][1].watered = true
  // Surround with rocks
  grid.tiles[0][0].kind = Rock
  grid.tiles[0][2].kind = Rock
  grid.tiles[1][0].kind = Rock
  grid.tiles[1][1].kind = Rock
  grid.tiles[1][2].kind = Rock
  let newly = flow_water(grid)
  // No water should flow to rock tiles
  for i in 0..<newly.length() {
    let coord = newly[i]
    let tile = grid.tiles[coord.row][coord.col]
    assert_false(tile.kind == Rock)
  }
}

///|
test "channel_enables_same_height_flow" {
  let grid = @types.new_grid(3, 3)
  // Same height tiles, one watered, one with channel
  grid.tiles[0][0].kind = WaterSource
  grid.tiles[0][0].height = 1
  grid.tiles[0][0].watered = true
  grid.tiles[0][1].kind = Dirt
  grid.tiles[0][1].height = 1
  grid.tiles[0][1].has_channel = true
  let newly = flow_water(grid)
  // The channeled tile should get watered
  let mut found = false
  for i in 0..<newly.length() {
    if newly[i].col == 1 && newly[i].row == 0 {
      found = true
    }
  }
  assert_true(found)
}

///|
test "count_watered" {
  let grid = @types.new_grid(3, 3)
  grid.tiles[0][0].watered = true
  grid.tiles[1][1].watered = true
  assert_eq(count_watered(grid), 2)
}
