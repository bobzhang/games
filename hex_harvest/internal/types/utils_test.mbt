///|
test "hex_neighbors_even_row" {
  // Even row (row=0), col=3 should have 6 neighbors
  let neighbors = hex_neighbors(3, 0)
  assert_eq(neighbors.length(), 6)
  // Check specific neighbors for even row
  // NE: (3, -1) - out of bounds but still computed
  // E: (4, 0)
  // SE: (3, 1)
  // SW: (2, 1)
  // W: (2, 0)
  // NW: (2, -1)
  assert_eq(neighbors[1], (4, 0))
  assert_eq(neighbors[4], (2, 0))
}

///|
test "hex_neighbors_odd_row" {
  // Odd row (row=1), col=3
  let neighbors = hex_neighbors(3, 1)
  assert_eq(neighbors.length(), 6)
  // NE: (4, 0)
  // E: (4, 1)
  // SE: (4, 2)
  // SW: (3, 2)
  // W: (2, 1)
  // NW: (3, 0)
  assert_eq(neighbors[0], (4, 0))
  assert_eq(neighbors[1], (4, 1))
  assert_eq(neighbors[4], (2, 1))
  assert_eq(neighbors[5], (3, 0))
}

///|
test "hex_in_bounds" {
  assert_true(hex_in_bounds(0, 0))
  assert_true(hex_in_bounds(7, 5))
  assert_false(hex_in_bounds(-1, 0))
  assert_false(hex_in_bounds(0, -1))
  assert_false(hex_in_bounds(8, 0))
  assert_false(hex_in_bounds(0, 6))
}

///|
test "hex_distance_same" {
  assert_eq(hex_distance(3, 2, 3, 2), 0)
}

///|
test "hex_distance_adjacent" {
  // Adjacent hexes should have distance 1
  assert_eq(hex_distance(3, 0, 4, 0), 1)
  assert_eq(hex_distance(3, 0, 3, 1), 1)
}

///|
test "hex_distance_farther" {
  // Distance should increase
  let d = hex_distance(0, 0, 4, 0)
  assert_true(d > 1)
}

///|
test "offset_to_cube_roundtrip" {
  let (x, y, z) = offset_to_cube(3, 2)
  // Cube coordinate constraint: x + y + z = 0
  assert_eq(x + y + z, 0)
}

///|
test "crop_grow_time" {
  assert_eq(crop_grow_time(Wheat), 2)
  assert_eq(crop_grow_time(Corn), 3)
  assert_eq(crop_grow_time(Berry), 3)
  assert_eq(crop_grow_time(Flower), 2)
}

///|
test "crop_base_yield" {
  assert_eq(crop_base_yield(Wheat), 1)
  assert_eq(crop_base_yield(Corn), 2)
  assert_eq(crop_base_yield(Berry), 2)
  assert_eq(crop_base_yield(Flower), 1)
}

///|
test "tile_plantable" {
  let dirt = new_tile(Dirt, 0)
  assert_true(tile_plantable(dirt))
  let rock = new_tile(Rock, 0)
  assert_false(tile_plantable(rock))
  let ws = new_tile(WaterSource, 2)
  assert_false(tile_plantable(ws))
  let goal = new_tile(Goal, 0)
  assert_true(tile_plantable(goal))
  // Tile with crop already placed
  let planted = new_tile(Dirt, 0)
  planted.crop = Some(Wheat)
  assert_false(tile_plantable(planted))
}

///|
test "tile_channelable" {
  let dirt = new_tile(Dirt, 0)
  assert_true(tile_channelable(dirt))
  let rock = new_tile(Rock, 0)
  assert_false(tile_channelable(rock))
  // Already has channel
  let ch = new_tile(Dirt, 0)
  ch.has_channel = true
  assert_false(tile_channelable(ch))
  // Has crop
  let cropped = new_tile(Dirt, 0)
  cropped.crop = Some(Wheat)
  assert_false(tile_channelable(cropped))
}

///|
test "clampf" {
  let v1 : Float = clampf(-1.0, 0.0, 1.0)
  assert_true(v1 == 0.0)
  let v2 : Float = clampf(2.0, 0.0, 1.0)
  assert_true(v2 == 1.0)
  let v3 : Float = clampf(0.5, 0.0, 1.0)
  assert_true(v3 == 0.5)
}

///|
test "clampi" {
  assert_eq(clampi(-5, 0, 10), 0)
  assert_eq(clampi(15, 0, 10), 10)
  assert_eq(clampi(5, 0, 10), 5)
}
