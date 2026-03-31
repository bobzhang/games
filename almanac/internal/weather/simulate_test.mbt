///|
test "Sun makes adjacent tiles Sunny" {
  let grid = @types.make_grid(5, 5, [], [])
  let sources : Array[@types.Source] = [
    { kind: Sun, col: 2, row: 2, wind_dir: East },
  ]
  simulate_turn(grid, sources)
  // Center should be Sunny
  assert_eq(@types.grid_get(grid, 2, 2).weather, Sunny)
  // Adjacent tiles should be Sunny
  assert_eq(@types.grid_get(grid, 1, 2).weather, Sunny)
  assert_eq(@types.grid_get(grid, 3, 2).weather, Sunny)
  assert_eq(@types.grid_get(grid, 2, 1).weather, Sunny)
  assert_eq(@types.grid_get(grid, 2, 3).weather, Sunny)
  // Diagonal should remain Clear
  assert_eq(@types.grid_get(grid, 1, 1).weather, Clear)
}

///|
test "Cloud blocks sun" {
  let grid = @types.make_grid(5, 5, [], [])
  // Pre-set a cloud
  @types.grid_get(grid, 3, 2).weather = Cloudy
  let sources : Array[@types.Source] = [
    { kind: Sun, col: 2, row: 2, wind_dir: East },
  ]
  simulate_turn(grid, sources)
  // The cloudy tile should remain cloudy (sun blocked)
  assert_eq(@types.grid_get(grid, 3, 2).weather, Cloudy)
}

///|
test "Rain flows downhill" {
  // Height layout: center is 2, neighbors are 0
  let heights : Array[Int] = []
  for i in 0..<25 {
    if i == 12 {
      // (2,2)
      heights.push(2)
    } else {
      heights.push(0)
    }
  }
  let grid = @types.make_grid(5, 5, heights, [])
  let sources : Array[@types.Source] = [
    { kind: Rain, col: 2, row: 2, wind_dir: East },
  ]
  simulate_turn(grid, sources)
  // Center should be Rainy
  assert_eq(@types.grid_get(grid, 2, 2).weather, Rainy)
  // Adjacent lower tiles should be Rainy
  assert_eq(@types.grid_get(grid, 1, 2).weather, Rainy)
  assert_eq(@types.grid_get(grid, 3, 2).weather, Rainy)
}

///|
test "Wind pushes clouds" {
  let grid = @types.make_grid(5, 5, [], [])
  // Place a cloud at (2,2)
  @types.grid_get(grid, 2, 2).weather = Cloudy
  let sources : Array[@types.Source] = [
    { kind: Wind, col: 1, row: 2, wind_dir: East },
  ]
  simulate_turn(grid, sources)
  // Cloud should have moved east to (3,2)
  assert_eq(@types.grid_get(grid, 3, 2).weather, Cloudy)
}

///|
test "Rain + Wind = Storm" {
  let grid = @types.make_grid(5, 5, [], [])
  let sources : Array[@types.Source] = [
    { kind: Rain, col: 2, row: 2, wind_dir: East },
    { kind: Wind, col: 2, row: 3, wind_dir: East },
  ]
  simulate_turn(grid, sources)
  // The tile where rain and wind overlap should be Stormy
  // Wind at (2,3) affects adjacent (2,2), Rain at (2,2) is there
  // The rain source tile has rain influence and wind is adjacent, so should be stormy
  assert_eq(@types.grid_get(grid, 2, 2).weather, Stormy)
}

///|
test "Sunny + Rainy = Cancel to Clear" {
  let grid = @types.make_grid(5, 5, [], [])
  // Place sun and rain adjacent to same tile
  let sources : Array[@types.Source] = [
    { kind: Sun, col: 2, row: 2, wind_dir: East },
    { kind: Rain, col: 2, row: 3, wind_dir: East },
  ]
  simulate_turn(grid, sources)
  // Tile (2,3) would get rain from source + sun adjacency, should cancel
  // Actually: (2,3) is rain source => Rainy, sun at (2,2) is adjacent => cancel to Clear
  assert_eq(@types.grid_get(grid, 2, 3).weather, Clear)
}

///|
test "Target satisfaction" {
  let targets : Array[(Int, Int, @types.WeatherState)] = [
    (2, 2, Sunny),
    (3, 3, Rainy),
  ]
  let grid = @types.make_grid(5, 5, [], targets)
  // Not met initially
  assert_eq(check_targets(grid), false)
  // Set weather to match
  @types.grid_get(grid, 2, 2).weather = Sunny
  @types.grid_get(grid, 3, 3).weather = Rainy
  assert_eq(check_targets(grid), true)
}
