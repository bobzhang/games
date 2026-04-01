///|
test "trace beam straight through empty grid" {
  let grid = @types.new_hex_grid()
  // Place source at (0,0) facing East
  match @types.grid_get(grid, 0, 0) {
    Some(cell) => {
      cell.component = Some(Source)
      cell.direction = E
      cell.locked = true
    }
    None => fail("center cell missing")
  }
  let segments = trace_all_beams(grid)
  assert_true(segments.length() > 0)
}

///|
test "trace beam to target" {
  let grid = @types.new_hex_grid()
  // Source at (-3,0) facing E
  match @types.grid_get(grid, -3, 0) {
    Some(cell) => {
      cell.component = Some(Source)
      cell.direction = E
      cell.locked = true
    }
    None => fail("source cell missing")
  }
  // Target at (3,0) expecting white
  match @types.grid_get(grid, 3, 0) {
    Some(cell) => {
      cell.component = Some(Target)
      cell.direction = W
      cell.target_color = Some(@types.beam_color_white())
      cell.locked = true
    }
    None => fail("target cell missing")
  }
  let _segments = trace_all_beams(grid)
  assert_true(check_all_targets(grid))
}

///|
test "filter passes correct color" {
  let grid = @types.new_hex_grid()
  // Source at (-3,0) facing E, white
  match @types.grid_get(grid, -3, 0) {
    Some(cell) => {
      cell.component = Some(Source)
      cell.direction = E
      cell.locked = true
    }
    None => fail("source cell missing")
  }
  // Red filter at (0,0)
  match @types.grid_get(grid, 0, 0) {
    Some(cell) => {
      cell.component = Some(Filter)
      cell.direction = E
      cell.filter_color = Some(Red)
    }
    None => fail("filter cell missing")
  }
  // Target at (3,0) expecting red
  match @types.grid_get(grid, 3, 0) {
    Some(cell) => {
      cell.component = Some(Target)
      cell.direction = W
      cell.target_color = Some(@types.beam_color_red())
      cell.locked = true
    }
    None => fail("target cell missing")
  }
  let _segments = trace_all_beams(grid)
  assert_true(check_all_targets(grid))
}

///|
test "crystal refracts beam" {
  let grid = @types.new_hex_grid()
  // Source at (-3,0) facing E, white
  match @types.grid_get(grid, -3, 0) {
    Some(cell) => {
      cell.component = Some(Source)
      cell.direction = E
      cell.locked = true
    }
    None => fail("source cell missing")
  }
  // Crystal at (-1,0) refracting right (E->SE)
  match @types.grid_get(grid, -1, 0) {
    Some(cell) => {
      cell.component = Some(Crystal)
      cell.crystal_face = Some(Right60)
    }
    None => fail("crystal cell missing")
  }
  let segments = trace_all_beams(grid)
  // Should have at least 2 segments: source->crystal, crystal->edge
  assert_true(segments.length() >= 2)
  // The second segment should go SE direction
  if segments.length() >= 2 {
    assert_eq(segments[1].direction, SE)
  }
}

///|
test "mirror reflects beam" {
  let grid = @types.new_hex_grid()
  // Source at (-3,0) facing E
  match @types.grid_get(grid, -3, 0) {
    Some(cell) => {
      cell.component = Some(Source)
      cell.direction = E
      cell.locked = true
    }
    None => fail("source cell missing")
  }
  // Mirror at (0,0) facing NE: incoming E(0), facing NE(1),
  // reflected = (2*1-0)%6 = 2 => NW
  match @types.grid_get(grid, 0, 0) {
    Some(cell) => {
      cell.component = Some(Mirror)
      cell.direction = NE
    }
    None => fail("mirror cell missing")
  }
  let segments = trace_all_beams(grid)
  assert_true(segments.length() >= 2)
  if segments.length() >= 2 {
    assert_eq(segments[1].direction, NW)
  }
}

///|
test "target not satisfied with wrong color" {
  let grid = @types.new_hex_grid()
  // Source at (-3,0) facing E, white
  match @types.grid_get(grid, -3, 0) {
    Some(cell) => {
      cell.component = Some(Source)
      cell.direction = E
      cell.locked = true
    }
    None => fail("source cell missing")
  }
  // Target at (3,0) expecting red (but receives white)
  match @types.grid_get(grid, 3, 0) {
    Some(cell) => {
      cell.component = Some(Target)
      cell.direction = W
      cell.target_color = Some(@types.beam_color_red())
      cell.locked = true
    }
    None => fail("target cell missing")
  }
  let _segments = trace_all_beams(grid)
  assert_false(check_all_targets(grid))
}

///|
test "unlit target is not satisfied" {
  let grid = @types.new_hex_grid()
  // Target at (0,0) expecting white, but no source
  match @types.grid_get(grid, 0, 0) {
    Some(cell) => {
      cell.component = Some(Target)
      cell.target_color = Some(@types.beam_color_white())
      cell.locked = true
    }
    None => fail("target cell missing")
  }
  let _segments = trace_all_beams(grid)
  assert_false(check_all_targets(grid))
}

///|
test "multiple targets all satisfied" {
  let grid = @types.new_hex_grid()
  // Source at (-3,0) facing E, white
  match @types.grid_get(grid, -3, 0) {
    Some(cell) => {
      cell.component = Some(Source)
      cell.direction = E
      cell.locked = true
    }
    None => fail("source missing")
  }
  // Crystal at (-1,0) refracting right: E->SE
  match @types.grid_get(grid, -1, 0) {
    Some(cell) => {
      cell.component = Some(Crystal)
      cell.crystal_face = Some(Right60)
    }
    None => fail("crystal missing")
  }
  // Target at (0,1) in SE direction from (-1,0), expecting white
  match @types.grid_get(grid, -1, 1) {
    Some(cell) => {
      cell.component = Some(Target)
      cell.target_color = Some(@types.beam_color_white())
      cell.locked = true
    }
    None => fail("target missing")
  }
  let _segments = trace_all_beams(grid)
  assert_true(check_all_targets(grid))
}
