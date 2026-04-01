///|
test "can_place_sand - adjacent to land" {
  let g = @types.new_grid(3, 3)
  g.tiles[4].height = 3 // center tile is land
  // Can place adjacent to land (on water tile next to land)
  inspect(@terrain.can_place_sand(g, 1, 0, 0), content="true")
  // Can place on existing land (raise it)
  inspect(@terrain.can_place_sand(g, 1, 1, 0), content="true")
  // Cannot place on water far from land
  inspect(@terrain.can_place_sand(g, 0, 0, 0), content="false")
}

///|
test "can_place_sand - out of bounds" {
  let g = @types.new_grid(3, 3)
  inspect(@terrain.can_place_sand(g, -1, 0, 0), content="false")
  inspect(@terrain.can_place_sand(g, 3, 0, 0), content="false")
}

///|
test "place_sand raises height" {
  let g = @types.new_grid(3, 3)
  g.tiles[4].height = 3 // center
  // Place on water tile adjacent to land
  let placed = @terrain.place_sand(g, 1, 0, 0)
  inspect(placed, content="true")
  inspect(g.tiles[1].height, content="1") // sea_level + 1
  inspect(g.tiles[1].is_sand, content="true")
}

///|
test "place_sand raises existing land" {
  let g = @types.new_grid(3, 3)
  g.tiles[4].height = 3
  let placed = @terrain.place_sand(g, 1, 1, 0)
  inspect(placed, content="true")
  inspect(g.tiles[4].height, content="4") // raised by 1
}

///|
test "place_sand fails on isolated water" {
  let g = @types.new_grid(3, 3)
  g.tiles[4].height = 3 // only center is land
  let placed = @terrain.place_sand(g, 0, 0, 0)
  inspect(placed, content="false")
  inspect(g.tiles[0].height, content="0") // unchanged
}

///|
test "valid_placements" {
  let g = @types.new_grid(3, 3)
  g.tiles[4].height = 3 // center is land
  let placements = @terrain.valid_placements(g, 0)
  // Center (1,1) + 4 neighbors
  inspect(placements.length(), content="5")
}

///|
test "count_land_tiles" {
  let g = @types.new_grid(3, 3)
  g.tiles[0].height = 3
  g.tiles[4].height = 5
  g.tiles[8].height = 2
  inspect(@terrain.count_land_tiles(g, 0), content="3")
  inspect(@terrain.count_land_tiles(g, 2), content="2")
  inspect(@terrain.count_land_tiles(g, 5), content="0")
}

///|
test "sand placement validation with sea level" {
  let g = @types.new_grid(3, 3)
  g.tiles[4].height = 3 // center land
  g.tiles[1].height = 1 // shallow tile above center
  // At sea level 0, tile at (1,0) height=1 is above water, can place
  inspect(@terrain.can_place_sand(g, 1, 0, 0), content="true")
  // At sea level 1, tile at (1,0) height=1 is flooded, but adjacent to land
  inspect(@terrain.can_place_sand(g, 1, 0, 1), content="true")
  // At sea level 2, tile at (1,0) is flooded, still adjacent to land at height 3
  inspect(@terrain.can_place_sand(g, 1, 0, 2), content="true")
}
