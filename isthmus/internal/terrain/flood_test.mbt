///|
test "is_tile_flooded" {
  let t1 = @types.new_tile(3, false)
  inspect(@terrain.is_tile_flooded(t1, 2), content="false")
  inspect(@terrain.is_tile_flooded(t1, 3), content="true")
  inspect(@terrain.is_tile_flooded(t1, 4), content="true")
}

///|
test "count_flooded_tiles" {
  let g = @types.new_grid(3, 3)
  // Heights: 0,1,2, 3,4,5, 0,1,2
  g.tiles[0].height = 0
  g.tiles[1].height = 1
  g.tiles[2].height = 2
  g.tiles[3].height = 3
  g.tiles[4].height = 4
  g.tiles[5].height = 5
  g.tiles[6].height = 0
  g.tiles[7].height = 1
  g.tiles[8].height = 2
  // At sea level 2: tiles with height 0,1,2 are flooded
  inspect(@terrain.count_flooded_tiles(g, 2), content="6")
  // At sea level 0: tiles with height 0 are flooded
  inspect(@terrain.count_flooded_tiles(g, 0), content="2")
}

///|
test "any_settlement_flooded" {
  let g = @types.new_grid(3, 3)
  g.tiles[0].height = 5
  g.tiles[0].is_settlement = true
  g.tiles[4].height = 2
  g.tiles[4].is_settlement = true
  inspect(@terrain.any_settlement_flooded(g, 1), content="false")
  inspect(@terrain.any_settlement_flooded(g, 2), content="true")
  inspect(@terrain.any_settlement_flooded(g, 5), content="true")
}

///|
test "will_settlement_flood_next" {
  let g = @types.new_grid(3, 3)
  g.tiles[0].height = 3
  g.tiles[0].is_settlement = true
  g.tiles[4].height = 5
  g.tiles[4].is_settlement = true
  // At sea level 1, next is 2 -- settlement at height 3 won't flood
  inspect(@terrain.will_settlement_flood_next(g, 1), content="false")
  // At sea level 2, next is 3 -- settlement at height 3 will flood
  inspect(@terrain.will_settlement_flood_next(g, 2), content="true")
}

///|
test "tiles_flooding_next" {
  let g = @types.new_grid(3, 2)
  g.tiles[0].height = 0
  g.tiles[1].height = 1
  g.tiles[2].height = 2
  g.tiles[3].height = 3
  g.tiles[4].height = 4
  g.tiles[5].height = 5
  // At sea level 1, next level is 2: tile at index 2 has height 2
  let flooding = @terrain.tiles_flooding_next(g, 1)
  inspect(flooding.length(), content="1")
  inspect(flooding[0], content="2")
}

///|
test "bfs_connected basic" {
  // 3x3 grid, connected land strip
  let g = @types.new_grid(3, 3)
  // Row 0: all water (height 0)
  // Row 1: land bridge (height 2)
  g.tiles[3].height = 2
  g.tiles[4].height = 2
  g.tiles[5].height = 2
  // Row 2: all water
  let visited = @terrain.bfs_connected(g, 3, 0)
  inspect(visited[3], content="true")
  inspect(visited[4], content="true")
  inspect(visited[5], content="true")
  inspect(visited[0], content="false")
}

///|
test "all_settlements_connected - connected" {
  let g = @types.new_grid(5, 1)
  // Continuous land strip with settlements at ends
  g.tiles[0].height = 3
  g.tiles[0].is_settlement = true
  g.tiles[1].height = 3
  g.tiles[2].height = 3
  g.tiles[3].height = 3
  g.tiles[4].height = 3
  g.tiles[4].is_settlement = true
  inspect(@terrain.all_settlements_connected(g, 0), content="true")
}

///|
test "all_settlements_connected - disconnected" {
  let g = @types.new_grid(5, 1)
  g.tiles[0].height = 3
  g.tiles[0].is_settlement = true
  g.tiles[1].height = 3
  g.tiles[2].height = 0 // water gap
  g.tiles[3].height = 3
  g.tiles[4].height = 3
  g.tiles[4].is_settlement = true
  inspect(@terrain.all_settlements_connected(g, 0), content="false")
}

///|
test "all_settlements_connected - single settlement" {
  let g = @types.new_grid(3, 3)
  g.tiles[4].height = 3
  g.tiles[4].is_settlement = true
  inspect(@terrain.all_settlements_connected(g, 0), content="true")
}

///|
test "count_connected_settlements" {
  let g = @types.new_grid(5, 1)
  g.tiles[0].height = 3
  g.tiles[0].is_settlement = true
  g.tiles[1].height = 3
  g.tiles[2].height = 0 // gap
  g.tiles[3].height = 3
  g.tiles[3].is_settlement = true
  g.tiles[4].height = 3
  g.tiles[4].is_settlement = true
  let (connected, total) = @terrain.count_connected_settlements(g, 0)
  // Settlements at 3 and 4 are connected, settlement at 0 is separate
  // First above is 0, BFS from 0 only reaches 0
  inspect(connected, content="1")
  inspect(total, content="3")
}

///|
test "settlement_safety_margin" {
  let g = @types.new_grid(3, 1)
  g.tiles[0].height = 5
  g.tiles[0].is_settlement = true
  g.tiles[2].height = 3
  g.tiles[2].is_settlement = true
  // At sea level 1, margins are 4 and 2
  inspect(@terrain.settlement_safety_margin(g, 1), content="2")
}

///|
test "sea level progression floods correctly" {
  let g = @types.new_grid(3, 1)
  g.tiles[0].height = 1
  g.tiles[1].height = 2
  g.tiles[2].height = 3
  g.tiles[2].is_settlement = true
  // Sea level 0: nothing flooded relevant
  inspect(@terrain.any_settlement_flooded(g, 0), content="false")
  inspect(@terrain.count_flooded_tiles(g, 0), content="0")
  // Sea level 1: tile 0 floods
  inspect(@terrain.count_flooded_tiles(g, 1), content="1")
  inspect(@terrain.any_settlement_flooded(g, 1), content="false")
  // Sea level 2: tiles 0,1 flood
  inspect(@terrain.count_flooded_tiles(g, 2), content="2")
  inspect(@terrain.any_settlement_flooded(g, 2), content="false")
  // Sea level 3: all flood including settlement
  inspect(@terrain.count_flooded_tiles(g, 3), content="3")
  inspect(@terrain.any_settlement_flooded(g, 3), content="true")
}

///|
test "never_disconnected tracking scenario" {
  // Simulate a game where settlements start connected, get disconnected, then reconnected
  let g = @types.new_grid(5, 1)
  g.tiles[0].height = 3
  g.tiles[0].is_settlement = true
  g.tiles[1].height = 1 // will flood at sea level 1
  g.tiles[2].height = 3
  g.tiles[3].height = 3
  g.tiles[4].height = 3
  g.tiles[4].is_settlement = true
  // At sea level 0: all connected
  inspect(@terrain.all_settlements_connected(g, 0), content="true")
  // At sea level 1: tile 1 floods, disconnected
  inspect(@terrain.all_settlements_connected(g, 1), content="false")
  // Even if we raise tile 1 later, the never_disconnected flag would be false
}
