///|
test "new_hex_grid has correct cell count" {
  let grid = @types.new_hex_grid()
  // radius=3 hex grid: 3*3*3 + 3*3 + 1 = 27+9+1 = 37 cells
  // Formula: 3*R^2 + 3*R + 1
  let expected = 3 * @types.grid_radius * @types.grid_radius +
    3 * @types.grid_radius +
    1
  assert_eq(@types.grid_cell_count(grid), expected)
}

///|
test "grid center exists" {
  let grid = @types.new_hex_grid()
  assert_true(@types.grid_in_bounds(grid, 0, 0))
}

///|
test "grid boundary cells" {
  let grid = @types.new_hex_grid()
  // (3,0) should be in bounds
  assert_true(@types.grid_in_bounds(grid, 3, 0))
  assert_true(@types.grid_in_bounds(grid, -3, 0))
  assert_true(@types.grid_in_bounds(grid, 0, 3))
  assert_true(@types.grid_in_bounds(grid, 0, -3))
  // (4,0) should be out of bounds
  assert_false(@types.grid_in_bounds(grid, 4, 0))
  // (2,2) should be out of bounds: |q|=2, |r|=2, |s|=|-2-2|=4 > 3
  assert_false(@types.grid_in_bounds(grid, 2, 2))
}

///|
test "grid_clear resets all cells" {
  let grid = @types.new_hex_grid()
  let cell = @types.grid_get(grid, 0, 0)
  match cell {
    Some(c) => {
      c.component = Some(Source)
      c.locked = true
    }
    None => ()
  }
  @types.grid_clear(grid)
  match @types.grid_get(grid, 0, 0) {
    Some(c) => {
      assert_eq(c.component, None)
      assert_eq(c.locked, false)
    }
    None => fail("Center cell missing after clear")
  }
}

///|
test "hex_to_pixel and pixel_to_hex roundtrip" {
  let grid = @types.new_hex_grid()
  let coords = @types.grid_all_coords(grid)
  for i in 0..<coords.length() {
    let (q, r) = coords[i]
    let px = @types.hex_to_pixel_x(q, r)
    let py = @types.hex_to_pixel_y(q, r)
    let (rq, rr) = @types.pixel_to_hex(px, py)
    assert_eq(rq, q)
    assert_eq(rr, r)
  }
}

///|
test "count_placed_components" {
  let grid = @types.new_hex_grid()
  match @types.grid_get(grid, 0, 0) {
    Some(c) => {
      c.component = Some(Crystal)
      c.locked = false
    }
    None => ()
  }
  match @types.grid_get(grid, 1, 0) {
    Some(c) => {
      c.component = Some(Source)
      c.locked = true
    }
    None => ()
  }
  // Only the crystal counts (sources/targets don't count, locked sources don't either)
  assert_eq(@types.count_placed_components(grid), 1)
}
