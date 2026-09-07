///|
test "flood fill: no fences gives single region" {
  let tiles : Array[@types.TileKind] = []
  for _i in 0..<16 {
    tiles.push(Empty)
  }
  let grid = @types.make_grid(4, 4, tiles)
  let fences : Array[@types.FenceEdge] = []
  let regions = flood_fill_regions(grid, fences)
  assert_eq(regions.length(), 1)
  assert_eq(regions[0].area, 16)
}

///|
test "flood fill: horizontal fence splits into two regions" {
  let tiles : Array[@types.TileKind] = []
  for _i in 0..<16 {
    tiles.push(Empty)
  }
  let grid = @types.make_grid(4, 4, tiles)
  // Place horizontal fences across row 2 (between row 1 and row 2)
  let fences : Array[@types.FenceEdge] = [
    @types.make_fence(2, 0, Horizontal),
    @types.make_fence(2, 1, Horizontal),
    @types.make_fence(2, 2, Horizontal),
    @types.make_fence(2, 3, Horizontal),
  ]
  let regions = flood_fill_regions(grid, fences)
  assert_eq(regions.length(), 2)
  assert_eq(regions[0].area, 8)
  assert_eq(regions[1].area, 8)
}

///|
test "single house per region: satisfied" {
  let tiles : Array[@types.TileKind] = [
    House(0),
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
  ]
  let grid = @types.make_grid(3, 3, tiles)
  let houses = [@types.make_house(0, 0, 0, 9)]
  let level = @types.make_level(
    grid,
    houses,
    @types.make_constraint(false, false),
    4,
    4,
    Plots,
    "test",
  )
  let fences : Array[@types.FenceEdge] = []
  let regions = flood_fill_regions(grid, fences)
  let statuses = validate_level(level, fences, regions)
  assert_eq(statuses.length(), 1)
  assert_eq(statuses[0].one_house, Satisfied)
  assert_eq(statuses[0].correct_area, Satisfied)
}

///|
test "area constraint: violated when wrong" {
  let tiles : Array[@types.TileKind] = [
    House(0),
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
  ]
  let grid = @types.make_grid(3, 3, tiles)
  let houses = [@types.make_house(0, 0, 0, 5)] // wants area 5, but whole grid is 9
  let level = @types.make_level(
    grid,
    houses,
    @types.make_constraint(false, false),
    4,
    4,
    Plots,
    "test",
  )
  let fences : Array[@types.FenceEdge] = []
  let regions = flood_fill_regions(grid, fences)
  let statuses = validate_level(level, fences, regions)
  assert_eq(statuses[0].correct_area, Violated)
}

///|
test "road access: satisfied when region has road tile" {
  let tiles : Array[@types.TileKind] = [
    House(0),
    Road,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
  ]
  let grid = @types.make_grid(3, 3, tiles)
  let houses = [@types.make_house(0, 0, 0, 9)]
  let level = @types.make_level(
    grid,
    houses,
    @types.make_constraint(false, false),
    4,
    4,
    Plots,
    "test",
  )
  let fences : Array[@types.FenceEdge] = []
  let regions = flood_fill_regions(grid, fences)
  let statuses = validate_level(level, fences, regions)
  assert_eq(statuses[0].road_access, Satisfied)
}

///|
test "road access: violated when region lacks road" {
  // Grid has road but region with house doesn't touch it
  let tiles : Array[@types.TileKind] = [
    House(0),
    Empty,
    Empty,
    Empty,
    Empty,
    Empty,
    Road,
    Empty,
    House(1),
  ]
  let grid = @types.make_grid(3, 3, tiles)
  let houses = [@types.make_house(0, 0, 0, 4), @types.make_house(2, 2, 1, 4)]
  let level = @types.make_level(
    grid,
    houses,
    @types.make_constraint(false, false),
    4,
    4,
    Plots,
    "test",
  )
  // Fence to separate them horizontally at row 2
  let fences : Array[@types.FenceEdge] = [
    @types.make_fence(2, 0, Horizontal),
    @types.make_fence(2, 1, Horizontal),
    @types.make_fence(2, 2, Horizontal),
  ]
  let regions = flood_fill_regions(grid, fences)
  let statuses = validate_level(level, fences, regions)
  // House 0 region has no road -> Violated
  assert_eq(statuses[0].road_access, Violated)
  // House 1 region has road -> Satisfied
  assert_eq(statuses[1].road_access, Satisfied)
}

///|
test "fence placement and removal" {
  let fences : Array[@types.FenceEdge] = []
  let f = @types.make_fence(1, 2, Horizontal)
  @types.toggle_fence(fences, f)
  assert_eq(fences.length(), 1)
  @types.toggle_fence(fences, f)
  assert_eq(fences.length(), 0)
}

///|
test "multiple houses in one region: violated" {
  let tiles : Array[@types.TileKind] = [House(0), House(1), Empty, Empty]
  let grid = @types.make_grid(2, 2, tiles)
  let houses = [@types.make_house(0, 0, 0, 4), @types.make_house(1, 0, 1, 4)]
  let level = @types.make_level(
    grid,
    houses,
    @types.make_constraint(false, false),
    4,
    4,
    Plots,
    "test",
  )
  let fences : Array[@types.FenceEdge] = []
  let regions = flood_fill_regions(grid, fences)
  let statuses = validate_level(level, fences, regions)
  // Both houses in same region -> one_house violated
  assert_eq(statuses[0].one_house, Violated)
  assert_eq(statuses[1].one_house, Violated)
}

///|
test "rectangular region check" {
  // L-shaped region is not rectangular
  let tiles : Array[@types.Vec2i] = [
    @types.vec2i(0, 0),
    @types.vec2i(1, 0),
    @types.vec2i(0, 1),
  ]
  let region : @types.Region = { tiles, houses: [], has_road: false, area: 3, }
  assert_eq(@types.is_region_rectangular(region), false)
  // 2x2 region is rectangular
  let tiles2 : Array[@types.Vec2i] = [
    @types.vec2i(0, 0),
    @types.vec2i(1, 0),
    @types.vec2i(0, 1),
    @types.vec2i(1, 1),
  ]
  let region2 : @types.Region = {
    tiles: tiles2,
    houses: [],
    has_road: false,
    area: 4,
  }
  assert_eq(@types.is_region_rectangular(region2), true)
}

///|
test "star computation" {
  let tiles : Array[@types.TileKind] = []
  for _i in 0..<4 {
    tiles.push(Empty)
  }
  let grid = @types.make_grid(2, 2, tiles)
  let level = @types.make_level(
    grid,
    [],
    @types.make_constraint(false, false),
    10,
    6,
    Plots,
    "test",
  )
  assert_eq(compute_stars(level, 5, true), 3)
  assert_eq(compute_stars(level, 8, true), 2)
  assert_eq(compute_stars(level, 12, true), 1)
  assert_eq(compute_stars(level, 5, false), 0)
}
