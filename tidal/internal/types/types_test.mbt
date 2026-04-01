///|
test "grid_in_bounds" {
  assert_true(grid_in_bounds(0, 0))
  assert_true(grid_in_bounds(11, 9))
  assert_true(!grid_in_bounds(-1, 0))
  assert_true(!grid_in_bounds(0, -1))
  assert_true(!grid_in_bounds(12, 0))
  assert_true(!grid_in_bounds(0, 10))
}

///|
test "grid_index" {
  assert_eq(grid_index(0, 0), 0)
  assert_eq(grid_index(1, 0), 1)
  assert_eq(grid_index(0, 1), grid_width)
  assert_eq(grid_index(5, 3), 3 * grid_width + 5)
}

///|
test "direction helpers" {
  // Up: dy=-1
  assert_eq(dir_dy(0), -1)
  assert_eq(dir_dx(0), 0)
  // Right: dx=1
  assert_eq(dir_dx(1), 1)
  assert_eq(dir_dy(1), 0)
  // Down: dy=1
  assert_eq(dir_dy(2), 1)
  // Left: dx=-1
  assert_eq(dir_dx(3), -1)
  // Opposite
  assert_eq(opposite_dir(0), 2)
  assert_eq(opposite_dir(1), 3)
  assert_eq(opposite_dir(2), 0)
  assert_eq(opposite_dir(3), 1)
}

///|
test "clone_grid preserves data" {
  let grid = new_wave_grid()
  let tile = grid_get(grid, 3, 4)
  tile.amplitude = 0.75
  tile.phase = 2
  tile.has_wall = true
  let cloned = clone_grid(grid)
  let ctile = grid_get(cloned, 3, 4)
  assert_true(ctile.amplitude > 0.74)
  assert_true(ctile.amplitude < 0.76)
  assert_eq(ctile.phase, 2)
  assert_true(ctile.has_wall)
  // Modifying clone doesn't affect original
  ctile.amplitude = 0.0
  assert_true(tile.amplitude > 0.74)
}

///|
test "phase_color returns different colors" {
  let c0 = phase_color(0)
  let c1 = phase_color(1)
  // They should be different
  assert_true(c0.r != c1.r || c0.g != c1.g || c0.b != c1.b)
}

///|
test "clampf" {
  assert_true(clampf(0.5, 0.0, 1.0) > 0.49)
  assert_true(clampf(-1.0, 0.0, 1.0) < 0.01)
  assert_true(clampf(2.0, 0.0, 1.0) > 0.99)
  assert_true(clampf(2.0, 0.0, 1.0) < 1.01)
}
