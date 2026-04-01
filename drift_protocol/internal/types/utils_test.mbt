///|
test "in_bounds checks grid boundaries" {
  inspect(@types.in_bounds(0, 0), content="true")
  inspect(@types.in_bounds(19, 14), content="true")
  inspect(@types.in_bounds(-1, 0), content="false")
  inspect(@types.in_bounds(0, -1), content="false")
  inspect(@types.in_bounds(20, 0), content="false")
  inspect(@types.in_bounds(0, 15), content="false")
}

///|
test "tile_walkable identifies walkable tiles" {
  inspect(@types.tile_walkable(Floor), content="true")
  inspect(@types.tile_walkable(Wall), content="false")
  inspect(@types.tile_walkable(Shadow), content="true")
  inspect(@types.tile_walkable(Terminal), content="true")
  inspect(@types.tile_walkable(Exit), content="true")
}

///|
test "direction helpers return correct values" {
  inspect(@types.direction_dx(Left), content="-1")
  inspect(@types.direction_dx(Right), content="1")
  inspect(@types.direction_dx(Up), content="0")
  inspect(@types.direction_dy(Up), content="-1")
  inspect(@types.direction_dy(Down), content="1")
}

///|
test "manhattan_dist computes correctly" {
  inspect(@types.manhattan_dist(0, 0, 3, 4), content="7")
  inspect(@types.manhattan_dist(5, 5, 5, 5), content="0")
  inspect(@types.manhattan_dist(0, 0, 1, 0), content="1")
}

///|
test "is_adjacent checks 4-directional adjacency" {
  inspect(@types.is_adjacent(5, 5, 5, 6), content="true")
  inspect(@types.is_adjacent(5, 5, 6, 5), content="true")
  inspect(@types.is_adjacent(5, 5, 5, 5), content="false")
  inspect(@types.is_adjacent(5, 5, 6, 6), content="false")
  inspect(@types.is_adjacent(5, 5, 7, 5), content="false")
}

///|
test "tile_to_pixel and pixel_to_tile are inverse" {
  let gx = 5
  let gy = 7
  let px = @types.tile_to_pixel_x(gx)
  let py = @types.tile_to_pixel_y(gy)
  inspect(@types.pixel_to_tile_x(px), content="5")
  inspect(@types.pixel_to_tile_y(py), content="7")
}

///|
test "clampf constrains values" {
  inspect(@types.clampf(5.0, 0.0, 10.0), content="5")
  inspect(@types.clampf(-1.0, 0.0, 10.0), content="0")
  inspect(@types.clampf(15.0, 0.0, 10.0), content="10")
}

///|
test "has_line_of_sight through open tiles" {
  let tiles : Array[Array[@types.TileKind]] = Array::new(
    capacity=@types.grid_height,
  )
  for _y in 0..<@types.grid_height {
    let row : Array[@types.TileKind] = Array::new(capacity=@types.grid_width)
    for _x in 0..<@types.grid_width {
      row.push(Floor)
    }
    tiles.push(row)
  }
  // Clear path
  inspect(@types.has_line_of_sight(tiles, 1, 1, 5, 1), content="true")
  inspect(@types.has_line_of_sight(tiles, 1, 1, 5, 5), content="true")
  // Place a wall in the path
  tiles[1][3] = Wall
  inspect(@types.has_line_of_sight(tiles, 1, 1, 5, 1), content="false")
}

///|
test "rng produces different values" {
  @types.seed_rng(42)
  let a = @types.rng_next()
  let b = @types.rng_next()
  let c = @types.rng_next()
  // Verify they're different
  inspect(a != b, content="true")
  inspect(b != c, content="true")
}

///|
test "new_game creates valid initial state" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.level_scores.length(), content="8")
  inspect(game.frame_count, content="0")
}

///|
test "grid_dist computes euclidean distance" {
  let d = @types.grid_dist(0, 0, 3, 4)
  // Should be 5.0
  inspect(d == 5.0, content="true")
}
