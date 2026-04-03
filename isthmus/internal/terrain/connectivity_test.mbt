///|
test "bfs on single tile grid" {
  let g = @types.new_grid(1, 1)
  g.tiles[0].height = 5
  let visited = bfs_connected(g, 0, 0)
  inspect(visited[0], content="true")
}

///|
test "bfs does not cross flooded tiles" {
  let g = @types.new_grid(3, 1)
  g.tiles[0].height = 5
  g.tiles[1].height = 0 // flooded at sea level 0
  g.tiles[2].height = 5
  let visited = bfs_connected(g, 0, 0)
  inspect(visited[0], content="true")
  inspect(visited[1], content="false")
  inspect(visited[2], content="false")
}

///|
test "bfs traverses L-shaped path" {
  // 3x3 grid with L-shaped land
  let g = @types.new_grid(3, 3)
  // Bottom row: all land
  g.tiles[6].height = 3
  g.tiles[7].height = 3
  g.tiles[8].height = 3
  // Right column: land going up
  g.tiles[5].height = 3
  g.tiles[2].height = 3
  // Everything else is water (height 0)
  let visited = bfs_connected(g, 6, 0)
  inspect(visited[6], content="true")
  inspect(visited[7], content="true")
  inspect(visited[8], content="true")
  inspect(visited[5], content="true")
  inspect(visited[2], content="true")
  // Water tiles not visited
  inspect(visited[0], content="false")
  inspect(visited[1], content="false")
  inspect(visited[3], content="false")
  inspect(visited[4], content="false")
}

///|
test "bfs no diagonal connections" {
  // Diagonal tiles should NOT be connected
  let g = @types.new_grid(3, 3)
  g.tiles[0].height = 5 // top-left
  g.tiles[4].height = 5 // center (diagonal from top-left)
  g.tiles[8].height = 5 // bottom-right (diagonal from center)
  let visited = bfs_connected(g, 0, 0)
  inspect(visited[0], content="true")
  // Diagonal neighbors should NOT be reachable
  inspect(visited[4], content="false")
  inspect(visited[8], content="false")
}

///|
test "all settlements connected on fully connected land" {
  let g = @types.new_grid(4, 4)
  // All tiles are land
  for i in 0..<16 {
    g.tiles[i].height = 5
  }
  g.tiles[0].is_settlement = true
  g.tiles[3].is_settlement = true
  g.tiles[12].is_settlement = true
  g.tiles[15].is_settlement = true
  inspect(all_settlements_connected(g, 0), content="true")
}

///|
test "settlements disconnected by water channel" {
  // 5x3 grid with a vertical water channel in the middle
  let g = @types.new_grid(5, 3)
  for i in 0..<15 {
    g.tiles[i].height = 5
  }
  // Water channel at column 2
  g.tiles[2].height = 0
  g.tiles[7].height = 0
  g.tiles[12].height = 0
  g.tiles[0].is_settlement = true
  g.tiles[4].is_settlement = true
  inspect(all_settlements_connected(g, 0), content="false")
}

///|
test "single settlement is always connected" {
  let g = @types.new_grid(3, 3)
  g.tiles[4].height = 5
  g.tiles[4].is_settlement = true
  inspect(all_settlements_connected(g, 0), content="true")
}

///|
test "no settlements means connected" {
  let g = @types.new_grid(3, 3)
  inspect(all_settlements_connected(g, 0), content="true")
}

///|
test "all settlements flooded returns false for connectivity" {
  let g = @types.new_grid(3, 3)
  g.tiles[0].height = 0
  g.tiles[0].is_settlement = true
  g.tiles[8].height = 0
  g.tiles[8].is_settlement = true
  // At sea level 0, both settlements are flooded
  inspect(all_settlements_connected(g, 0), content="false")
}

///|
test "count connected settlements with isolated groups" {
  // Two groups of settlements separated by water
  let g = @types.new_grid(7, 1)
  g.tiles[0].height = 5
  g.tiles[0].is_settlement = true
  g.tiles[1].height = 5
  g.tiles[1].is_settlement = true
  g.tiles[2].height = 5
  g.tiles[3].height = 0 // water gap
  g.tiles[4].height = 5
  g.tiles[5].height = 5
  g.tiles[5].is_settlement = true
  g.tiles[6].height = 5
  g.tiles[6].is_settlement = true
  let (connected, total) = count_connected_settlements(g, 0)
  // BFS from first settlement (index 0) reaches indices 0, 1, 2
  // Settlements at 0 and 1 are connected; settlements at 5, 6 are not
  inspect(connected, content="2")
  inspect(total, content="4")
}

///|
test "count connected when all connected" {
  let g = @types.new_grid(3, 1)
  g.tiles[0].height = 5
  g.tiles[0].is_settlement = true
  g.tiles[1].height = 5
  g.tiles[2].height = 5
  g.tiles[2].is_settlement = true
  let (connected, total) = count_connected_settlements(g, 0)
  inspect(connected, content="2")
  inspect(total, content="2")
}

///|
test "count connected with no settlements" {
  let g = @types.new_grid(3, 3)
  let (connected, total) = count_connected_settlements(g, 0)
  inspect(connected, content="0")
  inspect(total, content="0")
}

///|
test "settlement safety margin with varying heights" {
  let g = @types.new_grid(4, 1)
  g.tiles[0].height = 10
  g.tiles[0].is_settlement = true
  g.tiles[1].height = 3
  g.tiles[1].is_settlement = true
  g.tiles[2].height = 7
  g.tiles[2].is_settlement = true
  g.tiles[3].height = 5
  // Sea level 2: margins are 8, 1, 5 -> min is 1
  inspect(settlement_safety_margin(g, 2), content="1")
}

///|
test "safety margin can be negative when settlement flooded" {
  let g = @types.new_grid(2, 1)
  g.tiles[0].height = 2
  g.tiles[0].is_settlement = true
  g.tiles[1].height = 5
  g.tiles[1].is_settlement = true
  // Sea level 3: margins are -1 and 2 -> min is -1
  inspect(settlement_safety_margin(g, 3), content="-1")
}

///|
test "rising sea level progressively disconnects settlements" {
  // In a 1D row, one flooded tile breaks the connection
  let g = @types.new_grid(5, 1)
  g.tiles[0].height = 5
  g.tiles[0].is_settlement = true
  g.tiles[1].height = 3 // bridge tile
  g.tiles[2].height = 4 // bridge tile
  g.tiles[3].height = 5 // bridge tile
  g.tiles[4].height = 5
  g.tiles[4].is_settlement = true
  // Sea level 0: all connected (all heights > 0)
  inspect(all_settlements_connected(g, 0), content="true")
  // Sea level 2: all tiles still above water (min height 3 > 2)
  inspect(all_settlements_connected(g, 2), content="true")
  // Sea level 3: tile 1 floods (height 3 <= 3), breaking path -> disconnected
  inspect(all_settlements_connected(g, 3), content="false")
  // Sea level 4: tiles 1,2 flood, still disconnected
  inspect(all_settlements_connected(g, 4), content="false")
}

///|
test "bfs on large grid with narrow corridor" {
  // 5x5 grid with a 1-tile-wide corridor
  let g = @types.new_grid(5, 5)
  // All water by default (height 0)
  // Top-left island
  g.tiles[0].height = 5
  g.tiles[1].height = 5
  g.tiles[5].height = 5
  g.tiles[6].height = 5
  // Narrow corridor
  g.tiles[12].height = 5 // center tile (2,2)
  // Bottom-right island
  g.tiles[18].height = 5
  g.tiles[19].height = 5
  g.tiles[23].height = 5
  g.tiles[24].height = 5
  let visited = bfs_connected(g, 0, 0)
  // Top-left island is connected within itself
  inspect(visited[0], content="true")
  inspect(visited[1], content="true")
  inspect(visited[5], content="true")
  inspect(visited[6], content="true")
  // But not connected to corridor (no adjacent land path)
  inspect(visited[12], content="false")
  inspect(visited[18], content="false")
}

///|
test "tiles flooding next returns correct indices" {
  let g = @types.new_grid(4, 1)
  g.tiles[0].height = 1
  g.tiles[1].height = 2
  g.tiles[2].height = 3
  g.tiles[3].height = 4
  // At sea level 2, next level is 3: tile at index 2 has height 3
  let flooding = tiles_flooding_next(g, 2)
  inspect(flooding.length(), content="1")
  inspect(flooding[0], content="2")
}

///|
test "tiles flooding next returns empty when no tiles at next level" {
  let g = @types.new_grid(3, 1)
  g.tiles[0].height = 1
  g.tiles[1].height = 1
  g.tiles[2].height = 5
  // At sea level 2, next level is 3: no tiles have height 3
  let flooding = tiles_flooding_next(g, 2)
  inspect(flooding.length(), content="0")
}

///|
test "will settlement flood next detects imminent danger" {
  let g = @types.new_grid(3, 1)
  g.tiles[0].height = 3
  g.tiles[0].is_settlement = true
  g.tiles[1].height = 5
  g.tiles[2].height = 7
  g.tiles[2].is_settlement = true
  // At sea level 2, next level is 3: settlement at tile 0 has height 3
  inspect(will_settlement_flood_next(g, 2), content="true")
  // At sea level 0, next level is 1: no settlement at height 1
  inspect(will_settlement_flood_next(g, 0), content="false")
}
