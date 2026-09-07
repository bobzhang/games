///|
test "cell_screen_x returns correct position" {
  let x = cell_screen_x(0)
  assert_eq(x, grid_offset_x)
  let x3 = cell_screen_x(3)
  assert_eq(x3, grid_offset_x + 3 * cell_size)
}

///|
test "cell_screen_y returns correct position" {
  let y = cell_screen_y(0)
  assert_eq(y, grid_offset_y)
  let y2 = cell_screen_y(2)
  assert_eq(y2, grid_offset_y + 2 * cell_size)
}

///|
test "cell_center_x is center of cell" {
  let cx = cell_center_x(0)
  let expected = Float::from_int(grid_offset_x + cell_size / 2)
  assert_eq(cx, expected)
}

///|
test "cell_center_y is center of cell" {
  let cy = cell_center_y(0)
  let expected = Float::from_int(grid_offset_y + cell_size / 2)
  assert_eq(cy, expected)
}

///|
test "is_adjacent detects adjacent cells" {
  inspect(is_adjacent(0, 0, 1, 0), content="true")
  inspect(is_adjacent(0, 0, 0, 1), content="true")
  inspect(is_adjacent(3, 3, 3, 4), content="true")
  inspect(is_adjacent(3, 3, 4, 3), content="true")
}

///|
test "is_adjacent rejects non-adjacent" {
  inspect(is_adjacent(0, 0, 2, 0), content="false")
  inspect(is_adjacent(0, 0, 1, 1), content="false")
  inspect(is_adjacent(0, 0, 0, 0), content="false")
}

///|
test "is_connectable for each kind" {
  inspect(is_connectable(Source), content="true")
  inspect(is_connectable(Temple(50.0)), content="true")
  inspect(is_connectable(Waystone), content="true")
  inspect(is_connectable(Amplifier), content="true")
  inspect(is_connectable(Empty), content="false")
  inspect(is_connectable(Void), content="false")
}

///|
test "in_grid boundary checks" {
  inspect(in_grid(0, 0), content="true")
  inspect(in_grid(9, 7), content="true")
  inspect(in_grid(-1, 0), content="false")
  inspect(in_grid(0, -1), content="false")
  inspect(in_grid(10, 0), content="false")
  inspect(in_grid(0, 8), content="false")
}

///|
test "connection_exists finds existing" {
  let conns = [new_connection(0, 0, 1, 0), new_connection(2, 2, 3, 2)]
  inspect(connection_exists(conns, 0, 0, 1, 0), content="true")
  inspect(connection_exists(conns, 1, 0, 0, 0), content="true")
  inspect(connection_exists(conns, 0, 0, 2, 0), content="false")
}

///|
test "tier_for_level returns correct tier" {
  inspect(tier_for_level(0), content="1")
  inspect(tier_for_level(6), content="1")
  inspect(tier_for_level(7), content="2")
  inspect(tier_for_level(13), content="2")
  inspect(tier_for_level(14), content="3")
  inspect(tier_for_level(19), content="3")
}

///|
test "level_unlocked logic" {
  let progress : Array[LevelProgress] = [
    { completed: true, stars: Bronze, best_waystones: 1, best_energy: 80.0, },
    { completed: false, stars: None, best_waystones: 0, best_energy: 0.0, },
    { completed: false, stars: None, best_waystones: 0, best_energy: 0.0, },
  ]
  inspect(level_unlocked(progress, 0), content="true")
  inspect(level_unlocked(progress, 1), content="true")
  inspect(level_unlocked(progress, 2), content="false")
}

///|
test "neighbor_connections finds neighbors" {
  let conns = [
    new_connection(1, 1, 2, 1),
    new_connection(1, 1, 1, 2),
    new_connection(3, 3, 4, 3),
  ]
  let neighbors = neighbor_connections(conns, 1, 1)
  assert_eq(neighbors.length(), 2)
}

///|
test "new_game creates valid initial state" {
  let game = new_game()
  assert_eq(game.screen, Title)
  assert_eq(game.progress.length(), total_levels)
  assert_eq(game.frame_count, 0)
  assert_eq(game.tool, PlaceWaystone)
}

///|
test "temple_required extracts requirement" {
  inspect(temple_required(Temple(50.0)), content="50")
  inspect(temple_required(Source), content="0")
  inspect(temple_required(Empty), content="0")
}

///|
test "sinf returns float values" {
  let val = sinf(0.0)
  inspect(val < 0.01 && val > -0.01, content="true")
}

///|
test "cosf returns float values" {
  let val = cosf(0.0)
  inspect(val > 0.99, content="true")
}
