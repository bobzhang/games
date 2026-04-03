///|
test "tile_screen_x returns correct position" {
  let x = tile_screen_x(0)
  assert_eq(x, grid_offset_x)
  let x3 = tile_screen_x(3)
  assert_eq(x3, grid_offset_x + 3 * tile_size)
}

///|
test "tile_screen_y returns correct position" {
  let y = tile_screen_y(0)
  assert_eq(y, grid_offset_y)
  let y5 = tile_screen_y(5)
  assert_eq(y5, grid_offset_y + 5 * tile_size)
}

///|
test "screen_to_grid_col inverse" {
  let col = 4
  let sx = tile_screen_x(col) + tile_size / 2
  let c = screen_to_grid_col(sx)
  assert_eq(c, col)
}

///|
test "screen_to_grid_row inverse" {
  let row = 3
  let sy = tile_screen_y(row) + tile_size / 2
  let r = screen_to_grid_row(sy)
  assert_eq(r, row)
}

///|
test "in_grid boundary checks" {
  assert_true(in_grid(0, 0))
  assert_true(in_grid(9, 7))
  assert_false(in_grid(-1, 0))
  assert_false(in_grid(0, -1))
  assert_false(in_grid(10, 0))
  assert_false(in_grid(0, 8))
}

///|
test "tower_range includes elevation bonus" {
  assert_eq(tower_range(0), base_range)
  assert_eq(tower_range(1), base_range + 1)
  assert_eq(tower_range(3), base_range + 3)
}

///|
test "star_count mapping" {
  assert_eq(star_count(None), 0)
  assert_eq(star_count(One), 1)
  assert_eq(star_count(Two), 2)
  assert_eq(star_count(Three), 3)
}

///|
test "new_tile defaults" {
  let t = new_tile(Empty, 0)
  assert_eq(t.kind, Empty)
  assert_eq(t.elevation, 0)
  assert_false(t.has_signal)
}

///|
test "new_level_progress defaults" {
  let p = new_level_progress()
  assert_false(p.completed)
  assert_eq(p.stars, None)
  assert_eq(p.best_towers, 999)
}

///|
test "absf handles negatives" {
  assert_eq(absf(-3.0), 3.0)
  assert_eq(absf(5.0), 5.0)
  assert_eq(absf(0.0), 0.0)
}

///|
test "maxi and mini" {
  assert_eq(maxi(3, 7), 7)
  assert_eq(mini(3, 7), 3)
}
